"""Schemas Pydantic v2 per profilo utente."""

import uuid

from pydantic import BaseModel


class UtenteResponse(BaseModel):
    id: uuid.UUID
    email: str | None
    nome: str | None
    preferenze_tutor: dict | None = None
    contesto_personale: dict | None = None
    materie_attive: list[str] | None = None
    obiettivo_giornaliero_min: int

    model_config = {"from_attributes": True}


class PreferenzeRequest(BaseModel):
    """Preferenze tutor aggiornabili dall'utente. Tutti i campi opzionali."""

    input: str | None = None
    velocita: str | None = None
    incoraggiamento: str | None = None
