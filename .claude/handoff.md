STATUS: CONTINUE
PHASE: 9
BLOCK: B35.5.4
SUMMARY: B35.5.3 completato. 4 nuovi modelli Dart (FormulaCurriculum, ErroreComune, SchedaNodo, NotaUtente) + QuadernoNodo esteso con scheda/notaUtente/copyWith. QuadernoState con isSaving. PathService.saveNotaUtente() PUT. QuadernoNotifier.saveNota(). 15 nuovi test. 474 frontend verdi, analyze 0.
NEXT: B35.5.4 — Frontend widget riutilizzabili (CollapsibleText, FormulaCurriculumCard, ErroreComuneCard, NotaUtenteEditor)
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: frontend/lib/models/quaderno.dart, frontend/lib/models/quaderno.g.dart, frontend/lib/config/api_config.dart, frontend/lib/services/path_service.dart, frontend/lib/providers/quaderno_provider.dart, frontend/test/models/quaderno_test.dart, frontend/test/providers/quaderno_provider_test.dart
TESTS: PASS (356 backend, 474 frontend, flutter analyze 0)
VERIFICATION: 474 passed, analyze 0, build OK

---

## Contesto dettagliato

### Cosa e stato fatto
- Aggiunti 4 nuovi modelli Dart in quaderno.dart: FormulaCurriculum (latex+descrizione), ErroreComune (tipo/descrizione/esempioSbagliato/correzione/suggerimento), SchedaNodo (definizioneTesto/formule/esempi/erroriComuni/paroleChiave), NotaUtente (testo/updatedAt)
- QuadernoNodo esteso con campi scheda (SchedaNodo?) e notaUtente (NotaUtente?) + metodo copyWith
- QuadernoState esteso con campo isSaving per feedback salvataggio
- PathService: aggiunto saveNotaUtente(nodoId, testo) -> PUT /quaderno/{nodoId}/nota
- QuadernoNotifier: aggiunto saveNota(nodoId, testo) con aggiornamento stato locale
- ApiConfig: aggiunto quadernoNota(nodoId)
- Rigenerato quaderno.g.dart con build_runner
- 15 nuovi test: FormulaCurriculum (3), ErroreComune (2), SchedaNodo (2), NotaUtente (2), QuadernoNodo con scheda/nota (3), QuadernoState isSaving (3)

### Stato del progetto
- Backend: 356 test verdi, 10 skipped (non toccato in questo blocco)
- Frontend: 474 test verdi, analyze 0

### Prossimo passo concreto
- B35.5.4: 4 nuovi widget isolati: CollapsibleText, FormulaCurriculumCard (LaTeX), ErroreComuneCard (accent rosso), NotaUtenteEditor (autosave debounced)
- Creare in frontend/lib/presentation/quaderno_screen/widgets/
- Usare i modelli creati in B35.5.3 (FormulaCurriculum, ErroreComune, NotaUtente)
- Widget devono usare Theme.of(context), zero colori hardcoded

### File da leggere per la prossima sessione
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md
4. .claude/handoff.md
5. frontend/lib/models/quaderno.dart (modelli appena creati)
6. frontend/lib/providers/quaderno_provider.dart (provider con saveNota)
7. frontend/lib/presentation/quaderno_screen/nodo_quaderno_screen.dart (schermata esistente)

## ISTRUZIONI CRITICHE PER IL RUNNER

### Branch dedicato
Stai lavorando sul branch wip/notte-quaderno-polish-2026-04-07, NON su develop. Regole branch:
- NON fare git checkout ad altri branch
- NON fare merge verso develop o main — Villa lo fara manualmente domani dopo review
- Tutti i commit vanno su wip/notte-quaderno-polish-2026-04-07

### Sequenza blocchi
| # | Blocco | Sintesi | Prossimo |
|---|---|---|---|
| 1 | B35.5.1 | ~~Backend GET quaderno esteso~~ FATTO | B35.5.2 |
| 2 | B35.5.2 | ~~Backend PUT nota utente~~ FATTO | B35.5.3 |
| 3 | B35.5.3 | ~~Frontend modelli + provider~~ FATTO | B35.5.4 |
| 4 | B35.5.4 | Frontend widget riutilizzabili | B35.5.5 |
| 5 | B35.5.5 | Frontend integrazione schermata | B35.6 |
| 6 | B35.6 | Polish empty states | B35.7 |
| 7 | B35.7 | Pull-to-refresh sulle liste | B35.8 |
| 8 | B35.8 | Snackbar errori user-friendly | B35.9 |
| 9 | B35.9 | Loading skeleton al posto degli spinner | B35.10 |
| 10 | B35.10 | Search mappa percorso con parole_chiave | B35.11 |
| 11 | B35.11 | Coerenza tono di voce italiana | B35.12 |
| 12 | B35.12 | Audit dev-shortcuts.md priorita alta | B35.13 |
| 13 | B35.13 | Audit accessibilita base (Semantics) | (FERMATI, PHASE_COMPLETE) |

Quando hai finito B35.13 (ultimo della sequenza), setta STATUS: PHASE_COMPLETE e FERMATI.
