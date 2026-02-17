"""Test algoritmi del knowledge graph con grafi sintetici (no DB)."""

import networkx as nx
import pytest

from app.grafo.algoritmi import (
    nodi_sbloccati_dopo_promozione,
    ordinamento_topologico,
    path_planner,
    verifica_sblocco,
)


# ---------------------------------------------------------------------------
# Helper per creare grafi di test
# ---------------------------------------------------------------------------

def _nodo(tipo_nodo="operativo", tipo="standard", tema_id="tema1", materia="matematica"):
    return {"tipo_nodo": tipo_nodo, "tipo": tipo, "tema_id": tema_id, "materia": materia}


def grafo_lineare() -> nx.DiGraph:
    """A -> B -> C, tutti bloccanti, tutti operativi."""
    g = nx.DiGraph()
    g.add_node("A", **_nodo())
    g.add_node("B", **_nodo())
    g.add_node("C", **_nodo())
    g.add_edge("A", "B", dipendenza="bloccante")
    g.add_edge("B", "C", dipendenza="bloccante")
    return g


def grafo_diamante() -> nx.DiGraph:
    """A -> B, A -> C, B -> D, C -> D. Tutti bloccanti."""
    g = nx.DiGraph()
    g.add_node("A", **_nodo())
    g.add_node("B", **_nodo())
    g.add_node("C", **_nodo())
    g.add_node("D", **_nodo())
    g.add_edge("A", "B", dipendenza="bloccante")
    g.add_edge("A", "C", dipendenza="bloccante")
    g.add_edge("B", "D", dipendenza="bloccante")
    g.add_edge("C", "D", dipendenza="bloccante")
    return g


def grafo_con_temi() -> nx.DiGraph:
    """Due rami paralleli con temi diversi:
    A(tema_a) -> B(tema_a)
    C(tema_b) -> D(tema_b)
    Nessuna dipendenza tra i rami.
    """
    g = nx.DiGraph()
    g.add_node("A", **_nodo(tema_id="tema_a"))
    g.add_node("B", **_nodo(tema_id="tema_a"))
    g.add_node("C", **_nodo(tema_id="tema_b"))
    g.add_node("D", **_nodo(tema_id="tema_b"))
    g.add_edge("A", "B", dipendenza="bloccante")
    g.add_edge("C", "D", dipendenza="bloccante")
    return g


# ---------------------------------------------------------------------------
# Test ordinamento topologico
# ---------------------------------------------------------------------------

class TestOrdinamentoTopologico:
    def test_ordine_lineare(self):
        g = grafo_lineare()
        ordine = ordinamento_topologico(g)
        assert ordine.index("A") < ordine.index("B") < ordine.index("C")

    def test_nodi_contesto_esclusi(self):
        g = grafo_lineare()
        g.add_node("CTX", **_nodo(tipo_nodo="contesto"))
        g.add_edge("CTX", "A", dipendenza="bloccante")
        ordine = ordinamento_topologico(g)
        assert "CTX" not in ordine
        assert "A" in ordine

    def test_relazioni_non_bloccanti_ignorate(self):
        g = nx.DiGraph()
        g.add_node("X", **_nodo())
        g.add_node("Y", **_nodo())
        g.add_edge("X", "Y", dipendenza="consigliato")
        ordine = ordinamento_topologico(g)
        # Entrambi presenti, ma nessun vincolo d'ordine (nessun arco bloccante)
        assert set(ordine) == {"X", "Y"}

    def test_ciclo_bloccante_solleva_errore(self):
        g = nx.DiGraph()
        g.add_node("A", **_nodo())
        g.add_node("B", **_nodo())
        g.add_edge("A", "B", dipendenza="bloccante")
        g.add_edge("B", "A", dipendenza="bloccante")
        with pytest.raises(ValueError, match="Ciclo"):
            ordinamento_topologico(g)

    def test_grafo_vuoto(self):
        g = nx.DiGraph()
        assert ordinamento_topologico(g) == []

    def test_diamante(self):
        g = grafo_diamante()
        ordine = ordinamento_topologico(g)
        assert ordine.index("A") < ordine.index("B")
        assert ordine.index("A") < ordine.index("C")
        assert ordine.index("B") < ordine.index("D")
        assert ordine.index("C") < ordine.index("D")


