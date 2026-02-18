"""Test Blocco 10 — Gamification: achievement, streak, statistiche.

Test critici di dominio:
- Achievement seed (8 definizioni dal brief)
- Condizioni achievement (nodi_completati, esercizi_risolti, streak, tema_completato,
  esercizi_consecutivi_ok, sessioni_completate)
- Calcolo streak (HARD CONSTRAINT)
- Aggiornamento statistiche giornaliere
- Lista achievement con progresso
- API endpoint /achievement
- Schemas Pydantic
"""

from __future__ import annotations

import uuid
from datetime import date, timedelta
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.core.gamification import (
    ACHIEVEMENT_SEED,
    calcola_streak,
    lista_achievement_utente,
    seed_achievement,
    verifica_achievement,
)

# ===================================================================
# Test: seed achievement
# ===================================================================


class TestSeedAchievement:
    def test_seed_contiene_8_definizioni(self):
        assert len(ACHIEVEMENT_SEED) == 8

    def test_seed_ids_unici(self):
        ids = [a["id"] for a in ACHIEVEMENT_SEED]
        assert len(ids) == len(set(ids))

    def test_seed_tipi_validi(self):
        tipi_validi = {"sigillo", "medaglia", "costellazione"}
        for a in ACHIEVEMENT_SEED:
            assert a["tipo"] in tipi_validi, f"Tipo invalido: {a['tipo']}"

    def test_seed_condizioni_hanno_tipo_e_valore(self):
        for a in ACHIEVEMENT_SEED:
            assert "tipo" in a["condizione"]
            assert "valore" in a["condizione"]

    def test_seed_ids_dal_brief(self):
        ids_attesi = {
            "primo_nodo",
            "cinque_nodi",
            "dieci_esercizi",
            "streak_3",
            "streak_7",
            "primo_tema",
            "perfetto_5",
            "prima_sessione",
        }
        ids_reali = {a["id"] for a in ACHIEVEMENT_SEED}
        assert ids_reali == ids_attesi

    @pytest.mark.asyncio
    async def test_seed_esegue_upsert(self):
        db = AsyncMock()
        db.execute = AsyncMock()
        db.flush = AsyncMock()

        count = await seed_achievement(db)
        assert count == 8
        assert db.execute.call_count == 8


# ===================================================================
# Test: calcolo streak (HARD CONSTRAINT)
# ===================================================================


class TestCalcoloStreak:
    """HARD CONSTRAINT: streak = giorni consecutivi con obiettivo_raggiunto.

    - Si conta all'indietro da oggi (o da ieri se oggi non ha studiato)
    - Un giorno senza record = obiettivo_raggiunto = false
    """

    @pytest.mark.asyncio
    async def test_streak_zero_nessun_record(self):
        """Nessun record → streak 0."""
        db = AsyncMock()
        result = MagicMock()
        result.all.return_value = []
        db.execute = AsyncMock(return_value=result)

        streak = await calcola_streak(uuid.uuid4(), db)
        assert streak == 0

    @pytest.mark.asyncio
    async def test_streak_oggi_ok(self):
        """Oggi obiettivo raggiunto → streak 1."""
        oggi = date.today()
        db = AsyncMock()
        result = MagicMock()
        result.all.return_value = [
            MagicMock(data=oggi, obiettivo_raggiunto=True),
        ]
        db.execute = AsyncMock(return_value=result)

        streak = await calcola_streak(uuid.uuid4(), db)
        assert streak == 1

    @pytest.mark.asyncio
    async def test_streak_tre_giorni_consecutivi(self):
        """Tre giorni consecutivi → streak 3."""
        oggi = date.today()
        db = AsyncMock()
        result = MagicMock()
        result.all.return_value = [
            MagicMock(data=oggi, obiettivo_raggiunto=True),
            MagicMock(data=oggi - timedelta(days=1), obiettivo_raggiunto=True),
            MagicMock(data=oggi - timedelta(days=2), obiettivo_raggiunto=True),
        ]
        db.execute = AsyncMock(return_value=result)

        streak = await calcola_streak(uuid.uuid4(), db)
        assert streak == 3

    @pytest.mark.asyncio
    async def test_streak_interrotto_da_giorno_false(self):
        """Giorno con obiettivo_raggiunto=false interrompe lo streak."""
        oggi = date.today()
        db = AsyncMock()
        result = MagicMock()
        result.all.return_value = [
            MagicMock(data=oggi, obiettivo_raggiunto=True),
            MagicMock(data=oggi - timedelta(days=1), obiettivo_raggiunto=False),
            MagicMock(data=oggi - timedelta(days=2), obiettivo_raggiunto=True),
        ]
        db.execute = AsyncMock(return_value=result)

        streak = await calcola_streak(uuid.uuid4(), db)
        assert streak == 1

    @pytest.mark.asyncio
    async def test_streak_interrotto_da_giorno_mancante(self):
        """Giorno senza record interrompe lo streak (gap = false)."""
        oggi = date.today()
        db = AsyncMock()
        result = MagicMock()
        # Oggi e 2 giorni fa ok, ma ieri manca
        result.all.return_value = [
            MagicMock(data=oggi, obiettivo_raggiunto=True),
            MagicMock(data=oggi - timedelta(days=2), obiettivo_raggiunto=True),
        ]
        db.execute = AsyncMock(return_value=result)

        streak = await calcola_streak(uuid.uuid4(), db)
        assert streak == 1

    @pytest.mark.asyncio
    async def test_streak_parte_da_ieri(self):
        """Se oggi non ha studiato, parte da ieri."""
        oggi = date.today()
        ieri = oggi - timedelta(days=1)
        db = AsyncMock()
        result = MagicMock()
        result.all.return_value = [
            MagicMock(data=ieri, obiettivo_raggiunto=True),
            MagicMock(data=ieri - timedelta(days=1), obiettivo_raggiunto=True),
        ]
        db.execute = AsyncMock(return_value=result)

        streak = await calcola_streak(uuid.uuid4(), db)
        assert streak == 2

    @pytest.mark.asyncio
    async def test_streak_zero_oggi_e_ieri_non_ok(self):
        """Se né oggi né ieri sono ok → streak 0."""
        oggi = date.today()
        db = AsyncMock()
        result = MagicMock()
        result.all.return_value = [
            MagicMock(data=oggi - timedelta(days=2), obiettivo_raggiunto=True),
        ]
        db.execute = AsyncMock(return_value=result)

        streak = await calcola_streak(uuid.uuid4(), db)
        assert streak == 0


