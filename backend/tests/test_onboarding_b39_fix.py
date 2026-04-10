"""Test B39-FIX — Collegamento onboarding narrativo.

Verifica che:
1. Accoglienza sia testo libero (NO tool use, NO VINCOLO ASSOLUTO)
2. Accoglienza → conoscenza transizione funzioni
3. Conoscenza riceva prossimo_campo dal decisore
4. Conoscenza completa → auto_valutazione (non più placement diretto)
5. Auto-valutazione usi tool onboarding_domanda
6. Direttiva conoscenza non contenga VINCOLO ASSOLUTO
7. Auto-valutazione cicla nodi gateway e transisce a placement
8. _parsa_livello_autovalutazione funziona correttamente
"""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.core.onboarding import (
    _parsa_livello_autovalutazione,
    aggiorna_fase_onboarding,
    elabora_decisione_onboarding,
)
from app.llm.prompts.direttive import direttiva_onboarding
from app.schemas.onboarding import (
    AzioneDecisore,
    CampoConConfidenza,
    ProfiloEstratto,
)


# ===================================================================
# Helper: mock objects
# ===================================================================


def _mock_sessione(
    fase="accoglienza",
    turni=0,
    turni_auto_valutazione=0,
    extra_stato=None,
):
    sess = MagicMock()
    sess.id = uuid.uuid4()
    sess.utente_id = uuid.uuid4()
    sess.stato = "attiva"
    sess.tipo = "onboarding"
    stato = {
        "fase_onboarding": fase,
        "turni_conoscenza": turni,
    }
    if turni_auto_valutazione > 0:
        stato["turni_auto_valutazione"] = turni_auto_valutazione
    if extra_stato:
        stato.update(extra_stato)
    sess.stato_orchestratore = stato
    sess.created_at = datetime.now(timezone.utc)
    sess.nodi_lavorati = []
    return sess


def _profilo_completo():
    return ProfiloEstratto(
        chi_e=CampoConConfidenza(valore="studente", confidenza="alta"),
        motivo=CampoConConfidenza(valore="esame", confidenza="alta"),
        stile_cognitivo=CampoConConfidenza(valore="visuale", confidenza="alta"),
        tempo_disponibile=CampoConConfidenza(valore="1h", confidenza="alta"),
        vissuto_scolastico=CampoConConfidenza(valore="ok", confidenza="alta"),
    )


def _profilo_parziale():
    """Solo chi_e e motivo completi, resto mancante."""
    return ProfiloEstratto(
        chi_e=CampoConConfidenza(valore="studente", confidenza="alta"),
        motivo=CampoConConfidenza(valore="esame", confidenza="alta"),
        stile_cognitivo=CampoConConfidenza(confidenza="bassa"),
        tempo_disponibile=CampoConConfidenza(confidenza="bassa"),
        vissuto_scolastico=CampoConConfidenza(confidenza="bassa"),
    )


def _gateway_nodes():
    return [
        {"nodo_id": "n1", "nome": "Frazioni", "tema_id": "aritmetica", "profondita": 0},
        {"nodo_id": "n2", "nome": "Equazioni", "tema_id": "algebra", "profondita": 5},
        {"nodo_id": "n3", "nome": "Derivate", "tema_id": "analisi", "profondita": 10},
    ]


# ===================================================================
# Test 1: accoglienza NO tool use
# ===================================================================


class TestAccoglienzaNoToolUse:
    def test_accoglienza_no_vincolo_assoluto(self):
        """Il prompt accoglienza NON deve contenere VINCOLO ASSOLUTO."""
        d = direttiva_onboarding(fase="accoglienza")
        assert "VINCOLO ASSOLUTO" not in d

    def test_accoglienza_no_devi_chiamare_tool(self):
        """Il prompt accoglienza NON deve forzare il tool use."""
        d = direttiva_onboarding(fase="accoglienza")
        assert "DEVI chiamare il tool" not in d

    def test_accoglienza_vieta_tool(self):
        """Il prompt dice esplicitamente di NON chiamare onboarding_domanda."""
        d = direttiva_onboarding(fase="accoglienza")
        assert "NON chiamare il tool `onboarding_domanda`" in d

    def test_accoglienza_menziona_patto(self):
        d = direttiva_onboarding(fase="accoglienza")
        assert "patto esplicito" in d

    def test_accoglienza_formato_testo_libero(self):
        d = direttiva_onboarding(fase="accoglienza")
        assert "testo libero" in d


# ===================================================================
# Test 2: accoglienza → conoscenza
# ===================================================================


