"""Test B39.4.1 — Fix completa_onboarding scrittura profilo (ONB-01).

Verifica che completa_onboarding scriva profilo_sintetizzato, contesto_personale
e preferenze_tutor sull'utente usando il profilo estratto dalla conversazione.
"""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.core.onboarding import (
    _costruisci_contesto_personale,
    _costruisci_preferenze_tutor,
    _costruisci_profilo_sintetizzato,
    completa_onboarding,
)
from app.db.models.utenti import OnboardingStato
from app.schemas.onboarding import CampoConConfidenza, ProfiloEstratto

# ===================================================================
# Helper
# ===================================================================

def _profilo_completo() -> ProfiloEstratto:
    """Profilo con tutti i campi a confidenza alta."""
    return ProfiloEstratto(
        chi_e=CampoConConfidenza(valore="Studente liceo scientifico", confidenza="alta"),
        motivo=CampoConConfidenza(valore="Preparazione maturità", confidenza="alta"),
        stile_cognitivo=CampoConConfidenza(valore="Visivo, preferisce esempi", confidenza="media"),
        tempo_disponibile=CampoConConfidenza(valore="30 minuti al giorno", confidenza="alta"),
        vissuto_scolastico=CampoConConfidenza(
            valore="Buono in algebra, debole in geometria", confidenza="media",
        ),
    )


def _profilo_parziale() -> ProfiloEstratto:
    """Profilo con solo 2 campi con confidenza sufficiente."""
    return ProfiloEstratto(
        chi_e=CampoConConfidenza(valore="Universitario ingegneria", confidenza="alta"),
        motivo=CampoConConfidenza(valore="Recupero esame analisi", confidenza="media"),
        stile_cognitivo=CampoConConfidenza(valore=None, confidenza="bassa"),
        tempo_disponibile=CampoConConfidenza(valore=None, confidenza="bassa"),
        vissuto_scolastico=CampoConConfidenza(valore=None, confidenza="bassa"),
    )


def _profilo_vuoto() -> ProfiloEstratto:
    """Profilo con tutti i campi a bassa confidenza."""
    campo = CampoConConfidenza(valore=None, confidenza="bassa")
    return ProfiloEstratto(
        chi_e=campo, motivo=campo, stile_cognitivo=campo,
        tempo_disponibile=campo, vissuto_scolastico=campo,
    )


def _mock_sessione(stato_orchestratore=None):
    sess = MagicMock()
    sess.id = uuid.uuid4()
    sess.utente_id = uuid.uuid4()
    sess.stato = "attiva"
    sess.tipo = "onboarding"
    sess.stato_orchestratore = stato_orchestratore or {
        "fase_onboarding": "conclusione",
    }
    sess.created_at = datetime.now(timezone.utc)
    sess.completed_at = None
    sess.durata_effettiva_min = None
    sess.nodi_lavorati = []
    return sess


def _mock_utente():
    utente = MagicMock()
    utente.id = uuid.uuid4()
    utente.contesto_personale = None
    utente.preferenze_tutor = None
    utente.profilo_sintetizzato = None
    utente.profilo_sintetizzato_at = None
    utente.onboarding_stato = OnboardingStato.IN_PROGRESS
    utente.materie_attive = ["matematica"]
    return utente


# ===================================================================
# Test: _costruisci_profilo_sintetizzato
# ===================================================================

class TestCostruisciProfiloSintetizzato:
    def test_profilo_completo(self):
        profilo = _profilo_completo()
        risultato = _costruisci_profilo_sintetizzato(profilo)

        assert risultato["chi_e"] == "Studente liceo scientifico"
        assert risultato["motivo"] == "Preparazione maturità"
        assert risultato["stile_cognitivo"] == "Visivo, preferisce esempi"
        assert risultato["tempo_disponibile"] == "30 minuti al giorno"
        assert risultato["vissuto_scolastico"] == "Buono in algebra, debole in geometria"
        assert len(risultato) == 5

    def test_profilo_parziale_esclude_bassa_confidenza(self):
        profilo = _profilo_parziale()
        risultato = _costruisci_profilo_sintetizzato(profilo)

        assert risultato["chi_e"] == "Universitario ingegneria"
        assert risultato["motivo"] == "Recupero esame analisi"
        assert "stile_cognitivo" not in risultato
        assert "tempo_disponibile" not in risultato
        assert "vissuto_scolastico" not in risultato
        assert len(risultato) == 2

    def test_profilo_vuoto_ritorna_dict_vuoto(self):
        profilo = _profilo_vuoto()
        risultato = _costruisci_profilo_sintetizzato(profilo)
        assert risultato == {}


# ===================================================================
# Test: _costruisci_contesto_personale
# ===================================================================

class TestCostruisciContestoPersonale:
    def test_include_solo_campi_biografici(self):
        profilo = _profilo_completo()
        risultato = _costruisci_contesto_personale(profilo)

        assert "chi_e" in risultato
        assert "motivo" in risultato
        assert "vissuto_scolastico" in risultato
        # Non deve includere campi di preferenza
        assert "stile_cognitivo" not in risultato
        assert "tempo_disponibile" not in risultato

    def test_profilo_vuoto(self):
        profilo = _profilo_vuoto()
        risultato = _costruisci_contesto_personale(profilo)
        assert risultato == {}


