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

## Stato Backend

Il backend e completo e testato. Vedi `backend/CLAUDE.md` per dettagli.
- 11 blocchi implementati + onboarding continuo (5 fasi), 264 test (260 passed, 4 failed pre-esistenti, 10 skipped)
- Test E2E manuale con DB + LLM reali superato
- API stabili — la fonte di verita e `docs/dydat_api_reference.md`

**Regola backend**: il backend e stabile ma puo essere esteso per feature cross-stack (es: nuovi tool LLM, prompt riscritture, filtering). Serve autorizzazione esplicita del fondatore. Le API endpoint e i modelli DB non vanno toccati senza necessita.

## Stato Frontend — Fase Corrente

### Loop 1 completato (B0-B10)
- Architettura completa: 9 modelli, 8 servizi Dio, 8 provider Riverpod, GoRouter con shell route
- Tutte le 3 tab funzionanti con dati API reali (Studio, Percorso, Profilo)
- Auth reale (login, registrazione, JWT), splash con redirect
- Test E2E superato con backend Docker
- `flutter analyze` → 0 errori
- `sizer` sostituito con `lib/core/sizer_extensions.dart` custom (compatibile Flutter 3.41)

### Loop 2 completato (B11-B16)
- SSE streaming reale: text_delta, azioni tutor, achievement, turno_completo
- Onboarding reale con AI (5 fasi: accoglienza, conoscenza, placement, piano, conclusione)
- Recap sessione + app lifecycle (sospensione/ripresa)
- Test E2E Loop 2 superato con SSE reale su emulatore Android

### Loop 3 completato (B17-B21)
- LaTeX rendering con `flutter_math_fork` (FormulaCard + inline `LatexText`)
- Node progression a 3 stati nel bottom sheet (non_iniziato/in_corso/operativo)
- Storico sessioni nella home (`SessionHistoryWidget`) + `GET /sessione/` backend
- Recap con card "Tema completato" via cross-reference pathProvider
- Celebrazioni animate: particle burst (primo_tentativo), radial glow (con_guida), haptic
- `esito_esercizio` nuovo evento SSE nel backend
- Fix hardcoded colors in mascotte, tema_card, tools_tray, exercise_card
- `flutter analyze` 0 errori, 195 test passed

### Loop 4 completato (B22-B25)
- Piano completo Loop 4-7 in `.claude/plans/roadmap_loop4_7.md`
- **B22**: Celebrazione promozione nodo + SSE event (DONE)
- **B23**: SSE reconnect + resilienza errori (DONE)
- **B24**: Fix test backend/frontend + pulizia worktree (DONE)
- **B25**: MascotteWidget con enum `MascotteState`, animazioni per stato, E2E Loop 4 (DONE)
- **Deferito**: mascotte "Creatura di Luce" (mancano asset design), voice input

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
| 14 | Onboarding reale con SSE + onboarding adattivo (B14-bis) | DONE | S10 |
| 15 | Recap sessione + App lifecycle | DONE | S11 |
| 16 | Test E2E Loop 2 | DONE | S12 |

### Loop 2 COMPLETATO
Tutti i 6 blocchi (B11-B16) completati. Flusso E2E completo con SSE reale senza crash verificato manualmente su emulatore Android. Bug fix: 409 handling race condition nel session_provider.

## Roadmap Frontend — Loop 3 (B17-B21) — UX Polish + LaTeX + Storico

| Blocco | Contenuto | Stato | Sessione |
|---|---|---|---|
| 17 | LaTeX rendering (FormulaCard + inline tutor messages) | DONE | S13 |
| 18 | Node progression visibility + Session history backend | DONE | S14 |
| 19 | Session history frontend + Recap improvements | DONE | S15 |
| 20 | Celebration animations + esito SSE backend | DONE | S16 |
| 21 | Test E2E Loop 3 + Polish | DONE | S17 |

### Loop 3 COMPLETATO
Tutti i 5 blocchi (B17-B21) completati. Code review + hardcoded colors fix + flutter analyze 0 errori + flutter test 195/199 (4 pre-esistenti). Test manuale E2E pendente.

## Roadmap Loop 4-7 (B22-B37) — Completamento Prodotto

Piano dettagliato in **`.claude/plans/roadmap_loop4_7.md`** — leggerlo a inizio sessione.

| Loop | Blocchi | Focus | Sessioni |
|------|---------|-------|----------|
| 4 | B22-B25 | Quick wins + robustezza | S18-S21 |
| 5 | B26-B29 | FSRS Spaced Repetition | S22-S25 |
| 6 | B30-B33 | Feynman + Comprensione Profonda | S26-S29 |
| 7 | B34-B37 | Atmosfera + Polish | S30-S33 |

