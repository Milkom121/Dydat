"""Test B39.3.2 — Integrazione decisore nell'endpoint /onboarding/turno.

Verifica che elabora_decisione_onboarding:
1. Chiami l'estrattore sulla conversazione reale dal DB
2. Chiami il decisore con profilo estratto + turni fatti
3. Salvi profilo + decisione nello stato_orchestratore
4. Transisca a placement quando il decisore lo decide
5. Non faccia nulla se la fase non è conoscenza
"""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.core.onboarding import (
    TETTO_TURNI_NARRATIVI,
    elabora_decisione_onboarding,
)
from app.schemas.onboarding import (
    AzioneDecisore,
    CampoConConfidenza,
    Decisione,
    ProfiloEstratto,
)


# --- Helper ---


def _campo(valore: str | None, confidenza: str) -> CampoConConfidenza:
    return CampoConConfidenza(valore=valore, confidenza=confidenza)


def _campo_alta(valore: str = "valore") -> CampoConConfidenza:
    return _campo(valore, "alta")


def _campo_bassa() -> CampoConConfidenza:
    return _campo(None, "bassa")


def _profilo_completo() -> ProfiloEstratto:
    return ProfiloEstratto(
        chi_e=_campo_alta("studente liceale"),
        motivo=_campo_alta("preparazione maturità"),
        stile_cognitivo=_campo_alta("visuale"),
        tempo_disponibile=_campo_alta("1h al giorno"),
        vissuto_scolastico=_campo_alta("buon rapporto"),
    )


def _profilo_parziale() -> ProfiloEstratto:
    """chi_e e motivo completi, resto mancante."""
    return ProfiloEstratto(
        chi_e=_campo_alta("studente"),
        motivo=_campo_alta("esame"),
        stile_cognitivo=_campo_bassa(),
        tempo_disponibile=_campo_bassa(),
        vissuto_scolastico=_campo_bassa(),
    )


def _profilo_vuoto() -> ProfiloEstratto:
    return ProfiloEstratto(
        chi_e=_campo_bassa(),
        motivo=_campo_bassa(),
        stile_cognitivo=_campo_bassa(),
        tempo_disponibile=_campo_bassa(),
        vissuto_scolastico=_campo_bassa(),
    )


def _mock_sessione(fase="conoscenza", turni=2):
    sess = MagicMock()
    sess.id = uuid.uuid4()
    sess.utente_id = uuid.uuid4()
    sess.stato_orchestratore = {
        "fase_onboarding": fase,
        "turni_conoscenza": turni,
    }
    return sess


def _mock_db():
    return AsyncMock()


# --- Test elabora_decisione_onboarding ---


