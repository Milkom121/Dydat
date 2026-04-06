STATUS: CONTINUE
PHASE: 8
BLOCK: B35
SUMMARY: B34 completato (S31). Riscritta LearningPathScreen da lista card a mappa visiva nodi con vista lineare, zoom grafo, ricerca argomento e tap nodo con placeholder quaderno. 14 nuovi test, 357 totale frontend, analyze 0.
NEXT: B35 - Quaderno per Nodo (Fase 8)
DECISIONS_NEEDED: Badge Gia studiato in percorso non implementato - API non espone dato cross-percorso.
FILES_MODIFIED: learning_path_screen.dart (riscrittura), linear_path_map.dart (nuovo), graph_overview.dart (nuovo), node_detail_bottom_sheet.dart (nuovo), 4 test nuovi
TESTS: PASS (341 backend, 357 frontend, flutter analyze 0)
VERIFICATION: flutter analyze 0, flutter test 357 verdi (da 343 baseline +14), commit b2cacaf su develop

---

## Contesto dettagliato

### Cosa e stato fatto
- LearningPathScreen riscritta: da lista card a mappa visiva con due viste
- LinearPathMap: mappa lineare verticale con cerchi nodo collegati da linee
- GraphOverview: vista grafo con InteractiveViewer pan+zoom, CustomPainter
- NodeDetailBottomSheet: dettaglio nodo con placeholder Quaderno B35
- Ricerca argomento: filtro client-side case-insensitive con highlight
- Toggle vista: IconButton in AppBar per alternare lineare/grafo

### Prossimo passo - B35: Quaderno per Nodo
1. Backend: nuovo endpoint GET /nodi/{id}/quaderno
2. Frontend: NodoQuadernoScreen con sezioni Appunti, Esercizi, Formule
3. Navigazione: da NodeDetailBottomSheet tap Quaderno apre nuova schermata

### File da leggere
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md
4. .claude/handoff.md
5. docs/dydat_api_reference.md
6. frontend/lib/presentation/learning_path_screen/
7. backend/app/api/ e backend/app/models/
