"""API sessione — CUORE dell'interazione tutoring.

Endpoint HTTP che collegano il motore al frontend.
SSE streaming via sse-starlette.
Nessuna logica di business — tutto delegato a core/.
"""

from __future__ import annotations

import json
import logging
import uuid
from collections.abc import AsyncGenerator

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm.attributes import flag_modified
from sse_starlette.sse import EventSourceResponse

from app.api.deps import get_utente_corrente
from app.core.sessione import (
    SessioneConflitto,
    get_sessione,
    inizia_sessione,
    sospendi_sessione,
    termina_sessione,
)
from app.core.turno import esegui_turno
from app.core.gamification import aggiorna_statistiche_giornaliere, verifica_achievement
from app.db.engine import get_db
from app.db.models.utenti import Utente
from app.schemas.sessione import (
    IniziaSessioneRequest,
    SessioneConflittoResponse,
    SessioneResponse,
    TurnoRequest,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/sessione", tags=["sessione"])


# ===================================================================
# Helper: genera stream SSE da eventi turno
# ===================================================================


async def _genera_stream_sse(
    db: AsyncSession,
    sessione_id: uuid.UUID,
    utente_id: uuid.UUID,
    messaggio_utente: str | None = None,
    evento_iniziale: dict | None = None,
) -> AsyncGenerator[dict, None]:
    """Genera eventi SSE dal turno, con opzionale evento iniziale.

    Yield dict con "event" e "data" per EventSourceResponse.
    """
    if evento_iniziale:
        yield {"event": evento_iniziale["event"], "data": json.dumps(evento_iniziale["data"])}

    async for evento in esegui_turno(
        db=db,
        sessione_id=sessione_id,
        utente_id=utente_id,
        messaggio_utente=messaggio_utente,
    ):
        yield {
            "event": evento["event"],
            "data": json.dumps(evento["data"]),
        }


# ===================================================================
# POST /sessione/inizia → SSE stream
# ===================================================================


@router.post("/inizia")
async def api_inizia_sessione(
    body: IniziaSessioneRequest | None = None,
    utente: Utente = Depends(get_utente_corrente),
    db: AsyncSession = Depends(get_db),
):
    """Avvia sessione, sceglie nodo, genera primo turno tutor via SSE.

    Response: text/event-stream con evento sessione_creata + stream turno.
    409: se esiste sessione attiva con < 5 min inattività.
    """
    tipo = body.tipo if body else "media"
    durata = body.durata_prevista_min if body else None

    try:
        sessione = await inizia_sessione(
            db=db,
            utente_id=utente.id,
            tipo=tipo,
            durata_prevista_min=durata,
        )
    except SessioneConflitto as e:
        raise HTTPException(
            status_code=409,
            detail=SessioneConflittoResponse(
                sessione_id_esistente=e.sessione_id,
                messaggio="Sessione attiva esistente con meno di 5 minuti di inattività",
            ).model_dump(mode="json"),
        )

    await db.commit()

    stato_orch = sessione.stato_orchestratore or {}
    nodo_id = stato_orch.get("nodo_focale_id")

    # Recupera nome nodo dal grafo (se disponibile)
    nodo_nome = None
    if nodo_id:
        from app.grafo.struttura import grafo_knowledge
        if grafo_knowledge.caricato and nodo_id in grafo_knowledge.grafo.nodes:
            nodo_nome = grafo_knowledge.grafo.nodes[nodo_id].get("nome", nodo_id)

    evento_iniziale = {
        "event": "sessione_creata",
        "data": {
            "sessione_id": str(sessione.id),
            "nodo_id": nodo_id,
            "nodo_nome": nodo_nome,
        },
    }

    return EventSourceResponse(
        _genera_stream_sse(
            db=db,
            sessione_id=sessione.id,
            utente_id=utente.id,
            messaggio_utente=None,  # Primo turno senza messaggio utente
            evento_iniziale=evento_iniziale,
        )
    )


# ===================================================================
# POST /sessione/{id}/turno → SSE stream
# ===================================================================


@router.post("/{sessione_id}/turno")
async def api_turno_sessione(
    sessione_id: uuid.UUID,
    body: TurnoRequest,
    utente: Utente = Depends(get_utente_corrente),
    db: AsyncSession = Depends(get_db),
):
    """Messaggio studente → SSE stream risposta tutor."""
    sessione = await get_sessione(db, sessione_id, utente.id)
    if sessione is None:
        raise HTTPException(status_code=404, detail="Sessione non trovata")
    if sessione.stato != "attiva":
        raise HTTPException(
            status_code=400,
            detail=f"Sessione non attiva (stato={sessione.stato})",
        )

    # Dopo il primo turno, rimuovi il flag ripresa
    stato = sessione.stato_orchestratore or {}
    if stato.get("ripresa"):
        stato["ripresa"] = False
        sessione.stato_orchestratore = stato
        flag_modified(sessione, "stato_orchestratore")
        await db.flush()

    return EventSourceResponse(
        _genera_stream_sse(
            db=db,
            sessione_id=sessione.id,
            utente_id=utente.id,
            messaggio_utente=body.messaggio,
        )
    )


# ===================================================================
# POST /sessione/{id}/sospendi
# ===================================================================


@router.post("/{sessione_id}/sospendi")
async def api_sospendi_sessione(
    sessione_id: uuid.UUID,
    utente: Utente = Depends(get_utente_corrente),
    db: AsyncSession = Depends(get_db),
):
    """Sospende la sessione salvando lo stato orchestratore."""
    sessione = await get_sessione(db, sessione_id, utente.id)
    if sessione is None:
        raise HTTPException(status_code=404, detail="Sessione non trovata")

    try:
        sessione = await sospendi_sessione(db, sessione)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    await db.commit()
    return _sessione_to_response(sessione)


# ===================================================================
# POST /sessione/{id}/termina
# ===================================================================


@router.post("/{sessione_id}/termina")
async def api_termina_sessione(
    sessione_id: uuid.UUID,
    utente: Utente = Depends(get_utente_corrente),
    db: AsyncSession = Depends(get_db),
):
    """Chiude la sessione."""
    sessione = await get_sessione(db, sessione_id, utente.id)
    if sessione is None:
        raise HTTPException(status_code=404, detail="Sessione non trovata")

    try:
        sessione = await termina_sessione(db, sessione)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    # Aggiorna statistiche e verifica achievement post-terminazione
    # (necessario perché achievement come "prima_sessione" dipendono da
    # sessioni_completate che cambia solo alla terminazione)
    try:
        await aggiorna_statistiche_giornaliere(utente.id, db)
        await verifica_achievement(utente.id, db)
    except Exception:
        logger.warning(
            "Errore post-terminazione stats/achievement (non bloccante)",
            exc_info=True,
        )

    await db.commit()
    return _sessione_to_response(sessione)


# ===================================================================
# GET /sessione/{id}
# ===================================================================


@router.get("/{sessione_id}")
async def api_get_sessione(
    sessione_id: uuid.UUID,
    utente: Utente = Depends(get_utente_corrente),
    db: AsyncSession = Depends(get_db),
):
    """Stato sessione."""
    sessione = await get_sessione(db, sessione_id, utente.id)
    if sessione is None:
        raise HTTPException(status_code=404, detail="Sessione non trovata")
    return _sessione_to_response(sessione)


# ===================================================================
# Helper
# ===================================================================


def _sessione_to_response(sessione) -> dict:
    """Converte Sessione ORM → dict di risposta."""
    stato_orch = sessione.stato_orchestratore or {}
    nodo_id = stato_orch.get("nodo_focale_id")

    nodo_nome = None
    if nodo_id:
        from app.grafo.struttura import grafo_knowledge
        if grafo_knowledge.caricato and nodo_id in grafo_knowledge.grafo.nodes:
            nodo_nome = grafo_knowledge.grafo.nodes[nodo_id].get("nome", nodo_id)

    return SessioneResponse(
        id=sessione.id,
        stato=sessione.stato,
        tipo=sessione.tipo,
        nodo_focale_id=nodo_id,
        nodo_focale_nome=nodo_nome,
        attivita_corrente=stato_orch.get("attivita_corrente"),
        durata_prevista_min=sessione.durata_prevista_min,
        durata_effettiva_min=sessione.durata_effettiva_min,
        nodi_lavorati=sessione.nodi_lavorati,
    ).model_dump(mode="json")
