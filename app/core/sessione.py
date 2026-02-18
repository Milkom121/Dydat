"""Session Manager — gestione sessioni di studio.

Creazione, sospensione, ripresa, terminazione.
Scelta nodo a inizio sessione: sospesa → in_corso → path planner.
Sessione unica attiva per utente (409 / auto-sospensione 5 min).
"""

from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.stato_utente import StatoNodoUtente
from app.db.models.utenti import Sessione
from app.grafo.algoritmi import path_planner
from app.grafo.stato import get_livelli_utente
from app.grafo.struttura import grafo_knowledge

logger = logging.getLogger(__name__)

INATTIVITA_MAX_SEC = 5 * 60  # 5 minuti


class SessioneConflitto(Exception):
    """Esiste già una sessione attiva con meno di 5 min di inattività."""

    def __init__(self, sessione_id: uuid.UUID) -> None:
        self.sessione_id = sessione_id
        super().__init__(f"Sessione attiva esistente: {sessione_id}")


async def inizia_sessione(
    db: AsyncSession,
    utente_id: uuid.UUID,
    tipo: str = "media",
    durata_prevista_min: int | None = None,
) -> Sessione:
    """Crea una nuova sessione o riprende una sospesa.

    1. Controlla sessione attiva (409 se < 5 min, auto-sospendi se > 5 min)
    2. Cerca sessione sospesa da riprendere
    3. Altrimenti crea sessione nuova
    4. Sceglie il nodo focale

    Returns:
        La sessione creata o ripresa.

    Raises:
        SessioneConflitto: se esiste sessione attiva recente.
    """
    # 1. Controlla sessione attiva
    await _gestisci_sessione_attiva(db, utente_id)

    # 2. Cerca sessione sospesa da riprendere
    sessione = await _cerca_sessione_sospesa(db, utente_id)

    if sessione:
        # Riprendi sessione sospesa
        sessione.stato = "attiva"
        stato = sessione.stato_orchestratore or {}
        stato["ripresa"] = True
        stato["attivita_al_momento_sospensione"] = stato.get("attivita_corrente", "spiegazione")
        sessione.stato_orchestratore = stato
        await db.flush()
        logger.info(
            "Sessione ripresa: %s, nodo=%s",
            sessione.id,
            stato.get("nodo_focale_id"),
        )
        return sessione

    # 3. Crea sessione nuova
    sessione = Sessione(
        utente_id=utente_id,
        tipo=tipo,
        durata_prevista_min=durata_prevista_min,
        stato="attiva",
        nodi_lavorati=[],
        stato_orchestratore={},
    )
    db.add(sessione)
    await db.flush()

    # 4. Sceglie nodo focale
    nodo_id = await _scegli_nodo(db, utente_id)

    stato_orch: dict = {
        "nodo_focale_id": nodo_id,
        "attivita_corrente": "spiegazione" if nodo_id else None,
    }
    sessione.stato_orchestratore = stato_orch
    await db.flush()

    logger.info(
        "Nuova sessione: %s, tipo=%s, nodo=%s",
        sessione.id,
        tipo,
        nodo_id,
    )
    return sessione


async def sospendi_sessione(
    db: AsyncSession,
    sessione: Sessione,
) -> Sessione:
    """Salva lo stato dell'orchestratore e sospende la sessione.

    Calcola durata_effettiva_min e aggiorna stato → sospesa.
    """
    if sessione.stato != "attiva":
        raise ValueError(f"Sessione {sessione.id} non è attiva (stato={sessione.stato})")

    # Calcola durata
    durata = (datetime.now(timezone.utc) - sessione.created_at).total_seconds() / 60
    sessione.durata_effettiva_min = int(durata)

    # Annota nella stato_orchestratore il contesto di sospensione
    stato = sessione.stato_orchestratore or {}
    stato["ripresa"] = False
    stato["dettaglio_sospensione"] = (
        f"Sospesa dopo {int(durata)} minuti. "
        f"Attività: {stato.get('attivita_corrente', 'n/a')}."
    )
    sessione.stato_orchestratore = stato
    sessione.stato = "sospesa"
    await db.flush()

    logger.info("Sessione sospesa: %s (durata=%d min)", sessione.id, int(durata))
    return sessione


