"""Test Blocco B27 — Interleaving SR nelle sessioni normali.

Testa:
- _scegli_nodo con interleaving SR probabilistico
- _nomi_nodi_sr: nomi leggibili dai nodi SR
- inizia_sessione imposta attivita_corrente="ripasso_sr" quando SR scelto
- inizia_sessione imposta concetti_scadenza nello stato_orchestratore
- Interleaving bypassa in_corso (in_corso ha sempre priorità assoluta)
- Senza nodi SR, il path planner funziona normalmente
"""

from __future__ import annotations

import uuid
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.core.sessione import (
    PROBABILITA_INTERLEAVING,
    _NodoScelto,
    _nomi_nodi_sr,
    _scegli_nodo,
    inizia_sessione,
)


# ===================================================================
# Helper: mock Sessione
# ===================================================================


def _mock_sessione_sospesa():
    sess = MagicMock()
    sess.id = uuid.uuid4()
    sess.utente_id = uuid.uuid4()
    sess.stato = "sospesa"
    sess.tipo = "media"
    sess.stato_orchestratore = {"nodo_focale_id": "nodo_sospeso", "attivita_corrente": "esercizio"}
    sess.nodi_lavorati = []
    return sess


# ===================================================================
# Test: costante interleaving
# ===================================================================


class TestCostanteInterleaving:
    def test_probabilita_in_range(self):
        """PROBABILITA_INTERLEAVING deve essere tra 0 e 1."""
        assert 0 < PROBABILITA_INTERLEAVING < 1

    def test_probabilita_circa_un_terzo(self):
        """Circa 1 ogni 3 nodi normali."""
        assert 0.25 <= PROBABILITA_INTERLEAVING <= 0.50


# ===================================================================
# Test: _nomi_nodi_sr
# ===================================================================


class TestNomiNodiSr:
    @patch("app.core.sessione.grafo_knowledge")
    def test_nomi_da_grafo_se_caricato(self, mock_grafo):
        """Restituisce i nomi leggibili dal grafo se caricato."""
        mock_grafo.caricato = True
        mock_grafo.grafo.nodes = {
            "nodo_001": {"nome": "Equazioni di primo grado"},
            "nodo_002": {"nome": "Frazioni"},
        }

        nomi = _nomi_nodi_sr(["nodo_001", "nodo_002"])

        assert nomi == ["Equazioni di primo grado", "Frazioni"]

    @patch("app.core.sessione.grafo_knowledge")
    def test_fallback_id_se_grafo_non_caricato(self, mock_grafo):
        """Se il grafo non è caricato, usa il nodo_id come fallback."""
        mock_grafo.caricato = False

        nomi = _nomi_nodi_sr(["nodo_abc", "nodo_xyz"])

        assert nomi == ["nodo_abc", "nodo_xyz"]

    @patch("app.core.sessione.grafo_knowledge")
    def test_fallback_id_se_nodo_non_in_grafo(self, mock_grafo):
        """Nodo non nel grafo → usa ID come fallback."""
        mock_grafo.caricato = True
        mock_grafo.grafo.nodes = {}  # grafo vuoto

        nomi = _nomi_nodi_sr(["nodo_sconosciuto"])

        assert nomi == ["nodo_sconosciuto"]

    @patch("app.core.sessione.grafo_knowledge")
    def test_massimo_5_concetti(self, mock_grafo):
        """Ritorna al massimo 5 nomi anche con più nodi scaduti."""
        mock_grafo.caricato = False
        nodi_sr = [f"nodo_{i}" for i in range(10)]

        nomi = _nomi_nodi_sr(nodi_sr)

        assert len(nomi) == 5

    @patch("app.core.sessione.grafo_knowledge")
    def test_lista_vuota(self, mock_grafo):
        """Lista vuota in input → lista vuota in output."""
        mock_grafo.caricato = False

        nomi = _nomi_nodi_sr([])

        assert nomi == []


# ===================================================================
# Test: _scegli_nodo con interleaving SR
# ===================================================================


