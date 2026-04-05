STATUS: CONTINUE
PHASE: 5
BLOCK: B28
SUMMARY: Blocco B28 completato (S25). Endpoint GET /ripasso/nodi. NodoRipasso model + ripassoProvider. Badge SR su TemaCardWidget. Sezione ripasso in HomeViewWidget. 10 nuovi test frontend. 329 backend + 220 frontend verdi.
NEXT: Blocco B29 - Sessioni Ripasso Dedicate + E2E Loop 5
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/app/api/ripasso.py, backend/app/main.py, backend/tests/test_ripasso.py, frontend/lib/models/ripasso.dart, frontend/lib/providers/ripasso_provider.dart, frontend/lib/config/api_config.dart, frontend/lib/services/path_service.dart, frontend/lib/main.dart, TemaCardWidget, LearningPathScreen, HomeViewWidget, StudioScreen, test files
TESTS: PASS (329 backend, 220 frontend, flutter analyze 0)
VERIFICATION: flutter analyze 0 issues, flutter test 220/220, pytest 329 passed 10 skipped

---

## Contesto dettagliato

### Cosa e stato fatto

**Backend:**
- backend/app/api/ripasso.py: endpoint GET /ripasso/nodi con join Nodo+NodoTema+Tema. Deduplica nodo_id. Ordine urgenza (sr_prossimo_ripasso ASC).
- backend/app/main.py: aggiunto ripasso.router
- backend/tests/test_ripasso.py: 5 test unitari

**Residui B27 committati separatamente (commit 448df4e):**
- backend/app/core/elaborazione.py: interleaving SR in aggiorna_nodo_dopo_promozione()
- backend/tests/test_interleaving.py: 4 test

**Frontend:**
- NodoRipasso model + ripasso.g.dart (json_annotation snake_case->camelCase)
- RipassoState (nodi, isLoading, error, conteggioPerTema, totale) + RipassoNotifier + ripassoProvider
- ApiConfig.ripassoNodi + PathService.getNodiDaRipassare()
- main.dart: ripassoProvider.overrideWith(...)
- TemaCardWidget: param nodiDaRipassare (default 0), badge tertiary in alto a destra (icona replay + numero)
- LearningPathScreen: watch ripassoProvider, carica() in initState e refresh, nodiDaRipassare per tema
- HomeViewWidget: param ripassoTotale, sezione tertiaryContainer con bottone Vai -> /studio
- StudioScreen: watch ripassoProvider, ripassoTotale a HomeViewWidget, carica() in initState

### Stato del progetto
- Backend: 329 test (+ 10 skipped integration)
- Frontend: 220 test, analyze 0 issues
- Branch: develop, Docker attivo

### Prossimo passo concreto
Blocco B29 - Sessioni Ripasso Dedicate + E2E Loop 5:
1. Backend: core/sessione.py inizia_sessione() accetta tipo=ripasso, usa get_nodi_da_ripassare()
2. Backend: direttiva_ripasso_sr gia predisposta in prompts/direttive.py
3. Frontend: bottone Vai avvia sessione tipo=ripasso con endpoint apposito
4. E2E: esercizi -> promozione -> badge -> sessione ripasso -> interleaving

### File da leggere per la prossima sessione
1. CLAUDE.md, PROJECT_CONFIG.md, ROADMAP.md (B29), .claude/handoff.md
2. backend/app/core/sessione.py
3. backend/app/grafo/fsrs.py
4. backend/app/llm/prompts/direttive.py
5. frontend/lib/presentation/studio_screen/widgets/home_view_widget.dart
6. docs/dydat_api_reference.md
