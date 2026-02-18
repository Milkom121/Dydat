"""API auth — registrazione + login JWT."""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.sicurezza import crea_token, hash_password, verifica_password
from app.db.crud.utenti import crea_utente, get_utente_by_email, get_utente_by_id
from app.db.engine import get_db
from app.schemas.auth import LoginRequest, RegistraRequest, TokenResponse

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/registrazione", response_model=TokenResponse, status_code=201)
async def registrazione(
    payload: RegistraRequest,
    db: AsyncSession = Depends(get_db),
):
    """Registra nuovo utente e ritorna JWT.

    Se utente_temp_id è fornito, converte l'utente temporaneo in utente
    registrato invece di crearne uno nuovo. Tutti i dati (percorso, sessioni,
    stato nodi) restano collegati allo stesso UUID.
    """
    if payload.utente_temp_id is not None:
        return await _converti_utente_temporaneo(payload, db)

    try:
        utente = await crea_utente(db, payload.email, payload.password, payload.nome)
    except ValueError:
        raise HTTPException(status_code=409, detail="Email gia' registrata")
    token = crea_token(str(utente.id))
    return TokenResponse(access_token=token)


async def _converti_utente_temporaneo(
    payload: RegistraRequest,
    db: AsyncSession,
) -> TokenResponse:
    """Converte un utente temporaneo (onboarding) in utente registrato."""
    # 1. Verifica che l'utente temporaneo esista
    utente_temp = await get_utente_by_id(db, payload.utente_temp_id)
    if utente_temp is None:
        raise HTTPException(status_code=404, detail="Utente temporaneo non trovato")

    # 2. Verifica che sia effettivamente temporaneo (email=null)
    if utente_temp.email is not None:
        raise HTTPException(status_code=400, detail="Utente gia' registrato")

    # 3. Verifica che l'email non sia già usata da un altro utente
    esistente = await get_utente_by_email(db, payload.email)
    if esistente is not None:
        raise HTTPException(status_code=409, detail="Email gia' registrata")

    # 4. Aggiorna l'utente temporaneo con i dati di registrazione
    utente_temp.email = payload.email
    utente_temp.password_hash = hash_password(payload.password)
    utente_temp.nome = payload.nome
    await db.commit()
    await db.refresh(utente_temp)

    # 5. Genera JWT con lo stesso UUID
    token = crea_token(str(utente_temp.id))
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
