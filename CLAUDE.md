# CLAUDE.md — Dydat Backend

## Progetto

**Dydat** è un tutor AI adattivo per matematica. Il backend orchestra sessioni di studio personalizzate su un knowledge graph di concetti matematici, usando Claude come LLM.

Il brief completo è in `dydat_brief_backend_v3.md` nella root del repo. È la fonte di verità. In caso di dubbio, consultarlo — sezione 18 (walkthrough E2E) è la reference finale.

## Architettura

Tre layer, regola d'oro: **Layer 1 e Layer 3 non comunicano mai direttamente**.

- **Layer 1 — Knowledge Graph**: dati strutturati + algoritmi deterministici (pathfinding, sblocco, SR)
- **Layer 2 — Orchestratore**: media tra grafo e tutor, gestisce sessioni, processa segnali
- **Layer 3 — Tutor LLM**: genera spiegazioni, propone esercizi, valuta risposte (Claude Sonnet)

## Stack tecnologico (HARD CONSTRAINT)

| Componente | Scelta |
|---|---|
| Linguaggio | Python 3.12+ |
| Framework | FastAPI |
| Database | PostgreSQL 16 (singolo DB) |
| ORM | SQLAlchemy 2.0 async + asyncpg |
| Migrazioni | Alembic |
| LLM | Anthropic SDK (Sonnet 4.5 tutor, Haiku 4.5 pipeline) |
| Validazione | Pydantic v2 |
| Auth | JWT self-implemented (python-jose) |
| SSE | sse-starlette |
| SR | FSRS via libreria `fsrs` su PyPI (Loop 2, non installare ora) |
| Ambiente | Docker Compose (backend + PostgreSQL) |

Modelli LLM configurabili via `.env`, MAI hardcodati:
- `LLM_MODEL_TUTOR` = claude-sonnet-4-5-20250929
- `LLM_MODEL_PIPELINE` = claude-haiku-4-5-20251001
- `LLM_MODEL_ESCALATION` = claude-sonnet-4-5-20250929

## Hard Constraint (non negoziabili)

### Struttura codice
- `core/turno.py` è il coordinatore — il flusso delle 3 fasi è visibile in un posto
- Gli endpoint API NON contengono logica di business
- Il core NON sa nulla di HTTP
- Il database è accessibile SOLO tramite funzioni CRUD dedicate
- I prompts vivono in file separati, MAI hardcoded nella logica

### Flusso del turno (3 fasi)
1. **Preparazione**: carica stato, assembla context package (6 blocchi XML)
2. **Chiamata LLM**: streaming SSE, tool use fire-and-forget
3. **Post-processing**: Signal Processor aggiorna stati, Achievement Checker

### Tool use — Fire-and-forget
- Ogni turno è UNA singola chiamata `messages.create()` con streaming
- NON si rimanda `tool_result` a Claude
- Il turno successivo è una NUOVA call con context package aggiornato
- Le azioni vanno al frontend via SSE, i segnali si accumulano per post-processing

### Conversazione
- `turni_conversazione.contenuto` = SOLO testo visibile
- `turni_conversazione.azioni` = JSONB separato (MAI nei messages)
- `turni_conversazione.segnali` = JSONB separato (MAI nei messages)
- I `messages` per Claude contengono SOLO il testo dei turni precedenti

### Sessione
- Max UNA sessione attiva per utente
- < 5 min inattività: errore 409
- > 5 min inattività: sospendi automaticamente + crea nuova

### Streak
- Giorni consecutivi con `obiettivo_raggiunto = true`
- Si conta all'indietro da oggi (o ieri se oggi non ha studiato)
- Giorno senza record = streak interrotto

## I tre loop

- **Loop 1 (IMPLEMENTARE)**: onboarding → studio nodo → esercizi → B+C → sblocco → gamification
- **Loop 2 (PREDISPORRE)**: tabelle DB + interfacce + stub per FSRS, notifiche, ripasso interleaving
- **Loop 3 (PREDISPORRE)**: tabelle DB + interfacce + stub per Feynman, assessment, promozione multi-segnale, memoria RAG

**Principio**: ciò che non è implementato è un placeholder esplicito con interfaccia definita, MAI un hack da riscrivere.

## Knowledge Base — Stato attuale

Due dataset completi, entrambi quality gate SUPERATO 9/9:

| | Algebra1 | Algebra2 | Totale |
|---|---|---|---|
| Nodi | 114 (101 op + 13 ctx) | 69 (68 op + 1 ctx) | 183 |
| Temi | 17 | 8 | 25 |
| Esercizi | 756 (100% con soluzione) | 714 (100% con soluzione) | 1.470 |
| Relazioni | 213 | 326 | 539 |
| Copertura esercizi | 100% | 95.6% | ~98% |

I file sono in `Knowledge Base/` nella root del repo. Per lo sviluppo, copiarli in `data/Algebra1/` e `data/Algebra2/` rinominando (togliere suffisso libro).

## Discrepanze KB vs Brief (gestire nello script di import)

### 1. Nomi file diversi
- **Brief**: `nodi.json`, `relazioni.json`, `esercizi.json`
- **Realtà**: `nodi_Algebra1.json`, `relazioni_Algebra1.json`, ecc.
- **Azione**: lo script accetta folder e auto-detecta per prefisso

### 2. Temi non nel file relazioni
- **Brief**: relazioni.json = `{"relazioni": [...], "temi": [...]}`
- **Realtà**: relazioni.json = array piatto `[{nodo_da, nodo_a, ...}]`. Nessuna sezione temi.
- **Temi**: sono nel campo `tema_id` di ogni nodo
- **Azione**: estrarre temi unici dai nodi. `temi.nome` = tema_id umanizzato. `descrizione` e `ordine_visualizzazione` non disponibili (NULL o generati)

### 3. Campo `tipo` nodi: valore extra
- **Brief**: standard | integrazione
- **Realtà**: anche `strumentale` (3 nodi totali)
- **Azione**: `tipo` come TEXT (non ENUM) nel DB. Per path planning, trattare come standard

### 4. Schema `errori_comuni` arricchito
- **Brief**: {tipo, descrizione, correzione, suggerimento}
- **Realtà**: aggiunge `esempio_sbagliato`
- **Azione**: nessuna, è JSONB — il campo extra si preserva

### 5. Campi extra negli esercizi
- `competenze_chiave`, `tipo_ragionamento`, `risposta_libro`, `metodo_estrazione`, `embedding` (1024 float)
- **Azione**: salvare in `metadata` JSONB. Gli embedding esercizi sono potenzialmente utili per Loop 3

### 6. Struttura `fonte` diversa
- **Brief nodi**: {pagine, tipo}
- **Realtà nodi**: {pdf, pagina_inizio, pagina_fine, sezione_id, gerarchia}
- **Brief esercizi**: {pagina, tipo}
- **Realtà esercizi**: {pdf, pagina, sezione_id, numero_originale}
- **Azione**: tutto in `metadata` JSONB, preservare struttura reale

### 7. Anomalia Algebra1: 25 esercizi "fix"
- Indici 731-755, ID con `_fix_`, schema ridotto (9 campi su 14)
- Mancano: competenze_chiave, tipo_ragionamento, risposta_libro, metodo_estrazione, confidence
- Soluzione con schema ridotto (3 campi su 7)
- **Azione**: importare normalmente, i campi mancanti saranno assenti dal JSONB metadata

## Mapping campi import (JSON → DB)

### Nodi
| Campo JSON | Campo DB |
|---|---|
| `id` | `nodi.id` |
| `nome` | `nodi.nome` |
| `materia` | `nodi.materia` |
| `tipo` | `nodi.tipo` (default 'standard' se mancante) |
| `tipo_nodo` | `nodi.tipo_nodo` (default 'operativo' se mancante) |
| `definizione` | `nodi.definizioni_formali` (wrappare in JSONB) |
| `formule` | `nodi.formule_proprieta` |
| `errori_comuni` | `nodi.errori_comuni` |
| `esempi` | `nodi.esempi_applicazione` |
| `parole_chiave` | `nodi.parole_chiave` |
| `embedding` | `nodi.embedding` |
| `fonte` + `confidence` | `nodi.metadata` |
| `tema_id` | → tabella `temi` + `nodi_temi` |

### Esercizi
| Campo JSON | Campo DB |
|---|---|
| `id` | `esercizi.id` |
| `nodo_focale` | `esercizi.nodo_id` (FK) |
| `testo` | `esercizi.testo` |
| `tipo` | `esercizi.tipo` |
| `difficolta` | `esercizi.difficolta` |
| `soluzione` | `esercizi.soluzione` (as-is JSONB) |
| `nodi_coinvolti` | `esercizi.nodi_coinvolti` (as-is JSONB) |
| `fonte` + `confidence` + campi extra | `esercizi.metadata` |

