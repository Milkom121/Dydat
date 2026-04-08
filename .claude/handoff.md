STATUS: CONTINUE
PHASE: 9
BLOCK: fix-bug-cosmetici
SUMMARY: B33.5 completato. Helper _preambolo_caldo + direttiva_spiegazione riscritta con 3 branch (nodo nuovo, nodo presunto, fallback) + direttiva_ripresa_sessione aggiornata + pass-through contesto.py. 14 nuovi test, 377 backend verdi (10 skipped).
NEXT: fix-bug-cosmetici - 5 bug UI frontend dal test manuale 6 aprile
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/app/llm/prompts/direttive.py, backend/app/core/contesto.py, backend/tests/test_contesto.py, backend/tests/test_direttive_primo_turno.py (nuovo)
TESTS: PASS (377 backend verdi, 10 skipped)
VERIFICATION: 377 test backend verdi, ruff pulito su file toccati, commit 8602b11

---

## ISTRUZIONI PER IL RUNNER - BLOCCO 2

### Branch
Lavora su develop. NON cambiare branch.

### Catena
Resta solo il blocco 2: fix-bug-cosmetici. Quando lo completi con test verdi, scrivi STATUS: PHASE_COMPLETE.

---

## BLOCCO 2 - fix-bug-cosmetici (frontend)

### Contesto
Cinque bug UI cosmetici emersi dal test manuale 2026-04-06 (vedi .claude/test-findings.md). Frontend Flutter only, nessuna modifica backend.

Bug da chiudere:
- BUG-01 Overflow 58px in MiniPercorsoWidget
- BUG-02 Riprendi a studiare mostrato anche per utente nuovo
- BUG-03 Bentornato in LoginScreen alla prima apertura
- BUG-05 GraphOverview nomi nodi troncati e sovrapposti (FIX PRUDENTE solo wrapping)
- BUG-07 GraphOverview vastita orizzontale eccessiva (FIX MINIMO solo zoom out iniziale)

### File da leggere PRIMA
1. .claude/test-findings.md (riferimento bug)
2. frontend/lib/presentation/home_screen/widgets/mini_percorso_widget.dart (BUG-01)
3. frontend/lib/presentation/home_screen/home_screen.dart (BUG-02)
4. frontend/lib/presentation/login_screen/login_screen.dart (BUG-03)
5. frontend/lib/presentation/learning_path_screen/widgets/graph_overview.dart (BUG-05, BUG-07)

### Fix specifici

BUG-01 - Overflow MiniPercorsoWidget
- File: frontend/lib/presentation/home_screen/widgets/mini_percorso_widget.dart (~riga 93)
- Fix: wrappa il Row in un SingleChildScrollView orizzontale con physics: ClampingScrollPhysics() e clipBehavior: Clip.hardEdge.

BUG-02 - Riprendi a studiare per utente nuovo
- File: frontend/lib/presentation/home_screen/home_screen.dart (bottone principale)
- Fix: condiziona il testo. Se sessionHistory vuota -> Inizia a studiare. Altrimenti -> Riprendi a studiare.

BUG-03 - Bentornato in LoginScreen alla prima apertura
- File: frontend/lib/presentation/login_screen/login_screen.dart
- Fix: testo generico Accedi a Dydat + sottotitolo Il tuo tutor personale SEMPRE.

BUG-05 - GraphOverview nomi tagliati (FIX PRUDENTE)
- File: frontend/lib/presentation/learning_path_screen/widgets/graph_overview.dart
- Fix: maxLines: 2 e overflow: TextOverflow.ellipsis sui nomi nodo. Solo wrapping.

BUG-07 - GraphOverview vastita orizzontale (FIX MINIMO)
- File: frontend/lib/presentation/learning_path_screen/widgets/graph_overview.dart
- Fix: minScale: 0.3, maxScale: 2.0, zoom-out iniziale (TransformationController con scale 0.6). Niente minimap.

### Test obbligatori
Crea frontend/test/widgets/fix_bug_cosmetici_test.dart con almeno 5 test:
1. MiniPercorsoWidget con 8 nodi non genera overflow exception
2. Bottone home mostra Inizia a studiare quando sessionHistory vuota
3. Bottone home mostra Riprendi a studiare quando sessionHistory ha almeno una sessione
4. LoginScreen mostra il nuovo testo neutro
5. GraphOverview con nodi a nome lungo non lancia overflow exception

### Gate di uscita BLOCCO 2
1. 5 bug fixati con commit atomico unico
2. 5+ test nuovi verdi
3. TUTTI i 588 test frontend continuano a passare
4. flutter analyze 0 errori
5. Aggiorna ROADMAP.md aggiungendo il blocco fix-bug-cosmetici
6. Aggiorna .claude/test-findings.md marcando BUG-01/02/03/05/07 come FIXED
7. Scrivi handoff con STATUS: PHASE_COMPLETE - il runner si ferma

### NON fare nel blocco 2
- Non toccare il backend
- Non toccare BUG-04 (LinearPathMap ridisegno)
- Non toccare BUG-06 (evidenziazione percorso attuale nel grafo)
- Non rifattorare codice fuori scope
- Non aggiungere dipendenze
- Non fare merge verso main

### Comandi frontend utili
cd frontend && flutter analyze && flutter test

---

## Stato baseline
- Branch: develop
- Backend: 377 test verdi, 10 skipped (post B33.5)
- Frontend: 588 test verdi, analyze 0
- Catena: fix-bug-cosmetici -> STOP
