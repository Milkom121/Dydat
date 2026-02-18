"""API auth — registrazione + login JWT."""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.sicurezza import crea_token, verifica_password
from app.db.crud.utenti import crea_utente, get_utente_by_email
from app.db.engine import get_db
from app.schemas.auth import LoginRequest, RegistraRequest, TokenResponse

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/registrazione", response_model=TokenResponse, status_code=201)
async def registrazione(
    payload: RegistraRequest,
    db: AsyncSession = Depends(get_db),
):
    """Registra nuovo utente e ritorna JWT."""
    try:
        utente = await crea_utente(db, payload.email, payload.password, payload.nome)
    except ValueError:
        raise HTTPException(status_code=409, detail="Email gia' registrata")
    token = crea_token(str(utente.id))
    return TokenResponse(access_token=token)


@router.post("/login", response_model=TokenResponse)
async def login(
    payload: LoginRequest,
    db: AsyncSession = Depends(get_db),
):
    """Login con email e password, ritorna JWT."""
    utente = await get_utente_by_email(db, payload.email)
    if utente is None or not verifica_password(payload.password, utente.password_hash):
        raise HTTPException(status_code=401, detail="Credenziali non valide")
    token = crea_token(str(utente.id))
    return TokenResponse(access_token=token)
