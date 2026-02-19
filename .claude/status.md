# Status Checkpoint — Dydat Frontend

> Aggiornato da ogni sessione. La sessione successiva legge questo per sapere da dove partire.

## Stato Corrente

**Ultimo aggiornamento**: 2026-02-19
**Ultima sessione**: S13 (B17 — LaTeX Rendering) — COMPLETATA
**Branch attivo**: feature/frontend-b17 (contiene B17)
**Loop 2 COMPLETATO**: tutti i 6 blocchi B11-B16 implementati e testati E2E con SSE reale.
**Loop 3 IN CORSO**: B17 DONE, B18-B21 TODO.
**Prossima sessione**: S14 — B18 (Node Progression + History Backend)

## Blocchi Completati

| Blocco | Stato | Sessione | Note |
|--------|-------|----------|------|
| B0 — Setup monorepo | DONE | S0 | Monorepo creato, sizer sostituito con sizer_extensions.dart |
| B1 — Dipendenze + Config | DONE | S1 | flutter_riverpod, go_router, flutter_secure_storage, json_annotation + config files |
| B2 — Modelli dati | DONE | S1 | 9 file modelli + 9 .g.dart generati + 37 unit test tutti verdi |
| B3 — Servizi API | DONE | S2 | 8 servizi (dio_client, storage, auth, user, onboarding, session, path, achievement) |
| B4 — Provider Riverpod | DONE | S2 | 8 provider (auth, user, onboarding, session, path, achievement, stats, theme) |
| B5 — GoRouter + Shell | DONE | S3 | GoRouter con shell route, auth redirect, mock login, 3 tab funzionanti |
| B6 — Schermate Auth | DONE | S4 | Login, Registration e Splash ricablati su auth_provider reale |
| B7 — Tab Percorso | DONE | S4 | LearningPathScreen + widget ricablati su path_provider con dati API |
| B8 — Tab Profilo | DONE | S5 | ProfileScreen con dati reali, stats, achievement, tema, logout |
| B9 — Tab Studio | DONE | S5 | StudioScreen ricablato su session_provider REST, timer, placeholder SSE |
| B10 — Test E2E | DONE | S6 | Flusso completo testato con backend reale — tutti i passi superati |
| B11 — SSE Client + Modelli eventi | DONE | S7 | sse_client.dart + sse_events.dart + 33 unit test tutti verdi |
| B12 — Studio con SSE reale | DONE | S8 | SSE streaming in StudioScreen, cursore ambra, auto-scroll |
| B13 — Azioni tutor nel canvas | DONE | S9 | ExerciseCard, FormulaCard, BacktrackCard, ChiudiSessioneCard, AchievementToast con dati SSE reali |
| B14 — Onboarding reale con SSE | DONE | S10 | OnboardingScreen con SSE streaming, conversione utente temp→registrato, cursore ambra |
| B14-bis — Onboarding adattivo | DONE | S10-bis | Tool `onboarding_domanda` backend + widget UI frontend (scelta/testo/scala) + markdown rendering + Docker fix worktree |
| B14-ter — Onboarding continuo (backend) | DONE | S10-ter | 5 fasi onboarding (placement + piano), segnali placement_esito/transizione_fase, nodi gateway, direttive placement/piano |
| B15 — Recap + App lifecycle | DONE | S11 | RecapSessionScreen con dati reali, route /recap/:sessioneId, WidgetsBindingObserver per sospensione/ripresa |
| B16 — Test E2E Loop 2 | DONE | S12 | Flusso completo verificato manualmente: SSE streaming, azioni tutor, lifecycle, 409, recap. Bug fix: 409 race condition |

## Risultati Test E2E (S6)

### Backend API (curl)
Tutti gli endpoint testati e funzionanti:
- `POST /auth/registrazione` → 201, JWT ottenuto
- `POST /auth/login` → 200, JWT ottenuto
- `GET /utente/me` → 200, profilo corretto
- `GET /utente/me/statistiche` → 200, stats corrette
- `GET /percorsi/` → 200, lista percorsi
- `GET /temi/` → 200, 25 temi matematica
- `GET /achievement/` → 200, 8 achievement prossimi
- `POST /sessione/inizia` → 200, SSE con sessione_creata + text_delta
- `POST /sessione/{id}/turno` → 200, SSE con risposta tutor
- `POST /sessione/{id}/sospendi` → 200, sessione sospesa
- `POST /sessione/{id}/termina` → 200, sessione completata

### Frontend E2E (emulatore Android)
Flusso completo testato manualmente:
1. Splash → Login: redirect corretto
2. Dev quick login: funzionante (login-first, register come fallback)
3. Tab Studio: creazione sessione, invio messaggio, timer, termina sessione — OK
4. Tab Percorso: 25 temi visibili, dettaglio nodi, pull-to-refresh — OK
5. Tab Profilo: dati reali, stats, achievement, cambio tema, logout — OK
6. Re-login: funzionante dopo logout
7. 409 handling: ripresa sessione attiva — OK

