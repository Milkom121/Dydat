"""Action Executor + Signal Processor.

Action Executor: processa le azioni fire-and-forget dal tutor LLM.
Signal Processor: aggiorna stati in base ai segnali accumulati.

Logica promozione Loop 1:
  in_corso → operativo quando:
    1. spiegazione_data = true
    2. esercizi_completati >= 3
    3. almeno 1 esercizio con esito = 'primo_tentativo' nello storico
"""

from __future__ import annotations

import logging
import random
import uuid
from datetime import datetime, timezone

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.grafo import Esercizio
from app.db.models.stato_utente import StatoNodoUtente, StoricoEsercizi
from app.db.models.utenti import Sessione
from app.grafo.algoritmi import nodi_sbloccati_dopo_promozione
from app.grafo.stato import get_livelli_utente
from app.grafo.struttura import grafo_knowledge

logger = logging.getLogger(__name__)

# Mapping difficoltà: base→1-2, intermedio→3, avanzato→4-5
DIFFICOLTA_MAPPING: dict[str, tuple[int, int]] = {
    "base": (1, 2),
    "intermedio": (3, 3),
    "avanzato": (4, 5),
}

ESERCIZI_PER_PROMOZIONE = 3


# ===================================================================
# Action Executor
# ===================================================================


async def esegui_azione(
    db: AsyncSession,
    azione: dict,
    sessione_id: uuid.UUID,
    utente_id: uuid.UUID,
) -> dict | None:
    """Esegue un'azione del tutor. Ritorna dati per evento SSE o None.

    Le azioni Loop 1 vengono processate.
    Le azioni Loop 2-3 vengono loggate.
    """
    nome = azione.get("name", "")
    params = azione.get("input", {})

    if nome == "proponi_esercizio":
        return await _esegui_proponi_esercizio(db, params, sessione_id)
    elif nome == "mostra_formula":
        return {"tipo": "mostra_formula", "params": params}
    elif nome == "suggerisci_backtrack":
        return {"tipo": "suggerisci_backtrack", "params": params}
    elif nome == "chiudi_sessione":
        return await _esegui_chiudi_sessione(db, params, sessione_id)
    else:
        # Loop 2-3 stubs — log e ignora
        logger.info(
            "Azione Loop 2-3 ignorata: %s (params=%s)", nome, params
        )
        return {"tipo": nome, "params": params, "stub": True}


async def _esegui_proponi_esercizio(
    db: AsyncSession,
    params: dict,
    sessione_id: uuid.UUID,
) -> dict:
    """Seleziona un esercizio dal banco per nodo e difficoltà."""
    nodo_id = params.get("nodo_id", "")
    difficolta_str = params.get("difficolta", "base")
    evita_ids = params.get("evita_ids", [])

    min_diff, max_diff = DIFFICOLTA_MAPPING.get(difficolta_str, (1, 2))

    # Query esercizi disponibili
    query = (
        select(Esercizio)
        .where(
            Esercizio.nodo_id == nodo_id,
            Esercizio.difficolta >= min_diff,
            Esercizio.difficolta <= max_diff,
        )
    )
    if evita_ids:
        query = query.where(Esercizio.id.notin_(evita_ids))

    result = await db.execute(query)
    esercizi = list(result.scalars().all())

    if not esercizi:
        # Fallback: prova con range più ampio
        result_fallback = await db.execute(
            select(Esercizio)
            .where(Esercizio.nodo_id == nodo_id)
            .where(Esercizio.id.notin_(evita_ids) if evita_ids else True)
        )
        esercizi = list(result_fallback.scalars().all())

    if not esercizi:
        logger.warning(
            "Nessun esercizio per nodo=%s, difficoltà=%s",
            nodo_id, difficolta_str,
        )
        return {
            "tipo": "proponi_esercizio",
            "params": {
                "nodo_id": nodo_id,
                "nessun_esercizio_disponibile": True,
            },
        }

    esercizio = random.choice(esercizi)

    # Aggiorna stato_orchestratore con esercizio corrente
    sessione = await db.execute(
        select(Sessione).where(Sessione.id == sessione_id)
    )
    sess = sessione.scalar_one_or_none()
    if sess:
        stato = sess.stato_orchestratore or {}
        stato["attivita_corrente"] = "esercizio"
        stato["esercizio_corrente_id"] = esercizio.id
        stato["esercizio_corrente_testo"] = esercizio.testo
        stato["esercizio_corrente_soluzione"] = esercizio.soluzione
        stato["numero_tentativo"] = 1
        stato["tentativi_bc"] = 0
        sess.stato_orchestratore = stato
        await db.flush()

    return {
        "tipo": "proponi_esercizio",
        "params": {
            "esercizio_id": esercizio.id,
            "testo": esercizio.testo,
            "difficolta": esercizio.difficolta,
            "nodo_id": nodo_id,
        },
    }


