# Status Checkpoint — Dydat Frontend

> Aggiornato da ogni sessione. La sessione successiva legge questo per sapere da dove partire.

## Stato Corrente

**Ultimo aggiornamento**: 2026-02-18
**Ultima sessione**: S4 (Blocchi 6+7 — Auth Screens + Tab Percorso) — COMPLETATA
**Branch attivo**: feature/frontend-b1-b2 (contiene B1-B7, non ancora committato)
**Prossima sessione**: S5 (Blocchi 8+9 — Tab Profilo + Tab Studio)

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
| B8 — Tab Profilo | TODO | S5 | |
| B9 — Tab Studio | TODO | S5 | |
| B10 — Test E2E | TODO | S6 | |

## Problemi Aperti

- `custom_error_widget.dart` ha colori hardcoded — da fixare in futuro
- StudioScreen ha overflow di 71px nel Column a riga 339 — fix in B9
- PUB_CACHE deve essere settato a `C:\PubCache` per aggirare sandbox Windows di Claude Code (junction AppContainer)

## Cosa e Stato Fatto in S4

### B6 — Schermate Auth (ricablate su auth_provider reale)
- **LoginScreen** (`login_screen.dart`):
  - Rimossi stato locale `_isLoading`, `_errorMessage`, mock credentials
  - Usa `ref.watch(authProvider)` per isLoading e error (reactive)
  - `_handleLogin()` chiama `ref.read(authProvider.notifier).login()` reale
  - GoRouter redirect gestisce la navigazione post-login automaticamente
  - HapticFeedback solo su successo
  - Rimosso box "Credenziali Demo" (non serve piu con auth reale)

- **RegistrationScreen** (`registration_screen.dart`):
  - Convertito da `StatefulWidget` a `ConsumerStatefulWidget`
  - Rimossi stato locale `_isLoading`, `_errorMessage`, logica mock
  - Usa `ref.watch(authProvider)` per isLoading e error
  - `_handleRegistration()` chiama `ref.read(authProvider.notifier).register()` reale
  - GoRouter redirect gestisce la navigazione post-registrazione

- **SplashScreen** (`splash_screen.dart`):
  - Convertito da `StatefulWidget` a `ConsumerStatefulWidget`
  - `_checkAuthentication()` ora chiama `ref.read(authProvider.notifier).checkAuth()` reale
  - Verifica JWT salvato contro backend → se valido: go('/studio'), se no: go('/login')
  - Timeout aumentato a 8s (checkAuth puo essere lento)
  - Rimossi mock `_loadThemePreferences()` e `_prepareCachedData()`
  - Gestione errori: se checkAuth fallisce (non 401), naviga comunque al login

### B7 — Tab Percorso (dati reali da API)
- **LearningPathScreen** (`learning_path_screen.dart`):
  - Convertito da `StatefulWidget` a `ConsumerStatefulWidget`
  - Rimossi tutti i dati mock hardcodati (6 temi finti)
  - Usa `ref.watch(pathProvider)` per topics, isLoading, error
  - `initState()` chiama `loadTopics()` al primo build
  - Pull-to-refresh chiama `loadTopics()` da API
  - Stato loading con CircularProgressIndicator
  - Stato errore con bottone Riprova
  - Stato empty con EmptyStateWidget
  - Progresso calcolato da nodi reali (nodiCompletati/nodiTotali)
  - Tema "corrente" = primo tema non completato con nodiCompletati > 0

- **TemaCardWidget** (`tema_card_widget.dart`):
  - Accetta `Tema` model (non piu `Map<String, dynamic>`)
  - Status derivato: completato → completed, nodiCompletati>0 → current, else → future
  - Progresso: nodiCompletati/nodiTotali
  - Mostra "X/Y nodi" al posto di "Progresso"

- **TemaDetailBottomSheet** (`tema_detail_bottom_sheet.dart`):
  - Convertito a `ConsumerStatefulWidget`
  - Accetta `Tema` model (non piu `Map<String, dynamic>`)
  - `initState()` chiama `loadTopicDetail(temaId)` per caricare la lista nodi
  - Nodi mostrati da `TemaDettaglio.nodi` (dati API)
  - Stato nodo: livello operativo/comprensivo/connesso = completato
  - Stato loading e errore gestiti inline

- **main.dart**:
  - Aggiunto `PathService` e override di `pathProvider` nel `ProviderScope`

### Analisi statica
- `flutter analyze` → 0 errori, 0 warning

## Cosa Esiste Gia

### UI funzionante (da Rocket.new)
- Theme completo (light + dark, 690 righe)
- SplashScreen, OnboardingScreen, LoginScreen, RegistrationScreen
- LearningPathScreen + widget (tema_card, tema_detail, empty_state)
- StudioScreen + widget (exercise, formula, backtrack, mascotte, tools_tray, tutor_message, tutor_panel)
- CustomAppBar (3 varianti), CustomBottomBar (3 tab), CustomImageWidget, CustomIconWidget

### Architettura (B1-B7 done)
- Config: api_config.dart, app_config.dart
- 9 modelli Dart con @JsonSerializable + .g.dart generati
- 8 servizi API con Dio
- 8 provider Riverpod (auth e path con override reali nel main)
- GoRouter con shell route + auth redirect
- Login, Registration e Splash collegati ad auth reale
- Tab Percorso collegata a path API reale

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
