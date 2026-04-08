"""Test B39.2.3 — Funzione estrai_profilo con chiamata Opus (mock).

Verifica: parsing JSON, retry su fallimento, fallback a profilo vuoto,
gestione conversazione vuota, JSON dentro markdown, JSON con testo extra.
"""

import json
from unittest.mock import AsyncMock, patch

import anthropic
import pytest

from app.core.onboarding import _parsa_json_risposta, _profilo_vuoto, estrai_profilo
from app.schemas.onboarding import ProfiloEstratto

# === Helper _profilo_vuoto ===


class TestProfiloVuoto:
    """Verifica che il profilo vuoto abbia tutti i campi a bassa confidenza."""

    def test_profilo_vuoto_tutti_bassa(self):
        profilo = _profilo_vuoto()
        assert isinstance(profilo, ProfiloEstratto)
        assert len(profilo.campi_mancanti()) == 5
        assert len(profilo.campi_completi()) == 0
        assert not profilo.is_completo()

    def test_profilo_vuoto_valori_none(self):
        profilo = _profilo_vuoto()
        for nome in ("chi_e", "motivo", "stile_cognitivo",
                     "tempo_disponibile", "vissuto_scolastico"):
            campo = getattr(profilo, nome)
            assert campo.valore is None
            assert campo.confidenza == "bassa"


# === Helper _parsa_json_risposta ===


class TestParsaJsonRisposta:
    """Test per il parser JSON robusto."""

    def test_json_puro(self):
        """JSON diretto senza testo extra."""
        risposta = json.dumps({
            "chi_e": {"valore": "studente", "confidenza": "alta"},
            "motivo": {"valore": None, "confidenza": "bassa"},
        })
        risultato = _parsa_json_risposta(risposta)
        assert risultato is not None
        assert risultato["chi_e"]["valore"] == "studente"

    def test_json_in_markdown(self):
        """JSON wrappato in blocco ```json."""
        risposta = '```json\n{"chi_e": {"valore": "test", "confidenza": "alta"}}\n```'
        risultato = _parsa_json_risposta(risposta)
        assert risultato is not None
        assert risultato["chi_e"]["valore"] == "test"

    def test_json_in_markdown_senza_label(self):
        """JSON wrappato in blocco ``` senza "json"."""
        risposta = '```\n{"chi_e": {"valore": "test", "confidenza": "alta"}}\n```'
        risultato = _parsa_json_risposta(risposta)
        assert risultato is not None

    def test_json_con_testo_prima(self):
        """JSON preceduto da testo."""
        risposta = 'Ecco il profilo:\n{"chi_e": {"valore": "test", "confidenza": "alta"}}'
        risultato = _parsa_json_risposta(risposta)
        assert risultato is not None
        assert risultato["chi_e"]["valore"] == "test"

    def test_json_con_testo_dopo(self):
        """JSON seguito da testo."""
        risposta = '{"chi_e": {"valore": "test", "confidenza": "alta"}}\nFine.'
        risultato = _parsa_json_risposta(risposta)
        assert risultato is not None

    def test_json_invalido(self):
        """Testo che non contiene JSON valido."""
        assert _parsa_json_risposta("non è json") is None

    def test_stringa_vuota(self):
        assert _parsa_json_risposta("") is None

    def test_array_json_non_dict(self):
        """Un array JSON non è un dict — deve ritornare None."""
        assert _parsa_json_risposta('[1, 2, 3]') is None


# === Funzione estrai_profilo ===


# JSON di risposta valido per i mock
_JSON_PROFILO_COMPLETO = json.dumps({
    "chi_e": {"valore": "adulto di 42 anni, grafico freelance", "confidenza": "alta"},
    "motivo": {"valore": "curiosità personale", "confidenza": "alta"},
    "stile_cognitivo": {"valore": "esempi concreti", "confidenza": "alta"},
    "tempo_disponibile": {"valore": "20 minuti sera", "confidenza": "alta"},
    "vissuto_scolastico": {"valore": "odiava la matematica", "confidenza": "alta"},
})

_JSON_PROFILO_PARZIALE = json.dumps({
    "chi_e": {"valore": "studente", "confidenza": "bassa"},
    "motivo": {"valore": None, "confidenza": "bassa"},
    "stile_cognitivo": {"valore": None, "confidenza": "bassa"},
    "tempo_disponibile": {"valore": None, "confidenza": "bassa"},
    "vissuto_scolastico": {"valore": None, "confidenza": "bassa"},
})

_CONVERSAZIONE_ESEMPIO = [
    {"role": "assistant", "content": "Ciao, raccontami di te."},
    {"role": "user", "content": "Sono Marco, ho 42 anni, faccio il grafico."},
]


