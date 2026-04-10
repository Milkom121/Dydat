STATUS: PHASE_COMPLETE
PHASE: 10
BLOCK: B40
SUMMARY: B39-FIX completato — Collegamento onboarding narrativo al flusso reale. (1) Riscritta `direttiva_onboarding` in direttive.py: rimosso VINCOLO ASSOLUTO, fasi accoglienza/conoscenza sono testo libero conversazionale (NO tool use), auto_valutazione/placement usano tool. (2) `elabora_decisione_onboarding` in onboarding.py: collegata a tutte le fasi narrative (accoglienza → chi_e, conoscenza → estrattore+decisore, auto_valutazione → cycling nodi gateway). (3) `_genera_direttiva` in contesto.py: passa prossimo_campo e nodo_da_valutare. (4) Descrizione tool onboarding_domanda aggiornata in tools.py per distinguere fasi narrative vs strutturate. (5) Aggiunta `_parsa_livello_autovalutazione` e logica auto_valutazione completa con cycling nodi e transizione a placement. 26 nuovi test in test_onboarding_b39_fix.py.
NEXT: B40 — Sistema Audio Base (micro-suoni, feedback aptico, impostazioni). NOTA: Villa deve prima eseguire il test manuale dell'onboarding narrativo B39 (checklist in docs/discussions/b39-checklist-test-manuale.md). Attendere conferma prima di procedere.
DECISIONS_NEEDED: Risultato test manuale onboarding B39 da Villa
FILES_MODIFIED: backend/app/llm/prompts/direttive.py, backend/app/core/onboarding.py, backend/app/core/contesto.py, backend/app/llm/tools.py, backend/tests/test_onboarding_b39_fix.py, backend/tests/test_onboarding.py, backend/tests/test_contesto.py, backend/tests/test_b39_3_2_decisor_integration.py
TESTS: PASS (795 passed, 13 skipped)
VERIFICATION: 795 test backend passati, 13 skippati (7 DB integration + 3 LLM integration + 3 STT integration), ruff pulito sui file modificati, build OK
