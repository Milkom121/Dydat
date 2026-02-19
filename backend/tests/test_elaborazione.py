"""Test Blocco 7 — Elaborazione: Action Executor, Signal Processor, promozione.

Test critici di dominio:
- Promozione in_corso → operativo (3 condizioni)
- Cascata sblocco post-promozione
- Signal processing (concetto_spiegato, risposta_esercizio)
- Action Executor (proponi_esercizio, mostra_formula)
- Conversation Manager (salva_turno, carica_conversazione)
- Turno coordinatore (3 fasi)
"""

from __future__ import annotations

from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.core.elaborazione import (
    DIFFICOLTA_MAPPING,
    ESERCIZI_PER_PROMOZIONE,
    _verifica_promozione,
)

# ===================================================================
# Test: mapping difficoltà
# ===================================================================


class TestMappingDifficolta:
    def test_base_mappa_1_2(self):
        assert DIFFICOLTA_MAPPING["base"] == (1, 2)

    def test_intermedio_mappa_3(self):
        assert DIFFICOLTA_MAPPING["intermedio"] == (3, 3)

    def test_avanzato_mappa_4_5(self):
        assert DIFFICOLTA_MAPPING["avanzato"] == (4, 5)

    def test_esercizi_per_promozione(self):
        assert ESERCIZI_PER_PROMOZIONE == 3


# ===================================================================
# Test: logica di promozione (regole pure)
# ===================================================================


class TestLogicaPromozione:
    """Test delle condizioni di promozione in_corso → operativo.

    Tre condizioni devono essere TUTTE vere:
    1. spiegazione_data = true
    2. esercizi_completati >= 3
    3. almeno 1 esercizio con esito='primo_tentativo'
    """

    @pytest.mark.asyncio
    async def test_promozione_tutte_condizioni_soddisfatte(self):
        """Con tutte le condizioni soddisfatte, promozione avviene."""
        # Mock stato nodo
        stato_mock = MagicMock()
        stato_mock.livello = "in_corso"
        stato_mock.spiegazione_data = True
        stato_mock.esercizi_completati = 3
        stato_mock.ultima_interazione = None

        # Mock DB
        db = AsyncMock()
        # Prima query: stato nodo
        result_stato = MagicMock()
        result_stato.scalar_one_or_none.return_value = stato_mock
        # Seconda query: count primo_tentativo
        result_pt = MagicMock()
        result_pt.scalar_one.return_value = 2  # 2 primi tentativi

        db.execute = AsyncMock(side_effect=[result_stato, result_pt])
        db.flush = AsyncMock()

        import uuid

        result = await _verifica_promozione(db, uuid.uuid4(), "nodo_test")

        assert result is not None
        assert result["nodo_id"] == "nodo_test"
        assert result["nuovo_livello"] == "operativo"
        assert stato_mock.livello == "operativo"

    @pytest.mark.asyncio
    async def test_no_promozione_senza_spiegazione(self):
        """Senza spiegazione, no promozione."""
        stato_mock = MagicMock()
        stato_mock.livello = "in_corso"
        stato_mock.spiegazione_data = False
        stato_mock.esercizi_completati = 5

        db = AsyncMock()
        result_stato = MagicMock()
        result_stato.scalar_one_or_none.return_value = stato_mock
        db.execute = AsyncMock(return_value=result_stato)

        import uuid

        result = await _verifica_promozione(db, uuid.uuid4(), "nodo_test")
        assert result is None

    @pytest.mark.asyncio
    async def test_no_promozione_pochi_esercizi(self):
        """Con meno di 3 esercizi, no promozione."""
        stato_mock = MagicMock()
        stato_mock.livello = "in_corso"
        stato_mock.spiegazione_data = True
        stato_mock.esercizi_completati = 2

        db = AsyncMock()
        result_stato = MagicMock()
        result_stato.scalar_one_or_none.return_value = stato_mock
        db.execute = AsyncMock(return_value=result_stato)

        import uuid

        result = await _verifica_promozione(db, uuid.uuid4(), "nodo_test")
        assert result is None

    @pytest.mark.asyncio
    async def test_no_promozione_senza_primo_tentativo(self):
        """Senza nessun primo_tentativo, no promozione."""
        stato_mock = MagicMock()
        stato_mock.livello = "in_corso"
        stato_mock.spiegazione_data = True
        stato_mock.esercizi_completati = 5

        db = AsyncMock()
        result_stato = MagicMock()
        result_stato.scalar_one_or_none.return_value = stato_mock
        result_pt = MagicMock()
        result_pt.scalar_one.return_value = 0  # zero primi tentativi

        db.execute = AsyncMock(side_effect=[result_stato, result_pt])

        import uuid

        result = await _verifica_promozione(db, uuid.uuid4(), "nodo_test")
        assert result is None

    @pytest.mark.asyncio
    async def test_no_promozione_gia_operativo(self):
        """Un nodo già operativo non viene promosso di nuovo."""
        stato_mock = MagicMock()
        stato_mock.livello = "operativo"

        db = AsyncMock()
        result_stato = MagicMock()
        result_stato.scalar_one_or_none.return_value = stato_mock
        db.execute = AsyncMock(return_value=result_stato)

        import uuid

        result = await _verifica_promozione(db, uuid.uuid4(), "nodo_test")
        assert result is None

    @pytest.mark.asyncio
    async def test_no_promozione_nodo_inesistente(self):
        """Nodo senza stato nel DB non viene promosso."""
        db = AsyncMock()
        result_stato = MagicMock()
        result_stato.scalar_one_or_none.return_value = None
        db.execute = AsyncMock(return_value=result_stato)

        import uuid

        result = await _verifica_promozione(db, uuid.uuid4(), "nodo_fantasma")
        assert result is None


