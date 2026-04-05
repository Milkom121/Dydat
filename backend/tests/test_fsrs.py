"""Test Blocco B26 — FSRS Spaced Repetition.

Testa:
- calcola_prossimo_ripasso: aggiorna campi SR su stato_nodi_utente
- get_nodi_da_ripassare: query nodi scaduti per ripasso
- Integrazione FSRS in _processa_risposta_esercizio
- Mappatura esiti → Rating
- Ricostruzione Card da sr_card_json
"""

from __future__ import annotations

import json
import uuid
from datetime import datetime, timedelta, timezone
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.grafo.fsrs import (
    ESITO_TO_RATING,
    _crea_card_da_stato,
    calcola_prossimo_ripasso,
    get_nodi_da_ripassare,
)


# ===================================================================
# Test: mappatura esiti
# ===================================================================


class TestMappingEsiti:
    def test_primo_tentativo_mappa_good(self):
        assert ESITO_TO_RATING["primo_tentativo"] == "Good"

    def test_con_guida_mappa_hard(self):
        assert ESITO_TO_RATING["con_guida"] == "Hard"

    def test_non_risolto_mappa_again(self):
        assert ESITO_TO_RATING["non_risolto"] == "Again"

    def test_esiti_coprono_tutti_i_casi(self):
        # I tre esiti usati in elaborazione.py devono avere una mappatura
        esiti_usati = {"primo_tentativo", "con_guida", "non_risolto"}
        assert esiti_usati.issubset(ESITO_TO_RATING.keys())


# ===================================================================
# Test: _crea_card_da_stato
# ===================================================================


class TestCreaCardDaStato:
    def test_stato_none_ritorna_card_nuova(self):
        """Senza stato DB, crea Card() nuova."""
        card = _crea_card_da_stato(None)
        try:
            from fsrs import Card

            assert card is not None
            assert isinstance(card, Card)
        except ImportError:
            assert card is None

    def test_stato_senza_card_json_ritorna_card_nuova(self):
        """Stato con sr_card_json=None → Card() nuova (prima review)."""
        stato_mock = MagicMock()
        stato_mock.sr_card_json = None
        card = _crea_card_da_stato(stato_mock)
        try:
            from fsrs import Card

            assert card is not None
            assert isinstance(card, Card)
        except ImportError:
            assert card is None

    def test_stato_con_card_json_ricostruisce_correttamente(self):
        """Stato con sr_card_json popolato → Card ricostruita correttamente."""
        try:
            from fsrs import Card, Rating, Scheduler
        except ImportError:
            pytest.skip("Libreria fsrs non installata")

        # Crea una Card reale e serializzala
        s = Scheduler()
        c = Card()
        c2, _ = s.review_card(c, Rating.Good)
        card_json_dict = json.loads(c2.to_json())

        stato_mock = MagicMock()
        stato_mock.sr_card_json = card_json_dict
        stato_mock.nodo_id = "nodo_test"

        card_ricostruita = _crea_card_da_stato(stato_mock)

        assert card_ricostruita is not None
        assert isinstance(card_ricostruita, Card)
        assert card_ricostruita.stability == c2.stability
        assert card_ricostruita.difficulty == c2.difficulty

    def test_card_json_malformato_fallback_a_nuova(self):
        """sr_card_json non valido → fallback a Card() nuova."""
        try:
            from fsrs import Card
        except ImportError:
            pytest.skip("Libreria fsrs non installata")

        stato_mock = MagicMock()
        stato_mock.sr_card_json = {"campo_invalido": "valore_errato"}
        stato_mock.nodo_id = "nodo_test"

        # Non deve sollevare eccezioni
        card = _crea_card_da_stato(stato_mock)
        assert card is not None
        assert isinstance(card, Card)


# ===================================================================
# Test: calcola_prossimo_ripasso
# ===================================================================


