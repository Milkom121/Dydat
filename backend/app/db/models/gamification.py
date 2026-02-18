"""Gruppo 4 — Note, gamification, statistiche."""

import uuid
from datetime import date, datetime

from sqlalchemy import Boolean, Date, ForeignKey, Integer, Text, text
from sqlalchemy.dialects.postgresql import JSONB, TIMESTAMP, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class NotaUtente(Base):
    __tablename__ = "note_utente"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    utente_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("utenti.id"), nullable=False
    )
    nodo_id: Mapped[str | None] = mapped_column(Text, ForeignKey("nodi.id"))
    tema_id: Mapped[str | None] = mapped_column(Text, ForeignKey("temi.id"))
    contenuto: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(TIMESTAMP(timezone=True), server_default=text("now()"))
    updated_at: Mapped[datetime] = mapped_column(TIMESTAMP(timezone=True), server_default=text("now()"))


class StatoTemaUtente(Base):
    __tablename__ = "stato_temi_utente"

    utente_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("utenti.id"), primary_key=True
    )
    tema_id: Mapped[str] = mapped_column(Text, ForeignKey("temi.id"), primary_key=True)
    stato: Mapped[str | None] = mapped_column(Text)
    riepilogo_ai: Mapped[str | None] = mapped_column(Text)


class AchievementDefinizione(Base):
    __tablename__ = "achievement_definizioni"

    id: Mapped[str] = mapped_column(Text, primary_key=True)
    nome: Mapped[str] = mapped_column(Text, nullable=False)
    descrizione: Mapped[str | None] = mapped_column(Text)
    tipo: Mapped[str] = mapped_column(Text, nullable=False)
    condizione: Mapped[dict | None] = mapped_column(JSONB)
    rarita: Mapped[str | None] = mapped_column(Text)


class AchievementUtente(Base):
    __tablename__ = "achievement_utente"

    utente_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("utenti.id"), primary_key=True
    )
    achievement_id: Mapped[str] = mapped_column(
        Text, ForeignKey("achievement_definizioni.id"), primary_key=True
    )
    sbloccato_at: Mapped[datetime] = mapped_column(TIMESTAMP(timezone=True), server_default=text("now()"))


class StatisticaGiornaliera(Base):
    __tablename__ = "statistiche_giornaliere"

    utente_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("utenti.id"), primary_key=True
    )
    data: Mapped[date] = mapped_column(Date, primary_key=True)
    minuti_studio: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    nodi_completati: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    esercizi_svolti: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    esercizi_corretti: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    obiettivo_raggiunto: Mapped[bool] = mapped_column(Boolean, server_default=text("false"))
