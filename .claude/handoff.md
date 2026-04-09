STATUS: CONTINUE
PHASE: 10
BLOCK: B39.8.1
SUMMARY: B39.7.4+B39.7.5+B39.7.6 completati in un'unica sessione. Nuovo SttService (astratto + RealSttService) con POST multipart /stt/transcribe e mapping errori Dio user-friendly. RecordingState.transcribing aggiunto. VoiceInputField: spinner + "Trascrizione in corso..." durante upload, testo trascritto popola campo modificabile (NO auto-invio), errori gestiti con onTranscriptionError callback. ApiConfig.sttTranscribe. 11 nuovi test (49 totale file). 637 frontend verdi, analyze 0.
NEXT: B39.8.1 - Aggiorna onboarding_provider.dart
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: stt_service.dart (nuovo), voice_input_field.dart, audio_recorder_service.dart, api_config.dart, b39_voice_input_field_test.dart
TESTS: PASS (637 frontend verdi, analyze 0)
VERIFICATION: 637 passed, 0 errors. Analyze pulito.

---

## Contesto dettagliato

### Cosa e stato fatto
- B39.7.4 completato: chiamata endpoint STT con spinner
- B39.7.5 completato: testo trascritto popola campo input modificabile
- B39.7.6 completato: gestione errori STT con fallback a scrittura manuale
- 26/38 sub-blocchi B39 completati totali

### SttService — nuovo servizio
- Path: frontend/lib/services/stt_service.dart
- SttService (astratto) + RealSttService (implementazione reale con DioClient)
- SttResult (testo), SttException (message, statusCode)
- POST multipart /stt/transcribe con MultipartFile.fromFile
- _mapDioError: 400 formato, 422 nessun parlato, 429 rate limit, 502/503 servizio down, timeout, rete
- receiveTimeout 30s per la trascrizione

### VoiceInputField — integrazione STT
- Nuovi parametri: sttService (iniettabile), onTranscriptionError (callback errori)
- RecordingState.transcribing: terzo stato dopo idle e recording
- Flusso: stop -> onAudioRecorded -> transcribing -> _transcribeAudio -> popola controller -> idle
- _buildTranscribingIndicator: Container con CircularProgressIndicator + "Trascrizione in corso..."
- Pulsante mic e invio disabilitati durante trascrizione (isBusy)
- Semantics label "Trascrizione in corso" durante stato transcribing
- Errori: SttException -> onTranscriptionError, generico -> fallback message, sempre torna a idle
- Senza sttService: comportamento identico a prima (stopRecording -> idle)

### ApiConfig — nuovo endpoint
- ApiConfig.sttTranscribe = '/stt/transcribe'

### Test — 11 nuovi (49 totale file)
- MockSttService con completer per controllare timing
- Test: chiamata transcribe, spinner visibile, testo popola campo, invio/mic disabilitati, errore torna idle, senza sttService, semantics, onAudioRecorded prima di trascrizione, ciclo completo, stopPath null

### Prossimo: B39.8.1 - Aggiorna onboarding_provider.dart
- Il provider deve gestire le nuove fasi (conoscenza/auto-valutazione/verifica/chiusura)
- Gestire lo skip onboarding
- Passare dati reali al backend
- Unit test provider con nuove fasi

### File da leggere
1. CLAUDE.md -> PROJECT_CONFIG.md -> ROADMAP.md -> handoff.md
2. frontend/lib/providers/onboarding_provider.dart
3. backend/app/api/onboarding.py (endpoint turno con decisore)
4. backend/app/schemas/onboarding.py (schema response)