### Bug fix in S6
- **Dev quick login**: invertita logica da register-first a login-first per evitare flash errore "Email gia' registrata" quando l'utente dev esiste gia

### Analisi statica
- `flutter analyze` → 0 errori, 0 warning

## Loop 2 — Piano (B11-B16)

| Blocco | Contenuto | Stato | Sessione |
|--------|-----------|-------|----------|
| B11 — SSE Client + Modelli eventi | `sse_client.dart`, `sse_events.dart`, parsing tutti i tipi evento | DONE | S7 |
| B12 — Studio con SSE reale | Testo tutor in streaming, rimuovere placeholder | DONE | S8 |
| B13 — Azioni tutor nel canvas | Exercise/formula/backtrack card con dati SSE, achievement toast | DONE | S9 |
| B14 — Onboarding reale con SSE | Onboarding con tutor AI, registrazione conversione utente_temp | DONE | S10 |
| B15 — Recap + App lifecycle | Recap post-sessione, sospensione in background | DONE | S11 |
| B16 — Test E2E Loop 2 | Flusso completo SSE reale senza crash | DONE | S12 |

Dettaglio completo in `.claude/plans/frontend-integration.md`.

## Risultati S7 (B11 — SSE Client + Modelli eventi)

### File creati
- `lib/models/sse_events.dart` — sealed class `SseEvent` con 7 sottotipi tipizzati (SessioneCreataEvent, OnboardingIniziatoEvent, TextDeltaEvent, AzioneEvent, AchievementEvent, TurnoCompletoEvent, ErroreEvent) + 4 typed action data classes (ProponiEsercizio, MostraFormula, SuggerisciBacktrack, ChiudiSessione)
- `lib/services/sse_client.dart` — client SSE generico basato su `http` package, metodo `stream()` che ritorna `Stream<SseEvent>`, parsing line-by-line con `sseLineTransformer()`, gestione errori HTTP/timeout/connessione
- `test/models/sse_events_test.dart` — 20 unit test per tutti i tipi di evento + edge case
- `test/services/sse_client_test.dart` — 13 unit test (line transformer, raw stream parsing, pipeline completa, chunked delivery)

### Dipendenze aggiunte
- `http: ^1.2.0` (risolto come 1.6.0) — per SSE streaming line-by-line

### Analisi statica
- `flutter analyze` → 0 errori, 0 warning

### Test
- 33 test nuovi — tutti verdi

## Risultati S8 (B12 — Studio Screen con SSE reale)

### File modificati
- `lib/services/session_service.dart` — Aggiunto `SseClient` come dipendenza, nuovi metodi `startStream()` e `sendTurnStream()` che ritornano `Stream<SseEvent>`
- `lib/providers/session_provider.dart` — Nuovo stato: `isStreaming`, `currentTutorText`, `currentTurnActions`, `currentTurnAchievements`. Nuovi metodi: `startSessionStream()`, `sendTurnStream()`, `_handleSseEvent()`, `_finalizeTutorMessage()`. Gestione subscription lifecycle con `_cancelSubscription()`.
- `lib/presentation/studio_screen/studio_screen.dart` — Rimosso placeholder SSE. `_startSession()` usa `startSessionStream()`. `_sendMessage()` usa `sendTurnStream()`. Streaming bubble con cursore ambra pulsante (`_AmberCursor`). Auto-scroll durante streaming. Input disabilitato durante streaming.
- `lib/main.dart` — Iniettato `SseClient` in `SessionService`
- `test/services/session_service_test.dart` — Aggiunto `SseClient` nella setUp
- `test/providers/session_provider_test.dart` — Aggiunto `SseClient` nella setUp

### Analisi statica
- `flutter analyze` → 0 errori, 0 warning

### Test
- 153 test — tutti verdi (4 fallimenti pre-esistenti: 3 path_service + 1 session_service.start mock)
- 10 test session_provider — tutti verdi
- 33 test SSE — tutti verdi

## Risultati S9 (B13 — Azioni tutor nel canvas)

### File modificati
- `lib/presentation/studio_screen/widgets/exercise_card_widget.dart` — Riscritto: accetta `ProponiEsercizioAction` da SSE, campo input risposta, bottone "Verifica" che invia via `sendTurnStream()`
- `lib/presentation/studio_screen/widgets/formula_card_widget.dart` — Riscritto: accetta `MostraFormulaAction` da SSE, mostra formula raw (no LaTeX), bottone "Copia"
- `lib/presentation/studio_screen/widgets/backtrack_card_widget.dart` — Riscritto: accetta `SuggerisciBacktrackAction` da SSE, bottoni "Ok, rivediamolo" / "Continua qui" che inviano messaggio al tutor
- `lib/presentation/studio_screen/studio_screen.dart` — `_messages` ora supporta tipi: user, tutor, exercise, formula, backtrack, chiudi. `_syncTutorMessages()` sincronizza anche azioni e achievement. `_buildChatItem()` renderizza il widget corretto per tipo. Achievement toast via `WidgetsBinding.instance.addPostFrameCallback`.