# ===================================================================
# Test: cascata sblocco con grafo reale
# ===================================================================


class TestCascataSbloccoPromozione:
    """Test cascata sblocco usando l'algoritmo reale del grafo."""

    def test_cascata_con_grafo_mock(self):
        """Verifica che nodi_sbloccati_dopo_promozione funziona."""
        import networkx as nx

        from app.grafo.algoritmi import nodi_sbloccati_dopo_promozione

        g = nx.DiGraph()
        g.add_node("A", tipo_nodo="operativo", tipo="standard", materia="mat")
        g.add_node("B", tipo_nodo="operativo", tipo="standard", materia="mat")
        g.add_node("C", tipo_nodo="operativo", tipo="standard", materia="mat")
        g.add_edge("A", "B", dipendenza="bloccante")
        g.add_edge("B", "C", dipendenza="bloccante")

        # Promozione di A: B si sblocca
        livelli = {"A": "operativo"}
        sbloccati = nodi_sbloccati_dopo_promozione(g, "A", livelli)
        assert "B" in sbloccati

    def test_cascata_non_sblocca_se_manca_prerequisito(self):
        """C non si sblocca se B non è operativo."""
        import networkx as nx

        from app.grafo.algoritmi import nodi_sbloccati_dopo_promozione

        g = nx.DiGraph()
        g.add_node("A", tipo_nodo="operativo", tipo="standard", materia="mat")
        g.add_node("B", tipo_nodo="operativo", tipo="standard", materia="mat")
        g.add_node("C", tipo_nodo="operativo", tipo="standard", materia="mat")
        g.add_edge("A", "C", dipendenza="bloccante")
        g.add_edge("B", "C", dipendenza="bloccante")

        # Promozione di A: C non si sblocca perché B non è operativo
        livelli = {"A": "operativo"}
        sbloccati = nodi_sbloccati_dopo_promozione(g, "A", livelli)
        assert "C" not in sbloccati

    def test_cascata_sblocca_con_tutti_prerequisiti(self):
        """C si sblocca quando A e B sono entrambi operativi."""
        import networkx as nx

        from app.grafo.algoritmi import nodi_sbloccati_dopo_promozione

        g = nx.DiGraph()
        g.add_node("A", tipo_nodo="operativo", tipo="standard", materia="mat")
        g.add_node("B", tipo_nodo="operativo", tipo="standard", materia="mat")
        g.add_node("C", tipo_nodo="operativo", tipo="standard", materia="mat")
        g.add_edge("A", "C", dipendenza="bloccante")
        g.add_edge("B", "C", dipendenza="bloccante")

        # Promozione di B (A già operativo): C si sblocca
        livelli = {"A": "operativo", "B": "operativo"}
        sbloccati = nodi_sbloccati_dopo_promozione(g, "B", livelli)
        assert "C" in sbloccati


