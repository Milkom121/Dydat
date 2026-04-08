STATUS: CONTINUE
PHASE: 10
BLOCK: B39.3.2
SUMMARY: B39.3.1 completato — Rules-based decisor puro Python per forma C adattiva. Funzione decidi_prossima_mossa con enum AzioneDecisore e schema Decisione. 23 nuovi test su 10+ scenari. 511 backend verdi, 10 skipped.
NEXT: B39.3.2 — Integrazione decisore nell'endpoint /onboarding/turno
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/app/core/onboarding.py, backend/app/schemas/onboarding.py, backend/tests/test_b39_3_1_decisor.py
TESTS: PASS (511 backend verdi, 10 skipped)
VERIFICATION: 511 passed, 10 skipped. Ruff pulito. Funzione deterministica senza LLM, testabile con unit test fissi.

---

## Contesto dettagliato

### Cosa e stato fatto
- B39.3.1 chiuso con commit 643d271 — 87 righe aggiunte a `backend/app/core/onboarding.py`, 23 righe a `backend/app/schemas/onboarding.py`, 253 righe di test nuovi
- Funzione `decidi_prossima_mossa(profilo_stato, turni_fatti)` implementa la logica di forma C adattiva: chiedi campo mancante con priorita chi_e > motivo > stile_cognitivo > tempo_disponibile > vissuto_scolastico, oppure chiudi narrativa se tutti i 5 campi sono pieni con alta confidenza, oppure forza chiusura al tetto di 7 turni
- Enum `AzioneDecisore` con valori `chiedi_campo_mancante`, `chiudi_narrativa`, `forza_chiusura_tetto_turni`, `passa_a_placement`
- Schema Pydantic `Decisione` con azione, campo_da_chiedere (optional), motivo

### Stato del progetto
- Backend: 511 test verdi, 10 skipped
- Frontend: 588 test verdi (non toccato in questo blocco), analyze 0
- Ruff pulito
- Branch: develop (pushato)

### Prossimo passo concreto
- B39.3.2 — Integrazione decisore nell'endpoint `/onboarding/turno`
- Dopo ogni turno utente, chiamare l'estrattore di B39.2.3 per aggiornare il profilo, poi il decisore di B39.3.1 per determinare la prossima mossa
- La response dell'endpoint deve includere la fase corrente e l'azione decisa
- Specs complete in `ROADMAP.md` alla voce B39.3.2

### File da leggere per la prossima sessione
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md (cerca B39.3.2 — contiene tutte le specs del prossimo blocco)
4. .claude/handoff.md (questo file)
5. backend/app/api/onboarding.py (endpoint da modificare)
6. backend/app/core/onboarding.py (estrattore + decisore gia implementati)
7. docs/discussions/b39-onboarding-narrativo.md (solo come riferimento strategico se serve capire il quadro d'insieme)
