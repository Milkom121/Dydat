"""API onboarding — flusso di conoscenza iniziale.

POST /onboarding/inizia → crea utente temp + sessione onboarding + SSE
POST /onboarding/turno → turno conversazione onboarding (SSE)
POST /onboarding/completa → finalizza, crea percorso
"""

from __future__ import annotations

import json
import logging
import uuid
from collections.abc import AsyncGenerator

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sse_starlette.sse import EventSourceResponse

from app.core.onboarding import (
    aggiorna_fase_onboarding,
    completa_onboarding,
    crea_sessione_onboarding,
    crea_utente_temporaneo,
)
from app.core.turno import esegui_turno
from app.db.engine import get_db
from app.db.models.utenti import Sessione, Utente
from app.schemas.onboarding import (
    OnboardingCompletaRequest,
    OnboardingCompletaResponse,
    OnboardingIniziaResponse,
    OnboardingTurnoRequest,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/onboarding", tags=["onboarding"])


# ===================================================================
# Helper: genera stream SSE
# ===================================================================


async def _genera_stream_onboarding(
    db: AsyncSession,
    sessione_id: uuid.UUID,
    utente_id: uuid.UUID,
    messaggio_utente: str | None = None,
    evento_iniziale: dict | None = None,
) -> AsyncGenerator[dict, None]:
    """Genera eventi SSE per turno onboarding."""
    if evento_iniziale:
        yield {
            "event": evento_iniziale["event"],
            "data": json.dumps(evento_iniziale["data"]),
        }

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
# POST /onboarding/inizia
# ===================================================================


@router.post("/inizia")
async def api_inizia_onboarding(
    db: AsyncSession = Depends(get_db),
):
    """Crea utente temporaneo + sessione onboarding + primo turno SSE.

    Non richiede auth — l'utente non esiste ancora.
    Response: evento onboarding_iniziato + SSE stream primo turno tutor.
    """
    # Crea utente temporaneo
    utente = await crea_utente_temporaneo(db)

    # Crea sessione onboarding
    sessione = await crea_sessione_onboarding(db, utente.id)

    await db.commit()

    evento_iniziale = {
        "event": "onboarding_iniziato",
        "data": OnboardingIniziaResponse(
            utente_temp_id=utente.id,
            sessione_id=sessione.id,
        ).model_dump(mode="json"),
    }

    return EventSourceResponse(
        _genera_stream_onboarding(
            db=db,
            sessione_id=sessione.id,
            utente_id=utente.id,
            messaggio_utente=None,
            evento_iniziale=evento_iniziale,
        )
    )


# ===================================================================
# POST /onboarding/turno
# ===================================================================


@router.post("/turno")
async def api_turno_onboarding(
    body: OnboardingTurnoRequest,
    db: AsyncSession = Depends(get_db),
):
    """Turno conversazione onboarding (SSE).

    Non richiede auth — usa sessione_id come identificativo.
    Gestisce automaticamente le transizioni di fase.
    """
    sessione = await _carica_sessione_onboarding(db, body.sessione_id)

    # Aggiorna fase automaticamente
    await aggiorna_fase_onboarding(db, sessione)

    return EventSourceResponse(
        _genera_stream_onboarding(
            db=db,
            sessione_id=sessione.id,
            utente_id=sessione.utente_id,
            messaggio_utente=body.messaggio,
        )
    )


# ===================================================================
# POST /onboarding/completa
# ===================================================================


@router.post("/completa")
async def api_completa_onboarding(
    body: OnboardingCompletaRequest,
    db: AsyncSession = Depends(get_db),
):
    """Finalizza onboarding: salva profilo, crea percorso, inizializza stato.

    Non richiede auth — usa sessione_id come identificativo.
    """
    sessione = await _carica_sessione_onboarding(db, body.sessione_id)

    # Carica utente
    result = await db.execute(
        select(Utente).where(Utente.id == sessione.utente_id)
    )
    utente = result.scalar_one_or_none()
    if utente is None:
        raise HTTPException(status_code=404, detail="Utente non trovato")

    risultato = await completa_onboarding(
        db=db,
        sessione=sessione,
        utente=utente,
        contesto_personale=body.contesto_personale,
        preferenze_tutor=body.preferenze_tutor,
    )

    await db.commit()

    return OnboardingCompletaResponse(
        percorso_id=risultato["percorso_id"],
        nodo_iniziale=risultato["nodo_iniziale"],
        nodi_inizializzati=risultato["nodi_inizializzati"],
    )


# ===================================================================
# Helper
# ===================================================================


async def _carica_sessione_onboarding(
    db: AsyncSession,
    sessione_id: uuid.UUID,
) -> Sessione:
    """Carica e valida una sessione onboarding."""
    result = await db.execute(
        select(Sessione).where(Sessione.id == sessione_id)
    )
    sessione = result.scalar_one_or_none()

    if sessione is None:
        raise HTTPException(status_code=404, detail="Sessione non trovata")
    if sessione.tipo != "onboarding":
        raise HTTPException(
            status_code=400, detail="Non è una sessione onboarding"
        )
    if sessione.stato != "attiva":
        raise HTTPException(
            status_code=400,
            detail=f"Sessione onboarding non attiva (stato={sessione.stato})",
        )

    return sessione
