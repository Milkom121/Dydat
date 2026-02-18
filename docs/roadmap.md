# Dydat Backend — Roadmap di sviluppo

> Aggiornamento: 2026-02-18
> Legenda: ⬚ da fare | 🔄 in corso | ✅ completato

---

## Blocco 1: Foundation (Sessione 1)

Setup progetto, Docker, database, struttura codice.

- ✅ `.gitignore`
- ✅ `pyproject.toml` con tutte le dipendenze
- ✅ `.env.example`
- ✅ `Dockerfile` (Python 3.12-slim)
- ✅ `docker-compose.yml` (backend + PostgreSQL 16)
- ✅ Struttura directory completa (`app/`, `tests/`, `scripts/`, `data/`)
- ✅ `app/config.py` (pydantic-settings)
- ✅ `app/db/engine.py` + `app/db/base.py`
- ✅ Modelli SQLAlchemy — tutte le 17 tabelle (4 file per gruppo)
- ✅ Alembic init + configurazione async
- ✅ Prima migrazione (crea tutte le tabelle)
- ✅ `app/main.py` con health check
- ✅ Router API stub (7 file, tutti 501)
- ✅ Stub moduli core (turno, sessione, contesto, elaborazione, conversazione, gamification)
- ✅ Stub moduli LLM (client, tools, prompts/system_prompt)
- ✅ Stub moduli grafo (struttura, algoritmi, stato, fsrs)
- ✅ Copiare KB JSON in `data/`
- ✅ Test base (health check + import modelli) — 3/3 pass
- ✅ Verifica: `docker-compose up` → health check OK → 17 tabelle nel DB

---

## Blocco 2: Import Knowledge Base (Sessione 2)

Caricare i dati reali nel database.

- ✅ `scripts/import_extraction.py`
  - ✅ Lettura JSON con auto-detect nomi file
  - ✅ Import nodi con mapping campi
  - ✅ Estrazione temi da `tema_id` dei nodi
  - ✅ Import relazioni (array piatto, ignorare confidence/passaggio)
  - ✅ Import esercizi con mapping campi
  - ✅ UPSERT idempotente (re-import sicuro) — verificato con doppio run
  - ✅ Skip nodi contesto per stato utente (importati nel DB, esclusi dal percorso)
  - ✅ Gestione import multipli (Algebra1 + Algebra2)
- ✅ Test import con dati reali — 8/8 unit test + import completo
- ✅ Verifica integrità: 183 nodi, 25 temi, 539 relazioni, 1470 esercizi, 0 orfani, 166/169 copertura

---

## Blocco 3: Grafo in memoria + algoritmi (Sessione 2)

Knowledge graph deterministico.

- ✅ `app/grafo/struttura.py` — GrafoKnowledge singleton con NetworkX DiGraph, caricamento da DB
- ✅ `app/grafo/algoritmi.py` — funzioni pure (no DB, no async)
  - ✅ Ordinamento topologico (sottografo bloccante, esclusi nodi contesto)
  - ✅ Verifica sblocco nodo (tutti prerequisiti bloccanti ≥ operativo)
  - ✅ Path planner (prossimo nodo non completato con prerequisiti soddisfatti)
  - ✅ Preferenza stesso tema in caso di parità
  - ✅ Gestione "percorso completato" (tutti i nodi operativi → None)
  - ✅ Cascata sblocco post-promozione (`nodi_sbloccati_dopo_promozione`)
- ✅ `app/grafo/stato.py` — `get_livelli_utente` + `aggiorna_livello` (UPSERT)
- ✅ `app/main.py` aggiornato con lifespan per caricamento grafo
- ✅ Test: 35/35 pass — topological sort, sblocco, path planner, diamante, cascata, tie-break tema

---

## Blocco 4: Auth + gestione utente (Sessione 3)