class TestScegliNodoInterleaving:
    @pytest.mark.asyncio
    async def test_in_corso_bypassa_sr(self):
        """Nodo in_corso ha priorità assoluta — nessun interleaving SR."""
        db = AsyncMock()
        utente_id = uuid.uuid4()

        # Restituisce un nodo in_corso: early return senza chiamare SR
        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = "nodo_in_corso"
        db.execute = AsyncMock(return_value=result_mock)

        with patch("app.core.sessione.get_nodi_da_ripassare") as mock_sr:
            nodo_scelto = await _scegli_nodo(db, utente_id)

        # SR non deve essere chiamata quando c'è un nodo in_corso
        mock_sr.assert_not_called()
        assert nodo_scelto.nodo_id == "nodo_in_corso"
        assert nodo_scelto.attivita == "spiegazione"
        assert nodo_scelto.concetti_scadenza == []

    @pytest.mark.asyncio
    @patch("app.core.sessione.grafo_knowledge")
    @patch("app.core.sessione.get_livelli_utente")
    @patch("app.core.sessione.path_planner")
    @patch("app.core.sessione.get_nodi_da_ripassare")
    @patch("app.core.sessione.random")
    async def test_sr_scelto_con_prob_alta(
        self, mock_random, mock_sr, mock_planner, mock_livelli, mock_grafo
    ):
        """Con nodi SR disponibili e random sotto soglia → sceglie SR."""
        db = AsyncMock()
        utente_id = uuid.uuid4()

        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = None  # nessun in_corso
        db.execute = AsyncMock(return_value=result_mock)

        mock_sr.return_value = ["nodo_sr_001", "nodo_sr_002"]
        mock_random.random.return_value = 0.10  # sotto PROBABILITA_INTERLEAVING

        mock_grafo.caricato = False  # non serve il grafo per SR

        with patch("app.core.sessione._nomi_nodi_sr", return_value=["Concetto A"]):
            nodo_scelto = await _scegli_nodo(db, utente_id)

        assert nodo_scelto.nodo_id == "nodo_sr_001"
        assert nodo_scelto.attivita == "ripasso_sr"
        assert nodo_scelto.concetti_scadenza == ["Concetto A"]
        # Path planner NON deve essere chiamato
        mock_planner.assert_not_called()

    @pytest.mark.asyncio
    @patch("app.core.sessione.grafo_knowledge")
    @patch("app.core.sessione.get_livelli_utente")
    @patch("app.core.sessione.path_planner")
    @patch("app.core.sessione.get_nodi_da_ripassare")
    @patch("app.core.sessione.random")
    async def test_path_planner_scelto_con_prob_bassa(
        self, mock_random, mock_sr, mock_planner, mock_livelli, mock_grafo
    ):
        """Con nodi SR disponibili ma random sopra soglia → path planner."""
        db = AsyncMock()
        utente_id = uuid.uuid4()

        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = None
        db.execute = AsyncMock(return_value=result_mock)

        mock_sr.return_value = ["nodo_sr_001"]
        mock_random.random.return_value = 0.90  # sopra PROBABILITA_INTERLEAVING

        mock_grafo.caricato = True
        mock_grafo.grafo = MagicMock()
        mock_livelli.return_value = {}
        mock_planner.return_value = "nodo_normale"

        nodo_scelto = await _scegli_nodo(db, utente_id)

        assert nodo_scelto.nodo_id == "nodo_normale"
        assert nodo_scelto.attivita == "spiegazione"
        assert nodo_scelto.concetti_scadenza == []
        mock_planner.assert_called_once()

    @pytest.mark.asyncio
    @patch("app.core.sessione.grafo_knowledge")
    @patch("app.core.sessione.get_livelli_utente")
    @patch("app.core.sessione.path_planner")
    @patch("app.core.sessione.get_nodi_da_ripassare")
    async def test_senza_nodi_sr_usa_path_planner(
        self, mock_sr, mock_planner, mock_livelli, mock_grafo
    ):
        """Senza nodi SR scaduti → sempre path planner."""
        db = AsyncMock()
        utente_id = uuid.uuid4()

        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = None
        db.execute = AsyncMock(return_value=result_mock)

        mock_sr.return_value = []  # nessun nodo SR
        mock_grafo.caricato = True
        mock_grafo.grafo = MagicMock()
        mock_livelli.return_value = {}
        mock_planner.return_value = "prossimo_nodo"

        nodo_scelto = await _scegli_nodo(db, utente_id)

        assert nodo_scelto.nodo_id == "prossimo_nodo"
        assert nodo_scelto.attivita == "spiegazione"
        mock_planner.assert_called_once()

    @pytest.mark.asyncio
    @patch("app.core.sessione.grafo_knowledge")
    @patch("app.core.sessione.get_nodi_da_ripassare")
    async def test_sr_con_grafo_non_caricato_usa_primo_nodo(self, mock_sr, mock_grafo):
        """Anche con grafo non caricato, SR seleziona il primo nodo scaduto."""
        db = AsyncMock()
        utente_id = uuid.uuid4()

        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = None
        db.execute = AsyncMock(return_value=result_mock)

        mock_sr.return_value = ["nodo_sr_urgente"]
        mock_grafo.caricato = False

        with patch("app.core.sessione.random") as mock_random:
            mock_random.random.return_value = 0.01  # sempre sotto soglia
            nodo_scelto = await _scegli_nodo(db, utente_id)

        assert nodo_scelto.nodo_id == "nodo_sr_urgente"
        assert nodo_scelto.attivita == "ripasso_sr"

    @pytest.mark.asyncio
    @patch("app.core.sessione.grafo_knowledge")
    @patch("app.core.sessione.get_nodi_da_ripassare")
    async def test_nodo_scelto_e_named_tuple(self, mock_sr, mock_grafo):
        """Il risultato è un _NodoScelto con i campi corretti."""
        db = AsyncMock()
        utente_id = uuid.uuid4()

        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = None
        db.execute = AsyncMock(return_value=result_mock)

        mock_sr.return_value = []
        mock_grafo.caricato = False

        nodo_scelto = await _scegli_nodo(db, utente_id)

        assert isinstance(nodo_scelto, _NodoScelto)
        assert hasattr(nodo_scelto, "nodo_id")
        assert hasattr(nodo_scelto, "attivita")
        assert hasattr(nodo_scelto, "concetti_scadenza")


