STATUS: CONTINUE
PHASE: 10
BLOCK: B39.6.5
SUMMARY: B39.6.4 completato - Funzione genera_esercizi_verifica. Schema Pydantic EsercizioCompound + OpzioneEsercizio in schemas/onboarding.py. Funzione genera_esercizi_verifica(aree_da_verificare, nomi_concetti) in core/onboarding.py con singola chiamata LLM Opus, retry 1x su errore API/parsing, fallback lista vuota su errore inatteso. Helper _costruisci_coppie con scala adattiva: 1-2 aree singole, 3+ compound, cap 6 aree. 29 nuovi test. 689 backend verdi, 13 skipped.
NEXT: B39.6.5 - Logica grading deterministico
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/app/core/onboarding.py (genera_esercizi_verifica + _costruisci_coppie), backend/app/schemas/onboarding.py (EsercizioCompound + OpzioneEsercizio), backend/tests/test_b39_6_4_genera_esercizi.py (nuovo)
TESTS: PASS (689 backend verdi, 13 skipped)
VERIFICATION: 689 passed, 13 skipped. Ruff pulito. Tutti i test preesistenti continuano a passare.

---

## Contesto dettagliato

### Cosa e stato fatto
- B39.6.4 completato: funzione genera_esercizi_verifica
- Fase 6 Placement: 4/6 sub-blocchi completati (B39.6.1 + B39.6.2 + B39.6.3 + B39.6.4)
- 18/38 sub-blocchi B39 completati totali

### File modificati
- backend/app/schemas/onboarding.py:
  - Nuovo OpzioneEsercizio (lettera, testo)
  - Nuovo EsercizioCompound (testo, concetti, opzioni, risposta_corretta, spiegazione_breve)
  - Validatore: risposta_corretta deve essere tra le lettere delle opzioni
  - spiegazione_breve ha default stringa vuota (opzionale)

- backend/app/core/onboarding.py:
  - Import aggiunti: MAX_ESERCIZI_VERIFICA, build_exercise_prompt, parse_exercise_response, EsercizioCompound
  - Nuova funzione genera_esercizi_verifica(aree_da_verificare, nomi_concetti):
    - Costruisce coppie con _costruisci_coppie
    - Singola chiamata LLM con build_exercise_prompt
    - Parser con parse_exercise_response
    - Validazione Pydantic per ogni esercizio (scarta invalidi)
    - Retry 1x su errore API/parsing, no retry su errore inatteso
    - Cap finale a MAX_ESERCIZI_VERIFICA (3)
  - Nuova funzione _costruisci_coppie(aree):
    - 1-2 aree -> esercizi singoli [[a], [b]]
    - 3+ aree -> compound consecutivi [[a,b], [c,d], ...]
    - Cap a 6 aree (le prime 6, gia ordinate per fondazionalita da B39.6.2)

- backend/tests/test_b39_6_4_genera_esercizi.py (nuovo):
  - 5 test schema EsercizioCompound
  - 9 test _costruisci_coppie (scala adattiva + cap)
  - 15 test genera_esercizi_verifica (successo, retry, fallimenti, edge case)

### Relazione tra funzioni placement
- seleziona_aree_da_grafo (B39.6.1) -> sceglie i temi da presentare per auto-valutazione
- seleziona_aree_fondazionali (B39.6.2) -> filtra le aree forte per verifica compound
- build_exercise_prompt + parse_exercise_response (B39.6.3) -> prompt e parser
- genera_esercizi_verifica (B39.6.4) -> orchestratore che accoppia, chiama LLM, valida
- Prossimo: valuta_risposta (B39.6.5) -> grading deterministico

### Stato del progetto
- Backend: 689 test verdi, 13 skipped
- Frontend: 588 test verdi (non toccato), analyze 0
- Branch: develop

### Prossimo passo concreto
- B39.6.5 - Logica grading deterministico
- Funzione valuta_risposta(esercizio, risposta_utente) deterministica
- Confronto scelta utente con risposta corretta
- Ritorna bool + lista concetti retroceduti in caso di fail (entrambi i concetti -> incerto)
- Gate: unit test con risposte corrette e sbagliate, verifica retrocessione concetti

### File da leggere per la prossima sessione
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md (cerca B39.6.5)
4. .claude/handoff.md (questo file)
5. backend/app/schemas/onboarding.py (schema EsercizioCompound)
6. backend/app/core/onboarding.py (contesto funzioni placement)
7. docs/discussions/b39-onboarding-narrativo.md (Decisione 8 - regola fallimento)
