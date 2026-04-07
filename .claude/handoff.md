STATUS: CONTINUE
PHASE: 9
BLOCK: B35.10
SUMMARY: B35.10 completato. Search mappa percorso estesa alle parole_chiave dei nodi. Backend: aggiunto campo parole_chiave alla response GET /percorsi/{id}/mappa. Frontend: NodoMappa con paroleChiave, ricerca estesa nome+keyword in LearningPathScreen. 11 nuovi test. 552 frontend verdi, analyze 0.
NEXT: B35.11 - Coerenza tono di voce italiana (bonus)
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/app/api/percorsi.py, frontend/lib/models/percorso.dart, frontend/lib/models/percorso.g.dart, frontend/lib/presentation/learning_path_screen/learning_path_screen.dart, frontend/test/widgets/b34_learning_path_screen_test.dart
TESTS: PASS (356 backend, 552 frontend, flutter analyze 0)
VERIFICATION: 552 passed, analyze 0, ruff clean, build OK

---

## Contesto dettagliato

### Cosa e stato fatto
- **percorsi.py** (backend): aggiunto Nodo.parole_chiave alla SELECT query e al dict response nella mappa nodi. Valore default [] se null.
- **percorso.dart** (frontend model): aggiunto campo paroleChiave (List<String>) a NodoMappa con @JsonKey(name: 'parole_chiave', defaultValue: <String>[]).
- **percorso.g.dart**: aggiornato fromJson/toJson per gestire parole_chiave con fallback a lista vuota.
- **learning_path_screen.dart**: _getHighlightedNodeIds() ora cerca sia nel nome del nodo che nelle parole chiave.
- **b34_learning_path_screen_test.dart**: riscritto con 2 gruppi: ricerca per nome (8 test esistenti) + ricerca per parole chiave (7 nuovi test) + deserializzazione (4 nuovi test).

### Stato del progetto
- Backend: 356 test verdi, 10 skipped (non toccato tranne percorsi.py)
- Frontend: 552 test verdi, analyze 0

### Prossimo passo concreto
- B35.11: Audit testi UI italiani - uso coerente del "tu", traduzione inglesismi residui, uniformare terminologia
- Creare docs/tone-of-voice.md

### File da leggere per la prossima sessione
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md
4. .claude/handoff.md
5. Schermate frontend per audit testi
