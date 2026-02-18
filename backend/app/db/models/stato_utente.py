"""Gruppo 2 — Stato utente sul grafo: stato_nodi_utente, storico_esercizi, storico_errori."""

import uuid
from datetime import datetime

from sqlalchemy import Boolean, Float, ForeignKey, Index, Integer, Text, text
from sqlalchemy.dialects.postgresql import ARRAY, JSONB, TIMESTAMP, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class StatoNodoUtente(Base):
    __tablename__ = "stato_nodi_utente"

    utente_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("utenti.id"), primary_key=True
    )
    nodo_id: Mapped[str] = mapped_column(Text, ForeignKey("nodi.id"), primary_key=True)

    # Livello corrente
    livello: Mapped[str] = mapped_column(Text, server_default="non_iniziato")
    presunto: Mapped[bool] = mapped_column(Boolean, server_default=text("false"))

    # Stato in corso
    spiegazione_data: Mapped[bool] = mapped_column(Boolean, server_default=text("false"))
    esercizi_completati: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    errori_in_corso: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    contesto_sospensione: Mapped[dict | None] = mapped_column(JSONB)

    # Spaced Repetition (Loop 2 — predisposto)
    sr_prossimo_ripasso: Mapped[datetime | None] = mapped_column(TIMESTAMP(timezone=True))
    sr_intervallo_giorni: Mapped[float | None] = mapped_column(Float)
    sr_facilita: Mapped[float] = mapped_column(Float, server_default=text("2.5"))
    sr_ripetizioni: Mapped[int | None] = mapped_column(Integer)
    sr_stabilita: Mapped[float | None] = mapped_column(Float)
    sr_difficolta: Mapped[float | None] = mapped_column(Float)

    # Promozione multi-segnale (Loop 3 — predisposto)
    feynman_superato: Mapped[bool | None] = mapped_column(Boolean)
    feynman_data: Mapped[datetime | None] = mapped_column(TIMESTAMP(timezone=True))
    esercizi_consecutivi_ok: Mapped[int | None] = mapped_column(Integer)
    ripasso_post_feynman_ok: Mapped[bool | None] = mapped_column(Boolean)

    ultima_interazione: Mapped[datetime | None] = mapped_column(TIMESTAMP(timezone=True))

    __table_args__ = (
        Index("ix_stato_nodi_utente_sr", "utente_id", "sr_prossimo_ripasso"),
        Index("ix_stato_nodi_utente_livello", "utente_id", "livello"),
    )


class StoricoEsercizi(Base):
    __tablename__ = "storico_esercizi"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    utente_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("utenti.id"), nullable=False
    )
    nodo_focale_id: Mapped[str] = mapped_column(Text, ForeignKey("nodi.id"), nullable=False)
    esercizio_id: Mapped[str | None] = mapped_column(Text, ForeignKey("esercizi.id"))
    esito: Mapped[str] = mapped_column(Text, nullable=False)
    nodo_causa_id: Mapped[str | None] = mapped_column(Text, ForeignKey("nodi.id"))
    nodi_coinvolti: Mapped[list | None] = mapped_column(ARRAY(Text))
    tipo_errore: Mapped[str | None] = mapped_column(Text)
    tempo_risposta_sec: Mapped[int | None] = mapped_column(Integer)
    sessione_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("sessioni.id")
    )
    created_at: Mapped[datetime] = mapped_column(
        TIMESTAMP(timezone=True), server_default=text("now()")
    )

    __table_args__ = (
        Index("ix_storico_esercizi_utente_nodo", "utente_id", "nodo_focale_id"),
    )


class StoricoErrori(Base):
    __tablename__ = "storico_errori"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    utente_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("utenti.id"), nullable=False
    )
    nodo_id: Mapped[str] = mapped_column(Text, ForeignKey("nodi.id"), nullable=False)
    tipo_errore: Mapped[str | None] = mapped_column(Text)
    descrizione: Mapped[str | None] = mapped_column(Text)
    contesto: Mapped[dict | None] = mapped_column(JSONB)
    sessione_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("sessioni.id")
    )
    created_at: Mapped[datetime] = mapped_column(
        TIMESTAMP(timezone=True), server_default=text("now()")
    )
