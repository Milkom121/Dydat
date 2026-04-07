STATUS: CONTINUE
PHASE: 9
BLOCK: B35.5.1
SUMMARY: B38.5 chiuso (459 test, 7 bug UI fixati). Ricalibrazione granularita applicata: B35.5 Quaderno Enciclopedico spezzato in 5 sub-blocchi piccoli (B35.5.1-B35.5.5). Aggiunto B35.6 Polish empty states come 6° blocco. Runner ora usa --model opus. Obiettivo: ogni sub-blocco fattibile in una sessione 10-25 min usando max meta del context.
NEXT: B35.5.2 — Backend PUT nota utente
DECISIONS_NEEDED: nessuna — Villa ha approvato la ricalibrazione. Lavorare in autonomia.
FILES_MODIFIED: nessuno in questa preparazione
TESTS: PASS (341 backend, 459 frontend, flutter analyze 0)
VERIFICATION: baseline verde, modello opus configurato.

---

## ⚠️ ISTRUZIONI CRITICHE PER IL RUNNER

Stiamo facendo SEI sub-blocchi consecutivi in una sola nottata. Per evitare loop e mantenere ordine, segui ESATTAMENTE questo flusso:

1. Esegui il blocco corrente (vedi sotto la sequenza).
2. Quando hai finito un blocco, aggiorna `.claude/handoff.md` settando `BLOCK:` al PROSSIMO blocco della sequenza (vedi sotto), e `STATUS: CONTINUE`.
3. Aggiorna `ROADMAP.md` marcando come `[x] completato (Sxx)` il blocco appena finito, lasciando i successivi come `[ ] da fare`.
4. Continua col prossimo.
5. Quando hai finito **B35.6** (ultimo della sequenza), setta `STATUS: PHASE_COMPLETE` e **FERMATI**. Non avanzare a B39 senza nuova decisione di Villa.

## SEQUENZA BLOCCHI

| # | Blocco | Sintesi | Prossimo |
|---|---|---|---|
| 1 | **B35.5.1** | Backend GET quaderno esteso | B35.5.2 |
| 2 | **B35.5.2** | Backend PUT nota utente | B35.5.3 |
| 3 | **B35.5.3** | Frontend modelli + provider | B35.5.4 |
| 4 | **B35.5.4** | Frontend widget riutilizzabili | B35.5.5 |
| 5 | **B35.5.5** | Frontend integrazione schermata | B35.6 |
| 6 | **B35.6** | Polish empty states | (FERMATI, PHASE_COMPLETE) |

## FILOSOFIA RICALIBRATA

Ogni sub-blocco e progettato per essere FATTIBILE IN UNA SINGOLA SESSIONE del runner usando MASSIMO META' del context del modello (Opus 4.6). Linee guida:

- **Tocca pochi file** (1-3 file per blocco)
- **NON mescolare backend e frontend** in uno stesso blocco
- **NON anticipare lavoro di blocchi successivi**: se un blocco crea un widget, il blocco di integrazione viene DOPO
- **Test inclusi nel blocco** che ha la modifica (no blocchi separati "test")
- **Commit atomico** alla fine del blocco

---

# BLOCCO 1 — B35.5.1 Backend GET quaderno esteso

## Obiettivo
Estendere `GET /quaderno/{nodo_id}` per restituire anche la "scheda intrinseca" del nodo letta dalla tabella `nodi`. NON tocca PUT, NON tocca frontend.

## File da modificare
- `backend/app/api/quaderno.py` (esistente, estendere)
- Eventuale `backend/app/services/quaderno_service.py` se la logica e separata
- `backend/tests/test_quaderno.py` (esistente o nuovo, aggiungere 3 test)

