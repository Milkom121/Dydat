STATUS: CONTINUE
PHASE: 9
BLOCK: B35.14
SUMMARY: Nottata B35.5.1-B35.13 completata e testata manualmente da Villa. Trovati 7 bug UI/UX (NB-01..NB-07). B35.14 e un blocco di fix chirurgico per risolverli tutti prima del merge wip→develop. Branch attuale: wip/notte-quaderno-polish-2026-04-07. Modello: opus.
NEXT: Merge wip/notte-quaderno-polish-2026-04-07 → develop (manuale, dopo il fix verificato)
DECISIONS_NEEDED: nessuna — Villa ha approvato la lista bug. Lavorare in autonomia.
FILES_MODIFIED: nessuno in questa preparazione
TESTS: PASS (363 backend, 564 frontend, flutter analyze 0 — baseline da fine nottata)
VERIFICATION: baseline verde post-nottata, branch wip pulito.

---

## ⚠️ ISTRUZIONI CRITICHE PER IL RUNNER

### Branch dedicato
Stai lavorando sul branch **`wip/notte-quaderno-polish-2026-04-07`**, NON su `develop`. Prosegui qui. NON fare checkout, NON fare merge.

### Singolo blocco
B35.14 e UN SOLO blocco. Quando hai finito setta `STATUS: PHASE_COMPLETE` e fermati. NON avanzare ad altri blocchi.

### Approccio
B35.14 contiene 7 fix puntuali su 4 file. Falli **uno alla volta**, esegui i test dopo ognuno, commit atomico finale alla fine. Se uno dei fix rompe qualcosa, ferma tutto e segnala STATUS: ERROR.

---

# B35.14 — Fix post-test manuale nottata

## Contesto
Villa ha eseguito un test manuale completo dei 13 blocchi della nottata su emulatore. 5 scenari su 8 PASS senza problemi. 7 bug raccolti, dettaglio in `.claude/test-findings-nottata.md`.

## File da toccare (esattamente questi, niente di piu)
1. `frontend/lib/presentation/quaderno_screen/widgets/formula_curriculum_card.dart`
2. `frontend/lib/presentation/quaderno_screen/nodo_quaderno_screen.dart`
3. `frontend/lib/presentation/learning_path_screen/widgets/linear_path_map.dart`
4. `frontend/lib/presentation/home_screen/widgets/mini_percorso_widget.dart`
5. (NUOVO) `frontend/lib/utils/pluralize.dart`
6. (NUOVO) `frontend/lib/presentation/quaderno_screen/widgets/esempio_inline_card.dart`

## Bug da fixare

### NB-01 — Formule LaTeX troppo grandi
- **File**: `formula_curriculum_card.dart`
- **Sintomo**: Math.tex sborda dalla card lateralmente, l'utente deve scrollare orizzontalmente per leggere
- **Stato attuale codice** (riga 32-49): la formula e gia in `SingleChildScrollView` orizzontale, con `Math.tex(textStyle: TextStyle(fontSize: 16.sp))`. Il problema e che 16.sp e troppo grande per molte formule.
- **Fix obbligatorio**:
  1. Wrappare `Math.tex` in `FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.center, child: ...)` cosi le formule grandi vengono rimpicciolite automaticamente per stare nella card senza scroll
  2. Mantenere `SingleChildScrollView` come fallback per formule davvero enormi
  3. Ridurre il `fontSize` del textStyle da `16.sp` a `20.sp` come dimensione di partenza (FittedBox lo ridurra dove serve)
- **Test obbligatorio**: aggiungere widget test che verifica `FormulaCurriculumCard` con formula lunga (es. la formula `(-a)^n = \\begin{cases}...\\end{cases}` di "Potenza di un numero relativo") NON genera RenderFlex overflow.

