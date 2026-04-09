STATUS: CONTINUE
PHASE: 10
BLOCK: B39.7.1
SUMMARY: B39.6.6 completato - Integrazione stato_orchestratore + path planner. costruisci_mappa_placement() unisce autovalutazione + esiti verifica compound in mappa {area: stato} con 4 stati (forte_confermato/forte_unverified/incerto/digiuno). determina_nodo_partenza_da_mappa() sceglie primo nodo operativo con tema non-forte. _determina_nodo_da_placement aggiornato con priorita mappa > legacy gateway. _inizializza_stato_nodi esteso: nodi di temi forte_confermato marcati presunti. completa_onboarding passa placement_mappa a inizializzazione nodi. 28 nuovi test. 737 backend verdi, 13 skipped.
NEXT: B39.7.1 - Scheletro widget VoiceInputField
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/app/core/onboarding.py (costruisci_mappa_placement, determina_nodo_partenza_da_mappa, _determina_nodo_da_placement, _inizializza_stato_nodi, completa_onboarding), backend/tests/test_b39_6_6_placement_integration.py (nuovo)
TESTS: PASS (737 backend verdi, 13 skipped)
VERIFICATION: 737 passed, 13 skipped. Ruff pulito. Tutti i test preesistenti continuano a passare.

---

## Contesto dettagliato

### Cosa e stato fatto
- B39.6.6 completato: integrazione stato_orchestratore + path planner
- Tutta la Fase 6 Placement completata (B39.6.1 - B39.6.6, 6/6 sub-blocchi)
- 20/38 sub-blocchi B39 completati totali

### Funzioni aggiunte/modificate in core/onboarding.py

- **costruisci_mappa_placement(autovalutazione, esiti_verifica, aree_verificate)**:
  - Unisce auto-valutazione {area: forte/incerto/digiuno} + esiti compound -> mappa finale
  - 4 stati: forte_confermato, forte_unverified, incerto, digiuno
  - Aree verificate non retrocesse = confermate, retrocesse = incerto
  - Livello sconosciuto -> incerto (fallback sicuro)

- **determina_nodo_partenza_da_mappa(mappa_placement, grafo)**:
  - Primo nodo operativo nell'ordine topologico con tema non-forte
  - Nodi senza tema trattati come non-forti
  - Se tutti forti -> ultimo nodo operativo

- **_determina_nodo_da_placement** (aggiornato):
  - Nuova priorita: placement_mappa (B39.6.6) > esiti legacy (gateway)
  - Retrocompatibile: se mappa assente, usa il vecchio sistema

- **_inizializza_stato_nodi** (aggiornato):
  - Nuovo parametro placement_mappa
  - Nodi di temi forte_confermato -> operativo + presunto=true
  - Logica OR: presunto se nodo_prima_override O tema forte_confermato

- **completa_onboarding** (aggiornato):
  - Estrae placement_mappa da placement_risultati
  - La passa a _inizializza_stato_nodi

### Catena completa Placement (B39.6.1-B39.6.6)
1. seleziona_aree_da_grafo -> temi per auto-valutazione
2. parse_autovalutazione -> {area: forte/incerto/digiuno}
3. seleziona_aree_fondazionali -> aree forti da verificare
4. genera_esercizi_verifica -> esercizi compound
5. valuta_risposta -> EsitoVerifica per ogni esercizio
6. costruisci_mappa_placement -> mappa finale {area: stato}
7. determina_nodo_partenza_da_mappa -> nodo_id partenza
8. _inizializza_stato_nodi con placement_mappa -> nodi presunti

### Stato del progetto
- Backend: 737 test verdi, 13 skipped
- Frontend: 588 test verdi (non toccato), analyze 0
- Branch: develop

### Prossimo passo concreto
- B39.7.1 - Scheletro widget VoiceInputField
- File Flutter con struttura base del widget riutilizzabile: TextFormField + pulsante microfono disabilitato come placeholder
- Nessuna funzionalita audio ancora
- Gate: widget compila, widget test rendering base

### File da leggere per la prossima sessione
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md (cerca B39.7.1)
4. .claude/handoff.md (questo file)
5. docs/discussions/b39-onboarding-narrativo.md (riferimento strategico onboarding)