# ===================================================================
# Test: verifica achievement
# ===================================================================


class TestVerificaAchievement:
    """Test che le condizioni achievement vengano valutate correttamente."""

    @pytest.mark.asyncio
    async def test_nessun_achievement_se_nessuna_definizione(self):
        """Se non ci sono definizioni, lista vuota."""
        db = AsyncMock()
        # Definizioni vuote
        result_def = MagicMock()
        result_def.scalars.return_value.all.return_value = []
        # Sbloccati vuoti
        result_sbl = MagicMock()
        result_sbl.scalars.return_value.all.return_value = []

        db.execute = AsyncMock(side_effect=[result_def, result_sbl])

        nuovi = await verifica_achievement(uuid.uuid4(), db)
        assert nuovi == []

    @pytest.mark.asyncio
    async def test_achievement_gia_sbloccato_non_ricalcolato(self):
        """Achievement già sbloccato non viene verificato di nuovo."""
        db = AsyncMock()

        defn = MagicMock()
        defn.id = "primo_nodo"
        defn.condizione = {"tipo": "nodi_completati", "valore": 1}

        result_def = MagicMock()
        result_def.scalars.return_value.all.return_value = [defn]

        result_sbl = MagicMock()
        result_sbl.scalars.return_value.all.return_value = ["primo_nodo"]

        db.execute = AsyncMock(side_effect=[result_def, result_sbl])

        nuovi = await verifica_achievement(uuid.uuid4(), db)
        assert nuovi == []

    @pytest.mark.asyncio
    async def test_sblocca_primo_nodo(self):
        """Sblocca 'primo_nodo' quando nodi_completati >= 1."""
        db = AsyncMock()

        defn = MagicMock()
        defn.id = "primo_nodo"
        defn.nome = "Primo passo!"
        defn.tipo = "sigillo"
        defn.condizione = {"tipo": "nodi_completati", "valore": 1}

        result_def = MagicMock()
        result_def.scalars.return_value.all.return_value = [defn]

        result_sbl = MagicMock()
        result_sbl.scalars.return_value.all.return_value = []

        # Metrica: count nodi completati = 1
        result_count = MagicMock()
        result_count.scalar_one.return_value = 1

        db.execute = AsyncMock(side_effect=[result_def, result_sbl, result_count])
        db.add = MagicMock()
        db.flush = AsyncMock()

        nuovi = await verifica_achievement(uuid.uuid4(), db)
        assert len(nuovi) == 1
        assert nuovi[0]["id"] == "primo_nodo"
        assert nuovi[0]["nome"] == "Primo passo!"

    @pytest.mark.asyncio
    async def test_non_sblocca_se_condizione_non_soddisfatta(self):
        """Non sblocca se il valore corrente è inferiore al richiesto."""
        db = AsyncMock()

        defn = MagicMock()
        defn.id = "cinque_nodi"
        defn.nome = "Cinque su cinque"
        defn.tipo = "sigillo"
        defn.condizione = {"tipo": "nodi_completati", "valore": 5}

        result_def = MagicMock()
        result_def.scalars.return_value.all.return_value = [defn]

        result_sbl = MagicMock()
        result_sbl.scalars.return_value.all.return_value = []

        # Metrica: count nodi completati = 3 (< 5)
        result_count = MagicMock()
        result_count.scalar_one.return_value = 3

        db.execute = AsyncMock(side_effect=[result_def, result_sbl, result_count])

        nuovi = await verifica_achievement(uuid.uuid4(), db)
        assert nuovi == []

    @pytest.mark.asyncio
    async def test_sblocca_prima_sessione(self):
        """Sblocca 'prima_sessione' quando sessioni_completate >= 1."""
        db = AsyncMock()

        defn = MagicMock()
        defn.id = "prima_sessione"
        defn.nome = "Si parte!"
        defn.tipo = "sigillo"
        defn.condizione = {"tipo": "sessioni_completate", "valore": 1}

        result_def = MagicMock()
        result_def.scalars.return_value.all.return_value = [defn]

        result_sbl = MagicMock()
        result_sbl.scalars.return_value.all.return_value = []

        # Metrica: sessioni completate = 1
        result_count = MagicMock()
        result_count.scalar_one.return_value = 1

        db.execute = AsyncMock(side_effect=[result_def, result_sbl, result_count])
        db.add = MagicMock()
        db.flush = AsyncMock()

        nuovi = await verifica_achievement(uuid.uuid4(), db)
        assert len(nuovi) == 1
        assert nuovi[0]["id"] == "prima_sessione"

    @pytest.mark.asyncio
    async def test_sblocca_multipli_in_un_turno(self):
        """Può sbloccare più achievement in un singolo turno."""
        db = AsyncMock()

        defn1 = MagicMock()
        defn1.id = "primo_nodo"
        defn1.nome = "Primo passo!"
        defn1.tipo = "sigillo"
        defn1.condizione = {"tipo": "nodi_completati", "valore": 1}

        defn2 = MagicMock()
        defn2.id = "prima_sessione"
        defn2.nome = "Si parte!"
        defn2.tipo = "sigillo"
        defn2.condizione = {"tipo": "sessioni_completate", "valore": 1}

        result_def = MagicMock()
        result_def.scalars.return_value.all.return_value = [defn1, defn2]

        result_sbl = MagicMock()
        result_sbl.scalars.return_value.all.return_value = []

        # Metriche: nodi=1, sessioni=1
        result_nodi = MagicMock()
        result_nodi.scalar_one.return_value = 1
        result_sessioni = MagicMock()
        result_sessioni.scalar_one.return_value = 1

        db.execute = AsyncMock(
            side_effect=[result_def, result_sbl, result_nodi, result_sessioni]
        )
        db.add = MagicMock()
        db.flush = AsyncMock()

        nuovi = await verifica_achievement(uuid.uuid4(), db)
        assert len(nuovi) == 2
        ids = {a["id"] for a in nuovi}
        assert ids == {"primo_nodo", "prima_sessione"}