# ---------------------------------------------------------------------------
# Test verifica sblocco
# ---------------------------------------------------------------------------

class TestVerificaSblocco:
    def test_nodo_radice_sempre_sbloccato(self):
        g = grafo_lineare()
        assert verifica_sblocco(g, "A", {}) is True

    def test_nodo_bloccato_senza_prerequisiti(self):
        g = grafo_lineare()
        assert verifica_sblocco(g, "B", {}) is False

    def test_nodo_sbloccato_con_prerequisiti_operativi(self):
        g = grafo_lineare()
        assert verifica_sblocco(g, "B", {"A": "operativo"}) is True

    def test_prerequisito_comprensivo_sblocca(self):
        g = grafo_lineare()
        assert verifica_sblocco(g, "B", {"A": "comprensivo"}) is True

    def test_prerequisito_connesso_sblocca(self):
        g = grafo_lineare()
        assert verifica_sblocco(g, "B", {"A": "connesso"}) is True

    def test_prerequisito_in_corso_non_sblocca(self):
        g = grafo_lineare()
        assert verifica_sblocco(g, "B", {"A": "in_corso"}) is False

    def test_consigliato_non_blocca(self):
        g = nx.DiGraph()
        g.add_node("P", **_nodo())
        g.add_node("Q", **_nodo())
        g.add_edge("P", "Q", dipendenza="consigliato")
        assert verifica_sblocco(g, "Q", {}) is True

    def test_nessuna_non_blocca(self):
        g = nx.DiGraph()
        g.add_node("P", **_nodo())
        g.add_node("Q", **_nodo())
        g.add_edge("P", "Q", dipendenza="nessuna")
        assert verifica_sblocco(g, "Q", {}) is True

    def test_prerequisito_contesto_ignorato(self):
        g = nx.DiGraph()
        g.add_node("CTX", **_nodo(tipo_nodo="contesto"))
        g.add_node("A", **_nodo())
        g.add_edge("CTX", "A", dipendenza="bloccante")
        # CTX e' contesto, quindi anche se non completato non blocca A
        assert verifica_sblocco(g, "A", {}) is True

    def test_diamante_bloccato_parzialmente(self):
        g = grafo_diamante()
        # D richiede B e C operativi
        assert verifica_sblocco(g, "D", {"B": "operativo"}) is False
        assert verifica_sblocco(g, "D", {"C": "operativo"}) is False

    def test_diamante_sbloccato(self):
        g = grafo_diamante()
        assert verifica_sblocco(g, "D", {"B": "operativo", "C": "operativo"}) is True


# ---------------------------------------------------------------------------
# Test path planner
# ---------------------------------------------------------------------------

