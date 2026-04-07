STATUS: CONTINUE
PHASE: 9
BLOCK: B35.5.3
SUMMARY: B35.5.2 completato. Nuovo endpoint PUT /quaderno/{nodo_id}/nota con upsert (SELECT + UPDATE/INSERT). Validazione Pydantic NotaUtenteRequest (min 1, max 10000 char). 5 nuovi test. 356 backend verdi, 10 skipped, ruff pulito.
NEXT: B35.5.3 — Frontend modelli + provider
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/app/api/quaderno.py, backend/tests/test_b35_quaderno.py
TESTS: PASS (356 backend, 459 frontend, flutter analyze 0)
VERIFICATION: 356 passed, 10 skipped, ruff clean su quaderno.py

---

## Contesto dettagliato

### Cosa e stato fatto
- Aggiunto schema Pydantic NotaUtenteRequest con validazione (testo: min 1, max 10000 char)
- Implementato endpoint PUT /quaderno/{nodo_id}/nota: verifica nodo esiste (404), cerca nota esistente, aggiorna o crea
- 5 nuovi test: creazione nuova nota, aggiornamento nota esistente, nodo inesistente 404, validazione testo vuoto, validazione testo troppo lungo

### Stato del progetto
- Backend: 356 test verdi, 10 skipped, ruff clean
- Frontend: 459 test verdi, analyze 0 (non toccato in questo blocco)

### Prossimo passo concreto
- B35.5.3: Nuovi modelli Dart SchedaNodo, FormulaCurriculum, ErroreComune, NotaUtente. Provider esteso con saveNota.
- Leggere i modelli esistenti in frontend/lib/models/quaderno_nodo.dart e il provider in frontend/lib/providers/quaderno_provider.dart

### File da leggere per la prossima sessione
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md
4. .claude/handoff.md
5. frontend/lib/models/quaderno_nodo.dart
6. frontend/lib/providers/quaderno_provider.dart
7. backend/app/api/quaderno.py (per sapere la struttura JSON da mappare)

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
| 3 | B35.5.3 | Frontend modelli + provider | B35.5.4 |
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
