STATUS: CONTINUE
PHASE: 10
BLOCK: B39.8.2
SUMMARY: B39.8.1 completato. OnboardingProvider aggiornato per gestire le nuove fasi onboarding narrativo (accoglienza/conoscenza/placement/piano/conclusione), skip/resume, evento decisione_onboarding dal backend. Nuovo DecisioneOnboardingEvent in sse_events.dart con switch aggiornati in session_provider e onboarding_provider. OnboardingFase enum. Progresso calcolato per fase (non piu per turni). MockOnboardingService per test con stream controllati. 25 nuovi test (37 totale file). 662 frontend verdi, analyze 0.
NEXT: B39.8.2 - Riscrittura onboarding_screen.dart con VoiceInputField + skip
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: sse_events.dart, onboarding_provider.dart, session_provider.dart, onboarding_provider_test.dart
TESTS: PASS (662 frontend verdi, analyze 0)
VERIFICATION: 662 passed, 0 errors. Analyze pulito.

---

## Contesto dettagliato

### Cosa e stato fatto (B39.8.1)
- 27/38 sub-blocchi B39 completati totali

### DecisioneOnboardingEvent - nuovo evento SSE
- Path: frontend/lib/models/sse_events.dart
- Campi: azione, campoDaChiedere, motivo, faseCorrente, campiCompleti
- Aggiunto al parser SseEvent.fromRawEvent (tipo decisione_onboarding)
- Switch aggiornato in session_provider.dart (ignorato, non rilevante per sessione)

### OnboardingFase enum
- Path: frontend/lib/providers/onboarding_provider.dart
- 5 valori: accoglienza, conoscenza, placement, piano, conclusione
- Helper onboardingFaseFromString con fallback a accoglienza

### OnboardingScreenState - nuovi campi
- faseCorrente (OnboardingFase): fase backend, default accoglienza
- campiCompleti (int): 0-5, campi profilo con confidenza alta/media
- isSkipped (bool): utente ha saltato onboarding
- ultimaAzioneDecisore (String?): ultima azione del decisore forma C
- progress: ricalcolato per fase (accoglienza=0, conoscenza=0.1-0.4, placement=0.5, piano=0.7, conclusione=0.9, completato=1.0)
- copyWith: aggiunto clearUltimaAzione

### OnboardingNotifier - nuovi metodi
- skipOnboarding(): cancella subscription, isSkipped=true
- resumeOnboarding(): se sessione esiste ripristina isSkipped=false, altrimenti startOnboarding
- _handleSseEvent gestisce DecisioneOnboardingEvent (aggiorna fase, campi, azione)
- startOnboarding resetta tutti i nuovi campi

### Test - 25 nuovi (37 totale file)
- MockOnboardingService con StreamController per simulare eventi SSE
- Copertura: stato iniziale, faseFromString, progress per fase, copyWith, DecisioneOnboardingEvent fromJson, flusso SSE completo, skip/resume, errore, forza_chiusura

### Prossimo: B39.8.2 - Riscrittura onboarding_screen.dart con VoiceInputField + skip
- La schermata onboarding deve usare VoiceInputField come campo input
- Bottone Salta per ora visibile fin dalla prima schermata
- UI deve reagire a faseCorrente per mostrare progresso
- Widget test nuovo flusso, test skip, rendering corretto

### File da leggere
1. CLAUDE.md -> PROJECT_CONFIG.md -> ROADMAP.md -> handoff.md
2. frontend/lib/presentation/onboarding_screen/onboarding_screen.dart
3. frontend/lib/providers/onboarding_provider.dart (appena aggiornato)
4. frontend/lib/widgets/voice_input_field.dart
