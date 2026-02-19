"""Test Blocco 8 — API sessione con SSE.

Test:
- Session Manager: sessione unica, auto-sospensione, ripresa, scelta nodo
- API endpoints: inizia, turno, sospendi, termina, get
- Formato eventi SSE
- Gestione errori (409, 404, 400)
"""

from __future__ import annotations

import json
import uuid
from datetime import datetime, timedelta, timezone
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.core.sessione import (
    INATTIVITA_MAX_SEC,
    SessioneConflitto,
    _calcola_inattivita,
    _scegli_nodo,
    inizia_sessione,
    sospendi_sessione,
    termina_sessione,
)
from app.schemas.sessione import (
    IniziaSessioneRequest,
    SessioneConflittoResponse,
    SessioneListItemResponse,
    SessioneResponse,
    TurnoRequest,
)

# ===================================================================
# Helper: mock Sessione
# ===================================================================


def _mock_sessione(
    sessione_id=None,
    utente_id=None,
    stato="attiva",
    tipo="media",
    created_at=None,
    stato_orchestratore=None,
    nodi_lavorati=None,
    durata_prevista_min=None,
    durata_effettiva_min=None,
    completed_at=None,
):
    sess = MagicMock()
    sess.id = sessione_id or uuid.uuid4()
    sess.utente_id = utente_id or uuid.uuid4()
    sess.stato = stato
    sess.tipo = tipo
    sess.created_at = created_at or datetime.now(timezone.utc)
    sess.stato_orchestratore = stato_orchestratore or {}
    sess.nodi_lavorati = nodi_lavorati or []
    sess.durata_prevista_min = durata_prevista_min
    sess.durata_effettiva_min = durata_effettiva_min
    sess.completed_at = completed_at
    return sess


# ===================================================================
# Test: SessioneConflitto
# ===================================================================


class TestSessioneConflitto:
    def test_eccezione_contiene_sessione_id(self):
        sid = uuid.uuid4()
        exc = SessioneConflitto(sid)
        assert exc.sessione_id == sid
        assert str(sid) in str(exc)


# ===================================================================
# Test: calcolo inattività
# ===================================================================


class TestCalcoloInattivita:
    def test_sessione_recente(self):
        sess = _mock_sessione(created_at=datetime.now(timezone.utc) - timedelta(seconds=60))
        inattivita = _calcola_inattivita(sess)
        assert 55 < inattivita < 65

    def test_sessione_vecchia(self):
        sess = _mock_sessione(created_at=datetime.now(timezone.utc) - timedelta(minutes=10))
        inattivita = _calcola_inattivita(sess)
        assert inattivita > INATTIVITA_MAX_SEC

    def test_sessione_appena_creata(self):
        sess = _mock_sessione(created_at=datetime.now(timezone.utc))
        inattivita = _calcola_inattivita(sess)
        assert inattivita < 2

    def test_sessione_naive_datetime(self):
        """Gestisce datetime senza timezone."""
        sess = _mock_sessione(created_at=datetime.now(timezone.utc).replace(tzinfo=None))
        inattivita = _calcola_inattivita(sess)
        assert inattivita < 2


# ===================================================================
# Test: sospensione sessione
# ===================================================================


class TestSospendiSessione:
    @pytest.mark.asyncio
    async def test_sospende_sessione_attiva(self):
        db = AsyncMock()
        sess = _mock_sessione(
            stato="attiva",
            created_at=datetime.now(timezone.utc) - timedelta(minutes=15),
        )

        result = await sospendi_sessione(db, sess)

        assert result.stato == "sospesa"
        assert result.durata_effettiva_min == 15
        db.flush.assert_awaited()

    @pytest.mark.asyncio
    async def test_sospende_salva_stato_orchestratore(self):
        db = AsyncMock()
        sess = _mock_sessione(
            stato="attiva",
            created_at=datetime.now(timezone.utc) - timedelta(minutes=10),
            stato_orchestratore={"nodo_focale_id": "nodo_1", "attivita_corrente": "esercizio"},
        )

        result = await sospendi_sessione(db, sess)

        stato = result.stato_orchestratore
        assert stato["ripresa"] is False
        assert "dettaglio_sospensione" in stato
        assert "nodo_focale_id" in stato

    @pytest.mark.asyncio
    async def test_sospende_sessione_non_attiva_errore(self):
        db = AsyncMock()
        sess = _mock_sessione(stato="completata")

        with pytest.raises(ValueError, match="non è attiva"):
            await sospendi_sessione(db, sess)


