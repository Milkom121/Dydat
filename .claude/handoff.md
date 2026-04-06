STATUS: CONTINUE
PHASE: 9
BLOCK: B38.5
SUMMARY: Fix chirurgico di 7 bug UI cosmetici emersi dal test manuale Fasi 7-9. Tutti i bug risolti, 11 nuovi test, 459 totale frontend verdi, analyze 0.
NEXT: B39 - Onboarding con Momento Wow (Fase 10)
DECISIONS_NEEDED: Nessuna
FILES_MODIFIED: mini_percorso_widget.dart, home_screen.dart, login_screen.dart, linear_path_map.dart, graph_overview.dart, learning_path_screen.dart, b34_linear_path_map_test.dart, b38_5_fix_ui_test.dart (nuovo), ROADMAP.md, PROJECT_CONFIG.md
TESTS: PASS (341 backend, 459 frontend, flutter analyze 0)
VERIFICATION: flutter analyze 0 errori, flutter test 459/459 passano (erano 448, +11 nuovi). Build OK.

---

## Contesto dettagliato

### Cosa e stato fatto
7 bug UI cosmetici fixati (BUG-01 a BUG-07). Vedi commit f7da51f per dettagli.

### Stato del progetto
- Frontend: 459 test verdi, analyze 0
- Backend: 341 test verdi (invariato)
- Branch: develop

### Prompt handoff
[Dydat] - Sessione S37 - Blocco B39 - Onboarding con Momento Wow
LEGGI: CLAUDE.md, PROJECT_CONFIG.md, ROADMAP.md, .claude/handoff.md, docs/dydat-ux-redesign-concept-v1.1.docx (sez. 4), frontend/lib/presentation/onboarding_screen/
COSA FARE: Ristrutturare onboarding. (1) Momento wow 30-60s. (2) Domande rapide. (3) Flusso tutor esistente. (4) Registrazione posticipata. (5) Mascotte.
GATE DI USCITA: Wow moment, domande rapide, registrazione posticipata, E2E, analyze 0, test verdi
NON fare: non toccare backend, non audio (B40), non refactoring bonus