class TestAccoglienzaTransizioneConoscenza:
    @pytest.mark.asyncio
    async def test_decisore_accoglienza_ritorna_decisione(self):
        """Il decisore in accoglienza ritorna Decisione (non None)."""
        sess = _mock_sessione(fase="accoglienza")
        db = AsyncMock()

        decisione = await elabora_decisione_onboarding(db, sess)

        assert decisione is not None
        assert decisione.azione == AzioneDecisore.chiedi_campo_mancante
        assert decisione.campo_da_chiedere == "chi_e"


# ===================================================================
# Test 3: conoscenza con prossimo_campo
# ===================================================================


class TestConoscenzaCampoMancante:
    @pytest.mark.asyncio
    @patch("app.core.onboarding.estrai_profilo")
    @patch("app.core.onboarding.carica_conversazione")
    async def test_conoscenza_salva_prossimo_campo(
        self, mock_carica, mock_estrai
    ):
        """Dopo turno conoscenza, il decisore salva prossimo_campo in stato."""
        db = AsyncMock()
        sess = _mock_sessione(fase="conoscenza", turni=2)

        mock_carica.return_value = [
            {"role": "user", "content": "Sono uno studente"},
        ]
        mock_estrai.return_value = _profilo_parziale()

        decisione = await elabora_decisione_onboarding(db, sess)

        assert decisione is not None
        assert decisione.azione == AzioneDecisore.chiedi_campo_mancante
        # prossimo_campo salvato nello stato
        assert "prossimo_campo" in sess.stato_orchestratore
        assert sess.stato_orchestratore["prossimo_campo"] == decisione.campo_da_chiedere

    def test_direttiva_conoscenza_include_campo(self):
        """La direttiva conoscenza include la descrizione del campo da approfondire."""
        d = direttiva_onboarding(fase="conoscenza", prossimo_campo="stile_cognitivo")
        assert "come preferisce studiare" in d


# ===================================================================
# Test 4: conoscenza completa → auto_valutazione
# ===================================================================


class TestConoscenzaCompletaTransizione:
    @pytest.mark.asyncio
    @patch("app.core.onboarding.seleziona_nodi_gateway")
    @patch("app.core.onboarding.estrai_profilo")
    @patch("app.core.onboarding.carica_conversazione")
    async def test_profilo_completo_transisce_a_auto_valutazione(
        self, mock_carica, mock_estrai, mock_gateway
    ):
        """Con profilo completo, il decisore transisce a auto_valutazione."""
        db = AsyncMock()
        sess = _mock_sessione(fase="conoscenza", turni=3)

        mock_carica.return_value = [{"role": "user", "content": "tutto detto"}]
        mock_estrai.return_value = _profilo_completo()
        mock_gateway.return_value = _gateway_nodes()

        decisione = await elabora_decisione_onboarding(db, sess)

        assert decisione is not None
        assert decisione.azione == AzioneDecisore.chiudi_narrativa
        assert sess.stato_orchestratore["fase_onboarding"] == "auto_valutazione"
        assert sess.stato_orchestratore["nodo_da_valutare"] is not None
        assert sess.stato_orchestratore["nodo_da_valutare"]["nome"] == "Frazioni"
        assert "autovalutazioni" in sess.stato_orchestratore
        assert len(sess.stato_orchestratore["autovalutazioni"]) == 0


# ===================================================================
# Test 5: auto_valutazione usa tool
# ===================================================================


class TestAutoValutazioneUsaTool:
    def test_auto_valutazione_menziona_onboarding_domanda(self):
        """La direttiva auto_valutazione dice di usare il tool."""
        nodo = {"nodo_id": "n1", "nome": "Frazioni", "tema_id": "aritmetica"}
        d = direttiva_onboarding(fase="auto_valutazione", nodo_da_valutare=nodo)
        assert "onboarding_domanda" in d

    def test_auto_valutazione_menziona_scelta_singola(self):
        nodo = {"nodo_id": "n1", "nome": "Frazioni", "tema_id": "aritmetica"}
        d = direttiva_onboarding(fase="auto_valutazione", nodo_da_valutare=nodo)
        assert "scelta_singola" in d

    def test_auto_valutazione_include_nome_nodo(self):
        nodo = {"nodo_id": "n1", "nome": "Frazioni", "tema_id": "aritmetica"}
        d = direttiva_onboarding(fase="auto_valutazione", nodo_da_valutare=nodo)
        assert "Frazioni" in d

    def test_auto_valutazione_opzioni_forte_incerto_digiuno(self):
        nodo = {"nodo_id": "n1", "nome": "Frazioni", "tema_id": "aritmetica"}
        d = direttiva_onboarding(fase="auto_valutazione", nodo_da_valutare=nodo)
        assert "Forte, lo so bene" in d
        assert "Incerto, mi serve ripassare" in d
        assert "Digiuno, mai visto" in d


# ===================================================================
# Test 6: conoscenza NO VINCOLO ASSOLUTO
# ===================================================================


