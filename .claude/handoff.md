STATUS: CONTINUE
PHASE: 8
BLOCK: B34
SUMMARY: Fase 7 completata (B33, S30). Pronti per B34 — Percorso Unificato: Mappa + Zoom. Tab "I miei studi" attualmente mostra LearningPathScreen a lista card (tema_card_widget). Da riscrivere come mappa visiva lineare + zoom grafo + ricerca + tap nodo.
NEXT: B34 — Percorso Unificato: Mappa + Zoom (Fase 8)
DECISIONS_NEEDED: Test manuali B33 (transizione/goal picker/recap narrativo) rimandati — Villa testerà in sessione successiva. Il runner può procedere con B34 su develop senza merge su main (Fase 7 non ancora merged, resta su develop con il resto della Fase 8).
FILES_MODIFIED: (nessuno in questa preparazione — solo aggiornamento handoff/progress/session-log per kickoff B34)
TESTS: PASS (341 backend, 343 frontend, flutter analyze 0 — baseline da B33)
VERIFICATION: baseline verde confermata da chiusura S30. Nessuna modifica di codice in questa preparazione.

---

## Contesto dettagliato

### Situazione di partenza
- Fase 7 chiusa con B33 (S30). Tutti i test verdi, commit su `develop` (874b537).
- Test manuali di B33 (transizione Home->Studio, SessionGoalPicker, recap narrativo, snackbar pausa obiettivo) NON ancora eseguiti da Villa. Il runner procede comunque: se B34 rompe qualcosa rilevante per B33, ce ne accorgiamo dai test automatici.
- Merge `develop -> main` rimandato a fine Fase 8 (B34+B35), non dopo Fase 7. Si resta su `develop`.

### Cosa fare in B34 — Percorso Unificato: Mappa + Zoom

Obiettivo: riscrivere `learning_path_screen.dart` da lista di card (`tema_card_widget`) a mappa visiva del percorso, con zoom grafo completo, ricerca argomento, tap nodo. Corrisponde al tab "I miei studi" nella nuova navigazione (B30).

**File principali da toccare**:
- `frontend/lib/presentation/learning_path_screen/learning_path_screen.dart` (riscrittura)
- `frontend/lib/presentation/learning_path_screen/widgets/` (nuovi widget mappa, sostituire tema_card_widget)
- `frontend/lib/providers/path_provider.dart` (eventuale arricchimento stato per zoom/filtri)
- NON toccare `frontend/lib/services/path_service.dart` se non necessario (API `GET /percorsi/{id}/mappa` già esistente — vedi `docs/dydat_api_reference.md`)

**Sotto-obiettivi (gate di uscita)**:
1. **Vista default — mappa lineare**: il percorso attuale come cerchi collegati da linee (NON lista card). Ogni cerchio è un nodo (tema). Stato nodo (da_iniziare / in_corso / operativo / comprensivo) tramite colore/bordo. Layout verticale scrollabile.
2. **Zoom out — grafo completo**: bottone/gesture per passare da mappa lineare a grafo completo delle connessioni (es. `InteractiveViewer` con `CustomPainter` o `flutter_graph_view`/`graphview`). Usare dati da `pathProvider.currentMap`.
3. **Badge "Già studiato in [percorso]"**: se un nodo compare in altri percorsi dell'utente, mostrare indicatore. Serve dato aggregato — se non disponibile dall'API attuale, mettere placeholder e segnalare nel handoff finale.
4. **Ricerca argomento**: `TextField` in top bar che filtra nodi per nome (client-side, case-insensitive). Quando filtrato, evidenzia i match nella mappa o mostra lista risultati.
5. **Tap nodo**: apre placeholder quaderno (B35 non ancora implementato) — per ora mostrare `tema_detail_bottom_sheet` esistente oppure un messaggio "Quaderno in arrivo (B35)". NON implementare il quaderno — è B35.

**Constraint**:
- `Theme.of(context)` — zero colori hardcoded. Stati nodo via `colorScheme` (primary / secondary / tertiary / surfaceVariant).
- Riverpod safety: non modificare provider in initState/build/dispose.
- Test: coprire almeno (a) rendering mappa con N nodi, (b) filtro ricerca, (c) tap nodo naviga/apre sheet, (d) stato vuoto.
- Niente refactoring bonus su altri file. Solo learning_path_screen + suoi widget.

**Gate di uscita (da ROADMAP.md)**:
Mappa lineare funziona, zoom grafo funziona, ricerca funziona, tap su nodo navigabile, `flutter analyze` 0, `flutter test` verdi.

### File da leggere per la prossima sessione (in ordine)
1. `CLAUDE.md` (regole Metodo Villa + progetto)
2. `PROJECT_CONFIG.md` (stack, comandi)
3. `ROADMAP.md` (blocchi B34 e B35 per capire il confine)
4. `.claude/handoff.md` (questo file)
5. `docs/dydat_api_reference.md` (endpoint `GET /percorsi/{id}/mappa`, modelli `MappaPercorso`, `Tema`)
6. `docs/dydat-ux-redesign-concept-v1.1.docx` sezioni 3.2, 3.3 (riferimento UX)
7. `frontend/lib/presentation/learning_path_screen/learning_path_screen.dart` (stato attuale)
8. `frontend/lib/presentation/learning_path_screen/widgets/tema_card_widget.dart` (da sostituire)
9. `frontend/lib/presentation/learning_path_screen/widgets/tema_detail_bottom_sheet.dart` (riutilizzabile per tap nodo in attesa di B35)
10. `frontend/lib/providers/path_provider.dart` (stato percorso)
11. `frontend/lib/models/percorso.dart`, `frontend/lib/models/tema.dart` (modelli)

### Stato tecnico baseline (da B33)
- Backend: 341 test verdi
- Frontend: 343 test verdi, `flutter analyze` 0 errori
- Branch: `develop`, ultimo commit `874b537`
- Test manuali B33: RIMANDATI — Villa li farà in una sessione dedicata successiva

### NON fare
- Non implementare il quaderno nodo (è B35)
- Non modificare backend (tutti i dati necessari sono già esposti)
- Non modificare `app_router.dart` (tab "I miei studi" è già configurato da B30 al path `/studi`)
- Non toccare `home_screen.dart` / `studio_screen.dart`
- Non aggiungere dipendenze pesanti senza giustificarle (preferire `CustomPainter` + `InteractiveViewer` a librerie grafo esterne, se possibile)
