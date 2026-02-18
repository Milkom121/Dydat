"""Schemas Pydantic v2 per autenticazione."""

import uuid

from pydantic import BaseModel, EmailStr


class RegistraRequest(BaseModel):
    email: EmailStr
    password: str
    nome: str
    utente_temp_id: uuid.UUID | None = None


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
