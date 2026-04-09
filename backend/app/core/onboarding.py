"""Onboarding Manager — flusso di conoscenza iniziale.

Fasi: accoglienza → conoscenza → placement → piano → conclusione.
- accoglienza: presentazione e prima domanda
- conoscenza: raccolta info studente con estrattore profilo Opus + decisore forma C
- placement: mini-test diagnostico su nodi gateway
- piano: proposta piano studio basata sui risultati placement
- conclusione: riepilogo e avvio percorso

Transizioni:
- accoglienza → conoscenza: automatica dopo 1° risposta utente
- conoscenza → placement: gestita dal decisore forma C (decidi_prossima_mossa)
- placement → piano, piano → conclusione: guidate da segnale transizione_fase del LLM

Al completamento: salva profilo estratto, crea percorso, inizializza stato_nodi_utente.
Punto di partenza personalizzato via placement o segnale punto_partenza_suggerito.
"""

from __future__ import annotations

import json as json_module
import logging
import uuid
from datetime import datetime, timezone

import anthropic
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm.attributes import flag_modified

from app.config import settings
from app.core.conversazione import carica_conversazione
from app.db.models.stato_utente import StatoNodoUtente
from app.db.models.utenti import (
    OnboardingStato,
    PercorsoUtente,
    Sessione,
    TurnoConversazione,
    Utente,
)
from app.grafo.algoritmi import ordinamento_topologico
from app.grafo.struttura import grafo_knowledge
from app.llm.client import chiama_llm_singolo
from app.llm.prompts.onboarding_exercise_generator import (
    MAX_ESERCIZI_VERIFICA,
    build_exercise_prompt,
    parse_exercise_response,
)
from app.llm.prompts.onboarding_extractor import build_extractor_prompt
from app.schemas.onboarding import (
    AzioneDecisore,
    CampoConConfidenza,
    Decisione,
    EsercizioCompound,
    ProfiloEstratto,
)

logger = logging.getLogger(__name__)

# Fasi onboarding in ordine
FASI_ONBOARDING = ("accoglienza", "conoscenza", "placement", "piano", "conclusione")

# Tetto massimo turni narrativi prima di chiusura forzata (Decisione 4)
TETTO_TURNI_NARRATIVI = 7

# Priorità campi: obbligatori prima, opzionali dopo
_CAMPI_PRIORITA = (
    "chi_e",
    "motivo",
    "stile_cognitivo",
    "tempo_disponibile",
    "vissuto_scolastico",
)

# I primi 3 sono obbligatori per un profilo minimamente utilizzabile
_CAMPI_OBBLIGATORI = {"chi_e", "motivo", "stile_cognitivo"}


def decidi_prossima_mossa(
    profilo_stato: ProfiloEstratto,
    turni_fatti: int,
    fase_placement: str | None = None,
) -> Decisione:
    """Decisore forma C: regole deterministiche, nessun LLM.

    Dato lo stato corrente del profilo estratto e il numero di turni fatti,
    decide la prossima mossa del tutor di onboarding.

    Regole (in ordine di priorità):
    1. turni_fatti >= TETTO → forza_chiusura_tetto_turni
    2. Tutti i 5 campi con confidenza alta o media → chiudi_narrativa
    3. Campo mancante (bassa confidenza) → chiedi_campo_mancante (per priorità)

    Args:
        profilo_stato: profilo estratto con 5 campi + confidenza
        turni_fatti: numero di turni narrativi già eseguiti
        fase_placement: riservato per estensioni future (placement test)

    Returns:
        Decisione con azione, campo_da_chiedere (se applicabile), motivo
    """
    # Regola 1: tetto turni raggiunto → chiusura forzata
    if turni_fatti >= TETTO_TURNI_NARRATIVI:
        return Decisione(
            azione=AzioneDecisore.forza_chiusura_tetto_turni,
            campo_da_chiedere=None,
            motivo=(
                f"Tetto di {TETTO_TURNI_NARRATIVI} turni raggiunto "
                f"({turni_fatti} fatti), chiusura forzata"
            ),
        )

    # Regola 2: profilo completo → chiudi narrativa
    if profilo_stato.is_completo():
        return Decisione(
            azione=AzioneDecisore.chiudi_narrativa,
            campo_da_chiedere=None,
            motivo="Tutti i 5 campi hanno confidenza alta o media",
        )

    # Regola 3: campo mancante → chiedi per priorità
    # campi_mancanti() ritorna solo quelli a bassa confidenza
    mancanti = set(profilo_stato.campi_mancanti())

    # Cerca il primo campo mancante nell'ordine di priorità
    for campo in _CAMPI_PRIORITA:
        if campo in mancanti:
            tipo = "obbligatorio" if campo in _CAMPI_OBBLIGATORI else "opzionale"
            return Decisione(
                azione=AzioneDecisore.chiedi_campo_mancante,
                campo_da_chiedere=campo,
                motivo=f"Campo {tipo} '{campo}' mancante o a bassa confidenza",
            )

    # Non dovrebbe mai arrivare qui (is_completo sarebbe True),
    # ma per sicurezza chiudi
    return Decisione(
        azione=AzioneDecisore.chiudi_narrativa,
        campo_da_chiedere=None,
        motivo="Nessun campo mancante trovato (fallback)",
    )