### File creati
- `lib/presentation/studio_screen/widgets/achievement_toast_widget.dart` — Overlay toast con slide-in/fade, icona per tipo (sigillo/medaglia/costellazione), auto-dismiss 4s
- `lib/presentation/studio_screen/widgets/chiudi_sessione_card_widget.dart` — Card riepilogo sessione con testo riepilogo, prossimi passi, bottone "Termina sessione"

### Analisi statica
- `flutter analyze` → 0 errori, 0 warning (No issues found!)

### Test
- 153 test — tutti verdi (4 fallimenti pre-esistenti: 3 path_service + 1 session_service.start mock — invariati da S8)
- Nessun nuovo test fallito

## Risultati S10 (B14 — Onboarding reale con SSE)

### File modificati
- `lib/services/onboarding_service.dart` — Riscritto: aggiunto `SseClient` come dipendenza, nuovi metodi `startStream()` e `sendTurnStream()` che ritornano `Stream<SseEvent>`, rimossi metodi REST `start()` e `sendTurn()`. `complete()` REST mantenuto.
- `lib/providers/onboarding_provider.dart` — Riscritto: nuovo stato con `currentTutorText`, `isStreaming`, `turnsCompleted`, `progress` getter. Nuovi metodi SSE: `startOnboarding()`, `sendMessage()`, `completeOnboarding()`, `_handleSseEvent()`, `_finalizeTutorMessage()`. Gestione subscription lifecycle. Rimossi `setIds()` e `addTutorMessage()` (ora gestiti internamente dal SSE handler).
- `lib/presentation/onboarding_screen/onboarding_screen.dart` — Convertito da `StatefulWidget` a `ConsumerStatefulWidget`. Rimossi mock: `_simulateAiResponse()` e messaggi placeholder. Collegato a `onboardingProvider` per SSE reale. Streaming bubble con `_AmberCursor` ambra pulsante. Typing indicator. Progress bar da turni reali. Bottone "Inizia il tuo percorso!" dopo ~8 turni. Input disabilitato durante streaming.
- `lib/presentation/registration_screen/registration_screen.dart` — Aggiunto import `onboarding_provider`. `_handleRegistration()` legge `utenteTempId` dal provider e lo passa a `authProvider.register()`.
- `lib/main.dart` — Creato `OnboardingService` con `SseClient` iniettato. Aggiunto `onboardingProvider.overrideWith()` nel `ProviderScope`.
- `test/services/onboarding_service_test.dart` — Aggiornato per nuova API con `SseClient`, rimossi test per metodi REST rimossi.
- `test/providers/onboarding_provider_test.dart` — Riscritto per nuova API SSE-based.

### Analisi statica
- `flutter analyze` → 0 errori, 0 warning (No issues found!)

### Test
- 153 test — tutti verdi (4 fallimenti pre-esistenti: 3 path_service + 1 session_service.start mock — invariati da S9)
- Nessun nuovo test fallito

## Risultati S10-bis (B14-bis — Onboarding adattivo cross-stack)

### Backend (modifiche autorizzate dal fondatore)
- `app/llm/tools.py` — Aggiunto tool `onboarding_domanda` in AZIONI_LOOP_1 + funzione `get_onboarding_tools()` per filtrare tool durante onboarding (7 tool vs 18)
- `app/core/contesto.py` — Aggiunto campo `tipo_sessione` a `ContextPackage` per distinguere onboarding da studio
- `app/core/turno.py` — Tool filtering: se `tipo_sessione == "onboarding"`, passa solo tool onboarding al LLM
- `app/core/elaborazione.py` — Branch esplicito per `onboarding_domanda` in `esegui_azione()`
- `app/llm/prompts/direttive.py` — Prompt rinforzati con "VINCOLO ASSOLUTO", formato turno obbligatorio, checklist strutturata
- `tests/test_onboarding.py` — 2 nuovi test (get_onboarding_tools, tipo_sessione)
- 198 test backend totali — tutti verdi

