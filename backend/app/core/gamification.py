"""Achievement checker + statistiche.

Verifica condizioni achievement dopo ogni turno.
Calcolo streak (giorni consecutivi obiettivo raggiunto).
Aggiornamento statistiche_giornaliere.

Achievement Loop 1 (8 definizioni dal brief):
  - primo_nodo: nodi_completati >= 1
  - cinque_nodi: nodi_completati >= 5
  - dieci_esercizi: esercizi_risolti >= 10
  - streak_3: streak >= 3
  - streak_7: streak >= 7
  - primo_tema: tema_completato >= 1
  - perfetto_5: esercizi_consecutivi_ok >= 5 (max corrente su qualsiasi nodo)
  - prima_sessione: sessioni_completate >= 1
"""

from __future__ import annotations

import logging
import uuid
from datetime import date, datetime, timedelta, timezone

from sqlalchemy import func, select
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.gamification import (
    AchievementDefinizione,
    AchievementUtente,
    StatisticaGiornaliera,
)
from app.db.models.stato_utente import StatoNodoUtente, StoricoEsercizi
from app.db.models.utenti import Sessione, Utente

logger = logging.getLogger(__name__)

# 8 achievement iniziali dal brief
ACHIEVEMENT_SEED: list[dict] = [
    {
        "id": "primo_nodo",
        "nome": "Primo passo!",
        "tipo": "sigillo",
        "condizione": {"tipo": "nodi_completati", "valore": 1},
    },
    {
        "id": "cinque_nodi",
        "nome": "Cinque su cinque",
        "tipo": "sigillo",
        "condizione": {"tipo": "nodi_completati", "valore": 5},
    },
    {
        "id": "dieci_esercizi",
        "nome": "Pratica costante",
        "tipo": "sigillo",
        "condizione": {"tipo": "esercizi_risolti", "valore": 10},
    },
    {
        "id": "streak_3",
        "nome": "Tre giorni!",
        "tipo": "medaglia",
        "condizione": {"tipo": "streak", "valore": 3},
    },
    {
        "id": "streak_7",
        "nome": "Una settimana!",
        "tipo": "medaglia",
        "condizione": {"tipo": "streak", "valore": 7},
    },
    {
        "id": "primo_tema",
        "nome": "Tema completato",
        "tipo": "costellazione",
        "condizione": {"tipo": "tema_completato", "valore": 1},
    },
    {
        "id": "perfetto_5",
        "nome": "Cinque di fila!",
        "tipo": "medaglia",
        "condizione": {"tipo": "esercizi_consecutivi_ok", "valore": 5},
    },
    {
        "id": "prima_sessione",
        "nome": "Si parte!",
        "tipo": "sigillo",
        "condizione": {"tipo": "sessioni_completate", "valore": 1},
    },
]


async def seed_achievement(db: AsyncSession) -> int:
    """Inserisce le definizioni achievement iniziali (UPSERT idempotente).

    Returns:
        Numero di achievement inseriti/aggiornati.
    """
    count = 0
    for ach in ACHIEVEMENT_SEED:
        stmt = pg_insert(AchievementDefinizione).values(
            id=ach["id"],
            nome=ach["nome"],
            tipo=ach["tipo"],
            condizione=ach["condizione"],
        )
        stmt = stmt.on_conflict_do_update(
            index_elements=["id"],
            set_={
                "nome": ach["nome"],
                "tipo": ach["tipo"],
                "condizione": ach["condizione"],
            },
        )
        await db.execute(stmt)
        count += 1
    await db.flush()
    logger.info("Seed achievement: %d definizioni", count)
    return count


