STATUS: CONTINUE
PHASE: 10
BLOCK: B39.6.2
SUMMARY: B39.6.1 completato - Prompt auto-valutazione placement. Nuovo file onboarding_self_assessment.py con build_self_assessment_prompt (direttiva tutor con aree, livelli forte/incerto/digiuno, marker strutturato [AUTOVALUTAZIONE]), parse_autovalutazione (parser blocco strutturato), seleziona_aree_da_grafo (selezione temi ordinati per importanza/numero nodi). 34 nuovi test. 603 backend verdi, 13 skipped.
NEXT: B39.6.2 - Logica selezione aree fondazionali
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/app/llm/prompts/onboarding_self_assessment.py (nuovo), backend/tests/test_b39_6_1_self_assessment.py (nuovo)
TESTS: PASS (603 backend verdi, 13 skipped)
VERIFICATION: 603 passed, 13 skipped. File nuovi ruff-puliti. Tutti i test preesistenti continuano a passare.

---

## Contesto dettagliato

### Cosa e stato fatto
- B39.6.1 completato: prompt auto-valutazione placement
- Fase 6 Placement: 1/6 sub-blocchi completati
- 16/38 sub-blocchi B39 completati totali

### File creati
- backend/app/llm/prompts/onboarding_self_assessment.py:
  - build_self_assessment_prompt(aree, nome_utente) - direttiva per il tutor
  - parse_autovalutazione(testo_tutor) - parser blocco [AUTOVALUTAZIONE]/[/AUTOVALUTAZIONE]
  - seleziona_aree_da_grafo(grafo_nodi) - seleziona temi ordinati per numero nodi
  - Costanti: LIVELLI_AUTOVALUTAZIONE, MAX_AREE_AUTOVALUTAZIONE (10), ISTRUZIONI_CHIAVE
- backend/tests/test_b39_6_1_self_assessment.py: 34 test (costanti, prompt, parser, selezione aree, umanizzazione)

### Stato del progetto
- Backend: 603 test verdi, 13 skipped
- Frontend: 588 test verdi (non toccato), analyze 0
- Branch: develop

### Prossimo passo concreto
- B39.6.2 - Logica selezione aree fondazionali
- Funzione seleziona_aree_fondazionali(aree_forte, grafo) che, data la lista aree dichiarate forti, seleziona le N piu fondazionali partendo dai nodi del grafo con meno prerequisiti. Cap a 6 per la verifica.
- Gate: unit test deterministici con grafo mockato
- NOTA: seleziona_aree_da_grafo (B39.6.1) seleziona i temi per auto-valutazione; seleziona_aree_fondazionali (B39.6.2) filtra le aree forte per la verifica compound

### File da leggere per la prossima sessione
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md (cerca B39.6.2)
4. .claude/handoff.md (questo file)
5. docs/discussions/b39-onboarding-narrativo.md (Decisione 8 - placement)
6. backend/app/llm/prompts/onboarding_self_assessment.py (appena creato, contesto)
7. backend/app/grafo/algoritmi.py (ordinamento topologico, prerequisiti)
8. backend/app/grafo/struttura.py (GrafoKnowledge, struttura grafo)
