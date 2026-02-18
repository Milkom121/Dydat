"""Algoritmi deterministici sul knowledge graph.

Ordinamento topologico, sblocco nodo, path planner.
Preferenza stesso tema in caso di parita'.
Funzioni pure: prendono il grafo e lo stato utente come parametri, nessun accesso DB.
"""

import logging

import networkx as nx

logger = logging.getLogger(__name__)

LIVELLI_COMPLETI = frozenset({"operativo", "comprensivo", "connesso"})


def ordinamento_topologico(grafo: nx.DiGraph) -> list[str]:
    """Ordinamento topologico sul sottografo delle relazioni bloccanti.

    Considera solo nodi con tipo_nodo='operativo' e archi con dipendenza='bloccante'.
    Nodi contesto esclusi.
    """
    sottografo = nx.DiGraph()

    for nodo_id, attrs in grafo.nodes(data=True):
        if attrs.get("tipo_nodo") == "operativo":
            sottografo.add_node(nodo_id, **attrs)

    for u, v, attrs in grafo.edges(data=True):
        if attrs.get("dipendenza") == "bloccante":
            if u in sottografo and v in sottografo:
                sottografo.add_edge(u, v, **attrs)

    try:
        return list(nx.topological_sort(sottografo))
    except nx.NetworkXUnfeasible:
        ciclo = nx.find_cycle(sottografo)
        logger.error("Ciclo rilevato nel sottografo bloccante: %s", ciclo)
        raise ValueError(f"Ciclo nel sottografo bloccante: {ciclo}") from None


def verifica_sblocco(
    grafo: nx.DiGraph,
    nodo_id: str,
    livelli_utente: dict[str, str],
) -> bool:
    """Verifica se un nodo e' sbloccato (tutti prerequisiti bloccanti >= operativo).

    - Controlla solo archi entranti con dipendenza='bloccante'
    - Ignora predecessori con tipo_nodo='contesto'
    - Nodo senza predecessori bloccanti -> sempre sbloccato
    """
    for pred_id, _, edge_attrs in grafo.in_edges(nodo_id, data=True):
        if edge_attrs.get("dipendenza") != "bloccante":
            continue
        pred_node_attrs = grafo.nodes.get(pred_id, {})
        if pred_node_attrs.get("tipo_nodo") == "contesto":
            continue
        livello = livelli_utente.get(pred_id, "non_iniziato")
        if livello not in LIVELLI_COMPLETI:
            return False
    return True


def path_planner(
    grafo: nx.DiGraph,
    livelli_utente: dict[str, str],
    tema_corrente: str | None = None,
) -> str | None:
    """Path planner: prossimo nodo non completato con prerequisiti soddisfatti.

    1. Ordinamento topologico del sottografo bloccante (solo nodi operativi)
    2. Filtra nodi non ancora completati con prerequisiti soddisfatti
    3. Tie-break: preferenza stesso tema di tema_corrente
    4. Ritorna None se tutti completati
    """
    ordine = ordinamento_topologico(grafo)
    candidati: list[str] = []

    for nodo_id in ordine:
        livello = livelli_utente.get(nodo_id, "non_iniziato")
        if livello in LIVELLI_COMPLETI:
            continue
        if verifica_sblocco(grafo, nodo_id, livelli_utente):
            candidati.append(nodo_id)

    if not candidati:
        return None

    if tema_corrente:
        stessa_tema = [
            n for n in candidati if grafo.nodes[n].get("tema_id") == tema_corrente
        ]
        if stessa_tema:
            return stessa_tema[0]

    return candidati[0]


def nodi_sbloccati_dopo_promozione(
    grafo: nx.DiGraph,
    nodo_promosso: str,
    livelli_utente: dict[str, str],
) -> list[str]:
    """Trova i nodi sbloccati dalla promozione di un nodo a operativo.

    Controlla i successori diretti (via archi bloccanti) del nodo promosso
    e verifica se ora sono sbloccati.
    """
    sbloccati: list[str] = []

    for _, succ_id, edge_attrs in grafo.out_edges(nodo_promosso, data=True):
        if edge_attrs.get("dipendenza") != "bloccante":
            continue
        succ_attrs = grafo.nodes.get(succ_id, {})
        if succ_attrs.get("tipo_nodo") != "operativo":
            continue
        livello = livelli_utente.get(succ_id, "non_iniziato")
        if livello in LIVELLI_COMPLETI:
            continue
        if verifica_sblocco(grafo, succ_id, livelli_utente):
            sbloccati.append(succ_id)

    return sbloccati
