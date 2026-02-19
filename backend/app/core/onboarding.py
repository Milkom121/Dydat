"""Onboarding Manager — flusso di conoscenza iniziale.

Fasi: accoglienza → conoscenza → placement → piano → conclusione.
- accoglienza: presentazione e prima domanda
- conoscenza: raccolta info studente (max TURNI_CONOSCENZA_MAX turni)
- placement: mini-test diagnostico su nodi gateway
- piano: proposta piano studio basata sui risultati placement
- conclusione: riepilogo e avvio percorso

Transizioni guidate da segnali: transizione_fase e placement_esito.
Al completamento: salva profilo, crea percorso, inizializza stato_nodi_utente.
Punto di partenza personalizzato via placement o segnale punto_partenza_suggerito.
"""

from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm.attributes import flag_modified

from app.db.models.stato_utente import StatoNodoUtente
from app.db.models.utenti import PercorsoUtente, Sessione, TurnoConversazione, Utente
from app.grafo.algoritmi import ordinamento_topologico
from app.grafo.struttura import grafo_knowledge

logger = logging.getLogger(__name__)

# Dopo quanti turni in "conoscenza" si passa a "placement"
TURNI_CONOSCENZA_MAX = 6

# Fasi onboarding in ordine
FASI_ONBOARDING = ("accoglienza", "conoscenza", "placement", "piano", "conclusione")


async def crea_utente_temporaneo(db: AsyncSession) -> Utente:
    """Crea un utente temporaneo (UUID, senza email/password)."""
    utente = Utente(
        materie_attive=["matematica"],
    )
    db.add(utente)
    await db.flush()
    logger.info("Utente temporaneo creato: %s", utente.id)
    return utente


async def crea_sessione_onboarding(
    db: AsyncSession,
    utente_id: uuid.UUID,
) -> Sessione:
    """Crea una sessione di tipo onboarding con fase accoglienza."""
    sessione = Sessione(
        utente_id=utente_id,
        tipo="onboarding",
        stato="attiva",
        nodi_lavorati=[],
        stato_orchestratore={
            "fase_onboarding": "accoglienza",
            "turni_conoscenza": 0,
        },
    )
    db.add(sessione)
    await db.flush()
    logger.info("Sessione onboarding creata: %s", sessione.id)
    return sessione


async def aggiorna_fase_onboarding(
    db: AsyncSession,
    sessione: Sessione,
) -> str:
    """Aggiorna automaticamente la fase onboarding e ritorna la fase corrente.

    Logica automatica (senza segnale):
    - Primo turno: accoglienza
    - Dopo 1° risposta studente: conoscenza
    - Dopo TURNI_CONOSCENZA_MAX turni in conoscenza: placement

    Le transizioni placement→piano e piano→conclusione sono guidate
    dal segnale transizione_fase emesso dal LLM.
    """
    stato = sessione.stato_orchestratore or {}
    fase = stato.get("fase_onboarding", "accoglienza")

    if fase == "accoglienza":
        # Conta turni utente nella sessione
        result = await db.execute(
            select(func.count()).where(
                TurnoConversazione.sessione_id == sessione.id,
                TurnoConversazione.ruolo == "utente",
            )
        )
        turni_utente = result.scalar_one()

        if turni_utente >= 1:
            fase = "conoscenza"
            stato["fase_onboarding"] = fase
            stato["turni_conoscenza"] = 0
            sessione.stato_orchestratore = stato
            flag_modified(sessione, "stato_orchestratore")
            await db.flush()
            logger.info("Onboarding: accoglienza → conoscenza")

    elif fase == "conoscenza":
        turni = stato.get("turni_conoscenza", 0) + 1
        stato["turni_conoscenza"] = turni

        if turni >= TURNI_CONOSCENZA_MAX:
            fase = "placement"
            stato["fase_onboarding"] = fase
            sessione.stato_orchestratore = stato
            flag_modified(sessione, "stato_orchestratore")
            await db.flush()
            logger.info("Onboarding: conoscenza → placement (max turni)")
        else:
            sessione.stato_orchestratore = stato
            flag_modified(sessione, "stato_orchestratore")
            await db.flush()

    # placement e piano: transizioni guidate da segnale transizione_fase
    # (gestite in elaborazione.py → _processa_transizione_fase)

    return fase


