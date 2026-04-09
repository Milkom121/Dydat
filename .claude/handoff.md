STATUS: CONTINUE
PHASE: 10
BLOCK: B39.6.3
SUMMARY: B39.6.2 completato - Logica selezione aree fondazionali. Funzione seleziona_aree_fondazionali(aree_forte, grafo) in onboarding_self_assessment.py. Fondazionalita = posizione media dei nodi del tema nell ordine topologico. Cap a MAX_AREE_FONDAZIONALI (6). Ignora nodi contesto, aree non presenti nel grafo. 21 nuovi test deterministici con grafi mockati (lineare + ramificato). 624 backend verdi, 13 skipped.
NEXT: B39.6.3 - Prompt generatore esercizi compound
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/app/llm/prompts/onboarding_self_assessment.py (esteso), backend/tests/test_b39_6_2_aree_fondazionali.py (nuovo)
TESTS: PASS (624 backend verdi, 13 skipped)
VERIFICATION: 624 passed, 13 skipped. File ruff-puliti. Tutti i test preesistenti continuano a passare.

---

## Contesto dettagliato

### Cosa e stato fatto
- B39.6.2 completato: logica selezione aree fondazionali
- Fase 6 Placement: 2/6 sub-blocchi completati (B39.6.1 + B39.6.2)
- 17/38 sub-blocchi B39 completati totali

### File modificati
- backend/app/llm/prompts/onboarding_self_assessment.py:
  - Aggiunto import networkx + ordinamento_topologico
  - Nuova costante MAX_AREE_FONDAZIONALI = 6
  - Nuova funzione seleziona_aree_fondazionali(aree_forte, grafo):
    - Calcola posizione media nodi per tema nell ordine topologico
    - Ordina temi per fondazionalita (posizione bassa = piu fondazionale)
    - Cappa a 6 risultati
    - Ignora nodi contesto, temi non presenti nel grafo, nodi senza tema_id
- backend/tests/test_b39_6_2_aree_fondazionali.py (nuovo):
  - 21 test deterministici con 2 grafi mockati (lineare 4 temi + ramificato 8 temi)
  - Copertura: edge case vuoti, ordinamento, cap, nodi contesto, duplicati, stabilita

### Relazione tra funzioni di assessment
- seleziona_aree_da_grafo (B39.6.1) -> sceglie i temi da presentare all utente per l auto-valutazione
- seleziona_aree_fondazionali (B39.6.2) -> filtra le aree "forte" per la verifica compound
- Entrambe vivono in onboarding_self_assessment.py (non in core/onboarding.py come indicato nella roadmap originale -- piu coerente avere tutta la logica assessment nello stesso file)

### Stato del progetto
- Backend: 624 test verdi, 13 skipped
- Frontend: 588 test verdi (non toccato), analyze 0
- Branch: develop

### Prossimo passo concreto
- B39.6.3 - Prompt generatore esercizi compound
- Prompt Opus in backend/app/llm/prompts/onboarding_exercise_generator.py
- Genera esercizi a scelta multipla (3-4 opzioni, 1 corretta) che coprono fino a 2 concetti
- Gate: unit test presenza istruzioni (max 2 concetti, formato multiple choice), output JSON specificato

### File da leggere per la prossima sessione
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md (cerca B39.6.3)
4. .claude/handoff.md (questo file)
5. docs/discussions/b39-onboarding-narrativo.md (Decisione 8 - placement, formato esercizi)
6. backend/app/llm/prompts/onboarding_self_assessment.py (contesto assessment)
7. backend/app/llm/prompts/onboarding_extractor.py (stile prompt esistente)