async def elabora_decisione_onboarding(
    db: AsyncSession,
    sessione: Sessione,
) -> Decisione | None:
    """Dopo un turno in fase conoscenza, estrae profilo e decide prossima mossa.

    Flusso:
    1. Carica conversazione dal DB
    2. Chiama estrattore Opus per aggiornare il profilo a 5 campi
    3. Chiama decisore rules-based per la prossima mossa
    4. Salva profilo + decisione nello stato_orchestratore
    5. Se chiudi_narrativa o forza_chiusura → transizione a placement

    Returns:
        Decisione se fase == conoscenza, None altrimenti.
    """
    stato = sessione.stato_orchestratore or {}
    fase = stato.get("fase_onboarding", "accoglienza")

    if fase != "conoscenza":
        return None

    # 1. Carica conversazione per l'estrattore
    conversazione = await carica_conversazione(db, sessione.id)

    # 2. Estrai profilo dalla conversazione
    profilo = await estrai_profilo(conversazione)

    # 3. Conta turni conoscenza (già incrementato da aggiorna_fase_onboarding)
    turni_fatti = stato.get("turni_conoscenza", 0)

    # 4. Decidi prossima mossa
    decisione = decidi_prossima_mossa(profilo, turni_fatti)

    # 5. Salva profilo e decisione nello stato_orchestratore
    stato["profilo_estratto"] = profilo.model_dump()
    stato["ultima_decisione"] = decisione.model_dump()

    # 6. Se chiudi_narrativa o forza_chiusura → transizione a placement
    if decisione.azione in (
        AzioneDecisore.chiudi_narrativa,
        AzioneDecisore.forza_chiusura_tetto_turni,
    ):
        stato["fase_onboarding"] = "placement"
        logger.info(
            "Onboarding: conoscenza → placement (decisore: %s, turni=%d)",
            decisione.azione.value,
            turni_fatti,
        )

    sessione.stato_orchestratore = stato
    flag_modified(sessione, "stato_orchestratore")
    await db.flush()

    logger.info(
        "Decisione onboarding: azione=%s, campo=%s, profilo=%d/5 completi",
        decisione.azione.value,
        decisione.campo_da_chiedere,
        len(profilo.campi_completi()),
    )

    return decisione


def _profilo_vuoto() -> ProfiloEstratto:
    """Profilo con tutti i campi a bassa confidenza (fallback su errore)."""
    campo_vuoto = CampoConConfidenza(valore=None, confidenza="bassa")
    return ProfiloEstratto(
        chi_e=campo_vuoto,
        motivo=campo_vuoto,
        stile_cognitivo=campo_vuoto,
        tempo_disponibile=campo_vuoto,
        vissuto_scolastico=campo_vuoto,
    )