async def _esegui_chiudi_sessione(
    db: AsyncSession,
    params: dict,
    sessione_id: uuid.UUID,
) -> dict:
    """Chiude la sessione salvando il riepilogo."""
    sessione = await db.execute(
        select(Sessione).where(Sessione.id == sessione_id)
    )
    sess = sessione.scalar_one_or_none()
    if sess:
        sess.stato = "completata"
        sess.riepilogo = params.get("riepilogo", "")
        sess.completed_at = datetime.now(timezone.utc)
        await db.flush()

    return {"tipo": "chiudi_sessione", "params": params}


# ===================================================================
# Signal Processor
# ===================================================================


async def processa_segnali(
    db: AsyncSession,
    segnali: list[dict],
    sessione_id: uuid.UUID,
    utente_id: uuid.UUID,
) -> list[dict]:
    """Processa i segnali accumulati. Ritorna lista promozioni avvenute.

    Returns:
        Lista di dict con promozioni: [{"nodo_id": ..., "nuovo_livello": ...}]
    """
    promozioni: list[dict] = []

    for segnale in segnali:
        nome = segnale.get("name", "")
        params = segnale.get("input", {})

        if nome == "concetto_spiegato":
            await _processa_concetto_spiegato(db, params, utente_id)
        elif nome == "risposta_esercizio":
            promo = await _processa_risposta_esercizio(
                db, params, utente_id, sessione_id
            )
            if promo:
                promozioni.append(promo)
        elif nome == "confusione_rilevata":
            _log_segnale("confusione_rilevata", params)
        elif nome == "energia_utente":
            _log_segnale("energia_utente", params)
        elif nome == "prossimo_passo_raccomandato":
            await _processa_prossimo_passo(db, params, sessione_id)
        elif nome == "punto_partenza_suggerito":
            await _processa_punto_partenza(db, params, sessione_id)
        else:
            # Loop 3 segnali — log senza processare
            _log_segnale(nome, params)

    return promozioni


def _log_segnale(nome: str, params: dict) -> None:
    logger.info("Segnale %s: %s", nome, params)


async def _processa_concetto_spiegato(
    db: AsyncSession,
    params: dict,
    utente_id: uuid.UUID,
) -> None:
    """concetto_spiegato → aggiorna spiegazione_data, livello in_corso."""
    nodo_id = params.get("nodo_id", "")
    if not nodo_id:
        return

    # UPSERT stato nodo utente
    from sqlalchemy.dialects.postgresql import insert as pg_insert

    stmt = pg_insert(StatoNodoUtente).values(
        utente_id=utente_id,
        nodo_id=nodo_id,
        livello="in_corso",
        spiegazione_data=True,
        ultima_interazione=datetime.now(timezone.utc),
    )
    stmt = stmt.on_conflict_do_update(
        index_elements=["utente_id", "nodo_id"],
        set_={
            "spiegazione_data": True,
            "livello": "in_corso",
            "ultima_interazione": datetime.now(timezone.utc),
        },
    )
    await db.execute(stmt)
    await db.flush()

    logger.info(
        "Concetto spiegato: nodo=%s, utente=%s → in_corso",
        nodo_id, utente_id,
    )


