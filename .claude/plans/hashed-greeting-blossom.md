# Piano B14-bis Sessione B — Widget Onboarding Adattivo (Frontend)

## Contesto

Il backend (Sessione A, già committata) manda ora eventi SSE `azione` con `tipo: "onboarding_domanda"` durante l'onboarding. Il frontend li ignora (riga 176 di `onboarding_provider.dart`: `case AzioneEvent(): break;`). Dobbiamo parsarli e renderizzarli come widget interattivi: card a scelta, campo testo, scala numerica.

## Flusso Target

1. Tutor streamma testo (text_delta) → bubble nel chat
2. Backend manda `azione` con `onboarding_domanda` → provider salva `currentQuestion`
3. `turno_completo` → streaming finisce → UI mostra widget domanda in basso
4. Utente interagisce (tap card / scrivi testo / tap numero) → risposta inviata → widget sparisce → tutor risponde

## Step di Implementazione

### Step 1 — Modello `OnboardingDomandaAction` in `sse_events.dart`
- Aggiungere classe `OnboardingDomandaAction` con `fromParams` (snake_case → camelCase)
- Campi: `tipoInput`, `domanda`, `opzioni`, `placeholder`, `scalaMin`, `scalaMax`, `scalaLabels`
- Aggiungere accessor `asOnboardingDomanda` su `AzioneEvent`

### Step 2 — Stato `currentQuestion` in `onboarding_provider.dart`
- Aggiungere `OnboardingDomandaAction? currentQuestion` allo state
- Aggiornare `copyWith` con `clearQuestion` flag
- In `_handleSseEvent`, parsare `AzioneEvent` → settare `currentQuestion`
- Aggiungere metodo `answerQuestion(String)` (clear question + sendMessage)
- Aggiungere `clearQuestion: true` in `startOnboarding` e `sendMessage`

### Step 3 — 3 Widget domanda (nuovi file in `onboarding_screen/widgets/`)
Seguono pattern card esistenti (4.w padding, surface bg, 2px border 0.3 alpha, borderRadius 12, HapticFeedback):

- **`scelta_singola_widget.dart`** — Lista verticale di card tappabili, tap = invio immediato
- **`testo_libero_widget.dart`** — StatefulWidget con TextField + bottone "Invia", placeholder opzionale
- **`scala_widget.dart`** — Riga di bottoni numerati (1-5 o 1-10), labels min/max opzionali, tap = invio

### Step 4 — Refactor `onboarding_screen.dart`
- Estrarre input attuale in `_buildDefaultTextInput()`
- Nuovo `_buildBottomArea()` che switcha: streaming → nulla, question → widget appropriato, default → text input
- Aggiungere `_answerQuestion(String)` che aggiunge bubble utente + chiama provider
- Mutua esclusione: se `showCompleteButton` → bottone completa, altrimenti → bottom area

### Step 5 — Test
- Test modello in `test/models/sse_events_test.dart`: parse scelta_singola, testo_libero, scala, campi opzionali, accessor null per tipo diverso
- Test provider in `test/providers/onboarding_provider_test.dart`: currentQuestion iniziale null, copyWith, clearQuestion, clear()

## File Coinvolti

| File | Azione |
|------|--------|
| `frontend/lib/models/sse_events.dart` | MODIFICA — classe + accessor |
| `frontend/lib/providers/onboarding_provider.dart` | MODIFICA — state + handler + metodo |
| `frontend/lib/presentation/onboarding_screen/onboarding_screen.dart` | MODIFICA — bottom area dinamica |
| `frontend/lib/presentation/onboarding_screen/widgets/scelta_singola_widget.dart` | NUOVO |
| `frontend/lib/presentation/onboarding_screen/widgets/testo_libero_widget.dart` | NUOVO |
| `frontend/lib/presentation/onboarding_screen/widgets/scala_widget.dart` | NUOVO |
| `frontend/test/models/sse_events_test.dart` | MODIFICA — test nuovi |
| `frontend/test/providers/onboarding_provider_test.dart` | MODIFICA — test nuovi |

## Ordine Esecuzione

1. `sse_events.dart` → `flutter analyze`
2. Test modello → run
3. `onboarding_provider.dart` → `flutter analyze`
4. Test provider → run
5. 3 widget files (parallelo)
6. `onboarding_screen.dart` → `flutter analyze`
7. Tutti i test → green

## Verifica Finale

- `flutter analyze` → 0 errori
- Tutti i test → green
- Backend NON toccato
- Nessun colore hardcoded, tutto via Theme.of(context)