- ✅ `app/core/sicurezza.py` — hash bcrypt (diretto, no passlib) + JWT con python-jose
- ✅ `app/db/crud/utenti.py` — crea_utente, get_by_email, get_by_id, aggiorna_profilo
- ✅ `app/api/deps.py` — `get_utente_corrente` dependency (Bearer token → Utente)
- ✅ `app/schemas/auth.py` + `app/schemas/utente.py` — Pydantic v2 con EmailStr
- ✅ `app/api/auth.py` — `POST /auth/registrazione` (201) + `POST /auth/login` (JWT)
- ✅ `app/api/utente.py` — `GET /me`, `PUT /me/preferenze`, `GET /me/statistiche` (stub 501)
- ✅ Test: 8/8 pass (hash, verifica, JWT crea/verifica/manomesso/uuid) + 7 API test skippati (richiedono DB)

---

## Blocco 5: Client LLM + streaming (Sessione 3)

- ✅ `app/llm/client.py`
  - ✅ Wrapper Anthropic SDK (`chiama_tutor` async generator)
  - ✅ Streaming response con parsing text_delta + tool_use (azioni vs segnali)
  - ✅ Gestione timeout (`asyncio.timeout` + errore strutturato)
  - ✅ Conteggio token e costo stimato (`RisultatoTurno` dataclass)
- ✅ `app/llm/tools.py` — Schema completo: 4 azioni Loop 1, 4 azioni Loop 2-3, 6 segnali Loop 1, 2 segnali Loop 3 + helper `is_azione`/`is_segnale`
- ✅ `app/llm/prompts/system_prompt.py` — System prompt completo (personalità, metodo B+C, Feynman, regole, toolkit)
- ✅ `app/llm/prompts/direttive.py` — 6 template direttive
- ✅ Test: 17/17 pass — schema validation, streaming mock (text only, text+tool, timeout), costo stimato

---

## Blocco 6: Context builder + direttive (Sessione 4)

- ✅ `app/core/contesto.py` — Assembla i 6 blocchi XML → `ContextPackage`
  - ✅ Blocco 1: System prompt (fisso, da `SYSTEM_PROMPT`)
  - ✅ Blocco 2: Direttiva (generata da `stato_orchestratore` della sessione)
  - ✅ Blocco 3: Profilo utente (preferenze, contesto, profilo sintetizzato)
  - ✅ Blocco 4: Contesto attivo (nodo focale + esercizi + storico errori + nodi supporto)
  - ✅ Blocco 5: Conversazione nei messages (solo testo, da `turni_conversazione`)
  - ✅ Blocco 6: Memoria rilevante (placeholder Loop 3)
- ✅ Template direttive (`app/llm/prompts/direttive.py`):
  - ✅ Spiegazione concetto nuovo (con minuti rimasti opzionale)
  - ✅ Esercizio in corso (con soluzione, storico errori, tentativi B+C)
  - ✅ Onboarding (accoglienza / conoscenza / conclusione)
  - ✅ Ripresa sessione sospesa
  - ✅ Verifica Feynman (template Loop 3 definito)
  - ✅ Ripasso SR (template Loop 2 definito)
- ✅ Troncamento conversazione (>50 turni: primi 2 + raccordo + ultimi 20)
- ✅ Test: 26/26 pass — troncamento, blocchi XML, direttive, ContextPackage, system prompt

---

## Blocco 7: Flusso del turno — IL CUORE (Sessione 4-5)

- ✅ `app/core/turno.py` — `esegui_turno()` coordinatore 3 fasi
  - ✅ Fase 1: Preparazione (salva messaggio utente, assembla context package)
  - ✅ Fase 2: Chiamata LLM (streaming, parsing text_delta + tool_use, dispatch azioni vs segnali)
  - ✅ Fase 3: Post-processing (salva turno assistente, processa segnali, gestisci promozioni, achievement check safe, commit + turno_completo)
