"""Test B39.9.3 — Endpoint GET /onboarding/riprendi.

Verifica il recupero di una sessione onboarding attiva per ripresa
dopo skip o interruzione dell'utente.
"""

from __future__ import annotations

import uuid
from unittest.mock import AsyncMock, MagicMock

import pytest
from fastapi import HTTPException

from app.api.onboarding import api_riprendi_onboarding


# ===================================================================
# Helper: mock turno conversazione
# ===================================================================


def _mock_turno(ruolo: str, contenuto: str | None, ordine: int):
    turno = MagicMock()
    turno.ruolo = ruolo
    turno.contenuto = contenuto
    turno.ordine = ordine
    return turno


def _mock_sessione(
    sessione_id=None,
    utente_id=None,
    stato_orchestratore=None,
):
    sess = MagicMock()
    sess.id = sessione_id or uuid.uuid4()
    sess.utente_id = utente_id or uuid.uuid4()
    sess.tipo = "onboarding"
    sess.stato = "attiva"
    sess.stato_orchestratore = stato_orchestratore or {
        "fase_onboarding": "accoglienza",
        "turni_conoscenza": 0,
    }
    return sess


# ===================================================================
# Test: sessione attiva con conversazione
# ===================================================================


class TestRiprendiOnboarding:
    """Test per GET /onboarding/riprendi."""

    @pytest.mark.asyncio
    async def test_sessione_attiva_con_turni(self):
        """Sessione attiva con turni → restituisce conversazione completa."""
        utente_id = uuid.uuid4()
        sessione_id = uuid.uuid4()

        sessione = _mock_sessione(
            sessione_id=sessione_id,
            utente_id=utente_id,
            stato_orchestratore={
                "fase_onboarding": "conoscenza",
                "turni_conoscenza": 2,
                "profilo_estratto": {
                    "chi_e": {"valore": "studente 17 anni", "confidenza": "alta"},
                    "motivo": {"valore": "esame maturità", "confidenza": "media"},
                    "stile_cognitivo": {"valore": None, "confidenza": "bassa"},
                    "tempo_disponibile": {"valore": None, "confidenza": "bassa"},
                    "vissuto_scolastico": {"valore": None, "confidenza": "bassa"},
                },
            },
        )

        turni = [
            _mock_turno("assistant", "Ciao! Benvenuto su Dydat.", 1),
            _mock_turno("user", "Ciao, ho 17 anni", 2),
            _mock_turno("assistant", "Perfetto! Cosa ti porta qui?", 3),
            _mock_turno("user", "Devo preparare la maturità", 4),
        ]

        # Mock DB: prima query = sessione, seconda = turni
        db = AsyncMock()
        sessione_result = MagicMock()
        sessione_result.scalar_one_or_none.return_value = sessione

        turni_result = MagicMock()
        scalars_mock = MagicMock()
        scalars_mock.all.return_value = turni
        turni_result.scalars.return_value = scalars_mock

        db.execute = AsyncMock(side_effect=[sessione_result, turni_result])

        result = await api_riprendi_onboarding(
            utente_id=utente_id,
            db=db,
        )

        assert str(result.sessione_id) == str(sessione_id)
        assert result.fase_corrente == "conoscenza"
        assert result.campi_completi == 2  # chi_e alta + motivo media
        assert len(result.turni) == 4
        assert result.turni[0].ruolo == "assistant"
        assert result.turni[0].contenuto == "Ciao! Benvenuto su Dydat."
        assert result.turni[3].ruolo == "user"

    @pytest.mark.asyncio
    async def test_nessuna_sessione_attiva_404(self):
        """Nessuna sessione attiva per questo utente → 404."""
        db = AsyncMock()
        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = None
        db.execute = AsyncMock(return_value=result_mock)

        with pytest.raises(HTTPException) as exc_info:
            await api_riprendi_onboarding(
                utente_id=uuid.uuid4(),
                db=db,
            )
        assert exc_info.value.status_code == 404

    @pytest.mark.asyncio
    async def test_turni_senza_contenuto_esclusi(self):
        """Turni con contenuto None (tool-use only) vengono esclusi."""
        sessione = _mock_sessione()
        turni = [
            _mock_turno("assistant", "Ciao!", 1),
            _mock_turno("assistant", None, 2),  # tool-use only
            _mock_turno("user", "Ciao", 3),
        ]

        db = AsyncMock()
        sess_result = MagicMock()
        sess_result.scalar_one_or_none.return_value = sessione

        turni_result = MagicMock()
        scalars_mock = MagicMock()
        scalars_mock.all.return_value = turni
        turni_result.scalars.return_value = scalars_mock

        db.execute = AsyncMock(side_effect=[sess_result, turni_result])

        result = await api_riprendi_onboarding(
            utente_id=sessione.utente_id,
            db=db,
        )

        # Solo 2 turni (il turno tool-use senza contenuto è escluso)
        assert len(result.turni) == 2
        assert result.turni[0].contenuto == "Ciao!"
        assert result.turni[1].contenuto == "Ciao"

    @pytest.mark.asyncio
    async def test_sessione_vuota_zero_turni(self):
        """Sessione appena creata senza turni → lista vuota."""
        sessione = _mock_sessione()

        db = AsyncMock()
        sess_result = MagicMock()
        sess_result.scalar_one_or_none.return_value = sessione

        turni_result = MagicMock()
        scalars_mock = MagicMock()
        scalars_mock.all.return_value = []
        turni_result.scalars.return_value = scalars_mock

        db.execute = AsyncMock(side_effect=[sess_result, turni_result])

        result = await api_riprendi_onboarding(
            utente_id=sessione.utente_id,
            db=db,
        )

        assert len(result.turni) == 0
        assert result.fase_corrente == "accoglienza"
        assert result.campi_completi == 0

    @pytest.mark.asyncio
    async def test_stato_orchestratore_nullo(self):
        """Sessione con stato_orchestratore None → defaults sicuri."""
        sessione = _mock_sessione(stato_orchestratore=None)
        # Forza None
        sessione.stato_orchestratore = None

        db = AsyncMock()
        sess_result = MagicMock()
        sess_result.scalar_one_or_none.return_value = sessione

        turni_result = MagicMock()
        scalars_mock = MagicMock()
        scalars_mock.all.return_value = []
        turni_result.scalars.return_value = scalars_mock

        db.execute = AsyncMock(side_effect=[sess_result, turni_result])

        result = await api_riprendi_onboarding(
            utente_id=sessione.utente_id,
            db=db,
        )

        assert result.fase_corrente == "accoglienza"
        assert result.campi_completi == 0

    @pytest.mark.asyncio
    async def test_profilo_completo_5_campi(self):
        """Profilo con tutti e 5 i campi alta/media → campi_completi=5."""
        sessione = _mock_sessione(
            stato_orchestratore={
                "fase_onboarding": "conclusione",
                "profilo_estratto": {
                    "chi_e": {"valore": "studente", "confidenza": "alta"},
                    "motivo": {"valore": "esame", "confidenza": "alta"},
                    "stile_cognitivo": {"valore": "visivo", "confidenza": "media"},
                    "tempo_disponibile": {"valore": "30 min", "confidenza": "alta"},
                    "vissuto_scolastico": {"valore": "buono", "confidenza": "media"},
                },
            },
        )

        db = AsyncMock()
        sess_result = MagicMock()
        sess_result.scalar_one_or_none.return_value = sessione

        turni_result = MagicMock()
        scalars_mock = MagicMock()
        scalars_mock.all.return_value = []
        turni_result.scalars.return_value = scalars_mock

        db.execute = AsyncMock(side_effect=[sess_result, turni_result])

        result = await api_riprendi_onboarding(
            utente_id=sessione.utente_id,
            db=db,
        )

        assert result.campi_completi == 5
        assert result.fase_corrente == "conclusione"