async def verifica_achievement(
    utente_id: uuid.UUID, db: AsyncSession
) -> list[dict]:
    """Verifica e sblocca achievement dopo un turno. Ritorna lista di nuovi achievement.

    Per ogni achievement non ancora sbloccato, verifica se la condizione è soddisfatta.
    Se sì, inserisce in achievement_utente e lo aggiunge alla lista di ritorno.
    """
    # Carica definizioni e achievement già sbloccati
    result_def = await db.execute(select(AchievementDefinizione))
    definizioni = list(result_def.scalars().all())

    result_sbloccati = await db.execute(
        select(AchievementUtente.achievement_id).where(
            AchievementUtente.utente_id == utente_id
        )
    )
    ids_sbloccati = set(result_sbloccati.scalars().all())

    # Filtra solo quelli non ancora sbloccati
    da_verificare = [d for d in definizioni if d.id not in ids_sbloccati]
    if not da_verificare:
        return []

    # Calcola metriche necessarie (lazy, solo se servono)
    metriche: dict[str, int | None] = {}
    nuovi: list[dict] = []

    for defn in da_verificare:
        condizione = defn.condizione or {}
        tipo_cond = condizione.get("tipo", "")
        valore_richiesto = condizione.get("valore", 0)

        valore_corrente = await _calcola_metrica(
            db, utente_id, tipo_cond, metriche
        )

        if valore_corrente is not None and valore_corrente >= valore_richiesto:
            # Sblocca!
            db.add(AchievementUtente(
                utente_id=utente_id,
                achievement_id=defn.id,
            ))
            await db.flush()

            nuovi.append({
                "id": defn.id,
                "nome": defn.nome,
                "tipo": defn.tipo,
            })
            logger.info(
                "Achievement sbloccato: %s (%s) per utente=%s",
                defn.id, defn.nome, utente_id,
            )

    return nuovi


async def _calcola_metrica(
    db: AsyncSession,
    utente_id: uuid.UUID,
    tipo_cond: str,
    cache: dict[str, int | None],
) -> int | None:
    """Calcola una metrica per le condizioni achievement, con cache per evitare query ripetute."""
    if tipo_cond in cache:
        return cache[tipo_cond]

    valore: int | None = None

    if tipo_cond == "nodi_completati":
        result = await db.execute(
            select(func.count()).where(
                StatoNodoUtente.utente_id == utente_id,
                StatoNodoUtente.livello == "operativo",
                StatoNodoUtente.presunto == False,  # noqa: E712
            )
        )
        valore = result.scalar_one()

    elif tipo_cond == "esercizi_risolti":
        result = await db.execute(
            select(func.count()).where(
                StoricoEsercizi.utente_id == utente_id,
                StoricoEsercizi.esito.in_(["primo_tentativo", "con_guida"]),
            )
        )
        valore = result.scalar_one()

    elif tipo_cond == "streak":
        valore = await calcola_streak(utente_id, db)

    elif tipo_cond == "tema_completato":
        valore = await _conta_temi_completati(db, utente_id)

    elif tipo_cond == "esercizi_consecutivi_ok":
        result = await db.execute(
            select(func.max(StatoNodoUtente.esercizi_consecutivi_ok)).where(
                StatoNodoUtente.utente_id == utente_id,
            )
        )
        valore = result.scalar_one() or 0

    elif tipo_cond == "sessioni_completate":
        result = await db.execute(
            select(func.count()).where(
                Sessione.utente_id == utente_id,
                Sessione.stato == "completata",
            )
        )
        valore = result.scalar_one()

    cache[tipo_cond] = valore
    return valore