### NB-02 — LaTeX negli "Esempi" non renderizzato
- **File**: `nodo_quaderno_screen.dart` + nuovo widget `esempio_inline_card.dart`
- **Sintomo**: la sezione "Esempi" del quaderno mostra esempi come testo plain. Quando un esempio contiene LaTeX (es. `(-2)^{-3} = \\frac{1}{(-2)^3}`), si vede il codice grezzo `\frac{1}{8}` invece della frazione renderizzata.
- **Fix obbligatorio**:
  1. Creare nuovo widget `EsempioInlineCard(String esempio)` in `frontend/lib/presentation/quaderno_screen/widgets/esempio_inline_card.dart`
  2. Logica: se l'esempio contiene marcatori LaTeX (`\\`, `^{`, `_{`, `\frac`, `\begin`, ecc.), tenta `Math.tex(esempio)` con `onErrorFallback: (e) => Text(esempio)`. Altrimenti `Text(esempio)` diretto.
  3. Helper di detection: `bool _looksLikeLaTeX(String s)` che ritorna true se trova almeno uno dei marcatori sopra.
  4. Wrappare la formula in `FittedBox(fit: BoxFit.scaleDown)` come per NB-01 per evitare overflow.
  5. Modificare `nodo_quaderno_screen.dart` sezione Esempi per usare `EsempioInlineCard` invece di `Text` plain.
- **Test obbligatorio**:
  - widget test che `EsempioInlineCard` con esempio plain `"(-3)^4 = 81"` mostra Text
  - widget test che `EsempioInlineCard` con `"(-2)^{-3} = \\frac{1}{8}"` mostra Math (nessuna stringa "\\frac" visibile)

### NB-03 — Singolare/plurale italiano (ricorrente)
- **File**: nuovo `frontend/lib/utils/pluralize.dart` + uso in `nodo_quaderno_screen.dart` + uso in profile screen
- **Sintomo**: in piu schermate compaiono testi tipo "1 sessioni", "1 giorni" invece di "1 sessione", "1 giorno"
- **Fix obbligatorio**:
  1. Creare nuovo file `frontend/lib/utils/pluralize.dart` con funzioni:
     ```dart
     String sessione(int n) => n == 1 ? '$n sessione' : '$n sessioni';
     String giorno(int n) => n == 1 ? '$n giorno' : '$n giorni';
     String esercizio(int n) => n == 1 ? '$n esercizio' : '$n esercizi';
     String nodo(int n) => n == 1 ? '$n nodo' : '$n nodi';
     ```
  2. Cercare nel codebase frontend stringhe tipo `'$n sessioni'`, `'${...} sessioni'`, `'${...} giorni'`, ecc. e sostituirle con le funzioni dell'helper.
  3. Punti d'uso noti: chip statistiche del Quaderno (`nodo_quaderno_screen.dart`), card statistiche del Profilo (`profile_screen.dart` o sue widget tipo `stats_card.dart`).
- **Test obbligatorio**: 3 unit test che verificano `sessione(0)`, `sessione(1)`, `sessione(5)` ritornano stringhe corrette.

