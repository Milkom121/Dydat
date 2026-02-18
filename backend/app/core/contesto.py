"""Context Builder — assembla i 6 blocchi XML per il system prompt.

Blocco 1: System prompt (fisso)
Blocco 2: Direttiva (da template, situazione corrente)
Blocco 3: Profilo utente
Blocco 4: Contesto attivo (nodo focale + nodi supporto)
Blocco 5: Conversazione nei messages (solo testo)
Blocco 6: Memoria rilevante (placeholder Loop 3)

Blocchi 1-4 e 6 → system prompt (stringa unica).
Blocco 5 → messages (lista di dict role/content).
"""

from __future__ import annotations

import json
import logging
import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm.attributes import flag_modified

from app.db.models.grafo import Esercizio, Nodo, Relazione
from app.db.models.stato_utente import StatoNodoUtente, StoricoEsercizi
from app.db.models.utenti import Sessione, TurnoConversazione, Utente
from app.llm.prompts.direttive import (
    direttiva_esercizio,
    direttiva_feynman,
    direttiva_onboarding,
    direttiva_ripasso_sr,
    direttiva_ripresa_sessione,
    direttiva_spiegazione,
)
from app.llm.prompts.system_prompt import SYSTEM_PROMPT

logger = logging.getLogger(__name__)

# Soglia per troncamento conversazione
SOGLIA_TURNI = 50
TURNI_INIZIALI = 2
TURNI_FINALI = 20


# ---------------------------------------------------------------------------
# Risultato del context builder
# ---------------------------------------------------------------------------

class ContextPackage:
    """Risultato assemblato: system prompt + messages per Claude API."""

    __slots__ = ("system", "messages", "modello")

    def __init__(self, system: str, messages: list[dict], modello: str) -> None:
        self.system = system
        self.messages = messages
        self.modello = modello


# ---------------------------------------------------------------------------
# Funzioni di supporto per caricare dati dal DB
# ---------------------------------------------------------------------------

async def _carica_utente(db: AsyncSession, utente_id: uuid.UUID) -> Utente | None:
    result = await db.execute(select(Utente).where(Utente.id == utente_id))
    return result.scalar_one_or_none()


async def _carica_sessione(db: AsyncSession, sessione_id: uuid.UUID) -> Sessione | None:
    result = await db.execute(select(Sessione).where(Sessione.id == sessione_id))
    return result.scalar_one_or_none()


async def _carica_nodo(db: AsyncSession, nodo_id: str) -> Nodo | None:
    result = await db.execute(select(Nodo).where(Nodo.id == nodo_id))
    return result.scalar_one_or_none()


async def _carica_esercizi_nodo(db: AsyncSession, nodo_id: str) -> list[Esercizio]:
    result = await db.execute(
        select(Esercizio).where(Esercizio.nodo_id == nodo_id).order_by(Esercizio.difficolta)
    )
    return list(result.scalars().all())


async def _carica_stato_nodo_utente(
    db: AsyncSession, utente_id: uuid.UUID, nodo_id: str
) -> StatoNodoUtente | None:
    result = await db.execute(
        select(StatoNodoUtente).where(
            StatoNodoUtente.utente_id == utente_id,
            StatoNodoUtente.nodo_id == nodo_id,
        )
    )
    return result.scalar_one_or_none()


async def _carica_storico_errori_nodo(
    db: AsyncSession, utente_id: uuid.UUID, nodo_id: str, limit: int = 10
) -> list[dict]:
    result = await db.execute(
        select(
            StoricoEsercizi.esito,
            StoricoEsercizi.tipo_errore,
            StoricoEsercizi.created_at,
        )
        .where(
            StoricoEsercizi.utente_id == utente_id,
            StoricoEsercizi.nodo_focale_id == nodo_id,
        )
        .order_by(StoricoEsercizi.created_at.desc())
        .limit(limit)
    )
    return [
        {"esito": esito, "tipo_errore": tipo, "data": str(data)}
        for esito, tipo, data in result.all()
    ]


async def _carica_prerequisiti_diretti(db: AsyncSession, nodo_id: str) -> list[str]:
    """Ritorna gli ID dei prerequisiti bloccanti diretti di un nodo."""
    result = await db.execute(
        select(Relazione.nodo_da).where(
            Relazione.nodo_a == nodo_id,
            Relazione.dipendenza == "bloccante",
        )
    )
    return [row[0] for row in result.all()]