async def _conta_temi_completati(
    db: AsyncSession, utente_id: uuid.UUID
) -> int:
    """Conta i temi in cui tutti i nodi operativi sono a livello >= operativo.

    Un tema è completato quando tutti i suoi nodi (tipo_nodo != 'contesto')
    hanno livello 'operativo' per l'utente.
    """
    from app.db.models.grafo import Nodo, NodoTema

    # Temi con almeno un nodo (join via nodi_temi)
    result_temi = await db.execute(
        select(NodoTema.tema_id, func.count().label("totale"))
        .join(Nodo, Nodo.id == NodoTema.nodo_id)
        .where(Nodo.tipo_nodo != "contesto")
        .group_by(NodoTema.tema_id)
    )
    temi_totali = {row.tema_id: row.totale for row in result_temi.all()}

    if not temi_totali:
        return 0

    # Nodi operativi per tema
    result_operativi = await db.execute(
        select(NodoTema.tema_id, func.count().label("completati"))
        .join(Nodo, Nodo.id == NodoTema.nodo_id)
        .join(
            StatoNodoUtente,
            (StatoNodoUtente.nodo_id == Nodo.id)
            & (StatoNodoUtente.utente_id == utente_id)
            & (StatoNodoUtente.livello == "operativo"),
        )
        .where(Nodo.tipo_nodo != "contesto")
        .group_by(NodoTema.tema_id)
    )
    temi_operativi = {row.tema_id: row.completati for row in result_operativi.all()}

    completati = 0
    for tema_id, totale in temi_totali.items():
        if temi_operativi.get(tema_id, 0) >= totale:
            completati += 1

    return completati


async def calcola_streak(utente_id: uuid.UUID, db: AsyncSession) -> int:
    """Calcola lo streak corrente (giorni consecutivi con obiettivo raggiunto).

    HARD CONSTRAINT sulla logica (dal brief):
    1. Query statistiche_giornaliere per l'utente, ordinate per data DESC
    2. Contare i giorni consecutivi con obiettivo_raggiunto = true
       partendo da oggi (o da ieri se oggi non ha ancora studiato)
    3. Un giorno senza record equivale a obiettivo_raggiunto = false
    """
    oggi = date.today()

    result = await db.execute(
        select(StatisticaGiornaliera.data, StatisticaGiornaliera.obiettivo_raggiunto)
        .where(StatisticaGiornaliera.utente_id == utente_id)
        .order_by(StatisticaGiornaliera.data.desc())
        .limit(90)  # Massimo 90 giorni indietro
    )
    righe = result.all()

    # Costruisci set di date con obiettivo raggiunto
    date_ok: set[date] = set()
    for riga in righe:
        if riga.obiettivo_raggiunto:
            date_ok.add(riga.data)

    # Parti da oggi; se oggi non è in date_ok, prova ieri
    giorno = oggi
    if giorno not in date_ok:
        giorno = oggi - timedelta(days=1)
        if giorno not in date_ok:
            return 0

    streak = 0
    while giorno in date_ok:
        streak += 1
        giorno -= timedelta(days=1)

    return streak


