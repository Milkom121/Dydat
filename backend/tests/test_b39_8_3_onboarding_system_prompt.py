"""Test B39.8.3 — System prompt tutor onboarding riscritto.

Verifica che il system prompt onboarding contenga le istruzioni chiave
definite nelle Decisioni 1-5 del documento b39-onboarding-narrativo.md.
Verifica anche l'integrazione nel context builder (modello Opus,
prompt alternativo per sessioni onboarding).
"""

from __future__ import annotations

from app.core.contesto import _blocco_system_prompt
from app.llm.prompts.onboarding_system_prompt import ONBOARDING_SYSTEM_PROMPT
from app.llm.prompts.system_prompt import SYSTEM_PROMPT

# ===================================================================
# Test: contenuto del system prompt onboarding
# ===================================================================


class TestOnboardingSystemPromptContenuto:
    """Verifica presenza delle istruzioni chiave nel prompt."""

    def test_personificazione_prima_persona(self):
        """Decisione 3: tutor personificato in prima persona."""
        assert "prima persona" in ONBOARDING_SYSTEM_PROMPT.lower()
        assert "io sono il tuo tutor" in ONBOARDING_SYSTEM_PROMPT.lower()

    def test_patto_esplicito_presente(self):
        """Decisione 3/4: patto esplicito dichiarato."""
        prompt_lower = ONBOARDING_SYSTEM_PROMPT.lower()
        assert "patto" in prompt_lower
        # Il patto deve menzionare cosa fa e perché
        assert "personalizzare" in prompt_lower or "personalizzar" in prompt_lower

    def test_menzione_voce(self):
        """Decisione 5: menzione del microfono/voce."""
        prompt_lower = ONBOARDING_SYSTEM_PROMPT.lower()
        assert "microfono" in prompt_lower or "voce" in prompt_lower

    def test_forma_c_adattiva(self):
        """Decisione 1: forma adattiva ibrida (turno libero + domande mirate)."""
        prompt_lower = ONBOARDING_SYSTEM_PROMPT.lower()
        # Deve menzionare il concetto di invito libero e domande mirate
        assert "libero" in prompt_lower or "liberamente" in prompt_lower
        assert "mirat" in prompt_lower  # mirate/mirati

    def test_cinque_campi_profilo(self):
        """Decisione 2: i 5 campi del profilo sono menzionati."""
        prompt_lower = ONBOARDING_SYSTEM_PROMPT.lower()
        assert "chi è" in prompt_lower or "chi e" in prompt_lower
        assert "perché studia" in prompt_lower or "perche studia" in prompt_lower
        assert "come impara" in prompt_lower
        assert "quanto tempo" in prompt_lower
        assert "rapporto con la materia" in prompt_lower

    def test_skip_menzionato(self):
        """Decisione 4: lo studente può saltare."""
        prompt_lower = ONBOARDING_SYSTEM_PROMPT.lower()
        assert "saltare" in prompt_lower or "salt" in prompt_lower

    def test_brevita_turni(self):
        """Il prompt richiede turni brevi (max 4-5 righe)."""
        assert "massimo" in ONBOARDING_SYSTEM_PROMPT.lower()
        # Deve indicare un limite di righe
        assert "righe" in ONBOARDING_SYSTEM_PROMPT.lower()

    def test_no_elenchi_puntati(self):
        """Il prompt vieta elenchi puntati nella conversazione."""
        prompt_lower = ONBOARDING_SYSTEM_PROMPT.lower()
        assert "elenchi" in prompt_lower or "elenco" in prompt_lower

    def test_tono_tu_informale(self):
        """Il prompt richiede uso del tu informale."""
        assert "tu" in ONBOARDING_SYSTEM_PROMPT.lower()
        assert "informale" in ONBOARDING_SYSTEM_PROMPT.lower()

    def test_no_nominare_campi_tecnici(self):
        """Non deve suggerire di chiedere "stile cognitivo" letteralmente."""
        prompt_lower = ONBOARDING_SYSTEM_PROMPT.lower()
        assert "non nominare" in prompt_lower or "non chiedere mai" in prompt_lower \
            or "mai nominarli" in prompt_lower or "senza mai nominarli" in prompt_lower

    def test_tool_onboarding_domanda_menzionato(self):
        """Il tool onboarding_domanda è menzionato per uso condizionale."""
        assert "onboarding_domanda" in ONBOARDING_SYSTEM_PROMPT

    def test_prompt_non_vuoto(self):
        """Sanity: il prompt non è vuoto e ha dimensione ragionevole."""
        assert len(ONBOARDING_SYSTEM_PROMPT) > 500
        # Non deve essere esageratamente lungo (< 10k chars)
        assert len(ONBOARDING_SYSTEM_PROMPT) < 10000

    def test_diverso_da_system_prompt_studio(self):
        """Il prompt onboarding è diverso da quello delle sessioni di studio."""
        assert ONBOARDING_SYSTEM_PROMPT != SYSTEM_PROMPT


