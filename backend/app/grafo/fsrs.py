"""FSRS — Spaced Repetition (Loop 5, implementato con FSRS6).

Usa la libreria `fsrs` su PyPI per calcolare intervalli di ripasso adattivi.
Algoritmo FSRS6: stima stabilità e difficoltà memoria per ogni nodo utente.

Mappatura esiti → Rating FSRS:
  primo_tentativo → Good  (risposta corretta al primo colpo)
  con_guida       → Hard  (risposta corretta con aiuto/difficoltà)
  non_risolto     → Again (risposta sbagliata, da rivedere)

Il JSON completo della Card FSRS viene salvato in sr_card_json per garantire
la ricostruzione esatta dello stato (state, step, stability, difficulty, ecc.)
tra una sessione e l'altra.
"""

from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.stato_utente import StatoNodoUtente

logger = logging.getLogger(__name__)

# Importazione lazy per compatibilità ambienti senza libreria
try:
    from fsrs import Card, Rating, Scheduler

    _FSRS_AVAILABLE = True
    _scheduler = Scheduler()
except ImportError:
    _FSRS_AVAILABLE = False
    _scheduler = None  # type: ignore[assignment]

# Mappatura esito esercizio → nome Rating FSRS
ESITO_TO_RATING: dict[str, str] = {
    "primo_tentativo": "Good",
    "con_guida": "Hard",
    "non_risolto": "Again",
}


def _crea_card_da_stato(stato: StatoNodoUtente | None) -> "Card | None":
    """Ricostruisce una Card FSRS dallo stato DB.

    Usa sr_card_json (JSON serializzato della Card) per ricostruzione esatta.
    Se sr_card_json è assente (prima review), ritorna Card() nuova.
    Ritorna None se la libreria fsrs non è disponibile.
    """
    if not _FSRS_AVAILABLE:
        return None

    if stato is None or stato.sr_card_json is None:
        # Prima review per questo nodo: carta nuova
        return Card()  # type: ignore[misc]

    # Ricostruisce Card dal JSON serializzato salvato nel DB
    try:
        import json

        card_json_str = json.dumps(stato.sr_card_json)
        return Card.from_json(card_json_str)  # type: ignore[misc]
    except Exception as exc:
        logger.warning(
            "Fallback a Card() nuova per errore ricostruzione (nodo=%s): %s",
            getattr(stato, "nodo_id", "?"),
            exc,
        )
        return Card()  # type: ignore[misc]


async def calcola_prossimo_ripasso(
    utente_id: uuid.UUID,
    nodo_id: str,
    esito: str,
    db: AsyncSession,
) -> None:
    """Calcola e persiste il prossimo ripasso FSRS per un nodo utente.

    Aggiorna i campi sr_* e sr_card_json in stato_nodi_utente dopo ogni esercizio.
    Se la libreria fsrs non è installata, logga e ritorna silenziosamente.

    Args:
        utente_id: UUID dell'utente.
        nodo_id: ID del nodo appena esercitato.
        esito: "primo_tentativo", "con_guida" o "non_risolto".
        db: sessione DB async.
    """
    if not _FSRS_AVAILABLE:
        logger.warning("Libreria fsrs non disponibile — SR non aggiornato per nodo=%s", nodo_id)
        return

    # Mappa esito → Rating (fallback su Again per esiti non mappati)
    rating_name = ESITO_TO_RATING.get(esito, "Again")
    rating = getattr(Rating, rating_name)  # type: ignore[misc]

    # Carica stato SR corrente
    result = await db.execute(
        select(StatoNodoUtente).where(
            StatoNodoUtente.utente_id == utente_id,
            StatoNodoUtente.nodo_id == nodo_id,
        )
    )
    stato = result.scalar_one_or_none()

    card = _crea_card_da_stato(stato)
    if card is None:
        return

    # Calcola nuovo scheduling FSRS
    now = datetime.now(timezone.utc)
    card, _review_log = _scheduler.review_card(card, rating, now)  # type: ignore[misc]

    # Calcola intervallo in giorni (frazionario per ripasso a breve termine in Learning)
    delta = card.due - now
    intervallo_giorni = max(0.0, delta.total_seconds() / 86400.0)
    ripetizioni_precedenti = stato.sr_ripetizioni if stato is not None else None
    nuove_ripetizioni = (ripetizioni_precedenti or 0) + 1

    # Serializza Card completa per ricostruzione esatta alla prossima sessione
    import json

    card_json_dict = json.loads(card.to_json())

    update_values: dict = {
        "sr_prossimo_ripasso": card.due,
        "sr_intervallo_giorni": intervallo_giorni,
        "sr_ripetizioni": nuove_ripetizioni,
        "sr_stabilita": card.stability,
        "sr_difficolta": card.difficulty,
        "sr_card_json": card_json_dict,
    }

    if stato is not None:
        # Record esiste: aggiorna direttamente
        for campo, valore in update_values.items():
            setattr(stato, campo, valore)
        await db.flush()
    else:
        # Record non esiste ancora: UPSERT
        stmt = pg_insert(StatoNodoUtente).values(
            utente_id=utente_id,
            nodo_id=nodo_id,
            **update_values,
        )
        stmt = stmt.on_conflict_do_update(
            index_elements=["utente_id", "nodo_id"],
            set_=update_values,
        )
        await db.execute(stmt)
        await db.flush()

    logger.info(
        "FSRS: nodo=%s esito=%s → prossimo ripasso %s (tra %.1f giorni, stabilità=%s)",
        nodo_id,
        esito,
        card.due.date(),
        intervallo_giorni,
        f"{card.stability:.2f}" if card.stability else "n/a",
    )


async def get_nodi_da_ripassare(
    utente_id: uuid.UUID,
    db: AsyncSession,
) -> list[str]:
    """Ritorna i nodi che necessitano ripasso oggi (sr_prossimo_ripasso <= now()).

    Considera solo nodi con almeno una review SR completata (sr_card_json IS NOT NULL).
    Usato da B27 per interleaving e da B28 per badge/sezione ripasso.

    Args:
        utente_id: UUID dell'utente.
        db: sessione DB async.

    Returns:
        Lista di nodo_id da ripassare, ordinati per data scadenza.
    """
    now = datetime.now(timezone.utc)

    result = await db.execute(
        select(StatoNodoUtente.nodo_id)
        .where(
            StatoNodoUtente.utente_id == utente_id,
            StatoNodoUtente.sr_prossimo_ripasso <= now,
            StatoNodoUtente.sr_card_json.is_not(None),
        )
        .order_by(StatoNodoUtente.sr_prossimo_ripasso)  # più urgente (scaduto prima) per primo
    )
    return [row[0] for row in result.all()]