async def estrai_profilo(conversazione: list[dict]) -> ProfiloEstratto:
    """Estrae il profilo utente dalla conversazione onboarding via Opus.

    Chiama Opus con il prompt estrattore, parsa il JSON, valida con Pydantic.
    Retry 1 volta su fallimento. Fallback a profilo vuoto se irrecuperabile.

    Args:
        conversazione: lista di messaggi [{role: "user"|"assistant", content: str}]

    Returns:
        ProfiloEstratto validato (tutti i 5 campi sempre presenti).
    """
    if not conversazione:
        logger.warning("estrai_profilo: conversazione vuota, ritorno profilo vuoto")
        return _profilo_vuoto()

    prompt = build_extractor_prompt(conversazione)
    max_tentativi = 2  # 1 tentativo + 1 retry

    for tentativo in range(max_tentativi):
        try:
            testo_risposta = await chiama_llm_singolo(
                user_prompt=prompt,
                modello=settings.LLM_MODEL_ONBOARDING,
                max_tokens=1024,
            )

            # Parsa il JSON dalla risposta
            profilo_dict = _parsa_json_risposta(testo_risposta)
            if profilo_dict is None:
                raise ValueError("JSON non trovato nella risposta LLM")

            # Valida con Pydantic
            profilo = ProfiloEstratto.model_validate(profilo_dict)
            logger.info(
                "Profilo estratto: %d/%d campi completi (tentativo %d)",
                len(profilo.campi_completi()),
                5,
                tentativo + 1,
            )
            return profilo

        except (anthropic.APIError, TimeoutError) as e:
            # Errore di rete/API — ritentabile
            logger.warning(
                "estrai_profilo tentativo %d fallito (API): %s",
                tentativo + 1, e,
            )
        except (ValueError, json_module.JSONDecodeError) as e:
            # JSON malformato o validazione Pydantic fallita — ritentabile
            logger.warning(
                "estrai_profilo tentativo %d fallito (parsing): %s",
                tentativo + 1, e,
            )
        except Exception:
            # Errore inatteso — non ritentare, fallback immediato
            logger.exception("estrai_profilo: errore inatteso")
            return _profilo_vuoto()

    # Tutti i tentativi falliti — fallback a profilo vuoto
    logger.error(
        "estrai_profilo: %d tentativi falliti, ritorno profilo vuoto",
        max_tentativi,
    )
    return _profilo_vuoto()


def _parsa_json_risposta(testo: str) -> dict | None:
    """Estrae e parsa il primo oggetto JSON valido dalla risposta LLM.

    Gestisce i casi in cui Opus aggiunge testo prima/dopo il JSON
    o lo wrappa in un blocco ```json.
    """
    testo = testo.strip()

    # Caso 1: risposta è direttamente JSON
    try:
        risultato = json_module.loads(testo)
        if isinstance(risultato, dict):
            return risultato
    except json_module.JSONDecodeError:
        pass

    # Caso 2: JSON dentro blocco markdown ```json ... ```
    if "```" in testo:
        # Cerca il contenuto tra ``` (opzionalmente con "json" dopo il primo ```)
        parti = testo.split("```")
        for parte in parti[1::2]:  # indici dispari = contenuto dentro ```
            contenuto = parte.strip()
            if contenuto.startswith("json"):
                contenuto = contenuto[4:].strip()
            try:
                risultato = json_module.loads(contenuto)
                if isinstance(risultato, dict):
                    return risultato
            except json_module.JSONDecodeError:
                continue

    # Caso 3: JSON preceduto/seguito da testo — cerca { ... }
    inizio = testo.find("{")
    fine = testo.rfind("}")
    if inizio != -1 and fine > inizio:
        try:
            risultato = json_module.loads(testo[inizio:fine + 1])
            if isinstance(risultato, dict):
                return risultato
        except json_module.JSONDecodeError:
            pass

    return None


