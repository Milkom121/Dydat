"""Test Blocco 5 — LLM client, tool schemas, streaming mock."""

from __future__ import annotations

from dataclasses import dataclass
from unittest.mock import MagicMock, patch

import pytest

from app.llm.tools import (
    NOMI_AZIONI,
    NOMI_SEGNALI,
    get_tool_schemas,
    is_azione,
    is_segnale,
)

# ===================================================================
# Test: tool schemas
# ===================================================================


class TestToolSchemas:
    def test_get_tool_schemas_returns_list(self):
        schemas = get_tool_schemas()
        assert isinstance(schemas, list)
        assert len(schemas) > 0

    def test_all_schemas_have_required_fields(self):
        for tool in get_tool_schemas():
            assert "name" in tool, f"Tool manca 'name': {tool}"
            assert "description" in tool, f"Tool {tool['name']} manca 'description'"
            assert "input_schema" in tool, f"Tool {tool['name']} manca 'input_schema'"
            schema = tool["input_schema"]
            assert schema["type"] == "object"
            assert "properties" in schema

    def test_azioni_loop1_presenti(self):
        nomi = {t["name"] for t in get_tool_schemas()}
        azioni_attese = {
            "proponi_esercizio", "mostra_formula",
            "suggerisci_backtrack", "chiudi_sessione",
        }
        assert azioni_attese.issubset(nomi)

    def test_segnali_loop1_presenti(self):
        nomi = {t["name"] for t in get_tool_schemas()}
        segnali_attesi = {
            "concetto_spiegato",
            "risposta_esercizio",
            "confusione_rilevata",
            "energia_utente",
            "prossimo_passo_raccomandato",
            "punto_partenza_suggerito",
        }
        assert segnali_attesi.issubset(nomi)

    def test_azioni_loop23_presenti(self):
        nomi = {t["name"] for t in get_tool_schemas()}
        stub_attesi = {
            "mostra_visualizzazione",
            "avvia_feynman",
            "mostra_connessione",
            "mostra_percorso",
        }
        assert stub_attesi.issubset(nomi)

    def test_segnali_loop3_presenti(self):
        nomi = {t["name"] for t in get_tool_schemas()}
        assert "valutazione_feynman" in nomi
        assert "connessione_seminata" in nomi

    def test_nessun_duplicato(self):
        nomi = [t["name"] for t in get_tool_schemas()]
        duplicati = [n for n in nomi if nomi.count(n) > 1]
        assert len(nomi) == len(set(nomi)), f"Nomi duplicati: {duplicati}"

    def test_azioni_e_segnali_non_si_sovrappongono(self):
        overlap = NOMI_AZIONI & NOMI_SEGNALI
        assert len(overlap) == 0, f"Overlap azioni/segnali: {overlap}"

    def test_is_azione(self):
        assert is_azione("proponi_esercizio")
        assert is_azione("mostra_formula")
        assert is_azione("suggerisci_backtrack")
        assert is_azione("chiudi_sessione")
        assert not is_azione("concetto_spiegato")
        assert not is_azione("tool_inesistente")

    def test_is_segnale(self):
        assert is_segnale("concetto_spiegato")
        assert is_segnale("risposta_esercizio")
        assert is_segnale("punto_partenza_suggerito")
        assert not is_segnale("proponi_esercizio")
        assert not is_segnale("tool_inesistente")

    def test_proponi_esercizio_required_fields(self):
        tool = next(t for t in get_tool_schemas() if t["name"] == "proponi_esercizio")
        assert "nodo_id" in tool["input_schema"]["required"]

    def test_risposta_esercizio_required_fields(self):
        tool = next(t for t in get_tool_schemas() if t["name"] == "risposta_esercizio")
        required = tool["input_schema"]["required"]
        assert "esercizio_id" in required
        assert "nodo_focale" in required
        assert "esito" in required

    def test_risposta_esercizio_esito_enum(self):
        tool = next(t for t in get_tool_schemas() if t["name"] == "risposta_esercizio")
        esito_schema = tool["input_schema"]["properties"]["esito"]
        assert set(esito_schema["enum"]) == {"primo_tentativo", "con_guida", "non_risolto"}


# ===================================================================
# Test: client LLM — parsing streaming events
# ===================================================================