### Prossima sessione
**S22 — B26** — Algoritmo FSRS (Backend). Installare libreria `fsrs` da PyPI nel Docker. `backend/app/grafo/fsrs.py` — sostituire stub con implementazione reale: `calcola_prossimo_ripasso(db, utente_id, nodo_id, esito)` mappa esiti a FSRS Rating, `get_nodi_da_ripassare(db, utente_id)` query nodi scaduti. `backend/app/core/elaborazione.py` — in `_processa_risposta_esercizio()`, dopo update contatori, chiamare `calcola_prossimo_ripasso()` per aggiornare campi SR. 8-10 test in `test_fsrs.py`.

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
| S12 | B16 | Flusso completo con SSE reale senza crash | `feature/frontend-b1-b2` (consolidato) |

### Loop 3 (UX Polish + LaTeX + Storico)
| Sessione | Blocchi | Gate di uscita | Branch |
|----------|---------|----------------|--------|
| S13 | B17 | LaTeX renderizza + inline funziona + unit test | `feature/frontend-b17` |
| S14 | B18 | 3 stati nodo + backend GET /sessione/ | `feature/frontend-b18` |
| S15 | B19 | Storico sessioni nella home + recap tema completato | `feature/frontend-b19` |
| S16 | B20 | Celebrazioni burst/glow + esito SSE backend | `feature/frontend-b20` |
| S17 | B21 | Flusso E2E Loop 3 completo senza crash | `feature/frontend-b21` |

### Loop 4 (Quick wins + Robustezza)
| Sessione | Blocchi | Gate di uscita | Branch |
|----------|---------|----------------|--------|
| S18 | B22 | Promozione SSE + celebrazione | `feature/loop4-b22` |
| S19 | B23 | SSE reconnect + banner | `feature/loop4-b23` |
| S20 | B24 | 0 test failures + worktree rimosso | `feature/loop4-b24` |
| S21 | B25 | MascotteState + E2E Loop 4 | `feature/loop4-b25` |

**Regola**: ogni sessione crea branch da main, PR a fine sessione dopo test verdi.

## Documenti di Riferimento