async def genera_esercizi_verifica(
    aree_da_verificare: list[str],
    nomi_concetti: dict[str, str] | None = None,
) -> list[EsercizioCompound]:
    """Genera esercizi compound per verificare le aree dichiarate 'forte'.

    Prende le aree da verificare, le accoppia (max 2 per esercizio),
    chiama Opus per generare gli esercizi a scelta multipla.

    Cap duro: max MAX_ESERCIZI_VERIFICA (3) esercizi.
    Retry 1 volta su fallimento per coppia. Lista vuota in caso di
    fallimento totale irrecuperabile.

    Scala adattiva (da Decisione 8):
    - 1-2 aree → 1-2 esercizi singoli
    - 3-4 aree → 2 esercizi compound
    - 5-6 aree → 3 esercizi compound

    Args:
        aree_da_verificare: lista di concept_id delle aree da verificare.
        nomi_concetti: dict opzionale {concept_id: nome_leggibile}.

    Returns:
        Lista di EsercizioCompound validati. Può essere vuota.
    """
    if not aree_da_verificare:
        return []

    # Costruisci coppie di concetti
    coppie = _costruisci_coppie(aree_da_verificare)

    # Cap al massimo esercizi
    coppie = coppie[:MAX_ESERCIZI_VERIFICA]

    # Genera il prompt con tutte le coppie in una singola chiamata
    prompt = build_exercise_prompt(coppie, nomi_concetti)

    max_tentativi = 2
    for tentativo in range(max_tentativi):
        try:
            testo_risposta = await chiama_llm_singolo(
                user_prompt=prompt,
                modello=settings.LLM_MODEL_ONBOARDING,
                max_tokens=2048,
            )

            esercizi_raw = parse_exercise_response(testo_risposta)
            if esercizi_raw is None:
                raise ValueError("Parsing esercizi fallito: nessun esercizio valido")

            # Valida con Pydantic
            esercizi = []
            for ex_dict in esercizi_raw:
                try:
                    esercizi.append(EsercizioCompound.model_validate(ex_dict))
                except Exception:
                    logger.warning(
                        "Esercizio scartato per validazione Pydantic: %s",
                        ex_dict.get("testo", "?")[:50],
                    )

            if not esercizi:
                raise ValueError("Nessun esercizio ha superato la validazione Pydantic")

            # Cap finale
            esercizi = esercizi[:MAX_ESERCIZI_VERIFICA]

            logger.info(
                "Esercizi verifica generati: %d/%d coppie (tentativo %d)",
                len(esercizi),
                len(coppie),
                tentativo + 1,
            )
            return esercizi

        except (anthropic.APIError, TimeoutError) as e:
            logger.warning(
                "genera_esercizi_verifica tentativo %d fallito (API): %s",
                tentativo + 1, e,
            )
        except (ValueError, json_module.JSONDecodeError) as e:
            logger.warning(
                "genera_esercizi_verifica tentativo %d fallito (parsing): %s",
                tentativo + 1, e,
            )
        except Exception:
            logger.exception("genera_esercizi_verifica: errore inatteso")
            return []

    # Tutti i tentativi falliti
    logger.error(
        "genera_esercizi_verifica: %d tentativi falliti, ritorno lista vuota",
        max_tentativi,
    )
    return []