class TestPathPlanner:
    def test_stato_vuoto_ritorna_radice(self):
        g = grafo_lineare()
        assert path_planner(g, {}) == "A"

    def test_a_completato_ritorna_b(self):
        g = grafo_lineare()
        assert path_planner(g, {"A": "operativo"}) == "B"

    def test_a_b_completati_ritorna_c(self):
        g = grafo_lineare()
        assert path_planner(g, {"A": "operativo", "B": "operativo"}) == "C"

    def test_tutti_completati_ritorna_none(self):
        g = grafo_lineare()
        tutti = {"A": "operativo", "B": "operativo", "C": "operativo"}
        assert path_planner(g, tutti) is None

    def test_nodo_in_corso_non_completato(self):
        g = grafo_lineare()
        # A e' in_corso, quindi non e' completato — path planner lo ritorna
        assert path_planner(g, {"A": "in_corso"}) == "A"

    def test_tie_break_stesso_tema(self):
        g = grafo_con_temi()
        # A e C sono entrambi radici (sbloccati). Con tema_corrente=tema_b, preferisce C
        risultato = path_planner(g, {}, tema_corrente="tema_b")
        assert risultato == "C"

    def test_tie_break_senza_tema_ritorna_primo(self):
        g = grafo_con_temi()
        # Senza tema corrente, ritorna il primo nell'ordine topologico
        risultato = path_planner(g, {}, tema_corrente=None)
        assert risultato in {"A", "C"}  # dipende dall'ordine topologico

    def test_tie_break_tema_inesistente_ignora(self):
        g = grafo_con_temi()
        # Tema che non esiste — nessun match, ritorna il primo
        risultato = path_planner(g, {}, tema_corrente="tema_inesistente")
        assert risultato in {"A", "C"}

    def test_diamante_path(self):
        g = grafo_diamante()
        # Solo A sbloccato all'inizio
        assert path_planner(g, {}) == "A"
        # A completato — B e C sbloccati
        risultato = path_planner(g, {"A": "operativo"})
        assert risultato in {"B", "C"}
        # A, B completati — C sbloccato, D ancora bloccato (manca C)
        risultato = path_planner(g, {"A": "operativo", "B": "operativo"})
        assert risultato == "C"
        # A, B, C completati — D sbloccato
        risultato = path_planner(
            g, {"A": "operativo", "B": "operativo", "C": "operativo"}
        )
        assert risultato == "D"

    def test_grafo_vuoto(self):
        g = nx.DiGraph()
        assert path_planner(g, {}) is None

    def test_nodi_contesto_mai_nel_path(self):
        g = grafo_lineare()
        g.add_node("CTX", **_nodo(tipo_nodo="contesto"))
        # Il path planner non deve mai ritornare un nodo contesto
        risultato = path_planner(g, {"A": "operativo", "B": "operativo", "C": "operativo"})
        assert risultato is None  # tutti completati, CTX non conta


# ---------------------------------------------------------------------------
# Test cascata sblocco dopo promozione
# ---------------------------------------------------------------------------

class TestNodiSbloccatiDopoPromozione:
    def test_promozione_a_sblocca_b(self):
        g = grafo_lineare()
        livelli = {"A": "operativo"}
        sbloccati = nodi_sbloccati_dopo_promozione(g, "A", livelli)
        assert "B" in sbloccati

    def test_promozione_b_sblocca_c(self):
        g = grafo_lineare()
        livelli = {"A": "operativo", "B": "operativo"}
        sbloccati = nodi_sbloccati_dopo_promozione(g, "B", livelli)
        assert "C" in sbloccati

    def test_promozione_non_sblocca_senza_altri_prerequisiti(self):
        g = grafo_diamante()
        # B promosso, ma D richiede anche C
        livelli = {"A": "operativo", "B": "operativo"}
        sbloccati = nodi_sbloccati_dopo_promozione(g, "B", livelli)
        assert "D" not in sbloccati

    def test_promozione_diamante_completa(self):
        g = grafo_diamante()
        # C promosso, B gia' operativo — D ora sbloccato
        livelli = {"A": "operativo", "B": "operativo", "C": "operativo"}
        sbloccati = nodi_sbloccati_dopo_promozione(g, "C", livelli)
        assert "D" in sbloccati

    def test_nodo_gia_completato_non_incluso(self):
        g = grafo_lineare()
        livelli = {"A": "operativo", "B": "operativo"}
        sbloccati = nodi_sbloccati_dopo_promozione(g, "A", livelli)
        # B e' gia' operativo, non deve apparire
        assert "B" not in sbloccati

    def test_nodo_foglia_nessuno_sbloccato(self):
        g = grafo_lineare()
        livelli = {"A": "operativo", "B": "operativo", "C": "operativo"}
        sbloccati = nodi_sbloccati_dopo_promozione(g, "C", livelli)
        assert sbloccati == []

    def test_consigliato_non_cascata(self):
        g = nx.DiGraph()
        g.add_node("A", **_nodo())
        g.add_node("B", **_nodo())
        g.add_edge("A", "B", dipendenza="consigliato")
        livelli = {"A": "operativo"}
        # B non ha archi bloccanti da A, quindi non appare nella cascata
        sbloccati = nodi_sbloccati_dopo_promozione(g, "A", livelli)
        assert sbloccati == []