### Relazioni
| Campo JSON | Campo DB |
|---|---|
| `nodo_da` | `relazioni.nodo_da` |
| `nodo_a` | `relazioni.nodo_a` |
| `dipendenza` | `relazioni.dipendenza` |
| `descrizione` | `relazioni.descrizione` |
| `confidence`, `passaggio` | ignorare |

## Regole di tracking e continuità tra sessioni

### Regola 1 — Aggiornare SEMPRE a fine blocco

Quando un blocco della roadmap viene completato (test passano + ruff clean), aggiornare OBBLIGATORIAMENTE questi file **prima** di dichiarare il blocco finito:

1. **`docs/roadmap.md`** — Mettere ✅ su ogni voce completata del blocco. Aggiungere dettagli implementativi (file creati, conteggio test, note rilevanti).
2. **`CLAUDE.md` sezione "Stato attuale"** — Aggiornare:
   - La riga `**Fase**` e `**Ultimo aggiornamento**`
   - Aggiungere il blocco alla lista "Completato" con una riga di riepilogo
   - Aggiornare il conteggio test totale
   - Aggiornare "Prossimo passo" col blocco successivo
3. **`CLAUDE.md` sezione "Log decisioni"** — Aggiungere eventuali decisioni architetturali prese durante il blocco

### Regola 2 — Il "Prossimo passo" è la bussola

La sezione "Prossimo passo" nel CLAUDE.md deve contenere:
- Quale blocco fare
- I file principali da creare/modificare
- Quali sezioni del brief leggere per contesto
- Eventuali dipendenze o attenzioni particolari

Questo è ciò che una sessione nuova legge per prima cosa per sapere da dove ripartire.

### Regola 3 — Checklist di fine sessione

Prima di chiudere una sessione di lavoro, verificare:
- [ ] Tutti i test passano (`pytest tests/ --ignore=tests/test_import.py`)
- [ ] Ruff clean (`ruff check`)
- [ ] `docs/roadmap.md` aggiornato
- [ ] `CLAUDE.md` sezione "Stato attuale" aggiornato
- [ ] "Prossimo passo" punta al lavoro successivo con indicazioni chiare
- [ ] Se un blocco è a metà, scrivere esattamente cosa manca nella sezione "Prossimo passo"

### Regola 4 — Blocco a metà

Se la sessione finisce nel mezzo di un blocco:
- Nella roadmap: marcare con 🔄 le voci in corso, ⬚ quelle ancora da fare
- Nel "Prossimo passo": elencare esattamente i file già scritti e quelli mancanti
- Se ci sono test che falliscono o problemi aperti, documentarli esplicitamente

### Regola 5 — Inizio sessione nuova

All'inizio di una nuova sessione:
1. Leggere `CLAUDE.md` (stato attuale + prossimo passo)
2. Leggere `docs/roadmap.md` per dettaglio del blocco da fare
3. Leggere le sezioni del brief indicate nel "Prossimo passo"
4. Leggere i file esistenti che il nuovo blocco deve usare o estendere
5. Solo dopo, iniziare a scrivere codice

## Convenzioni di sviluppo

- **Async everywhere** — tutte le funzioni DB e HTTP sono async
- **Pydantic v2** per tutti gli schema request/response
- **ruff** per formatting e linting (line-length=100, target py312)
- **pytest-asyncio** (asyncio_mode = "auto") per i test
- **Docker Compose** per tutto il dev — non installare nulla sull'host
- **JSONB** esplicito (mai JSON generico) via `sqlalchemy.dialects.postgresql`
- **UUID** con `server_default=text("gen_random_uuid()")`
- **Placeholder espliciti**: signature + docstring + `raise NotImplementedError`, mai implementazioni vuote silenziose

## Struttura codebase

