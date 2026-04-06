STATUS: CONTINUE
PHASE: 7
BLOCK: B32
SUMMARY: B30 (Nuova Navigazione: 3 Tab + Studio Modale) completato in S27. B31 (Home Calda con Ritorno Intelligente) completato in S28. 4 sub-widget in home_screen/widgets/: WelcomeHeader, MiniPercorsoWidget, StreakCard, RipassoSection. 41 nuovi test. 274 frontend verdi, analyze 0.
NEXT: B32 — Modello Ibrido: Esercizi Fullscreen
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: home_screen.dart, home_screen/widgets/ (4 file), app_router.dart, custom_bottom_bar.dart, studio_screen.dart
TESTS: PASS (341 backend, 274 frontend, flutter analyze 0)
VERIFICATION: 274 test verdi, flutter analyze 0 issues, build OK.

---

## Contesto dettagliato

### Cosa e stato fatto (Fase 6)
- B30 (S27): Ristrutturata navigazione - 3 tab (Home/I miei studi/Profilo) + Studio fullscreen modale fuori dalla shell.
- B31 (S28): Home arricchita con 4 sub-widget: WelcomeHeader, MiniPercorsoWidget, StreakCard, RipassoSection.

### Stato del progetto
- Backend: 341 test verdi, stabile, NON va toccato in B32
- Frontend: 274 test verdi, analyze 0
- Branch: develop

### Navigazione corrente
- Shell: 3 tab (Home /home, I miei studi /studi, Profilo /profilo)
- Studio: route fullscreen /studio?tipo=media|ripasso FUORI dalla shell
- context.push('/studio') da tab, context.go('/home') per tornare

### Prossimo passo concreto — B32

Quando il tutor propone un esercizio (proponi_esercizio), l'ExerciseCardWidget esce dal feed e si prende lo schermo.

1. ExerciseFullscreenView — layout dedicato (no chat dietro), transizione slide up/fade
2. Completato esercizio: record compatto rientra nel feed
3. Stessa logica per FormulaCardWidget (mostra_formula) e BacktrackCardWidget (suggerisci_backtrack)
4. Feed conversazionale resta scrollabile per le spiegazioni
5. Gestione stato in session_provider.dart

Gate di uscita: esercizi/formule/backtrack in fullscreen, record compatto nel feed, transizioni fluide, analyze 0, test verdi

### File da leggere per la prossima sessione
1. frontend/lib/presentation/studio_screen/studio_screen.dart
2. frontend/lib/presentation/studio_screen/widgets/chat_view_widget.dart
3. frontend/lib/presentation/studio_screen/widgets/exercise_card_widget.dart
4. frontend/lib/presentation/studio_screen/widgets/formula_card_widget.dart
5. frontend/lib/presentation/studio_screen/widgets/backtrack_card_widget.dart
6. frontend/lib/providers/session_provider.dart