# ===================================================================
# Test: _costruisci_preferenze_tutor
# ===================================================================

class TestCostruisciPreferenzeTutor:
    def test_include_solo_campi_preferenza(self):
        profilo = _profilo_completo()
        risultato = _costruisci_preferenze_tutor(profilo)

        assert "stile_cognitivo" in risultato
        assert "tempo_disponibile" in risultato
        # Non deve includere campi biografici
        assert "chi_e" not in risultato
        assert "motivo" not in risultato
        assert "vissuto_scolastico" not in risultato

    def test_profilo_parziale_senza_preferenze(self):
        profilo = _profilo_parziale()
        risultato = _costruisci_preferenze_tutor(profilo)
        assert risultato == {}


# ===================================================================
# Test: completa_onboarding — scrittura profilo da estratto
# ===================================================================

class TestCompletaOnboardingProfilo:
    @pytest.mark.asyncio
    @patch("app.core.onboarding._inizializza_stato_nodi")
    @patch("app.core.onboarding.grafo_knowledge")
    async def test_scrive_profilo_sintetizzato_da_estratto(self, mock_grafo, mock_init):
        """ONB-01: profilo_sintetizzato viene popolato dal profilo estratto."""
        db = AsyncMock()
        profilo = _profilo_completo()
        sessione = _mock_sessione(stato_orchestratore={
            "fase_onboarding": "conclusione",
            "profilo_estratto": profilo.model_dump(),
        })
        utente = _mock_utente()

        mock_grafo.caricato = False
        mock_init.return_value = 0

        await completa_onboarding(db=db, sessione=sessione, utente=utente)

        # profilo_sintetizzato scritto con i 5 campi
        assert utente.profilo_sintetizzato is not None
        assert utente.profilo_sintetizzato["chi_e"] == "Studente liceo scientifico"
        assert utente.profilo_sintetizzato["motivo"] == "Preparazione maturità"
        assert len(utente.profilo_sintetizzato) == 5

        # timestamp scritto
        assert utente.profilo_sintetizzato_at is not None

    @pytest.mark.asyncio
    @patch("app.core.onboarding._inizializza_stato_nodi")
    @patch("app.core.onboarding.grafo_knowledge")
    async def test_scrive_contesto_personale_da_estratto(self, mock_grafo, mock_init):
        """contesto_personale costruito automaticamente dal profilo estratto."""
        db = AsyncMock()
        profilo = _profilo_completo()
        sessione = _mock_sessione(stato_orchestratore={
            "fase_onboarding": "conclusione",
            "profilo_estratto": profilo.model_dump(),
        })
        utente = _mock_utente()

        mock_grafo.caricato = False
        mock_init.return_value = 0

        await completa_onboarding(db=db, sessione=sessione, utente=utente)

        assert utente.contesto_personale is not None
        assert "chi_e" in utente.contesto_personale
        assert "motivo" in utente.contesto_personale
        assert "vissuto_scolastico" in utente.contesto_personale

    @pytest.mark.asyncio
    @patch("app.core.onboarding._inizializza_stato_nodi")
    @patch("app.core.onboarding.grafo_knowledge")
    async def test_scrive_preferenze_tutor_da_estratto(self, mock_grafo, mock_init):
        """preferenze_tutor costruite automaticamente dal profilo estratto."""
        db = AsyncMock()
        profilo = _profilo_completo()
        sessione = _mock_sessione(stato_orchestratore={
            "fase_onboarding": "conclusione",
            "profilo_estratto": profilo.model_dump(),
        })
        utente = _mock_utente()

        mock_grafo.caricato = False
        mock_init.return_value = 0

        await completa_onboarding(db=db, sessione=sessione, utente=utente)

        assert utente.preferenze_tutor is not None
        assert "stile_cognitivo" in utente.preferenze_tutor
        assert "tempo_disponibile" in utente.preferenze_tutor

    @pytest.mark.asyncio
    @patch("app.core.onboarding._inizializza_stato_nodi")
    @patch("app.core.onboarding.grafo_knowledge")
    async def test_payload_override_su_profilo_estratto(self, mock_grafo, mock_init):
        """I parametri espliciti dal payload hanno priorità sul profilo estratto."""
        db = AsyncMock()
        profilo = _profilo_completo()
        sessione = _mock_sessione(stato_orchestratore={
            "fase_onboarding": "conclusione",
            "profilo_estratto": profilo.model_dump(),
        })
        utente = _mock_utente()

        mock_grafo.caricato = False
        mock_init.return_value = 0

        override_ctx = {"custom": "context"}
        override_pref = {"custom": "prefs"}

        await completa_onboarding(
            db=db, sessione=sessione, utente=utente,
            contesto_personale=override_ctx,
            preferenze_tutor=override_pref,
        )

        # Il payload ha priorità
        assert utente.contesto_personale == override_ctx
        assert utente.preferenze_tutor == override_pref
        # Ma profilo_sintetizzato viene sempre dal profilo estratto
        assert utente.profilo_sintetizzato is not None
        assert len(utente.profilo_sintetizzato) == 5

    @pytest.mark.asyncio
    @patch("app.core.onboarding._inizializza_stato_nodi")
    @patch("app.core.onboarding.grafo_knowledge")
    async def test_profilo_parziale_scrive_solo_campi_validi(self, mock_grafo, mock_init):
        """Con profilo parziale, solo i campi con confidenza alta/media vengono scritti."""
        db = AsyncMock()
        profilo = _profilo_parziale()
        sessione = _mock_sessione(stato_orchestratore={
            "fase_onboarding": "conclusione",
            "profilo_estratto": profilo.model_dump(),
        })
        utente = _mock_utente()

        mock_grafo.caricato = False
        mock_init.return_value = 0

        await completa_onboarding(db=db, sessione=sessione, utente=utente)

        # profilo_sintetizzato ha solo 2 campi
        assert len(utente.profilo_sintetizzato) == 2
        assert "chi_e" in utente.profilo_sintetizzato
        assert "motivo" in utente.profilo_sintetizzato

        # contesto_personale ha 2 campi (chi_e, motivo — vissuto_scolastico è bassa)
        assert len(utente.contesto_personale) == 2

        # preferenze_tutor vuoto (stile_cognitivo e tempo_disponibile sono bassa)
        assert utente.preferenze_tutor is None

    @pytest.mark.asyncio
    @patch("app.core.onboarding._inizializza_stato_nodi")
    @patch("app.core.onboarding.grafo_knowledge")
    async def test_senza_profilo_estratto_nessun_crash(self, mock_grafo, mock_init):
        """Senza profilo_estratto nello stato, la funzione funziona come prima."""
        db = AsyncMock()
        sessione = _mock_sessione(stato_orchestratore={
            "fase_onboarding": "conclusione",
        })
        utente = _mock_utente()

        mock_grafo.caricato = False
        mock_init.return_value = 0

        await completa_onboarding(db=db, sessione=sessione, utente=utente)

        # Nessun profilo scritto (nessun dato disponibile)
        assert utente.profilo_sintetizzato is None
        assert utente.contesto_personale is None
        assert utente.preferenze_tutor is None

    @pytest.mark.asyncio
    @patch("app.core.onboarding._inizializza_stato_nodi")
    @patch("app.core.onboarding.grafo_knowledge")
    async def test_profilo_estratto_malformato_non_blocca(self, mock_grafo, mock_init):
        """Se profilo_estratto è malformato, la funzione non crasha."""
        db = AsyncMock()
        sessione = _mock_sessione(stato_orchestratore={
            "fase_onboarding": "conclusione",
            "profilo_estratto": {"dati_corrotti": True},
        })
        utente = _mock_utente()

        mock_grafo.caricato = False
        mock_init.return_value = 0

        # Non deve sollevare eccezioni
        await completa_onboarding(db=db, sessione=sessione, utente=utente)

        # Sessione completata comunque
        assert sessione.stato == "completata"

    @pytest.mark.asyncio
    @patch("app.core.onboarding._inizializza_stato_nodi")
    @patch("app.core.onboarding.grafo_knowledge")
    async def test_onboarding_stato_aggiornato_a_completed(self, mock_grafo, mock_init):
        """onboarding_stato viene aggiornato a COMPLETED."""
        db = AsyncMock()
        sessione = _mock_sessione()
        utente = _mock_utente()

        mock_grafo.caricato = False
        mock_init.return_value = 0

        await completa_onboarding(db=db, sessione=sessione, utente=utente)

        assert utente.onboarding_stato == OnboardingStato.COMPLETED

    @pytest.mark.asyncio
    @patch("app.core.onboarding._inizializza_stato_nodi")
    @patch("app.core.onboarding.grafo_knowledge")
    async def test_profilo_vuoto_estratto_non_scrive_dict_vuoti(self, mock_grafo, mock_init):
        """Se il profilo estratto ha tutti i campi a bassa, non scrive dict vuoti."""
        db = AsyncMock()
        profilo = _profilo_vuoto()
        sessione = _mock_sessione(stato_orchestratore={
            "fase_onboarding": "conclusione",
            "profilo_estratto": profilo.model_dump(),
        })
        utente = _mock_utente()

        mock_grafo.caricato = False
        mock_init.return_value = 0

        await completa_onboarding(db=db, sessione=sessione, utente=utente)

        # profilo_sintetizzato scritto ma vuoto (dict vuoto è comunque scritto,
        # è il segnale che l'estrazione è avvenuta)
        assert utente.profilo_sintetizzato == {}
        assert utente.profilo_sintetizzato_at is not None
        # contesto e preferenze vuoti → non scritti (rimangono None)
        assert utente.contesto_personale is None
        assert utente.preferenze_tutor is None
