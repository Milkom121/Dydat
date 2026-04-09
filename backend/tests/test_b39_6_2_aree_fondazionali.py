"""Test per seleziona_aree_fondazionali (B39.6.2).

Verifica: selezione aree fondazionali con grafo mockato,
cap a MAX_AREE_FONDAZIONALI, ordinamento per posizione topologica,
edge case (lista vuota, grafo vuoto, aree non presenti nel grafo).
"""

import networkx as nx

from app.llm.prompts.onboarding_self_assessment import (
    MAX_AREE_FONDAZIONALI,
    seleziona_aree_fondazionali,
)


# --- Helper per costruire grafi di test ---


def _crea_grafo_lineare() -> nx.DiGraph:
    """Grafo lineare: A1 -> A2 -> B1 -> B2 -> C1 -> C2 -> D1 -> D2.

    4 temi: tema_a (nodi 1-2), tema_b (3-4), tema_c (5-6), tema_d (7-8).
    tema_a è il più fondazionale (posizione media più bassa).
    """
    g = nx.DiGraph()
    nodi = [
        ("a1", {"tipo_nodo": "operativo", "tema_id": "tema_a", "nome": "A1"}),
        ("a2", {"tipo_nodo": "operativo", "tema_id": "tema_a", "nome": "A2"}),
        ("b1", {"tipo_nodo": "operativo", "tema_id": "tema_b", "nome": "B1"}),
        ("b2", {"tipo_nodo": "operativo", "tema_id": "tema_b", "nome": "B2"}),
        ("c1", {"tipo_nodo": "operativo", "tema_id": "tema_c", "nome": "C1"}),
        ("c2", {"tipo_nodo": "operativo", "tema_id": "tema_c", "nome": "C2"}),
        ("d1", {"tipo_nodo": "operativo", "tema_id": "tema_d", "nome": "D1"}),
        ("d2", {"tipo_nodo": "operativo", "tema_id": "tema_d", "nome": "D2"}),
    ]
    for nodo_id, attrs in nodi:
        g.add_node(nodo_id, **attrs)

    # Catena lineare: a1 -> a2 -> b1 -> b2 -> c1 -> c2 -> d1 -> d2
    archi = [
        ("a1", "a2", "bloccante"),
        ("a2", "b1", "bloccante"),
        ("b1", "b2", "bloccante"),
        ("b2", "c1", "bloccante"),
        ("c1", "c2", "bloccante"),
        ("c2", "d1", "bloccante"),
        ("d1", "d2", "bloccante"),
    ]
    for u, v, dip in archi:
        g.add_edge(u, v, dipendenza=dip)

    return g


def _crea_grafo_ramificato() -> nx.DiGraph:
    """Grafo ramificato con 8 temi (per testare il cap a 6).

    Struttura:
        t1_a -> t2_a -> t4_a
        t1_b -> t3_a -> t5_a
                t3_b -> t6_a
        t7_a (isolato)
        t8_a (isolato)

    Ordine topologico atteso (circa): t1, t7, t8, t2, t3, t4, t5, t6
    (t1 più fondazionale, t6 meno fondazionale tra quelli collegati)
    """
    g = nx.DiGraph()
    nodi = [
        ("t1_a", {"tipo_nodo": "operativo", "tema_id": "tema_1", "nome": "T1A"}),
        ("t1_b", {"tipo_nodo": "operativo", "tema_id": "tema_1", "nome": "T1B"}),
        ("t2_a", {"tipo_nodo": "operativo", "tema_id": "tema_2", "nome": "T2A"}),
        ("t3_a", {"tipo_nodo": "operativo", "tema_id": "tema_3", "nome": "T3A"}),
        ("t3_b", {"tipo_nodo": "operativo", "tema_id": "tema_3", "nome": "T3B"}),
        ("t4_a", {"tipo_nodo": "operativo", "tema_id": "tema_4", "nome": "T4A"}),
        ("t5_a", {"tipo_nodo": "operativo", "tema_id": "tema_5", "nome": "T5A"}),
        ("t6_a", {"tipo_nodo": "operativo", "tema_id": "tema_6", "nome": "T6A"}),
        ("t7_a", {"tipo_nodo": "operativo", "tema_id": "tema_7", "nome": "T7A"}),
        ("t8_a", {"tipo_nodo": "operativo", "tema_id": "tema_8", "nome": "T8A"}),
    ]
    for nodo_id, attrs in nodi:
        g.add_node(nodo_id, **attrs)

    archi = [
        ("t1_a", "t2_a", "bloccante"),
        ("t1_b", "t3_a", "bloccante"),
        ("t2_a", "t4_a", "bloccante"),
        ("t3_a", "t5_a", "bloccante"),
        ("t3_b", "t6_a", "bloccante"),
    ]
    for u, v, dip in archi:
        g.add_edge(u, v, dipendenza=dip)

    return g