async def _processa_risposta_esercizio(
    db: AsyncSession,
    params: dict,
    utente_id: uuid.UUID,
    sessione_id: uuid.UUID,
) -> dict | None:
    """risposta_esercizio → storico, contatori, verifica promozione.

    Returns:
        Dict con promozione se avvenuta, None altrimenti.
    """
    esercizio_id = params.get("esercizio_id", "")
    nodo_focale = params.get("nodo_focale", "")
    esito = params.get("esito", "non_risolto")

    if not nodo_focale:
        return None

    # 1. Salva nello storico_esercizi
    storico = StoricoEsercizi(
        utente_id=utente_id,
        nodo_focale_id=nodo_focale,
        esercizio_id=esercizio_id or None,
        esito=esito,
        nodo_causa_id=params.get("nodo_causa"),
        nodi_coinvolti=params.get("nodi_coinvolti"),
        tipo_errore=params.get("tipo_errore"),
        sessione_id=sessione_id,
    )
    db.add(storico)
    await db.flush()

    # 2. Aggiorna contatori su stato_nodi_utente
    from sqlalchemy.dialects.postgresql import insert as pg_insert

    # Assicura che il record esista
    stmt = pg_insert(StatoNodoUtente).values(
        utente_id=utente_id,
        nodo_id=nodo_focale,
        livello="in_corso",
        esercizi_completati=1,
        esercizi_consecutivi_ok=1 if esito == "primo_tentativo" else 0,
        ultima_interazione=datetime.now(timezone.utc),
    )
    stmt = stmt.on_conflict_do_update(
        index_elements=["utente_id", "nodo_id"],
        set_={
            "esercizi_completati": StatoNodoUtente.esercizi_completati + 1,
            "esercizi_consecutivi_ok": (
                StatoNodoUtente.esercizi_consecutivi_ok + 1
                if esito == "primo_tentativo"
                else 0
            ),
            "errori_in_corso": (
                StatoNodoUtente.errori_in_corso + (
                    1 if esito == "non_risolto" else 0
                )
            ),
            "ultima_interazione": datetime.now(timezone.utc),
        },
    )
    await db.execute(stmt)
    await db.flush()

    logger.info(
        "Risposta esercizio: nodo=%s, esito=%s, utente=%s",
        nodo_focale, esito, utente_id,
    )

    # 3. Verifica promozione
    promozione = await _verifica_promozione(db, utente_id, nodo_focale)
    return promozione


async def _verifica_promozione(
    db: AsyncSession,
    utente_id: uuid.UUID,
    nodo_id: str,
) -> dict | None:
    """Verifica se il nodo può essere promosso da in_corso a operativo.

    Condizioni (tutte devono essere vere):
    1. spiegazione_data = true
    2. esercizi_completati >= 3
    3. almeno 1 esercizio con esito = 'primo_tentativo' nello storico
    """
    # Carica stato corrente
    result = await db.execute(
        select(StatoNodoUtente).where(
            StatoNodoUtente.utente_id == utente_id,
            StatoNodoUtente.nodo_id == nodo_id,
        )
    )
    stato = result.scalar_one_or_none()

    if stato is None:
        return None
    if stato.livello != "in_corso":
        return None
    if not stato.spiegazione_data:
        return None
    if stato.esercizi_completati < ESERCIZI_PER_PROMOZIONE:
        return None

    # Controlla almeno 1 primo_tentativo
    result_pt = await db.execute(
        select(func.count()).where(
            StoricoEsercizi.utente_id == utente_id,
            StoricoEsercizi.nodo_focale_id == nodo_id,
            StoricoEsercizi.esito == "primo_tentativo",
        )
    )
    primo_tentativo_count = result_pt.scalar_one()

    if primo_tentativo_count < 1:
        return None

    # Promozione!
    stato.livello = "operativo"
    stato.ultima_interazione = datetime.now(timezone.utc)
    await db.flush()

    logger.info(
        "PROMOZIONE: nodo=%s → operativo, utente=%s",
        nodo_id, utente_id,
    )

    # Cascata sblocco
    nodi_sbloccati = await _cascata_sblocco(db, utente_id, nodo_id)

    return {
        "nodo_id": nodo_id,
        "nuovo_livello": "operativo",
        "nodi_sbloccati": nodi_sbloccati,
    }