# ===================================================================
# Test: turno coordinatore (flusso 3 fasi)
# ===================================================================


class TestTurnoCoordinatore:
    """Test del flusso del turno con mock LLM."""

    @pytest.mark.asyncio
    async def test_turno_text_only(self):
        """Turno con solo testo, senza tool use."""
        from dataclasses import dataclass

        from app.core.turno import esegui_turno

        @dataclass
        class FakeRisultato:
            testo_completo: str = "Ciao studente!"
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
            tipo_sessione: str = "studio"

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
                    "nodo_focale_id": "nodo_test"
                }

        # Mock delle dipendenze

        async def fake_chiama_tutor(**kwargs):
            yield {"tipo": "text_delta", "testo": "Ciao "}
            yield {"tipo": "text_delta", "testo": "studente!"}
            yield {"tipo": "stop", "risultato": FakeRisultato()}

        db = AsyncMock()
        # Mock per salva_turno (2 chiamate: utente + assistente)
        # Mock per commit, refresh
        db.commit = AsyncMock()
        db.refresh = AsyncMock()

        # Mock per query Sessione nel post-processing
        sess_result = MagicMock()
        sess_result.scalar_one_or_none.return_value = FakeSessione()
        db.execute = AsyncMock(return_value=sess_result)

        import uuid

        with (
            patch(
                "app.core.turno.assembla_context_package",
                return_value=FakeContextPackage(),
            ),
            patch(
                "app.core.turno.chiama_tutor",
                side_effect=fake_chiama_tutor,
            ),
            patch(
                "app.core.turno.salva_turno",
                return_value=FakeTurno(),
            ),
            patch(
                "app.core.turno.processa_segnali",
                return_value=[],
            ),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="ciao",
            ):
                eventi.append(ev)

        # Verifiche
        text_deltas = [
            e for e in eventi if e.get("event") == "text_delta"
        ]
        assert len(text_deltas) == 2
        assert text_deltas[0]["data"]["testo"] == "Ciao "

        turno_completo = [
            e for e in eventi if e.get("event") == "turno_completo"
        ]
        assert len(turno_completo) == 1
        assert turno_completo[0]["data"]["nodo_focale"] == "nodo_test"

        # Nessun errore
        errori = [e for e in eventi if e.get("event") == "errore"]
        assert len(errori) == 0

    @pytest.mark.asyncio
    async def test_turno_con_azione_e_segnale(self):
        """Turno con testo + azione + segnale."""
        from dataclasses import dataclass

        from app.core.turno import esegui_turno

        @dataclass
        class FakeRisultato:
            testo_completo: str = "Proviamo un esercizio."
            azioni: list = None
            segnali: list = None
            token_input: int = 200
            token_output: int = 100
            costo_stimato: float = 0.002
            modello: str = "test-model"
            stop_reason: str = "tool_use"

            def __post_init__(self):
                self.azioni = self.azioni or []
                self.segnali = self.segnali or []

        @dataclass
        class FakeContextPackage:
            system: str = "test"
            messages: list = None
            modello: str = "test-model"
            tipo_sessione: str = "studio"

            def __post_init__(self):
                self.messages = self.messages or []

        @dataclass
        class FakeTurno:
            id: int = 2

        @dataclass
        class FakeSessione:
            stato_orchestratore: dict = None

            def __post_init__(self):
                self.stato_orchestratore = {"nodo_focale_id": "nodo_x"}

        async def fake_chiama_tutor(**kwargs):
            yield {"tipo": "text_delta", "testo": "Proviamo un esercizio."}
            yield {
                "tipo": "tool_use",
                "name": "proponi_esercizio",
                "input": {"nodo_id": "nodo_x", "difficolta": "base"},
                "categoria": "azione",
            }
            yield {
                "tipo": "tool_use",
                "name": "concetto_spiegato",
                "input": {
                    "nodo_id": "nodo_x",
                    "punti_coperti": ["definizione"],
                },
                "categoria": "segnale",
            }
            yield {"tipo": "stop", "risultato": FakeRisultato()}

        db = AsyncMock()
        db.commit = AsyncMock()
        db.refresh = AsyncMock()
        sess_result = MagicMock()
        sess_result.scalar_one_or_none.return_value = FakeSessione()
        db.execute = AsyncMock(return_value=sess_result)

        azione_result = {
            "tipo": "proponi_esercizio",
            "params": {
                "esercizio_id": "ex_1",
                "testo": "Risolvi...",
                "difficolta": 1,
                "nodo_id": "nodo_x",
            },
        }

        import uuid

        with (
            patch(
                "app.core.turno.assembla_context_package",
                return_value=FakeContextPackage(),
            ),
            patch(
                "app.core.turno.chiama_tutor",
                side_effect=fake_chiama_tutor,
            ),
            patch(
                "app.core.turno.salva_turno",
                return_value=FakeTurno(),
            ),
            patch(
                "app.core.turno.esegui_azione",
                return_value=azione_result,
            ),
            patch(
                "app.core.turno.processa_segnali",
                return_value=[],
            ),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="ok",
            ):
                eventi.append(ev)

        azioni = [e for e in eventi if e.get("event") == "azione"]
        assert len(azioni) == 1
        assert azioni[0]["data"]["tipo"] == "proponi_esercizio"

    @pytest.mark.asyncio
    async def test_turno_errore_llm(self):
        """Turno che fallisce con errore LLM."""
        from dataclasses import dataclass

        from app.core.turno import esegui_turno

        @dataclass
        class FakeContextPackage:
            system: str = "test"
            messages: list = None
            modello: str = "test-model"
            tipo_sessione: str = "studio"

            def __post_init__(self):
                self.messages = self.messages or []

        async def fake_chiama_errore(**kwargs):
            yield {"tipo": "errore", "messaggio": "Timeout dopo 60s"}

        db = AsyncMock()
        db.commit = AsyncMock()

        import uuid

        with (
            patch(
                "app.core.turno.assembla_context_package",
                return_value=FakeContextPackage(),
            ),
            patch(
                "app.core.turno.chiama_tutor",
                side_effect=fake_chiama_errore,
            ),
            patch("app.core.turno.salva_turno", return_value=MagicMock(id=1)),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="ciao",
            ):
                eventi.append(ev)

        errori = [e for e in eventi if e.get("event") == "errore"]
        assert len(errori) == 1
        assert "Timeout" in errori[0]["data"]["messaggio"]

    @pytest.mark.asyncio
    async def test_turno_primo_senza_messaggio_utente(self):
        """Primo turno automatico (senza messaggio utente)."""
        from dataclasses import dataclass

        from app.core.turno import esegui_turno

        @dataclass
        class FakeRisultato:
            testo_completo: str = "Benvenuto!"
            azioni: list = None
            segnali: list = None
            token_input: int = 100
            token_output: int = 30
            costo_stimato: float = 0.0005
            modello: str = "test-model"
            stop_reason: str = "end_turn"

            def __post_init__(self):
                self.azioni = self.azioni or []
                self.segnali = self.segnali or []

        @dataclass
        class FakeContextPackage:
            system: str = "test"
            messages: list = None
            modello: str = "test-model"
            tipo_sessione: str = "studio"

            def __post_init__(self):
                self.messages = self.messages or []

        @dataclass
        class FakeSessione:
            stato_orchestratore: dict = None

            def __post_init__(self):
                self.stato_orchestratore = {"nodo_focale_id": None}

        async def fake_chiama_tutor(**kwargs):
            yield {"tipo": "text_delta", "testo": "Benvenuto!"}
            yield {"tipo": "stop", "risultato": FakeRisultato()}

        db = AsyncMock()
        db.commit = AsyncMock()
        db.refresh = AsyncMock()
        sess_result = MagicMock()
        sess_result.scalar_one_or_none.return_value = FakeSessione()
        db.execute = AsyncMock(return_value=sess_result)

        salva_turno_mock = AsyncMock(return_value=MagicMock(id=1))

        import uuid

        with (
            patch(
                "app.core.turno.assembla_context_package",
                return_value=FakeContextPackage(),
            ),
            patch(
                "app.core.turno.chiama_tutor",
                side_effect=fake_chiama_tutor,
            ),
            patch(
                "app.core.turno.salva_turno",
                salva_turno_mock,
            ),
            patch(
                "app.core.turno.processa_segnali",
                return_value=[],
            ),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente=None,  # Primo turno: nessun msg utente
            ):
                eventi.append(ev)

        # salva_turno chiamato solo 1 volta (assistente, no utente)
        assert salva_turno_mock.call_count == 1
        call_kwargs = salva_turno_mock.call_args[1]
        assert call_kwargs["ruolo"] == "assistente"

    @pytest.mark.asyncio
    async def test_turno_con_promozione(self):
        """Turno che trigger una promozione e avanza al nodo successivo."""
        from dataclasses import dataclass

        from app.core.turno import esegui_turno

        @dataclass
        class FakeRisultato:
            testo_completo: str = "Bravo!"
            azioni: list = None
            segnali: list = None
            token_input: int = 150
            token_output: int = 60
            costo_stimato: float = 0.001
            modello: str = "test-model"
            stop_reason: str = "end_turn"

            def __post_init__(self):
                self.azioni = self.azioni or []
                self.segnali = self.segnali or []

        @dataclass
        class FakeContextPackage:
            system: str = "test"
            messages: list = None
            modello: str = "test-model"
            tipo_sessione: str = "studio"

            def __post_init__(self):
                self.messages = self.messages or []

        @dataclass
        class FakeSessione:
            stato_orchestratore: dict = None

            def __post_init__(self):
                self.stato_orchestratore = {"nodo_focale_id": "nodo_next"}

        async def fake_chiama_tutor(**kwargs):
            yield {"tipo": "text_delta", "testo": "Bravo!"}
            yield {"tipo": "stop", "risultato": FakeRisultato()}

        db = AsyncMock()
        db.commit = AsyncMock()
        db.refresh = AsyncMock()
        sess_result = MagicMock()
        sess_result.scalar_one_or_none.return_value = FakeSessione()
        db.execute = AsyncMock(return_value=sess_result)

        promozione = [{
            "nodo_id": "nodo_old",
            "nuovo_livello": "operativo",
            "nodi_sbloccati": ["nodo_next"],
        }]

        aggiorna_mock = AsyncMock(return_value="nodo_next")

        import uuid

        with (
            patch(
                "app.core.turno.assembla_context_package",
                return_value=FakeContextPackage(),
            ),
            patch(
                "app.core.turno.chiama_tutor",
                side_effect=fake_chiama_tutor,
            ),
            patch(
                "app.core.turno.salva_turno",
                return_value=MagicMock(id=3),
            ),
            patch(
                "app.core.turno.processa_segnali",
                return_value=promozione,
            ),
            patch(
                "app.core.turno.aggiorna_nodo_dopo_promozione",
                aggiorna_mock,
            ),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="x = 2",
            ):
                eventi.append(ev)

        # aggiorna_nodo_dopo_promozione chiamato
        aggiorna_mock.assert_called_once()

        turno_completo = [
            e for e in eventi if e.get("event") == "turno_completo"
        ]
        assert len(turno_completo) == 1


