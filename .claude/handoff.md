STATUS: CONTINUE
PHASE: 10
BLOCK: B39.7.4
SUMMARY: B39.7.3 completato - UI stato registrazione. Wave sinusoidale animata (CustomPainter con ampiezza da stream), timer mm:ss, pallino rosso pulsante, pulsante stop con animazione scale, sfondo errorContainer. amplitudeStream aggiunto ad AudioRecorderService (dBFS normalizzato 0-1). 11 nuovi test (38 totale). 626 frontend verdi, analyze 0.
NEXT: B39.7.4 - Chiamata endpoint /stt/transcribe
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: audio_recorder_service.dart, voice_input_field.dart, b39_voice_input_field_test.dart
TESTS: PASS (626 frontend verdi, analyze 0)
VERIFICATION: 626 passed, 0 errors. Analyze pulito.

---

## Contesto dettagliato

### Cosa e stato fatto
- B39.7.3 completato: UI stato registrazione con feedback visivo completo
- 23/38 sub-blocchi B39 completati totali

### AudioRecorderService - nuovo: amplitudeStream
- Path: frontend/lib/services/audio_recorder_service.dart
- Aggiunto Stream double get amplitudeStream all interfaccia astratta
- RealAudioRecorderService: _recorder.onAmplitudeChanged(100ms) -> normalizza dBFS (-60..0) in 0..1
- StreamSubscription cancellata su stop e dispose, StreamController broadcast chiuso su dispose

### VoiceInputField - UI registrazione
- TickerProviderStateMixin per 2 AnimationController (pulse 800ms + wave 1500ms)
- Durante registrazione: TextField sostituito da _buildRecordingIndicator (Container con sfondo errorContainer, bordo error)
- Contenuto indicatore: pallino rosso pulsante + timer mm:ss (tabularFigures) + wave CustomPaint
- _WavePainter: sinusoide con envelope (piu alta al centro), ampiezza 15%-100% proporzionale al volume, fase da waveController
- Pulsante stop: wrappato in Transform.scale con _pulseAnimation (1.0 -> 1.15)
- Timer: Timer.periodic(1s) incrementa _elapsedSeconds, resettato su stop
- Getter esposti per test: elapsedSeconds, currentAmplitude

### Prossimo: B39.7.4 - Chiamata endpoint /stt/transcribe
- Dopo stop registrazione, upload audio al backend POST /stt/transcribe
- Nuovo frontend/lib/services/stt_service.dart
- Spinner durante trascrizione
- Widget test con mock service

### File da leggere
1. CLAUDE.md -> PROJECT_CONFIG.md -> ROADMAP.md -> handoff.md
2. frontend/lib/widgets/voice_input_field.dart
3. frontend/lib/services/audio_recorder_service.dart
4. backend/app/api/stt.py (endpoint gia pronto da B39.5.2)
