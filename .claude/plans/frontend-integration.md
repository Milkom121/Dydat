# Piano Frontend Integration — Dydat

> Fonte di verita operativa. Ogni sessione legge questo file per sapere COSA fare e COME.

## Architettura Target

```
frontend/lib/
├── main.dart                          # Entry point + ProviderScope + ScreenUtilInit
├── config/
│   ├── api_config.dart                # Base URL, timeouts, endpoints
│   └── app_config.dart                # Feature flags, version, environment
├── core/
│   ├── app_export.dart                # Barrel exports
│   └── sizer_extensions.dart          # .w .h .sp responsive (gia fatto)
├── models/                            # Dart data classes con fromJson/toJson
│   ├── utente.dart                    # Utente, PreferenzeStudio
│   ├── sessione.dart                  # Sessione, Turno, MessaggioChat
│   ├── percorso.dart                  # Percorso
│   ├── nodo.dart                      # Nodo, StatoNodoUtente
│   ├── tema.dart                      # Tema (raggruppamento nodi)
│   ├── achievement.dart               # Achievement, AchievementUtente
│   ├── statistiche.dart               # StatisticheGiornaliere, StoricoEsercizi
│   ├── onboarding.dart                # OnboardingMessage, OnboardingState
│   └── api_response.dart              # Wrapper errori API, PaginatedResponse
├── services/                          # HTTP layer puro (Dio)
│   ├── dio_client.dart                # Dio instance + interceptor JWT + refresh
│   ├── auth_service.dart              # login, register, refresh, logout
│   ├── user_service.dart              # profilo, preferenze, statistiche
│   ├── onboarding_service.dart        # POST messaggi, GET stato
│   ├── session_service.dart           # CRUD sessioni, turni
│   ├── path_service.dart              # percorsi, temi, nodi, stati
│   ├── achievement_service.dart       # lista achievement, claim
│   └── storage_service.dart           # flutter_secure_storage wrapper (JWT)
├── providers/                         # Riverpod providers
│   ├── auth_provider.dart             # AuthState (token, user, isLogged)
│   ├── user_provider.dart             # UserState (profilo, preferenze)
│   ├── onboarding_provider.dart       # OnboardingState (messages, progress, stage)
│   ├── session_provider.dart          # SessionState (sessione attiva, messaggi, timer)
│   ├── path_provider.dart             # PathState (percorsi, temi, nodi, progresso)
│   ├── achievement_provider.dart      # AchievementState (lista, non-letti)
│   ├── stats_provider.dart            # StatsState (giornaliere, storico)
│   └── theme_provider.dart            # ThemeMode (system/light/dark)
├── routes/
│   └── app_router.dart                # GoRouter con redirect auth-guard
├── theme/
│   └── app_theme.dart                 # GIA COMPLETO — non toccare
├── widgets/                           # GIA COMPLETI — non toccare
│   ├── custom_app_bar.dart
│   ├── custom_bottom_bar.dart
│   ├── custom_error_widget.dart
│   ├── custom_icon_widget.dart
│   └── custom_image_widget.dart
└── presentation/                      # Schermate — da RICABLARE su providers
    ├── splash_screen/
    ├── onboarding_screen/
    ├── login_screen/
    ├── registration_screen/
    ├── learning_path_screen/
    ├── studio_screen/
    └── profile_screen/                # NUOVO — da creare
```

---

## Pipeline Sessioni

| Sessione | Blocchi | Deliverable | Gate di uscita | Branch |
|----------|---------|-------------|----------------|--------|
| **S1** | B1 + B2 | Config + Modelli dati | `flutter analyze` 0 errori + unit test modelli | `feature/frontend-b1-b2` |
| **S2** | B3 + B4 | Servizi API + Provider Riverpod | `flutter analyze` 0 errori + unit test services/providers | `feature/frontend-b3-b4` |
| **S3** | B5 | GoRouter + shell app + ProviderScope | App parte, navigazione funziona, auth redirect ok | `feature/frontend-b5` |
| **S4** | B6 + B7 | Auth screens + Tab Percorso (dati reali) | Login/register funzionanti + percorso mostra dati API | `feature/frontend-b6-b7` |
| **S5** | B8 + B9 | Tab Profilo + Tab Studio (SSE placeholder) | Tutte le tab mostrano dati reali | `feature/frontend-b8-b9` |
| **S6** | B10 | Test E2E con backend reale | Flusso completo: register → onboarding → studio → percorso | `feature/frontend-e2e` |

