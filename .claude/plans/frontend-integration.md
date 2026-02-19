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
---

# LOOP 2 — SSE Streaming + Azioni Tutor + Onboarding Reale

> Il Loop 1 (B0-B10) ha costruito l'architettura completa e collegato tutte le API REST.
> Il Loop 2 porta l'app da "demo funzionante" a "app usabile": il tutor risponde in tempo reale,
> le azioni (esercizi, formule, backtrack) appaiono nel canvas, l'onboarding e reale.

## Cosa esiste gia (da Loop 1)

- `SessionService.start()` parsa la risposta SSE come testo piatto per estrarre `sessione_id`
- `SessionService.sendTurn()` chiama POST ma ignora lo stream di risposta
- `TutorMessageWidget` ha gia supporto per `isStreaming: true` (animazione char-by-char)
- Widget `exercise_card_widget.dart`, `formula_card_widget.dart`, `backtrack_card_widget.dart` esistono (rimossi dal layout in S5)
- `OnboardingScreen` ha struttura completa con chat, mascotte, progress bar, ma usa dati mock
- Modello `Sessione` con tutti i campi (nodoFocaleId, nodoFocaleNome, attivitaCorrente)
- `SessionNotifier` con `addTutorMessage()`, `setActiveSession()` gia pronti
- `OnboardingService` con `start()`, `sendTurn()`, `complete()` gia implementati

## Cosa va costruito

| # | Componente | Descrizione |
|---|---|---|
| 1 | **SSE Client** | Servizio per ricevere e parsare stream `text/event-stream` in tempo reale |
| 2 | **Studio SSE** | StudioScreen riceve `text_delta`, `azione`, `achievement`, `turno_completo`, `errore` in streaming |
| 3 | **Azioni tutor nel canvas** | Exercise card, formula card, backtrack card riattivate con dati SSE reali |
| 4 | **Onboarding reale** | OnboardingScreen collegata a SSE onboarding + registrazione con `utente_temp_id` |
| 5 | **Recap sessione** | Schermata post-sessione con stats e dati reali |
| 6 | **App lifecycle** | Sospensione sessione in background, ripresa in foreground |

---

## Blocchi Loop 2

### Blocco 11 — SSE Client + Modelli Eventi
**Dipende da**: Loop 1 completo
**File da creare**:
- `lib/services/sse_client.dart` — Client SSE generico basato su `http` package (non Dio)
- `lib/models/sse_events.dart` — Modelli tipizzati per tutti gli eventi SSE

**SSE Client** (`sse_client.dart`):
```
- Usa il package `http` per fare POST con `Accept: text/event-stream`
- Parsa lo stream linea per linea: `event: <tipo>\ndata: <json>\n\n`
- Ritorna uno `Stream<SseEvent>` tipizzato
- Aggiunge header `Authorization: Bearer <token>` dalle StorageService
- Gestisce timeout (90s turno, 120s primo turno)
- Gestisce errori di connessione e stream interrotto
- Metodo: `Stream<SseEvent> stream(String path, {Map<String, dynamic>? body})`
```

**Modelli SSE** (`sse_events.dart`):
```dart
// SseEvent — sealed class/union con sottotipi:
// - SessioneCreataEvent {sessioneId, nodoId, nodoNome}
// - OnboardingIniziatoEvent {utenteTempId, sessioneId}
// - TextDeltaEvent {testo}
// - AzioneEvent {tipo, params} con sottotipi:
//   - ProponiEsercizioAction {esercizioId, testo, difficolta, nodoId, nessunoDisponibile}
//   - MostraFormulaAction {latex, etichetta}
//   - SuggerisciBacktrackAction {nodoId, motivo}
//   - ChiudiSessioneAction {riepilogo, prossimiPassi}
// - AchievementEvent {id, nome, tipo}
// - TurnoCompletoEvent {turnoId, nodoFocale}
// - ErroreEvent {codice, messaggio}
```

**pubspec.yaml**: aggiungere `http: ^1.2.0` (per SSE streaming, Dio non supporta bene stream line-by-line)

**Test B11**: Unit test SSE client con stream mockato — verifica parsing di tutti i tipi di evento.

---

### Blocco 12 — Studio Screen con SSE Reale
**Dipende da**: B11 (SSE Client)
**File da modificare**:
- `lib/services/session_service.dart` — Aggiungere metodi SSE per `start()` e `sendTurn()`
- `lib/providers/session_provider.dart` — Gestire stream SSE, accumulare testo, gestire azioni
- `lib/presentation/studio_screen/studio_screen.dart` — Mostrare testo streaming in tempo reale

