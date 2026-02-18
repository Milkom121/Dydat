"""Test Blocco 6 — Context builder, direttive, troncamento conversazione."""

from __future__ import annotations

from app.core.contesto import (
    SOGLIA_TURNI,
    TURNI_FINALI,
    TURNI_INIZIALI,
    ContextPackage,
    _blocco_contesto_attivo,
    _blocco_direttiva,
    _blocco_memoria,
    _blocco_profilo_utente,
    _blocco_system_prompt,
    tronca_conversazione,
)
from app.llm.prompts.direttive import (
    direttiva_esercizio,
    direttiva_feynman,
    direttiva_onboarding,
    direttiva_ripasso_sr,
    direttiva_ripresa_sessione,
    direttiva_spiegazione,
)
from app.llm.prompts.system_prompt import SYSTEM_PROMPT

# ===================================================================
# Test: troncamento conversazione
# ===================================================================


class TestTroncaConversazione:
    def test_no_troncamento_sotto_soglia(self):
        messages = [{"role": "user", "content": f"msg {i}"} for i in range(30)]
        result = tronca_conversazione(messages)
        assert result == messages

    def test_no_troncamento_a_soglia(self):
        messages = [{"role": "user", "content": f"msg {i}"} for i in range(SOGLIA_TURNI)]
        result = tronca_conversazione(messages)
        assert result == messages

    def test_troncamento_sopra_soglia(self):
        n = 80
        messages = [{"role": "user", "content": f"msg {i}"} for i in range(n)]
        result = tronca_conversazione(messages)

        # Lunghezza: iniziali + raccordo + finali
        assert len(result) == TURNI_INIZIALI + 1 + TURNI_FINALI

        # Primi 2 preservati
        assert result[0]["content"] == "msg 0"
        assert result[1]["content"] == "msg 1"

        # Raccordo
        raccordo = result[TURNI_INIZIALI]
        omessi = n - TURNI_INIZIALI - TURNI_FINALI
        assert str(omessi) in raccordo["content"]
        assert "omessi" in raccordo["content"]

        # Ultimi 20 preservati
        assert result[-1]["content"] == f"msg {n - 1}"
        assert result[-TURNI_FINALI]["content"] == f"msg {n - TURNI_FINALI}"

    def test_troncamento_lista_vuota(self):
        assert tronca_conversazione([]) == []

    def test_troncamento_un_elemento(self):
        messages = [{"role": "user", "content": "solo"}]
        assert tronca_conversazione(messages) == messages


# ===================================================================
# Test: blocchi XML
# ===================================================================


class TestBlocchiXML:
    def test_blocco_system_prompt(self):
        result = _blocco_system_prompt()
        assert "<system_prompt>" in result
        assert "</system_prompt>" in result
        assert "tutor personale di Dydat" in result

    def test_blocco_direttiva(self):
        result = _blocco_direttiva("ATTIVITÀ: Test\nISTRUZIONI: fai qualcosa")
        assert "<direttiva>" in result
        assert "</direttiva>" in result
        assert "ATTIVITÀ: Test" in result

    def test_blocco_profilo_utente_con_dati(self):
        class FakeUtente:
            preferenze_tutor = {"stile": "informale"}
            contesto_personale = {"occupazione": "studente"}
            profilo_sintetizzato = None

        result = _blocco_profilo_utente(FakeUtente())
        assert "<profilo_utente>" in result
        assert "</profilo_utente>" in result
        assert "informale" in result
        assert "studente" in result

    def test_blocco_profilo_utente_vuoto(self):
        class FakeUtente:
            preferenze_tutor = None
            contesto_personale = None
            profilo_sintetizzato = None

        result = _blocco_profilo_utente(FakeUtente())
        assert "nessuna informazione" in result

    def test_blocco_memoria_placeholder(self):
        result = _blocco_memoria()
        assert "<memoria_rilevante>" in result
        assert "</memoria_rilevante>" in result

    def test_blocco_contesto_attivo(self):
        class FakeNodo:
            id = "nodo_test_1"
            nome = "Equazioni di primo grado"
            definizioni_formali = {"def": "un'equazione è..."}
            formule_proprieta = [{"formula": "ax + b = 0"}]
            errori_comuni = [{"tipo": "segno", "descrizione": "errore di segno"}]
            esempi_applicazione = [{"esempio": "2x + 3 = 7"}]

        class FakeEsercizio:
            id = "es_001"
            difficolta = 2
            testo = "Risolvi 3x + 1 = 10"

        esercizi = [FakeEsercizio()]
        storico_errori = [{"esito": "non_risolto", "tipo_errore": "segno", "data": "2026-02-17"}]
        nodi_supporto = {
            "prereq_1": {"livello": "operativo", "esercizi_completati": 3, "errori_in_corso": 0}
        }

        result = _blocco_contesto_attivo(FakeNodo(), esercizi, storico_errori, nodi_supporto)

        assert "<contesto_attivo>" in result
        assert "<nodo_focale>" in result
        assert "</nodo_focale>" in result
        assert "<nodi_supporto>" in result
        assert "nodo_test_1" in result
        assert "Equazioni di primo grado" in result
        assert "es_001" in result
        assert "prereq_1" in result
        assert "operativo" in result

    def test_blocco_contesto_attivo_senza_supporto(self):
        class FakeNodo:
            id = "nodo_solo"
            nome = "Nodo senza prerequisiti"
            definizioni_formali = None
            formule_proprieta = None
            errori_comuni = None
            esempi_applicazione = None

        result = _blocco_contesto_attivo(FakeNodo(), [], [], {})
        assert "nessun prerequisito" in result


