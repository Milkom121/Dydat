# CLAUDE.md — Dydat Monorepo

## Progetto

**Dydat** e un tutor AI adattivo per matematica, fisica e chimica. App mobile Flutter + backend FastAPI + Claude API. One-man team con AI coding agents.

## Struttura Monorepo

```
Dydat_V1_2026/
├── backend/          # Python/FastAPI — COMPLETO (Loop 1, 11 blocchi, 196 test)
├── frontend/         # Flutter/Dart — IN SVILUPPO (integrazione con backend)
├── docs/             # Documentazione progetto
├── .claude/
│   ├── plans/frontend-integration.md  # Piano operativo dettagliato
│   └── status.md                       # Checkpoint tra sessioni
├── .gitignore
├── CLAUDE.md         # QUESTO FILE — bussola per le sessioni di lavoro
└── README.md
```

## Stato Backend (NON TOCCARE)

Il backend e completo e testato. Vedi `backend/CLAUDE.md` per dettagli.
- 11 blocchi implementati, 196 test (186 passed, 10 skipped)
- Test E2E manuale con DB + LLM reali superato
- API stabili — la fonte di verita e `docs/dydat_api_reference.md`

**Non modificare il backend** a meno di bug bloccanti (es: CORS mancante per dev).

## Stato Frontend — Fase Corrente

### Loop 1 completato (B0-B10)
- Architettura completa: 9 modelli, 8 servizi Dio, 8 provider Riverpod, GoRouter con shell route
- Tutte le 3 tab funzionanti con dati API reali (Studio, Percorso, Profilo)
- Auth reale (login, registrazione, JWT), splash con redirect
- Test E2E superato con backend Docker
- `flutter analyze` → 0 errori
- `sizer` sostituito con `lib/core/sizer_extensions.dart` custom (compatibile Flutter 3.41)

### Fase attuale: Loop 2 — SSE Streaming
- **Obiettivo**: streaming reale delle risposte tutor, azioni nel canvas, onboarding reale
- **Blocchi**: B11-B16 (6 sessioni, S7-S12)
- **NON implementiamo ora**: LaTeX rendering, animazioni celebrative, mascotte animata — rimandati a Loop 3

### Stack Frontend (HARD CONSTRAINT)
| Componente | Scelta |
|---|---|
| Framework | Flutter (mobile-first) |
| State Management | Riverpod (flutter_riverpod) |
| Routing | GoRouter (go_router) |
| HTTP Client | Dio |
| JWT Storage | flutter_secure_storage |
| Responsive | sizer_extensions.dart custom (.w .h .sp) |
| Tema | Dark-first, ThemeMode.system default |
| Font | Plus Jakarta Sans (Google Fonts) |

## Roadmap Frontend — Loop 1 (B0-B10) — COMPLETATO

| Blocco | Contenuto | Stato | Sessione |
|---|---|---|---|
| 0 | Pulizia repo, monorepo, CLAUDE.md, fix sizer | DONE | S0 |
| 1 | Dipendenze + config | DONE | S1 |
| 2 | Modelli dati (9 file) | DONE | S1 |
| 3 | Servizi API (8 file) | DONE | S2 |
| 4 | Provider Riverpod (8 file) | DONE | S2 |
| 5 | GoRouter + shell app | DONE | S3 |
| 6 | Schermate auth (login, registrazione, splash) | DONE | S4 |
| 7 | Tab Percorso (dati reali) | DONE | S4 |
| 8 | Tab Profilo (da zero) | DONE | S5 |
| 9 | Tab Studio (SSE placeholder) | DONE | S5 |
| 10 | Test E2E con backend | DONE | S6 |

## Roadmap Frontend — Loop 2 (B11-B16) — SSE Streaming Reale

| Blocco | Contenuto | Stato | Sessione |
|---|---|---|---|
| 11 | SSE Client + Modelli eventi | DONE | S7 |
| 12 | Studio Screen con SSE reale | DONE | S8 |
| 13 | Azioni tutor nel canvas (exercise/formula/backtrack) | DONE | S9 |
| 14 | Onboarding reale con SSE | TODO | S10 |
| 15 | Recap sessione + App lifecycle | TODO | S11 |
| 16 | Test E2E Loop 2 | TODO | S12 |