class TestElaboraDecisioneOnboarding:
    """Test della funzione elabora_decisione_onboarding."""

    @pytest.mark.asyncio
    @patch("app.core.onboarding.estrai_profilo")
    @patch("app.core.onboarding.carica_conversazione")
    async def test_fase_non_conoscenza_ritorna_none(
        self, mock_carica, mock_estrai
    ):
        """Se la fase non è conoscenza, non si fa nulla."""
        db = _mock_db()
        for fase in ("accoglienza", "placement", "piano", "conclusione"):
            sess = _mock_sessione(fase=fase)
            risultato = await elabora_decisione_onboarding(db, sess)
            assert risultato is None

        # L'estrattore non deve essere chiamato
        mock_carica.assert_not_called()
        mock_estrai.assert_not_called()

    @pytest.mark.asyncio
    @patch("app.core.onboarding.estrai_profilo")
    @patch("app.core.onboarding.carica_conversazione")
    async def test_profilo_parziale_chiede_campo(
        self, mock_carica, mock_estrai
    ):
        """Con profilo parziale, il decisore chiede il campo mancante."""
        db = _mock_db()
        sess = _mock_sessione(fase="conoscenza", turni=2)

        mock_carica.return_value = [
            {"role": "assistant", "content": "Ciao!"},
            {"role": "user", "content": "Sono uno studente"},
        ]
        mock_estrai.return_value = _profilo_parziale()

        decisione = await elabora_decisione_onboarding(db, sess)

        assert decisione is not None
        assert decisione.azione == AzioneDecisore.chiedi_campo_mancante
        # stile_cognitivo è il primo campo mancante per priorità
        assert decisione.campo_da_chiedere == "stile_cognitivo"

        # Profilo e decisione salvati nello stato_orchestratore
        stato = sess.stato_orchestratore
        assert "profilo_estratto" in stato
        assert "ultima_decisione" in stato
        assert stato["fase_onboarding"] == "conoscenza"  # resta in conoscenza

    @pytest.mark.asyncio
    @patch("app.core.onboarding.estrai_profilo")
    @patch("app.core.onboarding.carica_conversazione")
    async def test_profilo_completo_chiudi_narrativa(
        self, mock_carica, mock_estrai
    ):
        """Con profilo completo, il decisore chiude la narrativa → placement."""
        db = _mock_db()
        sess = _mock_sessione(fase="conoscenza", turni=3)

        mock_carica.return_value = [
            {"role": "assistant", "content": "Ciao!"},
            {"role": "user", "content": "Racconto tutto di me..."},
        ]
        mock_estrai.return_value = _profilo_completo()

        decisione = await elabora_decisione_onboarding(db, sess)

        assert decisione is not None
        assert decisione.azione == AzioneDecisore.chiudi_narrativa
        assert decisione.campo_da_chiedere is None

        # Transizione a placement
        assert sess.stato_orchestratore["fase_onboarding"] == "placement"

    @pytest.mark.asyncio
    @patch("app.core.onboarding.estrai_profilo")
    @patch("app.core.onboarding.carica_conversazione")
    async def test_tetto_turni_forza_chiusura(
        self, mock_carica, mock_estrai
    ):
        """Al tetto turni, forza chiusura anche con profilo vuoto → placement."""
        db = _mock_db()
        sess = _mock_sessione(
            fase="conoscenza",
            turni=TETTO_TURNI_NARRATIVI,
        )

        mock_carica.return_value = [
            {"role": "user", "content": "boh"},
        ]
        mock_estrai.return_value = _profilo_vuoto()

        decisione = await elabora_decisione_onboarding(db, sess)

        assert decisione is not None
        assert decisione.azione == AzioneDecisore.forza_chiusura_tetto_turni

        # Transizione a placement
        assert sess.stato_orchestratore["fase_onboarding"] == "placement"

    @pytest.mark.asyncio
    @patch("app.core.onboarding.estrai_profilo")
    @patch("app.core.onboarding.carica_conversazione")
    async def test_profilo_estratto_salvato_correttamente(
        self, mock_carica, mock_estrai
    ):
        """Verifica che profilo e decisione siano serializzati nel DB."""
        db = _mock_db()
        sess = _mock_sessione(fase="conoscenza", turni=1)
        profilo = _profilo_parziale()

        mock_carica.return_value = [
            {"role": "user", "content": "Ciao sono Marco"},
        ]
        mock_estrai.return_value = profilo

        await elabora_decisione_onboarding(db, sess)

        stato = sess.stato_orchestratore
        profilo_salvato = stato["profilo_estratto"]
        decisione_salvata = stato["ultima_decisione"]

        # Verifica struttura profilo serializzato
        assert profilo_salvato["chi_e"]["confidenza"] == "alta"
        assert profilo_salvato["chi_e"]["valore"] == "studente"
        assert profilo_salvato["stile_cognitivo"]["confidenza"] == "bassa"

        # Verifica struttura decisione serializzata
        assert decisione_salvata["azione"] == "chiedi_campo_mancante"
        assert decisione_salvata["campo_da_chiedere"] == "stile_cognitivo"

    @pytest.mark.asyncio
    @patch("app.core.onboarding.estrai_profilo")
    @patch("app.core.onboarding.carica_conversazione")
    async def test_carica_conversazione_chiamata_con_sessione_id(
        self, mock_carica, mock_estrai
    ):
        """Verifica che carica_conversazione riceva l'ID sessione corretto."""
        db = _mock_db()
        sessione_id = uuid.uuid4()
        sess = _mock_sessione(fase="conoscenza", turni=1)
        sess.id = sessione_id

        mock_carica.return_value = []
        mock_estrai.return_value = _profilo_vuoto()

        await elabora_decisione_onboarding(db, sess)

        mock_carica.assert_awaited_once_with(db, sessione_id)

    @pytest.mark.asyncio
    @patch("app.core.onboarding.estrai_profilo")
    @patch("app.core.onboarding.carica_conversazione")
    async def test_flush_chiamato(self, mock_carica, mock_estrai):
        """Verifica che db.flush() venga chiamato per persistere lo stato."""
        db = _mock_db()
        sess = _mock_sessione(fase="conoscenza", turni=1)

        mock_carica.return_value = []
        mock_estrai.return_value = _profilo_vuoto()

        await elabora_decisione_onboarding(db, sess)

        db.flush.assert_awaited()

    @pytest.mark.asyncio
    @patch("app.core.onboarding.estrai_profilo")
    @patch("app.core.onboarding.carica_conversazione")
    async def test_priorita_campo_chi_e_prima_di_tutto(
        self, mock_carica, mock_estrai
    ):
        """Se tutti i campi sono mancanti, chi_e viene chiesto per primo."""
        db = _mock_db()
        sess = _mock_sessione(fase="conoscenza", turni=1)

        mock_carica.return_value = [{"role": "user", "content": "..."}]
        mock_estrai.return_value = _profilo_vuoto()

        decisione = await elabora_decisione_onboarding(db, sess)

        assert decisione.azione == AzioneDecisore.chiedi_campo_mancante
        assert decisione.campo_da_chiedere == "chi_e"

    @pytest.mark.asyncio
    @patch("app.core.onboarding.estrai_profilo")
    @patch("app.core.onboarding.carica_conversazione")
    async def test_turni_1_sotto_tetto_chiede_campo(
        self, mock_carica, mock_estrai
    ):
        """Un turno prima del tetto, il decisore chiede ancora campi."""
        db = _mock_db()
        sess = _mock_sessione(
            fase="conoscenza",
            turni=TETTO_TURNI_NARRATIVI - 1,
        )

        mock_carica.return_value = [{"role": "user", "content": "..."}]
        mock_estrai.return_value = _profilo_vuoto()

        decisione = await elabora_decisione_onboarding(db, sess)

        assert decisione.azione == AzioneDecisore.chiedi_campo_mancante

    @pytest.mark.asyncio
    @patch("app.core.onboarding.estrai_profilo")
    @patch("app.core.onboarding.carica_conversazione")
    async def test_solo_obbligatori_mancanti_chiede_opzionale(
        self, mock_carica, mock_estrai
    ):
        """Se chi_e, motivo, stile_cognitivo sono ok ma opzionali mancano,
        chiede tempo_disponibile (primo opzionale per priorità)."""
        db = _mock_db()
        sess = _mock_sessione(fase="conoscenza", turni=3)

        profilo = ProfiloEstratto(
            chi_e=_campo_alta("studente"),
            motivo=_campo_alta("esame"),
            stile_cognitivo=_campo_alta("visuale"),
            tempo_disponibile=_campo_bassa(),
            vissuto_scolastico=_campo_bassa(),
        )
        mock_carica.return_value = [{"role": "user", "content": "..."}]
        mock_estrai.return_value = profilo

        decisione = await elabora_decisione_onboarding(db, sess)

        assert decisione.azione == AzioneDecisore.chiedi_campo_mancante
        assert decisione.campo_da_chiedere == "tempo_disponibile"

    @pytest.mark.asyncio
    @patch("app.core.onboarding.estrai_profilo")
    @patch("app.core.onboarding.carica_conversazione")
    async def test_stato_orchestratore_none_trattato_come_accoglienza(
        self, mock_carica, mock_estrai
    ):
        """Se stato_orchestratore è None, la fase è 'accoglienza' → nessuna decisione."""
        db = _mock_db()
        sess = MagicMock()
        sess.id = uuid.uuid4()
        sess.stato_orchestratore = None

        risultato = await elabora_decisione_onboarding(db, sess)
        assert risultato is None
        mock_estrai.assert_not_called()

    @pytest.mark.asyncio
    @patch("app.core.onboarding.estrai_profilo")
    @patch("app.core.onboarding.carica_conversazione")
    async def test_profilo_con_media_confidenza_e_completo(
        self, mock_carica, mock_estrai
    ):
        """Campi con confidenza media contano come completi → chiudi narrativa."""
        db = _mock_db()
        sess = _mock_sessione(fase="conoscenza", turni=4)

        profilo = ProfiloEstratto(
            chi_e=_campo_alta("studente"),
            motivo=CampoConConfidenza(valore="curiosità", confidenza="media"),
            stile_cognitivo=CampoConConfidenza(valore="pratico", confidenza="media"),
            tempo_disponibile=_campo_alta("30 min"),
            vissuto_scolastico=CampoConConfidenza(valore="ok", confidenza="media"),
        )
        mock_carica.return_value = [{"role": "user", "content": "..."}]
        mock_estrai.return_value = profilo

        decisione = await elabora_decisione_onboarding(db, sess)

        assert decisione.azione == AzioneDecisore.chiudi_narrativa
        assert sess.stato_orchestratore["fase_onboarding"] == "placement"

    @pytest.mark.asyncio
    @patch("app.core.onboarding.estrai_profilo")
    @patch("app.core.onboarding.carica_conversazione")
    async def test_conversazione_passata_a_estrattore(
        self, mock_carica, mock_estrai
    ):
        """L'estrattore riceve la conversazione dal DB."""
        db = _mock_db()
        sess = _mock_sessione(fase="conoscenza", turni=1)

        conversazione_mock = [
            {"role": "assistant", "content": "Ciao!"},
            {"role": "user", "content": "Sono Marco, studio ingegneria"},
            {"role": "assistant", "content": "Piacere Marco!"},
        ]
        mock_carica.return_value = conversazione_mock
        mock_estrai.return_value = _profilo_vuoto()

        await elabora_decisione_onboarding(db, sess)

        mock_estrai.assert_awaited_once_with(conversazione_mock)
