"""Schemas Pydantic v2 per onboarding."""

import uuid

from pydantic import BaseModel


class OnboardingIniziaResponse(BaseModel):
    utente_temp_id: uuid.UUID
    sessione_id: uuid.UUID


class OnboardingTurnoRequest(BaseModel):
    sessione_id: uuid.UUID
    messaggio: str


class OnboardingCompletaRequest(BaseModel):
    sessione_id: uuid.UUID
    contesto_personale: dict | None = None
    preferenze_tutor: dict | None = None


class OnboardingCompletaResponse(BaseModel):
    percorso_id: int
    nodo_iniziale: str | None = None
    nodi_inizializzati: int
