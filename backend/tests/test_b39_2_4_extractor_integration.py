"""Test B39.2.4 — Integrazione estrattore profilo su scenari realistici.

A differenza di test_b39_2_3, qui si testano conversazioni multi-turno
realistiche con risposte LLM complete (mock). Ogni scenario verifica
che i campi estratti, le confidenze e i metodi helper (campi_completi,
campi_mancanti, is_completo) riflettano correttamente il contenuto.
"""

import json
from unittest.mock import AsyncMock, patch

import anthropic
import pytest

from app.core.onboarding import estrai_profilo
from app.schemas.onboarding import ProfiloEstratto

# ═══════════════════════════════════════════════════════════════
# Conversazioni realistiche
# ═══════════════════════════════════════════════════════════════

CONV_COLLABORATIVA = [
    {
        "role": "assistant",
        "content": (
            "Ciao! Benvenuto su Dydat. Raccontami un po' di te:"
            " quanti anni hai, cosa fai nella vita?"
        ),
    },
    {
        "role": "user",
        "content": (
            "Ciao! Ho 35 anni, sono un ingegnere informatico."
            " Voglio ripassare matematica perché sto preparando"
            " un concorso pubblico."
        ),
    },
    {
        "role": "assistant",
        "content": (
            "Fantastico! Un ingegnere che torna alla matematica,"
            " mi piace. Come preferisci imparare? Ti trovi meglio"
            " con esempi pratici o con le regole formali?"
        ),
    },
    {
        "role": "user",
        "content": (
            "Decisamente esempi pratici prima, poi le regole."
            " A scuola mi annoiavo con le definizioni astratte,"
            " ma quando vedevo un esempio concreto capivo subito."
        ),
    },
    {
        "role": "assistant",
        "content": (
            "Perfetto! E quanto tempo pensi di poter dedicare"
            " allo studio ogni giorno?"
        ),
    },
    {
        "role": "user",
        "content": (
            "Circa 30 minuti la sera dopo cena. Il weekend magari"
            " un'oretta. A scuola andavo bene in matematica ma poi"
            " all'università ho un po' perso il filo."
        ),
    },
]

CONV_PARZIALE = [
    {
        "role": "assistant",
        "content": "Ciao! Benvenuto su Dydat. Raccontami un po' di te.",
    },
    {"role": "user", "content": "Ciao, sono uno studente delle superiori."},
    {"role": "assistant", "content": "Bene! Cosa ti porta su Dydat?"},
    {
        "role": "user",
        "content": "Devo recuperare un debito in matematica.",
    },
]

CONV_OFF_TOPIC = [
    {
        "role": "assistant",
        "content": "Ciao! Benvenuto su Dydat. Raccontami un po' di te.",
    },
    {"role": "user", "content": "Ciao, che tempo fa oggi?"},
    {
        "role": "assistant",
        "content": (
            "Haha, qui parliamo di matematica! Dimmi qualcosa di te:"
            " cosa studi? Cosa fai nella vita?"
        ),
    },
    {
        "role": "user",
        "content": "Mi piace il calcio. Ieri la Juve ha vinto 3-0.",
    },
    {
        "role": "assistant",
        "content": (
            "Capisco! Ma tornando a noi:"
            " perché vuoi studiare matematica?"
        ),
    },
    {"role": "user", "content": "Boh, mi hanno detto di provarci."},
]

CONV_MINIMALE = [
    {
        "role": "assistant",
        "content": "Ciao! Benvenuto su Dydat. Raccontami un po' di te.",
    },
]

CONV_CONFIDENZA_MISTA = [
    {"role": "assistant", "content": "Ciao! Raccontami di te."},
    {
        "role": "user",
        "content": (
            "Ho 28 anni, faccio l'infermiera."
            " Voglio capire la statistica per il lavoro."
        ),
    },
    {"role": "assistant", "content": "Che bello! E come preferisci studiare?"},
    {
        "role": "user",
        "content": (
            "Non saprei, credo di preferire cose pratiche"
            " ma non ne sono sicura."
        ),
    },
]

