"""Test B39.6.6 — Integrazione stato_orchestratore + path planner.

Verifica:
- costruisci_mappa_placement: unione auto-valutazione + esiti verifica
- determina_nodo_partenza_da_mappa: scelta nodo da mappa placement
- _determina_nodo_da_placement: priorità mappa > legacy
- _inizializza_stato_nodi: nodi temi forte_confermato come presunti
- Flusso completo: autovalutazione → verifica → mappa → nodo partenza
"""

import networkx as nx
import pytest

from app.core.onboarding import (
    STATI_PLACEMENT,
    costruisci_mappa_placement,
    determina_nodo_partenza_da_mappa,
    _determina_nodo_da_placement,
)
from app.schemas.onboarding import EsitoVerifica


# --- Helper per creare grafi di test ---

def _crea_grafo_lineare(temi: list[str]) -> nx.DiGraph:
    """Crea un grafo lineare con nodi operativi, uno per tema.

    Ogni nodo ha id "nodo_{tema}" e attributi tipo_nodo="operativo", tema_id=tema.
    I nodi sono collegati in ordine: nodo_0 → nodo_1 → nodo_2 → ...
    """
    g = nx.DiGraph()
    nodi = []
    for tema in temi:
        nodo_id = f"nodo_{tema}"
        g.add_node(nodo_id, tipo_nodo="operativo", tema_id=tema, nome=tema)
        nodi.append(nodo_id)

    for i in range(len(nodi) - 1):
        g.add_edge(nodi[i], nodi[i + 1])

    return g


def _crea_grafo_multi_nodo(temi_con_nodi: dict[str, int]) -> nx.DiGraph:
    """Crea un grafo con più nodi per tema, in ordine lineare.

    temi_con_nodi: {tema_id: num_nodi}. I nodi sono in ordine topologico.
    """
    g = nx.DiGraph()
    nodi = []
    for tema, count in temi_con_nodi.items():
        for i in range(count):
            nodo_id = f"{tema}_{i}"
            g.add_node(nodo_id, tipo_nodo="operativo", tema_id=tema, nome=f"{tema} {i}")
            nodi.append(nodo_id)

    for i in range(len(nodi) - 1):
        g.add_edge(nodi[i], nodi[i + 1])

    return g


# === Test STATI_PLACEMENT ===

def test_stati_placement_contiene_4_valori():
    assert len(STATI_PLACEMENT) == 4
    assert "forte_confermato" in STATI_PLACEMENT
    assert "forte_unverified" in STATI_PLACEMENT
    assert "incerto" in STATI_PLACEMENT
    assert "digiuno" in STATI_PLACEMENT


# === Test costruisci_mappa_placement ===

