# Status Checkpoint — Dydat Frontend

> Aggiornato da ogni sessione. La sessione successiva legge questo per sapere da dove partire.

## Stato Corrente

**Ultimo aggiornamento**: 2026-02-18
**Ultima sessione**: S2 (Blocchi 3+4 — Servizi API + Provider Riverpod)
**Branch attivo**: feature/frontend-b1-b2
**Prossima sessione**: S3 (Blocco 5 — GoRouter + Shell App)

## Blocchi Completati

| Blocco | Stato | Sessione | Note |
|--------|-------|----------|------|
| B0 — Setup monorepo | DONE | S0 | Monorepo creato, sizer sostituito con sizer_extensions.dart |
| B1 — Dipendenze + Config | DONE | S1 | flutter_riverpod, go_router, flutter_secure_storage, json_annotation + config files |
| B2 — Modelli dati | DONE | S1 | 9 file modelli + 9 .g.dart generati + 37 unit test tutti verdi |
| B3 — Servizi API | DONE | S2 | 8 file servizi + 32 unit test tutti verdi |
| B4 — Provider Riverpod | DONE | S2 | 8 file provider + 55 unit test tutti verdi |
| B5 — GoRouter + Shell | TODO | S3 | |
| B6 — Schermate Auth | TODO | S4 | |
| B7 — Tab Percorso | TODO | S4 | |
| B8 — Tab Profilo | TODO | S5 | |
| B9 — Tab Studio | TODO | S5 | |
| B10 — Test E2E | TODO | S6 | |

## Problemi Aperti

- `flutter analyze` ha 6 warning pre-esistenti (variabili non usate, dead code in UI Rocket.new) — non bloccanti
- `custom_error_widget.dart` ha colori hardcoded — da fixare in futuro
- Profilo screen non esiste ancora (referenziato in routing ma non implementato)

## Cosa e Stato Fatto in S2

### B3 — Servizi API (8 file)
- `storage_service.dart` — Wrapper flutter_secure_storage (saveToken, getToken, deleteToken, utenteTempId)
- `dio_client.dart` — Singleton Dio con interceptor JWT (aggiunge Authorization header, trasforma errori in ApiException)
- `auth_service.dart` — login(), register() con utenteTempId opzionale
- `user_service.dart` — getMe(), updatePreferences(), getStats()
- `onboarding_service.dart` — start(), sendTurn(), complete()
- `session_service.dart` — start(), sendTurn(), suspend(), end(), get()
- `path_service.dart` — getPaths(), getMap(), getTopics(), getTopicDetail()
- `achievement_service.dart` — getAll()

### B4 — Provider Riverpod (8 file)
- `auth_provider.dart` — AuthState (token, user, isAuthenticated) + AuthNotifier (checkAuth, login, register, logout)
- `user_provider.dart` — UserState (profile, isLoading, error) + UserNotifier (loadProfile, updatePreferences)
- `onboarding_provider.dart` — OnboardingScreenState (sessioneId, messages, isCompleted) + OnboardingNotifier
- `session_provider.dart` — SessionScreenState (activeSession, tutorMessages) + SessionNotifier (sendTurn, suspend, end, load)
- `path_provider.dart` — PathState (paths, currentMap, topics) + PathNotifier (loadPaths, loadMap, loadTopics, refresh)
- `achievement_provider.dart` — AchievementState (unlocked, next) + AchievementNotifier (load, clear)
- `stats_provider.dart` — StatsState (stats) + StatsNotifier (load, clear)
- `theme_provider.dart` — ThemeNotifier (load, setThemeMode, toggle) con persistenza SharedPreferences

### Test
- 124 unit test totali — tutti verdi
  - 37 test modelli (B2, gia presenti)
  - 32 test servizi (B3, nuovi)
  - 55 test provider (B4, nuovi)
- Helper condiviso: `test/helpers/fake_secure_storage.dart`
- Mock HTTP: http_mock_adapter ^0.6.1

### Dipendenze aggiunte (dev)
- `http_mock_adapter: ^0.6.1` — mock Dio per test servizi
- `mockito: ^5.4.4` — mock framework (disponibile per usi futuri)

## Cosa Esiste Gia

### UI funzionante (da Rocket.new)
- Theme completo (light + dark, 690 righe)
- SplashScreen, OnboardingScreen, LoginScreen, RegistrationScreen
- LearningPathScreen + widget (tema_card, tema_detail, empty_state)
- StudioScreen + widget (exercise, formula, backtrack, mascotte, tools_tray, tutor_message, tutor_panel)
- CustomAppBar (3 varianti), CustomBottomBar (3 tab), CustomImageWidget, CustomIconWidget

### Architettura (B1-B4 done)
- Config: api_config.dart, app_config.dart
- 9 modelli Dart con @JsonSerializable + .g.dart generati
- 8 servizi API con Dio + interceptor JWT
- 8 provider Riverpod con StateNotifier + state immutabile
- Zero GoRouter (B5)

## Decisioni Prese

| Data | Decisione | Motivo |
|------|-----------|--------|
| 2026-02-18 | Sostituito sizer con sizer_extensions.dart custom | sizer ^2.0.15 incompatibile con Flutter 3.41/Dart 3.11 |
| 2026-02-18 | Rimossi web e universal_html dal pubspec | Non necessari per app mobile, causavano conflitti |
| 2026-02-18 | Rimosso wrapper Sizer() da main.dart | Non necessario con estensioni custom |
| 2026-02-18 | Pipeline 6 sessioni da 1-2 blocchi | Preservare contesto pulito per ogni sessione |
| 2026-02-18 | json_annotation ^4.10.0 (non ^4.9.0) | Warning build_runner su versioni < 4.10.0 |
| 2026-02-18 | Provider con throw UnimplementedError di default | Saranno overridden con dependencies reali in B5 (main.dart con ProviderScope) |
| 2026-02-18 | FakeSecureStorage in test/helpers/ condiviso | Evita duplicazione del boilerplate nei test |
| 2026-02-18 | SSE endpoints come REST placeholder nei servizi | SSE streaming implementato in loop futuro, ora solo POST call |