CONV_LUNGA = [
    {
        "role": "assistant",
        "content": "Ciao! Benvenuto su Dydat. Raccontami un po' di te.",
    },
    {
        "role": "user",
        "content": "Sono Laura, 22 anni, studentessa di economia.",
    },
    {"role": "assistant", "content": "Piacere Laura! Cosa ti porta qui?"},
    {
        "role": "user",
        "content": (
            "Ho un esame di analisi matematica tra un mese"
            " e sono nel panico totale."
        ),
    },
    {
        "role": "assistant",
        "content": (
            "Capisco l'urgenza! Come ti trovi con la matematica"
            " in generale?"
        ),
    },
    {
        "role": "user",
        "content": (
            "Al liceo andavo benissimo, ma all'università"
            " è tutto un altro livello. Mi sento persa."
        ),
    },
    {
        "role": "assistant",
        "content": (
            "È normale, non sei sola. Come preferisci imparare?"
            " Ti trovi meglio con esercizi o teoria?"
        ),
    },
    {
        "role": "user",
        "content": (
            "Esercizi, tanti esercizi. La teoria la capisco"
            " solo quando la applico."
        ),
    },
    {
        "role": "assistant",
        "content": (
            "Ottimo approccio! Quanto tempo puoi dedicare"
            " ogni giorno?"
        ),
    },
    {
        "role": "user",
        "content": (
            "Ho un mese, quindi posso fare anche 2 ore al giorno."
            " Di più nel weekend."
        ),
    },
    {
        "role": "assistant",
        "content": (
            "Perfetto, con 2 ore al giorno possiamo fare tanto!"
            " Qualcos'altro che vuoi dirmi?"
        ),
    },
    {
        "role": "user",
        "content": (
            "Sì, ho il terrore degli integrali."
            " Il prof spiega malissimo e l'ansia da esame"
            " non aiuta."
        ),
    },
]


# ═══════════════════════════════════════════════════════════════
# Risposte mock LLM (JSON realistici)
# ═══════════════════════════════════════════════════════════════

_RISPOSTA_COLLABORATIVA = json.dumps({
    "chi_e": {
        "valore": "ingegnere informatico di 35 anni",
        "confidenza": "alta",
    },
    "motivo": {
        "valore": "preparazione concorso pubblico, ripasso",
        "confidenza": "alta",
    },
    "stile_cognitivo": {
        "valore": "esempi concreti prima delle regole",
        "confidenza": "alta",
    },
    "tempo_disponibile": {
        "valore": "30 minuti la sera, un'ora nel weekend",
        "confidenza": "alta",
    },
    "vissuto_scolastico": {
        "valore": "bene a scuola, perso il filo all'università",
        "confidenza": "alta",
    },
})

_RISPOSTA_PARZIALE = json.dumps({
    "chi_e": {
        "valore": "studente delle superiori",
        "confidenza": "media",
    },
    "motivo": {
        "valore": "recupero debito in matematica",
        "confidenza": "alta",
    },
    "stile_cognitivo": {"valore": None, "confidenza": "bassa"},
    "tempo_disponibile": {"valore": None, "confidenza": "bassa"},
    "vissuto_scolastico": {"valore": None, "confidenza": "bassa"},
})

_RISPOSTA_OFF_TOPIC = json.dumps({
    "chi_e": {"valore": None, "confidenza": "bassa"},
    "motivo": {"valore": None, "confidenza": "bassa"},
    "stile_cognitivo": {"valore": None, "confidenza": "bassa"},
    "tempo_disponibile": {"valore": None, "confidenza": "bassa"},
    "vissuto_scolastico": {"valore": None, "confidenza": "bassa"},
})

_RISPOSTA_CONFIDENZA_MISTA = json.dumps({
    "chi_e": {
        "valore": "infermiera di 28 anni",
        "confidenza": "alta",
    },
    "motivo": {
        "valore": "capire la statistica per il lavoro",
        "confidenza": "alta",
    },
    "stile_cognitivo": {
        "valore": "preferisce cose pratiche ma è incerta",
        "confidenza": "media",
    },
    "tempo_disponibile": {"valore": None, "confidenza": "bassa"},
    "vissuto_scolastico": {"valore": None, "confidenza": "bassa"},
})

_RISPOSTA_LUNGA = json.dumps({
    "chi_e": {
        "valore": "Laura, 22 anni, studentessa di economia",
        "confidenza": "alta",
    },
    "motivo": {
        "valore": "esame di analisi matematica tra un mese",
        "confidenza": "alta",
    },
    "stile_cognitivo": {
        "valore": "preferisce esercizi, capisce applicando",
        "confidenza": "alta",
    },
    "tempo_disponibile": {
        "valore": "2 ore al giorno, di più nel weekend",
        "confidenza": "alta",
    },
    "vissuto_scolastico": {
        "valore": (
            "brava al liceo ma persa all'università,"
            " terrore degli integrali, ansia da esame"
        ),
        "confidenza": "alta",
    },
})


# ═══════════════════════════════════════════════════════════════
# Test scenari realistici
# ═══════════════════════════════════════════════════════════════