### NB-04 — Log personale nascosto se vuoto, manca empty state
- **File**: `nodo_quaderno_screen.dart` righe 197-224
- **Sintomo**: quando il nodo non ha esercizi/formule/spiegazioni, sotto "Le mie note" non c'e niente. Manca il separator e un messaggio gentile.
- **Stato attuale codice**: `if (_hasLogPersonale(quaderno)) ... { separator + sezioni }`
- **Fix obbligatorio**:
  1. Mostrare SEMPRE il separator "— I tuoi appunti —" sotto la sezione note (rimuovere il check `_hasLogPersonale`)
  2. Quando `_hasLogPersonale` e false, dopo il separator mostrare un Container con:
     - Icona libro (`Icons.menu_book_outlined` o simile)
     - Testo: "Non hai ancora fatto sessioni su questo nodo. Inizia una sessione per popolare i tuoi appunti."
     - Stile: card grigia (`colorScheme.surfaceContainerHighest`), padding generoso, testo centrato
     - NESSUN bottone (l'utente puo tornare in Home da solo)
  3. Quando `_hasLogPersonale` e true, mostrare le sezioni come ora (formule, esercizi, spiegazioni)
- **Test obbligatorio**: widget test che `NodoQuadernoScreen` con `quaderno` con log personale vuoto mostra il messaggio empty state.

### NB-05 — Errore quaderno offline generico, non sfrutta helper
- **File**: `nodo_quaderno_screen.dart` (gestione stato error)
- **Sintomo**: in modalita aereo, aprendo un quaderno non in cache appare "Errore caricamento quaderno" hardcoded. Non usa l'helper `userFriendlyError` di B35.8.
- **Fix obbligatorio**:
  1. Trovare nel file dove viene mostrato il messaggio di errore (probabilmente in un widget che gestisce stato `quadernoState.error`)
  2. Sostituire la stringa hardcoded con `userFriendlyError(state.error)` (l'helper e in `frontend/lib/utils/error_messages.dart` creato in B35.8)
  3. Verificare import del helper
- **Test obbligatorio**: widget test che mock dello stato error con `DioException` di tipo `connectionError` mostra "Connessione assente" (o quello che restituisce l'helper per quel caso).

### NB-06 — Lucchetto sui nodi "da iniziare" (regressione B38.5)
- **File**: `linear_path_map.dart` riga 287
- **Sintomo**: nella mappa lineare di "I miei studi", i nodi "da iniziare" mostrano un lucchetto. Semantica errata perche i nodi sono accessibili.
- **Stato attuale**: `case _NodeState.nonIniziato: return 'lock_outline';`
- **Fix obbligatorio**:
  1. Sostituire `'lock_outline'` con `'circle_outlined'` (cerchio vuoto, neutrale)
  2. Verificare anche `_circleColor` e `_circleBorderColor` per `_NodeState.nonIniziato` — devono essere visivamente distinti ma non comunicare "bloccato"
  3. NON introdurre uno stato "bloccato" (Villa ha detto: nessun nodo e davvero bloccato per ora)
- **Test obbligatorio**: widget test che `LinearPathMap` con nodo `livello: 'da_iniziare'` NON contiene icona `lock_outline` ma contiene `circle_outlined`.

### NB-07 — Overflow MiniPercorso con TextScaler aumentato
- **File**: `mini_percorso_widget.dart` riga 130 (Column principale)
- **Sintomo**: con TextScaler di sistema aumentato (es. 1.3x), la Column del MiniPercorsoWidget genera "RenderFlex overflowed by 6.6 pixels on the bottom"
- **Fix obbligatorio**:
  1. Rimuovere eventuali altezze fisse della Column o dei suoi figli
  2. Verificare che i Text non siano dentro Container con altezza fissa
  3. Wrappare i Text che mostrano nomi nodo in `Flexible` se sono in una Row, oppure in `FittedBox(fit: BoxFit.scaleDown)` se sono in una Column ad altezza limitata
  4. In ultima istanza: aumentare leggermente l'altezza fissa del widget se necessario, ma preferire soluzioni reattive
- **Test obbligatorio**: widget test che `MiniPercorsoWidget` con `MediaQuery(textScaler: TextScaler.linear(1.5), child: ...)` non genera overflow.

## Gate di uscita B35.14
1. Tutti i 7 bug fixati come descritto
2. 6+ widget test nuovi/aggiornati (uno minimo per bug, eccetto NB-03 che ha 3 unit test)
3. `flutter analyze` 0 errori
4. `flutter test` verde (TUTTI i test, non solo i nuovi). Se test esistenti si rompono per le modifiche, aggiornarli.
5. `pytest -x -q` backend verde (anche se non dovrebbe essere toccato)
6. Commit atomico unico "B35.14 — Fix post-test manuale nottata: 7 bug NB-01..NB-07"
7. Aggiornare ROADMAP.md aggiungendo B35.14 come completato sotto Fase 9
8. Aggiornare `.claude/test-findings-nottata.md` marcando ogni bug come "FIXATO in B35.14" (non rimuovere il dettaglio)
9. Setta `STATUS: PHASE_COMPLETE` nel handoff e fermati

## NON fare in B35.14
- Non toccare backend (i fix sono tutti frontend)
- Non rifattorare file fuori scope
- Non aggiungere dipendenze nuove
- Non avanzare ad altri blocchi dopo B35.14
- Non fare merge verso develop (Villa lo fara manualmente)
- Non toccare la mascotte
- Non toccare il sistema runner

## File da leggere a inizio sessione
1. `CLAUDE.md`
2. `PROJECT_CONFIG.md`
3. `.claude/handoff.md` (questo)
4. `.claude/test-findings-nottata.md` (dettaglio bug)
5. I 4 file da modificare elencati sopra
6. `frontend/lib/utils/error_messages.dart` (per NB-05, helper esistente di B35.8)
7. `frontend/lib/theme/surface_decorations.dart` (per coerenza superfici)
