STATUS: CONTINUE
PHASE: 9
BLOCK: B35.5.2
SUMMARY: B35.5.1 completato. GET /quaderno/{nodo_id} esteso con scheda intrinseca (definizione_testo, formule, esempi, errori_comuni, parole_chiave da JSONB nodi) + nota_utente (testo + updated_at da tabella note_utente). 3 nuovi test, 7 aggiornati.
NEXT: B35.5.2 — Backend PUT nota utente
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/app/api/quaderno.py, backend/tests/test_b35_quaderno.py
TESTS: PASS (351 backend, 459 frontend, flutter analyze 0)
VERIFICATION: 351 passed, 10 skipped, ruff clean su quaderno.py

---

## ISTRUZIONI CRITICHE PER IL RUNNER

### Branch dedicato
Stai lavorando sul branch **`wip/notte-quaderno-polish-2026-04-07`**, NON su `develop`. Regole branch:
- **NON fare `git checkout`** ad altri branch
- **NON fare merge verso develop o main** — Villa lo fara manualmente domani dopo review
- Tutti i commit vanno su `wip/notte-quaderno-polish-2026-04-07`

### Sequenza blocchi
| # | Blocco | Sintesi | Prossimo |
|---|---|---|---|
| 1 | **B35.5.1** | ~~Backend GET quaderno esteso~~ FATTO | B35.5.2 |
| 2 | **B35.5.2** | Backend PUT nota utente | B35.5.3 |
| 3 | **B35.5.3** | Frontend modelli + provider | B35.5.4 |
| 4 | **B35.5.4** | Frontend widget riutilizzabili | B35.5.5 |
| 5 | **B35.5.5** | Frontend integrazione schermata | B35.6 |
| 6 | **B35.6** | Polish empty states | B35.7 |
| 7 | **B35.7** | Pull-to-refresh sulle liste | B35.8 |
| 8 | **B35.8** | Snackbar errori user-friendly | B35.9 |
| 9 | **B35.9** | Loading skeleton al posto degli spinner | B35.10 |
| 10 | **B35.10** | Search mappa percorso con parole_chiave | B35.11 |
| 11 | **B35.11** | Coerenza tono di voce italiana | B35.12 |
| 12 | **B35.12** | Audit dev-shortcuts.md priorita alta | B35.13 |
| 13 | **B35.13** | Audit accessibilita base (Semantics) | (FERMATI, PHASE_COMPLETE) |

Quando hai finito **B35.13** (ultimo della sequenza), setta `STATUS: PHASE_COMPLETE` e **FERMATI**.