class TestScenarioCollaborativo:
    """Scenario 1: utente collaborativo con conversazione ricca."""

    @pytest.mark.asyncio
    async def test_tutti_i_campi_estratti(self):
        """Conversazione completa → 5/5 campi con confidenza alta."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_RISPOSTA_COLLABORATIVA,
        ):
            profilo = await estrai_profilo(CONV_COLLABORATIVA)

        assert isinstance(profilo, ProfiloEstratto)
        assert profilo.is_completo()
        assert len(profilo.campi_completi()) == 5
        assert len(profilo.campi_mancanti()) == 0

    @pytest.mark.asyncio
    async def test_valori_campi_collaborativo(self):
        """Verifica che i valori estratti corrispondano."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_RISPOSTA_COLLABORATIVA,
        ):
            profilo = await estrai_profilo(CONV_COLLABORATIVA)

        assert "ingegnere" in profilo.chi_e.valore.lower()
        assert "concorso" in profilo.motivo.valore.lower()
        assert "esempi" in profilo.stile_cognitivo.valore.lower()
        assert profilo.tempo_disponibile.valore is not None
        assert profilo.vissuto_scolastico.valore is not None

    @pytest.mark.asyncio
    async def test_tutte_confidenze_alta(self):
        """Conversazione ricca → tutte le confidenze 'alta'."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_RISPOSTA_COLLABORATIVA,
        ):
            profilo = await estrai_profilo(CONV_COLLABORATIVA)

        for nome in (
            "chi_e", "motivo", "stile_cognitivo",
            "tempo_disponibile", "vissuto_scolastico",
        ):
            assert getattr(profilo, nome).confidenza == "alta"


class TestScenarioParziale:
    """Scenario 2: utente che fornisce solo 2 campi su 5."""

    @pytest.mark.asyncio
    async def test_profilo_non_completo(self):
        """Solo 2 campi estratti, profilo non completo."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_RISPOSTA_PARZIALE,
        ):
            profilo = await estrai_profilo(CONV_PARZIALE)

        assert not profilo.is_completo()
        assert len(profilo.campi_completi()) == 2
        assert len(profilo.campi_mancanti()) == 3

    @pytest.mark.asyncio
    async def test_campi_mancanti_corretti(self):
        """I 3 campi mancanti sono quelli giusti."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_RISPOSTA_PARZIALE,
        ):
            profilo = await estrai_profilo(CONV_PARZIALE)

        mancanti = set(profilo.campi_mancanti())
        assert mancanti == {
            "stile_cognitivo",
            "tempo_disponibile",
            "vissuto_scolastico",
        }

    @pytest.mark.asyncio
    async def test_campi_presenti_corretti(self):
        """I 2 campi presenti hanno valori sensati."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_RISPOSTA_PARZIALE,
        ):
            profilo = await estrai_profilo(CONV_PARZIALE)

        assert profilo.chi_e.confidenza == "media"
        assert "studente" in profilo.chi_e.valore.lower()
        assert profilo.motivo.confidenza == "alta"
        assert "debito" in profilo.motivo.valore.lower()


class TestScenarioOffTopic:
    """Scenario 3: utente con messaggi irrilevanti."""

    @pytest.mark.asyncio
    async def test_profilo_quasi_vuoto(self):
        """Off-topic → profilo vuoto (tutti bassa confidenza)."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_RISPOSTA_OFF_TOPIC,
        ):
            profilo = await estrai_profilo(CONV_OFF_TOPIC)

        assert not profilo.is_completo()
        assert len(profilo.campi_mancanti()) == 5
        assert len(profilo.campi_completi()) == 0

    @pytest.mark.asyncio
    async def test_tutti_valori_none(self):
        """Off-topic → tutti i valori sono None."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_RISPOSTA_OFF_TOPIC,
        ):
            profilo = await estrai_profilo(CONV_OFF_TOPIC)

        for nome in (
            "chi_e", "motivo", "stile_cognitivo",
            "tempo_disponibile", "vissuto_scolastico",
        ):
            campo = getattr(profilo, nome)
            assert campo.valore is None
            assert campo.confidenza == "bassa"


class TestScenarioMinimale:
    """Scenario 4: conversazione con solo un messaggio del tutor."""

    @pytest.mark.asyncio
    async def test_solo_messaggio_tutor_no_crash(self):
        """Un solo messaggio assistant → LLM chiamato, no crash."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_RISPOSTA_OFF_TOPIC,
        ):
            profilo = await estrai_profilo(CONV_MINIMALE)

        assert isinstance(profilo, ProfiloEstratto)
        assert not profilo.is_completo()

    @pytest.mark.asyncio
    async def test_conversazione_vuota_non_chiama_llm(self):
        """Conversazione vuota → profilo vuoto senza LLM."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
        ) as mock_llm:
            profilo = await estrai_profilo([])

        mock_llm.assert_not_called()
        assert len(profilo.campi_mancanti()) == 5