# ===================================================================
# Test: direttive
# ===================================================================


class TestDirettive:
    def test_direttiva_spiegazione(self):
        result = direttiva_spiegazione(
            nodo_nome="Equazioni di secondo grado",
            nodo_id="eq_2_grado",
            prerequisiti_completati=["eq_1_grado"],
            livello_materia="intermedio",
            definizioni_formali={"def": "ax^2 + bx + c = 0"},
            formule_proprieta=[{"formula": "discriminante"}],
            errori_comuni=[{"tipo": "segno"}],
            stile_cognitivo="visivo",
            esempi_preferiti="vita reale",
            minuti_rimasti=25,
        )
        assert "ATTIVITÀ: Spiegazione" in result
        assert "eq_2_grado" in result
        assert "eq_1_grado" in result
        assert "Concreto → Problema → Formale" in result
        assert "25 minuti" in result

    def test_direttiva_spiegazione_senza_tempo(self):
        result = direttiva_spiegazione(
            nodo_nome="Test",
            nodo_id="test_id",
            prerequisiti_completati=[],
            livello_materia="base",
            definizioni_formali=None,
            formule_proprieta=None,
            errori_comuni=None,
        )
        assert "TEMPO RIMASTO" not in result

    def test_direttiva_esercizio(self):
        result = direttiva_esercizio(
            nodo_nome="Equazioni",
            esercizio_testo="Risolvi 2x + 3 = 7",
            soluzione={"risposta_finale": "x = 2", "passaggi": ["2x = 4", "x = 2"]},
            numero_tentativo=2,
            tentativi_bc=1,
        )
        assert "ATTIVITÀ: Esercizio" in result
        assert "Risolvi 2x + 3 = 7" in result
        assert "x = 2" in result
        assert "B+C" in result

    def test_direttiva_esercizio_senza_soluzione(self):
        result = direttiva_esercizio(
            nodo_nome="Test",
            esercizio_testo="Esercizio senza soluzione",
        )
        assert "non disponibile" in result
        assert "Risolvi tu" in result

    def test_direttiva_onboarding_accoglienza(self):
        result = direttiva_onboarding(fase="accoglienza")
        assert "Onboarding" in result
        assert "accoglienza" in result
        assert "Presentati" in result

    def test_direttiva_onboarding_conoscenza(self):
        result = direttiva_onboarding(fase="conoscenza")
        assert "conoscenza" in result
        assert "punto_partenza_suggerito" in result

    def test_direttiva_onboarding_conclusione(self):
        result = direttiva_onboarding(fase="conclusione", info_raccolte="studente 20 anni, esame")
        assert "conclusione" in result
        assert "studente 20 anni" in result

    def test_direttiva_ripresa(self):
        result = direttiva_ripresa_sessione(
            nodo_nome="Equazioni",
            attivita_precedente="esercizio",
            dettaglio="Stava risolvendo un esercizio di tipo intermedio.",
        )
        assert "Ripresa sessione" in result
        assert "Bentornato" in result
        assert "Equazioni" in result

    def test_direttiva_feynman(self):
        result = direttiva_feynman(
            nodo_nome="Frazioni",
            fase_feynman="invito",
            punti_chiave=["definizione", "operazioni", "proprietà"],
        )
        assert "Feynman" in result
        assert "invito" in result
        assert "definizione" in result

    def test_direttiva_ripasso_sr(self):
        result = direttiva_ripasso_sr(
            concetti_scadenza=["frazioni", "equazioni"],
            ordine_ottimale=["equazioni", "frazioni"],
        )
        assert "Ripasso Spaced Repetition" in result
        assert "frazioni" in result
        assert "Interleaving" in result


# ===================================================================
# Test: ContextPackage
# ===================================================================


class TestContextPackage:
    def test_context_package_creation(self):
        pkg = ContextPackage(
            system="<system_prompt>test</system_prompt>",
            messages=[{"role": "user", "content": "ciao"}],
            modello="claude-sonnet-4-5-20250929",
        )
        assert "test" in pkg.system
        assert len(pkg.messages) == 1
        assert pkg.modello == "claude-sonnet-4-5-20250929"


# ===================================================================
# Test: system prompt content
# ===================================================================


class TestSystemPrompt:
    def test_system_prompt_non_vuoto(self):
        assert len(SYSTEM_PROMPT) > 100

    def test_system_prompt_contiene_sezioni_chiave(self):
        assert "CHI SEI" in SYSTEM_PROMPT
        assert "METODO DIDATTICO" in SYSTEM_PROMPT
        assert "B+C" in SYSTEM_PROMPT
        assert "Feynman" in SYSTEM_PROMPT
        assert "REGOLE" in SYSTEM_PROMPT
        assert "TOOLKIT" in SYSTEM_PROMPT
        assert "proponi_esercizio" in SYSTEM_PROMPT

    def test_system_prompt_non_contiene_placeholder(self):
        assert "PLACEHOLDER" not in SYSTEM_PROMPT
        # "TODO" come marker standalone (non in parole come "METODO")
        import re
        assert not re.search(r"\bTODO\b", SYSTEM_PROMPT)
