# Dydat — Brief Tecnico per Rocket.new

> Documento di implementazione per AI coding agent (Rocket.new)
> Data: 18 febbraio 2026 — v2 (allineato a dydat_api_reference.md)
> Stack: Flutter/Dart — Mobile-first (iOS + Android)
> Backend: già implementato e funzionante — questo documento descrive il frontend

---

## 1. Panoramica del progetto

Dydat è un'app di apprendimento adattivo AI-first per matematica, fisica e chimica. L'utente studia con un tutor AI conversazionale che spiega concetti, propone esercizi, e adatta il percorso in tempo reale.

L'app ha 3 tab principali (Studio, Percorso, Profilo) + un flusso di onboarding. Il backend è un'API REST + SSE streaming già funzionante. Questo brief copre tutto ciò che Rocket.new deve costruire.

### Cosa costruisce Rocket.new

- Architettura app Flutter completa (struttura cartelle, routing, state management)
- Sistema di temi (dark + light) con design tokens
- Tutte le schermate con layout e componenti
- Integrazione API REST (autenticazione, lettura dati, chiamate)
- Navigazione completa (tab, bottom sheet, onboarding flow)
- Componenti riusabili (card, bottoni, indicatori di progresso)
- Placeholder strutturati per le parti che Claude Code completerà dopo

### Cosa NON costruisce Rocket.new (placeholder)

- Client SSE e streaming testo token-by-token → placeholder: widget con testo statico "Risposta del tutor..."
- Rendering LaTeX (`flutter_math_fork`) → placeholder: widget Text con stringa formula
- Sistema celebrazioni beat-specific → placeholder: SnackBar semplice "Esercizio corretto!"
- Animazioni avanzate (particelle, glow, shimmer) → placeholder: AnimatedContainer basici
- Mascotte animata → placeholder: Container circolare 48dp con icona statica, posizionato correttamente
- Logica sospensione/ripresa sessione con context restore → placeholder: chiama gli endpoint, mostra stato
- Calcolatrice scientifica nel tools tray → placeholder: voce nel tray con icona, nessuna funzionalità
- Input voce → placeholder: voce nel tray disabilitata con label "Prossimamente"

---

## 2. Architettura app

### Struttura cartelle

```
lib/
├── main.dart
├── app.dart                     # MaterialApp, tema, routing
├── config/
│   ├── theme/
│   │   ├── app_theme.dart       # ThemeData dark + light
│   │   ├── colors.dart          # Design tokens colori
│   │   ├── typography.dart      # Design tokens tipografia
│   │   └── spacing.dart         # Design tokens spacing
│   ├── api_config.dart          # Base URL, timeout
│   └── routes.dart              # Route names
├── models/
│   ├── utente.dart
│   ├── sessione.dart
│   ├── percorso.dart
│   ├── nodo.dart
│   ├── tema.dart
│   ├── achievement.dart
│   ├── statistiche.dart
│   └── sse_events.dart          # Enum e modelli per eventi SSE
├── services/
│   ├── api/
│   │   ├── api_client.dart      # HTTP client con JWT, error handling
│   │   ├── auth_service.dart
│   │   ├── sessione_service.dart
│   │   ├── percorso_service.dart
│   │   ├── tema_service.dart
│   │   ├── achievement_service.dart
│   │   ├── utente_service.dart
│   │   └── onboarding_service.dart
│   ├── sse/
│   │   └── sse_client.dart      # PLACEHOLDER — Claude Code implementerà
│   └── storage/
│       └── secure_storage.dart  # JWT persistence
├── providers/                   # State management (Riverpod)
│   ├── auth_provider.dart
│   ├── sessione_provider.dart
│   ├── percorso_provider.dart
│   ├── tema_provider.dart
│   ├── achievement_provider.dart
│   ├── utente_provider.dart
│   └── theme_provider.dart      # Dark/light mode state
├── screens/
│   ├── onboarding/
│   │   ├── onboarding_screen.dart
│   │   └── registrazione_screen.dart
│   ├── studio/
│   │   ├── studio_screen.dart
│   │   ├── widgets/
│   │   │   ├── studio_header.dart
│   │   │   ├── canvas_area.dart         # PLACEHOLDER per streaming
│   │   │   ├── exercise_card.dart
│   │   │   ├── formula_card.dart        # PLACEHOLDER per LaTeX
│   │   │   ├── backtrack_card.dart      # PLACEHOLDER per suggerimento backtrack
│   │   │   ├── mascotte_widget.dart     # PLACEHOLDER
│   │   │   ├── tools_tray.dart
│   │   │   ├── tutor_panel.dart
│   │   │   └── input_bar.dart
│   │   └── recap_sessione_screen.dart
│   ├── percorso/
│   │   ├── percorso_screen.dart
│   │   └── widgets/
│   │       ├── percorso_header.dart
│   │       ├── sentiero_widget.dart
│   │       ├── tema_card.dart
│   │       └── tema_detail_sheet.dart
│   ├── profilo/
│   │   ├── profilo_screen.dart
│   │   └── widgets/
│   │       ├── identita_section.dart
│   │       ├── snapshot_section.dart
│   │       ├── achievement_section.dart
│   │       ├── statistiche_section.dart
│   │       ├── preferenze_tutor_section.dart
│   │       └── impostazioni_section.dart
│   └── auth/
│       ├── login_screen.dart
│       └── splash_screen.dart
├── widgets/                     # Componenti riusabili
│   ├── dydat_card.dart
│   ├── dydat_button.dart
│   ├── progress_bar.dart
│   ├── achievement_badge.dart
│   ├── loading_indicator.dart
│   └── error_widget.dart
└── utils/
    ├── date_formatter.dart
    └── validators.dart
```