async def aggiorna_statistiche_giornaliere(
    utente_id: uuid.UUID, db: AsyncSession
) -> None:
    """Aggiorna le statistiche della giornata corrente.

    Incrementa esercizi_svolti e esercizi_corretti basandosi sull'ultimo turno.
    Aggiorna obiettivo_raggiunto se minuti_studio >= obiettivo_giornaliero_min.
    """
    oggi = date.today()

    # UPSERT riga di oggi
    stmt = pg_insert(StatisticaGiornaliera).values(
        utente_id=utente_id,
        data=oggi,
    )
    stmt = stmt.on_conflict_do_nothing(
        index_elements=["utente_id", "data"],
    )
    await db.execute(stmt)
    await db.flush()

    # Calcola statistiche attuali dalla giornata
    # Esercizi svolti oggi (tutti gli esiti)
    inizio_giornata = datetime.combine(oggi, datetime.min.time(), tzinfo=timezone.utc)
    fine_giornata = inizio_giornata + timedelta(days=1)

    result_esercizi = await db.execute(
        select(func.count()).where(
            StoricoEsercizi.utente_id == utente_id,
            StoricoEsercizi.created_at >= inizio_giornata,
            StoricoEsercizi.created_at < fine_giornata,
        )
    )
    esercizi_svolti = result_esercizi.scalar_one()

    result_corretti = await db.execute(
        select(func.count()).where(
            StoricoEsercizi.utente_id == utente_id,
            StoricoEsercizi.created_at >= inizio_giornata,
            StoricoEsercizi.created_at < fine_giornata,
            StoricoEsercizi.esito.in_(["primo_tentativo", "con_guida"]),
        )
    )
    esercizi_corretti = result_corretti.scalar_one()

    # Nodi completati oggi
    result_nodi = await db.execute(
        select(func.count()).where(
            StatoNodoUtente.utente_id == utente_id,
            StatoNodoUtente.livello == "operativo",
            StatoNodoUtente.presunto == False,  # noqa: E712
            StatoNodoUtente.ultima_interazione >= inizio_giornata,
            StatoNodoUtente.ultima_interazione < fine_giornata,
        )
    )
    nodi_completati = result_nodi.scalar_one()

    # Minuti studio: somma durata sessioni di oggi
    result_minuti = await db.execute(
        select(func.coalesce(func.sum(Sessione.durata_effettiva_min), 0)).where(
            Sessione.utente_id == utente_id,
            Sessione.created_at >= inizio_giornata,
            Sessione.created_at < fine_giornata,
        )
    )
    minuti_studio = result_minuti.scalar_one()

    # Obiettivo raggiunto?
    result_utente = await db.execute(
        select(Utente.obiettivo_giornaliero_min).where(Utente.id == utente_id)
    )
    obiettivo_min = result_utente.scalar_one_or_none() or 20
    obiettivo_raggiunto = minuti_studio >= obiettivo_min

    # Aggiorna la riga
    result_stat = await db.execute(
        select(StatisticaGiornaliera).where(
            StatisticaGiornaliera.utente_id == utente_id,
            StatisticaGiornaliera.data == oggi,
        )
    )
    stat = result_stat.scalar_one_or_none()
    if stat:
        stat.esercizi_svolti = esercizi_svolti
        stat.esercizi_corretti = esercizi_corretti
        stat.nodi_completati = nodi_completati
        stat.minuti_studio = minuti_studio
        stat.obiettivo_raggiunto = obiettivo_raggiunto
        await db.flush()

    logger.info(
        "Statistiche giornaliere aggiornate: utente=%s, data=%s, "
        "esercizi=%d, corretti=%d, nodi=%d, minuti=%d, obiettivo=%s",
        utente_id, oggi, esercizi_svolti, esercizi_corretti,
        nodi_completati, minuti_studio, obiettivo_raggiunto,
    )


async def lista_achievement_utente(
    utente_id: uuid.UUID, db: AsyncSession
) -> dict:
    """Ritorna achievement sbloccati + prossimi con progresso.

    Returns:
        {"sbloccati": [...], "prossimi": [...]}
    """
    # Tutte le definizioni
    result_def = await db.execute(select(AchievementDefinizione))
    definizioni = list(result_def.scalars().all())

    # Sbloccati
    result_sbl = await db.execute(
        select(AchievementUtente).where(
            AchievementUtente.utente_id == utente_id
        )
    )
    sbloccati_db = {r.achievement_id: r for r in result_sbl.scalars().all()}

    sbloccati = []
    prossimi = []
    metriche: dict[str, int | None] = {}

    for defn in definizioni:
        condizione = defn.condizione or {}
        tipo_cond = condizione.get("tipo", "")
        valore_richiesto = condizione.get("valore", 0)

        if defn.id in sbloccati_db:
            sbloccati.append({
                "id": defn.id,
                "nome": defn.nome,
                "tipo": defn.tipo,
                "descrizione": defn.descrizione,
                "sbloccato_at": sbloccati_db[defn.id].sbloccato_at.isoformat()
                if sbloccati_db[defn.id].sbloccato_at
                else None,
            })
        else:
            valore_corrente = await _calcola_metrica(
                db, utente_id, tipo_cond, metriche
            )
            prossimi.append({
                "id": defn.id,
                "nome": defn.nome,
                "tipo": defn.tipo,
                "descrizione": defn.descrizione,
                "condizione": condizione,
                "progresso": {
                    "corrente": valore_corrente or 0,
                    "richiesto": valore_richiesto,
                },
            })

    return {"sbloccati": sbloccati, "prossimi": prossimi}