class TestCostruisciMappaPlacement:
    """Test per costruisci_mappa_placement()."""

    def test_autovalutazione_vuota(self):
        mappa = costruisci_mappa_placement({})
        assert mappa == {}

    def test_solo_digiuno(self):
        auto = {"algebra": "digiuno", "geometria": "digiuno"}
        mappa = costruisci_mappa_placement(auto)
        assert mappa == {"algebra": "digiuno", "geometria": "digiuno"}

    def test_solo_incerto(self):
        auto = {"algebra": "incerto"}
        mappa = costruisci_mappa_placement(auto)
        assert mappa == {"algebra": "incerto"}

    def test_forte_senza_verifica(self):
        """Forte non selezionato per verifica → forte_unverified."""
        auto = {"algebra": "forte", "geometria": "forte"}
        mappa = costruisci_mappa_placement(auto)
        assert mappa == {
            "algebra": "forte_unverified",
            "geometria": "forte_unverified",
        }

    def test_forte_verificato_corretto(self):
        """Forte + verifica corretta → forte_confermato."""
        auto = {"algebra": "forte", "geometria": "forte"}
        esiti = [
            EsitoVerifica(corretto=True, concetti_retrocessi=[], spiegazione_breve="ok"),
        ]
        # algebra verificata e non retrocessa → confermata
        mappa = costruisci_mappa_placement(auto, esiti, aree_verificate=["algebra"])
        assert mappa["algebra"] == "forte_confermato"
        assert mappa["geometria"] == "forte_unverified"

    def test_forte_verificato_sbagliato(self):
        """Forte + verifica sbagliata → incerto (retrocessione)."""
        auto = {"algebra": "forte", "geometria": "forte"}
        esiti = [
            EsitoVerifica(
                corretto=False,
                concetti_retrocessi=["algebra"],
                spiegazione_breve="errore",
            ),
        ]
        mappa = costruisci_mappa_placement(
            auto, esiti, aree_verificate=["algebra", "geometria"]
        )
        assert mappa["algebra"] == "incerto"  # retrocesso
        assert mappa["geometria"] == "forte_confermato"  # non retrocesso

    def test_compound_sbagliato_retrocede_entrambi(self):
        """Compound sbagliato → entrambi i concetti retrocedono (Decisione 8)."""
        auto = {"algebra": "forte", "geometria": "forte"}
        esiti = [
            EsitoVerifica(
                corretto=False,
                concetti_retrocessi=["algebra", "geometria"],
                spiegazione_breve="errore",
            ),
        ]
        mappa = costruisci_mappa_placement(
            auto, esiti, aree_verificate=["algebra", "geometria"]
        )
        assert mappa["algebra"] == "incerto"
        assert mappa["geometria"] == "incerto"

    def test_mix_completo(self):
        """Scenario realistico con mix di tutti i livelli."""
        auto = {
            "algebra": "forte",
            "geometria": "forte",
            "analisi": "incerto",
            "trigonometria": "digiuno",
            "statistica": "forte",
        }
        esiti = [
            # compound algebra+geometria: algebra ok, geometria no
            EsitoVerifica(
                corretto=False,
                concetti_retrocessi=["geometria"],
                spiegazione_breve="errore geo",
            ),
        ]
        mappa = costruisci_mappa_placement(
            auto, esiti,
            aree_verificate=["algebra", "geometria"],
        )
        assert mappa["algebra"] == "forte_confermato"
        assert mappa["geometria"] == "incerto"
        assert mappa["analisi"] == "incerto"
        assert mappa["trigonometria"] == "digiuno"
        assert mappa["statistica"] == "forte_unverified"

    def test_esiti_none(self):
        """Esiti None → tutti i forti come unverified."""
        auto = {"algebra": "forte"}
        mappa = costruisci_mappa_placement(auto, esiti_verifica=None)
        assert mappa == {"algebra": "forte_unverified"}

    def test_livello_sconosciuto_diventa_incerto(self):
        """Livello non riconosciuto → trattato come incerto."""
        auto = {"algebra": "sconosciuto"}
        mappa = costruisci_mappa_placement(auto)
        assert mappa == {"algebra": "incerto"}

    def test_esiti_vuoti(self):
        """Lista esiti vuota → nessuna retrocessione."""
        auto = {"algebra": "forte"}
        mappa = costruisci_mappa_placement(auto, esiti_verifica=[], aree_verificate=["algebra"])
        assert mappa["algebra"] == "forte_confermato"

    def test_multipli_esercizi_misti(self):
        """Più esercizi: uno corretto, uno sbagliato."""
        auto = {"a1": "forte", "a2": "forte", "a3": "forte", "a4": "forte"}
        esiti = [
            # Esercizio 1: a1+a2 corretto
            EsitoVerifica(corretto=True, concetti_retrocessi=[], spiegazione_breve="ok"),
            # Esercizio 2: a3+a4 sbagliato
            EsitoVerifica(
                corretto=False,
                concetti_retrocessi=["a3", "a4"],
                spiegazione_breve="errore",
            ),
        ]
        mappa = costruisci_mappa_placement(
            auto, esiti, aree_verificate=["a1", "a2", "a3", "a4"]
        )
        assert mappa["a1"] == "forte_confermato"
        assert mappa["a2"] == "forte_confermato"
        assert mappa["a3"] == "incerto"
        assert mappa["a4"] == "incerto"


# === Test determina_nodo_partenza_da_mappa ===