class TestScenarioFallimentoLLM:
    """Scenario 5: LLM fallisce, retry e fallback."""

    @pytest.mark.asyncio
    async def test_json_rotto_poi_ok(self):
        """Primo tentativo: JSON rotto. Secondo: OK."""
        mock_llm = AsyncMock(
            side_effect=[
                "{ questo non è json valido !!!",
                _RISPOSTA_COLLABORATIVA,
            ]
        )
        with patch(
            "app.core.onboarding.chiama_llm_singolo", mock_llm,
        ):
            profilo = await estrai_profilo(CONV_COLLABORATIVA)

        assert profilo.is_completo()
        assert mock_llm.call_count == 2

    @pytest.mark.asyncio
    async def test_entrambi_tentativi_falliscono(self):
        """Due JSON rotti → profilo vuoto, no crash."""
        mock_llm = AsyncMock(
            side_effect=["non json 1", "non json 2"]
        )
        with patch(
            "app.core.onboarding.chiama_llm_singolo", mock_llm,
        ):
            profilo = await estrai_profilo(CONV_COLLABORATIVA)

        assert not profilo.is_completo()
        assert len(profilo.campi_mancanti()) == 5
        assert mock_llm.call_count == 2

    @pytest.mark.asyncio
    async def test_api_error_poi_successo(self):
        """APIError al primo tentativo, JSON valido al secondo."""
        errore = anthropic.APIConnectionError(request=None)
        mock_llm = AsyncMock(
            side_effect=[errore, _RISPOSTA_PARZIALE]
        )
        with patch(
            "app.core.onboarding.chiama_llm_singolo", mock_llm,
        ):
            profilo = await estrai_profilo(CONV_PARZIALE)

        assert not profilo.is_completo()
        assert len(profilo.campi_completi()) == 2
        assert mock_llm.call_count == 2


class TestScenarioConfidenzaMista:
    """Scenario 6: campi con confidenze miste."""

    @pytest.mark.asyncio
    async def test_mix_confidenze(self):
        """Alcuni campi alta, uno media, altri bassa."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_RISPOSTA_CONFIDENZA_MISTA,
        ):
            profilo = await estrai_profilo(CONV_CONFIDENZA_MISTA)

        # 3 campi completi (2 alta + 1 media)
        assert len(profilo.campi_completi()) == 3
        assert len(profilo.campi_mancanti()) == 2
        assert not profilo.is_completo()

    @pytest.mark.asyncio
    async def test_media_conta_come_completo(self):
        """Confidenza media viene contata come campo completo."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_RISPOSTA_CONFIDENZA_MISTA,
        ):
            profilo = await estrai_profilo(CONV_CONFIDENZA_MISTA)

        assert profilo.stile_cognitivo.confidenza == "media"
        assert "stile_cognitivo" in profilo.campi_completi()


class TestScenarioConversazioneLunga:
    """Scenario 7: conversazione lunga con molti turni."""

    @pytest.mark.asyncio
    async def test_molti_turni_estrazione_completa(self):
        """12 messaggi → profilo completo con tutti i campi."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_RISPOSTA_LUNGA,
        ):
            profilo = await estrai_profilo(CONV_LUNGA)

        assert profilo.is_completo()
        assert len(profilo.campi_completi()) == 5

    @pytest.mark.asyncio
    async def test_valori_conversazione_lunga(self):
        """Verifica contenuto dei campi con conversazione lunga."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_RISPOSTA_LUNGA,
        ):
            profilo = await estrai_profilo(CONV_LUNGA)

        assert "laura" in profilo.chi_e.valore.lower()
        assert "economia" in profilo.chi_e.valore.lower()
        assert "esame" in profilo.motivo.valore.lower()
        assert "esercizi" in profilo.stile_cognitivo.valore.lower()
        assert "2 ore" in profilo.tempo_disponibile.valore.lower()
        assert "integrali" in profilo.vissuto_scolastico.valore.lower()

    @pytest.mark.asyncio
    async def test_prompt_riceve_tutti_i_turni(self):
        """Verifica che il prompt includa tutta la conversazione."""
        with patch(
            "app.core.onboarding.chiama_llm_singolo",
            new_callable=AsyncMock,
            return_value=_RISPOSTA_LUNGA,
        ) as mock_llm:
            await estrai_profilo(CONV_LUNGA)

        # Il prompt passato deve contenere i messaggi chiave
        call_args = mock_llm.call_args
        prompt_inviato = call_args.kwargs.get(
            "user_prompt",
            call_args.args[0] if call_args.args else "",
        )
        assert "Laura" in prompt_inviato
        assert "integrali" in prompt_inviato
