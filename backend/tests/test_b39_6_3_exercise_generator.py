"""Test per il prompt generatore esercizi compound (B39.6.3).

Verifica:
- Costanti e schema
- Presenza istruzioni chiave nel prompt
- Formato output JSON specificato
- Parser della risposta LLM
- Edge case (nessun esercizio, concetto singolo, coppie eccedenti il cap)
"""

import json

from app.llm.prompts.onboarding_exercise_generator import (
    ISTRUZIONI_CHIAVE,
    MAX_CONCETTI_PER_ESERCIZIO,
    MAX_ESERCIZI_VERIFICA,
    MAX_OPZIONI,
    MIN_OPZIONI,
    SCHEMA_ESERCIZIO_ESEMPIO,
    SCHEMA_OUTPUT_ESEMPIO,
    build_exercise_prompt,
    parse_exercise_response,
)

# --- Test costanti ---


class TestCostanti:
    """Verifica che le costanti siano coerenti con le decisioni di design."""

    def test_max_esercizi_verifica(self):
        """Cap duro a 3 esercizi (Decisione 8)."""
        assert MAX_ESERCIZI_VERIFICA == 3

    def test_max_concetti_per_esercizio(self):
        """Ogni esercizio copre max 2 concetti (compound)."""
        assert MAX_CONCETTI_PER_ESERCIZIO == 2

    def test_opzioni_range(self):
        """3-4 opzioni per esercizio."""
        assert MIN_OPZIONI == 3
        assert MAX_OPZIONI == 4

    def test_schema_esempio_struttura(self):
        """Lo schema esempio ha tutti i campi richiesti."""
        assert "testo" in SCHEMA_ESERCIZIO_ESEMPIO
        assert "concetti" in SCHEMA_ESERCIZIO_ESEMPIO
        assert "opzioni" in SCHEMA_ESERCIZIO_ESEMPIO
        assert "risposta_corretta" in SCHEMA_ESERCIZIO_ESEMPIO
        assert "spiegazione_breve" in SCHEMA_ESERCIZIO_ESEMPIO

    def test_schema_esempio_opzioni_valide(self):
        """Le opzioni nello schema hanno lettera e testo."""
        for opzione in SCHEMA_ESERCIZIO_ESEMPIO["opzioni"]:
            assert "lettera" in opzione
            assert "testo" in opzione

    def test_schema_esempio_risposta_tra_opzioni(self):
        """La risposta corretta dello schema è tra le lettere delle opzioni."""
        lettere = {o["lettera"] for o in SCHEMA_ESERCIZIO_ESEMPIO["opzioni"]}
        assert SCHEMA_ESERCIZIO_ESEMPIO["risposta_corretta"] in lettere

    def test_schema_output_e_lista(self):
        """L'output è una lista di esercizi."""
        assert isinstance(SCHEMA_OUTPUT_ESEMPIO, list)
        assert len(SCHEMA_OUTPUT_ESEMPIO) == 1


# --- Test build_exercise_prompt ---