async def _carica_stati_nodi_utente(
    db: AsyncSession, utente_id: uuid.UUID, nodo_ids: list[str]
) -> dict[str, dict]:
    """Carica lo stato utente per una lista di nodi."""
    if not nodo_ids:
        return {}
    result = await db.execute(
        select(StatoNodoUtente).where(
            StatoNodoUtente.utente_id == utente_id,
            StatoNodoUtente.nodo_id.in_(nodo_ids),
        )
    )
    stati = {}
    for stato in result.scalars().all():
        stati[stato.nodo_id] = {
            "livello": stato.livello,
            "spiegazione_data": stato.spiegazione_data,
            "esercizi_completati": stato.esercizi_completati,
            "errori_in_corso": stato.errori_in_corso,
        }
    return stati


async def _carica_conversazione(
    db: AsyncSession, sessione_id: uuid.UUID
) -> list[dict]:
    """Carica i turni di conversazione per i messages Claude (SOLO testo)."""
    result = await db.execute(
        select(TurnoConversazione.ruolo, TurnoConversazione.contenuto, TurnoConversazione.ordine)
        .where(TurnoConversazione.sessione_id == sessione_id)
        .order_by(TurnoConversazione.ordine)
    )
    turni = []
    for ruolo, contenuto, _ordine in result.all():
        if contenuto:
            turni.append({
                "role": "user" if ruolo == "utente" else "assistant",
                "content": contenuto,
            })
    return turni


# ---------------------------------------------------------------------------
# Troncamento conversazione
# ---------------------------------------------------------------------------

def tronca_conversazione(messages: list[dict]) -> list[dict]:
    """Tronca la conversazione se supera SOGLIA_TURNI.

    Mantiene i primi TURNI_INIZIALI e gli ultimi TURNI_FINALI,
    inserendo un messaggio sintetico di raccordo.
    """
    if len(messages) <= SOGLIA_TURNI:
        return messages

    iniziali = messages[:TURNI_INIZIALI]
    finali = messages[-TURNI_FINALI:]
    omessi = len(messages) - TURNI_INIZIALI - TURNI_FINALI

    raccordo = {
        "role": "user",
        "content": (
            f"[Nota di sistema: {omessi} turni omessi per brevità. "
            "La conversazione è continuata normalmente.]"
        ),
    }

    return iniziali + [raccordo] + finali


# ---------------------------------------------------------------------------
# Assemblaggio blocchi XML
# ---------------------------------------------------------------------------

def _blocco_system_prompt() -> str:
    """Blocco 1: system prompt fisso."""
    return f"<system_prompt>\n{SYSTEM_PROMPT}\n</system_prompt>"


def _blocco_direttiva(direttiva: str) -> str:
    """Blocco 2: direttiva generata dalla situazione corrente."""
    return f"<direttiva>\n{direttiva}\n</direttiva>"


def _blocco_profilo_utente(utente: Utente) -> str:
    """Blocco 3: profilo utente."""
    parti = []

    pref = utente.preferenze_tutor
    if pref:
        parti.append(f"Preferenze tutor: {json.dumps(pref, ensure_ascii=False)}")

    ctx = utente.contesto_personale
    if ctx:
        parti.append(f"Contesto personale: {json.dumps(ctx, ensure_ascii=False)}")

    profilo = utente.profilo_sintetizzato
    if profilo:
        parti.append(f"Profilo sintetizzato: {json.dumps(profilo, ensure_ascii=False)}")

    if not parti:
        parti.append("(nessuna informazione disponibile sul profilo)")

    return "<profilo_utente>\n" + "\n".join(parti) + "\n</profilo_utente>"


def _blocco_contesto_attivo(
    nodo: Nodo,
    esercizi: list[Esercizio],
    storico_errori: list[dict],
    nodi_supporto: dict[str, dict],
) -> str:
    """Blocco 4: contesto attivo (nodo focale + nodi supporto)."""
    parti_nodo = [
        f"ID: {nodo.id}",
        f"Nome: {nodo.nome}",
    ]

    if nodo.definizioni_formali:
        parti_nodo.append(
            f"Definizioni formali: {json.dumps(nodo.definizioni_formali, ensure_ascii=False)}"
        )
    if nodo.formule_proprieta:
        parti_nodo.append(
            f"Formule e proprietà: {json.dumps(nodo.formule_proprieta, ensure_ascii=False)}"
        )
    if nodo.errori_comuni:
        parti_nodo.append(
            f"Errori comuni: {json.dumps(nodo.errori_comuni, ensure_ascii=False)}"
        )
    if nodo.esempi_applicazione:
        parti_nodo.append(
            f"Esempi: {json.dumps(nodo.esempi_applicazione, ensure_ascii=False)}"
        )

    # Esercizi disponibili (id + testo + difficoltà)
    if esercizi:
        lista_es = []
        for es in esercizi:
            lista_es.append(f"  - [{es.id}] (diff={es.difficolta}) {es.testo[:200]}")
        parti_nodo.append("Esercizi disponibili:\n" + "\n".join(lista_es))

    # Storico errori
    if storico_errori:
        parti_nodo.append(
            f"Storico errori utente: {json.dumps(storico_errori, ensure_ascii=False)}"
        )

    nodo_focale_xml = "\n".join(parti_nodo)

    # Nodi supporto
    parti_supporto = []
    for nodo_id, stato in nodi_supporto.items():
        parti_supporto.append(
            f"  - {nodo_id}: livello={stato.get('livello', 'non_iniziato')}, "
            f"esercizi={stato.get('esercizi_completati', 0)}, "
            f"errori_recenti={stato.get('errori_in_corso', 0)}"
        )

    supporto_xml = "\n".join(parti_supporto) if parti_supporto else "(nessun prerequisito)"

    return (
        "<contesto_attivo>\n"
        f"  <nodo_focale>\n{nodo_focale_xml}\n  </nodo_focale>\n"
        f"  <nodi_supporto>\n{supporto_xml}\n  </nodi_supporto>\n"
        "</contesto_attivo>"
    )