@dataclass
class FakeContentBlockStart:
    type: str = "content_block_start"
    content_block: object = None


@dataclass
class FakeContentBlockDelta:
    type: str = "content_block_delta"
    delta: object = None


@dataclass
class FakeContentBlockStop:
    type: str = "content_block_stop"


@dataclass
class FakeMessageStart:
    type: str = "message_start"
    message: object = None


@dataclass
class FakeMessageDelta:
    type: str = "message_delta"
    delta: object = None
    usage: object = None


@dataclass
class FakeBlock:
    type: str
    id: str = ""
    name: str = ""


@dataclass
class FakeTextDelta:
    text: str


@dataclass
class FakeJsonDelta:
    partial_json: str


@dataclass
class FakeStopDelta:
    stop_reason: str


@dataclass
class FakeUsage:
    input_tokens: int = 0
    output_tokens: int = 0


@dataclass
class FakeMessage:
    usage: FakeUsage = None


class FakeStream:
    """Simula uno stream Anthropic con eventi predefiniti."""

    def __init__(self, events: list):
        self.events = events

    async def __aenter__(self):
        return self

    async def __aexit__(self, *args):
        pass

    def __aiter__(self):
        return self._iter_events()

    async def _iter_events(self):
        for event in self.events:
            yield event


class TestClientStreaming:
    """Test del parsing dello streaming usando eventi mock."""

    @pytest.fixture
    def text_only_events(self):
        """Simula una risposta con solo testo."""
        return [
            FakeMessageStart(
                message=FakeMessage(usage=FakeUsage(input_tokens=100))
            ),
            FakeContentBlockStart(content_block=FakeBlock(type="text")),
            FakeContentBlockDelta(delta=FakeTextDelta(text="Ciao! ")),
            FakeContentBlockDelta(delta=FakeTextDelta(text="Oggi parliamo di equazioni.")),
            FakeContentBlockStop(),
            FakeMessageDelta(
                delta=FakeStopDelta(stop_reason="end_turn"),
                usage=FakeUsage(output_tokens=50),
            ),
        ]

    @pytest.fixture
    def text_and_tool_events(self):
        """Simula una risposta con testo + tool_use (azione + segnale)."""
        return [
            FakeMessageStart(
                message=FakeMessage(usage=FakeUsage(input_tokens=200))
            ),
            # Testo
            FakeContentBlockStart(content_block=FakeBlock(type="text")),
            FakeContentBlockDelta(delta=FakeTextDelta(text="Proviamo un esercizio. ")),
            FakeContentBlockStop(),
            # Azione: proponi_esercizio
            FakeContentBlockStart(
                content_block=FakeBlock(
                    type="tool_use",
                    id="toolu_001",
                    name="proponi_esercizio",
                )
            ),
            FakeContentBlockDelta(
                delta=FakeJsonDelta(partial_json='{"nodo_id": "alg1_eq_primo')
            ),
            FakeContentBlockDelta(
                delta=FakeJsonDelta(partial_json='_grado", "difficolta": "base"}')
            ),
            FakeContentBlockStop(),
            # Segnale: concetto_spiegato
            FakeContentBlockStart(
                content_block=FakeBlock(
                    type="tool_use",
                    id="toolu_002",
                    name="concetto_spiegato",
                )
            ),
            FakeContentBlockDelta(
                delta=FakeJsonDelta(
                    partial_json=(
                        '{"nodo_id": "alg1_eq_primo_grado",'
                        ' "punti_coperti": ["definizione"]}'
                    )
                )
            ),
            FakeContentBlockStop(),
            FakeMessageDelta(
                delta=FakeStopDelta(stop_reason="tool_use"),
                usage=FakeUsage(output_tokens=150),
            ),
        ]

    @pytest.mark.asyncio
    async def test_text_only_stream(self, text_only_events):
        from app.llm.client import chiama_tutor

        mock_client = MagicMock()
        mock_client.messages.stream.return_value = FakeStream(text_only_events)

        with patch("app.llm.client._get_client", return_value=mock_client):
            eventi = []
            async for evento in chiama_tutor(
                system="test", messages=[{"role": "user", "content": "ciao"}]
            ):
                eventi.append(evento)

        text_deltas = [e for e in eventi if e["tipo"] == "text_delta"]
        assert len(text_deltas) == 2
        assert text_deltas[0]["testo"] == "Ciao! "
        assert text_deltas[1]["testo"] == "Oggi parliamo di equazioni."

        stop = [e for e in eventi if e["tipo"] == "stop"]
        assert len(stop) == 1
        risultato = stop[0]["risultato"]
        assert risultato.testo_completo == "Ciao! Oggi parliamo di equazioni."
        assert risultato.token_input == 100
        assert risultato.token_output == 50
        assert risultato.azioni == []
        assert risultato.segnali == []

    @pytest.mark.asyncio
    async def test_text_and_tool_stream(self, text_and_tool_events):
        from app.llm.client import chiama_tutor

        mock_client = MagicMock()
        mock_client.messages.stream.return_value = FakeStream(text_and_tool_events)

        with patch("app.llm.client._get_client", return_value=mock_client):
            eventi = []
            async for evento in chiama_tutor(
                system="test", messages=[{"role": "user", "content": "ciao"}]
            ):
                eventi.append(evento)

        # Testo
        text_deltas = [e for e in eventi if e["tipo"] == "text_delta"]
        assert len(text_deltas) == 1
        assert "esercizio" in text_deltas[0]["testo"].lower()

        # Tool use
        tool_uses = [e for e in eventi if e["tipo"] == "tool_use"]
        assert len(tool_uses) == 2

        # Azione
        azione = tool_uses[0]
        assert azione["name"] == "proponi_esercizio"
        assert azione["categoria"] == "azione"
        assert azione["input"]["nodo_id"] == "alg1_eq_primo_grado"
        assert azione["input"]["difficolta"] == "base"

        # Segnale
        segnale = tool_uses[1]
        assert segnale["name"] == "concetto_spiegato"
        assert segnale["categoria"] == "segnale"
        assert segnale["input"]["nodo_id"] == "alg1_eq_primo_grado"

        # Risultato finale
        stop = [e for e in eventi if e["tipo"] == "stop"]
        risultato = stop[0]["risultato"]
        assert len(risultato.azioni) == 1
        assert len(risultato.segnali) == 1
        assert risultato.token_input == 200
        assert risultato.token_output == 150
        assert risultato.stop_reason == "tool_use"

    @pytest.mark.asyncio
    async def test_timeout_yields_error(self):
        from app.llm.client import chiama_tutor

        mock_client = MagicMock()

        class SlowStream:
            async def __aenter__(self):
                import asyncio
                await asyncio.sleep(100)
                return self

            async def __aexit__(self, *args):
                pass

            def __aiter__(self):
                return self

            async def __anext__(self):
                raise StopAsyncIteration

        mock_client.messages.stream.return_value = SlowStream()

        with (
            patch("app.llm.client._get_client", return_value=mock_client),
            patch("app.llm.client.settings") as mock_settings,
        ):
            mock_settings.TIMEOUT_LLM_SEC = 0.01
            mock_settings.LLM_MODEL_TUTOR = "test-model"
            mock_settings.ANTHROPIC_API_KEY = "test"

            eventi = []
            async for evento in chiama_tutor(
                system="test", messages=[{"role": "user", "content": "ciao"}]
            ):
                eventi.append(evento)

        errori = [e for e in eventi if e["tipo"] == "errore"]
        assert len(errori) == 1
        assert "timeout" in errori[0]["messaggio"].lower()

    @pytest.mark.asyncio
    async def test_costo_stimato(self):
        from app.llm.client import _stima_costo

        # Sonnet: 3.0 input, 15.0 output per milione
        costo = _stima_costo("claude-sonnet-4-5-20250929", 1000, 500)
        expected = (1000 * 3.0 + 500 * 15.0) / 1_000_000
        assert abs(costo - expected) < 0.0001

        # Haiku: 0.80 input, 4.0 output per milione
        costo_h = _stima_costo("claude-haiku-4-5-20251001", 1000, 500)
        expected_h = (1000 * 0.80 + 500 * 4.0) / 1_000_000
        assert abs(costo_h - expected_h) < 0.0001

        # Modello sconosciuto: fallback a default (3.0, 15.0)
        costo_u = _stima_costo("unknown-model", 1000, 500)
        assert costo_u == expected
