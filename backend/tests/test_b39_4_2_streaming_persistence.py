"""Test B39.4.2 — Persistenza contenuto streaming turni con tool use (ONB-02).

Verifica che il contenuto testuale del tutor venga sempre persistito
correttamente nel DB, anche in presenza di tool use nel turno.

Scenari:
- Testo + tool use → contenuto salvato (non None)
- Solo tool use senza testo → contenuto None (corretto)
- Fallback: risultato_llm.testo_completo vuoto ma text_delta ricevuti
- Stream con tool use multipli + testo
- Turno onboarding con tool use (scenario reale ONB-02)
"""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

# ===================================================================
# Fixture condivise
# ===================================================================


@dataclass
class FakeRisultato:
    testo_completo: str = ""
    azioni: list = None
    segnali: list = None
    token_input: int = 100
    token_output: int = 50
    costo_stimato: float = 0.001
    modello: str = "test-model"
    stop_reason: str = "end_turn"

    def __post_init__(self):
        self.azioni = self.azioni or []
        self.segnali = self.segnali or []


@dataclass
class FakeContextPackage:
    system: str = "test system"
    messages: list = None
    modello: str = "test-model"
    tipo_sessione: str = "onboarding"

    def __post_init__(self):
        self.messages = self.messages or []


@dataclass
class FakeTurno:
    id: int = 1


@dataclass
class FakeSessione:
    stato_orchestratore: dict = None
    id: str = "sess-1"

    def __post_init__(self):
        self.stato_orchestratore = self.stato_orchestratore or {
            "nodo_focale_id": "nodo_test",
            "fase_onboarding": "conoscenza",
        }


def _make_db_mock():
    db = AsyncMock()
    db.commit = AsyncMock()
    db.refresh = AsyncMock()
    sess_result = MagicMock()
    sess_result.scalar_one_or_none.return_value = FakeSessione()
    db.execute = AsyncMock(return_value=sess_result)
    return db


# ===================================================================
# Test: persistenza contenuto con tool use
# ===================================================================