class TestConoscenzaNoVincoloAssoluto:
    def test_conoscenza_no_vincolo_assoluto(self):
        """La direttiva conoscenza NON deve contenere VINCOLO ASSOLUTO."""
        d = direttiva_onboarding(fase="conoscenza")
        assert "VINCOLO ASSOLUTO" not in d

    def test_conoscenza_no_devi_chiamare_tool(self):
        """La direttiva conoscenza NON deve forzare il tool use."""
        d = direttiva_onboarding(fase="conoscenza")
        assert "DEVI chiamare il tool" not in d

    def test_conoscenza_vieta_tool(self):
        """La direttiva dice esplicitamente di NON chiamare onboarding_domanda."""
        d = direttiva_onboarding(fase="conoscenza")
        assert "NON chiamare `onboarding_domanda`" in d


# ===================================================================
# Test 7: auto_valutazione cicla nodi
# ===================================================================


class TestAutoValutazioneCicloNodi:
    @pytest.mark.asyncio
    async def test_aggiorna_fase_auto_valutazione_processa_risposta(self):
        """Il secondo turno auto_valutazione processa la risposta e cicla al nodo successivo."""
        db = AsyncMock()
        gateway = _gateway_nodes()
        sess = _mock_sessione(
            fase="auto_valutazione",
            extra_stato={
                "turni_auto_valutazione": 1,  # >= 1 → processa risposta
                "nodo_da_valutare": gateway[0],  # Frazioni
                "nodi_gateway_auto_valutazione": gateway,
                "autovalutazioni": {},
            },
        )

        # Mock: ultimo messaggio utente "Forte, lo so bene"
        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = "Forte, lo so bene"
        db.execute = AsyncMock(return_value=result_mock)

        fase = await aggiorna_fase_onboarding(db, sess)

        assert fase == "auto_valutazione"
        autoval = sess.stato_orchestratore["autovalutazioni"]
        assert "aritmetica" in autoval
        assert autoval["aritmetica"] == "forte"
        # Nodo successivo selezionato
        assert sess.stato_orchestratore["nodo_da_valutare"]["nome"] == "Equazioni"

    @pytest.mark.asyncio
    async def test_auto_valutazione_completa_transisce_a_placement(self):
        """Quando tutti i nodi sono valutati, transisce a placement."""
        db = AsyncMock()
        gateway = _gateway_nodes()
        sess = _mock_sessione(
            fase="auto_valutazione",
            extra_stato={
                "turni_auto_valutazione": 3,
                "nodo_da_valutare": gateway[2],  # ultimo: Derivate (analisi)
                "nodi_gateway_auto_valutazione": gateway,
                "autovalutazioni": {
                    "aritmetica": "forte",
                    "algebra": "incerto",
                    # analisi manca, verrà processato ora
                },
            },
        )

        # Mock: ultimo messaggio utente "Digiuno, mai visto"
        result_mock = MagicMock()
        result_mock.scalar_one_or_none.return_value = "Digiuno, mai visto"
        db.execute = AsyncMock(return_value=result_mock)

        fase = await aggiorna_fase_onboarding(db, sess)

        # Tutte le 3 aree valutate → placement
        assert fase == "placement"
        assert sess.stato_orchestratore["fase_onboarding"] == "placement"
        autoval = sess.stato_orchestratore["autovalutazioni"]
        assert autoval["analisi"] == "digiuno"
        assert len(autoval) == 3


# ===================================================================
# Test 8: _parsa_livello_autovalutazione
# ===================================================================


class TestParsaLivelloAutovalutazione:
    def test_forte(self):
        assert _parsa_livello_autovalutazione("Forte, lo so bene") == "forte"

    def test_forte_parziale(self):
        assert _parsa_livello_autovalutazione("Mi sento forte") == "forte"

    def test_incerto(self):
        assert _parsa_livello_autovalutazione("Incerto, mi serve ripassare") == "incerto"

    def test_digiuno(self):
        assert _parsa_livello_autovalutazione("Digiuno, mai visto") == "digiuno"

    def test_digiuno_mai_fatto(self):
        assert _parsa_livello_autovalutazione("Mai fatto in vita mia") == "digiuno"

    def test_risposta_ambigua_default_incerto(self):
        """Risposta non riconosciuta → default conservativo a incerto."""
        assert _parsa_livello_autovalutazione("boh non lo so") == "incerto"

    def test_risposta_vuota_default_incerto(self):
        assert _parsa_livello_autovalutazione("") == "incerto"

    def test_case_insensitive(self):
        assert _parsa_livello_autovalutazione("FORTE, LO SO BENE") == "forte"
        assert _parsa_livello_autovalutazione("digiuno") == "digiuno"