class TestDeterminaNodoPartenzaDaMappa:
    """Test per determina_nodo_partenza_da_mappa()."""

    def test_mappa_vuota(self):
        g = _crea_grafo_lineare(["algebra", "geometria"])
        assert determina_nodo_partenza_da_mappa({}, g) is None

    def test_grafo_vuoto(self):
        g = nx.DiGraph()
        mappa = {"algebra": "digiuno"}
        assert determina_nodo_partenza_da_mappa(mappa, g) is None

    def test_tutti_digiuno_parte_dal_primo(self):
        """Tutti digiuno → parte dal primo nodo."""
        g = _crea_grafo_lineare(["algebra", "geometria", "analisi"])
        mappa = {"algebra": "digiuno", "geometria": "digiuno", "analisi": "digiuno"}
        assert determina_nodo_partenza_da_mappa(mappa, g) == "nodo_algebra"

    def test_primo_forte_secondo_incerto(self):
        """Primo tema forte → parte dal secondo (incerto)."""
        g = _crea_grafo_lineare(["algebra", "geometria", "analisi"])
        mappa = {
            "algebra": "forte_confermato",
            "geometria": "incerto",
            "analisi": "digiuno",
        }
        assert determina_nodo_partenza_da_mappa(mappa, g) == "nodo_geometria"

    def test_primi_due_forti(self):
        """Primi due forti → parte dal terzo."""
        g = _crea_grafo_lineare(["algebra", "geometria", "analisi"])
        mappa = {
            "algebra": "forte_confermato",
            "geometria": "forte_unverified",
            "analisi": "incerto",
        }
        assert determina_nodo_partenza_da_mappa(mappa, g) == "nodo_analisi"

    def test_tutti_forti_parte_dallultimo(self):
        """Tutti forti → ritorna ultimo nodo operativo."""
        g = _crea_grafo_lineare(["algebra", "geometria"])
        mappa = {
            "algebra": "forte_confermato",
            "geometria": "forte_confermato",
        }
        risultato = determina_nodo_partenza_da_mappa(mappa, g)
        assert risultato == "nodo_geometria"

    def test_tema_non_nel_grafo_ignorato(self):
        """Tema nella mappa ma non nel grafo → ignorato, parte dal primo non-forte."""
        g = _crea_grafo_lineare(["algebra", "geometria"])
        mappa = {
            "algebra": "forte_confermato",
            "statistica": "digiuno",  # non nel grafo
            "geometria": "incerto",
        }
        assert determina_nodo_partenza_da_mappa(mappa, g) == "nodo_geometria"

    def test_multi_nodo_per_tema(self):
        """Più nodi per tema: salta tutti i nodi del tema forte."""
        g = _crea_grafo_multi_nodo({"algebra": 3, "geometria": 2})
        mappa = {"algebra": "forte_confermato", "geometria": "incerto"}
        # Deve saltare algebra_0, algebra_1, algebra_2 e andare a geometria_0
        assert determina_nodo_partenza_da_mappa(mappa, g) == "geometria_0"

    def test_nodo_senza_tema_non_forte(self):
        """Nodo senza tema_id → non è mai 'forte', viene selezionato."""
        g = nx.DiGraph()
        g.add_node("nodo_orfano", tipo_nodo="operativo", tema_id="")
        g.add_node("nodo_geo", tipo_nodo="operativo", tema_id="geometria")
        g.add_edge("nodo_orfano", "nodo_geo")
        mappa = {"geometria": "forte_confermato"}
        assert determina_nodo_partenza_da_mappa(mappa, g) == "nodo_orfano"


# === Test _determina_nodo_da_placement con mappa ===

class TestDeterminaNodoDaPlacementNuovo:
    """Test per _determina_nodo_da_placement con la nuova mappa."""

    def test_mappa_ha_priorita_su_esiti(self, monkeypatch):
        """Se placement_mappa presente, usa quella ignorando esiti legacy."""
        g = _crea_grafo_lineare(["algebra", "geometria", "analisi"])

        # Mock grafo_knowledge: settiamo _grafo (la property caricato è derivata)
        from app.grafo.struttura import grafo_knowledge
        monkeypatch.setattr(grafo_knowledge, "_grafo", g)

        placement = {
            "placement_mappa": {
                "algebra": "forte_confermato",
                "geometria": "incerto",
                "analisi": "digiuno",
            },
            # Esiti legacy che punterebbero altrove
            "esiti": [{"nodo_id": "nodo_analisi", "padroneggiato": False}],
        }
        risultato = _determina_nodo_da_placement(placement)
        assert risultato == "nodo_geometria"  # dalla mappa, non da esiti

    def test_fallback_legacy_se_mappa_assente(self, monkeypatch):
        """Senza mappa, usa il fallback legacy con esiti gateway."""
        from app.grafo.struttura import grafo_knowledge
        monkeypatch.setattr(grafo_knowledge, "_grafo", None)

        placement = {
            "esiti": [
                {"nodo_id": "n1", "padroneggiato": True},
                {"nodo_id": "n2", "padroneggiato": False},
            ],
        }
        risultato = _determina_nodo_da_placement(placement)
        assert risultato == "n2"

    def test_mappa_vuota_usa_legacy(self, monkeypatch):
        """Mappa vuota → fallback a legacy."""
        from app.grafo.struttura import grafo_knowledge
        monkeypatch.setattr(grafo_knowledge, "_grafo", None)

        placement = {
            "placement_mappa": {},
            "esiti": [{"nodo_id": "n1", "padroneggiato": False}],
        }
        risultato = _determina_nodo_da_placement(placement)
        assert risultato == "n1"


