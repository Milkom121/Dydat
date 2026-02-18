"""API utente — profilo, preferenze, statistiche."""

from datetime import date, timedelta

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_utente_corrente
from app.core.gamification import calcola_streak
from app.db.crud.utenti import aggiorna_profilo
from app.db.engine import get_db
from app.db.models.gamification import StatisticaGiornaliera
from app.db.models.stato_utente import StatoNodoUtente
from app.db.models.utenti import Sessione, Utente
from app.schemas.utente import PreferenzeRequest, UtenteResponse

router = APIRouter(prefix="/utente", tags=["utente"])


@router.get("/me", response_model=UtenteResponse)
async def get_profilo(utente: Utente = Depends(get_utente_corrente)):
    """Ritorna il profilo dell'utente autenticato."""
    return utente


@router.put("/me/preferenze", response_model=UtenteResponse)
async def update_preferenze(
    payload: PreferenzeRequest,
    utente: Utente = Depends(get_utente_corrente),
    db: AsyncSession = Depends(get_db),
):
    """Aggiorna le preferenze del tutor per l'utente autenticato."""
    preferenze = utente.preferenze_tutor or {}
    aggiornamenti = payload.model_dump(exclude_none=True)
    preferenze.update(aggiornamenti)
    try:
        utente = await aggiorna_profilo(db, utente.id, preferenze_tutor=preferenze)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    return utente


@router.get("/me/statistiche")
async def get_statistiche(
    utente: Utente = Depends(get_utente_corrente),
    db: AsyncSession = Depends(get_db),
):
    """Statistiche utente: settimana, mese, sempre."""
    oggi = date.today()
    inizio_settimana = oggi - timedelta(days=oggi.weekday())  # Lunedì
    inizio_mese = oggi.replace(day=1)

    # Nodi completati (totale)
    result_nodi = await db.execute(
        select(func.count()).where(
            StatoNodoUtente.utente_id == utente.id,
            StatoNodoUtente.livello == "operativo",
            StatoNodoUtente.presunto == False,  # noqa: E712
        )
    )
    nodi_completati_totale = result_nodi.scalar_one()

    # Sessioni completate (totale)
    result_sessioni = await db.execute(
        select(func.count()).where(
            Sessione.utente_id == utente.id,
            Sessione.stato == "completata",
        )
    )
    sessioni_totale = result_sessioni.scalar_one()

    # Streak corrente
    streak = await calcola_streak(utente.id, db)

    # Statistiche per periodo (da statistiche_giornaliere)
    stats_settimana = await _stats_periodo(
        db, utente.id, inizio_settimana, oggi
    )
    stats_mese = await _stats_periodo(
        db, utente.id, inizio_mese, oggi
    )
    stats_sempre = await _stats_periodo(db, utente.id, None, None)

    return {
        "streak": streak,
        "nodi_completati": nodi_completati_totale,
        "sessioni_completate": sessioni_totale,
        "settimana": stats_settimana,
        "mese": stats_mese,
        "sempre": stats_sempre,
    }


async def _stats_periodo(
    db: AsyncSession,
    utente_id,
    da: date | None,
    a: date | None,
) -> dict:
    """Aggrega statistiche giornaliere per un periodo."""
    query = select(
        func.coalesce(func.sum(StatisticaGiornaliera.minuti_studio), 0),
        func.coalesce(func.sum(StatisticaGiornaliera.esercizi_svolti), 0),
        func.coalesce(func.sum(StatisticaGiornaliera.esercizi_corretti), 0),
        func.coalesce(func.sum(StatisticaGiornaliera.nodi_completati), 0),
        func.count(),
    ).where(StatisticaGiornaliera.utente_id == utente_id)

    if da is not None:
        query = query.where(StatisticaGiornaliera.data >= da)
    if a is not None:
        query = query.where(StatisticaGiornaliera.data <= a)

    result = await db.execute(query)
    row = result.one()

    return {
        "minuti_studio": row[0],
        "esercizi_svolti": row[1],
        "esercizi_corretti": row[2],
        "nodi_completati": row[3],
        "giorni_attivi": row[4],
    }
