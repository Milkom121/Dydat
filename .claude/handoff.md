STATUS: PHASE_COMPLETE
PHASE: 5
BLOCK: B29
SUMMARY: Blocco B29 completato (S26). Loop 5 FSRS completo. Sessioni ripasso dedicate: _scegli_nodo_ripasso() con fallback path planner. Frontend: bottone Vai avvia sessione ripasso. 12 nuovi test backend + 8 nuovi frontend. 341 backend + 228 frontend verdi, analyze 0.
NEXT: Fase 6 — Blocco B30 — Feynman Signal Processing (Backend)
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/app/core/sessione.py, backend/tests/test_b29_sessioni_ripasso.py, frontend/test/services/session_service_test.dart, frontend/test/providers/session_provider_test.dart, ROADMAP.md
TESTS: PASS (341 backend, 228 frontend, flutter analyze 0)
VERIFICATION: flutter analyze 0 issues, flutter test 228/228, pytest 341 passed 10 skipped

---

## Contesto dettagliato

### Cosa e stato fatto — B29

Loop 5 completato. Tutti i blocchi B26-B29 sono completati.

**Backend — sessione.py:**
- _scegli_nodo_ripasso(): quando tipo=ripasso, sceglie sempre il nodo SR piu urgente (nessuna probabilita). Se nessun nodo SR scaduto, fallback al path planner normale.
- inizia_sessione(): se tipo == "ripasso" chiama _scegli_nodo_ripasso(), altrimenti _scegli_nodo() (interleaving 35%).
- 12 test in test_b29_sessioni_ripasso.py (5 per _scegli_nodo_ripasso, 4 per inizia_sessione, 3 per direttiva_ripasso_sr).

**Frontend (gia predisposto da B28, verificato funzionante in B29):**
- session_provider.dart: startSessionStream() accetta tipo param (default 'media').
- home_view_widget.dart: onRipassoTap callback. Bottone "Vai" invoca callback se fornito.
- studio_screen.dart: _startRipassoSession() chiama _startSession(tipo: 'ripasso'). Passato come onRipassoTap a HomeViewWidget.
- Test aggiunti: session_service_test (tipo ripasso nel body), session_provider_test (stato sessione ripasso), home_view_widget_test (4 test UI ripasso).

### Stato del progetto
- Backend: 341 test (+ 10 skipped integration) — Loop 5 FSRS completo
- Frontend: 228 test, analyze 0 issues — Loop 5 FSRS completo
- Branch: develop, Docker attivo

### Architettura sessioni ripasso
bottone Vai (HomeViewWidget)
  -> onRipassoTap callback
  -> _startRipassoSession() in StudioScreen
  -> startSessionStream(tipo: 'ripasso')
  -> SessionService.startStream(tipo: 'ripasso')
  -> POST /sessione/inizia {"tipo": "ripasso"}
  -> inizia_sessione(tipo="ripasso")
  -> _scegli_nodo_ripasso()
    -> get_nodi_da_ripassare() -> nodo SR piu urgente
    -> se vuoto -> path_planner fallback
  -> stato_orchestratore.attivita_corrente = "ripasso_sr"
  -> direttiva_ripasso_sr() nel context package

### Prossimo passo concreto — B30
Fase 6 — Feynman Signal Processing (Backend):
1. Attivare tool avvia_feynman e valutazione_feynman in tools.py
2. Implementare _processa_valutazione_feynman() in elaborazione.py
3. Routing azione avvia_feynman in elaborazione.py
4. feynman_superato aggiornato dopo valutazione positiva

### File da leggere per la prossima sessione
1. CLAUDE.md, PROJECT_CONFIG.md, ROADMAP.md (B30), .claude/handoff.md
2. backend/app/core/elaborazione.py (signal processor, action executor)
3. backend/app/llm/tools.py (tool schemas)
4. backend/app/llm/prompts/direttive.py (direttiva_feynman gia presente)
5. backend/app/db/models/stato_utente.py (campo feynman_superato)