**Regola**: ogni sessione inizia su branch pulito da main, PR a fine sessione.

---

## Blocchi Dettagliati

### Blocco 1 — Dipendenze + Config
**File da creare**: `lib/config/api_config.dart`, `lib/config/app_config.dart`
**File da modificare**: `pubspec.yaml`

**pubspec.yaml — aggiungere**:
```yaml
flutter_riverpod: ^2.6.1
go_router: ^14.8.1
flutter_secure_storage: ^9.2.4
json_annotation: ^4.9.0
```

**dev_dependencies — aggiungere**:
```yaml
build_runner: ^2.4.14
json_serializable: ^6.9.4
```

**api_config.dart**:
```dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000';  // Android emulator
  static const String baseUrlIos = 'http://localhost:8000';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Endpoints (da docs/dydat_api_reference.md)
  static const String health = '/health';
  static const String register = '/auth/registrazione';
  static const String login = '/auth/login';
  static const String me = '/utente/me';
  static const String preferences = '/utente/me/preferenze';
  static const String stats = '/utente/me/statistiche';
  static const String onboarding = '/onboarding';
  static const String sessions = '/sessioni';
  static const String paths = '/percorsi';
  static const String topics = '/temi';
  static const String nodes = '/nodi';
  static const String achievements = '/achievement';
}
```

**app_config.dart**:
```dart
class AppConfig {
  static const String appName = 'Dydat';
  static const String version = '1.0.0';
  static const bool enableSse = false;  // placeholder, Loop 2
  static const bool enableLatex = false; // placeholder, Loop 2
}
```

**Test B1**: `flutter pub get` + `flutter analyze` 0 errori.

---

### Blocco 2 — Modelli Dati (9 file)
**Fonte**: `docs/dydat_api_reference.md` sezione "Modelli dati principali"

**Regola conversione**: JSON snake_case → Dart camelCase nei fromJson.
Usare `@JsonSerializable()` + `@JsonKey(name: 'snake_case')`.

**9 file**:
1. `utente.dart` — Utente, PreferenzeStudio, LoginRequest, LoginResponse, RegisterRequest
2. `sessione.dart` — Sessione, Turno, MessaggioUtente, RispostaAzione
3. `percorso.dart` — Percorso
4. `nodo.dart` — Nodo, StatoNodoUtente
5. `tema.dart` — Tema (aggregazione frontend di nodi per argomento)
6. `achievement.dart` — Achievement, AchievementUtente
7. `statistiche.dart` — StatisticheGiornaliere, StoricoEsercizi
8. `onboarding.dart` — OnboardingMessage, OnboardingState
9. `api_response.dart` — ApiError, ApiException

**Test B2**: Unit test per ogni modello — fromJson/toJson roundtrip con fixture JSON copiate dalla API reference.

---

### Blocco 3 — Servizi API (8 file)
**Dipende da**: B1 (config), B2 (modelli)

1. `dio_client.dart` — Singleton Dio, interceptor JWT (legge token da storage, aggiunge header, gestisce 401)
2. `storage_service.dart` — Wrapper flutter_secure_storage (saveToken, getToken, deleteToken, saveRefreshToken)
3. `auth_service.dart` — register(), login(), refreshToken(), logout()
4. `user_service.dart` — getMe(), updatePreferences(), getStats()
5. `onboarding_service.dart` — sendMessage(), getState()
6. `session_service.dart` — create(), getActive(), sendTurn(), end(), suspend()
7. `path_service.dart` — getPaths(), getTopics(), getNodes(), getNodeStates()
8. `achievement_service.dart` — getAll(), getUser(), claim()

**Test B3**: Unit test con mock Dio adapter — verifica URL, headers, body, parsing response.

