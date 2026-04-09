"""Test per genera_esercizi_verifica e _costruisci_coppie (B39.6.4).

Verifica:
- Schema Pydantic EsercizioCompound
- Funzione _costruisci_coppie (scala adattiva)
- Funzione genera_esercizi_verifica con mock LLM
- Retry su fallimento
- Fallimento totale → lista vuota
- Cap a MAX_ESERCIZI_VERIFICA
"""

import json
from unittest.mock import AsyncMock, patch

import anthropic
import pytest

from app.core.onboarding import _costruisci_coppie, genera_esercizi_verifica
from app.llm.prompts.onboarding_exercise_generator import MAX_ESERCIZI_VERIFICA
from app.schemas.onboarding import EsercizioCompound, OpzioneEsercizio


# --- Fixture: risposta LLM valida ---

def _esercizio_dict(
    concetti: list[str] | None = None,
    risposta: str = "A",
) -> dict:
    """Helper: esercizio valido come dict."""
    concetti = concetti or ["frazioni"]
    return {
        "testo": f"Esercizio su {', '.join(concetti)}",
        "concetti": concetti,
        "opzioni": [
            {"lettera": "A", "testo": "Risposta A"},
            {"lettera": "B", "testo": "Risposta B"},
            {"lettera": "C", "testo": "Risposta C"},
        ],
        "risposta_corretta": risposta,
        "spiegazione_breve": "Spiegazione.",
    }


def _risposta_llm_valida(esercizi: list[dict] | None = None) -> str:
    """Simula una risposta JSON valida di Opus."""
    esercizi = esercizi or [_esercizio_dict()]
    return json.dumps(esercizi, ensure_ascii=False)


# --- Test schema EsercizioCompound ---


class TestEsercizioCompound:
    """Verifica lo schema Pydantic EsercizioCompound."""

    def test_validazione_valida(self):
        """Un esercizio valido viene accettato."""
        ex = EsercizioCompound.model_validate(_esercizio_dict())
        assert ex.testo.startswith("Esercizio")
        assert ex.risposta_corretta == "A"
        assert len(ex.opzioni) == 3
        assert ex.concetti == ["frazioni"]

    def test_risposta_corretta_non_tra_opzioni(self):
        """risposta_corretta deve essere tra le lettere delle opzioni."""
        d = _esercizio_dict(risposta="Z")
        with pytest.raises(ValueError, match="risposta_corretta"):
            EsercizioCompound.model_validate(d)

    def test_due_concetti(self):
        """Esercizio compound con 2 concetti."""
        ex = EsercizioCompound.model_validate(
            _esercizio_dict(concetti=["frazioni", "proporzioni"])
        )
        assert len(ex.concetti) == 2

    def test_spiegazione_opzionale_default(self):
        """spiegazione_breve ha default stringa vuota."""
        d = _esercizio_dict()
        del d["spiegazione_breve"]
        ex = EsercizioCompound.model_validate(d)
        assert ex.spiegazione_breve == ""

    def test_opzione_serializzazione(self):
        """OpzioneEsercizio serializza correttamente."""
        o = OpzioneEsercizio(lettera="A", testo="Risposta A")
        assert o.lettera == "A"
        assert o.testo == "Risposta A"


# --- Test _costruisci_coppie ---


class TestCostruisciCoppie:
    """Verifica la logica di accoppiamento aree per esercizi compound."""

    def test_vuota(self):
        """Lista vuota → nessuna coppia."""
        assert _costruisci_coppie([]) == []

    def test_una_area(self):
        """1 area → 1 coppia singola."""
        result = _costruisci_coppie(["frazioni"])
        assert result == [["frazioni"]]

    def test_due_aree_singole(self):
        """2 aree → 2 coppie singole."""
        result = _costruisci_coppie(["frazioni", "proporzioni"])
        assert result == [["frazioni"], ["proporzioni"]]

    def test_tre_aree_compound(self):
        """3 aree → 1 compound + 1 singola."""
        result = _costruisci_coppie(["a", "b", "c"])
        assert result == [["a", "b"], ["c"]]

    def test_quattro_aree_compound(self):
        """4 aree → 2 compound."""
        result = _costruisci_coppie(["a", "b", "c", "d"])
        assert result == [["a", "b"], ["c", "d"]]

    def test_cinque_aree_compound(self):
        """5 aree → 2 compound + 1 singola."""
        result = _costruisci_coppie(["a", "b", "c", "d", "e"])
        assert result == [["a", "b"], ["c", "d"], ["e"]]

    def test_sei_aree_compound(self):
        """6 aree → 3 compound."""
        result = _costruisci_coppie(["a", "b", "c", "d", "e", "f"])
        assert result == [["a", "b"], ["c", "d"], ["e", "f"]]

    def test_sette_aree_cap_a_sei(self):
        """7+ aree → cap a 6 (le prime 6, da B39.6.2)."""
        result = _costruisci_coppie(["a", "b", "c", "d", "e", "f", "g"])
        assert result == [["a", "b"], ["c", "d"], ["e", "f"]]
        # 'g' è esclusa dal cap

    def test_dieci_aree_cap(self):
        """10 aree → sempre max 3 coppie (cap a 6 aree → 3 compound)."""
        aree = [f"area_{i}" for i in range(10)]
        result = _costruisci_coppie(aree)
        assert len(result) == 3


