STATUS: CONTINUE
PHASE: 10
BLOCK: B39.8.4
SUMMARY: B39.8.3 completato. Creato ONBOARDING_SYSTEM_PROMPT dedicato in onboarding_system_prompt.py con 7 sezioni: chi sei (personificato prima persona), patto esplicito (6 punti), forma C adattiva (turno libero + domande mirate), 5 campi profilo (senza nominarli), regole tono/formato (brevita, tu informale), tool use, cosa non fare mai. Integrato in contesto.py: _blocco_system_prompt(tipo_sessione) seleziona prompt onboarding vs studio; modello Opus (LLM_MODEL_ONBOARDING) per sessioni onboarding. 21 nuovi test. 758 backend verdi (13 skipped), ruff pulito.
NEXT: B39.8.4 - Test integrazione onboarding completo
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: onboarding_system_prompt.py (nuovo), contesto.py, test_b39_8_3_onboarding_system_prompt.py (nuovo)
TESTS: PASS (758 backend verdi, 13 skipped, ruff pulito)
VERIFICATION: 758 passed, 13 skipped. Ruff pulito sui file toccati. Analyze frontend 0.

---

## Contesto dettagliato

### Cosa e stato fatto (B39.8.3)
- 29/38 sub-blocchi B39 completati totali

### Nuovo file: backend/app/llm/prompts/onboarding_system_prompt.py
- ONBOARDING_SYSTEM_PROMPT: costante stringa (~3500 chars)
- 7 sezioni: CHI SEI, IL PATTO ESPLICITO, COME CONDUCI LA CONVERSAZIONE, 5 CAMPI, REGOLE TONO, TOOL USE, COSA NON FARE MAI

### Modifiche a contesto.py
- _blocco_system_prompt(tipo_sessione) seleziona prompt onboarding vs studio
- Modello Opus per sessioni onboarding

### Test 21 nuovi
- 13 contenuto + 5 integrazione + 3 struttura

### Prossimo: B39.8.4
- Widget test flusso completo onboarding frontend
- Scenari: collaborativo, taciturno, skip