```
dydat-backend/          (root del progetto = root del repo)
├── app/
│   ├── main.py                    # FastAPI app, startup
│   ├── config.py                  # Settings da .env
│   ├── api/                       # Layer HTTP (nessuna logica di business)
│   │   ├── sessione.py            # CUORE
│   │   ├── onboarding.py
│   │   ├── auth.py
│   │   ├── utente.py
│   │   ├── percorsi.py
│   │   ├── temi.py
│   │   └── achievement.py
│   ├── core/                      # Orchestratore
│   │   ├── turno.py               # Ciclo del turno (3 fasi)
│   │   ├── sessione.py            # Session Manager + Path Planner
│   │   ├── contesto.py            # Context Builder (6 blocchi)
│   │   ├── elaborazione.py        # Action Executor + Signal Processor
│   │   ├── conversazione.py       # Conversation Manager
│   │   └── gamification.py        # Achievement checker
│   ├── llm/                       # Claude API
│   │   ├── client.py              # Wrapper SDK, streaming
│   │   ├── tools.py               # Schema azioni + segnali
│   │   └── prompts/               # System prompt, direttive
│   ├── grafo/                     # Knowledge Graph
│   │   ├── struttura.py           # Grafo in memoria
│   │   ├── algoritmi.py           # Topological sort, sblocco
│   │   ├── stato.py               # Query stato utente
│   │   └── fsrs.py                # Loop 2 stub
│   ├── db/
│   │   ├── engine.py              # Async engine + session
│   │   ├── base.py                # DeclarativeBase
│   │   └── models/                # 4 file per gruppo logico
│   └── schemas/                   # Pydantic schemas
├── data/                          # KB JSON (copiati da Knowledge Base/)
│   ├── Algebra1/
│   └── Algebra2/
├── scripts/                       # import_extraction.py, seed, etc.
├── tests/
├── alembic/
├── docs/
│   └── roadmap.md
├── .env.example
├── .gitignore
├── Dockerfile
├── docker-compose.yml
└── pyproject.toml
```

## Stato attuale

**Fase**: Sviluppo — Loop 1 completo, mergiato su main, testato E2E con DB e LLM reali
**Ultimo aggiornamento**: 2026-02-18

### Completato
- [x] Analisi Knowledge Base (Algebra1 + Algebra2)
- [x] Lettura e comprensione brief v3
- [x] Identificazione discrepanze KB vs brief
- [x] Pianificazione architettura
- [x] CLAUDE.md + roadmap
- [x] **Blocco 1**: Foundation — Docker, DB, 17 tabelle, Alembic, app base, stub tutti i moduli
- [x] **Blocco 2**: Import KB — 183 nodi, 25 temi, 539 relazioni, 1470 esercizi caricati
- [x] **Blocco 3**: Grafo in memoria — NetworkX DiGraph, topological sort, verifica sblocco, path planner, cascata sblocco
- [x] **Blocco 4**: Auth — bcrypt hash, JWT con python-jose, registrazione/login, dependency `get_utente_corrente`
- [x] **Blocco 5**: Client LLM — wrapper Anthropic SDK con streaming, 16 tool schemas (azioni + segnali), parsing fire-and-forget
- [x] **Blocco 6**: Context builder — 6 blocchi XML, 6 template direttive, troncamento conversazione (>50 turni)
- [x] **Blocco 7**: Flusso del turno (IL CUORE) — `esegui_turno()` 3 fasi, Action Executor, Signal Processor, promozione (3 condizioni), cascata sblocco, conversation manager
- [x] **Blocco 8**: API sessione con SSE — Session Manager + 5 endpoint HTTP + schemas Pydantic + 29 test
- [x] **Blocco 9**: Onboarding — Onboarding Manager + 3 endpoint SSE + fasi auto (accoglienza→conoscenza→conclusione) + punto di partenza personalizzato + inizializzazione stato nodi + 24 test
- [x] **Blocco 10**: Gamification — 8 achievement (seed al startup), verifica condizioni dopo ogni turno, calcolo streak (HARD CONSTRAINT), statistiche giornaliere, API `GET /achievement` con progresso + 26 test
- [x] **Blocco 11**: API restanti + test — `GET /percorsi` + mappa nodi, `GET /temi` + dettaglio con progresso, `GET /me/statistiche` (settimana/mese/sempre), test E2E mock (walkthrough sez.18, 8 test), test integrazione LLM reale (3 smoke test con `--run-integration`) + 8 test E2E + 3 integration

### Test: 196 passed, 10 skipped (7 DB integration + 3 LLM integration), ruff clean

### Test manuale E2E completato (DB + LLM reali)
- ✅ Health check, registrazione, login
- ✅ Onboarding completo (3 turni SSE con LLM reale, tutor risponde in italiano, tono naturale)
- ✅ Sessione di studio (path planner sceglie nodo, tutor spiega con esempi, emette `mostra_formula` con LaTeX)
- ✅ API dati: `/temi` (25 temi con progresso), `/achievement` (8 con progresso), `/me/statistiche`, `/me`
- ⚠️ Fix trovato e applicato: `contesto.py` — primo turno mandava `messages=[]` → iniettato messaggio placeholder
- ✅ PR #5 mergiata su main (2026-02-18)

