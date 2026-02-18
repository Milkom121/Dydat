"""Gruppo 1 — Grafo strutturale (dati editoriali): nodi, temi, nodi_temi, relazioni, esercizi."""

from sqlalchemy import ForeignKey, Index, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class Nodo(Base):
    __tablename__ = "nodi"

    id: Mapped[str] = mapped_column(Text, primary_key=True)
    nome: Mapped[str] = mapped_column(Text, nullable=False)
    materia: Mapped[str] = mapped_column(Text, nullable=False)
    tipo: Mapped[str] = mapped_column(Text, server_default="standard")
    tipo_nodo: Mapped[str] = mapped_column(Text, server_default="operativo")
    definizioni_formali: Mapped[dict | None] = mapped_column(JSONB)
    formule_proprieta: Mapped[list | None] = mapped_column(JSONB)
    errori_comuni: Mapped[list | None] = mapped_column(JSONB)
    esempi_applicazione: Mapped[list | None] = mapped_column(JSONB)
    parole_chiave: Mapped[list | None] = mapped_column(JSONB)
    embedding: Mapped[list | None] = mapped_column(JSONB)
    metadata_: Mapped[dict | None] = mapped_column("metadata", JSONB)

    temi: Mapped[list["Tema"]] = relationship(
        secondary="nodi_temi", back_populates="nodi", lazy="selectin"
    )
    esercizi: Mapped[list["Esercizio"]] = relationship(back_populates="nodo", lazy="selectin")


class Tema(Base):
    __tablename__ = "temi"

    id: Mapped[str] = mapped_column(Text, primary_key=True)
    nome: Mapped[str] = mapped_column(Text, nullable=False)
    materia: Mapped[str] = mapped_column(Text, nullable=False)
    descrizione: Mapped[str | None] = mapped_column(Text)
    ordine_visualizzazione: Mapped[int | None] = mapped_column(Integer)

    nodi: Mapped[list["Nodo"]] = relationship(
        secondary="nodi_temi", back_populates="temi", lazy="selectin"
    )


class NodoTema(Base):
    __tablename__ = "nodi_temi"

    nodo_id: Mapped[str] = mapped_column(Text, ForeignKey("nodi.id"), primary_key=True)
    tema_id: Mapped[str] = mapped_column(Text, ForeignKey("temi.id"), primary_key=True)


class Relazione(Base):
    __tablename__ = "relazioni"

    nodo_da: Mapped[str] = mapped_column(Text, ForeignKey("nodi.id"), primary_key=True)
    nodo_a: Mapped[str] = mapped_column(Text, ForeignKey("nodi.id"), primary_key=True)
    dipendenza: Mapped[str] = mapped_column(Text, nullable=False)
    descrizione: Mapped[str] = mapped_column(Text, nullable=False)


class Esercizio(Base):
    __tablename__ = "esercizi"

    id: Mapped[str] = mapped_column(Text, primary_key=True)
    nodo_id: Mapped[str] = mapped_column(Text, ForeignKey("nodi.id"), nullable=False)
    testo: Mapped[str] = mapped_column(Text, nullable=False)
    tipo: Mapped[str | None] = mapped_column(Text)
    difficolta: Mapped[int | None] = mapped_column(Integer)
    soluzione: Mapped[dict | None] = mapped_column(JSONB)
    nodi_coinvolti: Mapped[list | None] = mapped_column(JSONB)
    metadata_: Mapped[dict | None] = mapped_column("metadata", JSONB)

    nodo: Mapped["Nodo"] = relationship(back_populates="esercizi")

    __table_args__ = (Index("ix_esercizi_nodo_id", "nodo_id"),)
