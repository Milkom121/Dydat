STATUS: CONTINUE
PHASE: 5
BLOCK: B27
SUMMARY: Blocco B27 completato (S24). Interleaving SR probabilistico implementato in _scegli_nodo() e aggiorna_nodo_dopo_promozione(). _NodoScelto NamedTuple, PROBABILITA_INTERLEAVING=0.35, direttiva ripasso assemblata tramite contesto.py.
NEXT: Blocco B28 - Sezione Ripasso Frontend + Badge
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/app/core/sessione.py, backend/app/core/elaborazione.py, backend/app/grafo/fsrs.py, backend/tests/test_sessione.py, backend/tests/test_b27_interleaving.py, backend/tests/test_interleaving.py
TESTS: PASS (324 backend, 10 skipped integrazione DB/LLM)
VERIFICATION: pytest 324/324, ruff clean su file modificati, logica interleaving verificata

---

## Contesto dettagliato

### Cosa e stato fatto
- sessione.py: _scegli_nodo() ritorna _NodoScelto (NamedTuple con nodo_id, attivita, concetti_scadenza). Priorita: 1) nodo in_corso (nessun interleaving), 2) interleaving SR probabilistico (35%), 3) path planner
- sessione.py: _nomi_nodi_sr() helper per nomi leggibili dei nodi SR (max 5, fallback a ID)
- sessione.py: inizia_sessione() gestisce il nuovo return type, imposta attivita_corrente=ripasso_sr e concetti_scadenza
- elaborazione.py: aggiorna_nodo_dopo_promozione() aggiunto interleaving SR dopo promozione, con esclusione del nodo appena promosso
- elaborazione.py: pulizia concetti_scadenza residui quando non e ripasso
- fsrs.py: aggiunto order_by(sr_prossimo_ripasso) in get_nodi_da_ripassare per ordinamento per urgenza
- test_b27_interleaving.py: 17 test per interleaving in sessione.py
- test_interleaving.py: 4 test per interleaving in aggiorna_nodo_dopo_promozione

### Flusso interleaving
1. Nuova sessione: _scegli_nodo() se no nodo in_corso e ci sono nodi SR scaduti -> 35% prob di ripasso
2. Dopo promozione: aggiorna_nodo_dopo_promozione() se ci sono nodi SR scaduti (escluso il promosso) -> 35% prob di ripasso
3. Se interleaving: nodo_focale = nodo SR piu urgente, attivita_corrente = ripasso_sr, concetti_scadenza popolati
4. Direttiva: contesto.py riga 389 direttiva_ripasso_sr() gia collegata e funzionante

### Stato del progetto
- Backend: 324 test (21 nuovi B27), ruff clean
- Frontend: 210 test (non toccato in questo blocco)
- Branch: develop
- Docker: funzionante

### Prossimo passo concreto
Blocco B28 - Sezione Ripasso Frontend + Badge:
1. Nuovo endpoint GET /ripasso/nodi (backend)
2. Modello NodoRipasso (frontend)
3. Badge Da ripassare su tema_card (frontend)
4. Sezione ripasso in home con conteggio e bottone (frontend)
5. Gate: Badge visibili, sezione ripasso in home, API funziona, analyze 0, test verdi

### File da leggere per la prossima sessione
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md (sezione Fase 5, B28)
4. .claude/handoff.md
5. backend/app/grafo/fsrs.py (get_nodi_da_ripassare per endpoint)
6. docs/dydat_api_reference.md (per nuovo endpoint)
7. frontend/lib/presentation/studio_screen/ (home view per sezione ripasso)
