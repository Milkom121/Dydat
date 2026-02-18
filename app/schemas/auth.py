"""Schemas Pydantic v2 per autenticazione."""

from pydantic import BaseModel, EmailStr


class RegistraRequest(BaseModel):
    email: EmailStr
    password: str
    nome: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
