"""Test Blocco 9 + B14-bis — Onboarding.

Test:
- Creazione utente temporaneo
- Sessione onboarding con fasi
- Transizione fasi: accoglienza → conoscenza → conclusione
- Completamento: profilo, percorso, stato nodi
- Punto di partenza personalizzato
- Match tema/nodo nel grafo
- Schemas Pydantic
- B14-bis: tool onboarding_domanda, elaborazione passthrough, prompt adattivi
"""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.core.onboarding import (
    TURNI_CONOSCENZA_MAX,
    _trova_nodo_per_tema,
    aggiorna_fase_onboarding,
    completa_onboarding,
    crea_sessione_onboarding,
    crea_utente_temporaneo,
)
from app.llm.prompts.direttive import direttiva_onboarding
from app.llm.tools import NOMI_AZIONI, is_azione
from app.schemas.onboarding import (
    OnboardingCompletaRequest,
    OnboardingCompletaResponse,
    OnboardingIniziaResponse,
    OnboardingTurnoRequest,
)

# ===================================================================
# Helper: mock objects
# ===================================================================


def _mock_sessione(
    sessione_id=None,
    utente_id=None,
    stato="attiva",
    tipo="onboarding",
    stato_orchestratore=None,
    created_at=None,
):
    sess = MagicMock()
    sess.id = sessione_id or uuid.uuid4()
    sess.utente_id = utente_id or uuid.uuid4()
    sess.stato = stato
    sess.tipo = tipo
    sess.stato_orchestratore = stato_orchestratore or {
        "fase_onboarding": "accoglienza",
        "turni_conoscenza": 0,
    }
    sess.created_at = created_at or datetime.now(timezone.utc)
    sess.completed_at = None
    sess.durata_effettiva_min = None
    sess.nodi_lavorati = []
    return sess


def _mock_utente(utente_id=None):
    utente = MagicMock()
    utente.id = utente_id or uuid.uuid4()
    utente.contesto_personale = None
    utente.preferenze_tutor = None
    utente.materie_attive = ["matematica"]
    return utente


# ===================================================================
# Test: creazione utente temporaneo
# ===================================================================


class TestCreaUtenteTemporaneo:
    @pytest.mark.asyncio
    async def test_crea_utente_temp(self):
        db = AsyncMock()
        utente = await crea_utente_temporaneo(db)

        db.add.assert_called_once()
        db.flush.assert_awaited_once()
        assert utente.materie_attive == ["matematica"]


# ===================================================================
# Test: creazione sessione onboarding
# ===================================================================


class TestCreaSessioneOnboarding:
    @pytest.mark.asyncio
    async def test_crea_sessione(self):
        db = AsyncMock()
        utente_id = uuid.uuid4()

        sessione = await crea_sessione_onboarding(db, utente_id)

        db.add.assert_called_once()
        db.flush.assert_awaited_once()
        assert sessione.tipo == "onboarding"
        assert sessione.stato == "attiva"
        stato = sessione.stato_orchestratore
        assert stato["fase_onboarding"] == "accoglienza"


# ===================================================================
# Test: transizione fasi onboarding
# ===================================================================