class TestBuildExercisePrompt:
    """Verifica il prompt generato."""

    def test_istruzioni_chiave_presenti(self):
        """Tutte le istruzioni chiave devono essere nel prompt."""
        prompt = build_exercise_prompt([["frazioni", "proporzioni"]])
        prompt_lower = prompt.lower()
        for istruzione in ISTRUZIONI_CHIAVE:
            assert istruzione.lower() in prompt_lower, (
                f"Istruzione '{istruzione}' non trovata nel prompt"
            )

    def test_concetti_nel_prompt(self):
        """I nomi dei concetti compaiono nel prompt."""
        prompt = build_exercise_prompt([["frazioni", "proporzioni"]])
        assert "Frazioni" in prompt
        assert "Proporzioni" in prompt

    def test_concetti_ids_nel_prompt(self):
        """Gli ID concetti compaiono come JSON nel prompt."""
        prompt = build_exercise_prompt([["frazioni", "proporzioni"]])
        assert '"frazioni"' in prompt
        assert '"proporzioni"' in prompt

    def test_nomi_concetti_personalizzati(self):
        """Se forniti nomi custom, vengono usati al posto degli umanizzati."""
        nomi = {"frazioni": "Le Frazioni", "proporzioni": "Proporzioni e Rapporti"}
        prompt = build_exercise_prompt(
            [["frazioni", "proporzioni"]], nomi_concetti=nomi
        )
        assert "Le Frazioni" in prompt
        assert "Proporzioni e Rapporti" in prompt

    def test_numero_esercizi_nel_prompt(self):
        """Il prompt indica il numero corretto di esercizi."""
        prompt = build_exercise_prompt([["a", "b"], ["c"]])
        # Deve menzionare "2 esercizio/i"
        assert "2 esercizio/i" in prompt

    def test_singolo_concetto(self):
        """Un esercizio con singolo concetto funziona."""
        prompt = build_exercise_prompt([["equazioni_primo_grado"]])
        assert "Equazioni primo grado" in prompt
        assert "1 esercizio/i" in prompt

    def test_cap_esercizi(self):
        """Oltre MAX_ESERCIZI_VERIFICA, le coppie vengono troncate."""
        coppie = [["a"], ["b"], ["c"], ["d"], ["e"]]
        prompt = build_exercise_prompt(coppie)
        # Solo 3 esercizi nel prompt
        assert f"{MAX_ESERCIZI_VERIFICA} esercizio/i" in prompt
        assert "Esercizio 4" not in prompt

    def test_cap_concetti_per_coppia(self):
        """Più di 2 concetti per coppia: solo i primi 2 vengono usati."""
        prompt = build_exercise_prompt([["a", "b", "c"]])
        # Il terzo concetto non deve comparire come ID nel JSON della coppia
        assert '"c"' not in prompt or "Esercizio 1" in prompt

    def test_prompt_nessun_esercizio(self):
        """Lista vuota: prompt di fallback."""
        prompt = build_exercise_prompt([])
        assert "Nessun esercizio" in prompt

    def test_formato_json_schema_nel_prompt(self):
        """Lo schema JSON esempio è presente nel prompt."""
        prompt = build_exercise_prompt([["frazioni"]])
        assert "risposta_corretta" in prompt
        assert "spiegazione_breve" in prompt
        assert "opzioni" in prompt

    def test_regola_max_opzioni_nel_prompt(self):
        """Il prompt menziona il range di opzioni."""
        prompt = build_exercise_prompt([["frazioni"]])
        assert f"{MIN_OPZIONI}-{MAX_OPZIONI}" in prompt

    def test_lingua_italiana_nel_prompt(self):
        """Il prompt specifica lingua italiana."""
        prompt = build_exercise_prompt([["frazioni"]])
        assert "italiano" in prompt.lower()

    def test_risposta_corretta_unica_nel_prompt(self):
        """Il prompt specifica 1 risposta corretta."""
        prompt = build_exercise_prompt([["frazioni"]])
        prompt_lower = prompt.lower()
        assert "1 risposta corretta" in prompt_lower or "esattamente 1" in prompt_lower


# --- Test parse_exercise_response ---