# === Test flusso completo ===

class TestFlussoCompletoPlacement:
    """Test del flusso: autovalutazione → verifica → mappa → nodo partenza."""

    def test_flusso_realistico(self):
        """Simula un flusso placement completo end-to-end."""
        # 1. Auto-valutazione
        autovalutazione = {
            "numeri_naturali": "forte",
            "frazioni": "forte",
            "equazioni_primo_grado": "incerto",
            "proporzioni": "digiuno",
            "potenze": "forte",
        }

        # 2. Aree fondazionali selezionate per verifica (le più fondazionali tra i forti)
        aree_verificate = ["numeri_naturali", "frazioni", "potenze"]

        # 3. Esiti verifica compound
        esiti = [
            # numeri_naturali + frazioni: sbagliato
            EsitoVerifica(
                corretto=False,
                concetti_retrocessi=["numeri_naturali", "frazioni"],
                spiegazione_breve="Errore sulle frazioni",
            ),
            # potenze: corretto
            EsitoVerifica(
                corretto=True,
                concetti_retrocessi=[],
                spiegazione_breve="Corretto",
            ),
        ]

        # 4. Costruisci mappa
        mappa = costruisci_mappa_placement(autovalutazione, esiti, aree_verificate)

        assert mappa["numeri_naturali"] == "incerto"  # retrocesso
        assert mappa["frazioni"] == "incerto"  # retrocesso
        assert mappa["equazioni_primo_grado"] == "incerto"
        assert mappa["proporzioni"] == "digiuno"
        assert mappa["potenze"] == "forte_confermato"

        # 5. Determina nodo partenza
        g = _crea_grafo_lineare([
            "numeri_naturali", "frazioni", "equazioni_primo_grado",
            "proporzioni", "potenze",
        ])
        nodo = determina_nodo_partenza_da_mappa(mappa, g)
        # Il primo tema non-forte nell'ordine è numeri_naturali (incerto)
        assert nodo == "nodo_numeri_naturali"

    def test_flusso_studente_bravo(self):
        """Studente che supera tutto: parte dopo le aree forti."""
        autovalutazione = {
            "algebra": "forte",
            "geometria": "forte",
            "analisi": "incerto",
        }
        esiti = [
            EsitoVerifica(corretto=True, concetti_retrocessi=[], spiegazione_breve="ok"),
        ]
        mappa = costruisci_mappa_placement(
            autovalutazione, esiti, aree_verificate=["algebra", "geometria"]
        )

        assert mappa["algebra"] == "forte_confermato"
        assert mappa["geometria"] == "forte_confermato"
        assert mappa["analisi"] == "incerto"

        g = _crea_grafo_lineare(["algebra", "geometria", "analisi"])
        nodo = determina_nodo_partenza_da_mappa(mappa, g)
        assert nodo == "nodo_analisi"

    def test_flusso_studente_digiuno_totale(self):
        """Studente completamente nuovo: tutto digiuno, parte dall'inizio."""
        autovalutazione = {
            "algebra": "digiuno",
            "geometria": "digiuno",
        }
        mappa = costruisci_mappa_placement(autovalutazione)

        g = _crea_grafo_lineare(["algebra", "geometria"])
        nodo = determina_nodo_partenza_da_mappa(mappa, g)
        assert nodo == "nodo_algebra"
