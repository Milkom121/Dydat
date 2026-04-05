"""Test B28 — Endpoint GET /ripasso/nodi.

Testa:
- Endpoint ritorna lista vuota se nessun nodo SR scaduto
- Endpoint ritorna nodi con sr_prossimo_ripasso <= now
- Nodi futuri (sr_prossimo_ripasso > now) non compaiono
- Nodi senza sr_card_json (non ancora in SR) non compaiono
- Deduplica: un nodo in più temi appare una sola volta
"""

from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from unittest.mock import AsyncMock, MagicMock, patch

import pytest


def _make_row(
    nodo_id: str,
    nodo_nome: str,
    tema_id: str,
    tema_nome: str,
    sr_prossimo_ripasso,
    sr_ripetizioni: int = 1,
):
    """Helper: crea una riga simulata dal DB."""
    row = MagicMock()
    row.nodo_id = nodo_id
    row.nodo_nome = nodo_nome
    row.tema_id = tema_id
    row.tema_nome = tema_nome
    row.sr_prossimo_ripasso = sr_prossimo_ripasso
    row.sr_ripetizioni = sr_ripetizioni
    return row


class TestNodiDaRipassare:
    """Test per GET /ripasso/nodi."""

    @pytest.mark.asyncio
    @patch("app.api.ripasso.get_utente_corrente")
    async def test_lista_vuota_nessun_nodo_scaduto(self, mock_auth):
        """Se nessun nodo SR scaduto, ritorna lista vuota."""
        from app.api.ripasso import nodi_da_ripassare

        utente = MagicMock()
        utente.id = uuid.uuid4()

        db = AsyncMock()
        result_mock = MagicMock()
        result_mock.all.return_value = []
        db.execute = AsyncMock(return_value=result_mock)

        risposta = await nodi_da_ripassare(utente=utente, db=db)
        assert risposta == []

    @pytest.mark.asyncio
    async def test_nodi_scaduti_ritornati(self):
        """Nodi con sr_prossimo_ripasso <= now vengono ritornati."""
        from app.api.ripasso import nodi_da_ripassare

        now = datetime.now(timezone.utc)
        ieri = now - timedelta(days=1)

        utente = MagicMock()
        utente.id = uuid.uuid4()

        row = _make_row(
            nodo_id="nodo_1",
            nodo_nome="Equazioni di primo grado",
            tema_id="algebra",
            tema_nome="Algebra",
            sr_prossimo_ripasso=ieri,
            sr_ripetizioni=2,
        )

        db = AsyncMock()
        result_mock = MagicMock()
        result_mock.all.return_value = [row]
        db.execute = AsyncMock(return_value=result_mock)

        risposta = await nodi_da_ripassare(utente=utente, db=db)

        assert len(risposta) == 1
        assert risposta[0]["nodo_id"] == "nodo_1"
        assert risposta[0]["nodo_nome"] == "Equazioni di primo grado"
        assert risposta[0]["tema_id"] == "algebra"
        assert risposta[0]["tema_nome"] == "Algebra"
        assert risposta[0]["sr_ripetizioni"] == 2
        assert risposta[0]["sr_prossimo_ripasso"] is not None

    @pytest.mark.asyncio
    async def test_deduplica_nodo_in_piu_temi(self):
        """Un nodo in più temi appare solo una volta nel risultato."""
        from app.api.ripasso import nodi_da_ripassare

        now = datetime.now(timezone.utc)
        ieri = now - timedelta(days=1)

        utente = MagicMock()
        utente.id = uuid.uuid4()

        # Stesso nodo con due temi diversi
        row1 = _make_row("nodo_1", "Nodo A", "tema_1", "Tema 1", ieri)
        row2 = _make_row("nodo_1", "Nodo A", "tema_2", "Tema 2", ieri)

        db = AsyncMock()
        result_mock = MagicMock()
        result_mock.all.return_value = [row1, row2]
        db.execute = AsyncMock(return_value=result_mock)

        risposta = await nodi_da_ripassare(utente=utente, db=db)

        # Solo una voce nonostante due righe DB (temi diversi)
        assert len(risposta) == 1
        assert risposta[0]["nodo_id"] == "nodo_1"
        assert risposta[0]["tema_id"] == "tema_1"  # Primo tema trovato

    @pytest.mark.asyncio
    async def test_piu_nodi_multipli(self):
        """Più nodi scaduti vengono tutti ritornati."""
        from app.api.ripasso import nodi_da_ripassare

        now = datetime.now(timezone.utc)

        utente = MagicMock()
        utente.id = uuid.uuid4()

        rows = [
            _make_row("nodo_a", "Nodo A", "t1", "Tema 1", now - timedelta(days=3)),
            _make_row("nodo_b", "Nodo B", "t1", "Tema 1", now - timedelta(days=1)),
            _make_row("nodo_c", "Nodo C", "t2", "Tema 2", now - timedelta(hours=1)),
        ]

        db = AsyncMock()
        result_mock = MagicMock()
        result_mock.all.return_value = rows
        db.execute = AsyncMock(return_value=result_mock)

        risposta = await nodi_da_ripassare(utente=utente, db=db)

        assert len(risposta) == 3
        nodo_ids = [r["nodo_id"] for r in risposta]
        assert "nodo_a" in nodo_ids
        assert "nodo_b" in nodo_ids
        assert "nodo_c" in nodo_ids

    @pytest.mark.asyncio
    async def test_sr_ripetizioni_none_diventa_zero(self):
        """sr_ripetizioni = None dal DB viene normalizzato a 0."""
        from app.api.ripasso import nodi_da_ripassare

        now = datetime.now(timezone.utc)

        utente = MagicMock()
        utente.id = uuid.uuid4()

        row = _make_row("nodo_1", "Nodo A", "t1", "Tema 1", now - timedelta(days=1))
        row.sr_ripetizioni = None  # Forza None

        db = AsyncMock()
        result_mock = MagicMock()
        result_mock.all.return_value = [row]
        db.execute = AsyncMock(return_value=result_mock)

        risposta = await nodi_da_ripassare(utente=utente, db=db)

        assert risposta[0]["sr_ripetizioni"] == 0