def _blocco_memoria() -> str:
    """Blocco 6: memoria rilevante (Loop 3 — placeholder)."""
    return "<memoria_rilevante>\n</memoria_rilevante>"


# ---------------------------------------------------------------------------
# Generazione direttiva dalla situazione corrente
# ---------------------------------------------------------------------------

async def _genera_direttiva(
    db: AsyncSession,
    sessione: Sessione,
    utente: Utente,
    nodo: Nodo | None,
) -> str:
    """Genera la direttiva appropriata in base allo stato_orchestratore della sessione."""
    stato_orch = sessione.stato_orchestratore or {}
    attivita = stato_orch.get("attivita_corrente", "spiegazione")
    fase_onboarding = stato_orch.get("fase_onboarding")

    # Controlla se c'è una promozione appena avvenuta da celebrare
    promozione = stato_orch.pop("promozione_appena_avvenuta", None)
    if promozione is not None:
        # Salva la rimozione del flag (consumato)
        sessione.stato_orchestratore = stato_orch
        flag_modified(sessione, "stato_orchestratore")
        await db.flush()

    # Onboarding
    if sessione.tipo == "onboarding" or fase_onboarding:
        return direttiva_onboarding(
            fase=fase_onboarding or "accoglienza",
            info_raccolte=stato_orch.get("info_raccolte"),
        )

    # Ripresa sessione sospesa
    if stato_orch.get("ripresa"):
        return direttiva_ripresa_sessione(
            nodo_nome=nodo.nome if nodo else "(sconosciuto)",
            attivita_precedente=stato_orch.get("attivita_al_momento_sospensione", "studio"),
            dettaglio=stato_orch.get("dettaglio_sospensione"),
        )

    if nodo is None:
        return "ATTIVITÀ: In attesa\nISTRUZIONI: Il sistema sta determinando il prossimo nodo."

    # Esercizio in corso
    if attivita == "esercizio":
        storico = await _carica_storico_errori_nodo(db, utente.id, nodo.id)
        storico_str = [f"{e['esito']} ({e.get('tipo_errore', '?')})" for e in storico]

        return direttiva_esercizio(
            nodo_nome=nodo.nome,
            esercizio_testo=stato_orch.get("esercizio_corrente_testo", ""),
            soluzione=stato_orch.get("esercizio_corrente_soluzione"),
            errori_comuni_attesi=nodo.errori_comuni,
            risposta_studente=stato_orch.get("risposta_studente"),
            numero_tentativo=stato_orch.get("numero_tentativo", 1),
            tentativi_bc=stato_orch.get("tentativi_bc", 0),
            storico_errori=storico_str,
            prerequisito_debole=stato_orch.get("prerequisito_debole"),
        )

    # Feynman (Loop 3)
    if attivita == "feynman":
        return direttiva_feynman(
            nodo_nome=nodo.nome,
            fase_feynman=stato_orch.get("fase_feynman", "invito"),
            definizioni_formali=nodo.definizioni_formali,
            formule_proprieta=nodo.formule_proprieta,
            punti_chiave=stato_orch.get("punti_chiave_feynman"),
        )

    # Ripasso SR (Loop 2)
    if attivita == "ripasso_sr":
        return direttiva_ripasso_sr(
            concetti_scadenza=stato_orch.get("concetti_scadenza", []),
            ordine_ottimale=stato_orch.get("ordine_ripasso"),
        )

    # Default: spiegazione
    prerequisiti_ids = await _carica_prerequisiti_diretti(db, nodo.id)
    stati_prereq = await _carica_stati_nodi_utente(db, utente.id, prerequisiti_ids)
    prerequisiti_completati = [
        nid for nid, stato in stati_prereq.items()
        if stato.get("livello") in ("operativo", "comprensivo", "connesso")
    ]

    # Calcola minuti rimasti
    minuti_rimasti = None
    if sessione.durata_prevista_min:
        trascorsi = (datetime.now(timezone.utc) - sessione.created_at).total_seconds() / 60
        minuti_rimasti = max(0, int(sessione.durata_prevista_min - trascorsi))

    pref = utente.preferenze_tutor or {}

    direttiva = direttiva_spiegazione(
        nodo_nome=nodo.nome,
        nodo_id=nodo.id,
        prerequisiti_completati=prerequisiti_completati,
        livello_materia=stato_orch.get("livello_materia", "da determinare"),
        definizioni_formali=nodo.definizioni_formali,
        formule_proprieta=nodo.formule_proprieta,
        errori_comuni=nodo.errori_comuni,
        stile_cognitivo=pref.get("stile_cognitivo"),
        esempi_preferiti=pref.get("esempi_preferiti"),
        minuti_rimasti=minuti_rimasti,
    )

    # Se c'è una promozione appena avvenuta, anteponi il contesto di celebrazione
    if promozione:
        nodo_completato = promozione.get("nodo_nome", promozione.get("nodo_id", "?"))
        prefisso = (
            f"PROMOZIONE APPENA AVVENUTA: Lo studente ha appena completato "
            f'il nodo "{nodo_completato}" — riconoscilo brevemente prima di '
            f"introdurre il nuovo argomento. Non serve un discorso lungo: "
            f'un "ottimo lavoro su {nodo_completato}, ora passiamo a '
            f'{nodo.nome}" è perfetto. Lo studente deve sentire che il suo '
            f"progresso è visto e riconosciuto dal tutor, non solo dal sistema.\n\n"
        )
        direttiva = prefisso + direttiva

    return direttiva