# ===================================================================
# Test: schema Pydantic
# ===================================================================


class TestSchemaRipresa:
    """Test schema Pydantic per ripresa onboarding."""

    def test_turno_ripresa_serializzazione(self):
        from app.schemas.onboarding import TurnoRipresa

        turno = TurnoRipresa(ruolo="assistant", contenuto="Ciao!")
        d = turno.model_dump()
        assert d["ruolo"] == "assistant"
        assert d["contenuto"] == "Ciao!"

    def test_turno_ripresa_contenuto_nullo(self):
        from app.schemas.onboarding import TurnoRipresa

        turno = TurnoRipresa(ruolo="assistant", contenuto=None)
        assert turno.contenuto is None

    def test_ripresa_response_serializzazione(self):
        from app.schemas.onboarding import OnboardingRipresaResponse, TurnoRipresa

        resp = OnboardingRipresaResponse(
            sessione_id=uuid.uuid4(),
            fase_corrente="conoscenza",
            campi_completi=3,
            turni=[
                TurnoRipresa(ruolo="assistant", contenuto="Ciao"),
                TurnoRipresa(ruolo="user", contenuto="Ciao"),
            ],
        )
        d = resp.model_dump(mode="json")
        assert d["fase_corrente"] == "conoscenza"
        assert d["campi_completi"] == 3
        assert len(d["turni"]) == 2
        assert "sessione_id" in d

    def test_ripresa_response_turni_vuoti(self):
        from app.schemas.onboarding import OnboardingRipresaResponse

        resp = OnboardingRipresaResponse(
            sessione_id=uuid.uuid4(),
            fase_corrente="accoglienza",
            campi_completi=0,
            turni=[],
        )
        assert len(resp.turni) == 0
