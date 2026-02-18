"""Pydantic schemas per achievement / gamification."""

from __future__ import annotations

from pydantic import BaseModel


class ProgressoAchievement(BaseModel):
    corrente: int
    richiesto: int


class AchievementSbloccato(BaseModel):
    id: str
    nome: str
    tipo: str
    descrizione: str | None = None
    sbloccato_at: str | None = None


class AchievementProssimo(BaseModel):
    id: str
    nome: str
    tipo: str
    descrizione: str | None = None
    condizione: dict
    progresso: ProgressoAchievement


class ListaAchievementResponse(BaseModel):
    sbloccati: list[AchievementSbloccato]
    prossimi: list[AchievementProssimo]
