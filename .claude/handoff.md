STATUS: CONTINUE
PHASE: 10
BLOCK: B39.6.1
SUMMARY: B39.5.3 completato - Test di integrazione endpoint STT con audio reale. 3 smoke test integration (tono WAV 440Hz, silenzio WAV, formato MP3 header) + 1 test helper sempre attivo. WAV generati programmaticamente con modulo wave. Skip automatico senza OPENAI_API_KEY o senza --run-integration. 569 backend verdi, 13 skipped.
NEXT: B39.6.1 - Prompt auto-valutazione placement
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/tests/test_b39_5_3_stt_integration.py (nuovo)
TESTS: PASS (569 backend verdi, 13 skipped)
VERIFICATION: 569 passed, 13 skipped. File di test ruff-pulito. Tutti i test preesistenti continuano a passare.

---

## Contesto dettagliato

### Cosa e stato fatto
- B39.5.1 completato (commit a327233): OPENAI_API_KEY configurata
- B39.5.2 completato (commit 8b383be): endpoint POST /stt/transcribe
- B39.5.3 completato: 3 smoke test integration + 1 helper test
- Fase 5 STT completata (3/3 sub-blocchi)
- 15/38 sub-blocchi B39 completati: Fase 1 (3/3), Fase 2 (4/4), Fase 3 (2/2), Fase 4 (3/3), Fase 5 (3/3)
- Prossimo: B39.6.1 (primo sub-blocco di Fase 6 - Placement)

### Stato del progetto
- Backend: 569 test verdi, 13 skipped
- Frontend: 588 test verdi (non toccato), analyze 0
- Branch: develop (pushato)

### Prossimo passo concreto
- B39.6.1 - Prompt auto-valutazione placement
- Nuovo file: backend/app/llm/prompts/onboarding_self_assessment.py
- Il prompt istruisce il tutor a chiedere per ogni area chiave della materia se utente si sente forte/incerto/digiuno
- Gate: unit test presenza istruzioni chiave, aree selezionate dal grafo curriculum
- Riferimento strategico: docs/discussions/b39-onboarding-narrativo.md per contesto decisioni placement

### File da leggere per la prossima sessione
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md (cerca B39.6.1)
4. .claude/handoff.md (questo file)
5. docs/discussions/b39-onboarding-narrativo.md (decisioni placement)
6. backend/app/llm/prompts/onboarding_extractor.py (riferimento per stile prompt)
7. backend/app/grafo/struttura.py (per capire come esporre aree dal grafo)