**SessionService** — nuovi metodi:
```dart
// startStream() → Stream<SseEvent> che fa POST /sessione/inizia come SSE
// sendTurnStream(sessioneId, messaggio) → Stream<SseEvent> che fa POST /sessione/{id}/turno come SSE
// I metodi REST start()/sendTurn() restano come fallback
```

**SessionNotifier** — aggiornamenti:
```dart
// startSessionStream() — ascolta lo stream SSE:
//   - sessione_creata → setta activeSession
//   - text_delta → accumula testo nel messaggio corrente (concatena tutti i .testo)
//   - azione → aggiunge azione alla lista azioni del turno corrente
//   - achievement → aggiunge alla lista achievement del turno
//   - turno_completo → finalizza il messaggio tutor, aggiorna nodoFocale
//   - errore → setta errore, chiude stream
//
// sendTurnStream(messaggio) — stessa logica per i turni successivi
//
// Nuovo stato:
//   - String currentTutorText (testo in accumulo durante streaming)
//   - bool isStreaming
//   - List<AzioneEvent> currentTurnActions
//   - List<AchievementEvent> currentTurnAchievements
```

**StudioScreen** — aggiornamenti:
```dart
// Il messaggio tutor si costruisce in tempo reale:
//   - Durante streaming: mostra currentTutorText che cresce token per token
//   - A turno_completo: il messaggio viene finalizzato nella lista _messages
//   - Cursore ambra pulsante durante lo streaming (come da direzione visiva)
//   - Auto-scroll durante streaming
//
// Rimuovere: il placeholder "Messaggio ricevuto. La risposta in tempo reale..."
// Rimuovere: il Future.delayed finto
```

**Test B12**: App crea sessione e mostra il primo messaggio tutor in streaming reale. Invio messaggio e risposta streaming funzionano.

---

### Blocco 13 — Azioni Tutor nel Canvas
**Dipende da**: B12 (SSE funzionante nella studio)
**File da modificare**:
- `lib/presentation/studio_screen/studio_screen.dart` — Riattivare card nel layout
- `lib/presentation/studio_screen/widgets/exercise_card_widget.dart` — Ricablare su dati SSE reali
- `lib/presentation/studio_screen/widgets/formula_card_widget.dart` — Ricablare su dati SSE reali
- `lib/presentation/studio_screen/widgets/backtrack_card_widget.dart` — Ricablare su dati SSE reali

**File da creare**:
- `lib/presentation/studio_screen/widgets/achievement_toast_widget.dart` — Toast per achievement sbloccato

**Come funziona**:
```
Quando SessionNotifier riceve un evento `azione`:
- proponi_esercizio → ExerciseCard appare inline nel flusso chat
  - Se nessunoDisponibile: true → niente card (il tutor genera nel testo)
  - Altrimenti: card con testo esercizio, badge difficolta, campo input, bottone "Verifica"
  - "Verifica" invia la risposta come messaggio al tutor via sendTurnStream()
- mostra_formula → FormulaCard appare inline (testo raw della formula, placeholder LaTeX)
- suggerisci_backtrack → BacktrackCard con motivo + bottoni "Ok, rivediamolo" / "Continua qui"
  - "Ok, rivediamolo" invia messaggio al tutor
- chiudi_sessione → Mostra riepilogo, bottone "Vai al riepilogo" → naviga a recap

Quando SessionNotifier riceve un evento `achievement`:
- AchievementToast appare come overlay (tipo SnackBar ma piu elaborato)
- Icona differenziata per tipo (sigillo/medaglia/costellazione)
- Auto-dismiss dopo 4 secondi
```

**Test B13**: Durante una sessione reale, le azioni del tutor (esercizi, formule) appaiono nel canvas. Achievement toast funziona.

---

### Blocco 14 — Onboarding Reale con SSE
**Dipende da**: B11 (SSE Client)
**File da modificare**:
- `lib/services/onboarding_service.dart` — Aggiungere metodi SSE streaming
- `lib/providers/onboarding_provider.dart` — Gestire stream SSE onboarding
- `lib/presentation/onboarding_screen/onboarding_screen.dart` — Collegare a SSE reale
- `lib/presentation/registration_screen/registration_screen.dart` — Passare `utente_temp_id`

