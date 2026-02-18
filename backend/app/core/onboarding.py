"""Onboarding Manager — flusso di conoscenza iniziale.

Fasi: accoglienza → conoscenza (automatico dopo 1° scambio) → conclusione.
Al completamento: salva profilo, crea percorso, inizializza stato_nodi_utente.
Punto di partenza personalizzato via segnale punto_partenza_suggerito.
"""

from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm.attributes import flag_modified

from app.db.models.stato_utente import StatoNodoUtente
from app.db.models.utenti import PercorsoUtente, Sessione, TurnoConversazione, Utente
from app.grafo.algoritmi import ordinamento_topologico
from app.grafo.struttura import grafo_knowledge

logger = logging.getLogger(__name__)

# Dopo quanti turni in "conoscenza" si passa a "conclusione"
TURNI_CONOSCENZA_MAX = 8


async def crea_utente_temporaneo(db: AsyncSession) -> Utente:
    """Crea un utente temporaneo (UUID, senza email/password)."""
    utente = Utente(
        materie_attive=["matematica"],
    )
    db.add(utente)
    await db.flush()
    logger.info("Utente temporaneo creato: %s", utente.id)
    return utente


async def crea_sessione_onboarding(
    db: AsyncSession,
    utente_id: uuid.UUID,
) -> Sessione:
    """Crea una sessione di tipo onboarding con fase accoglienza."""
    sessione = Sessione(
        utente_id=utente_id,
        tipo="onboarding",
        stato="attiva",
        nodi_lavorati=[],
        stato_orchestratore={
            "fase_onboarding": "accoglienza",
            "turni_conoscenza": 0,
        },
    )
    db.add(sessione)
    await db.flush()
    logger.info("Sessione onboarding creata: %s", sessione.id)
    return sessione


async def aggiorna_fase_onboarding(
    db: AsyncSession,
    sessione: Sessione,
) -> str:
    """Aggiorna automaticamente la fase onboarding e ritorna la fase corrente.

    Logica:
    - Primo turno: accoglienza
    - Dopo 1° risposta studente: conoscenza
    - Dopo TURNI_CONOSCENZA_MAX turni in conoscenza O chiudi_sessione: conclusione
    """
    stato = sessione.stato_orchestratore or {}
    fase = stato.get("fase_onboarding", "accoglienza")

    if fase == "accoglienza":
        # Conta turni utente nella sessione
        result = await db.execute(
            select(func.count()).where(
                TurnoConversazione.sessione_id == sessione.id,
                TurnoConversazione.ruolo == "utente",
            )
        )
        turni_utente = result.scalar_one()

        if turni_utente >= 1:
            fase = "conoscenza"
            stato["fase_onboarding"] = fase
            stato["turni_conoscenza"] = 0
            sessione.stato_orchestratore = stato
            flag_modified(sessione, "stato_orchestratore")
            await db.flush()
            logger.info("Onboarding: accoglienza → conoscenza")

    elif fase == "conoscenza":
        turni = stato.get("turni_conoscenza", 0) + 1
        stato["turni_conoscenza"] = turni

        if turni >= TURNI_CONOSCENZA_MAX:
            fase = "conclusione"
            stato["fase_onboarding"] = fase
            sessione.stato_orchestratore = stato
            flag_modified(sessione, "stato_orchestratore")
            await db.flush()
            logger.info("Onboarding: conoscenza → conclusione (max turni)")
        else:
            sessione.stato_orchestratore = stato
            flag_modified(sessione, "stato_orchestratore")
            await db.flush()

    return fase