class TestAggiornaFaseOnboarding:
    @pytest.mark.asyncio
    async def test_accoglienza_resta_senza_turni_utente(self):
        db = AsyncMock()
        sessione = _mock_sessione(
            stato_orchestratore={
                "fase_onboarding": "accoglienza",
                "turni_conoscenza": 0,
            }
        )

        # Mock: 0 turni utente
        result_mock = MagicMock()
        result_mock.scalar_one.return_value = 0
        db.execute = AsyncMock(return_value=result_mock)

        fase = await aggiorna_fase_onboarding(db, sessione)
        assert fase == "accoglienza"

    @pytest.mark.asyncio
    async def test_accoglienza_a_conoscenza_dopo_primo_turno(self):
        db = AsyncMock()
        sessione = _mock_sessione(
            stato_orchestratore={
                "fase_onboarding": "accoglienza",
                "turni_conoscenza": 0,
            }
        )

        # Mock: 1 turno utente
        result_mock = MagicMock()
        result_mock.scalar_one.return_value = 1
        db.execute = AsyncMock(return_value=result_mock)

        fase = await aggiorna_fase_onboarding(db, sessione)
        assert fase == "conoscenza"
        assert sessione.stato_orchestratore["fase_onboarding"] == "conoscenza"

    @pytest.mark.asyncio
    async def test_conoscenza_incrementa_turni(self):
        db = AsyncMock()
        sessione = _mock_sessione(
            stato_orchestratore={
                "fase_onboarding": "conoscenza",
                "turni_conoscenza": 2,
            }
        )

        fase = await aggiorna_fase_onboarding(db, sessione)
        assert fase == "conoscenza"
        assert sessione.stato_orchestratore["turni_conoscenza"] == 3

    @pytest.mark.asyncio
    async def test_conoscenza_a_conclusione_max_turni(self):
        db = AsyncMock()
        sessione = _mock_sessione(
            stato_orchestratore={
                "fase_onboarding": "conoscenza",
                "turni_conoscenza": TURNI_CONOSCENZA_MAX - 1,
            }
        )

        fase = await aggiorna_fase_onboarding(db, sessione)
        assert fase == "conclusione"

    @pytest.mark.asyncio
    async def test_conclusione_resta_conclusione(self):
        db = AsyncMock()
        sessione = _mock_sessione(
            stato_orchestratore={
                "fase_onboarding": "conclusione",
                "turni_conoscenza": 5,
            }
        )

        fase = await aggiorna_fase_onboarding(db, sessione)
        assert fase == "conclusione"


# ===================================================================
# Test: completamento onboarding
# ===================================================================


class TestCompletaOnboarding:
    @pytest.mark.asyncio
    @patch("app.core.onboarding._inizializza_stato_nodi")
    @patch("app.core.onboarding.grafo_knowledge")
    async def test_completa_salva_profilo(self, mock_grafo, mock_init):
        db = AsyncMock()
        sessione = _mock_sessione()
        utente = _mock_utente()

        mock_grafo.caricato = False
        mock_init.return_value = 0

        risultato = await completa_onboarding(
            db=db,
            sessione=sessione,
            utente=utente,
            contesto_personale={"lavoro": "studente"},
            preferenze_tutor={"velocita": "bene"},
        )

        assert utente.contesto_personale == {"lavoro": "studente"}
        assert utente.preferenze_tutor == {"velocita": "bene"}
        assert sessione.stato == "completata"
        assert sessione.completed_at is not None
        assert "percorso_id" in risultato

    @pytest.mark.asyncio
    @patch("app.core.onboarding._inizializza_stato_nodi")
    @patch("app.core.onboarding.grafo_knowledge")
    async def test_completa_crea_percorso(self, mock_grafo, mock_init):
        db = AsyncMock()
        sessione = _mock_sessione()
        utente = _mock_utente()

        mock_grafo.caricato = False
        mock_init.return_value = 100

        risultato = await completa_onboarding(
            db=db,
            sessione=sessione,
            utente=utente,
        )

        # Verifica che db.add è stato chiamato (per percorso)
        assert db.add.call_count >= 1
        assert risultato["nodi_inizializzati"] == 100

    @pytest.mark.asyncio
    @patch("app.core.onboarding._inizializza_stato_nodi")
    @patch("app.core.onboarding._trova_nodo_per_tema")
    @patch("app.core.onboarding.grafo_knowledge")
    async def test_completa_con_punto_partenza(
        self, mock_grafo, mock_trova, mock_init
    ):
        db = AsyncMock()
        sessione = _mock_sessione(
            stato_orchestratore={
                "fase_onboarding": "conclusione",
                "punto_partenza_suggerito": "equazioni secondo grado",
            }
        )
        utente = _mock_utente()

        mock_grafo.caricato = True
        mock_trova.return_value = "mat_algebra2_eq_secondo_grado"
        mock_init.return_value = 50

        risultato = await completa_onboarding(
            db=db,
            sessione=sessione,
            utente=utente,
        )

        assert risultato["nodo_iniziale"] == "mat_algebra2_eq_secondo_grado"
        mock_init.assert_awaited_once()

    @pytest.mark.asyncio
    @patch("app.core.onboarding._inizializza_stato_nodi")
    @patch("app.core.onboarding.grafo_knowledge")
    async def test_completa_senza_profilo(self, mock_grafo, mock_init):
        db = AsyncMock()
        sessione = _mock_sessione()
        utente = _mock_utente()

        mock_grafo.caricato = False
        mock_init.return_value = 0

        risultato = await completa_onboarding(
            db=db,
            sessione=sessione,
            utente=utente,
        )

        assert utente.contesto_personale is None
        assert utente.preferenze_tutor is None
        assert risultato["nodo_iniziale"] is None