# ===================================================================
# Test: lista achievement con progresso
# ===================================================================


class TestListaAchievement:
    @pytest.mark.asyncio
    async def test_lista_con_sbloccato_e_prossimo(self):
        """Lista mostra sbloccati e prossimi con progresso."""
        from datetime import datetime, timezone

        db = AsyncMock()

        # Definizioni
        defn1 = MagicMock()
        defn1.id = "primo_nodo"
        defn1.nome = "Primo passo!"
        defn1.tipo = "sigillo"
        defn1.descrizione = None
        defn1.condizione = {"tipo": "nodi_completati", "valore": 1}

        defn2 = MagicMock()
        defn2.id = "cinque_nodi"
        defn2.nome = "Cinque su cinque"
        defn2.tipo = "sigillo"
        defn2.descrizione = None
        defn2.condizione = {"tipo": "nodi_completati", "valore": 5}

        result_def = MagicMock()
        result_def.scalars.return_value.all.return_value = [defn1, defn2]

        # Sbloccati: solo primo_nodo
        ach_utente = MagicMock()
        ach_utente.achievement_id = "primo_nodo"
        ach_utente.sbloccato_at = datetime(2026, 2, 18, tzinfo=timezone.utc)
        result_sbl = MagicMock()
        result_sbl.scalars.return_value.all.return_value = [ach_utente]

        # Metrica per cinque_nodi: 3 nodi completati
        result_count = MagicMock()
        result_count.scalar_one.return_value = 3

        db.execute = AsyncMock(
            side_effect=[result_def, result_sbl, result_count]
        )

        risultato = await lista_achievement_utente(uuid.uuid4(), db)
        assert len(risultato["sbloccati"]) == 1
        assert risultato["sbloccati"][0]["id"] == "primo_nodo"

        assert len(risultato["prossimi"]) == 1
        assert risultato["prossimi"][0]["id"] == "cinque_nodi"
        assert risultato["prossimi"][0]["progresso"]["corrente"] == 3
        assert risultato["prossimi"][0]["progresso"]["richiesto"] == 5