## Cosa fare
1. Leggere il file dell'endpoint GET attuale per capire la struttura.
2. Aggiungere al payload restituito una nuova chiave `scheda` che contiene:
   - `definizione_testo`: stringa, da `nodi.definizioni_formali.testo` (oggetto JSONB; se NULL → null)
   - `formule`: array di `{latex, descrizione}` da `nodi.formule_proprieta` (array JSONB; se NULL → [])
   - `esempi`: array di stringhe da `nodi.esempi_applicazione` (array JSONB; se NULL → [])
   - `errori_comuni`: array di `{tipo, descrizione, esempio_sbagliato, correzione, suggerimento}` da `nodi.errori_comuni` (array JSONB; se NULL → [])
   - `parole_chiave`: array di stringhe da `nodi.parole_chiave` (array JSONB; se NULL → [])
3. Aggiungere anche `nota_utente: {testo, updated_at}` letta da `note_utente` filtrando per utente corrente + nodo. Se non esiste record → null.
4. Le sezioni esistenti del payload (esercizi, formule_viste, spiegazioni dal log personale) RESTANO invariate.
5. Schema Pydantic aggiornato di conseguenza.

## Test pytest (almeno 3)
1. GET con scheda completa (mock o fixture nodo con tutti i JSONB popolati): verifica che il payload contenga `scheda.definizione_testo`, `scheda.formule`, ecc.
2. GET con scheda parziale (alcuni JSONB null/vuoti): verifica fallback a [] o null.
3. GET con nota utente assente: `nota_utente == None`.

## Gate di uscita B35.5.1
- Endpoint GET esteso, schema aggiornato
- 3 test pytest verdi
- `pytest -x -q backend/tests/test_quaderno.py` passa
- `ruff check backend/app/api/quaderno.py` pulito
- Commit "B35.5.1 — Backend GET quaderno esteso con scheda intrinseca"

## NON fare in B35.5.1
- Non implementare PUT (è B35.5.2)
- Non toccare il frontend
- Non modificare lo schema DB (i campi gia esistono)
- Non modificare endpoint diversi da GET quaderno

---

# BLOCCO 2 — B35.5.2 Backend PUT nota utente

## Obiettivo
Nuovo endpoint per salvare/aggiornare la nota personale dell'utente per un nodo specifico.

## File da modificare
- `backend/app/api/quaderno.py` (aggiungere route PUT)
- Eventuale schema Pydantic per request/response
- `backend/tests/test_quaderno.py` (aggiungere 3 test)

## Cosa fare
1. Implementare `PUT /quaderno/{nodo_id}/nota`:
   - Body request: `{testo: str}`
   - Auth: utente corrente (come gli altri endpoint)
   - Logica: upsert su `note_utente` (chiave composta utente_id + nodo_id). Se la riga esiste → UPDATE testo + updated_at. Se non esiste → INSERT.
   - Response: `{testo, updated_at}` (la nota aggiornata)
