"""Test E2E — walkthrough sezione 18 del brief con mock LLM.

Verifica il flusso completo:
1. Primo turno tutor (spiegazione) → text_delta + segnale concetto_spiegato
2. Turno esercizio → azione proponi_esercizio
3. Risposta corretta → segnale risposta_esercizio + promozione dopo 3 esercizi
4. Achievement sbloccato dopo promozione
5. Turno senza messaggio utente (primo turno automatico)
"""

from __future__ import annotations

import uuid
from dataclasses import dataclass, field
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.core.turno import esegui_turno

# ===================================================================
# Shared fixtures
# ===================================================================


@dataclass
class FakeRisultato:
    testo_completo: str = "Testo tutor"
    azioni: list = field(default_factory=list)
    segnali: list = field(default_factory=list)
    token_input: int = 100
    token_output: int = 50
    costo_stimato: float = 0.001
    modello: str = "test-model"
    stop_reason: str = "end_turn"


@dataclass
class FakeContextPackage:
    system: str = "test system"
    messages: list = field(default_factory=list)
    modello: str = "test-model"
    tipo_sessione: str = "studio"


@dataclass
class FakeTurno:
    id: int = 1


@dataclass
class FakeSessione:
    stato_orchestratore: dict = field(default_factory=lambda: {"nodo_focale_id": "nodo_A"})


def _make_db_mock(sessione=None):
    """Crea un AsyncMock per il database con sessione configurata."""
    db = AsyncMock()
    db.commit = AsyncMock()
    db.refresh = AsyncMock()
    sess = sessione or FakeSessione()
    result = MagicMock()
    result.scalar_one_or_none.return_value = sess
    db.execute = AsyncMock(return_value=result)
    return db


# ===================================================================
# Test E2E: flusso spiegazione → esercizio → promozione
# ===================================================================