---

### Blocco 4 — Provider Riverpod (8 file)
**Dipende da**: B3 (servizi)

1. `auth_provider.dart` — StateNotifier<AuthState> (token, user, isAuthenticated, login/logout/register)
2. `user_provider.dart` — StateNotifier<UserState> (profilo, preferenze, caricamento)
3. `onboarding_provider.dart` — StateNotifier<OnboardingState> (messaggi, progresso, stage, invioMessaggio)
4. `session_provider.dart` — StateNotifier<SessionState> (sessione attiva, messaggi, timer, invioTurno)
5. `path_provider.dart` — StateNotifier<PathState> (percorsi, temi, nodi, progresso, refresh)
6. `achievement_provider.dart` — StateNotifier<AchievementState> (lista, non-letti, claim)
7. `stats_provider.dart` — StateNotifier<StatsState> (giornaliere, storico, caricamento)
8. `theme_provider.dart` — StateNotifier<ThemeMode> (system/light/dark, persiste in SharedPreferences)

**Test B4**: Unit test provider con ProviderContainer + mock services.

---

### Blocco 5 — GoRouter + Shell App
**Dipende da**: B4 (providers, specialmente auth)

**app_router.dart**:
- Shell route con CustomBottomBar (3 tab)
- Auth redirect: se non autenticato → login
- Se primo accesso → onboarding
- Deep link: `/studio`, `/percorso`, `/profilo`

**main.dart** aggiornato:
- ProviderScope wrappa tutto
- MaterialApp.router con GoRouter
- ThemeMode da theme_provider

**File da modificare**:
- `main.dart` (ProviderScope + MaterialApp.router)
- `routes/app_router.dart` (nuovo, sostituisce app_routes.dart)
- `widgets/custom_bottom_bar.dart` (adatta a GoRouter shell)

**Eliminare**: `routes/app_routes.dart` (sostituito da GoRouter)

**Test B5**: App parte, navigazione tra tab funziona, redirect auth funziona (smoke test manuale).

---

### Blocco 6 — Schermate Auth
**Dipende da**: B5 (routing), B4 (auth_provider)

**Ricablare**:
- `login_screen.dart` → usa auth_provider.login(), navigazione GoRouter
- `registration_screen.dart` → usa auth_provider.register(), navigazione GoRouter
- `splash_screen.dart` → verifica token con auth_provider, redirect automatico

**Rimuovere**: dati mock, Future.delayed finti, Navigator.pushReplacementNamed.

**Test B6**: Login con credenziali reali contro backend, registrazione crea utente, splash redirige correttamente.

---

### Blocco 7 — Tab Percorso (dati reali)
**Dipende da**: B6 (auth funzionante), B4 (path_provider)

**Ricablare**:
- `learning_path_screen.dart` → usa path_provider (percorsi reali da API)
- `tema_card_widget.dart` → riceve Tema model, non Map<String, dynamic>
- `tema_detail_bottom_sheet.dart` → mostra nodi reali con stato
- `empty_state_widget.dart` → mostrato quando nessun percorso

**Test B7**: Tab Percorso mostra dati reali dal backend. Pull-to-refresh funziona.

---

### Blocco 8 — Tab Profilo (da zero)
**Dipende da**: B6, B4 (user_provider, achievement_provider, stats_provider)

**Creare** `presentation/profile_screen/`:
- `profile_screen.dart` — layout con sezioni
- Sezioni: identita, snapshot stats, achievement, preferenze, impostazioni

**Usa**: user_provider, stats_provider, achievement_provider, theme_provider.

**Test B8**: Tab Profilo mostra dati reali. Cambio tema funziona. Logout funziona.

---

### Blocco 9 — Tab Studio (SSE placeholder)
**Dipende da**: B6, B4 (session_provider)

**Ricablare**:
- `studio_screen.dart` → usa session_provider per sessione reale
- Messaggi inviati via API (REST, non SSE)
- Timer sessione collegato a sessione reale
- Placeholder: risposta mock dal provider, non streaming