### State management: Riverpod

Usare `flutter_riverpod` per la gestione dello stato. Ogni service API ha un provider corrispondente. Il tema (dark/light) è gestito da un `StateNotifierProvider`.

### Routing: GoRouter

Usare `go_router` per la navigazione. Route principali:

```dart
// Route
/splash              → SplashScreen (check JWT)
/onboarding          → OnboardingScreen
/onboarding/registra → RegistrazioneScreen
/login               → LoginScreen
/home                → ShellRoute con BottomNavigation
  /home/studio       → StudioScreen (tab index 0, default)
  /home/percorso     → PercorsoScreen (tab index 1)
  /home/profilo      → ProfiloScreen (tab index 2)
/profilo/impostazioni/:sezione → sotto-schermate impostazioni
/sessione/recap/:id  → RecapSessioneScreen
```

### Dipendenze (pubspec.yaml)

```yaml
dependencies:
  flutter_riverpod: ^2.5.0
  go_router: ^14.0.0
  dio: ^5.4.0               # HTTP client
  flutter_secure_storage: ^9.0.0  # JWT persistence
  shared_preferences: ^2.2.0     # Theme mode persistence
  google_fonts: ^6.2.0      # Plus Jakarta Sans
  # flutter_math_fork: ^0.7.0  # PLACEHOLDER — Claude Code aggiungerà
  intl: ^0.19.0              # Date formatting
  shimmer: ^3.0.0            # Loading placeholder
```

---

## 3. Sistema di temi

### Principio: dark-first, light completo

Il tema dark è l'esperienza primaria. Il tema light è una versione completa, non un afterthought. L'utente sceglie nelle impostazioni (Profilo → Accessibilità). Default: segue il sistema operativo.

### Design tokens — Colori (colors.dart)

```dart
// === DARK THEME ===

// Base (sfondi)
static const darkBackground = Color(0xFF1A1A1E);      // Sfondo principale
static const darkSurface = Color(0xFF242428);           // Card, bottom sheet
static const darkSurfaceInteractive = Color(0xFF2E2E34); // Input, hover
static const darkBorder = Color(0xFF3A3A42);            // Separatori

// Accento primario: Ambra/Oro
static const amber = Color(0xFFD4A843);                 // CTA, stato attivo
static const amberBright = Color(0xFFF0C85A);           // Achievement, celebrazioni
static const amberMuted = Color(0xFFA68A3A);            // Testo secondario ambra

// Testo
static const darkTextPrimary = Color(0xFFE8E4DC);       // Corpo testo (crema caldo)
static const darkTextSecondary = Color(0xFF9B978F);      // Label, meta-info
static const darkTextDisabled = Color(0xFF5A5750);       // Elementi non attivi

// Semantici
static const success = Color(0xFF7EBF8E);               // Corretto
static const error = Color(0xFFC97070);                  // Errore (morbido)
static const info = Color(0xFF7EA8C9);                   // Link, info

// === LIGHT THEME ===

// Base (sfondi)
static const lightBackground = Color(0xFFF5F2ED);       // Crema caldo, non bianco puro
static const lightSurface = Color(0xFFFFFFFF);           // Card
static const lightSurfaceInteractive = Color(0xFFEDE9E3); // Input, hover
static const lightBorder = Color(0xFFD9D5CE);            // Separatori

// Testo
static const lightTextPrimary = Color(0xFF2A2A2E);       // Corpo testo
static const lightTextSecondary = Color(0xFF6B6860);      // Label
static const lightTextDisabled = Color(0xFFB0ADA6);       // Disabilitato

// Accento e semantici: identici al dark theme
// amber, amberBright, amberMuted, success, error, info restano invariati
```

### Design tokens — Tipografia (typography.dart)

Font: **Plus Jakarta Sans** (da Google Fonts, fallback su sistema).

```dart
// Gerarchia
static const h1 = TextStyle(fontSize: 26, fontWeight: FontWeight.w700);   // Titolo pagina
static const h2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);   // Sezione
static const h3 = TextStyle(fontSize: 17, fontWeight: FontWeight.w500);   // Sotto-sezione
static const body = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.55); // Corpo
static const caption = TextStyle(fontSize: 13, fontWeight: FontWeight.w400); // Meta-info
static const gamification = TextStyle(fontSize: 24, fontWeight: FontWeight.w700); // Numeri grandi
```

### Design tokens — Spacing (spacing.dart)

```dart
static const xs = 4.0;
static const sm = 8.0;
static const md = 16.0;
static const lg = 24.0;
static const xl = 32.0;
static const xxl = 48.0;
```

### ThemeData (app_theme.dart)

Costruire due `ThemeData` completi (dark e light) usando i token. Ogni widget usa `Theme.of(context)` — nessun colore hardcoded.

Il `ThemeProvider` usa `StateNotifierProvider<ThemeNotifier, ThemeMode>`:
- Persiste la scelta in `SharedPreferences`
- Valori: `ThemeMode.system` (default), `ThemeMode.dark`, `ThemeMode.light`
- Il toggle è in Profilo → Impostazioni → Accessibilità

---

## 4. API Client e autenticazione

### Base URL e configurazione

```dart
// api_config.dart
static const baseUrl = 'http://localhost:8000';  // Configurabile per ambiente
static const timeoutRest = Duration(seconds: 10);
static const timeoutSse = Duration(seconds: 120);
```

**IMPORTANTE**: nessun prefisso `/api/v1/`. Gli endpoint montano direttamente su `/auth`, `/utente`, ecc.

### HTTP Client (api_client.dart)

