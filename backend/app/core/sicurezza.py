"""Sicurezza — JWT e hashing password.

Modulo core (non HTTP): usato sia da api/auth che da api/deps.
Usa bcrypt direttamente (passlib ha problemi con bcrypt >= 5.0).
"""

from datetime import datetime, timedelta, timezone

import bcrypt
from jose import JWTError, jwt

from app.config import settings


def hash_password(password: str) -> str:
    """Genera hash bcrypt della password."""
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verifica_password(password: str, password_hash: str) -> bool:
    """Verifica password in chiaro contro hash bcrypt."""
    return bcrypt.checkpw(password.encode("utf-8"), password_hash.encode("utf-8"))


def crea_token(utente_id: str) -> str:
    """Crea JWT con claim sub=utente_id e scadenza configurata."""
    expire = datetime.now(timezone.utc) + timedelta(hours=settings.JWT_EXPIRE_HOURS)
    payload = {"sub": utente_id, "exp": expire}
    return jwt.encode(payload, settings.JWT_SECRET, algorithm="HS256")


def verifica_token(token: str) -> str:
    """Decodifica e valida JWT. Ritorna utente_id.

    Raises:
        ValueError: se il token e' invalido o scaduto.
    """
    try:
        payload = jwt.decode(token, settings.JWT_SECRET, algorithms=["HS256"])
        utente_id: str | None = payload.get("sub")
        if utente_id is None:
            raise ValueError("Token senza claim 'sub'")
        return utente_id
    except JWTError as e:
        raise ValueError(f"Token non valido: {e}") from e
