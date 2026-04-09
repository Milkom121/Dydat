"""Test per il prompt di auto-valutazione placement (B39.6.1).

Verifica: costanti, build_self_assessment_prompt, parse_autovalutazione,
seleziona_aree_da_grafo, istruzioni chiave presenti nel prompt.
"""

from app.llm.prompts.onboarding_self_assessment import (
    ISTRUZIONI_CHIAVE,
    LIVELLI_AUTOVALUTAZIONE,
    MAX_AREE_AUTOVALUTAZIONE,
    _umanizza_tema_id,
    build_self_assessment_prompt,
    parse_autovalutazione,
    seleziona_aree_da_grafo,
)

# --- Fixture ---

AREE_ESEMPIO = [
    {"id": "frazioni", "nome": "Frazioni"},
    {"id": "potenze_radici", "nome": "Potenze e radici"},
    {"id": "equazioni_primo_grado", "nome": "Equazioni di primo grado"},
    {"id": "geometria_base", "nome": "Geometria di base"},
    {"id": "percentuali_proporzioni", "nome": "Percentuali e proporzioni"},
]


# --- Test costanti ---


class TestCostanti:
    def test_livelli_autovalutazione_sono_tre(self):
        assert len(LIVELLI_AUTOVALUTAZIONE) == 3

    def test_livelli_contengono_forte_incerto_digiuno(self):
        assert "forte" in LIVELLI_AUTOVALUTAZIONE
        assert "incerto" in LIVELLI_AUTOVALUTAZIONE
        assert "digiuno" in LIVELLI_AUTOVALUTAZIONE

    def test_max_aree_ragionevole(self):
        assert 5 <= MAX_AREE_AUTOVALUTAZIONE <= 15

    def test_istruzioni_chiave_non_vuote(self):
        assert len(ISTRUZIONI_CHIAVE) >= 3


# --- Test build_self_assessment_prompt ---


class TestBuildPrompt:
    def test_prompt_contiene_tutte_le_aree(self):
        prompt = build_self_assessment_prompt(AREE_ESEMPIO)
        for area in AREE_ESEMPIO:
            assert area["nome"] in prompt

    def test_prompt_contiene_istruzioni_chiave(self):
        """Verifica che tutte le istruzioni chiave siano presenti nel prompt."""
        prompt = build_self_assessment_prompt(AREE_ESEMPIO)
        for istruzione in ISTRUZIONI_CHIAVE:
            assert istruzione.lower() in prompt.lower(), (
                f"Istruzione chiave mancante nel prompt: '{istruzione}'"
            )

    def test_prompt_contiene_livelli(self):
        prompt = build_self_assessment_prompt(AREE_ESEMPIO)
        for livello in LIVELLI_AUTOVALUTAZIONE:
            assert livello in prompt

    def test_prompt_contiene_area_ids(self):
        prompt = build_self_assessment_prompt(AREE_ESEMPIO)
        for area in AREE_ESEMPIO:
            assert area["id"] in prompt

    def test_prompt_con_nome_utente(self):
        prompt = build_self_assessment_prompt(AREE_ESEMPIO, nome_utente="Marco")
        assert "Marco" in prompt

    def test_prompt_senza_nome_utente(self):
        prompt = build_self_assessment_prompt(AREE_ESEMPIO, nome_utente=None)
        # Non deve esplodere, il prompt è valido
        assert "FASE AUTO-VALUTAZIONE" in prompt

    def test_prompt_contiene_marker_autovalutazione(self):
        """Il prompt deve istruire il tutor a emettere il blocco strutturato."""
        prompt = build_self_assessment_prompt(AREE_ESEMPIO)
        assert "[AUTOVALUTAZIONE]" in prompt
        assert "[/AUTOVALUTAZIONE]" in prompt

    def test_prompt_lista_vuota_fallback(self):
        prompt = build_self_assessment_prompt([])
        assert "Non ci sono aree" in prompt
        assert "fase successiva" in prompt

    def test_prompt_tronca_aree_eccessive(self):
        """Se ci sono più aree del massimo, vengono troncate."""
        troppe_aree = [
            {"id": f"area_{i}", "nome": f"Area {i}"}
            for i in range(20)
        ]
        prompt = build_self_assessment_prompt(troppe_aree)
        # Le prime MAX dovrebbero esserci
        assert "Area 0" in prompt
        assert f"Area {MAX_AREE_AUTOVALUTAZIONE - 1}" in prompt
        # Quelle oltre il max non dovrebbero esserci
        assert "Area 15" not in prompt

    def test_prompt_non_contiene_parole_esame(self):
        """Il tono non deve sembrare un esame."""
        prompt = build_self_assessment_prompt(AREE_ESEMPIO)
        assert "NON è un test" in prompt

    def test_prompt_istruisce_raggruppamento(self):
        """Il tutor deve raggruppare 2-3 aree per messaggio."""
        prompt = build_self_assessment_prompt(AREE_ESEMPIO)
        assert "2-3" in prompt


# --- Test parse_autovalutazione ---