# ===================================================================
# Test: Pydantic schemas
# ===================================================================


class TestSchemas:
    def test_achievement_sbloccato_schema(self):
        from app.schemas.achievement import AchievementSbloccato

        a = AchievementSbloccato(
            id="primo_nodo",
            nome="Primo passo!",
            tipo="sigillo",
            sbloccato_at="2026-02-18T00:00:00+00:00",
        )
        assert a.id == "primo_nodo"
        assert a.descrizione is None

    def test_achievement_prossimo_schema(self):
        from app.schemas.achievement import AchievementProssimo, ProgressoAchievement

        p = AchievementProssimo(
            id="cinque_nodi",
            nome="Cinque su cinque",
            tipo="sigillo",
            condizione={"tipo": "nodi_completati", "valore": 5},
            progresso=ProgressoAchievement(corrente=3, richiesto=5),
        )
        assert p.progresso.corrente == 3

    def test_lista_response_schema(self):
        from app.schemas.achievement import (
            AchievementProssimo,
            AchievementSbloccato,
            ListaAchievementResponse,
            ProgressoAchievement,
        )

        resp = ListaAchievementResponse(
            sbloccati=[
                AchievementSbloccato(id="x", nome="X", tipo="sigillo"),
            ],
            prossimi=[
                AchievementProssimo(
                    id="y",
                    nome="Y",
                    tipo="medaglia",
                    condizione={"tipo": "streak", "valore": 3},
                    progresso=ProgressoAchievement(corrente=1, richiesto=3),
                ),
            ],
        )
        assert len(resp.sbloccati) == 1
        assert len(resp.prossimi) == 1


# ===================================================================
# Test: integrazione turno → achievement
# ===================================================================


class TestIntegrazioneTurno:
    @pytest.mark.asyncio
    async def test_verifica_achievement_safe_funziona(self):
        """_verifica_achievement_safe chiama verifica_achievement con db."""
        from app.core.turno import _verifica_achievement_safe

        with patch(
            "app.core.gamification.verifica_achievement",
            return_value=[{"id": "primo_nodo", "nome": "Primo passo!", "tipo": "sigillo"}],
        ) as mock_va:
            db = AsyncMock()
            uid = uuid.uuid4()
            result = await _verifica_achievement_safe(uid, db)
            assert len(result) == 1
            mock_va.assert_called_once_with(uid, db)

    @pytest.mark.asyncio
    async def test_verifica_achievement_safe_non_blocca_su_errore(self):
        """Se verifica_achievement fallisce, ritorna lista vuota."""
        from app.core.turno import _verifica_achievement_safe

        with patch(
            "app.core.gamification.verifica_achievement",
            side_effect=RuntimeError("DB down"),
        ):
            db = AsyncMock()
            result = await _verifica_achievement_safe(uuid.uuid4(), db)
            assert result == []

    @pytest.mark.asyncio
    async def test_aggiorna_stats_safe_non_blocca_su_errore(self):
        """Se aggiorna_statistiche fallisce, non blocca il turno."""
        from app.core.turno import _aggiorna_stats_safe

        with patch(
            "app.core.gamification.aggiorna_statistiche_giornaliere",
            side_effect=RuntimeError("DB down"),
        ):
            db = AsyncMock()
            # Non deve sollevare eccezione
            await _aggiorna_stats_safe(uuid.uuid4(), db)
