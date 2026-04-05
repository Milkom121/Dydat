"""Test B29 — Sessioni Ripasso Dedicate.

Testa:
- _scegli_nodo_ripasso() sceglie il nodo SR più urgente
- _scegli_nodo_ripasso() ritorna None se nessun nodo da ripassare
- inizia_sessione() con tipo=ripasso usa _scegli_nodo_ripasso
- inizia_sessione() con tipo=media usa _scegli_nodo (normale)
- stato_orchestratore con attivita_corrente=ripasso_sr per sessioni ripasso
- stato_orchestratore contiene concetti_scadenza per sessioni ripasso
"""

from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from unittest.mock import AsyncMock, MagicMock, patch

import pytest


class TestScegliNodoRipasso:
    """Test per _scegli_nodo_ripasso()."""

    @pytest.mark.asyncio
    async def test_sceglie_nodo_piu_urgente(self):
        """Con nodi SR scaduti, sceglie il primo (più urgente)."""
        from app.core.sessione import _scegli_nodo_ripasso

        utente_id = uuid.uuid4()
        db = AsyncMock()

        with patch(
            "app.core.sessione.get_nodi_da_ripassare",
            new=AsyncMock(return_value=["nodo_urgente", "nodo_meno_urgente"]),
        ):
            risultato = await _scegli_nodo_ripasso(db, utente_id)

        assert risultato.nodo_id == "nodo_urgente"
        assert risultato.attivita == "ripasso_sr"

    @pytest.mark.asyncio
    async def test_nessun_nodo_fallback_path_planner(self):
        """Senza nodi SR scaduti, cade in fallback al path planner.

        Grafo non caricato → nodo_id=None, attivita=spiegazione.
        """
        from app.core.sessione import _scegli_nodo_ripasso

        utente_id = uuid.uuid4()
        db = AsyncMock()

        with patch(
            "app.core.sessione.get_nodi_da_ripassare",
            new=AsyncMock(return_value=[]),
        ):
            # Grafo non caricato in test env → ritorna nodo_id=None con spiegazione
            risultato = await _scegli_nodo_ripasso(db, utente_id)

        # Fallback a path planner: nodo_id=None (grafo non caricato), attivita=spiegazione
        assert risultato.nodo_id is None
        assert risultato.concetti_scadenza == []

    @pytest.mark.asyncio
    async def test_concetti_scadenza_popolati(self):
        """I concetti_scadenza contengono i nomi dei nodi SR."""
        from app.core.sessione import _scegli_nodo_ripasso

        utente_id = uuid.uuid4()
        db = AsyncMock()

        nodi_sr = ["nodo_a", "nodo_b", "nodo_c"]

        with patch(
            "app.core.sessione.get_nodi_da_ripassare",
            new=AsyncMock(return_value=nodi_sr),
        ):
            risultato = await _scegli_nodo_ripasso(db, utente_id)

        # concetti_scadenza ha max 5 nomi (logica di _nomi_nodi_sr)
        assert len(risultato.concetti_scadenza) == 3

    @pytest.mark.asyncio
    async def test_non_usa_probabilita(self):
        """_scegli_nodo_ripasso sceglie sempre il nodo SR, mai il path planner."""
        from app.core.sessione import _scegli_nodo_ripasso

        utente_id = uuid.uuid4()
        db = AsyncMock()

        with patch(
            "app.core.sessione.get_nodi_da_ripassare",
            new=AsyncMock(return_value=["nodo_sr_1"]),
        ) as mock_sr, patch(
            "app.core.sessione.path_planner"
        ) as mock_path:
            risultato = await _scegli_nodo_ripasso(db, utente_id)

        # SR chiamato, path planner MAI chiamato
        mock_sr.assert_awaited_once()
        mock_path.assert_not_called()
        assert risultato.nodo_id == "nodo_sr_1"