### Prossimo passo
- **Frontend**: il backend è pronto. Serve un brief frontend (`dydat_brief_frontend_v1.md`) nella root del repo
- Il backend non richiede modifiche per supportare il frontend — API stabili, eventi SSE definiti
- Prossimi passi backend possibili (non urgenti):
  1. **Loop 2**: FSRS spaced repetition, notifiche, ripasso interleaving (stub già predisposti)
  2. **Loop 3**: Feynman verification, assessment, memoria RAG (stub già predisposti)
  3. **Test con DB reale**: attivare i 7 test DB skippati, creare fixture con PostgreSQL di test

### Note per nuova sessione
- Il brief backend è in `dydat_brief_backend_v3.md` — cercarlo nel worktree `focused-margulis`
- La roadmap dettagliata è in `docs/roadmap.md` dentro il worktree
- Loop 1 è completo, mergiato su main, testato E2E con DB e LLM reali
- Per i test LLM reale: `pytest tests/ --run-integration` (richiede ANTHROPIC_API_KEY in .env)
- Docker: `docker compose up --build -d`, poi `alembic upgrade head`, poi `python scripts/import_extraction.py data/Algebra1 data/Algebra2`
- I dati KB (`data/Algebra1`, `data/Algebra2`) vanno copiati dal worktree `focused-margulis` se non presenti
- Il path di gh CLI è `/c/Program Files/GitHub CLI/gh`

## Log decisioni

| Data | Decisione | Motivo |
|---|---|---|
| 2026-02-17 | Docker Compose per ambiente dev | Isolamento completo dall'host |
| 2026-02-17 | 4 file modelli (1 per gruppo logico) | Mappatura diretta al brief, ~100 righe/file |
| 2026-02-17 | `tipo` e `tipo_nodo` come TEXT non ENUM | Gestire valore inatteso `strumentale` |
| 2026-02-17 | JSONB esplicito ovunque | Evitare ambiguità JSON vs JSONB in PostgreSQL |
| 2026-02-17 | KB copiata in `data/` senza spazi | Compatibilità Docker + import pulito |
| 2026-02-17 | Test su tutte le regole critiche di dominio | Sblocco, promozione, path planner, achievement |
| 2026-02-17 | Ralph Loop solo per sotto-task ripetitivi | Blocchi principali troppo accoppiati per loop autonomi |
| 2026-02-18 | Import top-level in turno.py (no inline) | Ruff lint + leggibilità |
| 2026-02-18 | `esercizi_consecutivi_ok` solo per achievement | Non è condizione di promozione (solo spiegazione + 3 esercizi + 1 primo_tentativo) |
| 2026-02-18 | `SessioneConflitto` come eccezione custom | Separa logica di dominio (409) dalla gestione HTTP nell'API layer |
| 2026-02-18 | SSE con `sse-starlette` EventSourceResponse | Formato standard SSE, unidirezionale server→client, come da brief sezione 19 |
| 2026-02-18 | `_trova_nodo_per_tema` normalizza spazi→underscore | I tema_id nel grafo usano underscore (es. `equazioni_secondo_grado`) ma il tutor può suggerire con spazi |
| 2026-02-18 | `_inizializza_stato_nodi` con `pg_insert` ON CONFLICT DO NOTHING | UPSERT sicuro per inizializzazione idempotente dei nodi utente |
| 2026-02-18 | Seed achievement al startup (lifespan) con UPSERT | Idempotente, nessun rischio di duplicati, definizioni sempre aggiornate |
| 2026-02-18 | Cache metriche nel checker achievement | Evita query ripetute se più achievement usano la stessa condizione |
| 2026-02-18 | `nodi_completati` esclude `presunto=true` | I nodi marcati presunti dall'onboarding non contano come achievement |
| 2026-02-18 | Temi completati via join `nodi_temi` (non campo diretto) | Il modello Nodo non ha `tema_id` diretto, usa tabella ponte `nodi_temi` |
| 2026-02-18 | Test integrazione LLM con marker `@pytest.mark.integration` | Skip di default, eseguibili con `--run-integration`, evita costi accidentali |
| 2026-02-18 | `_stats_periodo` come helper privato in utente.py | Riuso per settimana/mese/sempre, aggregazione da `statistiche_giornaliere` |
| 2026-02-18 | Mappa nodi esclude nodi contesto (`tipo_nodo != "contesto"`) | I nodi contesto non appaiono nella mappa visuale, come da brief |
| 2026-02-18 | Messaggio placeholder per primo turno (`contesto.py`) | Anthropic API richiede almeno 1 messaggio; onboarding/sessione partono senza input utente |
| 2026-02-18 | Merge PR #5 su main — Loop 1 completo | Tutti gli 11 blocchi testati con DB+LLM reali, pronti per frontend |