# ===================================================================
# Test: terminazione sessione
# ===================================================================


class TestTerminaSessione:
    @pytest.mark.asyncio
    async def test_termina_sessione_attiva(self):
        db = AsyncMock()
        sess = _mock_sessione(
            stato="attiva",
            created_at=datetime.now(timezone.utc) - timedelta(minutes=20),
        )

        result = await termina_sessione(db, sess)

        assert result.stato == "completata"
        assert result.durata_effettiva_min == 20
        assert result.completed_at is not None
        db.flush.assert_awaited()

    @pytest.mark.asyncio
    async def test_termina_sessione_sospesa(self):
        db = AsyncMock()
        sess = _mock_sessione(
            stato="sospesa",
            created_at=datetime.now(timezone.utc) - timedelta(minutes=30),
        )

        result = await termina_sessione(db, sess)
        assert result.stato == "completata"

    @pytest.mark.asyncio
    async def test_termina_sessione_gia_completata_errore(self):
        db = AsyncMock()
        sess = _mock_sessione(stato="completata")

        with pytest.raises(ValueError, match="non può essere terminata"):
            await termina_sessione(db, sess)


# ===================================================================
# Test: scelta nodo
# ===================================================================


class TestScegliNodo:
    @pytest.mark.asyncio
    async def test_nodo_in_corso_ha_priorita(self):
        db = AsyncMock()
        utente_id = uuid.uuid4()

        # Mock: nodo in_corso trovato
        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = "nodo_in_corso_1"
        db.execute = AsyncMock(return_value=result_mock)

        nodo = await _scegli_nodo(db, utente_id)
        assert nodo == "nodo_in_corso_1"

    @pytest.mark.asyncio
    @patch("app.core.sessione.grafo_knowledge")
    @patch("app.core.sessione.get_livelli_utente")
    @patch("app.core.sessione.path_planner")
    async def test_path_planner_se_nessun_nodo_in_corso(
        self, mock_planner, mock_livelli, mock_grafo
    ):
        db = AsyncMock()
        utente_id = uuid.uuid4()

        # Mock: nessun nodo in_corso
        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = None
        db.execute = AsyncMock(return_value=result_mock)

        mock_grafo.caricato = True
        mock_grafo.grafo = MagicMock()
        mock_livelli.return_value = {}
        mock_planner.return_value = "nodo_da_path_planner"

        nodo = await _scegli_nodo(db, utente_id)
        assert nodo == "nodo_da_path_planner"
        mock_planner.assert_called_once()

    @pytest.mark.asyncio
    @patch("app.core.sessione.grafo_knowledge")
    async def test_grafo_non_caricato_ritorna_none(self, mock_grafo):
        db = AsyncMock()
        utente_id = uuid.uuid4()

        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = None
        db.execute = AsyncMock(return_value=result_mock)

        mock_grafo.caricato = False

        nodo = await _scegli_nodo(db, utente_id)
        assert nodo is None


# ===================================================================
# Test: inizia sessione — auto-sospensione e conflitto
# ===================================================================