# ---------------------------------------------------------------------------
# Entry point principale
# ---------------------------------------------------------------------------

async def assembla_context_package(
    sessione_id: uuid.UUID,
    utente_id: uuid.UUID,
    db: AsyncSession,
) -> ContextPackage:
    """Assembla il context package completo per una chiamata LLM.

    Returns:
        ContextPackage con system (blocchi 1-4+6 XML) e messages (blocco 5).
    """
    from app.config import settings

    # Carica entità principali
    utente = await _carica_utente(db, utente_id)
    if utente is None:
        raise ValueError(f"Utente non trovato: {utente_id}")

    sessione = await _carica_sessione(db, sessione_id)
    if sessione is None:
        raise ValueError(f"Sessione non trovata: {sessione_id}")

    stato_orch = sessione.stato_orchestratore or {}
    nodo_focale_id = stato_orch.get("nodo_focale_id")

    # Carica nodo focale (se presente)
    nodo: Nodo | None = None
    esercizi: list[Esercizio] = []
    storico_errori: list[dict] = []
    nodi_supporto: dict[str, dict] = {}

    if nodo_focale_id:
        nodo = await _carica_nodo(db, nodo_focale_id)
        if nodo:
            esercizi = await _carica_esercizi_nodo(db, nodo_focale_id)
            storico_errori = await _carica_storico_errori_nodo(db, utente_id, nodo_focale_id)

            # Carica prerequisiti diretti come nodi supporto
            prereq_ids = await _carica_prerequisiti_diretti(db, nodo_focale_id)
            nodi_supporto = await _carica_stati_nodi_utente(db, utente_id, prereq_ids)

    # Genera direttiva
    direttiva = await _genera_direttiva(db, sessione, utente, nodo)

    # Assembla system prompt (blocchi 1-4 + 6)
    blocchi = [
        _blocco_system_prompt(),
        _blocco_direttiva(direttiva),
        _blocco_profilo_utente(utente),
    ]

    if nodo:
        blocchi.append(_blocco_contesto_attivo(nodo, esercizi, storico_errori, nodi_supporto))

    blocchi.append(_blocco_memoria())

    system = "\n\n".join(blocchi)

    # Carica e tronca conversazione (blocco 5)
    messages = await _carica_conversazione(db, sessione_id)
    messages = tronca_conversazione(messages)

    # Anthropic API richiede almeno un messaggio.
    # Al primo turno (onboarding/sessione) il tutor parla per primo senza input utente.
    if not messages:
        messages = [{"role": "user", "content": "[Inizia la conversazione]"}]

    # Determina modello
    modello = settings.LLM_MODEL_TUTOR

    logger.info(
        "Context package assemblato: sessione=%s, nodo=%s, %d messages, system=%d chars",
        sessione_id,
        nodo_focale_id,
        len(messages),
        len(system),
    )

    return ContextPackage(system=system, messages=messages, modello=modello)
