"""Schemas Pydantic v2 per sessione."""

import uuid

from pydantic import BaseModel


class IniziaSessioneRequest(BaseModel):
    tipo: str = "media"
    durata_prevista_min: int | None = None


class TurnoRequest(BaseModel):
    messaggio: str


class SessioneResponse(BaseModel):
    id: uuid.UUID
    stato: str
    tipo: str | None = None
    nodo_focale_id: str | None = None
    nodo_focale_nome: str | None = None
    attivita_corrente: str | None = None
    durata_prevista_min: int | None = None
    durata_effettiva_min: int | None = None
    nodi_lavorati: list[str] | None = None

    model_config = {"from_attributes": True}


class SessioneConflittoResponse(BaseModel):
    sessione_id_esistente: uuid.UUID
    messaggio: str