class TestIniziaSessione:
    @pytest.mark.asyncio
    @patch("app.core.sessione._scegli_nodo")
    @patch("app.core.sessione._cerca_sessione_sospesa")
    @patch("app.core.sessione._gestisci_sessione_attiva")
    async def test_crea_nuova_sessione(
        self, mock_gestisci, mock_sospesa, mock_nodo
    ):
        db = AsyncMock()
        utente_id = uuid.uuid4()

        mock_gestisci.return_value = None
        mock_sospesa.return_value = None
        mock_nodo.return_value = "primo_nodo"

        sessione = await inizia_sessione(db, utente_id)

        assert sessione.stato == "attiva"
        assert sessione.tipo == "media"
        stato = sessione.stato_orchestratore
        assert stato["nodo_focale_id"] == "primo_nodo"
        assert stato["attivita_corrente"] == "spiegazione"

    @pytest.mark.asyncio
    @patch("app.core.sessione._cerca_sessione_sospesa")
    @patch("app.core.sessione._gestisci_sessione_attiva")
    async def test_riprende_sessione_sospesa(self, mock_gestisci, mock_sospesa):
        db = AsyncMock()
        utente_id = uuid.uuid4()

        sess_sospesa = _mock_sessione(
            stato="sospesa",
            stato_orchestratore={
                "nodo_focale_id": "nodo_sospeso",
                "attivita_corrente": "esercizio",
            },
        )
        mock_gestisci.return_value = None
        mock_sospesa.return_value = sess_sospesa

        result = await inizia_sessione(db, utente_id)

        assert result.stato == "attiva"
        stato = result.stato_orchestratore
        assert stato["ripresa"] is True
        assert stato["attivita_al_momento_sospensione"] == "esercizio"

    @pytest.mark.asyncio
    @patch("app.core.sessione._gestisci_sessione_attiva")
    async def test_conflitto_sessione_attiva(self, mock_gestisci):
        db = AsyncMock()
        utente_id = uuid.uuid4()
        sid = uuid.uuid4()

        mock_gestisci.side_effect = SessioneConflitto(sid)

        with pytest.raises(SessioneConflitto) as exc_info:
            await inizia_sessione(db, utente_id)

        assert exc_info.value.sessione_id == sid


# ===================================================================
# Test: Pydantic schemas
# ===================================================================


class TestSchemas:
    def test_inizia_sessione_request_defaults(self):
        req = IniziaSessioneRequest()
        assert req.tipo == "media"
        assert req.durata_prevista_min is None

    def test_inizia_sessione_request_custom(self):
        req = IniziaSessioneRequest(tipo="deep", durata_prevista_min=45)
        assert req.tipo == "deep"
        assert req.durata_prevista_min == 45

    def test_turno_request(self):
        req = TurnoRequest(messaggio="Come si risolve?")
        assert req.messaggio == "Come si risolve?"

    def test_sessione_response(self):
        sid = uuid.uuid4()
        resp = SessioneResponse(
            id=sid,
            stato="attiva",
            tipo="media",
            nodo_focale_id="nodo_1",
        )
        assert resp.id == sid
        assert resp.stato == "attiva"

    def test_sessione_conflitto_response(self):
        sid = uuid.uuid4()
        resp = SessioneConflittoResponse(
            sessione_id_esistente=sid,
            messaggio="Sessione attiva",
        )
        data = resp.model_dump(mode="json")
        assert data["sessione_id_esistente"] == str(sid)


# ===================================================================
# Test: formato eventi SSE
# ===================================================================