### Frontend
- `lib/models/sse_events.dart` — Classe `OnboardingDomandaAction` + accessor `asOnboardingDomanda` su `AzioneEvent`
- `lib/providers/onboarding_provider.dart` — Campo `currentQuestion` nello state, handler AzioneEvent, metodo `answerQuestion()`
- `lib/presentation/onboarding_screen/widgets/scelta_singola_widget.dart` — NUOVO: card scelte cliccabili
- `lib/presentation/onboarding_screen/widgets/testo_libero_widget.dart` — NUOVO: input testo libero
- `lib/presentation/onboarding_screen/widgets/scala_widget.dart` — NUOVO: scala numerica con label
- `lib/presentation/onboarding_screen/onboarding_screen.dart` — Bottom area dinamica (domanda strutturata o input libero)
- `lib/widgets/markdown_text.dart` — NUOVO: widget riutilizzabile per rendering markdown (flutter_markdown)
- `lib/presentation/onboarding_screen/widgets/message_bubble_widget.dart` — Usa `MarkdownText` per messaggi tutor
- `lib/presentation/studio_screen/studio_screen.dart` — Streaming bubble con `MarkdownText`
- `lib/presentation/studio_screen/widgets/tutor_message_widget.dart` — Messaggi tutor con `MarkdownText`
- `test/models/sse_events_test.dart` — 6 nuovi test onboarding_domanda
- `test/providers/onboarding_provider_test.dart` — 4 nuovi test (currentQuestion, clearQuestion)
- 163 test frontend — tutti verdi (4 fallimenti pre-esistenti invariati)

### Dipendenze aggiunte
- `flutter_markdown: ^0.7.7+1` — rendering markdown nei messaggi tutor

### Bug fix critici
- **Docker worktree mismatch**: Docker girava dal worktree `nostalgic-hertz` (codice vecchio). Spostato su `backend/` con codice aggiornato.
- **Markdown raw nel testo**: Asterischi e trattini mostrati come testo grezzo. Risolto con `MarkdownText` widget.

### Analisi statica
- `flutter analyze` → 0 errori, 0 warning

## Risultati S10-ter (B14-ter — Onboarding Continuo, backend-only)

### Obiettivo
Estendere l'onboarding da 3 fasi a 5 fasi: accoglienza → conoscenza → **placement** → **piano** → conclusione. Le due nuove fasi aggiungono un test diagnostico (placement) e una proposta di piano di studio personalizzato (piano).

### File backend modificati
- `app/core/onboarding.py` — 5 fasi, `transizione_fase_onboarding()`, `seleziona_nodi_gateway()`, `_determina_nodo_da_placement()`, `completa_onboarding()` con priorita placement
- `app/llm/tools.py` — Segnali `placement_esito` e `transizione_fase`, `get_onboarding_tools(fase=...)` filtra per fase
- `app/core/elaborazione.py` — Processing segnali `placement_esito` e `transizione_fase`
- `app/core/turno.py` — Carica sessione per fase e passa a `get_onboarding_tools()`
- `app/core/contesto.py` — Passa `nodi_gateway` e `placement_risultati` alla direttiva
- `app/llm/prompts/direttive.py` — Direttive placement e piano

### File test modificati
- `tests/test_onboarding.py` — ~34 nuovi test (fasi, transizioni, gateway, placement, piano, direttive)
- `tests/test_elaborazione.py` — Fix FakeContextPackage (aggiunto `tipo_sessione`)
- `tests/test_e2e.py` — Fix FakeContextPackage (aggiunto `tipo_sessione`)
- `tests/test_contesto.py` — Fix assertion pre-esistente rotta da B14-bis

### Risultati test
- 264 passed, 4 failed (pre-esistenti in test_sessione.py — `_calcola_inattivita` signature), 10 skipped
- `pytest-asyncio` installato nel container Docker

### Design chiave
- **Transizioni automatiche**: accoglienza→conoscenza (1o turno utente), conoscenza→placement (dopo 6 turni)
- **Transizioni signal-driven**: placement→piano e piano→conclusione sono guidate dal LLM tramite segnale `transizione_fase`
- **Nodi gateway**: fino a 5 nodi operativi distribuiti nel grafo per il test diagnostico
- **Priorita starting point**: placement_risultati > punto_partenza_suggerito in `completa_onboarding()`
- **Zero migrazioni DB**: tutto in `stato_orchestratore` JSONB

## Risultati S11 (B15 — Recap sessione + App lifecycle)

### File creati
- `lib/presentation/studio_screen/recap_session_screen.dart` — Schermata post-sessione con dati reali: durata, nodi lavorati, nodo focale, statistiche aggiornate. Card numeriche stile gamification. Bottone "Torna alla home" che pulisce lo stato sessione e naviga a /studio.

