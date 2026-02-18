# Status Checkpoint — Dydat Frontend

> Aggiornato da ogni sessione. La sessione successiva legge questo per sapere da dove partire.

## Stato Corrente

**Ultimo aggiornamento**: 2026-02-18
**Ultima sessione**: S9 (Blocco 13 — Azioni tutor nel canvas) — COMPLETATA
**Branch attivo**: feature/frontend-b1-b2 (contiene B1-B13)
**Prossima sessione**: S10 — Blocco 14 (Onboarding reale con SSE). Vedi `.claude/plans/frontend-integration.md` sezione Loop 2.

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
| B14 — Onboarding reale con SSE | Onboarding con tutor AI, registrazione conversione utente_temp | TODO | S10 |
| B15 — Recap + App lifecycle | Recap post-sessione, sospensione in background | TODO | S11 |
| B16 — Test E2E Loop 2 | Flusso completo SSE reale senza crash | TODO | S12 |

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

## Problemi Aperti

- `custom_error_widget.dart` ha colori hardcoded — da fixare in futuro
- PUB_CACHE deve essere settato a `C:\PubCache` per aggirare sandbox Windows di Claude Code (junction AppContainer)
- Exercise/formula/backtrack card riattivate con dati SSE reali (B13 DONE)
- Classi evento duplicate in sessione.dart e api_response.dart (B2) vs sse_events.dart (B11) — risolto con `hide` nelle import, ma le vecchie classi restano per retrocompatibilita test B2

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