2. Validazione: testo puo essere vuoto (l'utente puo cancellare la nota). Lunghezza max 10000 caratteri.

## Test pytest (almeno 3)
1. PUT crea nota nuova (utente non aveva nota su quel nodo)
2. PUT aggiorna nota esistente (verifica che updated_at cambi)
3. PUT senza autenticazione → 401

## Gate di uscita B35.5.2
- Endpoint PUT funzionante
- 3 test pytest verdi
- `pytest -x -q backend/tests/test_quaderno.py` passa (i test di B35.5.1 continuano a passare)
- `ruff check backend/app/api/quaderno.py` pulito
- Commit "B35.5.2 — Backend PUT nota utente"

## NON fare in B35.5.2
- Non toccare GET (è di B35.5.1)
- Non implementare cancellazione esplicita (DELETE) — basta PUT con stringa vuota
- Non note multiple per nodo (solo una)

---

# BLOCCO 3 — B35.5.3 Frontend modelli + provider

## Obiettivo
Aggiornare i modelli Dart e il provider Riverpod del quaderno per supportare i nuovi dati esposti dal backend.

## File da modificare
- `frontend/lib/models/quaderno_nodo.dart` (esistente, estendere)
- `frontend/lib/providers/quaderno_provider.dart` (esistente, estendere)
- Test unitari modello/provider (eventuale `frontend/test/models/`, `frontend/test/providers/`)

## Cosa fare
1. Aggiungere nuove classi Dart in `quaderno_nodo.dart`:
   - `class SchedaNodo { final String? definizioneTesto; final List<FormulaCurriculum> formule; final List<String> esempi; final List<ErroreComune> erroriComuni; final List<String> paroleChiave; ... }`
   - `class FormulaCurriculum { final String latex; final String descrizione; ... }`
   - `class ErroreComune { final String tipo; final String descrizione; final String esempioSbagliato; final String correzione; final String suggerimento; ... }`
   - `class NotaUtente { final String? testo; final DateTime? updatedAt; ... }`
2. Tutte con `fromJson`/`toJson` snake_case ↔ camelCase.
3. Aggiornare la classe esistente `QuadernoNodo` per includere `final SchedaNodo scheda;` e `final NotaUtente? nota;`.
4. In `quaderno_provider.dart`:
   - Aggiungere metodo `Future<void> saveNota(String nodoId, String testo)` che chiama il PUT, aggiorna lo stato locale (sostituendo `nota` nel `QuadernoNodo` corrente), gestisce errori.
   - Riverpod safety: niente provider update in initState/build/dispose.

## Test (almeno 3)
1. `SchedaNodo.fromJson` con payload completo
2. `SchedaNodo.fromJson` con campi vuoti/null (fallback)
3. `quadernoProvider.saveNota` (mock service) aggiorna lo stato

## Gate di uscita B35.5.3
- Modelli e provider aggiornati
- 3+ test verdi
- `flutter analyze` 0
- `flutter test test/models/ test/providers/` (se esistono) verde
- Commit "B35.5.3 — Frontend modelli e provider quaderno"

## NON fare in B35.5.3
- Non toccare la UI/schermata (sarà B35.5.5)
- Non creare widget (sono B35.5.4)
- Non modificare backend

---

# BLOCCO 4 — B35.5.4 Frontend widget riutilizzabili

## Obiettivo
Creare 4 nuovi widget Flutter riutilizzabili che verranno integrati nella schermata quaderno in B35.5.5. NON modifica ancora la schermata principale.

## File da creare (tutti nuovi)
- `frontend/lib/presentation/quaderno_screen/widgets/collapsible_text.dart`
- `frontend/lib/presentation/quaderno_screen/widgets/formula_curriculum_card.dart`
- `frontend/lib/presentation/quaderno_screen/widgets/errore_comune_card.dart`
- `frontend/lib/presentation/quaderno_screen/widgets/nota_utente_editor.dart`
- Test corrispondenti in `frontend/test/presentation/quaderno_screen/widgets/`

## Cosa fare

### CollapsibleText
- Stateful widget. Props: `String text`, `int previewLines = 3`.
- Mostra preview con maxLines + ellipsis. Bottone "Leggi tutto ▼" / "Mostra meno ▲" toggle.
- Solo testo, niente markdown. Theme.of(context).

### FormulaCurriculumCard
- Stateless widget. Props: `String latex`, `String descrizione`.
- Card con `DydatSurface.card()`. Dentro: LaTeX renderizzato con `flutter_math_fork` (Math.tex) sopra, descrizione italiana sotto.
- Gestione errore parsing LaTeX: fallback al testo grezzo.

### ErroreComuneCard
- Stateless widget. Props: `ErroreComune errore`.
- Card con accent rosso (`colorScheme.error`). Layout interno:
  - Chip piccolo con `errore.tipo` (concettuale/notazionale/procedurale)
  - `errore.descrizione` come testo principale
  - Blocco "Esempio sbagliato:" con `errore.esempioSbagliato` in monospace + accent rosso
  - Blocco "Come evitarlo:" con `errore.correzione` in verde (`colorScheme.tertiary`)
  - `errore.suggerimento` in italic come footer

### NotaUtenteEditor
- Stateful widget. Props: `String? initialText`, `Function(String) onSave`.
- TextField multilinea espandibile (max 6 righe, auto-grow).
- Bottone "Salva" manuale + autosave debounced 1 secondo dopo l'ultima digitazione.
- Indicatore "Salvato ✓" sotto il campo dopo il salvataggio (sparisce dopo 2s).

## Test widget (almeno 4, uno per widget)
1. CollapsibleText: tap su "Leggi tutto" toggla
2. FormulaCurriculumCard: renderizza LaTeX (verifica che Math widget sia presente)
3. ErroreComuneCard: mostra tutti i 5 campi
4. NotaUtenteEditor: tap su "Salva" chiama onSave; modifica testo + attesa 1s → autosave chiama onSave

## Gate di uscita B35.5.4
- 4 nuovi widget creati e isolati
- 4+ widget test verdi
- `flutter analyze` 0
- `flutter test test/presentation/quaderno_screen/widgets/` verde
- Commit "B35.5.4 — Frontend widget quaderno riutilizzabili"

## NON fare in B35.5.4
- Non integrare i widget nella schermata principale (è B35.5.5)
- Non modificare modelli o provider (sono di B35.5.3)
- Non toccare backend

---

# BLOCCO 5 — B35.5.5 Frontend integrazione schermata

## Obiettivo
Riscrivere `NodoQuadernoScreen` integrando i nuovi modelli/provider/widget creati nei blocchi precedenti, secondo la struttura concordata con Villa.

## File da modificare
- `frontend/lib/presentation/quaderno_screen/nodo_quaderno_screen.dart` (esistente, riscrivere)
- Test integrazione in `frontend/test/presentation/quaderno_screen/`

## Struttura della schermata (dall'alto in basso)

1. **Header**: AppBar con back + nome nodo
2. **Breadcrumb**: nome tema parent + chip stato (Da iniziare / In corso / Operativo / Comprensivo)
3. **Chip parole chiave**: riga horizontal scroll (solo se `paroleChiave.isNotEmpty`)
4. **Sezione "Cosa imparerai"**: `CollapsibleText(text: scheda.definizioneTesto!)` (solo se `definizioneTesto != null`)
5. **Sezione "Formule chiave"**: per ogni formula → `FormulaCurriculumCard(...)` (solo se `formule.isNotEmpty`)
6. **Sezione "Esempi"**: lista bullet (solo se `esempi.isNotEmpty`)
7. **Sezione "Attenzione a..."**: per ogni errore → `ErroreComuneCard(errore: ...)` (solo se `erroriComuni.isNotEmpty`)
8. **Sezione "Le mie note"**: `NotaUtenteEditor(initialText: nota?.testo, onSave: (t) => provider.saveNota(nodoId, t))`
9. **Separator** "— I tuoi appunti —" (Divider con label)
10. **Sezioni log personale** (gia esistenti): esercizi svolti, formule viste in sessione, spiegazioni del tutor — con empty state gentile se vuote

## Empty states intelligenti
- Se TUTTE le sezioni intrinseche sono vuote: messaggio in alto "La scheda di questo nodo è in arrivo."
- Sezioni log personale vuote: empty state gentile "Non hai ancora fatto esercizi su questo nodo — inizia una sessione per popolare i tuoi appunti."
- La sezione "Le mie note" è SEMPRE visibile, anche vuota.

## Test integrazione (almeno 3)
1. Rendering con scheda completa + log personale popolato
2. Rendering con scheda completa + log personale vuoto (verifica empty state log)
3. Rendering con scheda completamente vuota (verifica empty state generale + nota editor visibile)

## Gate di uscita B35.5.5
- Schermata riscritta usando widget di B35.5.4 e modelli di B35.5.3
- 3+ test integrazione verdi
- TUTTI i test esistenti del progetto continuano a passare (non solo i nuovi)
- `flutter analyze` 0
- Commit "B35.5.5 — Frontend integrazione schermata quaderno"

## NON fare in B35.5.5
- Non creare nuovi widget (devono già esistere da B35.5.4)
- Non modificare modelli (devono già esistere da B35.5.3)
- Non toccare backend

---

# BLOCCO 6 — B35.6 Polish empty states

## Obiettivo
Bonus block: audit + fix degli empty states e messaggi di benvenuto nelle varie schermate dell'app.

## Schermate da rivedere
- **Profilo Tab**: utente con 0 sessioni e 0 achievement → messaggio gentile contestuale
- **Sezione Ripasso in Home**: lista vuota → verificare che non ci sia spazio strano
- **I miei studi (search vuota)**: termine senza match → messaggio "Nessun nodo trovato per 'X'"
- **Recap di sessione conclusa con 0 esercizi**: gestione caso limite
- **Storico sessioni (se accessibile)**: empty state lista vuota
- **Login**: gia fixato in B38.5
- **Onboarding**: NO fix, sara riscritto in B39

## Approccio
1. Audit dei file delle schermate elencate
2. Cerca pattern `if (lista.isEmpty)`, `Container.empty`, `SizedBox.shrink`, ecc.
3. Verifica che ogni stato vuoto abbia: messaggio chiaro + eventuale icona + eventuale call-to-action
4. Fix solo dove serve, niente refactoring bonus
5. 2-4 widget test nuovi per i fix piu significativi

## Gate di uscita B35.6
- Empty states verificati e fixati nelle schermate elencate
- 2-4 widget test nuovi verdi
- TUTTI i test esistenti passano
- `flutter analyze` 0
- Commit "B35.6 — Polish empty states"
- Aggiorna handoff con `STATUS: PHASE_COMPLETE` e FERMATI

## NON fare in B35.6
- Non riscrivere schermate intere
- Non toccare backend
- Non toccare onboarding (sara B39)
- Non avanzare a B39 senza decisione di Villa

---

## File da leggere a inizio sessione (ognuno legge solo quelli del suo blocco)

### Tutti i blocchi leggono prima:
1. `CLAUDE.md`
2. `PROJECT_CONFIG.md`
3. `.claude/handoff.md` (questo)

### Backend (B35.5.1, B35.5.2):
4. `backend/app/api/quaderno.py`
5. `backend/tests/test_quaderno.py`
6. `backend/app/db/models/nodi.py` (per capire la struttura JSONB)
7. `backend/app/db/models/note_utente.py` (per la PUT)
8. `docs/dydat_api_reference.md`

### Frontend modelli/provider (B35.5.3):
4. `frontend/lib/models/quaderno_nodo.dart`
5. `frontend/lib/providers/quaderno_provider.dart`
6. `frontend/lib/services/quaderno_service.dart`

### Frontend widget (B35.5.4):
4. `frontend/lib/theme/surface_decorations.dart` (per superfici)
5. `frontend/lib/theme/app_theme.dart` (per colori semantici)
6. Esempi di widget esistenti per pattern (es. `frontend/lib/presentation/learning_path_screen/widgets/`)

### Frontend integrazione (B35.5.5):
4. `frontend/lib/presentation/quaderno_screen/nodo_quaderno_screen.dart` (esistente, da riscrivere)
5. I 4 widget creati in B35.5.4
6. I modelli di B35.5.3

### Polish (B35.6):
4. Schermate elencate sopra (audit on demand)

## Stato baseline
- Frontend: 459 test verdi, analyze 0
- Backend: 341 test verdi
- Branch: `develop`, ultimo commit `f0f5b35` (runner update)

## NON fare (riepilogo per tutti i blocchi)
- Non avanzare a B39 — quel blocco e separato
- Non implementare UX-01 primo turno caldo — sara B33.5
- Non modificare la mascotte
- Non rifattorare file fuori scope
- Non aggiungere dipendenze nuove
- Non toccare il sistema runner stesso
