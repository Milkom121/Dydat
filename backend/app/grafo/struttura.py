"""Grafo in memoria — caricamento da DB all'avvio dell'applicazione.

Nodi operativi + relazioni (bloccante, consigliato, nessuna).
Usato dal path planner e dalla logica di sblocco.
"""

import logging

import networkx as nx
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.grafo import Nodo, NodoTema, Relazione

logger = logging.getLogger(__name__)


class GrafoKnowledge:
    """Knowledge graph caricato in RAM all'avvio. Singleton."""

    def __init__(self) -> None:
        self._grafo: nx.DiGraph | None = None

    @property
    def grafo(self) -> nx.DiGraph:
        if self._grafo is None:
            raise RuntimeError("Grafo non caricato. Chiamare carica() all'avvio.")
        return self._grafo

    @property
    def caricato(self) -> bool:
        return self._grafo is not None

    async def carica(self, db: AsyncSession) -> None:
        """Carica il knowledge graph in RAM dal database."""
        g = nx.DiGraph()

        # Carica nodi
        result = await db.execute(select(Nodo.id, Nodo.nome, Nodo.tipo_nodo, Nodo.tipo, Nodo.materia))
        nodi = result.all()
        for nodo_id, nome, tipo_nodo, tipo, materia in nodi:
            g.add_node(
                nodo_id,
                nome=nome,
                tipo_nodo=tipo_nodo,
                tipo=tipo,
                materia=materia,
                tema_id=None,
            )

        # Carica tema_id per ogni nodo (primo tema associato)
        result = await db.execute(select(NodoTema.nodo_id, NodoTema.tema_id))
        nodi_temi = result.all()
        temi_assegnati: set[str] = set()
        for nodo_id, tema_id in nodi_temi:
            if nodo_id in g and nodo_id not in temi_assegnati:
                g.nodes[nodo_id]["tema_id"] = tema_id
                temi_assegnati.add(nodo_id)

        # Carica relazioni
        result = await db.execute(
            select(Relazione.nodo_da, Relazione.nodo_a, Relazione.dipendenza)
        )
        relazioni = result.all()
        for nodo_da, nodo_a, dipendenza in relazioni:
            if nodo_da in g and nodo_a in g:
                g.add_edge(nodo_da, nodo_a, dipendenza=dipendenza)

        self._grafo = g
        logger.info(
            "Grafo caricato: %d nodi, %d archi",
            g.number_of_nodes(),
            g.number_of_edges(),
        )


grafo_knowledge = GrafoKnowledge()