# ===================================================================
# Test: trova nodo per tema
# ===================================================================


class TestTrovaNodoPerTema:
    @patch("app.core.onboarding.grafo_knowledge")
    def test_match_per_tema_id(self, mock_grafo):
        mock_grafo.caricato = True
        g = MagicMock()
        g.nodes.return_value = [
            ("nodo_1", {"tipo_nodo": "operativo", "tema_id": "equazioni_secondo_grado"}),
            ("nodo_2", {"tipo_nodo": "operativo", "tema_id": "frazioni"}),
        ]
        # Simula iterazione su nodi con data
        g.nodes.__iter__ = MagicMock(return_value=iter(["nodo_1", "nodo_2"]))
        g.nodes.__contains__ = MagicMock(return_value=True)

        # Usa metodo diretto con side_effect
        def nodes_data(data=False):
            if data:
                return [
                    ("nodo_1", {"tipo_nodo": "operativo", "tema_id": "equazioni_secondo_grado"}),
                    ("nodo_2", {"tipo_nodo": "operativo", "tema_id": "frazioni"}),
                ]
            return ["nodo_1", "nodo_2"]

        g.nodes = MagicMock(side_effect=nodes_data)
        mock_grafo.grafo = g

        # Reimplementa il test con un grafo reale
        import networkx as nx
        grafo_reale = nx.DiGraph()
        grafo_reale.add_node(
            "nodo_eq2",
            tipo_nodo="operativo",
            tema_id="equazioni_secondo_grado",
        )
        grafo_reale.add_node(
            "nodo_fraz",
            tipo_nodo="operativo",
            tema_id="frazioni",
        )
        mock_grafo.grafo = grafo_reale

        result = _trova_nodo_per_tema("equazioni secondo grado")
        assert result == "nodo_eq2"

    @patch("app.core.onboarding.grafo_knowledge")
    def test_match_per_nodo_id_fallback(self, mock_grafo):
        mock_grafo.caricato = True

        import networkx as nx
        grafo = nx.DiGraph()
        grafo.add_node(
            "mat_algebra2_discriminante",
            tipo_nodo="operativo",
            tema_id="equazioni",
        )
        mock_grafo.grafo = grafo

        result = _trova_nodo_per_tema("discriminante")
        assert result == "mat_algebra2_discriminante"

    @patch("app.core.onboarding.grafo_knowledge")
    def test_nessun_match(self, mock_grafo):
        mock_grafo.caricato = True

        import networkx as nx
        grafo = nx.DiGraph()
        grafo.add_node("nodo_1", tipo_nodo="operativo", tema_id="algebra")
        mock_grafo.grafo = grafo

        result = _trova_nodo_per_tema("fisica quantistica")
        assert result is None

    @patch("app.core.onboarding.grafo_knowledge")
    def test_grafo_non_caricato(self, mock_grafo):
        mock_grafo.caricato = False

        result = _trova_nodo_per_tema("qualcosa")
        assert result is None

    @patch("app.core.onboarding.grafo_knowledge")
    def test_ignora_nodi_contesto(self, mock_grafo):
        mock_grafo.caricato = True

        import networkx as nx
        grafo = nx.DiGraph()
        grafo.add_node(
            "nodo_contesto",
            tipo_nodo="contesto",
            tema_id="equazioni_secondo_grado",
        )
        grafo.add_node(
            "nodo_operativo",
            tipo_nodo="operativo",
            tema_id="frazioni",
        )
        mock_grafo.grafo = grafo

        result = _trova_nodo_per_tema("equazioni secondo grado")
        assert result is None  # nodo_contesto viene ignorato


# ===================================================================
# Test: Pydantic schemas
# ===================================================================