Usare `Dio` con interceptor per JWT:

```dart
// Interceptor aggiunge automaticamente:
// Authorization: Bearer <token>
// a tutte le richieste (tranne /auth/registrazione, /auth/login, /onboarding/*)

// Gestione errori: tradurre i codici HTTP in eccezioni tipizzate
// 401 → TokenExpiredException → redirect a login
// 404/400 → ApiException con messaggio italiano dal backend
// 409 → ConflictException (gestione speciale per sessione, vedi §5.2)
// timeout → TimeoutException
```

### Flusso autenticazione

```
App si apre
  → SplashScreen: leggi JWT da SecureStorage
  → JWT presente? → verifica con GET /utente/me
    → 200: vai a /home
    → 401: cancella JWT, vai a /login
  → JWT assente? → vai a /onboarding (primo avvio) o /login
```

### Persistenza JWT

Usare `flutter_secure_storage` per salvare il token. Il token dura 30 giorni (720 ore). Non c'è refresh token — alla scadenza, redirect a login.

### Registrazione con conversione utente temporaneo

```dart
// POST /auth/registrazione
// Body: {email, password, nome, utente_temp_id?}
//
// Se utente_temp_id è presente (dall'onboarding):
//   converte l'utente temporaneo in registrato
//   il percorso resta collegato allo stesso UUID
//
// Response 201: {access_token, token_type}
//
// Errori:
//   409: "Email gia' registrata"
//   404: "Utente temporaneo non trovato" (con utente_temp_id)
//   400: "Utente gia' registrato" (utente_temp_id già convertito)
//
// Il frontend DEVE salvare utente_temp_id ricevuto da SSE onboarding_iniziato
// e passarlo alla registrazione
```

---

## 5. Schermate — Dettaglio implementativo

### 5.1 Onboarding

**Flusso**: L'onboarding è una conversazione con il tutor AI via SSE. Per il MVP di Rocket.new, implementare la struttura della schermata e le chiamate API. Il rendering streaming lo completerà Claude Code.

**Layout**:
```
┌──────────────────────────────────────────────────┐
│  Progress bar (sottile, ambra)                    │
├──────────────────────────────────────────────────┤
│                                                  │
│  [Mascotte placeholder — grande, centrata]       │
│                                                  │
│  Area messaggi tutor                             │
│  (ScrollView con messaggi del tutor)             │
│                                                  │
│                                                  │
│                                                  │
├──────────────────────────────────────────────────┤
│  [Input testo] [Invio]                           │
└──────────────────────────────────────────────────┘
```

**Chiamate API**:
1. `POST /onboarding/inizia` → SSE stream → primo evento: `onboarding_iniziato` con `utente_temp_id` e `sessione_id` → salva entrambi
2. `POST /onboarding/turno` con `{sessione_id, messaggio}` → SSE stream (N volte)
3. `POST /onboarding/completa` con `{sessione_id, contesto_personale, preferenze_tutor}` → 200: `{percorso_id, nodo_iniziale, nodi_inizializzati}`
4. Naviga a `RegistrazioneScreen` con `utente_temp_id`

**Fasi dell'onboarding** (gestite dal backend automaticamente):
- Fase accoglienza: primo turno (tutor saluta)
- Fase conoscenza: dal 2° turno (tutor esplora conoscenze dell'utente)
- Fase conclusione: dopo ~8 turni in conoscenza (tutor chiude)

Il frontend non deve gestire le fasi — il backend le aggiorna in automatico. Il frontend mostra semplicemente i messaggi del tutor e raccoglie le risposte dell'utente. La progress bar può avanzare approssimativamente in base al numero di turni.

**PLACEHOLDER SSE**: per ora, fare la POST e mostrare un indicatore di caricamento. Dopo 2 secondi simulati, mostrare un messaggio placeholder. Quando Claude Code implementerà il client SSE, i messaggi appariranno in streaming.

**RegistrazioneScreen**: form con email, password, nome + bottone "Crea account". Chiama `POST /auth/registrazione` con `utente_temp_id`. Successo → salva JWT → vai a `/home`.

### 5.2 Tab Studio

**Layout**:

```
┌──────────────────────────────────────────────────┐
│  Header: [●] Nodo attuale · ⏱ mm:ss             │  ~48dp
├──────────────────────────────────────────────────┤
│                                                  │
│                                                  │
│              CANVAS AREA                         │
│                                                  │
│  [Messaggi tutor — ScrollView]                   │
│                                                  │
│  [Card esercizio — quando presente]              │
│  [Card formula — quando presente]                │
│  [Card backtrack — quando presente]              │
│                                                  │
│                                          [🔵]    │  ← mascotte (48dp)
├──────────────────────────────────────────────────┤
│  [Input testo studente] [Invio]                  │
├──────────────────────────────────────────────────┤
│   Studio    │   Percorso    │   Profilo          │
└──────────────────────────────────────────────────┘
```

**Header leggero** (`studio_header.dart`):
- Una riga: indicatore colore materia (cerchietto), nome nodo focale, timer sessione
- Timer conta in su dal momento dell'apertura sessione
- Altezza fissa ~48dp
- Nessun bottone — solo informazione contestuale
- I dati vengono dall'evento SSE `sessione_creata` (nodo_id, nodo_nome)

**Canvas area** (`canvas_area.dart`):
- ScrollView verticale con i messaggi del tutor
- PLACEHOLDER: ogni messaggio del tutor è un widget `TutorMessage` con testo statico
- Claude Code sostituirà con streaming token-by-token + LaTeX rendering
- Le card (esercizio, formula, backtrack) appaiono inline nel flusso quando il backend emette un evento `azione`

**Card esercizio** (`exercise_card.dart`):
- Container con bordo ambra (#D4A843), border radius 12, sfondo surface elevata (#242428)
- Testo dell'esercizio (dal campo `testo` dell'azione `proponi_esercizio`)
- PLACEHOLDER per LaTeX: mostrare il testo raw
- Badge difficoltà (1-5 pallini)
- Campo input per la risposta
- Bottone "Verifica"
- **Stato speciale**: se l'azione arriva con `nessun_esercizio_disponibile: true`, non mostrare la card esercizio (il tutor genererà l'esercizio direttamente nel testo)