# ===================================================================
# Test: inizia_sessione con interleaving SR
# ===================================================================


class TestIniziaSessioneInterleaving:
    @pytest.mark.asyncio
    @patch("app.core.sessione._scegli_nodo")
    @patch("app.core.sessione._cerca_sessione_sospesa")
    @patch("app.core.sessione._gestisci_sessione_attiva")
    async def test_imposta_attivita_ripasso_sr(
        self, mock_gestisci, mock_sospesa, mock_nodo
    ):
        """inizia_sessione imposta attivita_corrente='ripasso_sr' quando SR scelto."""
        db = AsyncMock()
        utente_id = uuid.uuid4()

        mock_gestisci.return_value = None
        mock_sospesa.return_value = None
        mock_nodo.return_value = _NodoScelto(
            nodo_id="nodo_sr_001",
            attivita="ripasso_sr",
            concetti_scadenza=["Equazioni di primo grado"],
        )

        sessione = await inizia_sessione(db, utente_id)

        stato = sessione.stato_orchestratore
        assert stato["nodo_focale_id"] == "nodo_sr_001"
        assert stato["attivita_corrente"] == "ripasso_sr"

    @pytest.mark.asyncio
    @patch("app.core.sessione._scegli_nodo")
    @patch("app.core.sessione._cerca_sessione_sospesa")
    @patch("app.core.sessione._gestisci_sessione_attiva")
    async def test_imposta_concetti_scadenza(
        self, mock_gestisci, mock_sospesa, mock_nodo
    ):
        """inizia_sessione salva concetti_scadenza nello stato_orchestratore."""
        db = AsyncMock()
        utente_id = uuid.uuid4()

        mock_gestisci.return_value = None
        mock_sospesa.return_value = None
        mock_nodo.return_value = _NodoScelto(
            nodo_id="nodo_sr_001",
            attivita="ripasso_sr",
            concetti_scadenza=["Concetto A", "Concetto B"],
        )

        sessione = await inizia_sessione(db, utente_id)

        stato = sessione.stato_orchestratore
        assert "concetti_scadenza" in stato
        assert stato["concetti_scadenza"] == ["Concetto A", "Concetto B"]

    @pytest.mark.asyncio
    @patch("app.core.sessione._scegli_nodo")
    @patch("app.core.sessione._cerca_sessione_sospesa")
    @patch("app.core.sessione._gestisci_sessione_attiva")
    async def test_spiegazione_senza_concetti_scadenza(
        self, mock_gestisci, mock_sospesa, mock_nodo
    ):
        """Sessione normale non ha concetti_scadenza nello stato."""
        db = AsyncMock()
        utente_id = uuid.uuid4()

        mock_gestisci.return_value = None
        mock_sospesa.return_value = None
        mock_nodo.return_value = _NodoScelto(
            nodo_id="nodo_normale",
            attivita="spiegazione",
            concetti_scadenza=[],
        )

        sessione = await inizia_sessione(db, utente_id)

        stato = sessione.stato_orchestratore
        assert stato["attivita_corrente"] == "spiegazione"
        # concetti_scadenza non deve essere impostato se lista vuota
        assert "concetti_scadenza" not in stato

    @pytest.mark.asyncio
    @patch("app.core.sessione._scegli_nodo")
    @patch("app.core.sessione._cerca_sessione_sospesa")
    @patch("app.core.sessione._gestisci_sessione_attiva")
    async def test_attivita_none_quando_nodo_none(
        self, mock_gestisci, mock_sospesa, mock_nodo
    ):
        """Se nodo_id è None (percorso completato), attivita_corrente è None."""
        db = AsyncMock()
        utente_id = uuid.uuid4()

        mock_gestisci.return_value = None
        mock_sospesa.return_value = None
        mock_nodo.return_value = _NodoScelto(
            nodo_id=None,
            attivita="spiegazione",
            concetti_scadenza=[],
        )

        sessione = await inizia_sessione(db, utente_id)

        stato = sessione.stato_orchestratore
        assert stato["nodo_focale_id"] is None
        assert stato["attivita_corrente"] is None