class TestSchemas:
    def test_onboarding_inizia_response(self):
        uid = uuid.uuid4()
        sid = uuid.uuid4()
        resp = OnboardingIniziaResponse(
            utente_temp_id=uid, sessione_id=sid
        )
        data = resp.model_dump(mode="json")
        assert data["utente_temp_id"] == str(uid)
        assert data["sessione_id"] == str(sid)

    def test_onboarding_turno_request(self):
        sid = uuid.uuid4()
        req = OnboardingTurnoRequest(
            sessione_id=sid, messaggio="Sono uno studente"
        )
        assert req.sessione_id == sid

    def test_onboarding_completa_request_minimal(self):
        sid = uuid.uuid4()
        req = OnboardingCompletaRequest(sessione_id=sid)
        assert req.contesto_personale is None
        assert req.preferenze_tutor is None

    def test_onboarding_completa_request_full(self):
        sid = uuid.uuid4()
        req = OnboardingCompletaRequest(
            sessione_id=sid,
            contesto_personale={"lavoro": "liceale"},
            preferenze_tutor={"velocita": "sodo"},
        )
        assert req.contesto_personale["lavoro"] == "liceale"

    def test_onboarding_completa_response(self):
        resp = OnboardingCompletaResponse(
            percorso_id=1,
            nodo_iniziale="nodo_1",
            nodi_inizializzati=50,
        )
        assert resp.percorso_id == 1

    def test_onboarding_completa_response_no_override(self):
        resp = OnboardingCompletaResponse(
            percorso_id=1,
            nodi_inizializzati=100,
        )
        assert resp.nodo_iniziale is None


# ===================================================================
# Test: costante turni conoscenza
# ===================================================================


class TestCostanti:
    def test_turni_conoscenza_max(self):
        assert TURNI_CONOSCENZA_MAX == 8


# ===================================================================
# Test: flusso E2E onboarding
# ===================================================================


class TestFlussoOnboardingE2E:
    @pytest.mark.asyncio
    @patch("app.core.onboarding._inizializza_stato_nodi")
    @patch("app.core.onboarding.grafo_knowledge")
    async def test_flusso_completo_senza_override(
        self, mock_grafo, mock_init
    ):
        """Crea utente → crea sessione → transizioni fasi → completa."""
        db = AsyncMock()

        # Step 1: Crea utente temp
        utente = await crea_utente_temporaneo(db)
        assert utente.materie_attive == ["matematica"]

        # Step 2: Crea sessione
        sessione = await crea_sessione_onboarding(db, utente.id)
        assert sessione.tipo == "onboarding"
        stato = sessione.stato_orchestratore
        assert stato["fase_onboarding"] == "accoglienza"
        # Imposta created_at (normalmente lo fa il DB)
        sessione.created_at = datetime.now(timezone.utc)

        # Step 3: Simula transizione accoglienza → conoscenza
        result_mock = MagicMock()
        result_mock.scalar_one.return_value = 1
        db.execute = AsyncMock(return_value=result_mock)

        fase = await aggiorna_fase_onboarding(db, sessione)
        assert fase == "conoscenza"

        # Step 4: Simula turni in conoscenza fino a conclusione
        # Servono TURNI_CONOSCENZA_MAX chiamate: da 0 si incrementa a 1,2,...,8
        for i in range(TURNI_CONOSCENZA_MAX):
            fase = await aggiorna_fase_onboarding(db, sessione)

        assert fase == "conclusione"

        # Step 5: Completa
        mock_grafo.caricato = False
        mock_init.return_value = 100

        risultato = await completa_onboarding(
            db=db,
            sessione=sessione,
            utente=utente,
            contesto_personale={"motivazione": "debito matematica"},
        )

        assert sessione.stato == "completata"
        assert utente.contesto_personale == {"motivazione": "debito matematica"}
        assert risultato["nodi_inizializzati"] == 100


# ===================================================================
# Test B14-bis: tool onboarding_domanda
# ===================================================================