**Card formula** (`formula_card.dart`) — PLACEHOLDER:
- Container con sfondo surface, border radius 12
- Testo raw della formula (campo `latex` dell'azione `mostra_formula`)
- Label opzionale (campo `etichetta`)
- Claude Code sostituirà con rendering LaTeX reale

**Card backtrack** (`backtrack_card.dart`) — PLACEHOLDER:
- Container con bordo info (#7EA8C9), border radius 12
- Testo: "Il tutor suggerisce di rivedere: [nodo]" (campo `motivo` dell'azione `suggerisci_backtrack`)
- Due bottoni: "Ok, rivediamolo" e "Continua qui"
- Il bottone "Ok" invia un messaggio al tutor via `/sessione/{id}/turno`

**Mascotte** (`mascotte_widget.dart`):
- PLACEHOLDER: `Container` circolare 48dp, colore ambra, con icona (es: `Icons.auto_awesome`)
- Posizionato con `Positioned` nell'angolo basso-destra del canvas (right: 16, bottom: 16)
- `GestureDetector` con `onTap` → apre tools tray
- Z-index sopra il canvas

**Tools tray** (`tools_tray.dart`):
- Bottom sheet che appare al tap sulla mascotte
- Altezza ~40% schermo
- Contenuto: griglia 3×2 di strumenti meccanici + bottone "Parla col tutor" separato in basso

| Strumento | Icona | Funzione | Stato |
|---|---|---|---|
| **Calcolatrice** | `Icons.calculate` | Calcolatrice scientifica | PLACEHOLDER — icona + label, nessuna azione |
| **Formule** | `Icons.functions` | Reference formule del nodo attuale | PLACEHOLDER |
| **Note** | `Icons.edit_note` | Appunti personali | PLACEHOLDER |
| **Salva** | `Icons.photo_camera` | Screenshot/salva canvas | PLACEHOLDER |
| **Visualizzazioni** | `Icons.bar_chart` | Toggle componenti visuali | PLACEHOLDER |
| **Input voce** | `Icons.mic` | Switch modalità input | PLACEHOLDER, label "Prossimamente", disabilitato |

Sotto la griglia: bottone "Parla col tutor" (full-width, visivamente distinto, colore ambra) → apre tutor panel.

Ultimo elemento: "Termina sessione" (testo discreto, colore textSecondary) → chiama `POST /sessione/{id}/termina` → naviga a recap.

- Slide-up con spring animation

**Tutor panel** (`tutor_panel.dart`):
- Slide-in da destra, ~70% larghezza schermo
- Espandibile a schermo intero con drag
- PLACEHOLDER: area messaggi + input text
- Claude Code implementerà la conversazione SSE completa

**Input bar** (`input_bar.dart`):
- TextField con bordo arrotondato, sfondo surface interattiva
- Bottone invio (icona freccia, colore ambra)
- PLACEHOLDER per toolbar simboli matematici sopra la tastiera

**Flusso sessione — chiamate API e gestione errori**:

```dart
// All'apertura del tab Studio:
// 1. POST /sessione/inizia → SSE stream
//    Gestione risposte:
//
//    SUCCESSO: SSE stream
//      → evento sessione_creata: {sessione_id, nodo_id, nodo_nome}
//      → salvare sessione_id nel provider
//      → aggiornare header con nodo_nome
//      → mostrare messaggi tutor nel canvas
//
//    ERRORE 409 — sessione attiva con < 5 min inattività:
//      → response body: {sessione_id_esistente, messaggio}
//      → il frontend recupera la sessione esistente:
//        GET /sessione/{sessione_id_esistente} per verificare lo stato
//        poi continua con turni su quella sessione
//      → NON mostrare errore — riprendere silenziosamente
//
//    Nota: se la sessione attiva ha > 5 min di inattività,
//    il backend la auto-sospende e ne crea una nuova (nessun 409).
//    Se c'è una sessione sospesa, il backend la riprende automaticamente.
//
// 2. Quando lo studente invia un messaggio:
//    POST /sessione/{sessione_id}/turno con {messaggio} → SSE stream
//
// 3. "Termina sessione" (dal tools tray):
//    POST /sessione/{sessione_id}/termina → naviga a recap
//
// 4. AZIONE chiudi_sessione dal tutor (via SSE):
//    Il tutor può decidere di chiudere la sessione autonomamente.
//    Quando arriva azione tipo "chiudi_sessione":
//    → mostrare il riepilogo dal campo params.riepilogo
//    → dopo 3 secondi, navigare a recap
//    → oppure bottone "Vai al riepilogo"
```

**Recap post-sessione** (`recap_sessione_screen.dart`):
- Schermata fullscreen dopo la terminazione
- Mostra dati da `GET /sessione/{sessione_id}`: durata, nodi lavorati
- Mostra statistiche da `GET /utente/me/statistiche`: streak, esercizi
- Card con numeri grandi (stile gamification)
- Bottone "Torna alla home" → naviga a `/home/studio`

### 5.3 Tab Percorso

**Layout**:
```
┌──────────────────────────────────────────────────┐
│  Header: ● Matematica – Percorso Base  · •       │
│  🏅 Prossima Medaglia: Algebra · 2 temi          │
├──────────────────────────────────────────────────┤
│                                                  │
│         ◆ Numeri e operazioni  ✓                 │
│         │                                        │
│         ◆ Le Frazioni  ████▒▒ 6/8                │
│         │                                        │
│    ──── ● Equazioni 1° grado ────                │
│         │        SEI QUI                         │
│         │                                        │
│         ○ Proporzioni                            │
│         ╎                                        │
│         ░ ░ ░  (nebbia)                          │
│                                                  │
├──────────────────────────────────────────────────┤
│   Studio    │   Percorso    │   Profilo          │
└──────────────────────────────────────────────────┘
```

**Header percorso** (`percorso_header.dart`):
- Due righe: riga 1 = materia + nome percorso + dots (se multipli percorsi), riga 2 = prossimo traguardo
- I dots sono tappabili per switch percorso (se l'utente ha più percorsi)
- Dati da `GET /percorsi/` (lista percorsi)

**Sentiero** (`sentiero_widget.dart`):
- ListView verticale scrollabile
- All'apertura: auto-scroll al tema attuale (centrato nello schermo)
- Dati da `GET /temi/` (lista temi con progresso) + `GET /percorsi/{id}/mappa` (stato nodi)

**Tema card** (`tema_card.dart`):
Varianti visive in base allo stato:

| Stato | Visuale |
|---|---|
| **Completato** | Icona ✓, barra progresso piena, colori caldi stabili, opacità piena |
| **In corso** | Icona ◆, barra progresso parziale (N/M), colori vivaci |
| **Attuale (SEI QUI)** | Card più grande, bordo ambra, testo "ATTIVO", glow leggero (placeholder: bordo più spesso) |
| **Prossimo** | Icona ○, testo attenuato ma visibile, colori muted |
| **Futuro (nebbia)** | Opacità 0.3, nessun dettaglio, effetto sfumato |

- `GestureDetector` con `onTap` → apre bottom sheet dettaglio (per completati, in corso, attuale)
- I temi futuri oltre il prossimo non sono tappabili

**Connettori tra temi**: linea verticale tra le card, colore bordo (#3A3A42) per futuri, ambra per completati.

**Dettaglio tema — bottom sheet** (`tema_detail_sheet.dart`):
- Altezza ~55% schermo
- Contenuto: nome tema, barra progresso, lista nodi con stato, bottone "Studia questo"
- Dati da `GET /temi/{tema_id}` (dettaglio con nodi)
- Bottone "Studia questo" → naviga a Tab Studio (il backend sceglierà il nodo)
- Slide-up con spring animation

**Swipe tra percorsi**:
- `PageView` orizzontale con un sentiero per percorso
- Dots indicator nell'header sincronizzato con il PageView
- Se un solo percorso: niente PageView, niente dots

### 5.4 Tab Profilo

**Layout**: pagina scrollabile verticale con 6 sezioni. Tab bar sempre visibile.

**Sezione 1 — Identità** (`identita_section.dart`):
- Avatar centrato (placeholder: cerchio 80dp con iniziale del nome)
- Nome utente sotto
- "Su Dydat da N giorni" (calcolato da createdAt se disponibile, altrimenti "Benvenuto!")
- Dati da `GET /utente/me`

**Sezione 2 — Snapshot Oggi** (`snapshot_section.dart`):
- Riga con 3 metriche grandi:
  - 🔥 Streak (giorni)
  - ⏱ Minuti questa settimana
  - 📊 Nodi completati (totale)
- Font `gamification` (24sp bold)
- Dati da `GET /utente/me/statistiche`

**Sezione 3 — Achievement** (`achievement_section.dart`):
- 3 righe orizzontali scrollabili: Sigilli, Medaglie, Costellazioni
- Ogni achievement è un badge:
  - Sbloccato: icona colorata + nome sotto
  - Non sbloccato: sagoma grigia + "?" o nome attenuato
  - Mai vuoto — le sagome mostrano il potenziale
- Tap su badge → bottom sheet con dettaglio (nome, descrizione, progresso se bloccato)
- Dati da `GET /achievement/`

**Achievement badge** (`achievement_badge.dart` — widget riusabile):
```dart
// Props: id, nome, tipo (sigillo|medaglia|costellazione), sbloccato (bool),
//        progresso (corrente/richiesto, per bloccati)
// Sbloccato: Container con sfondo ambra/oro, icona, nome
// Bloccato: Container con sfondo grigio, sagoma, barra progresso mini
```

**Sezione 4 — Statistiche** (`statistiche_section.dart`):
- Griglia 2×2 di card compatte:
  - Card Tempo: minuti questa settimana, mini-barchart (7 barre con Container proporzionali per i giorni della settimana)
  - Card Progresso: nodi completati, barra progresso
  - Card Streak: streak corrente
  - Card Trend: esercizi corretti / svolti questa settimana (percentuale)
- Ogni card tappabile → espansione inline con dettagli (settimana/mese/sempre)
- Dati da `GET /utente/me/statistiche`

**Mini-barchart** (da costruire senza librerie di charting):
```dart
// 7 Container in una Row, altezza proporzionale ai minuti di studio
// Per il placeholder: usare dati mock se i dati per_giorno non sono disponibili
// Colore: ambra per giorni con obiettivo raggiunto, border per giorni sotto obiettivo
```

**Sezione 5 — Preferenze tutor** (`preferenze_tutor_section.dart`):
- 3 selettori inline (SegmentedButton o chip):
  - Velocità: "Vai al sodo" / "Spiegami bene" / "Lascia decidere"
  - Incoraggiamento: "Molto" / "Equilibrato" / "Fatti"
  - Input: "Testo" / "Voce" (voce = placeholder post-MVP, disabilitato)
- I valori da inviare al backend sono stringhe:
  - velocita: `"vai_al_sodo"` | `"spiegami_bene"` | `"lascia_decidere"`
  - incoraggiamento: `"molto"` | `"equilibrato"` | `"fatti"`
  - input: `"testo"` | `"voce"` | `"automatica"`
- Salvataggio con `PUT /utente/me/preferenze` al cambio (debounce 500ms)

**Sezione 6 — Impostazioni** (`impostazioni_section.dart`):
- Lista di voci raggruppate, ognuna naviga a sotto-schermata:

| Gruppo | Voci | Stato |
|---|---|---|
| Account | Email (read-only), Logout | Funzionante |
| Studio | Obiettivo giornaliero (slider minuti) | `PUT /utente/me/preferenze` |
| Accessibilità | **Tema (Chiaro / Scuro / Sistema)**, dimensione testo | ThemeProvider |
| Info | Versione app, supporto (link), termini (link), privacy policy (link) | Statico |
| Prossimamente | Materie attive, Promemoria, Memoria tutor, Esporta dati, Elimina account | **POST-MVP — mostrare come voci disabilitate con label "Prossimamente"** |

- Il toggle **Tema** è il punto di switch dark/light. Usa il `ThemeProvider` per cambiare `ThemeMode`.
- Le voci "Prossimamente" sono visibili ma grigie e non tappabili. Non collegare a endpoint inesistenti.

---

## 6. Bottom Navigation

### Implementazione

Usare `NavigationBar` (Material 3) dentro una `ShellRoute` di GoRouter.

```dart
// 3 tab
// Index 0: Studio (icona: Icons.school_outlined / Icons.school)
// Index 1: Percorso (icona: Icons.route_outlined / Icons.route)
// Index 2: Profilo (icona: Icons.person_outlined / Icons.person)
```

### Comportamento

- **Sempre visibile** nei tab Percorso e Profilo
- **Si nasconde durante studio attivo** nel Tab Studio: quando una sessione è in corso e l'utente scorre il canvas. Riappare con swipe verso il basso dalla zona bassa dello schermo.
- Stile: sfondo surface elevata, icona selezionata ambra, non selezionata textSecondary

---

## 7. Integrazione API — Contratti

### Endpoint che il frontend chiama

Tutti gli endpoint usano `Content-Type: application/json`. I messaggi di errore sono in italiano e possono essere mostrati direttamente all'utente.

#### Health
```
GET /health
  → 200: {status: "ok"}
```

#### Auth
```
POST /auth/registrazione
  Body: {email, password, nome, utente_temp_id?}
  → 201: {access_token, token_type: "bearer"}
  Errori: 409 "Email gia' registrata"
          404 "Utente temporaneo non trovato" (con utente_temp_id)
          400 "Utente gia' registrato" (con utente_temp_id)

POST /auth/login
  Body: {email, password}
  → 200: {access_token, token_type: "bearer"}
  Errori: 401 "Credenziali non valide"
```

#### Utente (auth richiesta)
```
GET /utente/me
  → 200: {id, email, nome, preferenze_tutor, contesto_personale,
          materie_attive, obiettivo_giornaliero_min}

PUT /utente/me/preferenze
  Body: {input?, velocita?, incoraggiamento?}
  → 200: (stesso formato di GET /utente/me)
  Errori: 400 campo non ammesso

GET /utente/me/statistiche
  → 200: {
    streak, nodi_completati, sessioni_completate,
    settimana: {minuti_studio, esercizi_svolti, esercizi_corretti,
                nodi_completati, giorni_attivi},
    mese: {stessa struttura},
    sempre: {stessa struttura}
  }
```

#### Onboarding (senza auth)
```
POST /onboarding/inizia
  Body: (vuoto)
  → SSE stream
    primo evento: onboarding_iniziato {utente_temp_id, sessione_id}
    poi: text_delta (N volte)
    poi: turno_completo {turno_id, nodo_focale: null}

POST /onboarding/turno
  Body: {sessione_id, messaggio}
  → SSE stream (text_delta + turno_completo)
  Errori: 404 "Sessione non trovata"
          400 "Non è una sessione onboarding"
          400 "Sessione onboarding non attiva"

POST /onboarding/completa
  Body: {sessione_id, contesto_personale?, preferenze_tutor?}
  → 200: {percorso_id, nodo_iniziale, nodi_inizializzati}
```

#### Sessione (auth richiesta)
```
POST /sessione/inizia
  Body: {tipo?: "media", durata_prevista_min?}
  → SSE stream
    primo evento: sessione_creata {sessione_id, nodo_id, nodo_nome}
    poi: text_delta (N volte)
    poi: azione (0-N volte)
    poi: turno_completo {turno_id, nodo_focale}
  Errori: 409 {sessione_id_esistente, messaggio}
          se sessione attiva con < 5min inattività

POST /sessione/{sessione_id}/turno
  Body: {messaggio}
  → SSE stream (text_delta + azione + achievement + turno_completo)
  Errori: 404 "Sessione non trovata"
          400 "Sessione non attiva"

POST /sessione/{sessione_id}/sospendi
  → 200: {id, stato: "sospesa", tipo, nodo_focale_id, nodo_focale_nome,
           attivita_corrente, durata_prevista_min, durata_effettiva_min,
           nodi_lavorati}

POST /sessione/{sessione_id}/termina
  → 200: (stesso formato di sospendi con stato: "completata")

GET /sessione/{sessione_id}
  → 200: {id, stato, tipo, nodo_focale_id, nodo_focale_nome,
           attivita_corrente, durata_prevista_min, durata_effettiva_min,
           nodi_lavorati}
```

#### Percorsi (auth richiesta)
```
GET /percorsi/
  → 200: [{id, tipo, materia, nome, stato, nodo_iniziale_override, created_at}]

GET /percorsi/{percorso_id}/mappa
  → 200: {percorso_id, materia, nodo_iniziale_override,
           nodi: [{id, nome, tipo, tema_id, livello, presunto,
                   spiegazione_data, esercizi_completati}]}
```

#### Temi (auth richiesta)
```
GET /temi/
  → 200: [{id, nome, materia, descrizione, nodi_totali,
            nodi_completati, completato}]

GET /temi/{tema_id}
  → 200: {id, nome, materia, descrizione, nodi_totali,
           nodi_completati, completato,
           nodi: [{id, nome, tipo, livello, presunto,
                   spiegazione_data, esercizi_completati}]}
```

#### Achievement (auth richiesta)
```
GET /achievement/
  → 200: {
    sbloccati: [{id, nome, tipo, descrizione, sbloccato_at}],
    prossimi: [{id, nome, tipo, descrizione,
                condizione: {tipo, valore},
                progresso: {corrente, richiesto}}]
  }
```

### Gestione SSE — PLACEHOLDER

Gli endpoint SSE (`/onboarding/inizia`, `/onboarding/turno`, `/sessione/inizia`, `/sessione/{id}/turno`) ritornano `text/event-stream`.

**Tipi di eventi SSE** (enum per il frontend):

```dart
// sse_events.dart

/// Tutti gli eventi SSE che il backend può emettere.
/// Claude Code implementerà il parsing completo.
enum SseEventType {
  onboardingIniziato,  // {utente_temp_id, sessione_id}
  sessioneCreata,      // {sessione_id, nodo_id, nodo_nome}
  textDelta,           // {testo: "frammento di testo"}  ⚠️ campo "testo", non "delta"
  azione,              // {tipo: "...", params: {...}}
  achievement,         // {id, nome, tipo}
  turnoCompleto,       // {turno_id, nodo_focale}
  errore,              // {codice, messaggio}
}

/// Tipi di azione che il tutor può invocare via SSE.
enum AzioneTutor {
  proponiEsercizio,    // params: {esercizio_id, testo, difficolta, nodo_id}
                       //   oppure {nodo_id, nessun_esercizio_disponibile: true}
  mostraFormula,       // params: {latex, etichetta?}
  suggerisciBacktrack, // params: {nodo_id, motivo}
  chiudiSessione,      // params: {riepilogo, prossimi_passi?}
}

/// Ordine tipico degli eventi in un turno:
/// 1. [sessione_creata | onboarding_iniziato]  — solo primo turno
/// 2. text_delta (N volte)                     — testo streaming
/// 3. azione (0-N volte)                       — azioni fire-and-forget
/// 4. achievement (0-N volte)                  — achievement sbloccati
/// 5. turno_completo                           — fine turno
///
/// In caso di errore: solo evento "errore" → stream terminato
```

Per il placeholder di Rocket.new:

```dart
// sse_client.dart — PLACEHOLDER
// Claude Code implementerà il vero client SSE.
//
// Per ora: fare la POST con Dio, ignorare lo stream,
// e mostrare un indicatore di caricamento.
// Dopo 2 secondi simulati, mostrare un messaggio placeholder.
//
// ⚠️ ATTENZIONE per Claude Code:
// Il campo nel payload text_delta è "testo", NON "delta".
// Esempio: {"testo": "Ciao! Oggi parliamo di..."}
//
// L'evento "achievement" può arrivare 0-N volte PRIMA di turno_completo.
// Il nodo_focale in turno_completo può cambiare dopo una promozione.

class SseClient {
  // TODO: Claude Code implementerà con http package o dart:html EventSource
  // Stream SSE da parsare:
  //   event: text_delta\ndata: {"testo": "..."}\n\n
  //   event: azione\ndata: {"tipo": "proponi_esercizio", "params": {...}}\n\n
  //   event: achievement\ndata: {"id": "primo_nodo", "nome": "Primo passo!", "tipo": "sigillo"}\n\n
  //   event: turno_completo\ndata: {"turno_id": 5, "nodo_focale": "..."}\n\n
}
```

---

## 8. Modelli dati (models/)

Ogni modello corrisponde a una response API. Usare `fromJson` factory constructor.

```dart
// utente.dart
class Utente {
  final String id;              // UUID come stringa
  final String? email;          // null per utenti temporanei
  final String? nome;
  final Map<String, dynamic>? preferenzeTutor;
  final Map<String, dynamic>? contestoPersonale;
  final List<String>? materieAttive;
  final int obiettivo_giornaliero_min;  // default 20
}

// sessione.dart
class Sessione {
  final String id;              // UUID come stringa
  final String stato;           // "attiva" | "sospesa" | "completata"
  final String? tipo;           // "media" | "onboarding"
  final String? nodoFocaleId;
  final String? nodoFocaleNome;
  final String? attivitaCorrente; // "spiegazione" | "esercizio" | "feynman" | "ripasso_sr"
  final int? durataPrevista;
  final int? durataEffettiva;
  final List<String>? nodiLavorati;
}

// percorso.dart
class Percorso {
  final int id;
  final String tipo;            // "binario_1"
  final String materia;
  final String? nome;
  final String stato;           // "attivo"
  final String? nodoInizialeOverride;
  final String? createdAt;      // ISO 8601
}

// nodo.dart
class NodoMappa {
  final String id;
  final String nome;
  final String tipo;            // "standard"
  final String? temaId;
  final String livello;         // "non_iniziato" | "in_corso" | "operativo" | "comprensivo" | "connesso"
  final bool presunto;          // true se skip da onboarding
  final bool spiegazioneData;
  final int eserciziCompletati;
}

// tema.dart
class Tema {
  final String id;
  final String nome;
  final String materia;
  final String? descrizione;
  final int nodiTotali;
  final int nodiCompletati;
  final bool completato;        // true se nodiCompletati >= nodiTotali
  final List<NodoMappa>? nodi;  // presente solo in GET /temi/{id}
}

// achievement.dart
class Achievement {
  final String id;
  final String nome;
  final String tipo;            // "sigillo" | "medaglia" | "costellazione"
  final String? descrizione;
  final String? sbloccatoAt;    // ISO 8601 (solo per sbloccati)
  final Map<String, dynamic>? condizione;  // {tipo, valore} (solo per prossimi)
  final Map<String, int>? progresso;       // {corrente, richiesto} (solo per prossimi)
}

// statistiche.dart
class Statistiche {
  final int streak;
  final int nodiCompletati;
  final int sessioniCompletate;
  final PeriodoStats settimana;
  final PeriodoStats mese;
  final PeriodoStats sempre;
}

class PeriodoStats {
  final int minutiStudio;
  final int eserciziSvolti;
  final int eserciziCorretti;
  final int nodiCompletati;
  final int giorniAttivi;
}
```

---

## 9. Comportamenti specifici

### App lifecycle

- **App in background durante sessione**: chiamare `POST /sessione/{id}/sospendi`
- **App ritorna in foreground**: chiamare `POST /sessione/inizia` (il backend riprende automaticamente la sessione sospesa, stesso sessione_id)
- Usare `WidgetsBindingObserver.didChangeAppLifecycleState`
- **Gestire il 409**: se l'utente esce e rientra in < 5 min senza che la sospensione sia andata a buon fine, `/sessione/inizia` ritorna 409. Usare il `sessione_id_esistente` dalla response per riprendere.

### Error handling globale

```dart
// Gestione errori per tipo di status code:
//
// 401 → cancella JWT, redirect a /login
//
// 409 su /sessione/inizia → gestione speciale:
//   parsare {sessione_id_esistente, messaggio}
//   riprendere la sessione esistente
//
// 400/404 → mostrare messaggio italiano dal backend in SnackBar
//   I messaggi sono già in italiano e user-friendly
//
// timeout → "La connessione è lenta. Riprova."
//
// Nessuna connessione → banner "Sei offline" persistente in alto
//
// Errore SSE (evento "errore") → mostrare messaggio in SnackBar
//   codici: "context_error" | "llm_error"
```

### Pull-to-refresh

- Tab Percorso: pull-to-refresh ricarica `GET /temi/` e `GET /percorsi/{id}/mappa`
- Tab Profilo: pull-to-refresh ricarica `GET /utente/me/statistiche` e `GET /achievement/`
- Tab Studio: nessun pull-to-refresh (la sessione è live)

### Empty states

- Nessun percorso → "Completa l'onboarding per iniziare" + bottone
- Nessun achievement → la bacheca mostra tutte le sagome grigie (mai vuota, piena di potenziale)
- Nessuna sessione completata → statistiche mostrano 0 con messaggio "Inizia la tua prima sessione"

---

## 10. Checklist finale per Rocket.new

Dopo aver costruito tutto, verificare:

- [ ] L'app si avvia senza errori
- [ ] Il tema dark e light funzionano entrambi, switch funzionante nelle impostazioni
- [ ] Nessun colore hardcoded — tutti da Theme.of(context) o design tokens
- [ ] Font Plus Jakarta Sans caricato correttamente
- [ ] Navigazione tra 3 tab funzionante
- [ ] Flusso onboarding → registrazione → home funzionante
- [ ] Flusso login → home funzionante
- [ ] Tutte le chiamate API REST (non SSE) funzionanti
- [ ] Tab Percorso mostra dati reali da API
- [ ] Tab Profilo mostra statistiche e achievement reali da API
- [ ] Tab Studio ha la struttura corretta con placeholder per SSE
- [ ] Mascotte placeholder posizionata correttamente con tap → tools tray
- [ ] Tools tray con 6 strumenti + "Parla col tutor" + "Termina sessione"
- [ ] Bottom sheet funzionanti (tools tray, dettaglio tema, dettaglio achievement)
- [ ] Card esercizio, formula e backtrack come placeholder nel canvas
- [ ] Preferenze tutor salvabili con valori corretti (vai_al_sodo, spiegami_bene, ecc.)
- [ ] Gestione errori con messaggi italiani dal backend
- [ ] Gestione errore 409 sessione (ripresa sessione esistente)
- [ ] JWT persistente tra sessioni
- [ ] App lifecycle: sospensione sessione in background
- [ ] Impostazioni: voci POST-MVP visibili ma disabilitate
- [ ] I placeholder per Claude Code sono chiaramente marcati con // TODO: Claude Code
- [ ] I modelli dati mappano correttamente le response API (vedi §8)

---

*Questo documento è il brief completo per Rocket.new. Contiene tutto ciò che serve per costruire l'app Flutter di Dydat: architettura, temi, schermate, API, modelli, comportamenti. Le parti marcate come PLACEHOLDER saranno completate da Claude Code in una fase successiva. Ogni scelta implementativa non coperta da questo brief deve seguire i principi della direzione visiva (dark mode first, ambra e grafite, giocoso ma adulto, canvas-first).*
