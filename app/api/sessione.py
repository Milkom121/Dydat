"""API sessione — CUORE dell'interazione tutoring."""

from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/sessione", tags=["sessione"])


@router.post("/inizia")
async def inizia_sessione():
    raise HTTPException(status_code=501, detail="Non implementato")


@router.post("/{sessione_id}/turno")
async def turno_sessione(sessione_id: str):
    raise HTTPException(status_code=501, detail="Non implementato")


@router.post("/{sessione_id}/sospendi")
async def sospendi_sessione(sessione_id: str):
    raise HTTPException(status_code=501, detail="Non implementato")


@router.post("/{sessione_id}/termina")
async def termina_sessione(sessione_id: str):
    raise HTTPException(status_code=501, detail="Non implementato")


@router.get("/{sessione_id}")
async def get_sessione(sessione_id: str):
    raise HTTPException(status_code=501, detail="Non implementato")