**OnboardingService** — nuovi metodi:
```dart
// startStream() → Stream<SseEvent> per POST /onboarding/inizia
//   - Primo evento: onboarding_iniziato {utente_temp_id, sessione_id}
//   - Poi: text_delta, turno_completo
// sendTurnStream(sessioneId, messaggio) → Stream<SseEvent> per POST /onboarding/turno
// complete() → gia implementato (REST, non SSE)
```

**OnboardingNotifier** — aggiornamenti:
```dart
// startOnboarding() — chiama startStream():
//   - onboarding_iniziato → salva utenteTempId e sessioneId
//   - text_delta → accumula testo tutor in tempo reale
//   - turno_completo → finalizza messaggio, incrementa contatore turni
//
// sendMessage(messaggio) — chiama sendTurnStream():
//   - Stessa logica di accumulo testo
//   - Progress bar avanza in base al numero di turni (~10 turni totali)
//
// completeOnboarding() — chiama complete() REST:
//   - Salva percorso_id
//   - Naviga a registrazione con utenteTempId
```

**OnboardingScreen** — aggiornamenti:
```
- Rimuovere: _simulateAiResponse() e tutti i messaggi mock
- Collegare a onboardingProvider
- Convertire a ConsumerStatefulWidget
- initState() chiama startOnboarding()
- Progress bar collegata a turni reali (turno/10)
- Gestione errore SSE con retry
```

**RegistrationScreen** — aggiornamenti:
```
- Ricevere utenteTempId (via provider o route extra)
- Passarlo a authProvider.register(utenteTempId: ...)
- Dopo successo: il JWT contiene lo stesso UUID, percorso gia collegato
```

**Test B14**: Onboarding reale con tutor AI. Messaggi in streaming. Registrazione con conversione utente temporaneo. Percorso creato.

---

### Blocco 15 — Recap Sessione + App Lifecycle
**Dipende da**: B12, B13
**File da creare**:
- `lib/presentation/studio_screen/recap_session_screen.dart` — Schermata post-sessione

**File da modificare**:
- `lib/presentation/studio_screen/studio_screen.dart` — Navigare a recap dopo terminazione
- `lib/routes/app_router.dart` — Aggiungere route /recap/:sessioneId
- `lib/main.dart` — WidgetsBindingObserver per app lifecycle

**Recap Screen**:
```
- Riceve sessioneId dalla route
- Carica dati: GET /sessione/{id} + GET /utente/me/statistiche
- Mostra: durata effettiva, nodi lavorati, statistiche aggiornate
- Card con numeri grandi (stile gamification dal design)
- Bottone "Torna alla home" → naviga a /studio
```

**App Lifecycle**:
```
- WidgetsBindingObserver in main.dart (o in StudioScreen)
- didChangeAppLifecycleState:
  - paused/inactive → se sessione attiva, chiama suspend()
  - resumed → se sessione era sospesa, chiama startSession() per riprendere
```

**Test B15**: Terminazione sessione mostra recap con dati reali. App in background sospende sessione.

---

### Blocco 16 — Test E2E Loop 2 + Polish
**Dipende da**: B11-B15

**Flusso E2E Loop 2**:
1. App parte → splash → login
2. (Nuovo utente) Onboarding reale con tutor AI streaming → registrazione → percorso creato
3. Tab Studio: crea sessione → testo tutor in streaming → esercizio proposto → risposta → feedback
4. Achievement sbloccato → toast
5. Termina sessione → recap con statistiche
6. Tab Percorso: progresso aggiornato
7. Tab Profilo: statistiche aggiornate, achievement visibili
8. App in background → sessione sospesa → riapri → sessione ripresa
9. Logout → login → dev quick login

**Test B16**: Tutto il flusso E2E funziona con SSE reale. `flutter analyze` → 0 errori.

---

## Pipeline Sessioni Loop 2

| Sessione | Blocchi | Deliverable | Gate di uscita | Branch |
|----------|---------|-------------|----------------|--------|
| **S7** | B11 | SSE Client + Modelli eventi | Unit test SSE parser + `flutter analyze` 0 errori | `feature/frontend-sse-client` |
| **S8** | B12 | Studio con SSE reale | Testo tutor in streaming reale nel canvas | `feature/frontend-studio-sse` |
| **S9** | B13 | Azioni tutor nel canvas | Exercise/formula/backtrack card con dati SSE | `feature/frontend-azioni-tutor` |
| **S10** | B14 | Onboarding reale | Onboarding completo con tutor AI + registrazione conversione | `feature/frontend-onboarding` |
| **S11** | B15 | Recap + lifecycle | Recap post-sessione + sospensione in background | `feature/frontend-recap-lifecycle` |
| **S12** | B16 | Test E2E Loop 2 | Flusso completo con SSE reale senza crash | `feature/frontend-e2e-loop2` |