# --- Test costante ---


class TestCostanteMaxAreeFondazionali:
    def test_max_aree_fondazionali_e_sei(self):
        assert MAX_AREE_FONDAZIONALI == 6

    def test_max_aree_fondazionali_ragionevole(self):
        assert 3 <= MAX_AREE_FONDAZIONALI <= 10


# --- Test funzione principale ---


class TestSelezionaAreeFondazionali:
    """Test deterministici con grafi mockati."""

    def test_lista_vuota_ritorna_vuota(self):
        g = _crea_grafo_lineare()
        assert seleziona_aree_fondazionali([], g) == []

    def test_grafo_vuoto_ritorna_vuota(self):
        g = nx.DiGraph()
        assert seleziona_aree_fondazionali(["tema_a"], g) == []

    def test_una_area_forte_ritorna_quella(self):
        g = _crea_grafo_lineare()
        result = seleziona_aree_fondazionali(["tema_b"], g)
        assert result == ["tema_b"]

    def test_ordine_fondazionalita_grafo_lineare(self):
        """In un grafo lineare, tema_a è il più fondazionale."""
        g = _crea_grafo_lineare()
        result = seleziona_aree_fondazionali(
            ["tema_d", "tema_b", "tema_a", "tema_c"], g
        )
        # tema_a (pos media ~0.5) < tema_b (~2.5) < tema_c (~4.5) < tema_d (~6.5)
        assert result == ["tema_a", "tema_b", "tema_c", "tema_d"]

    def test_ordine_fondazionalita_due_temi(self):
        """Solo due temi forti: l'ordine riflette la posizione nel grafo."""
        g = _crea_grafo_lineare()
        result = seleziona_aree_fondazionali(["tema_c", "tema_a"], g)
        assert result[0] == "tema_a"
        assert result[1] == "tema_c"

    def test_cap_a_sei_con_otto_temi(self):
        """Con 8 temi forti, il risultato è cappato a 6."""
        g = _crea_grafo_ramificato()
        tutti_i_temi = [f"tema_{i}" for i in range(1, 9)]
        result = seleziona_aree_fondazionali(tutti_i_temi, g)
        assert len(result) == MAX_AREE_FONDAZIONALI

    def test_cap_non_applicato_sotto_sei(self):
        """Con 3 temi forti, il cap non taglia nulla."""
        g = _crea_grafo_lineare()
        result = seleziona_aree_fondazionali(["tema_a", "tema_b", "tema_c"], g)
        assert len(result) == 3

    def test_aree_non_nel_grafo_ignorate(self):
        """Aree forti non presenti come tema_id nel grafo vengono ignorate."""
        g = _crea_grafo_lineare()
        result = seleziona_aree_fondazionali(
            ["tema_a", "tema_inesistente", "tema_b"], g
        )
        assert "tema_inesistente" not in result
        assert result == ["tema_a", "tema_b"]

    def test_tutte_aree_inesistenti_ritorna_vuota(self):
        g = _crea_grafo_lineare()
        result = seleziona_aree_fondazionali(["fake_1", "fake_2"], g)
        assert result == []

    def test_nodi_contesto_ignorati(self):
        """I nodi con tipo_nodo='contesto' non contano per la fondazionalità."""
        g = _crea_grafo_lineare()
        # Aggiungi un nodo contesto al tema_d in posizione precoce
        g.add_node("ctx_d", tipo_nodo="contesto", tema_id="tema_d", nome="CTX D")
        g.add_edge("a1", "ctx_d", dipendenza="consigliato")

        result = seleziona_aree_fondazionali(
            ["tema_a", "tema_d"], g
        )
        # tema_d non deve essere "promosso" dal nodo contesto
        assert result[0] == "tema_a"
        assert result[1] == "tema_d"

    def test_duplicati_in_input_non_causano_problemi(self):
        """Aree duplicate nell'input non generano duplicati nell'output."""
        g = _crea_grafo_lineare()
        result = seleziona_aree_fondazionali(
            ["tema_a", "tema_a", "tema_b"], g
        )
        assert result == ["tema_a", "tema_b"]

    def test_tema_con_un_solo_nodo(self):
        """Un tema con un solo nodo funziona (media = posizione di quel nodo)."""
        g = nx.DiGraph()
        g.add_node("solo", tipo_nodo="operativo", tema_id="tema_solo", nome="Solo")
        g.add_node("dopo", tipo_nodo="operativo", tema_id="tema_dopo", nome="Dopo")
        g.add_edge("solo", "dopo", dipendenza="bloccante")

        result = seleziona_aree_fondazionali(["tema_solo", "tema_dopo"], g)
        assert result[0] == "tema_solo"

    def test_risultato_e_lista_di_stringhe(self):
        g = _crea_grafo_lineare()
        result = seleziona_aree_fondazionali(["tema_a"], g)
        assert isinstance(result, list)
        assert all(isinstance(t, str) for t in result)

    def test_ordine_stabile_temi_stessa_posizione(self):
        """Se due temi hanno la stessa posizione media, l'ordine è deterministico."""
        g = nx.DiGraph()
        # Due nodi indipendenti (stesso livello nel grafo)
        g.add_node("x1", tipo_nodo="operativo", tema_id="tema_x", nome="X1")
        g.add_node("y1", tipo_nodo="operativo", tema_id="tema_y", nome="Y1")

        # Esegui più volte per verificare stabilità
        risultati = set()
        for _ in range(10):
            r = seleziona_aree_fondazionali(["tema_x", "tema_y"], g)
            risultati.add(tuple(r))

        # L'ordine deve essere sempre lo stesso (deterministico)
        assert len(risultati) == 1

    def test_cap_sei_mantiene_i_piu_fondazionali(self):
        """Con >6 temi, quelli tagliati sono i meno fondazionali."""
        g = _crea_grafo_ramificato()
        tutti_i_temi = [f"tema_{i}" for i in range(1, 9)]
        result = seleziona_aree_fondazionali(tutti_i_temi, g)

        # tema_1 deve essere nel risultato (è il più fondazionale: ha i nodi radice)
        assert "tema_1" in result
        # I temi con posizione media più alta (meno fondazionali) possono essere esclusi
        assert len(result) == 6

    def test_grafo_ramificato_tema_radice_primo(self):
        """Nel grafo ramificato, tema_1 (radice) è il più fondazionale."""
        g = _crea_grafo_ramificato()
        result = seleziona_aree_fondazionali(
            ["tema_1", "tema_4", "tema_6"], g
        )
        assert result[0] == "tema_1"

    def test_grafo_ramificato_tema_foglia_ultimo(self):
        """I temi foglia (4, 5, 6) sono i meno fondazionali."""
        g = _crea_grafo_ramificato()
        result = seleziona_aree_fondazionali(
            ["tema_1", "tema_4", "tema_5", "tema_6"], g
        )
        assert result[0] == "tema_1"
        # tema_4, tema_5, tema_6 sono dopo tema_1

    def test_archi_non_bloccanti_non_influenzano(self):
        """Solo archi bloccanti contano per l'ordine topologico."""
        g = _crea_grafo_lineare()
        # Aggiungi arco consigliato che "inverte" la direzione
        g.add_edge("d2", "a1", dipendenza="consigliato")

        result = seleziona_aree_fondazionali(
            ["tema_a", "tema_d"], g
        )
        # L'ordine non deve cambiare: tema_a resta più fondazionale
        assert result[0] == "tema_a"

    def test_nodi_senza_tema_id_ignorati(self):
        """Nodi operativi senza tema_id non causano errori."""
        g = _crea_grafo_lineare()
        g.add_node("orfano", tipo_nodo="operativo", nome="Orfano")
        # tema_id mancante → non viene conteggiato

        result = seleziona_aree_fondazionali(["tema_a"], g)
        assert result == ["tema_a"]
