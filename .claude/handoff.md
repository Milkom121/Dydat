STATUS: PHASE_COMPLETE
PHASE: 9
BLOCK: B35.14
SUMMARY: Fix chirurgico 7 bug UI post test manuale nottata. NB-01: FittedBox su FormulaCurriculumCard (formule LaTeX non sbordano piu). NB-02: nuovo EsempioInlineCard con rendering LaTeX intelligente (Math.tex + fallback Text). NB-03: nuovo pluralize.dart con 5 funzioni singolare/plurale, applicato in stato_header e welcome_header. NB-04: separator log personale sempre visibile + empty state gentile quando nessun log. NB-05: verificato che userFriendlyError era gia presente (nessun fix necessario). NB-06: icona nodi non iniziati da lock_outline a circle_outlined. NB-07: rimosso SizedBox(height:80) fisso in MiniPercorsoWidget + FittedBox su nomi nodo per TextScaler aumentato.
NEXT: Merge wip/notte-quaderno-polish-2026-04-07 to develop (manuale Villa), poi B39 Fase 10 Onboarding con Momento Wow.
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: formula_curriculum_card.dart, nodo_quaderno_screen.dart, linear_path_map.dart, mini_percorso_widget.dart, stato_header.dart, welcome_header.dart, NUOVO pluralize.dart, NUOVO esempio_inline_card.dart, test-findings-nottata.md, ROADMAP.md, b35_14_fix_nottata_test.dart, b35_5_5_quaderno_integration_test.dart (aggiornato), b35_quaderno_screen_test.dart (aggiornato)
TESTS: PASS (577 frontend verdi, flutter analyze 0 errori)
VERIFICATION: flutter analyze 0 issues. flutter test 577 verdi (564 baseline + 13 nuovi). 2 test esistenti aggiornati per riflettere il nuovo comportamento NB-04 (separator sempre visibile). Nessun test rotto.

---

## Prompt handoff prossima sessione

[Dydat] - Sessione S50 - Blocco B39 - Onboarding con Momento Wow
LEGGI: CLAUDE.md, PROJECT_CONFIG.md, ROADMAP.md, .claude/handoff.md, docs/dydat-ux-redesign-concept-v1.1.docx (sezioni 4, 11), frontend/lib/presentation/onboarding_screen/
COSA FARE: Ristrutturare onboarding - (1) Momento wow 30-60s con visualizzazione animata, (2) Domande rapide, (3) Flusso tutor esistente, (4) Registrazione posticipata, (5) Mascotte compare qui per la prima volta
GATE DI USCITA: Wow moment funziona, domande rapide, registrazione posticipata, flusso E2E, analyze 0, test verdi
NON fare: non toccare backend (salvo nuovi endpoint se necessario), non anticipare B40 audio