class TestFlussoE2ESpiegazionePromozione:
    """Walkthrough sezione 18: spiegazione → 3 esercizi → promozione → achievement."""

    @pytest.mark.asyncio
    async def test_passo_1_primo_turno_spiegazione(self):
        """Passo 1: il tutor spiega un concetto, emette concetto_spiegato."""

        async def fake_llm(**kwargs):
            yield {"tipo": "text_delta", "testo": "Gli insiemi numerici sono..."}
            yield {
                "tipo": "tool_use",
                "name": "concetto_spiegato",
                "input": {
                    "nodo_id": "mat_algebra2_insiemi_numerici",
                    "punti_coperti": ["definizione", "esempi"],
                },
                "categoria": "segnale",
            }
            yield {"tipo": "stop", "risultato": FakeRisultato(
                testo_completo="Gli insiemi numerici sono..."
            )}

        db = _make_db_mock()

        with (
            patch("app.core.turno.assembla_context_package",
                  return_value=FakeContextPackage()),
            patch("app.core.turno.chiama_tutor", side_effect=fake_llm),
            patch("app.core.turno.salva_turno", return_value=FakeTurno()),
            patch("app.core.turno.processa_segnali", return_value=[]) as mock_segnali,
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente=None,
            ):
                eventi.append(ev)

        # Verifiche
        text_deltas = [e for e in eventi if e["event"] == "text_delta"]
        assert len(text_deltas) >= 1
        assert "insiemi" in text_deltas[0]["data"]["testo"].lower()

        # processa_segnali chiamato con il segnale concetto_spiegato
        mock_segnali.assert_called_once()
        segnali_passati = mock_segnali.call_args[1]["segnali"]
        assert any(s["name"] == "concetto_spiegato" for s in segnali_passati)

        # turno_completo emesso
        completo = [e for e in eventi if e["event"] == "turno_completo"]
        assert len(completo) == 1

    @pytest.mark.asyncio
    async def test_passo_2_turno_con_azione_esercizio(self):
        """Passo 2: il tutor propone un esercizio via tool use."""

        async def fake_llm(**kwargs):
            yield {"tipo": "text_delta", "testo": "Proviamo un esercizio."}
            yield {
                "tipo": "tool_use",
                "name": "proponi_esercizio",
                "input": {
                    "nodo_id": "mat_algebra2_insiemi_numerici",
                    "difficolta": "base",
                },
                "categoria": "azione",
            }
            yield {"tipo": "stop", "risultato": FakeRisultato()}

        db = _make_db_mock()
        azione_result = {
            "tipo": "proponi_esercizio",
            "params": {
                "esercizio_id": "ex_1",
                "testo": "Classifica...",
                "difficolta": 1,
                "nodo_id": "mat_algebra2_insiemi_numerici",
            },
        }

        with (
            patch("app.core.turno.assembla_context_package",
                  return_value=FakeContextPackage()),
            patch("app.core.turno.chiama_tutor", side_effect=fake_llm),
            patch("app.core.turno.salva_turno", return_value=FakeTurno()),
            patch("app.core.turno.esegui_azione", return_value=azione_result),
            patch("app.core.turno.processa_segnali", return_value=[]),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="Ok, sono pronto",
            ):
                eventi.append(ev)

        azioni = [e for e in eventi if e["event"] == "azione"]
        assert len(azioni) == 1
        assert azioni[0]["data"]["tipo"] == "proponi_esercizio"
        assert azioni[0]["data"]["params"]["esercizio_id"] == "ex_1"

    @pytest.mark.asyncio
    async def test_passo_3_promozione_dopo_terzo_esercizio(self):
        """Passo 3: dopo il 3° esercizio corretto, promozione + achievement."""

        async def fake_llm(**kwargs):
            yield {"tipo": "text_delta", "testo": "Bravo!"}
            yield {
                "tipo": "tool_use",
                "name": "risposta_esercizio",
                "input": {
                    "esercizio_id": "ex_3",
                    "nodo_focale": "nodo_A",
                    "esito": "primo_tentativo",
                },
                "categoria": "segnale",
            }
            yield {"tipo": "stop", "risultato": FakeRisultato(testo_completo="Bravo!")}

        db = _make_db_mock(FakeSessione(
            stato_orchestratore={"nodo_focale_id": "nodo_B"}
        ))

        promozione = [{
            "nodo_id": "nodo_A",
            "nuovo_livello": "operativo",
            "nodi_sbloccati": ["nodo_B"],
        }]

        with (
            patch("app.core.turno.assembla_context_package",
                  return_value=FakeContextPackage()),
            patch("app.core.turno.chiama_tutor", side_effect=fake_llm),
            patch("app.core.turno.salva_turno", return_value=FakeTurno()),
            patch("app.core.turno.processa_segnali", return_value=promozione),
            patch("app.core.turno.aggiorna_nodo_dopo_promozione",
                  return_value="nodo_B") as mock_promo,
            patch("app.core.gamification.verifica_achievement",
                  return_value=[{"id": "primo_nodo", "nome": "Primo passo!",
                                 "tipo": "sigillo"}]),
            patch("app.core.gamification.aggiorna_statistiche_giornaliere"),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="√2 è irrazionale",
            ):
                eventi.append(ev)

        # Promozione processata
        mock_promo.assert_called_once()

        # Achievement emesso
        achievements = [e for e in eventi if e["event"] == "achievement"]
        assert len(achievements) == 1
        assert achievements[0]["data"]["id"] == "primo_nodo"
        assert achievements[0]["data"]["nome"] == "Primo passo!"

    @pytest.mark.asyncio
    async def test_passo_4_errore_llm_gestito(self):
        """Se Claude va in timeout, il turno emette un evento errore."""

        async def fake_llm_errore(**kwargs):
            yield {"tipo": "errore", "messaggio": "Timeout dopo 60s"}

        db = _make_db_mock()

        with (
            patch("app.core.turno.assembla_context_package",
                  return_value=FakeContextPackage()),
            patch("app.core.turno.chiama_tutor", side_effect=fake_llm_errore),
            patch("app.core.turno.salva_turno", return_value=FakeTurno()),
        ):
            eventi = []
            async for ev in esegui_turno(
                db=db,
                sessione_id=uuid.uuid4(),
                utente_id=uuid.uuid4(),
                messaggio_utente="ciao",
            ):
                eventi.append(ev)

        errori = [e for e in eventi if e["event"] == "errore"]
        assert len(errori) == 1
        assert "Timeout" in errori[0]["data"]["messaggio"]

        # Nessun turno_completo dopo errore
        completo = [e for e in eventi if e["event"] == "turno_completo"]
        assert len(completo) == 0


# ===================================================================
# Test: API percorsi schemas
# ===================================================================


class TestAPIPercorsiSchemas:
    """Verifica che le API percorsi e temi si importino senza errori."""

    def test_router_percorsi_ha_2_route(self):
        from app.api.percorsi import router
        paths = [r.path for r in router.routes]
        assert "/percorsi/" in paths
        assert "/percorsi/{percorso_id}/mappa" in paths

    def test_router_temi_ha_2_route(self):
        from app.api.temi import router
        paths = [r.path for r in router.routes]
        assert "/temi/" in paths
        assert "/temi/{tema_id}" in paths

    def test_router_utente_ha_statistiche(self):
        from app.api.utente import router
        paths = [r.path for r in router.routes]
        assert "/utente/me/statistiche" in paths


# ===================================================================
# Test: statistiche helper
# ===================================================================


class TestStatisticheHelper:
    @pytest.mark.asyncio
    async def test_stats_periodo_vuoto(self):
        """Periodo senza dati ritorna tutti zeri."""
        from app.api.utente import _stats_periodo

        db = AsyncMock()
        result = MagicMock()
        result.one.return_value = (0, 0, 0, 0, 0)
        db.execute = AsyncMock(return_value=result)

        stats = await _stats_periodo(db, uuid.uuid4(), None, None)
        assert stats["minuti_studio"] == 0
        assert stats["esercizi_svolti"] == 0
        assert stats["giorni_attivi"] == 0