class TestCalcolaProssimoRipasso:
    @pytest.mark.asyncio
    async def test_primo_tentativo_aggiorna_campi_sr(self):
        """primo_tentativo → campi SR aggiornati nello stato."""
        try:
            from fsrs import Card, Rating, Scheduler
        except ImportError:
            pytest.skip("Libreria fsrs non installata")

        utente_id = uuid.uuid4()
        nodo_id = "nodo_test_001"
        now = datetime.now(timezone.utc)

        # Stato senza review SR precedenti
        stato_mock = MagicMock()
        stato_mock.sr_card_json = None
        stato_mock.sr_ripetizioni = None
        stato_mock.nodo_id = nodo_id

        db_mock = AsyncMock()
        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = stato_mock
        db_mock.execute.return_value = result_mock

        await calcola_prossimo_ripasso(utente_id, nodo_id, "primo_tentativo", db_mock)

        # Verifica che i campi SR siano stati aggiornati
        assert stato_mock.sr_prossimo_ripasso is not None
        assert stato_mock.sr_prossimo_ripasso > now
        assert stato_mock.sr_ripetizioni == 1
        assert stato_mock.sr_stabilita is not None
        assert stato_mock.sr_card_json is not None
        db_mock.flush.assert_awaited_once()

    @pytest.mark.asyncio
    async def test_non_risolto_intervallo_breve(self):
        """non_risolto → Rating.Again → intervallo molto breve."""
        try:
            from fsrs import Card, Rating, Scheduler
        except ImportError:
            pytest.skip("Libreria fsrs non installata")

        utente_id = uuid.uuid4()
        nodo_id = "nodo_test_002"

        stato_mock = MagicMock()
        stato_mock.sr_card_json = None
        stato_mock.sr_ripetizioni = None
        stato_mock.nodo_id = nodo_id

        db_mock = AsyncMock()
        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = stato_mock
        db_mock.execute.return_value = result_mock

        await calcola_prossimo_ripasso(utente_id, nodo_id, "non_risolto", db_mock)

        # Rating.Again → ripasso imminente (< 1 giorno)
        assert stato_mock.sr_prossimo_ripasso is not None
        assert stato_mock.sr_intervallo_giorni < 1.0

    @pytest.mark.asyncio
    async def test_ripetizioni_si_incrementano(self):
        """sr_ripetizioni deve incrementarsi a ogni review."""
        try:
            from fsrs import Card, Rating, Scheduler
        except ImportError:
            pytest.skip("Libreria fsrs non installata")

        utente_id = uuid.uuid4()
        nodo_id = "nodo_test_003"

        stato_mock = MagicMock()
        stato_mock.sr_card_json = None
        stato_mock.sr_ripetizioni = 2  # già 2 review precedenti
        stato_mock.nodo_id = nodo_id

        db_mock = AsyncMock()
        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = stato_mock
        db_mock.execute.return_value = result_mock

        await calcola_prossimo_ripasso(utente_id, nodo_id, "con_guida", db_mock)

        assert stato_mock.sr_ripetizioni == 3

    @pytest.mark.asyncio
    async def test_card_json_salvato_come_dict(self):
        """sr_card_json deve essere un dict (non stringa) per compatibilità JSONB."""
        try:
            from fsrs import Card, Rating, Scheduler
        except ImportError:
            pytest.skip("Libreria fsrs non installata")

        utente_id = uuid.uuid4()
        nodo_id = "nodo_test_004"

        stato_mock = MagicMock()
        stato_mock.sr_card_json = None
        stato_mock.sr_ripetizioni = None
        stato_mock.nodo_id = nodo_id

        db_mock = AsyncMock()
        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = stato_mock
        db_mock.execute.return_value = result_mock

        await calcola_prossimo_ripasso(utente_id, nodo_id, "primo_tentativo", db_mock)

        assert isinstance(stato_mock.sr_card_json, dict)

    @pytest.mark.asyncio
    async def test_stato_assente_usa_upsert(self):
        """Se stato_nodi_utente non esiste, usa UPSERT (2 execute: SELECT + INSERT)."""
        try:
            from fsrs import Card, Rating, Scheduler
        except ImportError:
            pytest.skip("Libreria fsrs non installata")

        utente_id = uuid.uuid4()
        nodo_id = "nodo_test_005"

        db_mock = AsyncMock()
        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = None
        db_mock.execute.return_value = result_mock

        await calcola_prossimo_ripasso(utente_id, nodo_id, "primo_tentativo", db_mock)

        # SELECT (1) + INSERT ON CONFLICT (1) = 2 execute
        assert db_mock.execute.await_count == 2

    @pytest.mark.asyncio
    async def test_fsrs_non_disponibile_silenzioso(self):
        """Se fsrs non è installato, la funzione ritorna silenziosamente senza toccare il DB."""
        utente_id = uuid.uuid4()
        db_mock = AsyncMock()

        with patch("app.grafo.fsrs._FSRS_AVAILABLE", False):
            await calcola_prossimo_ripasso(utente_id, "nodo_x", "primo_tentativo", db_mock)

        db_mock.execute.assert_not_awaited()

    @pytest.mark.asyncio
    async def test_esito_sconosciuto_usa_again(self):
        """Esito non mappato → fallback a Rating.Again."""
        try:
            from fsrs import Card, Rating, Scheduler
        except ImportError:
            pytest.skip("Libreria fsrs non installata")

        utente_id = uuid.uuid4()
        nodo_id = "nodo_test_006"

        stato_mock = MagicMock()
        stato_mock.sr_card_json = None
        stato_mock.sr_ripetizioni = None
        stato_mock.nodo_id = nodo_id

        db_mock = AsyncMock()
        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = stato_mock
        db_mock.execute.return_value = result_mock

        # Non deve sollevare eccezioni
        await calcola_prossimo_ripasso(utente_id, nodo_id, "esito_invalido", db_mock)

        # Deve aver aggiornato comunque (con Rating.Again)
        assert stato_mock.sr_ripetizioni == 1


# ===================================================================
# Test: get_nodi_da_ripassare
# ===================================================================


