"""API utente — profilo, preferenze, statistiche."""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_utente_corrente
from app.db.crud.utenti import aggiorna_profilo
from app.db.engine import get_db
from app.db.models.utenti import Utente
from app.schemas.utente import PreferenzeRequest, UtenteResponse

router = APIRouter(prefix="/utente", tags=["utente"])


@router.get("/me", response_model=UtenteResponse)
async def get_profilo(utente: Utente = Depends(get_utente_corrente)):
    """Ritorna il profilo dell'utente autenticato."""
    return utente


@router.put("/me/preferenze", response_model=UtenteResponse)
async def update_preferenze(
    payload: PreferenzeRequest,
    utente: Utente = Depends(get_utente_corrente),
    db: AsyncSession = Depends(get_db),
):
    """Aggiorna le preferenze del tutor per l'utente autenticato."""
    preferenze = utente.preferenze_tutor or {}
    aggiornamenti = payload.model_dump(exclude_none=True)
    preferenze.update(aggiornamenti)
    try:
        utente = await aggiorna_profilo(db, utente.id, preferenze_tutor=preferenze)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    return utente


@router.get("/me/statistiche")
async def get_statistiche(utente: Utente = Depends(get_utente_corrente)):
    """Statistiche utente (settimana/mese/sempre)."""
    raise HTTPException(status_code=501, detail="Blocco 11 — non implementato")