| Documento | Cosa contiene | Quando leggerlo |
|---|---|---|
| `.claude/plans/frontend-integration.md` | **Piano operativo Loop 1-3** — dettaglio file per file | Riferimento (Loop 1-3 completati) |
| `.claude/plans/roadmap_loop4_7.md` | **Piano operativo Loop 4-7** — B22-B37 dettaglio blocco per blocco | Sempre, a inizio sessione |
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
docker exec backend-backend-1 alembic upgrade head
docker exec backend-backend-1 python scripts/import_extraction.py data/Algebra1 data/Algebra2
# Se il backend non parte al primo avvio (tabelle mancanti), riavviare:
docker compose restart backend
```

**ATTENZIONE**: lanciare Docker SEMPRE da `backend/`, MAI dal worktree `nostalgic-hertz`. Il worktree ha codice vecchio e non riceve le modifiche. Verificare: `docker ps` deve mostrare `backend-backend-1`, NON `nostalgic-hertz-backend-1`.

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## Regole di Sessione

### Inizio sessione
1. Leggere questo CLAUDE.md (stato globale + prossima sessione)
2. Leggere `.claude/plans/roadmap_loop4_7.md` (piano dettagliato Loop 4-7)
3. Leggere `.claude/status.md` (checkpoint: da dove riprendere)
4. Leggere `docs/dydat_api_reference.md` se il blocco tocca le API
5. Creare branch `feature/loopX-bY` da main

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
- **NON modificare il backend** senza autorizzazione del fondatore (eccezioni: CORS, nuovi tool LLM per feature approvate)
- **NON implementare** mascotte "Creatura di Luce" (manca design), beat-aware canvas styling — rimandati a Loop 4
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
| Unit test LaTeX parsing | B17 | Delimitatori $...$ e $$...$$ |
| Unit test SessioneListItem | B19 | fromJson roundtrip |
| Unit test EsitoEsercizio | B20 | SSE event parsing |
| Integration test Loop 3 | B21 | Flusso E2E con LaTeX + storico + celebrazioni |

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
| 2026-02-19 | Backend modificabile per feature cross-stack | B14-bis richiede tool LLM + prompt + filtering nel backend |
| 2026-02-19 | Docker SEMPRE da backend/, MAI dal worktree | Worktree nostalgic-hertz ha codice vecchio, causa mismatch |
| 2026-02-19 | Aggiunto flutter_markdown per rendering testo tutor | Raw **, - nel testo senza parsing markdown |
| 2026-02-19 | Onboarding esteso a 5 fasi (placement + piano) | Test diagnostico + piano studio personalizzato prima di completare onboarding |
| 2026-02-19 | Transizioni signal-driven per fasi avanzate | LLM decide quando passare da placement a piano e da piano a conclusione |
| 2026-02-19 | Zero migrazioni DB per onboarding continuo | Tutto in stato_orchestratore JSONB, nessun schema change |
| 2026-02-19 | Flag `_handling409` per race condition 409 | `onDone` del SSE stream azzerava stato prima che il fallback REST completasse |
| 2026-02-19 | FormulaCard mostra LaTeX raw — fix in Loop 3 | Rendering LaTeX richiede pacchetto dedicato, non fix cosmetico temporaneo |
| 2026-02-19 | Loop 2 completato — tutti i 6 blocchi B11-B16 | E2E manuale su emulatore: streaming, azioni, lifecycle, 409, recap tutti verificati |
| 2026-02-19 | Loop 3 pianificato — 5 blocchi B17-B21 | LaTeX, storico sessioni, node progression, recap improvements, celebrazioni |
| 2026-02-19 | Mascotte deferita a Loop 4 | Mancano asset di design (SVG/Rive), il placeholder circolare resta |
| 2026-02-19 | Backend modifiche autorizzate per Loop 3 | GET /sessione/ (list) + esito_esercizio SSE event |
| 2026-02-19 | flutter_math_fork per LaTeX rendering | Non WebView, rendering nativo Flutter |
| 2026-02-19 | LatexText widget per inline math | Parsa $...$ e $$...$$, fallback su MarkdownText per plain text, fallback monospace per LaTeX malformato |
| 2026-02-19 | Streaming bubble resta MarkdownText | Delimitatori $ possono arrivare split durante SSE streaming |
| 2026-02-19 | SessionHistoryWidget nella home sotto "Inizia" | Mostra sessioni recenti con date relative, durata, stato — tap naviga a recap |
| 2026-02-19 | Tema completato nel recap con pathProvider.loadTopics() | Cross-reference nodiLavorati con temi completati — card celebrativa con trofeo |
| 2026-02-19 | Auto-reload session history su ritorno alla home | StudioScreen rileva stato vuoto e ricarica in build() con Future.microtask |
| 2026-02-19 | `esito_esercizio` SSE event nel backend | `processa_segnali` ritorna tupla (promozioni, esiti), turno.py emette evento |
| 2026-02-19 | `EsitoEsercizioEvent` sealed class nel frontend | Nuova variante con `corretto`, `primoTentativo`, `conGuida` |
| 2026-02-19 | Celebration overlay (burst + glow) | `showCelebrationOverlay()` con particle burst per primo_tentativo, radial glow per con_guida |
| 2026-02-19 | Haptic feedback differenziato per esito | heavyImpact per primo_tentativo, mediumImpact per con_guida |
| 2026-02-19 | ExerciseCard colori hardcoded fixati | `Color(0xFF7EBF8E)` → `theme.colorScheme.secondary`, `Color(0xFFC97070)` → `theme.colorScheme.error` |
| 2026-02-27 | Roadmap Loop 4-7 (B22-B37) pianificata | 16 blocchi in 16 sessioni — quick wins, FSRS, Feynman, atmosfera |
| 2026-02-27 | FSRS duale: interleaving + sezione ripasso | Fondatore vuole entrambi gli approcci per completezza pedagogica |
| 2026-02-27 | Feynman tono incoraggiante | Mai giudicante, "buona intuizione, prova ad approfondire..." |
| 2026-02-27 | Mascotte asset con AI generativa (track separato) | Midjourney/DALL-E per PNG, Flutter code per glow/transizioni |
| 2026-02-27 | `promozione` SSE event nel backend | `turno.py` yield dopo ogni promozione con nodo_id, nodo_nome, nuovo_livello, nodi_sbloccati |
| 2026-02-27 | `PromozioneEvent` sealed class nel frontend | Nuovo sottotipo SSE con 4 campi, registrato nel parser |
| 2026-02-27 | `showPromotionCelebration()` celebrazione full-screen | 48 particelle, trofeo pulsante, 2500ms, doppio heavyImpact, nome nodo + nodi sbloccati |
| 2026-02-27 | SSE retry con backoff esponenziale in `SseClient` | max 3 retry, 1s/2s/4s, retry su timeout/network/5xx, NO retry su 4xx |
| 2026-02-27 | `ReconnectingEvent` generato client-side | Non e un evento backend — SseClient lo yield prima di ogni retry |
| 2026-02-27 | `isReconnecting` in `SessionScreenState` | Banner giallo "Riconnessione in corso..." nello studio_screen |
| 2026-02-27 | Snackbar errore fatale dopo retry esauriti | `_lastShownError` tracker evita duplicati |
| 2026-02-27 | `_calcola_inattivita` async con DB query | Usa timestamp ultimo turno (non solo created_at) per calcolo inattivita |
| 2026-02-27 | ThemeNotifier initial state `ThemeMode.dark` | Dark-first design, test aggiornati di conseguenza |
| 2026-02-27 | DioAdapter non supporta ResponseType.plain | JSON-encodes body, escapa newlines. Fix: Dio InterceptorsWrapper per test SSE plain text |
| 2026-02-27 | Worktree `nostalgic-hertz` rimosso da git | `git worktree prune` — directory fisica locked, rimuovere manualmente |
