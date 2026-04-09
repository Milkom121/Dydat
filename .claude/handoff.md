STATUS: CONTINUE
PHASE: 10
BLOCK: B39.7.3
SUMMARY: B39.7.2 completato - Libreria audio + permessi mic. Package record ^5.1.2. AudioRecorderService astratto + RealAudioRecorderService (AAC-LC, 44.1kHz, mono). Permessi Android/iOS. VoiceInputField con registra/ferma. 27 test (13 nuovi). 615 frontend verdi, analyze 0.
NEXT: B39.7.3 - UI stato registrazione
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: pubspec.yaml, AndroidManifest.xml, Info.plist, audio_recorder_service.dart (nuovo), voice_input_field.dart, b39_voice_input_field_test.dart
TESTS: PASS (615 frontend verdi, analyze 0)
VERIFICATION: 615 passed, 0 errors. Analyze pulito.

---

## Contesto dettagliato

### Cosa e stato fatto
- B39.7.2 completato: libreria audio + permessi mic
- 22/38 sub-blocchi B39 completati totali

### Servizio AudioRecorderService
- Path: frontend/lib/services/audio_recorder_service.dart
- Classe astratta + RealAudioRecorderService (record package, AAC-LC, 44.1kHz, mono, .m4a)
- DI pattern: VoiceInputField accetta recorderService opzionale

### Widget VoiceInputField aggiornato
- Nuovi params: onAudioRecorded, recorderService
- Flusso: tap mic -> permesso -> start -> stop -> onAudioRecorded(path)
- Durante registrazione: hint cambia, campo e invio disabilitati, icona stop rossa
- Gestione errori e permesso negato

### Permessi
- Android: RECORD_AUDIO in AndroidManifest.xml
- iOS: NSMicrophoneUsageDescription in Info.plist

### Prossimo: B39.7.3 - UI stato registrazione
- Wave animata, timer secondi, pulsante stop pulsante, sfondo diverso

### File da leggere
1. CLAUDE.md -> PROJECT_CONFIG.md -> ROADMAP.md -> handoff.md
2. frontend/lib/widgets/voice_input_field.dart
3. frontend/lib/services/audio_recorder_service.dart
