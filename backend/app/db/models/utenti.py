"""Gruppo 3 — Utenti, sessioni, conversazioni."""

import uuid
from datetime import datetime

from sqlalchemy import Float, ForeignKey, Index, Integer, Text, text
from sqlalchemy.dialects.postgresql import ARRAY, JSONB, TIMESTAMP, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Utente(Base):
    __tablename__ = "utenti"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()")
    )
    email: Mapped[str | None] = mapped_column(Text, unique=True)
    password_hash: Mapped[str | None] = mapped_column(Text)
    nome: Mapped[str | None] = mapped_column(Text)

    profilo_sintetizzato: Mapped[dict | None] = mapped_column(JSONB)
    profilo_sintetizzato_at: Mapped[datetime | None] = mapped_column(TIMESTAMP(timezone=True))
    preferenze_tutor: Mapped[dict | None] = mapped_column(JSONB)
    contesto_personale: Mapped[dict | None] = mapped_column(JSONB)
    materie_attive: Mapped[list | None] = mapped_column(ARRAY(Text))
    obiettivo_giornaliero_min: Mapped[int] = mapped_column(Integer, server_default=text("20"))
    impostazioni_promemoria: Mapped[dict | None] = mapped_column(JSONB)

    created_at: Mapped[datetime] = mapped_column(TIMESTAMP(timezone=True), server_default=text("now()"))
    updated_at: Mapped[datetime] = mapped_column(TIMESTAMP(timezone=True), server_default=text("now()"))


class PercorsoUtente(Base):
    __tablename__ = "percorsi_utente"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    utente_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("utenti.id"), nullable=False
    )
    tipo: Mapped[str] = mapped_column(Text, nullable=False)
    materia: Mapped[str] = mapped_column(Text, nullable=False)
    nome: Mapped[str | None] = mapped_column(Text)
    descrizione_obiettivo: Mapped[str | None] = mapped_column(Text)
    nodi_target: Mapped[list | None] = mapped_column(ARRAY(Text))
    nodo_iniziale_override: Mapped[str | None] = mapped_column(Text, ForeignKey("nodi.id"))
    stato: Mapped[str] = mapped_column(Text, server_default="attivo")
    created_at: Mapped[datetime] = mapped_column(TIMESTAMP(timezone=True), server_default=text("now()"))
    updated_at: Mapped[datetime] = mapped_column(TIMESTAMP(timezone=True), server_default=text("now()"))


class Sessione(Base):
    __tablename__ = "sessioni"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()")
    )
    utente_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("utenti.id"), nullable=False
    )
    tipo: Mapped[str | None] = mapped_column(Text)
    durata_prevista_min: Mapped[int | None] = mapped_column(Integer)
    durata_effettiva_min: Mapped[int | None] = mapped_column(Integer)
    nodi_lavorati: Mapped[list | None] = mapped_column(ARRAY(Text))
    attivita_svolte: Mapped[dict | None] = mapped_column(JSONB)
    riepilogo: Mapped[str | None] = mapped_column(Text)
    stato: Mapped[str] = mapped_column(Text, server_default="attiva")
    stato_orchestratore: Mapped[dict | None] = mapped_column(JSONB)
    created_at: Mapped[datetime] = mapped_column(TIMESTAMP(timezone=True), server_default=text("now()"))
    completed_at: Mapped[datetime | None] = mapped_column(TIMESTAMP(timezone=True))

    __table_args__ = (
        Index("ix_sessioni_utente_stato", "utente_id", "stato"),
    )


class TurnoConversazione(Base):
    __tablename__ = "turni_conversazione"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    sessione_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("sessioni.id"), nullable=False
    )
    ordine: Mapped[int] = mapped_column(Integer, nullable=False)
    ruolo: Mapped[str] = mapped_column(Text, nullable=False)
    contenuto: Mapped[str | None] = mapped_column(Text)
    azioni: Mapped[dict | None] = mapped_column(JSONB)
    segnali: Mapped[dict | None] = mapped_column(JSONB)
    nodo_focale_id: Mapped[str | None] = mapped_column(Text, ForeignKey("nodi.id"))
    modello: Mapped[str | None] = mapped_column(Text)
    token_input: Mapped[int | None] = mapped_column(Integer)
    token_output: Mapped[int | None] = mapped_column(Integer)
    costo_stimato: Mapped[float | None] = mapped_column(Float)
    created_at: Mapped[datetime] = mapped_column(TIMESTAMP(timezone=True), server_default=text("now()"))

    __table_args__ = (
        Index("ix_turni_conversazione_sessione_ordine", "sessione_id", "ordine"),
    )