class TestOnboardingDomandaTool:
    def test_onboarding_domanda_is_azione(self):
        """onboarding_domanda deve essere classificato come azione (SSE → frontend)."""
        assert "onboarding_domanda" in NOMI_AZIONI
        assert is_azione("onboarding_domanda")

    @pytest.mark.asyncio
    async def test_esegui_azione_onboarding_domanda_passthrough(self):
        """esegui_azione con onboarding_domanda ritorna passthrough senza stub."""
        from app.core.elaborazione import esegui_azione

        db = AsyncMock()
        result = await esegui_azione(
            db=db,
            azione={
                "name": "onboarding_domanda",
                "input": {
                    "tipo_input": "scelta_singola",
                    "domanda": "Come preferisci studiare?",
                    "opzioni": ["Teoria prima", "Subito esercizi", "Mix"],
                },
            },
            sessione_id=uuid.uuid4(),
            utente_id=uuid.uuid4(),
        )

        assert result is not None
        assert result["tipo"] == "onboarding_domanda"
        assert result["params"]["tipo_input"] == "scelta_singola"
        assert result["params"]["domanda"] == "Come preferisci studiare?"
        assert result["params"]["opzioni"] == ["Teoria prima", "Subito esercizi", "Mix"]
        assert "stub" not in result

    @pytest.mark.asyncio
    async def test_esegui_azione_onboarding_domanda_testo_libero(self):
        """esegui_azione con tipo_input testo_libero."""
        from app.core.elaborazione import esegui_azione

        db = AsyncMock()
        result = await esegui_azione(
            db=db,
            azione={
                "name": "onboarding_domanda",
                "input": {
                    "tipo_input": "testo_libero",
                    "domanda": "Cosa state facendo in classe?",
                    "placeholder": "Es: equazioni, derivate...",
                },
            },
            sessione_id=uuid.uuid4(),
            utente_id=uuid.uuid4(),
        )

        assert result["tipo"] == "onboarding_domanda"
        assert result["params"]["tipo_input"] == "testo_libero"
        assert result["params"]["placeholder"] == "Es: equazioni, derivate..."

    @pytest.mark.asyncio
    async def test_esegui_azione_onboarding_domanda_scala(self):
        """esegui_azione con tipo_input scala."""
        from app.core.elaborazione import esegui_azione

        db = AsyncMock()
        result = await esegui_azione(
            db=db,
            azione={
                "name": "onboarding_domanda",
                "input": {
                    "tipo_input": "scala",
                    "domanda": "Quanto ti senti sicuro?",
                    "scala_min": 1,
                    "scala_max": 5,
                    "scala_labels": ["Per niente", "Molto"],
                },
            },
            sessione_id=uuid.uuid4(),
            utente_id=uuid.uuid4(),
        )

        assert result["tipo"] == "onboarding_domanda"
        assert result["params"]["scala_min"] == 1
        assert result["params"]["scala_max"] == 5


# ===================================================================
# Test B14-bis: prompt onboarding adattivi
# ===================================================================


class TestDirettivaOnboardingAdattiva:
    def test_accoglienza_menziona_onboarding_domanda(self):
        d = direttiva_onboarding(fase="accoglienza")
        assert "onboarding_domanda" in d

    def test_accoglienza_menziona_checklist(self):
        d = direttiva_onboarding(fase="accoglienza")
        assert "CHECKLIST" in d

    def test_accoglienza_menziona_scelta_singola(self):
        d = direttiva_onboarding(fase="accoglienza")
        assert "scelta_singola" in d

    def test_conoscenza_menziona_onboarding_domanda(self):
        d = direttiva_onboarding(fase="conoscenza")
        assert "onboarding_domanda" in d

    def test_conoscenza_menziona_una_domanda(self):
        d = direttiva_onboarding(fase="conoscenza")
        assert "UNA domanda per turno" in d

    def test_conoscenza_include_info_raccolte(self):
        d = direttiva_onboarding(fase="conoscenza", info_raccolte="studente, matematica")
        assert "studente, matematica" in d

    def test_conclusione_vieta_onboarding_domanda(self):
        d = direttiva_onboarding(fase="conclusione")
        assert "NON usare onboarding_domanda" in d

    def test_conclusione_include_info_raccolte(self):
        d = direttiva_onboarding(fase="conclusione", info_raccolte="32 anni, vuole riprendere")
        assert "32 anni, vuole riprendere" in d

    def test_fase_sconosciuta(self):
        d = direttiva_onboarding(fase="inventata")
        assert "fase non riconosciuta" in d
