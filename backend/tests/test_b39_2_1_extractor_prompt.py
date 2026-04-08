"""Test B39.2.1 — Prompt estrattore profilo onboarding.

Verifica che il prompt contenga le istruzioni chiave, il formato JSON atteso,
e che la funzione build_extractor_prompt produca output coerente.
"""

import json

import pytest

from app.llm.prompts.onboarding_extractor import (
    CAMPI_PROFILO,
    CONFIDENZE_VALIDE,
    SCHEMA_OUTPUT_ESEMPIO,
    SCHEMA_OUTPUT_PARZIALE,
    build_extractor_prompt,
    _formatta_conversazione,
)


# --- Test costanti esportate ---


class TestCampiProfilo:
    """Verifica che le costanti del modulo siano coerenti."""

    def test_cinque_campi_presenti(self):
        assert len(CAMPI_PROFILO) == 5
        campi_attesi = {
            "chi_e", "motivo", "stile_cognitivo",
            "tempo_disponibile", "vissuto_scolastico",
        }
        assert set(CAMPI_PROFILO.keys()) == campi_attesi

    def test_confidenze_valide(self):
        assert CONFIDENZE_VALIDE == ("alta", "media", "bassa")

    def test_schema_esempio_e_json_valido(self):
        parsed = json.loads(SCHEMA_OUTPUT_ESEMPIO)
        assert isinstance(parsed, dict)
        # Tutti e 5 i campi presenti
        for campo in CAMPI_PROFILO:
            assert campo in parsed
            assert "valore" in parsed[campo]
            assert "confidenza" in parsed[campo]
            assert parsed[campo]["confidenza"] in CONFIDENZE_VALIDE

    def test_schema_parziale_e_json_valido(self):
        parsed = json.loads(SCHEMA_OUTPUT_PARZIALE)
        assert isinstance(parsed, dict)
        for campo in CAMPI_PROFILO:
            assert campo in parsed
            assert parsed[campo]["confidenza"] in CONFIDENZE_VALIDE

    def test_schema_parziale_ha_valori_null(self):
        """Lo schema parziale deve avere almeno un campo con valore null."""
        parsed = json.loads(SCHEMA_OUTPUT_PARZIALE)
        valori_null = [c for c in parsed if parsed[c]["valore"] is None]
        assert len(valori_null) >= 1


# --- Test formattazione conversazione ---


class TestFormattaConversazione:
    """Verifica che _formatta_conversazione produca testo leggibile."""

    def test_conversazione_vuota(self):
        assert _formatta_conversazione([]) == "(conversazione vuota)"

    def test_conversazione_singolo_turno_utente(self):
        conv = [{"role": "user", "content": "Ciao, sono Marco"}]
        result = _formatta_conversazione(conv)
        assert "UTENTE: Ciao, sono Marco" in result

    def test_conversazione_turno_assistente(self):
        conv = [{"role": "assistant", "content": "Piacere di conoscerti!"}]
        result = _formatta_conversazione(conv)
        assert "TUTOR: Piacere di conoscerti!" in result

    def test_conversazione_multi_turno(self):
        conv = [
            {"role": "assistant", "content": "Ciao!"},
            {"role": "user", "content": "Sono uno studente"},
            {"role": "assistant", "content": "Raccontami di più"},
        ]
        result = _formatta_conversazione(conv)
        righe = result.split("\n")
        assert len(righe) == 3
        assert righe[0].startswith("TUTOR:")
        assert righe[1].startswith("UTENTE:")
        assert righe[2].startswith("TUTOR:")

    def test_role_sconosciuto(self):
        conv = [{"role": "system", "content": "test"}]
        result = _formatta_conversazione(conv)
        assert "SYSTEM: test" in result


# --- Test build_extractor_prompt ---


class TestBuildExtractorPrompt:
    """Verifica che il prompt generato contenga tutti gli elementi necessari."""

    @pytest.fixture
    def conversazione_esempio(self):
        return [
            {"role": "assistant", "content": "Ciao, raccontami di te."},
            {
                "role": "user",
                "content": (
                    "Sono Marco, ho 42 anni, faccio il grafico freelance. "
                    "Ho sempre odiato la matematica alle superiori. "
                    "Vorrei riprovare da adulto, ho circa 20 minuti a sera."
                ),
            },
        ]

    def test_prompt_contiene_tutti_i_campi(self, conversazione_esempio):
        prompt = build_extractor_prompt(conversazione_esempio)
        for campo in CAMPI_PROFILO:
            assert campo in prompt, f"Campo '{campo}' mancante nel prompt"

    def test_prompt_contiene_descrizioni_campi(self, conversazione_esempio):
        prompt = build_extractor_prompt(conversazione_esempio)
        for desc in CAMPI_PROFILO.values():
            assert desc in prompt, f"Descrizione '{desc}' mancante nel prompt"

    def test_prompt_contiene_regole_confidenza(self, conversazione_esempio):
        prompt = build_extractor_prompt(conversazione_esempio)
        for conf in CONFIDENZE_VALIDE:
            assert f"**{conf}**" in prompt

    def test_prompt_contiene_istruzione_solo_json(self, conversazione_esempio):
        prompt = build_extractor_prompt(conversazione_esempio)
        assert "ESCLUSIVAMENTE" in prompt
        assert "JSON" in prompt

    def test_prompt_contiene_conversazione(self, conversazione_esempio):
        prompt = build_extractor_prompt(conversazione_esempio)
        assert "UTENTE: Sono Marco" in prompt
        assert "TUTOR: Ciao, raccontami di te." in prompt

    def test_prompt_contiene_esempio_completo(self, conversazione_esempio):
        prompt = build_extractor_prompt(conversazione_esempio)
        assert "utente collaborativo" in prompt.lower() or "completo" in prompt.lower()
        # L'esempio JSON è presente nel prompt
        assert '"chi_e"' in prompt
        assert '"confidenza"' in prompt

    def test_prompt_contiene_esempio_parziale(self, conversazione_esempio):
        prompt = build_extractor_prompt(conversazione_esempio)
        assert "taciturno" in prompt.lower() or "parziale" in prompt.lower()

    def test_prompt_specifica_non_inventare(self, conversazione_esempio):
        """Il prompt deve istruire a non inventare informazioni."""
        prompt = build_extractor_prompt(conversazione_esempio)
        assert "non inventare" in prompt.lower()

    def test_prompt_con_conversazione_vuota(self):
        prompt = build_extractor_prompt([])
        assert "(conversazione vuota)" in prompt
        # Deve comunque contenere le istruzioni
        for campo in CAMPI_PROFILO:
            assert campo in prompt

    def test_prompt_e_stringa_non_vuota(self, conversazione_esempio):
        prompt = build_extractor_prompt(conversazione_esempio)
        assert isinstance(prompt, str)
        assert len(prompt) > 500  # Un prompt serio è lungo

    def test_prompt_specifica_cinque_campi_sempre_presenti(self, conversazione_esempio):
        """Il prompt deve dire che tutti i 5 campi devono essere nell'output."""
        prompt = build_extractor_prompt(conversazione_esempio)
        assert "5 campi" in prompt.lower() or "SEMPRE presenti" in prompt