### Prossima sessione
**S10 — Blocco 14**: Onboarding reale con SSE. Collegare OnboardingScreen a SSE streaming, rimuovere dati mock, registrazione con conversione utente_temp_id.

## Pipeline Sessioni

### Loop 1 (completato)
| Sessione | Blocchi | Gate di uscita | Stato |
|----------|---------|----------------|-------|
| S1 | B1+B2 | analyze 0 err + unit test modelli | DONE |
| S2 | B3+B4 | analyze 0 err + unit test services/providers | DONE |
| S3 | B5 | app parte + navigazione + auth redirect | DONE |
| S4 | B6+B7 | login/register reali + percorso con dati API | DONE |
| S5 | B8+B9 | tutte le tab con dati reali | DONE |
| S6 | B10 | flusso E2E completo con backend | DONE |

### Loop 2 (SSE streaming)
| Sessione | Blocchi | Gate di uscita | Branch |
|----------|---------|----------------|--------|
| S7 | B11 | Unit test SSE parser + analyze 0 err | `feature/frontend-sse-client` |
| S8 | B12 | Testo tutor in streaming reale nel canvas | `feature/frontend-studio-sse` |
| S9 | B13 | Exercise/formula/backtrack card con dati SSE | `feature/frontend-azioni-tutor` |
| S10 | B14 | Onboarding completo con tutor AI + registrazione conversione | `feature/frontend-onboarding` |
| S11 | B15 | Recap post-sessione + sospensione in background | `feature/frontend-recap-lifecycle` |
| S12 | B16 | Flusso completo con SSE reale senza crash | `feature/frontend-e2e-loop2` |

**Regola**: ogni sessione crea branch da main, PR a fine sessione dopo test verdi.

## Documenti di Riferimento

| Documento | Cosa contiene | Quando leggerlo |
|---|---|---|
| `.claude/plans/frontend-integration.md` | **Piano operativo** — dettaglio file per file | Sempre, a inizio sessione |
| `.claude/status.md` | **Checkpoint** — stato corrente, problemi aperti | Sempre, a inizio sessione |
| `docs/dydat_api_reference.md` | **Fonte di verita API** — endpoint, modelli, flussi | Blocchi 2-10 |
| `docs/dydat_brief_rocket_new_v2.md` | Brief originale Rocket.new — architettura ideale | Riferimento |
| `docs/dydat_direzione_visiva_v2.md` | Palette, tipografia, mascotte, celebrazioni | Riferimento UI |
| `docs/dydat_digest.md` | Mappa completa del progetto | Riferimento |
| `docs/CLAUDE_CODE_BRIEF_FRONTEND.md` | Brief per integrazione frontend | Riferimento |
| `backend/CLAUDE.md` | Stato e architettura backend | Riferimento |

## Come Avviare

### Backend
```bash
cd backend
docker compose up --build -d
# Dentro il container:
alembic upgrade head
python scripts/import_extraction.py data/Algebra1 data/Algebra2
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## Regole di Sessione

### Inizio sessione
1. Leggere questo CLAUDE.md (stato globale + prossima sessione)
2. Leggere `.claude/plans/frontend-integration.md` (piano dettagliato)
3. Leggere `.claude/status.md` (checkpoint: da dove riprendere)
4. Leggere `docs/dydat_api_reference.md` se il blocco tocca le API
5. Creare branch `feature/frontend-bX-bY` da main

### Fine sessione — CHECKLIST OBBLIGATORIA
- [ ] `flutter analyze` → zero errori
- [ ] Test del blocco → tutti verdi
- [ ] `.claude/status.md` aggiornato (blocchi fatti, problemi, prossimo)
- [ ] Roadmap qui sopra aggiornata (stato blocchi)
- [ ] "Prossima sessione" aggiornato
- [ ] Commit con messaggio strutturato (solo se autorizzato dal fondatore)
- [ ] PR verso main (solo se autorizzato dal fondatore)
- [ ] **PROMPT SESSIONE SUCCESSIVA** — generare e mostrare al fondatore un prompt copia-incolla per avviare la prossima sessione (formato sotto)

### Formato prompt sessione successiva
Alla fine di ogni sessione, DEVI:
1. Generare il prompt copia-incolla (formato sotto)
2. Suggerire il **nome sessione** da dare alla conversazione: `Dydat — BX+BY — [attivita svolta]`
   Esempi: `Dydat — B1+B2 — Config e Modelli`, `Dydat — B5 — GoRouter e Shell App`

```
Sessione SX — Dydat Frontend, Blocchi Y+Z ([titolo])
NOME SESSIONE: Dydat — BY+BZ — [attivita]

