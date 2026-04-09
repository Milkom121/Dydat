STATUS: CONTINUE
PHASE: 10
BLOCK: B39.5.1
SUMMARY: B39.4.3 completato - Pulizia codice onboarding legacy. Rimosso TURNI_CONOSCENZA_MAX (non piu usato, il decisore forma C usa TETTO_TURNI_NARRATIVI). Rimosso AzioneDecisore.passa_a_placement (mai generato dal decisore). Aggiornate docstring modulo e aggiorna_fase_onboarding per riflettere il flusso attuale. 540 backend verdi, 10 skipped. Fase 4 chiusa al 100%.
NEXT: B39.5.1 - Configurazione OPENAI_API_KEY per Whisper
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/app/core/onboarding.py, backend/app/schemas/onboarding.py, backend/tests/test_onboarding.py
TESTS: PASS (540 backend verdi, 10 skipped)
VERIFICATION: 540 passed, 10 skipped. Ruff pulito. Fase 4 del piano B39 completata (ONB-01 e ONB-02 fixati, codice legacy rimosso).

---

## Contesto dettagliato

### Cosa e stato fatto
- Fase 4 di B39 completata: B39.4.1 (fix ONB-01 scrittura profilo), B39.4.2 (fix ONB-02 persistenza streaming con tool use), B39.4.3 (pulizia codice legacy)
- 12 sub-blocchi su 38 completati: Fase 1 (3/3), Fase 2 (4/4), Fase 3 (2/2), Fase 4 (3/3)
- Prossima fase: Fase 5 — Motore voce Whisper (3 sub-blocchi: B39.5.1, B39.5.2, B39.5.3)

### Stato del progetto
- Backend: 540 test verdi, 10 skipped
- Frontend: 588 test verdi (non toccato in Fase 4), analyze 0
- Ruff pulito
- Branch: develop (pushato)

### Prossimo passo concreto
- B39.5.1 - Configurazione OPENAI_API_KEY per il futuro endpoint /stt/transcribe (Whisper)
- Aggiungere la chiave al backend config, .env.example, docker-compose.yml, validate_secrets_for_startup
- Registrare la nuova dipendenza esterna in docs/dev-shortcuts.md
- Specs complete in ROADMAP.md alla voce B39.5.1

### File da leggere per la prossima sessione
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md (cerca B39.5.1)
4. .claude/handoff.md (questo file)
5. backend/app/config.py (dove aggiungere la chiave + validazione)
6. backend/.env.example (aggiornare con la nuova variabile)
7. backend/docker-compose.yml (passare la variabile al container)