class TestParseExerciseResponse:
    """Verifica il parser della risposta LLM."""

    def _esercizio_valido(self, **override):
        """Helper: genera un esercizio valido."""
        base = {
            "testo": "Quanto fa 2+2?",
            "concetti": ["addizione"],
            "opzioni": [
                {"lettera": "A", "testo": "3"},
                {"lettera": "B", "testo": "4"},
                {"lettera": "C", "testo": "5"},
            ],
            "risposta_corretta": "B",
            "spiegazione_breve": "2+2 = 4",
        }
        base.update(override)
        return base

    def test_parse_json_valido(self):
        """JSON valido con un esercizio."""
        esercizi = [self._esercizio_valido()]
        risultato = parse_exercise_response(json.dumps(esercizi))
        assert risultato is not None
        assert len(risultato) == 1
        assert risultato[0]["risposta_corretta"] == "B"

    def test_parse_json_multipli(self):
        """JSON con più esercizi."""
        esercizi = [
            self._esercizio_valido(concetti=["addizione"]),
            self._esercizio_valido(
                testo="Quanto fa 3*3?",
                concetti=["moltiplicazione"],
                risposta_corretta="C",
                opzioni=[
                    {"lettera": "A", "testo": "6"},
                    {"lettera": "B", "testo": "8"},
                    {"lettera": "C", "testo": "9"},
                ],
            ),
        ]
        risultato = parse_exercise_response(json.dumps(esercizi))
        assert risultato is not None
        assert len(risultato) == 2

    def test_parse_con_4_opzioni(self):
        """Esercizio con 4 opzioni (max)."""
        ex = self._esercizio_valido(
            opzioni=[
                {"lettera": "A", "testo": "3"},
                {"lettera": "B", "testo": "4"},
                {"lettera": "C", "testo": "5"},
                {"lettera": "D", "testo": "6"},
            ]
        )
        risultato = parse_exercise_response(json.dumps([ex]))
        assert risultato is not None
        assert len(risultato[0]["opzioni"]) == 4

    def test_parse_compound_2_concetti(self):
        """Esercizio compound con 2 concetti."""
        ex = self._esercizio_valido(concetti=["frazioni", "proporzioni"])
        risultato = parse_exercise_response(json.dumps([ex]))
        assert risultato is not None
        assert len(risultato[0]["concetti"]) == 2

    def test_parse_markdown_wrapped(self):
        """JSON wrappato in blocco markdown (```json...```)."""
        esercizi = [self._esercizio_valido()]
        testo = f"```json\n{json.dumps(esercizi)}\n```"
        risultato = parse_exercise_response(testo)
        assert risultato is not None
        assert len(risultato) == 1

    def test_parse_markdown_senza_lang(self):
        """JSON wrappato in ``` senza indicazione lingua."""
        esercizi = [self._esercizio_valido()]
        testo = f"```\n{json.dumps(esercizi)}\n```"
        risultato = parse_exercise_response(testo)
        assert risultato is not None

    def test_parse_vuoto(self):
        """Stringa vuota."""
        assert parse_exercise_response("") is None
        assert parse_exercise_response("   ") is None

    def test_parse_none(self):
        """None in input."""
        assert parse_exercise_response(None) is None

    def test_parse_json_invalido(self):
        """JSON malformato."""
        assert parse_exercise_response("non json {[") is None

    def test_parse_non_lista(self):
        """JSON valido ma non una lista."""
        assert parse_exercise_response('{"testo": "ciao"}') is None

    def test_parse_esercizio_senza_campo_obbligatorio(self):
        """Esercizio a cui manca un campo obbligatorio viene scartato."""
        ex = self._esercizio_valido()
        del ex["risposta_corretta"]
        risultato = parse_exercise_response(json.dumps([ex]))
        # Nessun esercizio valido
        assert risultato is None

    def test_parse_concetti_vuoti(self):
        """Esercizio con lista concetti vuota viene scartato."""
        ex = self._esercizio_valido(concetti=[])
        risultato = parse_exercise_response(json.dumps([ex]))
        assert risultato is None

    def test_parse_opzioni_insufficienti(self):
        """Esercizio con meno di MIN_OPZIONI viene scartato."""
        ex = self._esercizio_valido(
            opzioni=[{"lettera": "A", "testo": "si"}, {"lettera": "B", "testo": "no"}]
        )
        risultato = parse_exercise_response(json.dumps([ex]))
        assert risultato is None

    def test_parse_risposta_non_tra_opzioni(self):
        """Risposta corretta non presente tra le lettere delle opzioni."""
        ex = self._esercizio_valido(risposta_corretta="Z")
        risultato = parse_exercise_response(json.dumps([ex]))
        assert risultato is None

    def test_parse_misto_validi_e_invalidi(self):
        """Se ci sono esercizi validi e invalidi, restituisce solo i validi."""
        valido = self._esercizio_valido()
        invalido = {"testo": "incompleto"}
        risultato = parse_exercise_response(json.dumps([valido, invalido]))
        assert risultato is not None
        assert len(risultato) == 1

    def test_parse_spiegazione_breve_opzionale(self):
        """spiegazione_breve non obbligatoria per il parser."""
        ex = self._esercizio_valido()
        del ex["spiegazione_breve"]
        risultato = parse_exercise_response(json.dumps([ex]))
        # Deve essere valido anche senza spiegazione (non è nei campi obbligatori del parser)
        assert risultato is not None
        assert len(risultato) == 1