PRIMA DI SCRIVERE CODICE, leggi questi file in ordine:
1. CLAUDE.md
2. .claude/plans/frontend-integration.md
3. .claude/status.md
4. [altri file rilevanti per i blocchi specifici]

COSA FARE in questa sessione:
- Blocco Y: [descrizione concreta]
- Blocco Z: [descrizione concreta]

GATE DI USCITA:
- [criteri specifici]

NON fare: commit, push, toccare backend, toccare widget UI esistenti.
```
Questo prompt e l'UNICA cosa che il fondatore deve incollare per avviare la sessione.

### Test manuale del fondatore
Da B5 in poi (quando l'app ha navigazione reale), ci sono momenti in cui serve un test manuale sull'emulatore/device. Quando arriva quel momento, DEVI comunicarlo in modo chiaro con questo formato:

```
---------------------------------------------
FONDATORE: SERVE TEST MANUALE
---------------------------------------------
Cosa testare:
1. [azione concreta, es: "Apri l'app e verifica che la splash screen faccia redirect al login"]
2. [azione concreta]
3. [azione concreta]

Cosa mi aspetto:
- [risultato atteso per ogni punto]

Se qualcosa non funziona:
- Mandami uno screenshot o descrivi cosa vedi
---------------------------------------------
```

Non procedere al passo successivo finche il fondatore non conferma l'esito del test.

### Regole ferree
- **NON committare** senza autorizzazione esplicita del fondatore
- **NON pushare** senza autorizzazione esplicita del fondatore
- **NON modificare il backend** (salvo CORS)
- **NON implementare** LaTeX rendering, animazioni celebrative (particelle/glow), mascotte animata — rimandati a Loop 3
- **NON toccare** app_theme.dart, widget esistenti (salvo ricablarli su provider)
- Ogni widget nuovo usa `Theme.of(context)` — zero colori hardcoded
- JSON snake_case → Dart camelCase nei fromJson
- Commit message: `feat(frontend): BX+BY — [descrizione breve]`

### Testing per blocco
| Tipo | Quando | Tool |
|---|---|---|
| Analisi statica | Ogni blocco | `flutter analyze` (0 errori) |
| Unit test modelli | B2 | fromJson/toJson roundtrip |
| Unit test servizi | B3 | Mock Dio adapter |
| Unit test provider | B4 | ProviderContainer + mock |
| Smoke test manuale | B5+ | App parte senza crash |
| Integration test | B10 | Flusso E2E con backend reale |
| Unit test SSE parser | B11 | Stream mockato con tutti i tipi evento |
| SSE streaming manuale | B12+ | Testo tutor in tempo reale |
| Integration test Loop 2 | B16 | Flusso E2E con SSE reale |

## Log Decisioni

| Data | Decisione | Motivo |
|---|---|---|
| 2026-02-18 | Approccio chirurgico: tieni widget UI, ricostruisci architettura | Widget Rocket.new buoni esteticamente, manca tutto il resto |
| 2026-02-18 | Monorepo backend/ + frontend/ + docs/ | Tutto in un posto, struttura chiara |
| 2026-02-18 | Rimossi 5 worktrees, tenuto solo nostalgic-hertz | 3 vuoti, 2 superseded dal backend completo |
| 2026-02-18 | SSE come fase futura, non in questo piano | Prima fondamenta (REST), poi streaming |
| 2026-02-18 | Sostituito sizer con sizer_extensions.dart custom | sizer ^2.0.15 incompatibile con Flutter 3.41 |
| 2026-02-18 | Rimossi web e universal_html | Non necessari, causavano conflitti |
| 2026-02-18 | Pipeline 6 sessioni da 1-2 blocchi | Contesto pulito, test dopo ogni sessione |
| 2026-02-18 | Branch per sessione + PR verso main | Rollback facile, review before merge |