class TestStreamingPersistenceToolUse:
    """Verifica che il contenuto venga persistito anche con tool use."""

    @pytest.mark.asyncio
    async def test_testo_con_tool_use_viene_salvato(self):
        """Quando il LLM genera testo + tool use, il contenuto NON è None."""
        from app.core.turno import esegui_turno

        risultato = FakeRisultato(
            testo_completo="Ciao, raccontami di te!",
            stop_reason="tool_use",
        )

        async def fake_chiama_tutor(**kwargs):
            yield {"tipo": "text_delta", "testo": "Ciao, "}
            yield {"tipo": "text_delta", "testo": "raccontami di te!"}
            yield {
                "tipo": "tool_use",
                "name": "concetto_spiegato",
                "input": {"nodo_id": "n1", "punti_coperti": ["intro"]},
                "categoria": "segnale",
            }
            yield {"tipo": "stop", "risultato": risultato}

        db = _make_db_mock()
        mock_salva_turno = AsyncMock(return_value=FakeTurno())

        with (
            patch("app.core.turno.assembla_context_package",
                  return_value=FakeContextPackage()),
            patch("app.core.turno.chiama_tutor",
                  side_effect=fake_chiama_tutor),
            patch("app.core.turno.salva_turno",
                  mock_salva_turno),
            patch("app.core.turno.processa_segnali",
                  return_value=([], [])),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="ciao",
            ):
                eventi.append(ev)

        # Verifica che salva_turno sia stato chiamato per il turno assistente
        # con contenuto non-None
        chiamate_assistente = [
            c for c in mock_salva_turno.call_args_list
            if c.kwargs.get("ruolo") == "assistente"
        ]
        assert len(chiamate_assistente) == 1
        contenuto = chiamate_assistente[0].kwargs["contenuto"]
        assert contenuto is not None
        assert contenuto == "Ciao, raccontami di te!"

    @pytest.mark.asyncio
    async def test_solo_tool_use_senza_testo_contenuto_none(self):
        """Quando il LLM genera solo tool use senza testo, contenuto è None."""
        from app.core.turno import esegui_turno

        risultato = FakeRisultato(
            testo_completo="",
            stop_reason="tool_use",
        )

        async def fake_chiama_tutor(**kwargs):
            yield {
                "tipo": "tool_use",
                "name": "concetto_spiegato",
                "input": {"nodo_id": "n1", "punti_coperti": ["def"]},
                "categoria": "segnale",
            }
            yield {"tipo": "stop", "risultato": risultato}

        db = _make_db_mock()
        mock_salva_turno = AsyncMock(return_value=FakeTurno())

        with (
            patch("app.core.turno.assembla_context_package",
                  return_value=FakeContextPackage()),
            patch("app.core.turno.chiama_tutor",
                  side_effect=fake_chiama_tutor),
            patch("app.core.turno.salva_turno",
                  mock_salva_turno),
            patch("app.core.turno.processa_segnali",
                  return_value=([], [])),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="ok",
            ):
                eventi.append(ev)

        chiamate_assistente = [
            c for c in mock_salva_turno.call_args_list
            if c.kwargs.get("ruolo") == "assistente"
        ]
        assert len(chiamate_assistente) == 1
        contenuto = chiamate_assistente[0].kwargs["contenuto"]
        # Nessun testo generato → None è corretto
        assert contenuto is None

    @pytest.mark.asyncio
    async def test_fallback_testo_locale_quando_risultato_vuoto(self):
        """Se risultato_llm.testo_completo è vuoto ma text_delta ricevuti,
        usa il testo accumulato localmente (fix ONB-02)."""
        from app.core.turno import esegui_turno

        # Simula un bug: il risultato ha testo_completo vuoto
        # nonostante text_delta siano stati emessi
        risultato = FakeRisultato(
            testo_completo="",  # Bug: vuoto nonostante i delta
            stop_reason="tool_use",
        )

        async def fake_chiama_tutor(**kwargs):
            yield {"tipo": "text_delta", "testo": "Perfetto, "}
            yield {"tipo": "text_delta", "testo": "matematica!"}
            yield {
                "tipo": "tool_use",
                "name": "concetto_spiegato",
                "input": {"nodo_id": "n1", "punti_coperti": ["intro"]},
                "categoria": "segnale",
            }
            yield {"tipo": "stop", "risultato": risultato}

        db = _make_db_mock()
        mock_salva_turno = AsyncMock(return_value=FakeTurno())

        with (
            patch("app.core.turno.assembla_context_package",
                  return_value=FakeContextPackage()),
            patch("app.core.turno.chiama_tutor",
                  side_effect=fake_chiama_tutor),
            patch("app.core.turno.salva_turno",
                  mock_salva_turno),
            patch("app.core.turno.processa_segnali",
                  return_value=([], [])),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="matematica",
            ):
                eventi.append(ev)

        chiamate_assistente = [
            c for c in mock_salva_turno.call_args_list
            if c.kwargs.get("ruolo") == "assistente"
        ]
        assert len(chiamate_assistente) == 1
        contenuto = chiamate_assistente[0].kwargs["contenuto"]
        # Il fallback locale deve recuperare il testo
        assert contenuto is not None
        assert contenuto == "Perfetto, matematica!"

    @pytest.mark.asyncio
    async def test_tool_use_multipli_con_testo_intercalato(self):
        """Testo + tool use multipli: tutto il testo viene salvato."""
        from app.core.turno import esegui_turno

        testo_atteso = "Vediamo un esercizio.Ecco la formula."
        risultato = FakeRisultato(
            testo_completo=testo_atteso,
            stop_reason="tool_use",
        )

        async def fake_chiama_tutor(**kwargs):
            yield {"tipo": "text_delta", "testo": "Vediamo un esercizio."}
            yield {
                "tipo": "tool_use",
                "name": "proponi_esercizio",
                "input": {"nodo_id": "n1", "difficolta": "base"},
                "categoria": "azione",
            }
            yield {"tipo": "text_delta", "testo": "Ecco la formula."}
            yield {
                "tipo": "tool_use",
                "name": "concetto_spiegato",
                "input": {"nodo_id": "n1", "punti_coperti": ["formula"]},
                "categoria": "segnale",
            }
            yield {"tipo": "stop", "risultato": risultato}

        db = _make_db_mock()
        mock_salva_turno = AsyncMock(return_value=FakeTurno())

        azione_result = {
            "tipo": "proponi_esercizio",
            "params": {"esercizio_id": "ex_1", "testo": "...", "difficolta": 1, "nodo_id": "n1"},
        }

        with (
            patch("app.core.turno.assembla_context_package",
                  return_value=FakeContextPackage()),
            patch("app.core.turno.chiama_tutor",
                  side_effect=fake_chiama_tutor),
            patch("app.core.turno.salva_turno",
                  mock_salva_turno),
            patch("app.core.turno.esegui_azione",
                  return_value=azione_result),
            patch("app.core.turno.processa_segnali",
                  return_value=([], [])),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="avanti",
            ):
                eventi.append(ev)

        chiamate_assistente = [
            c for c in mock_salva_turno.call_args_list
            if c.kwargs.get("ruolo") == "assistente"
        ]
        assert len(chiamate_assistente) == 1
        contenuto = chiamate_assistente[0].kwargs["contenuto"]
        assert contenuto == testo_atteso

    @pytest.mark.asyncio
    async def test_text_delta_streamati_al_client(self):
        """I text_delta vengono comunque streamati al client via SSE."""
        from app.core.turno import esegui_turno

        risultato = FakeRisultato(
            testo_completo="Ciao mondo",
            stop_reason="tool_use",
        )

        async def fake_chiama_tutor(**kwargs):
            yield {"tipo": "text_delta", "testo": "Ciao "}
            yield {"tipo": "text_delta", "testo": "mondo"}
            yield {
                "tipo": "tool_use",
                "name": "concetto_spiegato",
                "input": {"nodo_id": "n1", "punti_coperti": ["x"]},
                "categoria": "segnale",
            }
            yield {"tipo": "stop", "risultato": risultato}

        db = _make_db_mock()

        with (
            patch("app.core.turno.assembla_context_package",
                  return_value=FakeContextPackage()),
            patch("app.core.turno.chiama_tutor",
                  side_effect=fake_chiama_tutor),
            patch("app.core.turno.salva_turno",
                  return_value=FakeTurno()),
            patch("app.core.turno.processa_segnali",
                  return_value=([], [])),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="ciao",
            ):
                eventi.append(ev)

        text_deltas = [e for e in eventi if e.get("event") == "text_delta"]
        assert len(text_deltas) == 2
        assert text_deltas[0]["data"]["testo"] == "Ciao "
        assert text_deltas[1]["data"]["testo"] == "mondo"

    @pytest.mark.asyncio
    async def test_onboarding_turno_con_azione_e_testo(self):
        """Scenario reale ONB-02: turno onboarding con onboarding_domanda + testo."""
        from app.core.turno import esegui_turno

        risultato = FakeRisultato(
            testo_completo="Che bello! Cosa studi?",
            stop_reason="tool_use",
        )

        async def fake_chiama_tutor(**kwargs):
            yield {"tipo": "text_delta", "testo": "Che bello! "}
            yield {"tipo": "text_delta", "testo": "Cosa studi?"}
            yield {
                "tipo": "tool_use",
                "name": "onboarding_domanda",
                "input": {"testo": "Cosa studi?", "campo_target": "motivo"},
                "categoria": "azione",
            }
            yield {"tipo": "stop", "risultato": risultato}

        db = _make_db_mock()
        mock_salva_turno = AsyncMock(return_value=FakeTurno())

        azione_result = {
            "tipo": "onboarding_domanda",
            "params": {"testo": "Cosa studi?", "campo_target": "motivo"},
        }

        with (
            patch("app.core.turno.assembla_context_package",
                  return_value=FakeContextPackage(tipo_sessione="onboarding")),
            patch("app.core.turno.chiama_tutor",
                  side_effect=fake_chiama_tutor),
            patch("app.core.turno.salva_turno",
                  mock_salva_turno),
            patch("app.core.turno.esegui_azione",
                  return_value=azione_result),
            patch("app.core.turno.processa_segnali",
                  return_value=([], [])),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="Mi piace la matematica",
            ):
                eventi.append(ev)

        chiamate_assistente = [
            c for c in mock_salva_turno.call_args_list
            if c.kwargs.get("ruolo") == "assistente"
        ]
        assert len(chiamate_assistente) == 1
        contenuto = chiamate_assistente[0].kwargs["contenuto"]
        assert contenuto is not None
        assert contenuto == "Che bello! Cosa studi?"

    @pytest.mark.asyncio
    async def test_fallback_con_azione_onboarding(self):
        """Fallback locale funziona anche con azione onboarding (ONB-02 specifico)."""
        from app.core.turno import esegui_turno

        # Bug simulato: risultato vuoto nonostante text_delta + azione
        risultato = FakeRisultato(
            testo_completo="",
            stop_reason="tool_use",
        )

        async def fake_chiama_tutor(**kwargs):
            yield {"tipo": "text_delta", "testo": "Raccontami "}
            yield {"tipo": "text_delta", "testo": "qualcosa di te."}
            yield {
                "tipo": "tool_use",
                "name": "onboarding_domanda",
                "input": {"testo": "...", "campo_target": "chi_e"},
                "categoria": "azione",
            }
            yield {"tipo": "stop", "risultato": risultato}

        db = _make_db_mock()
        mock_salva_turno = AsyncMock(return_value=FakeTurno())

        with (
            patch("app.core.turno.assembla_context_package",
                  return_value=FakeContextPackage(tipo_sessione="onboarding")),
            patch("app.core.turno.chiama_tutor",
                  side_effect=fake_chiama_tutor),
            patch("app.core.turno.salva_turno",
                  mock_salva_turno),
            patch("app.core.turno.esegui_azione",
                  return_value={"tipo": "onboarding_domanda", "params": {}}),
            patch("app.core.turno.processa_segnali",
                  return_value=([], [])),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="sono uno studente",
            ):
                eventi.append(ev)

        chiamate_assistente = [
            c for c in mock_salva_turno.call_args_list
            if c.kwargs.get("ruolo") == "assistente"
        ]
        assert len(chiamate_assistente) == 1
        contenuto = chiamate_assistente[0].kwargs["contenuto"]
        # Il fallback deve recuperare il testo
        assert contenuto == "Raccontami qualcosa di te."

    @pytest.mark.asyncio
    async def test_testo_senza_tool_use_non_tocca_fallback(self):
        """Turno solo testo: il percorso normale funziona, nessun fallback."""
        from app.core.turno import esegui_turno

        risultato = FakeRisultato(
            testo_completo="Benvenuto!",
            stop_reason="end_turn",
        )

        async def fake_chiama_tutor(**kwargs):
            yield {"tipo": "text_delta", "testo": "Benvenuto!"}
            yield {"tipo": "stop", "risultato": risultato}

        db = _make_db_mock()
        mock_salva_turno = AsyncMock(return_value=FakeTurno())

        with (
            patch("app.core.turno.assembla_context_package",
                  return_value=FakeContextPackage()),
            patch("app.core.turno.chiama_tutor",
                  side_effect=fake_chiama_tutor),
            patch("app.core.turno.salva_turno",
                  mock_salva_turno),
            patch("app.core.turno.processa_segnali",
                  return_value=([], [])),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="ciao",
            ):
                eventi.append(ev)

        chiamate_assistente = [
            c for c in mock_salva_turno.call_args_list
            if c.kwargs.get("ruolo") == "assistente"
        ]
        assert len(chiamate_assistente) == 1
        contenuto = chiamate_assistente[0].kwargs["contenuto"]
        assert contenuto == "Benvenuto!"

    @pytest.mark.asyncio
    async def test_logging_fallback_emette_warning(self):
        """Quando il fallback interviene, un warning viene loggato."""
        from app.core.turno import esegui_turno

        risultato = FakeRisultato(testo_completo="", stop_reason="tool_use")

        async def fake_chiama_tutor(**kwargs):
            yield {"tipo": "text_delta", "testo": "Testo perso"}
            yield {
                "tipo": "tool_use",
                "name": "concetto_spiegato",
                "input": {"nodo_id": "n1", "punti_coperti": []},
                "categoria": "segnale",
            }
            yield {"tipo": "stop", "risultato": risultato}

        db = _make_db_mock()

        with (
            patch("app.core.turno.assembla_context_package",
                  return_value=FakeContextPackage()),
            patch("app.core.turno.chiama_tutor",
                  side_effect=fake_chiama_tutor),
            patch("app.core.turno.salva_turno",
                  return_value=FakeTurno()),
            patch("app.core.turno.processa_segnali",
                  return_value=([], [])),
            patch("app.core.turno.logger") as mock_logger,
        ):
            async for _ in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="test",
            ):
                pass

        # Verifica che il warning di fallback sia stato emesso
        warning_calls = [
            c for c in mock_logger.warning.call_args_list
            if "fallback" in str(c).lower()
        ]
        assert len(warning_calls) >= 1

    @pytest.mark.asyncio
    async def test_logging_turno_solo_tool_use_info(self):
        """Turno solo tool use (nessun testo) emette log info diagnostico."""
        from app.core.turno import esegui_turno

        risultato = FakeRisultato(testo_completo="", stop_reason="tool_use")

        async def fake_chiama_tutor(**kwargs):
            yield {
                "tipo": "tool_use",
                "name": "concetto_spiegato",
                "input": {"nodo_id": "n1", "punti_coperti": []},
                "categoria": "segnale",
            }
            yield {"tipo": "stop", "risultato": risultato}

        db = _make_db_mock()

        with (
            patch("app.core.turno.assembla_context_package",
                  return_value=FakeContextPackage()),
            patch("app.core.turno.chiama_tutor",
                  side_effect=fake_chiama_tutor),
            patch("app.core.turno.salva_turno",
                  return_value=FakeTurno()),
            patch("app.core.turno.processa_segnali",
                  return_value=([], [])),
            patch("app.core.turno.logger") as mock_logger,
        ):
            async for _ in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="test",
            ):
                pass

        # Verifica log info per turno solo tool-use
        info_calls = [
            c for c in mock_logger.info.call_args_list
            if "solo tool-use" in str(c).lower()
        ]
        assert len(info_calls) >= 1
