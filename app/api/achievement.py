"""API achievement — sbloccati + prossimi."""

from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/achievement", tags=["achievement"])


@router.get("/")
async def lista_achievement():
    raise HTTPException(status_code=501, detail="Non implementato")