async def _cascata_sblocco(
    db: AsyncSession,
    utente_id: uuid.UUID,
    nodo_promosso: str,
) -> list[str]:
    """Dopo promozione, verifica e logga quali nodi sono ora sbloccati."""
    if not grafo_knowledge.caricato:
        return []

    livelli = await get_livelli_utente(utente_id, db)
    # Assicura che il nodo promosso sia aggiornato nella mappa
    livelli[nodo_promosso] = "operativo"

    sbloccati = nodi_sbloccati_dopo_promozione(
        grafo_knowledge.grafo, nodo_promosso, livelli
    )

    if sbloccati:
        logger.info(
            "Cascata sblocco dopo %s: %s",
            nodo_promosso, sbloccati,
        )

    return sbloccati


async def _processa_prossimo_passo(
    db: AsyncSession,
    params: dict,
    sessione_id: uuid.UUID,
) -> None:
    """prossimo_passo_raccomandato → salva nella sessione."""
    result = await db.execute(
        select(Sessione).where(Sessione.id == sessione_id)
    )
    sess = result.scalar_one_or_none()
    if not sess:
        return

    stato = sess.stato_orchestratore or {}
    tipo_passo = params.get("tipo", "continua_spiegazione")

    # Aggiorna attivita_corrente solo per tipi mappabili
    mapping_attivita = {
        "continua_spiegazione": "spiegazione",
        "esercizio": "esercizio",
        "feynman": "feynman",
        "ripasso": "ripasso_sr",
        "backtrack": "spiegazione",
        "chiudi_sessione": stato.get("attivita_corrente", "spiegazione"),
    }

    if tipo_passo in mapping_attivita:
        stato["attivita_corrente"] = mapping_attivita[tipo_passo]

    stato["prossimo_passo"] = params
    sess.stato_orchestratore = stato
    await db.flush()


async def _processa_punto_partenza(
    db: AsyncSession,
    params: dict,
    sessione_id: uuid.UUID,
) -> None:
    """punto_partenza_suggerito → salva nella sessione (onboarding)."""
    result = await db.execute(
        select(Sessione).where(Sessione.id == sessione_id)
    )
    sess = result.scalar_one_or_none()
    if not sess:
        return

    stato = sess.stato_orchestratore or {}
    stato["punto_partenza_suggerito"] = params.get("tema_o_concetto", "")
    stato["punto_partenza_motivazione"] = params.get("motivazione", "")
    sess.stato_orchestratore = stato
    await db.flush()

    logger.info(
        "Punto partenza suggerito: %s (sessione=%s)",
        params.get("tema_o_concetto"), sessione_id,
    )


# ===================================================================
# Aggiornamento nodo focale dopo promozione
# ===================================================================


async def aggiorna_nodo_dopo_promozione(
    db: AsyncSession,
    sessione_id: uuid.UUID,
    utente_id: uuid.UUID,
    nodo_promosso: str,
) -> str | None:
    """Dopo promozione, calcola prossimo nodo e aggiorna la sessione.

    Returns:
        ID del prossimo nodo, o None se percorso completato.
    """
    from app.grafo.algoritmi import path_planner

    if not grafo_knowledge.caricato:
        return None

    livelli = await get_livelli_utente(utente_id, db)
    livelli[nodo_promosso] = "operativo"

    # Tema del nodo promosso per tie-break
    tema_corrente = grafo_knowledge.grafo.nodes.get(
        nodo_promosso, {}
    ).get("tema_id")

    prossimo = path_planner(
        grafo_knowledge.grafo, livelli, tema_corrente
    )

    # Aggiorna sessione
    result = await db.execute(
        select(Sessione).where(Sessione.id == sessione_id)
    )
    sess = result.scalar_one_or_none()
    if sess:
        stato = sess.stato_orchestratore or {}
        stato["nodo_focale_id"] = prossimo
        stato["attivita_corrente"] = "spiegazione" if prossimo else None
        # Aggiungi nodo promosso ai lavorati
        lavorati = sess.nodi_lavorati or []
        if nodo_promosso not in lavorati:
            lavorati.append(nodo_promosso)
        sess.nodi_lavorati = lavorati
        sess.stato_orchestratore = stato
        await db.flush()

    if prossimo:
        logger.info(
            "Prossimo nodo dopo promozione %s: %s",
            nodo_promosso, prossimo,
        )
    else:
        logger.info(
            "Percorso completato! Nodo promosso: %s", nodo_promosso
        )

    return prossimo