**Regola**: stessa del Loop 1 — branch per sessione, PR verso main dopo test verdi.

---

## Cosa NON fa il Loop 2

- ~~**LaTeX rendering** (`flutter_math_fork`)~~ → **FATTO in Loop 3 (B17)**
- ~~**Animazioni celebrative** (particelle, glow, burst)~~ → **FATTO in Loop 3 (B20)**
- **Mascotte animata** (stati emotivi, Rive) — rimandato a Loop 4. Servono asset di design.
- **Spaced Repetition** — il backend ha i campi predisposti ma la logica non e attiva.
- **Feynman/Connessioni** — livelli `comprensivo` e `connesso` non raggiungibili.
- **Input voce** — placeholder "Prossimamente".
- **Calcolatrice nel tools tray** — placeholder.

---
---

# LOOP 3 — UX Polish + LaTeX + Storico Sessioni + Celebrazioni

> Il Loop 2 (B11-B16) ha portato l'app a funzionare con SSE reale.
> Il Loop 3 porta l'app da "funzionante" a "raffinata": formule matematiche renderizzate,
> storico sessioni nella home, progressione nodi visibile, celebrazioni animate.

## Cosa esiste gia (da Loop 2)

- `FormulaCardWidget` mostra LaTeX come testo raw — serve rendering
- `MascotteWidget` ha scale+pulse animation — resta placeholder circolare
- `AchievementToast` con slide-in/fade animation — completo
- `ExerciseCardWidget` con campo input e verifica — ha colori hardcoded da fixare
- `TemaDetailBottomSheet` mostra nodi con check binario — serve 3 stati
- `RecapSessionScreen` mostra dati reali — manca rilevamento tema completato
- `MarkdownText` widget per rendering markdown — base per LatexText
- Nessuno storico sessioni nella home
- Backend non ha `GET /sessione/` (list) ne espone `esito` esercizio

## Cosa va costruito

| # | Componente | Descrizione |
|---|---|---|
| 1 | **LaTeX Rendering** | `flutter_math_fork` in FormulaCard + `LatexText` widget per inline math |
| 2 | **Node Progression** | 3 stati nodo nel bottom sheet (non_iniziato/in_corso/operativo+) |
| 3 | **Session History Backend** | `GET /sessione/` endpoint per listare sessioni passate |
| 4 | **Session History Frontend** | `SessionHistoryWidget` nella home con card sessioni |
| 5 | **Recap Improvements** | Rilevamento e card "Tema completato" nel recap |
| 6 | **Celebration Animations** | Particelle (primo_tentativo) e glow (con_guida) + `esito_esercizio` SSE |

---

## Blocchi Loop 3

### Blocco 17 — LaTeX Rendering
**Dipende da**: Loop 2 completo
**File da creare**:
- `lib/widgets/latex_text.dart` — Widget che parsa `$...$` (inline) e `$$...$$` (block), renderizza con `Math.tex()`
- `test/widgets/latex_text_test.dart` — Unit test parsing delimitatori

**File da modificare**:
- `pubspec.yaml` — aggiungere `flutter_math_fork: ^0.7.0`
- `lib/presentation/studio_screen/widgets/formula_card_widget.dart` — `Text()` → `Math.tex()` con fallback
- `lib/presentation/studio_screen/studio_screen.dart` — `MarkdownText` → `LatexText` nei messaggi finalizzati
- `lib/presentation/studio_screen/widgets/tutor_message_widget.dart` — `MarkdownText` → `LatexText`

**NOTA**: LaTeX solo nei messaggi finalizzati (dopo `turno_completo`). Streaming bubble resta con `MarkdownText` (delimitatori possono arrivare split tra text_delta).

**Test B17**: FormulaCard renderizza LaTeX + inline funziona + fallback per malformato + unit test parsing.

---

### Blocco 18 — Node Progression + Session History Backend
**Dipende da**: B17 completato

**18a — Node Progression Visibility**
- `lib/presentation/learning_path_screen/widgets/tema_detail_bottom_sheet.dart` — 3 stati nodo:
  - `non_iniziato` → `theme.colorScheme.outline` + `radio_button_unchecked`
  - `in_corso` → `theme.colorScheme.primary` + `timelapse`
  - `operativo+` → `theme.colorScheme.secondary` + `check_circle`