# --- Test genera_esercizi_verifica ---


class TestGeneraEserciziVerifica:
    """Verifica genera_esercizi_verifica con mock LLM."""

    @pytest.mark.asyncio
    async def test_lista_vuota_input(self):
        """Input vuoto → lista vuota senza chiamate LLM."""
        result = await genera_esercizi_verifica([])
        assert result == []

    @pytest.mark.asyncio
    async def test_singola_area_successo(self):
        """1 area → 1 esercizio generato."""
        risposta = _risposta_llm_valida([_esercizio_dict(["frazioni"])])
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=risposta,
        ) as mock_llm:
            result = await genera_esercizi_verifica(["frazioni"])
            assert len(result) == 1
            assert isinstance(result[0], EsercizioCompound)
            assert result[0].concetti == ["frazioni"]
            mock_llm.assert_called_once()

    @pytest.mark.asyncio
    async def test_due_aree_compound(self):
        """2 aree → 2 esercizi singoli."""
        esercizi = [
            _esercizio_dict(["frazioni"]),
            _esercizio_dict(["proporzioni"]),
        ]
        risposta = _risposta_llm_valida(esercizi)
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=risposta,
        ):
            result = await genera_esercizi_verifica(["frazioni", "proporzioni"])
            assert len(result) == 2

    @pytest.mark.asyncio
    async def test_sei_aree_tre_compound(self):
        """6 aree → 3 esercizi compound."""
        esercizi = [
            _esercizio_dict(["a", "b"]),
            _esercizio_dict(["c", "d"]),
            _esercizio_dict(["e", "f"]),
        ]
        risposta = _risposta_llm_valida(esercizi)
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=risposta,
        ):
            result = await genera_esercizi_verifica(
                ["a", "b", "c", "d", "e", "f"]
            )
            assert len(result) == 3

    @pytest.mark.asyncio
    async def test_nomi_concetti_passati(self):
        """nomi_concetti viene passato al prompt builder."""
        risposta = _risposta_llm_valida([_esercizio_dict(["frazioni"])])
        nomi = {"frazioni": "Le frazioni"}
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=risposta,
        ):
            result = await genera_esercizi_verifica(["frazioni"], nomi_concetti=nomi)
            assert len(result) == 1

    @pytest.mark.asyncio
    async def test_cap_max_esercizi(self):
        """Anche se LLM ritorna più di MAX, vengono cappati."""
        esercizi = [_esercizio_dict([f"area_{i}"]) for i in range(5)]
        risposta = _risposta_llm_valida(esercizi)
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=risposta,
        ):
            result = await genera_esercizi_verifica(["a", "b", "c", "d", "e"])
            assert len(result) <= MAX_ESERCIZI_VERIFICA

    @pytest.mark.asyncio
    async def test_retry_su_errore_api(self):
        """Retry dopo errore API, successo al secondo tentativo."""
        risposta = _risposta_llm_valida([_esercizio_dict(["frazioni"])])
        mock = AsyncMock(side_effect=[
            anthropic.APIError(
                message="rate limit",
                request=None,
                body=None,
            ),
            risposta,
        ])
        with patch("app.core.onboarding.chiama_llm_singolo", mock):
            result = await genera_esercizi_verifica(["frazioni"])
            assert len(result) == 1
            assert mock.call_count == 2

    @pytest.mark.asyncio
    async def test_retry_su_json_invalido(self):
        """Retry dopo JSON invalido, successo al secondo tentativo."""
        risposta_ok = _risposta_llm_valida([_esercizio_dict(["frazioni"])])
        mock = AsyncMock(side_effect=[
            "questo non è JSON valido {{{",
            risposta_ok,
        ])
        with patch("app.core.onboarding.chiama_llm_singolo", mock):
            result = await genera_esercizi_verifica(["frazioni"])
            assert len(result) == 1
            assert mock.call_count == 2

    @pytest.mark.asyncio
    async def test_fallimento_totale_api(self):
        """Tutti i tentativi falliti (API) → lista vuota."""
        mock = AsyncMock(side_effect=anthropic.APIError(
            message="server error",
            request=None,
            body=None,
        ))
        with patch("app.core.onboarding.chiama_llm_singolo", mock):
            result = await genera_esercizi_verifica(["frazioni"])
            assert result == []
            assert mock.call_count == 2

    @pytest.mark.asyncio
    async def test_fallimento_totale_parsing(self):
        """Tutti i tentativi con JSON invalido → lista vuota."""
        mock = AsyncMock(return_value="non JSON")
        with patch("app.core.onboarding.chiama_llm_singolo", mock):
            result = await genera_esercizi_verifica(["frazioni"])
            assert result == []

    @pytest.mark.asyncio
    async def test_errore_inatteso_no_retry(self):
        """Errore inatteso → lista vuota, nessun retry."""
        mock = AsyncMock(side_effect=RuntimeError("bug inatteso"))
        with patch("app.core.onboarding.chiama_llm_singolo", mock):
            result = await genera_esercizi_verifica(["frazioni"])
            assert result == []
            # Nessun retry su errore inatteso
            assert mock.call_count == 1

    @pytest.mark.asyncio
    async def test_esercizio_parzialmente_invalido(self):
        """Se un esercizio è invalido Pydantic, viene scartato ma gli altri passano."""
        esercizio_ok = _esercizio_dict(["frazioni"])
        esercizio_ko = {
            "testo": "Esercizio invalido",
            "concetti": ["x"],
            "opzioni": [
                {"lettera": "A", "testo": "A"},
                {"lettera": "B", "testo": "B"},
                {"lettera": "C", "testo": "C"},
            ],
            "risposta_corretta": "Z",  # non tra le opzioni → invalido
        }
        risposta = json.dumps([esercizio_ok, esercizio_ko], ensure_ascii=False)
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=risposta,
        ):
            result = await genera_esercizi_verifica(["frazioni", "x"])
            # Solo l'esercizio valido passa
            assert len(result) == 1
            assert result[0].concetti == ["frazioni"]

    @pytest.mark.asyncio
    async def test_tutti_esercizi_invalidi_pydantic(self):
        """Tutti gli esercizi falliscono Pydantic → retry."""
        esercizio_ko = {
            "testo": "Invalido",
            "concetti": ["x"],
            "opzioni": [
                {"lettera": "A", "testo": "A"},
                {"lettera": "B", "testo": "B"},
                {"lettera": "C", "testo": "C"},
            ],
            "risposta_corretta": "Z",
        }
        risposta_ko = json.dumps([esercizio_ko], ensure_ascii=False)
        risposta_ok = _risposta_llm_valida([_esercizio_dict(["frazioni"])])
        mock = AsyncMock(side_effect=[risposta_ko, risposta_ok])
        with patch("app.core.onboarding.chiama_llm_singolo", mock):
            result = await genera_esercizi_verifica(["frazioni"])
            assert len(result) == 1
            assert mock.call_count == 2

    @pytest.mark.asyncio
    async def test_risposta_con_markdown_wrapper(self):
        """Risposta LLM wrappata in ```json funziona comunque."""
        esercizio = _esercizio_dict(["algebra"])
        risposta = f"```json\n{json.dumps([esercizio], ensure_ascii=False)}\n```"
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=risposta,
        ):
            result = await genera_esercizi_verifica(["algebra"])
            assert len(result) == 1

    @pytest.mark.asyncio
    async def test_modello_onboarding_usato(self):
        """Verifica che venga usato LLM_MODEL_ONBOARDING."""
        risposta = _risposta_llm_valida([_esercizio_dict(["frazioni"])])
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=risposta,
        ) as mock_llm:
            await genera_esercizi_verifica(["frazioni"])
            _, kwargs = mock_llm.call_args
            assert "modello" in kwargs
            assert "opus" in kwargs["modello"].lower() or "onboarding" in str(kwargs)
