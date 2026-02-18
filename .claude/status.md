# Status Checkpoint — Dydat Frontend

> Aggiornato da ogni sessione. La sessione successiva legge questo per sapere da dove partire.

## Stato Corrente

**Ultimo aggiornamento**: 2026-02-18
**Ultima sessione**: S6 (Blocco 10 — Test E2E con backend reale) — COMPLETATA
**Branch attivo**: feature/frontend-b1-b2 (contiene B1-B10)
**Prossima sessione**: S7 — Blocco 11 (SSE Client + Modelli eventi). Vedi `.claude/plans/frontend-integration.md` sezione Loop 2.

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
| B11 — SSE Client + Modelli eventi | `sse_client.dart`, `sse_events.dart`, parsing tutti i tipi evento | TODO | S7 |
| B12 — Studio con SSE reale | Testo tutor in streaming, rimuovere placeholder | TODO | S8 |
| B13 — Azioni tutor nel canvas | Exercise/formula/backtrack card con dati SSE, achievement toast | TODO | S9 |
| B14 — Onboarding reale con SSE | Onboarding con tutor AI, registrazione conversione utente_temp | TODO | S10 |
| B15 — Recap + App lifecycle | Recap post-sessione, sospensione in background | TODO | S11 |
| B16 — Test E2E Loop 2 | Flusso completo SSE reale senza crash | TODO | S12 |

Dettaglio completo in `.claude/plans/frontend-integration.md`.

## Problemi Aperti

- `custom_error_widget.dart` ha colori hardcoded — da fixare in futuro
- PUB_CACHE deve essere settato a `C:\PubCache` per aggirare sandbox Windows di Claude Code (junction AppContainer)
- Exercise/formula/backtrack card rimosse dallo StudioScreen — saranno riattivate con SSE (Loop 2)
- Risposta tutor e placeholder locale — SSE streaming da implementare in Loop 2

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