class TestGetNodiDaRipassare:
    @pytest.mark.asyncio
    async def test_ritorna_nodi_scaduti(self):
        """Nodi con sr_prossimo_ripasso passato vengono ritornati."""
        utente_id = uuid.uuid4()

        db_mock = AsyncMock()
        result_mock = MagicMock()
        result_mock.all.return_value = [("nodo_A",), ("nodo_B",)]
        db_mock.execute.return_value = result_mock

        nodi = await get_nodi_da_ripassare(utente_id, db_mock)

        assert nodi == ["nodo_A", "nodo_B"]
        db_mock.execute.assert_awaited_once()

    @pytest.mark.asyncio
    async def test_nessun_nodo_da_ripassare(self):
        """Nessun nodo scaduto → lista vuota."""
        utente_id = uuid.uuid4()

        db_mock = AsyncMock()
        result_mock = MagicMock()
        result_mock.all.return_value = []
        db_mock.execute.return_value = result_mock

        nodi = await get_nodi_da_ripassare(utente_id, db_mock)

        assert nodi == []

    @pytest.mark.asyncio
    async def test_ritorna_lista_di_stringhe(self):
        """Il risultato deve essere una lista di stringhe (nodo_id)."""
        utente_id = uuid.uuid4()

        db_mock = AsyncMock()
        result_mock = MagicMock()
        result_mock.all.return_value = [("nodo_algebra_001",)]
        db_mock.execute.return_value = result_mock

        nodi = await get_nodi_da_ripassare(utente_id, db_mock)

        assert isinstance(nodi, list)
        assert all(isinstance(n, str) for n in nodi)


# ===================================================================
# Test: integrazione FSRS in elaborazione.py
# ===================================================================


class TestFsrsInElaborazione:
    @pytest.mark.asyncio
    async def test_risposta_esercizio_chiama_fsrs(self):
        """processa_segnali con risposta_esercizio deve chiamare calcola_prossimo_ripasso."""
        from app.core.elaborazione import processa_segnali

        utente_id = uuid.uuid4()
        sessione_id = uuid.uuid4()

        segnali = [
            {
                "name": "risposta_esercizio",
                "input": {
                    "esercizio_id": "eserc_001",
                    "nodo_focale": "nodo_001",
                    "esito": "primo_tentativo",
                },
            }
        ]

        db_mock = AsyncMock()
        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = None
        result_mock.scalar_one.return_value = 1  # primo_tentativo_count
        db_mock.execute.return_value = result_mock

        with patch("app.core.elaborazione.calcola_prossimo_ripasso") as mock_fsrs:
            mock_fsrs.return_value = None
            promozioni, esiti = await processa_segnali(
                db_mock, segnali, sessione_id, utente_id
            )

        # FSRS deve essere stato chiamato con i parametri corretti
        mock_fsrs.assert_awaited_once_with(utente_id, "nodo_001", "primo_tentativo", db_mock)

    @pytest.mark.asyncio
    async def test_tutti_e_tre_gli_esiti_chiamano_fsrs(self):
        """FSRS viene chiamato per tutti e tre i tipi di esito."""
        from app.core.elaborazione import processa_segnali

        utente_id = uuid.uuid4()
        sessione_id = uuid.uuid4()

        for esito in ["primo_tentativo", "con_guida", "non_risolto"]:
            segnali = [
                {
                    "name": "risposta_esercizio",
                    "input": {
                        "esercizio_id": f"eserc_{esito}",
                        "nodo_focale": "nodo_001",
                        "esito": esito,
                    },
                }
            ]

            db_mock = AsyncMock()
            result_mock = MagicMock()
            result_mock.scalar_one_or_none.return_value = None
            result_mock.scalar_one.return_value = 0
            db_mock.execute.return_value = result_mock

            with patch("app.core.elaborazione.calcola_prossimo_ripasso") as mock_fsrs:
                mock_fsrs.return_value = None
                await processa_segnali(db_mock, segnali, sessione_id, utente_id)

            mock_fsrs.assert_awaited_once_with(utente_id, "nodo_001", esito, db_mock)

    @pytest.mark.asyncio
    async def test_segnale_senza_nodo_focale_non_chiama_fsrs(self):
        """Se nodo_focale è vuoto, elaborazione.py ritorna early e non chiama FSRS."""
        from app.core.elaborazione import processa_segnali

        utente_id = uuid.uuid4()
        sessione_id = uuid.uuid4()

        segnali = [
            {
                "name": "risposta_esercizio",
                "input": {
                    "esercizio_id": "eserc_001",
                    "nodo_focale": "",  # vuoto → return None early
                    "esito": "primo_tentativo",
                },
            }
        ]

        db_mock = AsyncMock()

        with patch("app.core.elaborazione.calcola_prossimo_ripasso") as mock_fsrs:
            await processa_segnali(db_mock, segnali, sessione_id, utente_id)

        mock_fsrs.assert_not_awaited()
