"""CRUD utenti — accesso al database SOLO tramite queste funzioni."""

import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.sicurezza import hash_password
from app.db.models.utenti import Utente


async def crea_utente(
    db: AsyncSession,
    email: str,
    password: str,
    nome: str,
) -> Utente:
    """Crea un nuovo utente con password hashata.

    Raises:
        ValueError: se l'email e' gia' registrata.
    """
    esistente = await get_utente_by_email(db, email)
    if esistente is not None:
        raise ValueError(f"Email gia' registrata: {email}")

    utente = Utente(
        email=email,
        password_hash=hash_password(password),
        nome=nome,
    )
    db.add(utente)
    await db.commit()
    await db.refresh(utente)
    return utente


async def get_utente_by_email(db: AsyncSession, email: str) -> Utente | None:
    """Ritorna utente per email, o None."""
    result = await db.execute(select(Utente).where(Utente.email == email))
    return result.scalar_one_or_none()


async def get_utente_by_id(db: AsyncSession, utente_id: uuid.UUID) -> Utente | None:
    """Ritorna utente per UUID, o None."""
    result = await db.execute(select(Utente).where(Utente.id == utente_id))
    return result.scalar_one_or_none()


async def aggiorna_profilo(
    db: AsyncSession,
    utente_id: uuid.UUID,
    **kwargs,
) -> Utente:
    """Aggiorna campi del profilo utente.

    Raises:
        ValueError: se l'utente non esiste.
    """
    utente = await get_utente_by_id(db, utente_id)
    if utente is None:
        raise ValueError(f"Utente non trovato: {utente_id}")

    campi_ammessi = {
        "nome", "preferenze_tutor", "contesto_personale",
        "materie_attive", "obiettivo_giornaliero_min", "impostazioni_promemoria",
    }
    for campo, valore in kwargs.items():
        if campo not in campi_ammessi:
            raise ValueError(f"Campo non ammesso: {campo}")
        setattr(utente, campo, valore)

    await db.commit()
    await db.refresh(utente)
    return utente