async def completa_onboarding(
    db: AsyncSession,
    sessione: Sessione,
    utente: Utente,
    contesto_personale: dict | None = None,
    preferenze_tutor: dict | None = None,
) -> dict:
    """Completa l'onboarding: salva profilo, crea percorso, inizializza stato.

    Returns:
        Dict con {percorso_id, nodo_iniziale, nodi_inizializzati}.
    """
    # 1. Salva profilo utente
    if contesto_personale:
        utente.contesto_personale = contesto_personale
    if preferenze_tutor:
        utente.preferenze_tutor = preferenze_tutor
    await db.flush()

    # 2. Chiudi sessione onboarding
    sessione.stato = "completata"
    sessione.completed_at = datetime.now(timezone.utc)
    durata = (
        datetime.now(timezone.utc) - sessione.created_at
    ).total_seconds() / 60
    sessione.durata_effettiva_min = int(durata)
    await db.flush()

    # 3. Gestisci punto di partenza personalizzato
    stato = sessione.stato_orchestratore or {}
    punto_partenza = stato.get("punto_partenza_suggerito")
    nodo_override = None

    if punto_partenza and grafo_knowledge.caricato:
        nodo_override = _trova_nodo_per_tema(punto_partenza)

    # 4. Crea percorso binario_1
    percorso = PercorsoUtente(
        utente_id=utente.id,
        tipo="binario_1",
        materia="matematica",
        nome="Percorso Matematica",
        stato="attivo",
        nodo_iniziale_override=nodo_override,
    )
    db.add(percorso)
    await db.flush()

    # 5. Inizializza stato_nodi_utente per tutti i nodi operativi
    nodi_init = await _inizializza_stato_nodi(
        db, utente.id, nodo_override
    )

    logger.info(
        "Onboarding completato: utente=%s, percorso=%d, "
        "nodo_override=%s, nodi_init=%d",
        utente.id,
        percorso.id,
        nodo_override,
        nodi_init,
    )

    return {
        "percorso_id": percorso.id,
        "nodo_iniziale": nodo_override,
        "nodi_inizializzati": nodi_init,
    }


def _trova_nodo_per_tema(tema_o_concetto: str) -> str | None:
    """Cerca nel grafo il nodo più vicino al tema/concetto indicato.

    Match per nome nodo o tema_id (case-insensitive, substring).
    """
    if not grafo_knowledge.caricato:
        return None

    query = tema_o_concetto.lower().replace(" ", "_")
    grafo = grafo_knowledge.grafo

    # Match per tema_id (spazi normalizzati a underscore)
    for nodo_id, attrs in grafo.nodes(data=True):
        if attrs.get("tipo_nodo") != "operativo":
            continue
        tema_id = attrs.get("tema_id", "")
        if tema_id and query in tema_id.lower():
            return nodo_id

    # Fallback: match per nodo_id
    for nodo_id in grafo.nodes:
        if query in nodo_id.lower():
            return nodo_id

    return None


async def _inizializza_stato_nodi(
    db: AsyncSession,
    utente_id: uuid.UUID,
    nodo_override: str | None,
) -> int:
    """Inizializza stato_nodi_utente per tutti i nodi operativi.

    Se c'è un nodo_override, i nodi precedenti nell'ordine topologico
    vengono marcati come operativo + presunto=true.

    Returns:
        Numero di nodi inizializzati.
    """
    if not grafo_knowledge.caricato:
        return 0

    grafo = grafo_knowledge.grafo
    ordine = ordinamento_topologico(grafo)
    nodi_prima_override: set[str] = set()

    if nodo_override and nodo_override in ordine:
        idx = ordine.index(nodo_override)
        nodi_prima_override = set(ordine[:idx])

    from sqlalchemy.dialects.postgresql import insert as pg_insert

    count = 0
    for nodo_id in ordine:
        attrs = grafo.nodes.get(nodo_id, {})
        if attrs.get("tipo_nodo") != "operativo":
            continue

        if nodo_id in nodi_prima_override:
            # Nodo prima del punto di partenza → operativo + presunto
            stmt = pg_insert(StatoNodoUtente).values(
                utente_id=utente_id,
                nodo_id=nodo_id,
                livello="operativo",
                presunto=True,
                spiegazione_data=False,
                ultima_interazione=datetime.now(timezone.utc),
            )
            stmt = stmt.on_conflict_do_nothing(
                index_elements=["utente_id", "nodo_id"]
            )
        else:
            # Nodo normale → non_iniziato
            stmt = pg_insert(StatoNodoUtente).values(
                utente_id=utente_id,
                nodo_id=nodo_id,
                livello="non_iniziato",
                presunto=False,
                spiegazione_data=False,
                ultima_interazione=datetime.now(timezone.utc),
            )
            stmt = stmt.on_conflict_do_nothing(
                index_elements=["utente_id", "nodo_id"]
            )

        await db.execute(stmt)
        count += 1

    await db.flush()
    return count