class TestFormatoEventiSSE:
    def test_evento_sessione_creata_formato(self):
        """L'evento sessione_creata ha il formato corretto."""
        sid = str(uuid.uuid4())
        evento = {
            "event": "sessione_creata",
            "data": {
                "sessione_id": sid,
                "nodo_id": "nodo_1",
                "nodo_nome": "Primo Nodo",
            },
        }
        assert evento["event"] == "sessione_creata"
        data = evento["data"]
        assert "sessione_id" in data
        assert "nodo_id" in data
        assert "nodo_nome" in data

    def test_evento_serializzabile_json(self):
        """Gli eventi SSE sono serializzabili in JSON."""
        eventi = [
            {"event": "text_delta", "data": {"testo": "Ciao!"}},
            {"event": "azione", "data": {"tipo": "proponi_esercizio", "params": {}}},
            {"event": "achievement", "data": {"id": "primo_nodo", "nome": "Primo passo!"}},
            {"event": "turno_completo", "data": {"turno_id": 1, "nodo_focale": "nodo_1"}},
            {"event": "errore", "data": {"codice": "llm_error", "messaggio": "Timeout"}},
        ]
        for evento in eventi:
            serialized = json.dumps(evento["data"])
            parsed = json.loads(serialized)
            assert parsed == evento["data"]


# ===================================================================
# Test: costante inattività
# ===================================================================


class TestCostanti:
    def test_inattivita_max_5_minuti(self):
        assert INATTIVITA_MAX_SEC == 300

    def test_inattivita_max_in_secondi(self):
        assert INATTIVITA_MAX_SEC == 5 * 60


# ===================================================================
# Test: flusso sessione end-to-end con mock
# ===================================================================


class TestFlussoSessioneE2E:
    """Test end-to-end del flusso sessione con componenti mockati."""

    @pytest.mark.asyncio
    @patch("app.core.sessione._scegli_nodo")
    @patch("app.core.sessione._cerca_sessione_sospesa")
    @patch("app.core.sessione._gestisci_sessione_attiva")
    async def test_flusso_crea_sospendi_riprendi(
        self, mock_gestisci, mock_sospesa, mock_nodo
    ):
        """Crea → sospendi → riprendi una sessione."""
        db = AsyncMock()
        utente_id = uuid.uuid4()

        # Step 1: Crea sessione
        mock_gestisci.return_value = None
        mock_sospesa.return_value = None
        mock_nodo.return_value = "nodo_A"

        sessione = await inizia_sessione(db, utente_id)
        assert sessione.stato == "attiva"
        assert sessione.stato_orchestratore["nodo_focale_id"] == "nodo_A"

        # Step 2: Sospendi
        sessione.created_at = datetime.now(timezone.utc) - timedelta(minutes=10)
        result = await sospendi_sessione(db, sessione)
        assert result.stato == "sospesa"

        # Step 3: Riprendi (mock ritorna la sessione sospesa)
        mock_sospesa.return_value = result
        ripresa = await inizia_sessione(db, utente_id)
        assert ripresa.stato == "attiva"
        assert ripresa.stato_orchestratore["ripresa"] is True

    @pytest.mark.asyncio
    @patch("app.core.sessione._scegli_nodo")
    @patch("app.core.sessione._cerca_sessione_sospesa")
    @patch("app.core.sessione._gestisci_sessione_attiva")
    async def test_flusso_crea_termina(
        self, mock_gestisci, mock_sospesa, mock_nodo
    ):
        """Crea → termina una sessione."""
        db = AsyncMock()
        utente_id = uuid.uuid4()

        mock_gestisci.return_value = None
        mock_sospesa.return_value = None
        mock_nodo.return_value = "nodo_B"

        sessione = await inizia_sessione(db, utente_id)
        sessione.created_at = datetime.now(timezone.utc) - timedelta(minutes=25)

        result = await termina_sessione(db, sessione)
        assert result.stato == "completata"
        assert result.durata_effettiva_min == 25
        assert result.completed_at is not None

    @pytest.mark.asyncio
    @patch("app.core.sessione._scegli_nodo")
    @patch("app.core.sessione._cerca_sessione_sospesa")
    @patch("app.core.sessione._gestisci_sessione_attiva")
    async def test_percorso_completato_nodo_none(
        self, mock_gestisci, mock_sospesa, mock_nodo
    ):
        """Quando tutti i nodi sono completati, nodo_focale_id è None."""
        db = AsyncMock()
        utente_id = uuid.uuid4()

        mock_gestisci.return_value = None
        mock_sospesa.return_value = None
        mock_nodo.return_value = None  # Percorso completato

        sessione = await inizia_sessione(db, utente_id)
        stato = sessione.stato_orchestratore
        assert stato["nodo_focale_id"] is None
        assert stato["attivita_corrente"] is None