- Rimuovere `TextDecoration.lineThrough`, 3x `Color(0xFF7EBF8E)` hardcoded
- Badge `presunto` per nodi assunti dall'onboarding

**18b — Session History Backend** (autorizzazione confermata)
- `backend/app/api/sessione.py` — route `GET /sessione/`
- `backend/app/schemas/sessione.py` — `SessioneListItemResponse`
- `backend/tests/test_sessione.py` — 3+ test

**Test B18**: 3 stati nodo visibili + backend list endpoint funzionante.

---

### Blocco 19 — Session History Frontend + Recap Improvements
**Dipende da**: B18b (endpoint backend)

**19a — Session History Frontend**
- `lib/models/sessione.dart` — aggiungere `SessioneListItem` con `createdAt`, `completedAt`
- `lib/services/session_service.dart` — `listSessions()`
- `lib/providers/session_provider.dart` — `sessionHistory`, `loadSessionHistory()`
- `lib/presentation/studio_screen/studio_screen.dart` — aggiungere `SessionHistoryWidget` nella home
- NUOVO: `lib/presentation/studio_screen/widgets/session_history_widget.dart`

**19b — Recap Improvements**
- `lib/presentation/studio_screen/recap_session_screen.dart` — fetch `GET /temi/`, cross-reference con `nodiLavorati`, card "Tema completato: [nome]!"

**Test B19**: Storico sessioni nella home + tap → recap + card tema completato.

---

### Blocco 20 — Celebration Animations + Esito SSE
**Dipende da**: B19 completato, autorizzazione backend confermata

**Backend**:
- `backend/app/core/elaborazione.py` — emettere evento `esito_esercizio` SSE
- `backend/tests/test_elaborazione.py` — test

**Frontend**:
- `lib/models/sse_events.dart` — `EsitoEsercizioEvent`
- `lib/providers/session_provider.dart` — `latestEsito` nello state
- `lib/presentation/studio_screen/studio_screen.dart` — trigger celebrazione
- `lib/presentation/studio_screen/widgets/exercise_card_widget.dart` — fix hardcoded colors
- NUOVO: `lib/presentation/studio_screen/widgets/celebration_overlay.dart` — particelle (burst) e glow

**Test B20**: Celebrazione burst su primo_tentativo + glow su con_guida + haptic.

---

### Blocco 21 — Test E2E Loop 3 + Polish
**Dipende da**: B17-B20

**Test E2E**: LaTeX, storico, node progression, recap tema, celebrazioni, lifecycle, 409.
- Fix hardcoded color residui (mascotte_widget.dart linea 103)
- `flutter analyze` 0 errori + `flutter test` tutti verdi

---

## Pipeline Sessioni Loop 3

| Sessione | Blocchi | Gate di uscita | Branch |
|----------|---------|----------------|--------|
| **S13** | B17 | LaTeX renderizza + inline + unit test + fallback | `feature/frontend-b17` |
| **S14** | B18 | 3 stati nodo + backend GET /sessione/ + pytest | `feature/frontend-b18` |
| **S15** | B19 | Storico nella home + recap tema completato | `feature/frontend-b19` |
| **S16** | B20 | Celebrazioni + esito SSE + haptic | `feature/frontend-b20` |
| **S17** | B21 | E2E completo senza crash + 0 errori | `feature/frontend-b21` |

## Cosa NON fa il Loop 3

- **Mascotte "Creatura di Luce"** — servono asset di design (SVG/Rive). Il placeholder circolare resta.
- **Beat-aware canvas styling** (shimmer, background dimming) — alta complessita, dipende dalla mascotte.
- **Celebrazione promozione nodo** (Beat 6) — serve segnale `promozione` esposto al frontend.
- **Streak flame animation** — bassa priorita, serve design.
- **Tools tray funzionale** — placeholders restano.
- **Voice input** — placeholder resta.

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
Alla fine di ogni sessione, DEVI:
1. Generare il prompt copia-incolla (formato sotto)
2. Suggerire il **nome sessione**: `Dydat — BX+BY — [attivita svolta]`

```
Sessione SX — Dydat Frontend, Blocchi Y+Z ([titolo])
NOME SESSIONE: Dydat — BY+BZ — [attivita]

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
Il fondatore rinomina la conversazione con il NOME SESSIONE suggerito.
Questo prompt e l'UNICA cosa che deve incollare per avviare la sessione successiva.

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
