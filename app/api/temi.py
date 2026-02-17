"""API temi — dettaglio tema con progresso."""

from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/temi", tags=["temi"])


@router.get("/")
async def lista_temi():
    raise HTTPException(status_code=501, detail="Non implementato")


@router.get("/{tema_id}")
async def dettaglio_tema(tema_id: str):
    raise HTTPException(status_code=501, detail="Non implementato")
