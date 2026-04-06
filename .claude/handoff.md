STATUS: PHASE_COMPLETE
PHASE: 7
BLOCK: B33
SUMMARY: B33 completato (S30). StudioTransitionOverlay (1150ms), SessionGoalPicker, recap narrativo tutor, notifica pausa obiettivo. 47 nuovi test, 343 totale, analyze 0.
NEXT: B34 — Percorso Unificato: Mappa + Zoom (Fase 8)
DECISIONS_NEEDED: Fase 7 completata — serve review e ok Villa per avanzare a Fase 8
FILES_MODIFIED: home_screen.dart, studio_screen.dart, recap_session_screen.dart, app_router.dart, nuovo studio_transition_overlay.dart, nuovo session_goal_picker.dart
TESTS: PASS (341 backend, 343 frontend, flutter analyze 0)
VERIFICATION: 343 test verdi, flutter analyze 0. Test SSE flaky passa in isolamento, non correlato a B33.

---

## Contesto dettagliato

### Cosa e stato fatto (B33)

1. StudioTransitionOverlay (home_screen/widgets/studio_transition_overlay.dart):
   - Overlay animato 1150ms prima di navigare a /studio
   - AnimationController con Interval: scale-in+fade-in, pausa, fade-out
   - onComplete via addStatusListener(completed) - testabile
   - HomeScreen: Stack+Positioned.fill, _avviaStudio() imposta _showTransitionOverlay=true

2. app_router.dart: route /studio usa CustomTransitionPage slide-up+fade (600/400ms)

3. SessionGoalPicker (studio_screen/widgets/session_goal_picker.dart):
   - enum SessionGoal { veloce(15), normale(30), approfondita(60) }
   - Dialog 3 tile + Salta/Inizia. showSessionGoalPicker(context)
   - Solo tipo=media. _durataPrevistaMin a startSessionStream.

4. _checkGoalExceeded(): snackbar una volta al superamento obiettivo

5. recap_session_screen.dart: recapBuildNarrativa() top-level pure, _buildNarrativaCard() in cima

6. Test: b33_session_goal_picker (12), b33_studio_transition (4), b33_recap_narrativa (9)

### Navigazione corrente
- Shell: 3 tab (Home /home, Studi /studi, Profilo /profilo)
- Studio: /studio?tipo=media|ripasso, transizione slide-up+fade
- Recap: narrativa tutor in cima, poi stats

### Prossimo passo — B34
Fase 8: ridisegnare LearningPathScreen.
(1) Mappa lineare percorso (cerchi collegati)
(2) Zoom grafo completo
(3) Ricerca argomento
(4) Tap nodo apre quaderno (B35)

File: learning_path_screen.dart, widgets/, path_provider.dart, dydat_api_reference.md