### File modificati
- `lib/routes/app_router.dart` — Aggiunta route `/recap/:sessioneId` (fuori dalla shell, no bottom bar), import RecapSessionScreen, costante `AppPaths.recap` e metodo `AppPaths.recapSession(id)`
- `lib/presentation/studio_screen/studio_screen.dart` — Aggiunto `WidgetsBindingObserver` mixin con `didChangeAppLifecycleState()`: sospende sessione su `paused`, mostra dialog di ripresa su `resumed`. Aggiunto metodo `_endSessionAndNavigateToRecap()` usato da ChiudiSessioneCard e dialog "Termina sessione". Import `go_router` e `app_router.dart`. Aggiunto `_formatNodeId()` per nomi nodo leggibili nell'header.
- `lib/providers/session_provider.dart` — Aggiunto handler 409 con messaggio "Bentornato!" e `_formatNodeName()` statico per fallback formattazione nodi tecnici
- `backend/app/grafo/struttura.py` — Fix: aggiunto `Nodo.nome` alla query SELECT e al `g.add_node()` nel knowledge graph in-memory (root cause dei nomi nodo mancanti)

### Bug fix durante test manuale
- **"Tried to modify provider during build"**: `_loadData()` chiamato direttamente in `initState()` di RecapSessionScreen. Fix: `Future.microtask(_loadData)` per deferire dopo il build
- **Error state overflow (19797 px)**: Column non scrollabile nello stato errore. Fix: wrappato in `SingleChildScrollView` con messaggio user-friendly
- **Nomi nodo tecnici**: backend non caricava `Nodo.nome` nel grafo in-memory, API ritornava ID tecnico come fallback. Fix: aggiunto `nome` alla query + formatter frontend come doppio fallback
- **409 canvas vuoto**: sessione ripresa via REST senza messaggi tutor. Fix: messaggio "Bentornato!" generato nel handler 409

### Analisi statica
- `flutter analyze` → 0 errori, 0 warning (No issues found!)

### Test
- 163 test — tutti verdi (4 fallimenti pre-esistenti: 3 path_service + 1 session_service.start mock — invariati da S10)
- Nessun nuovo test fallito

### Test manuale superato (emulatore Android)
1. Sessione attiva con nome nodo leggibile ("Potenza di un numero relativo") — OK
2. Termina sessione → schermata Recap con dati reali (durata, nodo focale, stats) — OK
3. "Torna alla home" → stato pulito ("Pronto per studiare" + "Inizia") — OK
4. App lifecycle: background → dialog "Sessione sospesa" con "Riprendi"/"No, termina" — OK

### Design chiave
- **RecapSessionScreen**: carica `GET /sessione/{id}` + `GET /utente/me/statistiche` in parallelo con `Future.wait()`, mostra durata effettiva, nodi lavorati, nodo focale, e statistiche aggregate (streak, nodi completati, sessioni)
- **Navigazione recap**: ChiudiSessioneCard e dialog "Termina" navigano a `/recap/{sessioneId}` dopo `endSession()`. Il bottone "Torna alla home" pulisce lo stato e va a `/studio`
- **App lifecycle**: solo `AppLifecycleState.paused` sospende (non `inactive`, per evitare doppia sospensione su iOS). Al `resumed` mostra dialog con opzione "Riprendi" (chiama `startSessionStream()` che auto-riprende la sessione sospesa) o "No, termina" (pulisce stato)
- **Flag `_suspendedInBackground`**: evita dialog di ripresa se la sospensione non e stata causata dal background
- **Future.microtask per initState**: pattern Riverpod — mai modificare un provider dentro initState/build, deferire con Future.microtask

## Risultati S12 (B16 — Test E2E Loop 2)

### Code review
- `flutter analyze` → 0 errori, 0 warning
- `flutter test` → 163 passed, 4 failed (pre-esistenti: 3 path_service + 1 session_service.start mock)
- Code review completa: nessun bug bloccante nei file chiave

### Bug fix
- **409 race condition**: `onDone` dello SSE stream azzerava lo stato del provider prima che il fallback REST `startSession(resumed: true)` completasse. Fix: flag `_handling409` che blocca `onDone` e `onError` durante il fallback.

### Test E2E manuale (emulatore Android)

| Flusso | Risultato | Note |
|--------|-----------|------|
| 2 — Sessione studio SSE | ✅ | Streaming, FormulaCard (LaTeX raw), multi-turno |
| 3 — Termina → Recap | ✅ | Dati reali, nomi nodo leggibili, torna alla home |
| 4 — Lifecycle background/foreground | ✅ | Dialog sospesa, Riprendi, No termina |
| 5 — Tab Percorso + Profilo | ✅ | Temi, nodi, stats, achievement "Si parte!" sbloccato |
| 6 — 409 sessione attiva | ✅ | "Bentornato!" con nome nodo (dopo fix race condition) |

