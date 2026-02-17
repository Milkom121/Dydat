"""API onboarding — flusso di conoscenza iniziale."""

from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/onboarding", tags=["onboarding"])


@router.post("/inizia")
async def inizia_onboarding():
    raise HTTPException(status_code=501, detail="Non implementato")


@router.post("/turno")
async def turno_onboarding():
    raise HTTPException(status_code=501, detail="Non implementato")


@router.post("/completa")
async def completa_onboarding():
    raise HTTPException(status_code=501, detail="Non implementato")
