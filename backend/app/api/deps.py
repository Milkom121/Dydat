"""Dipendenze FastAPI — autenticazione JWT."""

import uuid

from fastapi import Depends, Header, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.sicurezza import verifica_token
from app.db.crud.utenti import get_utente_by_id
from app.db.engine import get_db
from app.db.models.utenti import Utente


async def get_utente_corrente(
    authorization: str = Header(..., description="Bearer <token>"),
    db: AsyncSession = Depends(get_db),
) -> Utente:
    """Estrae e valida JWT dall'header Authorization, ritorna l'utente corrente.

    Raises:
        HTTPException 401: se il token manca, e' invalido, o l'utente non esiste.
    """
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Formato Authorization non valido")

    token = authorization.removeprefix("Bearer ")

    try:
        utente_id_str = verifica_token(token)
    except ValueError:
        raise HTTPException(status_code=401, detail="Token non valido")

    try:
        utente_id = uuid.UUID(utente_id_str)
    except ValueError:
        raise HTTPException(status_code=401, detail="Token non valido")

    utente = await get_utente_by_id(db, utente_id)
    if utente is None:
        raise HTTPException(status_code=401, detail="Utente non trovato")

    return utente