**NON implementare**: SSE streaming, LaTeX, animazioni celebrative.

**Test B9**: Creazione sessione funziona. Invio messaggio funziona (REST). Timer funziona.

---

### Blocco 10 — Test E2E con Backend
**Dipende da**: tutti i blocchi precedenti

**Flusso E2E**:
1. App parte → splash → redirect login
2. Registrazione nuovo utente → redirect onboarding
3. Onboarding (placeholder) → redirect studio
4. Tab Studio: crea sessione, invia messaggio, ricevi risposta
5. Tab Percorso: mostra percorso con temi e progresso
6. Tab Profilo: mostra stats, achievement, preferenze
7. Logout → redirect login
8. Login → redirect studio (sessione precedente)

**Prerequisiti**: Backend Docker running + DB con dati importati.

**Test B10**: Tutto il flusso funziona senza crash. Screenshots documentati.

---

## Regole di Sessione

### Inizio sessione
```
1. Leggere CLAUDE.md (stato globale)
2. Leggere QUESTO FILE (piano operativo)
3. Leggere .claude/status.md (checkpoint ultimo)
4. Leggere docs/dydat_api_reference.md (se tocchi API)
5. Creare branch da main
```

### Fine sessione — CHECKLIST OBBLIGATORIA
```
[ ] flutter analyze → 0 errori (warning tollerati)
[ ] Test del blocco → tutti verdi
[ ] .claude/status.md aggiornato con:
    - Blocchi completati in questa sessione
    - Eventuali problemi aperti
    - Prossimo blocco da fare
[ ] CLAUDE.md roadmap aggiornata (stato blocchi)
[ ] Commit con messaggio strutturato
[ ] PR verso main (se sessione completa)
[ ] PROMPT SESSIONE SUCCESSIVA generato e mostrato al fondatore
```

### Prompt sessione successiva — OBBLIGATORIO
Alla fine di ogni sessione, DEVI generare e mostrare al fondatore un prompt copia-incolla
con questo formato esatto:
```
Sessione SX — Dydat Frontend, Blocchi Y+Z ([titolo])

PRIMA DI SCRIVERE CODICE, leggi questi file in ordine:
1. CLAUDE.md
2. .claude/plans/frontend-integration.md
3. .claude/status.md
4. [altri file rilevanti per i blocchi specifici]

COSA FARE in questa sessione:
- Blocco Y: [descrizione concreta con file da creare/modificare]
- Blocco Z: [descrizione concreta con file da creare/modificare]

GATE DI USCITA:
- [criteri specifici per questa sessione]

NON fare: commit, push, toccare backend, toccare widget UI esistenti.
```
Questo prompt e l'UNICA cosa che il fondatore deve incollare per avviare la sessione successiva.
La sessione successiva sa automaticamente cosa fare leggendo i file indicati.

### Test manuale del fondatore
Da B5 in poi, quando serve test manuale sull'emulatore/device, comunicarlo con blocco visibile:
```
---------------------------------------------
FONDATORE: SERVE TEST MANUALE
---------------------------------------------
Cosa testare:
1. [azione concreta]
Cosa mi aspetto:
- [risultato atteso]
Se qualcosa non funziona:
- Screenshot o descrizione
---------------------------------------------
```
NON procedere finche il fondatore non conferma l'esito.

### Regole ferree
- **NON modificare il backend** (salvo CORS)
- **NON implementare** SSE, LaTeX, animazioni, celebrazioni
- **NON committare** senza test verdi
- **NON pushare** senza PR review
- Ogni widget nuovo usa `Theme.of(context)` — zero colori hardcoded
- JSON snake_case → Dart camelCase nei fromJson
- Commit message: `feat(frontend): Blocco X - [descrizione breve]`

### Formato commit
```
feat(frontend): B1+B2 — config e modelli dati

- Aggiunto flutter_riverpod, go_router, flutter_secure_storage
- Creati api_config.dart, app_config.dart
- Creati 9 modelli con fromJson/toJson
- 27 unit test modelli (tutti verdi)

Co-Authored-By: Claude <noreply@anthropic.com>
```