async def termina_sessione(
    db: AsyncSession,
    sessione: Sessione,
) -> Sessione:
    """Chiude la sessione e registra completamento."""
    if sessione.stato not in ("attiva", "sospesa"):
        raise ValueError(
            f"Sessione {sessione.id} non può essere terminata "
            f"(stato={sessione.stato})"
        )

    durata = (datetime.now(timezone.utc) - sessione.created_at).total_seconds() / 60
    sessione.durata_effettiva_min = int(durata)
    sessione.stato = "completata"
    sessione.completed_at = datetime.now(timezone.utc)
    await db.flush()

    logger.info("Sessione terminata: %s (durata=%d min)", sessione.id, int(durata))
    return sessione


async def get_sessione(
    db: AsyncSession,
    sessione_id: uuid.UUID,
    utente_id: uuid.UUID,
) -> Sessione | None:
    """Carica una sessione verificando che appartenga all'utente."""
    result = await db.execute(
        select(Sessione).where(
            Sessione.id == sessione_id,
            Sessione.utente_id == utente_id,
        )
    )
    return result.scalar_one_or_none()


# ===================================================================
# Helper interni
# ===================================================================


async def _gestisci_sessione_attiva(
    db: AsyncSession,
    utente_id: uuid.UUID,
) -> None:
    """Verifica e gestisce sessione attiva esistente.

    - Se < 5 min inattività: raise SessioneConflitto (409)
    - Se > 5 min inattività: auto-sospendi
    """
    result = await db.execute(
        select(Sessione).where(
            Sessione.utente_id == utente_id,
            Sessione.stato == "attiva",
        )
    )
    sessione_attiva = result.scalar_one_or_none()

    if sessione_attiva is None:
        return

    # Calcola inattività basandoci sul created_at della sessione
    # (in produzione si userebbe l'ultimo turno, qui usiamo created_at come proxy)
    inattivita = _calcola_inattivita(sessione_attiva)

    if inattivita < INATTIVITA_MAX_SEC:
        raise SessioneConflitto(sessione_attiva.id)

    # Auto-sospendi
    await sospendi_sessione(db, sessione_attiva)
    logger.info(
        "Sessione %s auto-sospesa per inattività (%d sec)",
        sessione_attiva.id,
        inattivita,
    )


def _calcola_inattivita(sessione: Sessione) -> float:
    """Calcola secondi di inattività dalla creazione o ultimo aggiornamento."""
    # Usiamo created_at; in futuro si potrà usare l'ultimo turno
    riferimento = sessione.created_at
    if riferimento.tzinfo is None:
        from datetime import timezone as tz
        riferimento = riferimento.replace(tzinfo=tz.utc)
    return (datetime.now(timezone.utc) - riferimento).total_seconds()


async def _cerca_sessione_sospesa(
    db: AsyncSession,
    utente_id: uuid.UUID,
) -> Sessione | None:
    """Cerca la sessione sospesa più recente dell'utente."""
    result = await db.execute(
        select(Sessione)
        .where(
            Sessione.utente_id == utente_id,
            Sessione.stato == "sospesa",
        )
        .order_by(Sessione.created_at.desc())
        .limit(1)
    )
    return result.scalar_one_or_none()


async def _scegli_nodo(
    db: AsyncSession,
    utente_id: uuid.UUID,
) -> str | None:
    """Sceglie il nodo focale per una nuova sessione.

    Priorità:
    1. Nodi in_corso (spiegazione iniziata ma non completata)
    2. Path planner (prossimo nodo sbloccato)
    """
    # 1. Cerca nodo in_corso
    result = await db.execute(
        select(StatoNodoUtente.nodo_id)
        .where(
            StatoNodoUtente.utente_id == utente_id,
            StatoNodoUtente.livello == "in_corso",
        )
        .order_by(StatoNodoUtente.ultima_interazione.desc())
        .limit(1)
    )
    nodo_in_corso = result.scalar_one_or_none()
    if nodo_in_corso:
        logger.info("Nodo in_corso trovato: %s", nodo_in_corso)
        return nodo_in_corso

    # 2. Path planner
    if not grafo_knowledge.caricato:
        logger.warning("Grafo non caricato — impossibile scegliere nodo")
        return None

    livelli = await get_livelli_utente(utente_id, db)
    prossimo = path_planner(grafo_knowledge.grafo, livelli)

    if prossimo:
        logger.info("Path planner → nodo: %s", prossimo)
    else:
        logger.info("Percorso completato — nessun nodo da studiare")

    return prossimo
