STATUS: CONTINUE
PHASE: 10
BLOCK: B39.4.1
SUMMARY: B39.3.2 completato - Integrazione decisore nell'endpoint /onboarding/turno. Dopo ogni turno utente in fase conoscenza, l'estrattore Opus aggiorna il profilo e il decisore rules-based decide la prossima mossa. Evento SSE decisione_onboarding emesso. 13 nuovi test, 2 aggiornati. 524 backend verdi, 10 skipped.
NEXT: B39.4.1 - Fix completa_onboarding scrittura profilo (ONB-01)
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/app/core/onboarding.py, backend/app/api/onboarding.py, backend/tests/test_b39_3_2_decisor_integration.py, backend/tests/test_onboarding.py
TESTS: PASS (524 backend verdi, 10 skipped)
VERIFICATION: 524 passed, 10 skipped. Ruff pulito sui file modificati.

---

## Contesto dettagliato

### Cosa e stato fatto
- Creata funzione elabora_decisione_onboarding(db, sessione) in core/onboarding.py
- Modificato aggiorna_fase_onboarding: rimossa auto-transizione conoscenza->placement (ora gestita dal decisore forma C)
- Modificato _genera_stream_onboarding in api/onboarding.py: decisore post-turno + evento SSE decisione_onboarding
- Evento SSE contiene: azione, campo_da_chiedere, motivo, fase_corrente, campi_completi (count 0-5)
- Gestione errori non bloccante: se estrazione o decisione falliscono, il turno resta completato
- Aggiornati 2 test esistenti in test_onboarding.py
- Creati 13 nuovi test in test_b39_3_2_decisor_integration.py

### Stato del progetto
- Backend: 524 test verdi, 10 skipped
- Frontend: 588 test verdi (non toccato), analyze 0
- Branch: develop

### Prossimo passo concreto
- B39.4.1 - Fix completa_onboarding scrittura profilo (ONB-01)
- completa_onboarding deve scrivere profilo_sintetizzato, contesto_personale, preferenze_tutor
- Il profilo estratto e disponibile in stato_orchestratore[profilo_estratto] grazie a B39.3.2

### File da leggere per la prossima sessione
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md (cerca B39.4.1)
4. .claude/handoff.md (questo file)
5. backend/app/core/onboarding.py (funzione completa_onboarding da modificare)
6. backend/app/api/onboarding.py (schema payload da aggiornare)