# ===================================================================
# Test: integrazione nel context builder
# ===================================================================


class TestOnboardingContextBuilderIntegrazione:
    """Verifica che il context builder usi il prompt corretto per tipo sessione."""

    def test_blocco_system_prompt_studio_usa_system_prompt(self):
        """Sessione studio usa il SYSTEM_PROMPT standard."""
        blocco = _blocco_system_prompt("studio")
        assert SYSTEM_PROMPT in blocco
        assert ONBOARDING_SYSTEM_PROMPT not in blocco

    def test_blocco_system_prompt_onboarding_usa_onboarding_prompt(self):
        """Sessione onboarding usa ONBOARDING_SYSTEM_PROMPT."""
        blocco = _blocco_system_prompt("onboarding")
        assert ONBOARDING_SYSTEM_PROMPT in blocco
        assert SYSTEM_PROMPT not in blocco

    def test_blocco_system_prompt_default_studio(self):
        """Il default è studio (retrocompatibilità)."""
        blocco_default = _blocco_system_prompt()
        blocco_studio = _blocco_system_prompt("studio")
        assert blocco_default == blocco_studio

    def test_blocco_system_prompt_ripasso_usa_standard(self):
        """Sessione ripasso usa il prompt standard, non quello onboarding."""
        blocco = _blocco_system_prompt("ripasso")
        assert SYSTEM_PROMPT in blocco
        assert ONBOARDING_SYSTEM_PROMPT not in blocco

    def test_blocco_xml_wrapping(self):
        """Il blocco è wrappato in tag XML <system_prompt>."""
        blocco = _blocco_system_prompt("onboarding")
        assert blocco.startswith("<system_prompt>")
        assert blocco.endswith("</system_prompt>")


# ===================================================================
# Test: proprietà strutturali del prompt
# ===================================================================


class TestOnboardingPromptStruttura:
    """Verifica proprietà strutturali del prompt."""

    def test_sezioni_principali_presenti(self):
        """Il prompt ha le sezioni essenziali."""
        assert "## CHI SEI" in ONBOARDING_SYSTEM_PROMPT
        assert "## IL PATTO ESPLICITO" in ONBOARDING_SYSTEM_PROMPT
        assert "## COME CONDUCI LA CONVERSAZIONE" in ONBOARDING_SYSTEM_PROMPT
        assert "## 5 CAMPI CHE DEVI SCOPRIRE" in ONBOARDING_SYSTEM_PROMPT
        assert "## REGOLE DI TONO E FORMATO" in ONBOARDING_SYSTEM_PROMPT
        assert "## COSA NON FARE MAI" in ONBOARDING_SYSTEM_PROMPT

    def test_primo_turno_istruzioni(self):
        """Il primo turno ha istruzioni specifiche nel patto."""
        prompt_lower = ONBOARDING_SYSTEM_PROMPT.lower()
        assert "primo turno" in prompt_lower

    def test_no_emoji(self):
        """Il prompt vieta le emoji."""
        prompt_lower = ONBOARDING_SYSTEM_PROMPT.lower()
        assert "emoji" in prompt_lower or "emoticon" in prompt_lower