# ===================================================================
# Test: promozione_appena_avvenuta salvata in stato_orchestratore
# ===================================================================


class TestPromozioneAppenAvvenuta:
    """Dopo promozione, aggiorna_nodo_dopo_promozione deve salvare
    promozione_appena_avvenuta nello stato_orchestratore della sessione.
    """

    @pytest.mark.asyncio
    async def test_promozione_salva_flag_in_stato(self):
        """Dopo promozione, stato_orchestratore contiene promozione_appena_avvenuta."""
        from dataclasses import dataclass, field

        from app.core.elaborazione import aggiorna_nodo_dopo_promozione

        @dataclass
        class FakeSessione:
            stato_orchestratore: dict = field(default_factory=dict)
            nodi_lavorati: list = field(default_factory=list)

        sessione = FakeSessione()

        db = AsyncMock()
        result_sess = MagicMock()
        result_sess.scalar_one_or_none.return_value = sessione
        db.execute = AsyncMock(return_value=result_sess)
        db.flush = AsyncMock()

        import uuid

        with (
            patch("app.core.elaborazione.grafo_knowledge") as mock_grafo,
            patch("app.core.elaborazione.get_livelli_utente", return_value={}),
            patch("app.grafo.algoritmi.path_planner", return_value="nodo_next"),
            patch("app.core.elaborazione.flag_modified"),
        ):
            mock_grafo.caricato = True
            nodes_dict = {
                "nodo_completato": {"nome": "Equazioni di primo grado", "tema_id": "algebra"},
            }
            mock_grafo.grafo.nodes = nodes_dict

            result = await aggiorna_nodo_dopo_promozione(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                nodo_promosso="nodo_completato",
            )

        assert result == "nodo_next"
        stato = sessione.stato_orchestratore
        assert "promozione_appena_avvenuta" in stato
        assert stato["promozione_appena_avvenuta"]["nodo_id"] == "nodo_completato"
        assert stato["promozione_appena_avvenuta"]["nodo_nome"] == "Equazioni di primo grado"
        assert stato["nodo_focale_id"] == "nodo_next"
        assert stato["attivita_corrente"] == "spiegazione"

    @pytest.mark.asyncio
    async def test_promozione_flag_contiene_fallback_id_se_grafo_non_ha_nome(self):
        """Se il grafo non ha il nome del nodo, usa l'ID come fallback."""
        from dataclasses import dataclass, field

        from app.core.elaborazione import aggiorna_nodo_dopo_promozione

        @dataclass
        class FakeSessione:
            stato_orchestratore: dict = field(default_factory=dict)
            nodi_lavorati: list = field(default_factory=list)

        sessione = FakeSessione()

        db = AsyncMock()
        result_sess = MagicMock()
        result_sess.scalar_one_or_none.return_value = sessione
        db.execute = AsyncMock(return_value=result_sess)
        db.flush = AsyncMock()

        import uuid

        with (
            patch("app.core.elaborazione.grafo_knowledge") as mock_grafo,
            patch("app.core.elaborazione.get_livelli_utente", return_value={}),
            patch("app.grafo.algoritmi.path_planner", return_value="nodo_b"),
            patch("app.core.elaborazione.flag_modified"),
        ):
            mock_grafo.caricato = True
            # Nodo senza chiave "nome" nel dizionario
            mock_grafo.grafo.nodes = {"nodo_a": {"tema_id": "algebra"}}

            result = await aggiorna_nodo_dopo_promozione(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                nodo_promosso="nodo_a",
            )

        stato = sessione.stato_orchestratore
        # Fallback: usa l'ID come nome
        assert stato["promozione_appena_avvenuta"]["nodo_nome"] == "nodo_a"


# ===================================================================
# Test: helper eventi SSE
# ===================================================================


class TestEventiSSE:
    def test_evento_sse_formato(self):
        from app.core.turno import _evento_sse

        ev = _evento_sse("text_delta", {"testo": "ciao"})
        assert ev["event"] == "text_delta"
        assert ev["data"]["testo"] == "ciao"

    def test_evento_errore_formato(self):
        from app.core.turno import _evento_errore

        ev = _evento_errore("timeout", "LLM non risponde")
        assert ev["event"] == "errore"
        assert ev["data"]["codice"] == "timeout"
        assert ev["data"]["messaggio"] == "LLM non risponde"
