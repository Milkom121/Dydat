"""API percorsi — lista percorsi, mappa nodi."""

from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/percorsi", tags=["percorsi"])


@router.get("/")
async def lista_percorsi():
    raise HTTPException(status_code=501, detail="Non implementato")


@router.get("/{percorso_id}/mappa")
async def mappa_nodi(percorso_id: int):
    raise HTTPException(status_code=501, detail="Non implementato")