async def transizione_fase_onboarding(
    db: AsyncSession,
    sessione: Sessione,
    fase_destinazione: str,
) -> str:
    """Transizione esplicita a una fase onboarding (guidata da segnale LLM).

    Valida che la transizione sia legale:
    - placement → piano
    - piano → conclusione

    Returns:
        La nuova fase, o la fase corrente se la transizione è illegale.
    """
    stato = sessione.stato_orchestratore or {}
    fase_corrente = stato.get("fase_onboarding", "accoglienza")

    transizioni_valide = {
        "placement": "piano",
        "piano": "conclusione",
    }

    fase_attesa = transizioni_valide.get(fase_corrente)
    if fase_attesa != fase_destinazione:
        logger.warning(
            "Transizione onboarding illegale: %s → %s (attesa: %s)",
            fase_corrente, fase_destinazione, fase_attesa,
        )
        return fase_corrente

    stato["fase_onboarding"] = fase_destinazione
    sessione.stato_orchestratore = stato
    flag_modified(sessione, "stato_orchestratore")
    await db.flush()
    logger.info("Onboarding: %s → %s (segnale)", fase_corrente, fase_destinazione)
    return fase_destinazione


def seleziona_nodi_gateway() -> list[dict]:
    """Seleziona nodi gateway per il placement test.

    I nodi gateway sono nodi operativi "di confine" nel grafo: nodi che,
    se padroneggiati, indicano che tutto ciò che viene prima è acquisito.

    Strategia: seleziona nodi con in-degree > 0 e out-degree > 0 (nodi
    interni nel DAG) a diversi livelli di profondità.

    Returns:
        Lista di dict con {nodo_id, nome, tema_id, profondita} — max 5 nodi.
    """
    if not grafo_knowledge.caricato:
        return []

    grafo = grafo_knowledge.grafo
    ordine = ordinamento_topologico(grafo)

    # Filtra solo nodi operativi
    nodi_operativi = [
        nid for nid in ordine
        if grafo.nodes.get(nid, {}).get("tipo_nodo") == "operativo"
    ]

    if not nodi_operativi:
        return []

    # Seleziona nodi distribuiti uniformemente nel percorso
    n_target = min(5, len(nodi_operativi))
    if n_target == 0:
        return []

    step = max(1, len(nodi_operativi) // n_target)
    gateway_indices = [i * step for i in range(n_target)]
    # Assicura che l'ultimo nodo selezionato sia negli ultimi nodi
    if gateway_indices[-1] < len(nodi_operativi) - 1:
        gateway_indices[-1] = len(nodi_operativi) - 1

    gateways = []
    for idx in gateway_indices:
        if idx < len(nodi_operativi):
            nid = nodi_operativi[idx]
            attrs = grafo.nodes.get(nid, {})
            gateways.append({
                "nodo_id": nid,
                "nome": attrs.get("nome", nid),
                "tema_id": attrs.get("tema_id", ""),
                "profondita": idx,
            })

    return gateways


async def completa_onboarding(
    db: AsyncSession,
    sessione: Sessione,
    utente: Utente,
    contesto_personale: dict | None = None,
    preferenze_tutor: dict | None = None,
) -> dict:
    """Completa l'onboarding: salva profilo, crea percorso, inizializza stato.

    Usa i risultati del placement test (se disponibili) per determinare
    il punto di partenza. Fallback su punto_partenza_suggerito dal LLM.

    Returns:
        Dict con {percorso_id, nodo_iniziale, nodi_inizializzati}.
    """
    # 1. Salva profilo utente
    if contesto_personale:
        utente.contesto_personale = contesto_personale
    if preferenze_tutor:
        utente.preferenze_tutor = preferenze_tutor
    await db.flush()

    # 2. Chiudi sessione onboarding
    sessione.stato = "completata"
    sessione.completed_at = datetime.now(timezone.utc)
    durata = (
        datetime.now(timezone.utc) - sessione.created_at
    ).total_seconds() / 60
    sessione.durata_effettiva_min = int(durata)
    await db.flush()

    # 3. Gestisci punto di partenza: placement_risultati > punto_partenza_suggerito
    stato = sessione.stato_orchestratore or {}
    nodo_override = None

    placement_risultati = stato.get("placement_risultati", {})
    if placement_risultati and grafo_knowledge.caricato:
        nodo_override = _determina_nodo_da_placement(placement_risultati)

    if not nodo_override:
        punto_partenza = stato.get("punto_partenza_suggerito")
        if punto_partenza and grafo_knowledge.caricato:
            nodo_override = _trova_nodo_per_tema(punto_partenza)

    # 4. Crea percorso binario_1
    percorso = PercorsoUtente(
        utente_id=utente.id,
        tipo="binario_1",
        materia="matematica",
        nome="Percorso Matematica",
        stato="attivo",
        nodo_iniziale_override=nodo_override,
    )
    db.add(percorso)
    await db.flush()

    # 5. Inizializza stato_nodi_utente per tutti i nodi operativi
    nodi_init = await _inizializza_stato_nodi(
        db, utente.id, nodo_override
    )

    logger.info(
        "Onboarding completato: utente=%s, percorso=%d, "
        "nodo_override=%s, nodi_init=%d, placement=%s",
        utente.id,
        percorso.id,
        nodo_override,
        nodi_init,
        bool(placement_risultati),
    )

    return {
        "percorso_id": percorso.id,
        "nodo_iniziale": nodo_override,
        "nodi_inizializzati": nodi_init,
    }


def _trova_nodo_per_tema(tema_o_concetto: str) -> str | None:
    """Cerca nel grafo il nodo più vicino al tema/concetto indicato.

    Match per nome nodo o tema_id (case-insensitive, substring).
    """
    if not grafo_knowledge.caricato:
        return None

    query = tema_o_concetto.lower().replace(" ", "_")
    grafo = grafo_knowledge.grafo

    # Match per tema_id (spazi normalizzati a underscore)
    for nodo_id, attrs in grafo.nodes(data=True):
        if attrs.get("tipo_nodo") != "operativo":
            continue
        tema_id = attrs.get("tema_id", "")
        if tema_id and query in tema_id.lower():
            return nodo_id

    # Fallback: match per nodo_id
    for nodo_id in grafo.nodes:
        if query in nodo_id.lower():
            return nodo_id

    return None


def _determina_nodo_da_placement(placement_risultati: dict) -> str | None:
    """Determina il nodo di partenza dai risultati del placement test.

    Strategia: trova il primo nodo gateway con esito negativo
    (il primo concetto che lo studente non padroneggia).
    Se tutti positivi, usa l'ultimo nodo gateway come partenza.
    """
    esiti = placement_risultati.get("esiti", [])
    if not esiti:
        return None

    # Trova il primo nodo con esito negativo
    for esito in esiti:
        if esito.get("padroneggiato") is False:
            return esito.get("nodo_id")

    # Tutti padroneggiati: parti dall'ultimo + 1 (prossimo nel grafo)
    ultimo_nodo = esiti[-1].get("nodo_id")
    if ultimo_nodo and grafo_knowledge.caricato:
        grafo = grafo_knowledge.grafo
        ordine = ordinamento_topologico(grafo)
        nodi_operativi = [
            nid for nid in ordine
            if grafo.nodes.get(nid, {}).get("tipo_nodo") == "operativo"
        ]
        if ultimo_nodo in nodi_operativi:
            idx = nodi_operativi.index(ultimo_nodo)
            if idx + 1 < len(nodi_operativi):
                return nodi_operativi[idx + 1]

    return ultimo_nodo


async def _inizializza_stato_nodi(
    db: AsyncSession,
    utente_id: uuid.UUID,
    nodo_override: str | None,
) -> int:
    """Inizializza stato_nodi_utente per tutti i nodi operativi.

    Se c'è un nodo_override, i nodi precedenti nell'ordine topologico
    vengono marcati come operativo + presunto=true.

    Returns:
        Numero di nodi inizializzati.
    """
    if not grafo_knowledge.caricato:
        return 0

    grafo = grafo_knowledge.grafo
    ordine = ordinamento_topologico(grafo)
    nodi_prima_override: set[str] = set()

    if nodo_override and nodo_override in ordine:
        idx = ordine.index(nodo_override)
        nodi_prima_override = set(ordine[:idx])

    from sqlalchemy.dialects.postgresql import insert as pg_insert

    count = 0
    for nodo_id in ordine:
        attrs = grafo.nodes.get(nodo_id, {})
        if attrs.get("tipo_nodo") != "operativo":
            continue

        if nodo_id in nodi_prima_override:
            # Nodo prima del punto di partenza → operativo + presunto
            stmt = pg_insert(StatoNodoUtente).values(
                utente_id=utente_id,
                nodo_id=nodo_id,
                livello="operativo",
                presunto=True,
                spiegazione_data=False,
                ultima_interazione=datetime.now(timezone.utc),
            )
            stmt = stmt.on_conflict_do_nothing(
                index_elements=["utente_id", "nodo_id"]
            )
        else:
            # Nodo normale → non_iniziato
            stmt = pg_insert(StatoNodoUtente).values(
                utente_id=utente_id,
                nodo_id=nodo_id,
                livello="non_iniziato",
                presunto=False,
                spiegazione_data=False,
                ultima_interazione=datetime.now(timezone.utc),
            )
            stmt = stmt.on_conflict_do_nothing(
                index_elements=["utente_id", "nodo_id"]
            )

        await db.execute(stmt)
        count += 1

    await db.flush()
    return count