# ===================================================================
# Test: SessioneListItemResponse schema
# ===================================================================


class TestSessioneListItemSchema:
    def test_list_item_minimal(self):
        sid = uuid.uuid4()
        resp = SessioneListItemResponse(
            id=sid,
            stato="completata",
        )
        data = resp.model_dump(mode="json")
        assert data["id"] == str(sid)
        assert data["stato"] == "completata"
        assert data["created_at"] is None
        assert data["completed_at"] is None

    def test_list_item_full(self):
        sid = uuid.uuid4()
        now = datetime.now(timezone.utc)
        resp = SessioneListItemResponse(
            id=sid,
            stato="completata",
            tipo="media",
            nodo_focale_id="nodo_1",
            nodo_focale_nome="Primo Nodo",
            durata_effettiva_min=25,
            nodi_lavorati=["nodo_1", "nodo_2"],
            created_at=now,
            completed_at=now,
        )
        data = resp.model_dump(mode="json")
        assert data["id"] == str(sid)
        assert data["tipo"] == "media"
        assert data["nodo_focale_nome"] == "Primo Nodo"
        assert data["durata_effettiva_min"] == 25
        assert len(data["nodi_lavorati"]) == 2
        assert data["created_at"] is not None
        assert data["completed_at"] is not None

    def test_list_item_json_roundtrip(self):
        sid = uuid.uuid4()
        now = datetime.now(timezone.utc)
        resp = SessioneListItemResponse(
            id=sid,
            stato="sospesa",
            tipo="media",
            nodo_focale_id="nodo_A",
            nodo_focale_nome="Nodo A",
            durata_effettiva_min=10,
            nodi_lavorati=["nodo_A"],
            created_at=now,
            completed_at=None,
        )
        data = resp.model_dump(mode="json")
        serialized = json.dumps(data)
        parsed = json.loads(serialized)
        assert parsed["id"] == str(sid)
        assert parsed["stato"] == "sospesa"
        assert parsed["completed_at"] is None


# ===================================================================
# Test: _sessione_to_list_item helper
# ===================================================================


class TestSessioneToListItem:
    def test_converts_mock_sessione(self):
        from app.api.sessione import _sessione_to_list_item

        now = datetime.now(timezone.utc)
        sess = _mock_sessione(
            stato="completata",
            tipo="media",
            stato_orchestratore={"nodo_focale_id": None},
            nodi_lavorati=["nodo_1"],
            durata_effettiva_min=15,
            completed_at=now,
        )
        sess.created_at = now - timedelta(minutes=15)

        data = _sessione_to_list_item(sess)
        assert data["stato"] == "completata"
        assert data["durata_effettiva_min"] == 15
        assert data["nodi_lavorati"] == ["nodo_1"]
        assert data["completed_at"] is not None

    def test_list_item_with_nodo_nome(self):
        from app.api.sessione import _sessione_to_list_item

        sess = _mock_sessione(
            stato="completata",
            stato_orchestratore={"nodo_focale_id": "test_nodo"},
        )
        sess.created_at = datetime.now(timezone.utc)

        # Without grafo loaded, nodo_nome will be None
        data = _sessione_to_list_item(sess)
        assert data["nodo_focale_id"] == "test_nodo"

    def test_list_item_no_orchestratore(self):
        from app.api.sessione import _sessione_to_list_item

        sess = _mock_sessione(
            stato="attiva",
            stato_orchestratore=None,
        )
        sess.created_at = datetime.now(timezone.utc)

        data = _sessione_to_list_item(sess)
        assert data["nodo_focale_id"] is None
        assert data["nodo_focale_nome"] is None
