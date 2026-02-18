"""Test base: health check + import modelli."""

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app


@pytest.mark.asyncio
async def test_health_check():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_import_all_models():
    """Verifica che tutti i 17 modelli si importino senza errori."""
    from app.db.models import (
        AchievementDefinizione,
        AchievementUtente,
        Esercizio,
        Nodo,
        NodoTema,
        NotaUtente,
        PercorsoUtente,
        Relazione,
        Sessione,
        StatisticaGiornaliera,
        StatoNodoUtente,
        StatoTemaUtente,
        StoricoErrori,
        StoricoEsercizi,
        Tema,
        TurnoConversazione,
        Utente,
    )

    models = [
        Nodo, Tema, NodoTema, Relazione, Esercizio,
        StatoNodoUtente, StoricoEsercizi, StoricoErrori,
        Utente, PercorsoUtente, Sessione, TurnoConversazione,
        NotaUtente, StatoTemaUtente, AchievementDefinizione,
        AchievementUtente, StatisticaGiornaliera,
    ]
    assert len(models) == 17


def test_all_tables_registered():
    """Verifica che Base.metadata contenga tutte le tabelle attese."""
    import app.db.models  # noqa: F401 — registra tutti i modelli
    from app.db.base import Base

    expected_tables = {
        "nodi", "temi", "nodi_temi", "relazioni", "esercizi",
        "stato_nodi_utente", "storico_esercizi", "storico_errori",
        "utenti", "percorsi_utente", "sessioni", "turni_conversazione",
        "note_utente", "stato_temi_utente", "achievement_definizioni",
        "achievement_utente", "statistiche_giornaliere",
    }
    actual_tables = set(Base.metadata.tables.keys())
    assert expected_tables == actual_tables
