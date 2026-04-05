"""Test B27 — Interleaving SR in aggiorna_nodo_dopo_promozione.

Testa:
- Interleaving dopo promozione: con probabilità sotto soglia e nodi SR scaduti
- Nodo promosso escluso dall'interleaving (appena visto, non serve ripassarlo)
- Random sopra soglia → nessun interleaving
- concetti_scadenza puliti quando non è ripasso
"""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, MagicMock, patch

import pytest  # noqa: F401 — usato per mark.asyncio

# ===================================================================
# Helper
# ===================================================================


def _mock_sessione(
    sessione_id=None,
    stato_orchestratore=None,
    nodi_lavorati=None,
):
    sess = MagicMock()
    sess.id = sessione_id or uuid.uuid4()
    sess.utente_id = uuid.uuid4()
    sess.stato = "attiva"
    sess.created_at = datetime.now(timezone.utc)
    sess.stato_orchestratore = stato_orchestratore if stato_orchestratore is not None else {}
    sess.nodi_lavorati = nodi_lavorati or []
    sess.tipo = "media"
    return sess


# ===================================================================
# Test: interleaving SR in aggiorna_nodo_dopo_promozione
# ===================================================================


class TestInterleavingDopoPromozione:
    """Test interleaving SR in aggiorna_nodo_dopo_promozione."""

    @pytest.mark.asyncio
    @patch("app.core.elaborazione.get_nodi_da_ripassare")
    @patch("app.core.elaborazione.random")
    @patch("app.core.elaborazione.get_livelli_utente")
    @patch("app.core.elaborazione.grafo_knowledge")
    async def test_interleaving_dopo_promozione(
        self, mock_grafo, mock_livelli, mock_random, mock_sr
    ):
        """Dopo promozione, con probabilità sotto soglia e nodi SR, sceglie ripasso."""
        from app.core.elaborazione import aggiorna_nodo_dopo_promozione

        db = AsyncMock()
        sessione_id = uuid.uuid4()
        utente_id = uuid.uuid4()

        mock_grafo.caricato = True
        # Uso MagicMock per .nodes con __contains__ e __getitem__
        nodes_dict = {
            "nodo_promosso": {"nome": "Nodo Promosso", "tema_id": "algebra"},
            "nodo_successivo": {"nome": "Nodo Successivo"},
            "nodo_sr_scaduto": {"nome": "Polinomi"},
        }
        mock_grafo.grafo = MagicMock()
        mock_grafo.grafo.nodes.__contains__ = lambda self, k: k in nodes_dict
        mock_grafo.grafo.nodes.__getitem__ = lambda self, k: nodes_dict[k]
        mock_grafo.grafo.nodes.get = lambda k, d=None: nodes_dict.get(k, d)

        mock_livelli.return_value = {"nodo_promosso": "in_corso"}

        with patch("app.grafo.algoritmi.path_planner") as mock_planner:
            mock_planner.return_value = "nodo_successivo"

            # Nodi SR scaduti (il nodo promosso verrà escluso dal codice)
            mock_sr.return_value = ["nodo_sr_scaduto"]
            mock_random.random.return_value = 0.1  # sotto soglia → interleaving

            # Mock della sessione
            sess_mock = _mock_sessione(
                sessione_id=sessione_id,
                stato_orchestratore={"nodo_focale_id": "nodo_promosso"},
                nodi_lavorati=[],
            )
            result_mock = MagicMock()
            result_mock.scalar_one_or_none.return_value = sess_mock
            db.execute = AsyncMock(return_value=result_mock)

            prossimo = await aggiorna_nodo_dopo_promozione(
                db, sessione_id, utente_id, "nodo_promosso"
            )

        # Deve aver scelto il nodo SR
        assert prossimo == "nodo_sr_scaduto"
        stato = sess_mock.stato_orchestratore
        assert stato["attivita_corrente"] == "ripasso_sr"
        assert "concetti_scadenza" in stato
        assert "Polinomi" in stato["concetti_scadenza"]

    @pytest.mark.asyncio
    @patch("app.core.elaborazione.get_nodi_da_ripassare")
    @patch("app.core.elaborazione.random")
    @patch("app.core.elaborazione.get_livelli_utente")
    @patch("app.core.elaborazione.grafo_knowledge")
    async def test_nodo_promosso_escluso_da_interleaving(
        self, mock_grafo, mock_livelli, mock_random, mock_sr
    ):
        """Il nodo appena promosso non può essere scelto come SR da ripassare."""
        from app.core.elaborazione import aggiorna_nodo_dopo_promozione

        db = AsyncMock()
        sessione_id = uuid.uuid4()
        utente_id = uuid.uuid4()

        nodes_dict = {
            "nodo_A": {"nome": "Nodo A", "tema_id": "algebra"},
            "nodo_B": {"nome": "Nodo B"},
        }
        mock_grafo.caricato = True
        mock_grafo.grafo = MagicMock()
        mock_grafo.grafo.nodes.__contains__ = lambda self, k: k in nodes_dict
        mock_grafo.grafo.nodes.__getitem__ = lambda self, k: nodes_dict[k]
        mock_grafo.grafo.nodes.get = lambda k, d=None: nodes_dict.get(k, d)

        mock_livelli.return_value = {"nodo_A": "in_corso"}

        with patch("app.grafo.algoritmi.path_planner") as mock_planner:
            mock_planner.return_value = "nodo_B"

            # Solo il nodo promosso è scaduto → dopo esclusione, lista vuota
            mock_sr.return_value = ["nodo_A"]
            mock_random.random.return_value = 0.1  # sotto soglia

            sess_mock = _mock_sessione(
                sessione_id=sessione_id,
                stato_orchestratore={},
                nodi_lavorati=[],
            )
            result_mock = MagicMock()
            result_mock.scalar_one_or_none.return_value = sess_mock
            db.execute = AsyncMock(return_value=result_mock)

            prossimo = await aggiorna_nodo_dopo_promozione(
                db, sessione_id, utente_id, "nodo_A"
            )

        # nodo_A escluso dall'interleaving → path planner normale
        assert prossimo == "nodo_B"
        assert sess_mock.stato_orchestratore["attivita_corrente"] == "spiegazione"

    @pytest.mark.asyncio
    @patch("app.core.elaborazione.get_nodi_da_ripassare")
    @patch("app.core.elaborazione.random")
    @patch("app.core.elaborazione.get_livelli_utente")
    @patch("app.core.elaborazione.grafo_knowledge")
    async def test_random_sopra_soglia_no_interleaving(
        self, mock_grafo, mock_livelli, mock_random, mock_sr
    ):
        """Se random >= soglia, nessun interleaving anche con nodi SR."""
        from app.core.elaborazione import aggiorna_nodo_dopo_promozione

        db = AsyncMock()
        sessione_id = uuid.uuid4()
        utente_id = uuid.uuid4()

        nodes_dict = {
            "nodo_X": {"nome": "Nodo X", "tema_id": "algebra"},
            "nodo_Y": {"nome": "Nodo Y"},
        }
        mock_grafo.caricato = True
        mock_grafo.grafo = MagicMock()
        mock_grafo.grafo.nodes.__contains__ = lambda self, k: k in nodes_dict
        mock_grafo.grafo.nodes.__getitem__ = lambda self, k: nodes_dict[k]
        mock_grafo.grafo.nodes.get = lambda k, d=None: nodes_dict.get(k, d)

        mock_livelli.return_value = {}

        with patch("app.grafo.algoritmi.path_planner") as mock_planner:
            mock_planner.return_value = "nodo_Y"

            mock_sr.return_value = ["nodo_sr_scaduto"]
            mock_random.random.return_value = 0.9  # sopra soglia

            sess_mock = _mock_sessione(
                sessione_id=sessione_id,
                stato_orchestratore={},
                nodi_lavorati=[],
            )
            result_mock = MagicMock()
            result_mock.scalar_one_or_none.return_value = sess_mock
            db.execute = AsyncMock(return_value=result_mock)

            prossimo = await aggiorna_nodo_dopo_promozione(
                db, sessione_id, utente_id, "nodo_X"
            )

        assert prossimo == "nodo_Y"
        assert sess_mock.stato_orchestratore["attivita_corrente"] == "spiegazione"
        assert "concetti_scadenza" not in sess_mock.stato_orchestratore

    @pytest.mark.asyncio
    @patch("app.core.elaborazione.get_nodi_da_ripassare")
    @patch("app.core.elaborazione.get_livelli_utente")
    @patch("app.core.elaborazione.grafo_knowledge")
    async def test_concetti_scadenza_puliti_se_no_ripasso(
        self, mock_grafo, mock_livelli, mock_sr
    ):
        """Se non c'è interleaving, concetti_scadenza viene rimosso dallo stato."""
        from app.core.elaborazione import aggiorna_nodo_dopo_promozione

        db = AsyncMock()
        sessione_id = uuid.uuid4()
        utente_id = uuid.uuid4()

        nodes_dict = {
            "nodo_Z": {"nome": "Nodo Z", "tema_id": "algebra"},
            "nodo_W": {"nome": "Nodo W"},
        }
        mock_grafo.caricato = True
        mock_grafo.grafo = MagicMock()
        mock_grafo.grafo.nodes.__contains__ = lambda self, k: k in nodes_dict
        mock_grafo.grafo.nodes.__getitem__ = lambda self, k: nodes_dict[k]
        mock_grafo.grafo.nodes.get = lambda k, d=None: nodes_dict.get(k, d)

        mock_livelli.return_value = {}
        mock_sr.return_value = []  # nessun nodo SR

        with patch("app.grafo.algoritmi.path_planner") as mock_planner:
            mock_planner.return_value = "nodo_W"

            # Stato precedente con concetti_scadenza residui
            sess_mock = _mock_sessione(
                sessione_id=sessione_id,
                stato_orchestratore={
                    "concetti_scadenza": ["Vecchio concetto"],
                },
                nodi_lavorati=[],
            )
            result_mock = MagicMock()
            result_mock.scalar_one_or_none.return_value = sess_mock
            db.execute = AsyncMock(return_value=result_mock)

            await aggiorna_nodo_dopo_promozione(
                db, sessione_id, utente_id, "nodo_Z"
            )

        # concetti_scadenza deve essere stato rimosso
        assert "concetti_scadenza" not in sess_mock.stato_orchestratore