- ✅ `app/core/elaborazione.py`
  - ✅ Action Executor (`esegui_azione` con dispatch)
    - ✅ `proponi_esercizio` (selezione dal banco con mapping difficoltà base→1-2, intermedio→3, avanzato→4-5, aggiornamento stato_orchestratore)
    - ✅ `mostra_formula` (passthrough al frontend)
    - ✅ `suggerisci_backtrack` (passthrough al frontend)
    - ✅ `chiudi_sessione` (transizione stato → completata)
    - ✅ Stub azioni Loop 2-3 (log + return None)
  - ✅ Signal Processor (`processa_segnali` con dispatch, ritorna lista promozioni)
    - ✅ `concetto_spiegato` → UPSERT stato_nodi_utente (livello=in_corso, spiegazione_data=True)
    - ✅ `risposta_esercizio` → StoricoEsercizi + aggiorna contatori (esercizi_completati++, esercizi_consecutivi_ok, errori_in_corso) + verifica promozione
    - ✅ `confusione_rilevata` → log (Loop 3 placeholder)
    - ✅ `energia_utente` → log (Loop 3 placeholder)
    - ✅ `prossimo_passo_raccomandato` → aggiorna attivita_corrente in stato_orchestratore
    - ✅ `punto_partenza_suggerito` → salva punto_partenza_suggerito in stato_orchestratore
    - ✅ Stub segnali Loop 3 (log + return None)
  - ✅ `aggiorna_nodo_dopo_promozione()` — path planner per prossimo nodo, aggiorna sessione
- ✅ `app/core/conversazione.py`
  - ✅ `salva_turno()` — calcolo ordine progressivo, salvataggio con testo/azioni/segnali separati, token/costo
  - ✅ `carica_conversazione()` — carica turni per Claude messages (solo testo, no azioni/segnali)
- ✅ Logica promozione: in_corso → operativo (3 condizioni: spiegazione_data + esercizi_completati≥3 + almeno 1 primo_tentativo nello storico)
- ✅ Cascata sblocco post-promozione (via `nodi_sbloccati_dopo_promozione` + UPSERT stato_nodi_utente sbloccato)
- ✅ Test: 20/20 pass — mapping difficoltà (4), logica promozione (6), cascata sblocco (3), turno coordinatore (5), eventi SSE (2)

---

## Blocco 8: API sessione con SSE (Sessione 5)

- ✅ `app/api/sessione.py` — 5 endpoint con SSE via sse-starlette
  - ✅ `POST /sessione/inizia` → SSE stream (sessione_creata + primo turno tutor)
  - ✅ `POST /sessione/{id}/turno` → SSE stream (risposta tutor)
  - ✅ `POST /sessione/{id}/sospendi` → salva stato orchestratore
  - ✅ `POST /sessione/{id}/termina` → chiudi sessione
  - ✅ `GET /sessione/{id}` → stato sessione
- ✅ `app/core/sessione.py` — Session Manager completo
  - ✅ Scelta nodo a inizio sessione (sospesa → in_corso → path planner)
  - ✅ Sessione unica attiva (409 `SessioneConflitto` / auto-sospensione 5 min)
  - ✅ Transizioni attività (gestite da stato_orchestratore)
  - ✅ Salvataggio/ripristino stato orchestratore (sospendi/riprendi)
- ✅ `app/schemas/sessione.py` — Pydantic v2 schemas (request + response)
- ✅ Formato eventi SSE (sessione_creata, text_delta, azione, achievement, turno_completo, errore)
- ✅ Gestione errori (409 conflitto, 404 non trovata, 400 stato invalido, timeout LLM via turno.py)
- ✅ Test: 29/29 pass — sessione unica, auto-sospensione, ripresa, scelta nodo, schemas, SSE, flusso E2E

---

## Blocco 9: Onboarding (Sessione 6)

- ✅ `app/core/onboarding.py` — Onboarding Manager (crea_utente_temporaneo, crea_sessione_onboarding, aggiorna_fase_onboarding, completa_onboarding, _trova_nodo_per_tema, _inizializza_stato_nodi)
- ✅ `app/api/onboarding.py` — 3 endpoint SSE
  - ✅ `POST /onboarding/inizia` → crea utente temp + sessione onboarding + SSE primo turno
  - ✅ `POST /onboarding/turno` → turno conversazione onboarding con auto-fase
  - ✅ `POST /onboarding/completa` → finalizza, crea percorso