class TestIniziaSessioneRipasso:
    """Test per inizia_sessione() con tipo=ripasso."""

    @pytest.mark.asyncio
    async def test_tipo_ripasso_usa_scegli_nodo_ripasso(self):
        """Con tipo=ripasso, usa _scegli_nodo_ripasso invece di _scegli_nodo."""
        from app.core.sessione import inizia_sessione, _NodoScelto

        utente_id = uuid.uuid4()
        db = AsyncMock()
        db.flush = AsyncMock()

        # Simula DB: nessuna sessione attiva né sospesa
        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = None
        db.execute = AsyncMock(return_value=result_mock)

        nodo_ripasso = _NodoScelto(
            nodo_id="nodo_sr_urgente", attivita="ripasso_sr", concetti_scadenza=["Algebra"]
        )

        with patch("app.core.sessione._gestisci_sessione_attiva", new=AsyncMock()), \
             patch("app.core.sessione._cerca_sessione_sospesa", new=AsyncMock(return_value=None)), \
             patch("app.core.sessione._scegli_nodo_ripasso", new=AsyncMock(return_value=nodo_ripasso)) as mock_ripasso, \
             patch("app.core.sessione._scegli_nodo") as mock_normale:
            sessione = await inizia_sessione(db=db, utente_id=utente_id, tipo="ripasso")

        mock_ripasso.assert_awaited_once()
        mock_normale.assert_not_called()
        assert sessione.stato_orchestratore["attivita_corrente"] == "ripasso_sr"
        assert sessione.stato_orchestratore["nodo_focale_id"] == "nodo_sr_urgente"

    @pytest.mark.asyncio
    async def test_tipo_media_usa_scegli_nodo_normale(self):
        """Con tipo=media, usa _scegli_nodo (con interleaving) invece di _scegli_nodo_ripasso."""
        from app.core.sessione import inizia_sessione, _NodoScelto

        utente_id = uuid.uuid4()
        db = AsyncMock()
        db.flush = AsyncMock()

        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = None
        db.execute = AsyncMock(return_value=result_mock)

        nodo_normale = _NodoScelto(
            nodo_id="nodo_percorso", attivita="spiegazione", concetti_scadenza=[]
        )

        with patch("app.core.sessione._gestisci_sessione_attiva", new=AsyncMock()), \
             patch("app.core.sessione._cerca_sessione_sospesa", new=AsyncMock(return_value=None)), \
             patch("app.core.sessione._scegli_nodo", new=AsyncMock(return_value=nodo_normale)) as mock_normale, \
             patch("app.core.sessione._scegli_nodo_ripasso") as mock_ripasso:
            sessione = await inizia_sessione(db=db, utente_id=utente_id, tipo="media")

        mock_normale.assert_awaited_once()
        mock_ripasso.assert_not_called()

    @pytest.mark.asyncio
    async def test_concetti_scadenza_in_stato_orchestratore(self):
        """I concetti_scadenza vengono salvati in stato_orchestratore per tipo=ripasso."""
        from app.core.sessione import inizia_sessione, _NodoScelto

        utente_id = uuid.uuid4()
        db = AsyncMock()
        db.flush = AsyncMock()

        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = None
        db.execute = AsyncMock(return_value=result_mock)

        nodo_ripasso = _NodoScelto(
            nodo_id="nodo_sr",
            attivita="ripasso_sr",
            concetti_scadenza=["Algebra", "Geometria"],
        )

        with patch("app.core.sessione._gestisci_sessione_attiva", new=AsyncMock()), \
             patch("app.core.sessione._cerca_sessione_sospesa", new=AsyncMock(return_value=None)), \
             patch("app.core.sessione._scegli_nodo_ripasso", new=AsyncMock(return_value=nodo_ripasso)):
            sessione = await inizia_sessione(db=db, utente_id=utente_id, tipo="ripasso")

        stato = sessione.stato_orchestratore
        assert "concetti_scadenza" in stato
        assert stato["concetti_scadenza"] == ["Algebra", "Geometria"]