class TestParseAutovalutazione:
    def test_parse_blocco_completo(self):
        testo = """Bene Marco, ecco il quadro che ho:

[AUTOVALUTAZIONE]
frazioni: incerto
potenze_radici: forte
equazioni_primo_grado: digiuno
geometria_base: forte
percentuali_proporzioni: incerto
[/AUTOVALUTAZIONE]

Ora verifico le aree dove ti senti forte."""

        risultato = parse_autovalutazione(testo)
        assert risultato == {
            "frazioni": "incerto",
            "potenze_radici": "forte",
            "equazioni_primo_grado": "digiuno",
            "geometria_base": "forte",
            "percentuali_proporzioni": "incerto",
        }

    def test_parse_senza_blocco(self):
        risultato = parse_autovalutazione("Ciao, come stai?")
        assert risultato == {}

    def test_parse_blocco_vuoto(self):
        testo = "[AUTOVALUTAZIONE]\n[/AUTOVALUTAZIONE]"
        risultato = parse_autovalutazione(testo)
        assert risultato == {}

    def test_parse_ignora_livelli_invalidi(self):
        testo = """[AUTOVALUTAZIONE]
frazioni: forte
potenze: benino
equazioni: digiuno
[/AUTOVALUTAZIONE]"""
        risultato = parse_autovalutazione(testo)
        assert risultato == {"frazioni": "forte", "equazioni": "digiuno"}
        assert "potenze" not in risultato

    def test_parse_case_insensitive_livelli(self):
        testo = """[AUTOVALUTAZIONE]
frazioni: FORTE
potenze: Incerto
[/AUTOVALUTAZIONE]"""
        risultato = parse_autovalutazione(testo)
        assert risultato == {"frazioni": "forte", "potenze": "incerto"}

    def test_parse_ignora_righe_senza_due_punti(self):
        testo = """[AUTOVALUTAZIONE]
frazioni: forte
questa riga non ha i due punti
equazioni: digiuno
[/AUTOVALUTAZIONE]"""
        risultato = parse_autovalutazione(testo)
        assert len(risultato) == 2

    def test_parse_spazi_extra(self):
        testo = """[AUTOVALUTAZIONE]
  frazioni  :  forte
  potenze  :  incerto
[/AUTOVALUTAZIONE]"""
        risultato = parse_autovalutazione(testo)
        assert risultato == {"frazioni": "forte", "potenze": "incerto"}

    def test_parse_marker_fine_mancante(self):
        testo = """[AUTOVALUTAZIONE]
frazioni: forte
potenze: incerto"""
        risultato = parse_autovalutazione(testo)
        assert risultato == {}

    def test_parse_testo_vuoto(self):
        assert parse_autovalutazione("") == {}


# --- Test seleziona_aree_da_grafo ---


class TestSelezionaAreeDaGrafo:
    def test_estrae_temi_unici(self):
        nodi = [
            {"tema_id": "frazioni", "tema_nome": "Frazioni"},
            {"tema_id": "frazioni", "tema_nome": "Frazioni"},
            {"tema_id": "potenze", "tema_nome": "Potenze"},
        ]
        aree = seleziona_aree_da_grafo(nodi)
        ids = [a["id"] for a in aree]
        assert len(ids) == 2
        assert "frazioni" in ids
        assert "potenze" in ids

    def test_ordina_per_numero_nodi(self):
        """Temi con più nodi vengono prima (più importanti nel curriculum)."""
        nodi = [
            {"tema_id": "piccolo", "tema_nome": "Piccolo"},
            {"tema_id": "grande", "tema_nome": "Grande"},
            {"tema_id": "grande", "tema_nome": "Grande"},
            {"tema_id": "grande", "tema_nome": "Grande"},
            {"tema_id": "medio", "tema_nome": "Medio"},
            {"tema_id": "medio", "tema_nome": "Medio"},
        ]
        aree = seleziona_aree_da_grafo(nodi)
        assert aree[0]["id"] == "grande"
        assert aree[1]["id"] == "medio"
        assert aree[2]["id"] == "piccolo"

    def test_limita_a_max(self):
        nodi = [
            {"tema_id": f"tema_{i}", "tema_nome": f"Tema {i}"}
            for i in range(25)
        ]
        aree = seleziona_aree_da_grafo(nodi)
        assert len(aree) <= MAX_AREE_AUTOVALUTAZIONE

    def test_lista_vuota(self):
        assert seleziona_aree_da_grafo([]) == []

    def test_nodi_senza_tema_ignorati(self):
        nodi = [
            {"tema_id": None, "tema_nome": None},
            {"tema_id": "frazioni", "tema_nome": "Frazioni"},
        ]
        aree = seleziona_aree_da_grafo(nodi)
        assert len(aree) == 1
        assert aree[0]["id"] == "frazioni"

    def test_fallback_umanizzazione_nome(self):
        """Se tema_nome mancante, umanizza il tema_id."""
        nodi = [
            {"tema_id": "equazioni_secondo_grado", "tema_nome": None},
        ]
        aree = seleziona_aree_da_grafo(nodi)
        assert aree[0]["nome"] == "Equazioni secondo grado"

    def test_formato_output(self):
        nodi = [{"tema_id": "frazioni", "tema_nome": "Frazioni"}]
        aree = seleziona_aree_da_grafo(nodi)
        assert len(aree) == 1
        assert "id" in aree[0]
        assert "nome" in aree[0]
        assert aree[0]["id"] == "frazioni"
        assert aree[0]["nome"] == "Frazioni"


# --- Test _umanizza_tema_id ---


class TestUmanizzaTemaId:
    def test_underscore_a_spazi(self):
        assert _umanizza_tema_id("equazioni_primo_grado") == "Equazioni primo grado"

    def test_singola_parola(self):
        assert _umanizza_tema_id("frazioni") == "Frazioni"

    def test_gia_capitalizzato(self):
        assert _umanizza_tema_id("Frazioni") == "Frazioni"