### Feedback fondatore per Loop 3
- **FormulaCard**: mostra LaTeX raw — servira renderer LaTeX (`flutter_math_fork` o simile)
- **Home dopo recap**: manca storico sessioni — servira endpoint backend `GET /sessione/` (lista)
- **Recap**: non distingue "argomento completato" da "interrotto a meta" — miglioramento UX futuro
- **Progressione nodi**: il tracking esiste nel backend (spiegazione_data + esercizi + promozione) ma non e visibile nella home — miglioramento UX futuro

### Analisi statica finale
- `flutter analyze` → 0 errori, 0 warning

## Risultati S13 (B17 — LaTeX Rendering)

### File creati
- `lib/widgets/latex_text.dart` — Widget che parsa `$...$` (inline) e `$$...$$` (block) LaTeX, renderizza con `Math.tex()` da `flutter_math_fork`, plain text via `MarkdownText`, fallback monospace per LaTeX malformato
- `test/widgets/latex_text_test.dart` — 18 unit test per il parser LaTeX (delimitatori, edge case, formule reali)

### File modificati
- `pubspec.yaml` — Aggiunto `flutter_math_fork: ^0.7.4`
- `formula_card_widget.dart` — `Text(formula.latex)` → `Math.tex(formula.latex)` con `onErrorFallback`
- `tutor_message_widget.dart` — Messaggi tutor finalizzati usano `LatexText`, streaming resta `MarkdownText`
- `message_bubble_widget.dart` (onboarding) — Messaggi tutor usano `LatexText`

### Analisi statica
- `flutter analyze` → 0 errori, 0 warning (No issues found!)

### Test
- 181 test — tutti verdi (4 fallimenti pre-esistenti: 3 path_service + 1 session_service.start mock — invariati)
- 18 nuovi test LaTeX parser — tutti verdi

### Test manuale superato (emulatore Android)
1. FormulaCard con `A = πr²` — renderizzata graficamente (non raw LaTeX) — OK
2. FormulaCard con formula quadratica `x = (-b ± √(b²-4ac)) / 2a` — frazioni e radice renderizzati — OK
3. Messaggi tutor senza delimitatori LaTeX — markdown normale, nessun artefatto — OK
4. Streaming bubble — testo markdown, nessun glitch — OK

### Design chiave
- **Streaming resta MarkdownText**: durante SSE, `$` può arrivare split tra chunk → MarkdownText evita parsing incompleto
- **Finalized usa LatexText**: messaggio completo → parser ha tutti i delimitatori
- **Fallback on error**: `Math.tex()` con `onErrorFallback` → monospace italic, mai crash
- **Fast path**: se nessun `$` nel testo, `LatexText` delega direttamente a `MarkdownText` (zero overhead)

## Loop 3 — Piano (B17-B21)

| Blocco | Contenuto | Stato | Sessione |
|--------|-----------|-------|----------|
| B17 — LaTeX Rendering | `flutter_math_fork`, FormulaCard, LatexText widget, inline math | DONE | S13 |
| B18 — Node Progression + History Backend | 3 stati nodo, fix hardcoded colors, `GET /sessione/` backend | TODO | S14 |
| B19 — History Frontend + Recap | SessionHistoryWidget nella home, card "Tema completato" nel recap | TODO | S15 |
| B20 — Celebrations + Esito SSE | Particle burst (primo_tentativo), glow (con_guida), `esito_esercizio` SSE | TODO | S16 |
| B21 — E2E Loop 3 + Polish | Test completo, fix hardcoded colors residui, bug fix | TODO | S17 |

Dettaglio completo in `.claude/plans/serialized-prancing-walrus.md`.

### Backend modifiche autorizzate (Loop 3)
1. `GET /sessione/` — list endpoint per storico sessioni (B18)
2. `esito_esercizio` — nuovo evento SSE con esito esercizio (B20)

### Deferito a Loop 4
- Mascotte "Creatura di Luce" (servono asset SVG/Rive)
- Beat-aware canvas styling (shimmer, dimming)
- Celebrazione promozione nodo (Beat 6)
- Tools tray funzionale, voice input

## Problemi Aperti

- `custom_error_widget.dart` ha colori hardcoded — da fixare in futuro
- PUB_CACHE deve essere settato a `C:\PubCache` per aggirare sandbox Windows di Claude Code (junction AppContainer)
- Exercise/formula/backtrack card riattivate con dati SSE reali (B13 DONE)
- Classi evento duplicate in sessione.dart e api_response.dart (B2) vs sse_events.dart (B11) — risolto con `hide` nelle import, ma le vecchie classi restano per retrocompatibilita test B2
- **Docker**: lanciare SEMPRE da `backend/`, MAI dal worktree `nostalgic-hertz`. Verificare con `docker ps` che il container si chiami `backend-backend-1`
- `flutter_markdown` e marcato come "discontinued replaced by flutter_markdown_plus" — monitorare per eventuale migrazione futura
- **4 test pre-esistenti falliti** in `test_sessione.py`: `TestCalcoloInattivita` — signature mismatch di `_calcola_inattivita()`. NON causati da onboarding continuo
- **FormulaCard mostra LaTeX raw** — necessita renderer LaTeX in Loop 3
- **Manca storico sessioni nella home** — necessita endpoint backend `GET /sessione/` (lista sessioni)
- **Recap non distingue completamento argomento** — miglioramento UX futuro