def _costruisci_coppie(aree: list[str]) -> list[list[str]]:
    """Accoppia le aree per esercizi compound.

    Scala adattiva:
    - 1 area → 1 coppia singola [[a]]
    - 2 aree → 2 coppie singole [[a], [b]] oppure 1 compound [[a, b]]
    - 3-4 aree → 2 compound (coppie da 2, ultimo singolo se dispari)
    - 5-6 aree → 3 compound
    - 7+ aree → le prime 6, poi 3 compound

    Returns:
        Lista di coppie (liste di 1-2 concept_id).
    """
    if not aree:
        return []

    # Cap a 6 aree (le prime 6 sono le più fondazionali, da B39.6.2)
    aree_cap = aree[:6]

    if len(aree_cap) <= 2:
        # 1-2 aree → esercizi singoli
        return [[a] for a in aree_cap]

    # 3+ aree → compound: accoppia consecutive
    coppie = []
    i = 0
    while i < len(aree_cap):
        if i + 1 < len(aree_cap):
            coppie.append([aree_cap[i], aree_cap[i + 1]])
            i += 2
        else:
            coppie.append([aree_cap[i]])
            i += 1

    return coppie


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
    - Dopo 1° risposta studente: conoscenza (+ incrementa contatore turni)

    La transizione conoscenza→placement è gestita dal decisore forma C
    (elabora_decisione_onboarding, chiamato post-turno dall'API).
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
        # Incrementa contatore turni — la transizione a placement è gestita
        # dal decisore forma C in elabora_decisione_onboarding (B39.3.2)
        turni = stato.get("turni_conoscenza", 0) + 1
        stato["turni_conoscenza"] = turni
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


def _costruisci_profilo_sintetizzato(profilo: ProfiloEstratto) -> dict:
    """Converte ProfiloEstratto in dict piatto per utente.profilo_sintetizzato.

    Include solo i valori dei campi con confidenza alta o media.
    Formato atteso dal sistema di direttive (B33.5): dict con chiavi
    chi_e, motivo, stile_cognitivo, tempo_disponibile, vissuto_scolastico.
    """
    risultato = {}
    for campo in (
        "chi_e", "motivo", "stile_cognitivo",
        "tempo_disponibile", "vissuto_scolastico",
    ):
        obj = getattr(profilo, campo)
        if obj.confidenza in ("alta", "media") and obj.valore:
            risultato[campo] = obj.valore
    return risultato


def _costruisci_contesto_personale(profilo: ProfiloEstratto) -> dict:
    """Costruisce contesto_personale dai campi biografici del profilo estratto."""
    risultato = {}
    for campo in ("chi_e", "motivo", "vissuto_scolastico"):
        obj = getattr(profilo, campo)
        if obj.confidenza in ("alta", "media") and obj.valore:
            risultato[campo] = obj.valore
    return risultato


def _costruisci_preferenze_tutor(profilo: ProfiloEstratto) -> dict:
    """Costruisce preferenze_tutor dai campi di preferenza del profilo estratto."""
    risultato = {}
    for campo in ("stile_cognitivo", "tempo_disponibile"):
        obj = getattr(profilo, campo)
        if obj.confidenza in ("alta", "media") and obj.valore:
            risultato[campo] = obj.valore
    return risultato


async def completa_onboarding(
    db: AsyncSession,
    sessione: Sessione,
    utente: Utente,
    contesto_personale: dict | None = None,
    preferenze_tutor: dict | None = None,
) -> dict:
    """Completa l'onboarding: salva profilo, crea percorso, inizializza stato.

    Usa il profilo estratto dalla conversazione (stato_orchestratore.profilo_estratto)
    per popolare profilo_sintetizzato, contesto_personale e preferenze_tutor.
    I parametri contesto_personale e preferenze_tutor dal payload hanno priorità
    (override esplicito dal frontend).

    Usa i risultati del placement test (se disponibili) per determinare
    il punto di partenza. Fallback su punto_partenza_suggerito dal LLM.

    Returns:
        Dict con {percorso_id, nodo_iniziale, nodi_inizializzati}.
    """
    # 1. Ricostruisci profilo dalla conversazione se disponibile
    stato = sessione.stato_orchestratore or {}
    profilo_raw = stato.get("profilo_estratto")

    if profilo_raw:
        try:
            profilo = ProfiloEstratto.model_validate(profilo_raw)

            # profilo_sintetizzato: sempre dal profilo estratto
            utente.profilo_sintetizzato = _costruisci_profilo_sintetizzato(profilo)
            utente.profilo_sintetizzato_at = datetime.now(timezone.utc)

            # contesto_personale: dal payload se fornito, altrimenti dal profilo
            if not contesto_personale:
                contesto_personale = _costruisci_contesto_personale(profilo)

            # preferenze_tutor: dal payload se fornito, altrimenti dal profilo
            if not preferenze_tutor:
                preferenze_tutor = _costruisci_preferenze_tutor(profilo)

            logger.info(
                "Profilo sintetizzato scritto: %d campi, contesto=%d, preferenze=%d",
                len(utente.profilo_sintetizzato),
                len(contesto_personale),
                len(preferenze_tutor),
            )
        except Exception:
            logger.warning(
                "Errore ricostruzione profilo da stato_orchestratore, "
                "uso parametri diretti",
                exc_info=True,
            )

    # Scrivi contesto_personale e preferenze_tutor
    if contesto_personale:
        utente.contesto_personale = contesto_personale
    if preferenze_tutor:
        utente.preferenze_tutor = preferenze_tutor

    # Aggiorna onboarding_stato
    utente.onboarding_stato = OnboardingStato.COMPLETED

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
