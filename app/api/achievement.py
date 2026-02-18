"""API achievement — sbloccati + prossimi con progresso."""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_utente_corrente
from app.core.gamification import lista_achievement_utente
from app.db.engine import get_db
from app.db.models.utenti import Utente
from app.schemas.achievement import ListaAchievementResponse

router = APIRouter(prefix="/achievement", tags=["achievement"])


@router.get("/", response_model=ListaAchievementResponse)
async def lista_achievement(
    utente: Utente = Depends(get_utente_corrente),
    db: AsyncSession = Depends(get_db),
) -> ListaAchievementResponse:
    """Ritorna achievement sbloccati + prossimi con progresso."""
    risultato = await lista_achievement_utente(utente.id, db)
    return ListaAchievementResponse(**risultato)