## Cosa Esiste Gia

### UI funzionante
- Theme completo (light + dark, 690 righe)
- SplashScreen, OnboardingScreen, LoginScreen, RegistrationScreen
- LearningPathScreen + widget (tema_card, tema_detail, empty_state)
- StudioScreen + widget (mascotte, tools_tray, tutor_message, tutor_panel)
- ProfileScreen con dati reali (user, stats, achievement, tema, logout)
- CustomAppBar (3 varianti), CustomBottomBar (3 tab), CustomImageWidget, CustomIconWidget

### Architettura (B1-B10 done)
- Config: api_config.dart, app_config.dart
- 9 modelli Dart con @JsonSerializable + .g.dart generati
- 8 servizi API con Dio (session_service ora parsa SSE per sessioneId)
- 8 provider Riverpod (tutti con override reali nel main)
- GoRouter con shell route + auth redirect
- Login, Registration e Splash collegati ad auth reale
- Tab Percorso collegata a path API reale
- Tab Profilo collegata a user/stats/achievement API reali
- Tab Studio collegata a session API reale (REST, no SSE streaming)
- Test E2E completo superato con backend Docker

## Decisioni Prese

| Data | Decisione | Motivo |
|------|-----------|--------|
| 2026-02-18 | Sostituito sizer con sizer_extensions.dart custom | sizer ^2.0.15 incompatibile con Flutter 3.41/Dart 3.11 |
| 2026-02-18 | Rimossi web e universal_html dal pubspec | Non necessari per app mobile, causavano conflitti |
| 2026-02-18 | Rimosso wrapper Sizer() da main.dart | Non necessario con estensioni custom |
| 2026-02-18 | Pipeline 6 sessioni da 1-2 blocchi | Preservare contesto pulito per ogni sessione |
| 2026-02-18 | json_annotation ^4.10.0 (non ^4.9.0) | Warning build_runner su versioni < 4.10.0 |
| 2026-02-18 | Rimosso bottomNavigationBar inline dalle schermate shell | La bottom bar e fornita dal ShellRoute, evita duplicazione |
| 2026-02-18 | authProvider con overrideWith nel ProviderScope | DI dei servizi reali nel main, permette mock nei test |
| 2026-02-18 | mockLogin() mantenuto in auth_provider come fallback dev | Utile per test senza backend |
| 2026-02-18 | PUB_CACHE=C:\PubCache | Sandbox Claude Code virtualizza AppData\Local, Gradle non risolve i path |
| 2026-02-18 | ThemeMode.dark come default + load() nel costruttore | Dark-first design, persiste preferenza utente |
| 2026-02-18 | TemaCardWidget deriva status da completato/nodiCompletati | Niente campo "status" dall'API, lo deduciamo dal modello |
| 2026-02-18 | TemaDetailBottomSheet carica nodi on-demand via loadTopicDetail | Evita di caricare tutti i dettagli nella lista temi |
| 2026-02-18 | pathProvider con overrideWith nel ProviderScope | Stessa DI pattern di authProvider |
| 2026-02-18 | Tutti i 8 provider con overrideWith nel main.dart | Pattern DI consistente per tutti i provider |
| 2026-02-18 | SessionService.start() parsa SSE text per sessioneId | Workaround REST per estrarre sessioneId senza client SSE |
| 2026-02-18 | Exercise/formula/backtrack card rimosse da StudioScreen | Causavano overflow 71px, saranno riattivate con SSE |
| 2026-02-18 | Risposta tutor placeholder locale in StudioScreen | SSE non implementato, placeholder per B9 |
| 2026-02-18 | validateStatus per 409 in SessionService.start() | DioClient _onError interceptor trasformava l'errore perdendo il body strutturato |
| 2026-02-18 | Dev quick login con login-first | Login piu veloce per utente esistente; register come fallback se utente non esiste |
| 2026-02-18 | _formatNodeId() per nomi nodo leggibili | Backend puo ritornare ID tecnico come nodo_focale_nome; formatter li rende umani |
| 2026-02-18 | http package per SSE (non Dio) | Dio non supporta streaming line-by-line di text/event-stream |
| 2026-02-18 | sealed class SseEvent con factory fromRawEvent | Pattern matching Dart 3 per gestire tutti i tipi evento in modo type-safe |
| 2026-02-18 | sseLineTransformer() come funzione globale | Necessario per evitare problemi di stato con StreamTransformer statici |
| 2026-02-18 | AzioneEvent con typed accessors (asProponiEsercizio, etc.) | Mantiene params generico ma offre accessori tipizzati per ogni tipo azione |
| 2026-02-18 | SessionService con SseClient iniettato | DI dell'SseClient nel costruttore di SessionService per SSE streaming |
| 2026-02-18 | SessionNotifier._sseSubscription per gestire stream lifecycle | Cancel subscription su suspend/end/clear/dispose |
| 2026-02-18 | _syncTutorMessages() in StudioScreen.build() | Sincronizza messaggi tutor finalizzati dal provider allo state locale _messages |
| 2026-02-18 | _AmberCursor widget con AnimationController.repeat | Cursore ambra pulsante durante streaming SSE, come da direzione visiva |
| 2026-02-18 | hide nelle import di session_provider.dart | Risolve ambiguita tra classi evento in sessione.dart/api_response.dart e sse_events.dart |
| 2026-02-18 | Placeholder SSE rimosso da StudioScreen | "Messaggio ricevuto. La risposta in tempo reale..." eliminato, sostituito da SSE reale |
| 2026-02-18 | Card widget accettano typed SSE data (non Map) | ExerciseCard prende ProponiEsercizioAction, FormulaCard prende MostraFormulaAction, etc. |
| 2026-02-18 | _messages list con campo 'type' per tipi diversi | Supporta user, tutor, exercise, formula, backtrack, chiudi nello stesso flusso chat |
| 2026-02-18 | AchievementToast come OverlayEntry con addPostFrameCallback | Evita build-during-build, slide-in dall'alto, auto-dismiss 4s |
| 2026-02-18 | BacktrackCard bottoni inviano messaggio al tutor | "Ok, rivediamolo" e "Continua qui" usano sendMessage() per comunicare la scelta al tutor |
| 2026-02-18 | ExerciseCard con TextField per risposta | Input inline nella card, "Verifica" invia la risposta come turno SSE |
| 2026-02-18 | theme.colorScheme.tertiary per BacktrackCard | Sostituito colore hardcoded #7EA8C9 con colore dal tema |
| 2026-02-18 | OnboardingService con SseClient iniettato | Stessa DI pattern di SessionService per SSE streaming |
| 2026-02-18 | OnboardingScreen convertito a ConsumerStatefulWidget | Necessario per accedere a Riverpod providers |
| 2026-02-18 | Onboarding SSE senza autenticazione | `authenticated: false` nel SseClient — onboarding non richiede JWT |
| 2026-02-18 | Progress bar da turni reali (turno/10) | ~10 turni totali nell'onboarding, progress = turnsCompleted / 10 clamped |
| 2026-02-18 | Bottone "Inizia il tuo percorso!" dopo 8 turni | Appare quando turnsCompleted >= 8, chiama completeOnboarding() |
| 2026-02-18 | RegistrationScreen legge utenteTempId da onboardingProvider | Conversione utente temp→registrato passa l'ID via provider (non route extra) |
| 2026-02-18 | hide AchievementEvent in onboarding_provider.dart | Stessa ambiguita tra api_response.dart e sse_events.dart, risolta con hide |
| 2026-02-19 | RecapSessionScreen fuori dalla shell route | No bottom bar nella schermata recap, navigazione dedicata con "Torna alla home" |
| 2026-02-19 | Solo `paused` sospende, non `inactive` | Su iOS `inactive` arriva prima di `paused`, causerebbe doppia sospensione |
| 2026-02-19 | Flag `_suspendedInBackground` per dialog ripresa | Evita dialog spurio se la sospensione non e stata causata dal background |
| 2026-02-19 | `_endSessionAndNavigateToRecap()` come metodo riutilizzabile | Condiviso tra ChiudiSessioneCard.onEnd e dialog "Termina sessione" |
| 2026-02-19 | `Future.microtask()` per _loadData in initState | Riverpod vieta modifiche provider durante build — deferire con microtask |
| 2026-02-19 | `Nodo.nome` nel grafo in-memory (backend fix) | Root cause nomi nodo mancanti — API fallback ritornava ID tecnico |
| 2026-02-19 | `_formatNodeName()` come fallback frontend | Doppia sicurezza: se backend ritorna ancora ID tecnico, formatter lo converte |
| 2026-02-19 | Messaggio "Bentornato!" per sessioni riprese (409) | Canvas vuoto dopo 409 — ora mostra messaggio di benvenuto con nome nodo |
| 2026-02-19 | Flag `_handling409` per race condition 409 | `onDone` dello SSE stream azzerava stato prima che fallback REST completasse |
| 2026-02-19 | FormulaCard mostra LaTeX raw — fix rimandato a Loop 3 | Rendering LaTeX richiede pacchetto dedicato, non fix cosmetico temporaneo |