- ✅ `app/schemas/onboarding.py` — 4 Pydantic schemas (IniziaResponse, TurnoRequest, CompletaRequest, CompletaResponse)
- ✅ Gestione fasi: accoglienza → conoscenza (automatico dopo 1° risposta utente) → conclusione (dopo TURNI_CONOSCENZA_MAX=8 turni)
- ✅ Punto di partenza personalizzato (segnale `punto_partenza_suggerito`)
  - ✅ Match tema/nodo nel grafo (spazi→underscore, case-insensitive, fallback nodo_id)
  - ✅ `nodo_iniziale_override` nel percorso
  - ✅ Nodi precedenti marcati operativo + presunto=true (via ordinamento topologico)
- ✅ Al completamento: salva profilo, crea percorso binario_1, inizializza stato_nodi_utente
- ✅ Test: 24/24 pass — utente temp, sessione, fasi (5), completamento (4), match tema (5), schemas (6), costanti (1), E2E (1)

---

## Blocco 10: Gamification (Sessione 7)

- ✅ `app/core/gamification.py`
  - ✅ Achievement checker (`verifica_achievement`) — verifica condizioni dopo ogni turno, sblocca automaticamente
  - ✅ Seed definizioni achievement iniziali (8 dal brief, UPSERT idempotente al startup)
  - ✅ Calcolo streak (HARD CONSTRAINT: giorni consecutivi all'indietro, gap=interruzione)
  - ✅ Aggiornamento `statistiche_giornaliere` (esercizi, nodi, minuti, obiettivo_raggiunto)
  - ✅ `lista_achievement_utente` — sbloccati + prossimi con progresso
  - ✅ Cache metriche per evitare query ripetute nello stesso turno
- ✅ `app/api/achievement.py` — `GET /achievement` (autenticato, response model Pydantic)
- ✅ `app/schemas/achievement.py` — 4 schemas (ProgressoAchievement, Sbloccato, Prossimo, ListaResponse)
- ✅ `app/core/turno.py` — integrazione: `_verifica_achievement_safe` + `_aggiorna_stats_safe` nel post-processing
- ✅ `app/main.py` — seed achievement al startup (lifespan)
- ✅ Test: 26/26 pass — seed (6), streak HARD CONSTRAINT (7), verifica achievement (6), lista progresso (1), schemas (3), integrazione turno (3)

---

## Blocco 11: API restanti + rifinitura + test (Sessione 7)

- ✅ `app/api/percorsi.py` — `GET /percorsi` (lista percorsi utente) + `GET /percorsi/{id}/mappa` (nodi con stato utente, tema, livello per mappa visuale)
- ✅ `app/api/temi.py` — `GET /temi/` (lista temi con progresso sintetico) + `GET /temi/{id}` (dettaglio tema con stato per-nodo)
- ✅ `GET /utente/me/statistiche` — stats settimana/mese/sempre (streak, nodi_completati, sessioni, aggregazioni da statistiche_giornaliere)
- ✅ Test end-to-end completo con mock (`tests/test_e2e.py`) — walkthrough sezione 18: spiegazione→esercizio→promozione+achievement→errore LLM. 8 test (4 flusso E2E + 3 router check + 1 helper stats)
- ✅ Test integrazione LLM reale (`tests/test_integration_llm.py`) — 3 smoke test con Anthropic API: spiegazione+segnale, esercizio+azione, validazione 16 tool schemas. Marcati `@pytest.mark.integration`, eseguibili con `--run-integration`
- ✅ `tests/conftest.py` — flag `--run-integration` per test con LLM reale
- ✅ `pyproject.toml` — marker `integration` registrato

---

## Note

- Ogni blocco aggiorna questo file e `CLAUDE.md` al completamento
- I test critici di dominio vengono scritti CON il codice, non dopo
- I blocchi 5-6-7-8 sono strettamente accoppiati — preferire sessioni dedicate con contesto pieno
- Ralph Loop utilizzabile per sotto-task ripetitivi dentro un blocco (es. "scrivi tutti i test di promozione")
