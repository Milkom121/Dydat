STATUS: CONTINUE
PHASE: 6
BLOCK: B30
SUMMARY: Fase 5 (FSRS) completata in S26. UX Redesign pianificato: concept document v1.1 approvato dal fondatore, ROADMAP aggiornata con Fasi 6-14 (Fase A UX in 6 sotto-fasi + Feynman + Visualizzazioni). Pronto per primo blocco implementativo.
NEXT: B30 — Nuova Navigazione: 3 Tab + Studio Modale
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: ROADMAP.md, docs/dydat-ux-redesign-concept-v1.1.docx, discovery-notes.md
TESTS: PASS (341 backend, 228 frontend, flutter analyze 0)

---

## Contesto dettagliato

### Cosa e stato fatto
- Discovery UX completa: 19 decisioni prese col fondatore su identita, navigazione, sessione, gamification, notifiche, audio, onboarding
- Concept document v1.1 prodotto e approvato (docs/dydat-ux-redesign-concept-v1.1.docx)
- ROADMAP aggiornata: vecchie Fasi 6-7 sostituite con piano UX Redesign strutturato in sotto-fasi (A.1-A.6) + Feynman spostato dopo il redesign
- Note di discovery complete in discovery-notes.md (19 decisioni documentate)

### Stato del progetto
- Backend: 341 test verdi, stabile, NON va toccato in B30
- Frontend: 228 test verdi, analyze 0
- Ultimo blocco completato: B29 (Sessioni Ripasso Dedicate) in S26
- Docker: funziona da backend/

### Prossimo passo concreto — B30

Ristrutturare la navigazione dell'app da 3 tab (Studio/Percorso/Profilo) a 3 tab (Home/I miei studi/Profilo) + Studio come route fullscreen modale.

**ATTENZIONE**: Questo blocco e SOLO frontend. Non toccare il backend.

Operazioni concrete:
1. Creare `presentation/home_screen/home_screen.dart` — nuovo Tab 1
   - Migrare contenuto da `presentation/studio_screen/widgets/home_view_widget.dart`
   - Per ora contenuto base: benvenuto, bottone "Riprendi a studiare", sezione ripasso FSRS
2. In `routes/app_router.dart`:
   - Tab 0: '/home' -> HomeScreen (nuovo)
   - Tab 1: '/studi' -> LearningPathScreen (rinominato)
   - Tab 2: '/profilo' -> ProfileScreen (invariato)
   - Route '/studio' FUORI dalla shell (fullscreen, no bottom bar)
   - Route '/studio' riceve parametri (tipo sessione, nodo_id opzionale)
3. In `widgets/custom_bottom_bar.dart`:
   - Tab 1: "Home" con icona home
   - Tab 2: "I miei studi" con icona book/map
   - Tab 3: "Profilo" (invariato)
4. In `studio_screen.dart`:
   - Rimuovere la logica home (showChat toggle) — la home ora e un screen separato
   - Lo StudioScreen e SOLO la sessione di studio attiva
   - Gestire parametri in ingresso (tipo sessione, nodo_id)
5. Test: navigazione funziona, sessione si apre e chiude, ritorno alla home

**Gate di uscita B30:** 3 tab funzionanti, Studio si apre come fullscreen modale, tab spariscono in sessione, navigazione Home->Studio->Home funziona, flutter analyze 0, flutter test verdi

### File da leggere per la prossima sessione
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md (aggiornata — leggere Fase 6 / B30)
4. .claude/handoff.md (questo file)
5. docs/dydat-ux-redesign-concept-v1.1.docx (sezioni 3, 6 — struttura e navigazione)
6. frontend/lib/routes/app_router.dart (navigazione attuale)
7. frontend/lib/widgets/custom_bottom_bar.dart (bottom bar attuale)
8. frontend/lib/presentation/studio_screen/studio_screen.dart (studio attuale — capire cosa separare)
9. frontend/lib/presentation/studio_screen/widgets/home_view_widget.dart (contenuto da migrare alla nuova HomeScreen)