class TestEstaiProfilo:
    """Test della funzione estrai_profilo con mock LLM."""

    @pytest.mark.asyncio
    async def test_estrazione_riuscita(self):
        """Estrazione riuscita al primo tentativo."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_JSON_PROFILO_COMPLETO,
        ):
            profilo = await estrai_profilo(_CONVERSAZIONE_ESEMPIO)

        assert isinstance(profilo, ProfiloEstratto)
        assert profilo.is_completo()
        assert profilo.chi_e.valore == "adulto di 42 anni, grafico freelance"
        assert profilo.chi_e.confidenza == "alta"

    @pytest.mark.asyncio
    async def test_estrazione_parziale(self):
        """Profilo parziale — tutti bassa confidenza tranne chi_e."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_JSON_PROFILO_PARZIALE,
        ):
            profilo = await estrai_profilo(_CONVERSAZIONE_ESEMPIO)

        assert not profilo.is_completo()
        assert len(profilo.campi_mancanti()) == 5  # tutti bassa

    @pytest.mark.asyncio
    async def test_conversazione_vuota(self):
        """Conversazione vuota — ritorna profilo vuoto senza chiamare LLM."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
        ) as mock_llm:
            profilo = await estrai_profilo([])

        mock_llm.assert_not_called()
        assert not profilo.is_completo()
        assert len(profilo.campi_mancanti()) == 5

    @pytest.mark.asyncio
    async def test_retry_su_errore_api(self):
        """Primo tentativo fallisce con APIError, secondo riesce."""
        errore_api = anthropic.APIConnectionError(request=None)
        mock_llm = AsyncMock(
            side_effect=[errore_api, _JSON_PROFILO_COMPLETO]
        )

        with patch("app.core.onboarding.chiama_llm_singolo", mock_llm):
            profilo = await estrai_profilo(_CONVERSAZIONE_ESEMPIO)

        assert profilo.is_completo()
        assert mock_llm.call_count == 2

    @pytest.mark.asyncio
    async def test_retry_su_json_malformato(self):
        """Primo tentativo ritorna JSON invalido, secondo riesce."""
        mock_llm = AsyncMock(
            side_effect=["non è json {{{", _JSON_PROFILO_COMPLETO]
        )

        with patch("app.core.onboarding.chiama_llm_singolo", mock_llm):
            profilo = await estrai_profilo(_CONVERSAZIONE_ESEMPIO)

        assert profilo.is_completo()
        assert mock_llm.call_count == 2

    @pytest.mark.asyncio
    async def test_retry_su_timeout(self):
        """Primo tentativo timeout, secondo riesce."""
        mock_llm = AsyncMock(
            side_effect=[TimeoutError("timeout"), _JSON_PROFILO_COMPLETO]
        )

        with patch("app.core.onboarding.chiama_llm_singolo", mock_llm):
            profilo = await estrai_profilo(_CONVERSAZIONE_ESEMPIO)

        assert profilo.is_completo()
        assert mock_llm.call_count == 2

    @pytest.mark.asyncio
    async def test_fallback_dopo_tutti_tentativi(self):
        """Entrambi i tentativi falliscono — profilo vuoto."""
        mock_llm = AsyncMock(
            side_effect=[
                anthropic.APIConnectionError(request=None),
                anthropic.APIConnectionError(request=None),
            ]
        )

        with patch("app.core.onboarding.chiama_llm_singolo", mock_llm):
            profilo = await estrai_profilo(_CONVERSAZIONE_ESEMPIO)

        assert not profilo.is_completo()
        assert len(profilo.campi_mancanti()) == 5
        assert mock_llm.call_count == 2

    @pytest.mark.asyncio
    async def test_fallback_su_errore_inatteso(self):
        """Errore inatteso — fallback immediato senza retry."""
        mock_llm = AsyncMock(side_effect=RuntimeError("errore inatteso"))

        with patch("app.core.onboarding.chiama_llm_singolo", mock_llm):
            profilo = await estrai_profilo(_CONVERSAZIONE_ESEMPIO)

        assert not profilo.is_completo()
        # Solo 1 chiamata — errore inatteso non ritenta
        assert mock_llm.call_count == 1

    @pytest.mark.asyncio
    async def test_json_in_markdown_wrapping(self):
        """LLM ritorna JSON in blocco markdown — deve funzionare."""
        risposta_markdown = f"```json\n{_JSON_PROFILO_COMPLETO}\n```"
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=risposta_markdown,
        ):
            profilo = await estrai_profilo(_CONVERSAZIONE_ESEMPIO)

        assert profilo.is_completo()

    @pytest.mark.asyncio
    async def test_json_con_testo_extra(self):
        """LLM ritorna JSON con testo descrittivo prima."""
        risposta = f"Ecco il profilo estratto:\n{_JSON_PROFILO_COMPLETO}"
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=risposta,
        ):
            profilo = await estrai_profilo(_CONVERSAZIONE_ESEMPIO)

        assert profilo.is_completo()

    @pytest.mark.asyncio
    async def test_usa_modello_onboarding(self):
        """Verifica che la funzione usi il modello LLM_MODEL_ONBOARDING."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_JSON_PROFILO_COMPLETO,
        ) as mock_llm:
            await estrai_profilo(_CONVERSAZIONE_ESEMPIO)

        # Verifica che il modello passato sia quello onboarding
        call_kwargs = mock_llm.call_args
        assert "modello" in call_kwargs.kwargs
        # Il valore viene da settings.LLM_MODEL_ONBOARDING

    @pytest.mark.asyncio
    async def test_validazione_pydantic_fallita_ritenta(self):
        """JSON valido ma non conforme allo schema Pydantic — ritenta."""
        # Manca il campo "confidenza" — Pydantic rifiuta
        json_invalido = json.dumps({
            "chi_e": {"valore": "test"},  # manca confidenza
            "motivo": {"valore": None, "confidenza": "bassa"},
            "stile_cognitivo": {"valore": None, "confidenza": "bassa"},
            "tempo_disponibile": {"valore": None, "confidenza": "bassa"},
            "vissuto_scolastico": {"valore": None, "confidenza": "bassa"},
        })
        mock_llm = AsyncMock(
            side_effect=[json_invalido, _JSON_PROFILO_COMPLETO]
        )

        with patch("app.core.onboarding.chiama_llm_singolo", mock_llm):
            profilo = await estrai_profilo(_CONVERSAZIONE_ESEMPIO)

        assert profilo.is_completo()
        assert mock_llm.call_count == 2
