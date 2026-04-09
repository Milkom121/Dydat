STATUS: CONTINUE
PHASE: 10
BLOCK: B39.8.3
SUMMARY: B39.8.2 completato. Riscritta onboarding_screen.dart con VoiceInputField al posto del TextField custom. Bottone Salta per ora sempre visibile nella top bar accanto all etichetta fase. Etichette fase italiane per ogni OnboardingFase. Bottone completa appare solo in fase conclusione. Skip naviga a /registration o /login. testo_libero usa VoiceInputField. 15 nuovi test. 677 frontend verdi, analyze 0.
NEXT: B39.8.3 - System prompt tutor onboarding riscritto
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: onboarding_screen.dart, b39_8_2_onboarding_screen_test.dart (nuovo)
TESTS: PASS (677 frontend verdi, analyze 0)
VERIFICATION: 677 passed, 0 errors. Analyze pulito.

---

## Contesto dettagliato

### Cosa e stato fatto (B39.8.2)
- 28/38 sub-blocchi B39 completati totali

### Modifiche a onboarding_screen.dart
- Path: frontend/lib/presentation/onboarding_screen/onboarding_screen.dart
- Rimosso _messageController e _messageFocusNode (gestiti da VoiceInputField)
- Aggiunto GlobalKey VoiceInputFieldState _voiceInputKey
- Nuova _buildTopBar(): barra progresso + etichetta fase + bottone Salta per ora
- Nuova _buildVoiceInput(): wrappa VoiceInputField con hint Scrivi o parla e onTranscriptionError snackbar
- _buildBottomArea(): scelta_singola -> SceltaSingolaWidget, scala -> ScalaWidget, tutto il resto -> VoiceInputField
- showCompleteButton usa faseCorrente == OnboardingFase.conclusione
- _skipOnboarding(): chiama provider.skipOnboarding(), naviga a /registration o /login
- _faseLabel(): mappa enum -> etichette italiane

### Test 15 nuovi (b39_8_2_onboarding_screen_test.dart)
- Mock service con StreamController per simulare eventi SSE
- Copertura: rendering base, skip, fasi, interazione, errore, domande strutturate, etichette fase

### Prossimo: B39.8.3 - System prompt tutor onboarding riscritto
- File da creare: backend/app/llm/prompts/onboarding_system_prompt.py
- Integrare nel flusso del turno onboarding
- Unit test presenza istruzioni chiave

### File da leggere
1. CLAUDE.md, PROJECT_CONFIG.md, ROADMAP.md, handoff.md
2. docs/discussions/b39-onboarding-narrativo.md
3. backend/app/llm/prompts/onboarding_extractor.py
4. backend/app/core/onboarding.py
5. backend/app/core/turno.py
