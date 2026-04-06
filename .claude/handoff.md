STATUS: CONTINUE
PHASE: 9
BLOCK: B35.5
SUMMARY: B38.5 chiuso (7 bug UI fixati, 459 test verdi). Pronti per due blocchi consecutivi: B35.5 Quaderno Enciclopedico (principale) + B35.6 Polish empty states (bonus). Specifiche concordate con Villa nella sessione di discussione strategica. Issue UX-01 (primo turno caldo) RIMANDATA, non fa parte di questa nottata.
NEXT: B35.6 — Polish empty states (immediatamente dopo B35.5)
DECISIONS_NEEDED: nessuna — Villa ha gia approvato struttura, sezioni, comportamenti. Lavorare in autonomia.
FILES_MODIFIED: nessuno in questa preparazione
TESTS: PASS (341 backend, 459 frontend, flutter analyze 0)
VERIFICATION: baseline verde, B38.5 commit f7da51f gia su origin/develop.

---

## ⚠️ ISTRUZIONI CRITICHE PER IL RUNNER

Stiamo facendo DUE blocchi consecutivi in una sola nottata. Per evitare loop come quello di B38.5, segui ESATTAMENTE questo flusso:

1. Esegui **B35.5** secondo la spec sotto.
2. Quando hai finito B35.5, aggiorna `handoff.md` settando `BLOCK: B35.6` (NON B39, NON B40) e `STATUS: CONTINUE`. Aggiorna ROADMAP.md marcando B35.5 come completato.
3. Esegui **B35.6** secondo la spec sotto.
4. Quando hai finito B35.6, aggiorna `handoff.md` settando `STATUS: PHASE_COMPLETE`. Aggiorna ROADMAP.md marcando B35.6 come completato.
5. **FERMATI**. Non avanzare a B39 senza una nuova decisione di Villa.

---

## BLOCCO 1 — B35.5 Quaderno Enciclopedico

### Obiettivo

Trasformare il `NodoQuadernoScreen` da semplice log dell'attivita personale a manuale didattico + log personale, usando i dati intrinseci gia presenti nella tabella `nodi` del DB. Decisione strategica concordata con Villa: il quaderno deve essere fruibile anche per nodi mai studiati.

### Backend

File: `backend/app/api/quaderno.py` (esistente, estendere) e `backend/app/services/quaderno_service.py` se esiste.

1. **Estendere `GET /quaderno/{nodo_id}`**: aggiungere al payload la "scheda intrinseca" del nodo letta direttamente dalla tabella `nodi`:
   - `definizione_testo` (da `definizioni_formali.testo` — oggetto JSONB)
   - `formule` (da `formule_proprieta` — array di `{latex, descrizione}`)
   - `esempi` (da `esempi_applicazione` — array di stringhe)
   - `errori_comuni` (da `errori_comuni` — array di `{tipo, descrizione, esempio_sbagliato, correzione, suggerimento}`)
   - `parole_chiave` (da `parole_chiave` — array di stringhe)

   Aggiungere anche `nota_utente: {testo, updated_at}` letta da `note_utente` filtrando per utente corrente + nodo.

2. **Nuovo endpoint `PUT /quaderno/{nodo_id}/nota`**: salva o aggiorna la nota personale dell'utente per quel nodo. Body: `{testo: string}`. Upsert sulla tabella `note_utente`. Restituisce la nota aggiornata.

3. **Test pytest**: almeno 6 nuovi test:
   - GET con scheda completa (nodo con tutti i JSONB popolati)
   - GET con scheda parziale (alcuni JSONB vuoti)
   - GET con nota utente esistente
   - GET con nota utente assente
   - PUT crea nota nuova
   - PUT aggiorna nota esistente
   - PUT unauthorized (no token)

### Frontend

#### Modelli

File: `frontend/lib/models/quaderno_nodo.dart` (estendere se esiste, altrimenti creare).

Aggiungere classi:
- `SchedaNodo { String? definizioneTesto; List<FormulaCurriculum> formule; List<String> esempi; List<ErroreComune> erroriComuni; List<String> paroleChiave; }`
- `FormulaCurriculum { String latex; String descrizione; }`
- `ErroreComune { String tipo; String descrizione; String esempioSbagliato; String correzione; String suggerimento; }`
- `NotaUtente { String? testo; DateTime? updatedAt; }`

Aggiornare `QuadernoNodo` esistente per includere `scheda` e `nota`. JSON mapping snake_case → camelCase nei `fromJson`.

#### Provider

File: `frontend/lib/providers/quaderno_provider.dart` (esistente).

Aggiungere azione `Future<void> saveNota(String nodoId, String testo)` che chiama il PUT, aggiorna lo stato locale e gestisce errori.

#### Schermata

File: `frontend/lib/presentation/quaderno_screen/nodo_quaderno_screen.dart` (esistente, riscrivere).

Struttura della pagina dall'alto in basso:

1. **Header**: back button + nome nodo + (eventuale menu)
2. **Breadcrumb**: nome tema parent + chip stato (Da iniziare / In corso / Operativo / Comprensivo)
3. **Chip parole chiave**: riga di chip piccoli scrollabile orizzontalmente (solo se `paroleChiave.isNotEmpty`)
4. **Sezione "Cosa imparerai"**: usa nuovo widget `CollapsibleText` con preview di 3 righe e bottone "Leggi tutto ▼". Solo se `definizioneTesto != null`.
5. **Sezione "Formule chiave"**: per ogni formula, una card con LaTeX renderizzato (usare `flutter_math_fork`, gia in pubspec) sopra e descrizione italiana sotto. Solo se `formule.isNotEmpty`. Nuovo widget `FormulaCurriculumCard`.
6. **Sezione "Esempi"**: lista con bullet, supporta LaTeX inline se presente. Solo se `esempi.isNotEmpty`.
7. **Sezione "Attenzione a..."**: per ogni errore, una card con accent rosso. Layout interno: chip piccolo con il `tipo` (concettuale/notazionale/procedurale) in alto, poi `descrizione`, poi blocco "Esempio sbagliato:" con `esempio_sbagliato` in monospace/rosso, poi blocco "Come evitarlo:" con `correzione` in verde, poi `suggerimento` in italic. Usa `colorScheme.error` e `colorScheme.tertiary`. Nuovo widget `ErroreComuneCard`. Solo se `erroriComuni.isNotEmpty`.
8. **Sezione "Le mie note"**: TextField multilinea espandibile con bottone "Salva". Salvataggio sia manuale (tap bottone) sia automatico debounced 1 secondo dopo l'ultima digitazione. Mostra un piccolo indicatore "Salvato ✓" sotto il campo dopo il save. Nuovo widget `NotaUtenteEditor`.
9. **Separator forte**: una `Divider` con label "— I tuoi appunti —" o un container ben marcato per separare visivamente la scheda intrinseca dal log personale.
10. **Sezioni log personale** (gia esistenti, mantenerle): esercizi svolti, formule viste in sessione, spiegazioni del tutor. Empty state gentile se vuote: "Non hai ancora fatto esercizi su questo nodo — inizia una sessione per popolare i tuoi appunti."

#### Empty states intelligenti

- Se UNA sezione intrinseca e vuota (es. `formule.isEmpty`), nasconde l'intera sezione (titolo incluso).
- Se TUTTE le sezioni intrinseche sono vuote, mostra in alto un messaggio gentile: "La scheda di questo nodo e in arrivo." Le sezioni log personale rimangono.
- Le note personali sono SEMPRE visibili (anche vuote): l'utente puo iniziare a scrivere le sue note in qualunque momento.

### Constraint

- `Theme.of(context)` obbligatorio. Zero colori hardcoded.
- Riverpod safety: niente provider update in initState/build/dispose (usare `Future.microtask`).
- LaTeX via `flutter_math_fork`. Niente WebView.
- JSON mapping snake_case → camelCase nei `fromJson`/`toJson`.
- Nessun refactoring bonus su altri file.

### Test widget frontend

Almeno 8 nuovi test:
- Rendering con scheda completa
- Rendering con scheda completamente vuota (empty state generale)
- Rendering con log personale vuoto (empty state log)
- CollapsibleText espande/collassa
- FormulaCurriculumCard renderizza LaTeX
- ErroreComuneCard mostra tutti i 5 campi
- NotaUtenteEditor: save manuale chiama provider
- NotaUtenteEditor: autosave debounced

### Gate di uscita B35.5

1. Backend: endpoint esteso, PUT nota funzionante, 6+ pytest verdi
2. Frontend: schermata riscritta con 10 sezioni, autosave nota, 8+ widget test
3. Tutti i test esistenti continuano a passare
4. `flutter analyze` 0 errori
5. `ruff check backend/app/` pulito
6. Commit atomico su develop con messaggio "B35.5 — Quaderno Enciclopedico"

### NON fare in B35.5

- Non implementare note multiple come diario (solo una nota per nodo)
- Non implementare entry point dal Studio screen
- Non implementare navigazione dettagli esercizio dal log
- Non toccare UX-01 primo turno caldo (B33.5 candidato, blocco separato)
- Non ri-importare dati dal curriculum

---

## BLOCCO 2 — B35.6 Polish Empty States

### Obiettivo

Bonus block: rivedere TUTTI gli empty state e i messaggi di benvenuto nelle varie schermate dell'app per essere contestuali rispetto allo stato dell'utente. Durante il test manuale Villa ha trovato testi tipo "Bentornato!" alla prima apertura o "Riprendi a studiare" per utenti nuovi (gia fixati in B38.5), ma probabilmente ce ne sono altri non scoperti.

### Cosa fare

Audit + fix dei seguenti punti:

1. **Profilo Tab**: cosa mostra per un utente con 0 sessioni e 0 achievement? Le statistiche zero sono ok ma:
   - Se `streak == 0 && nodi == 0 && sessioni == 0`: mostra messaggio gentile "Non hai ancora fatto sessioni — inizia dal tab Home!"
   - La sezione achievement gia mostra "Si parte!" sbloccato da default, ok.

2. **Sezione Ripasso in Home**: se `nodiDaRipassare.isEmpty`, oggi non mostra nulla. Va bene cosi, ma verificare che non ci sia stato uno spazio vuoto strano.

3. **I miei studi (search vuota)**: se l'utente cerca un termine che non matcha nessun nodo, cosa succede? Lista vuota? Mostrare un messaggio "Nessun nodo trovato per 'X'".

4. **Recap di una sessione conclusa con 0 esercizi**: la sessione e finita ma l'utente non ha fatto nessun esercizio. Il recap narrativo del tutor deve gestire questo caso (probabilmente gia lo fa, verificare).

5. **Quaderno per nodo**: gia gestito in B35.5.

6. **Storico sessioni (se accessibile da qualche parte)**: se utente nuovo, lista vuota. Verificare empty state.

7. **Login**: gia fixato in B38.5 con testo neutro.

8. **Onboarding** (saltato se gia fatto): no fix, sara riscritto in B39.

### Approccio

Procedi cosi:
1. Apri ciascuno dei file delle schermate elencate sopra.
2. Cerca pattern tipo `if (lista.isEmpty)`, `Container.empty`, `SizedBox.shrink`, `Text('Nessun...')`.
3. Verifica che ogni stato vuoto abbia: un messaggio chiaro, eventualmente un'icona, eventualmente una call-to-action.
4. Fix solo dove serve. Se uno stato e gia gestito bene, lascialo stare.
5. Aggiungi 2-4 widget test nuovi per i fix piu significativi.

### Constraint

- Non riscrivere niente di grosso. Solo polish.
- `Theme.of(context)` obbligatorio.
- Massimo 1-2 ore di lavoro stimato. Se vedi che servono modifiche grosse, fermati e segnale come "rimandato a blocco futuro".

### Gate di uscita B35.6

1. Empty states verificati e fixati nelle schermate elencate
2. 2-4 widget test nuovi
3. Tutti i test esistenti passano
4. `flutter analyze` 0 errori
5. Commit atomico "B35.6 — Polish empty states"

### NON fare in B35.6

- Non riscrivere schermate intere
- Non toccare il backend
- Non toccare l'onboarding (sara B39)
- Non aggiungere features nuove

---

## File da leggere per la sessione

1. CLAUDE.md
2. PROJECT_CONFIG.md
3. .claude/handoff.md (questo file)
4. .claude/test-findings.md (per contesto sui bug gia visti)
5. backend/app/api/quaderno.py
6. frontend/lib/presentation/quaderno_screen/nodo_quaderno_screen.dart
7. frontend/lib/models/quaderno_nodo.dart
8. frontend/lib/providers/quaderno_provider.dart
9. docs/dydat_api_reference.md (per il pattern degli endpoint)
10. frontend/lib/theme/surface_decorations.dart (per le superfici)

## Stato baseline
- Frontend: 459 test verdi, analyze 0
- Backend: 341 test verdi
- Branch: `develop`, ultimo commit `90969ec`

## NON fare (riepilogo)
- Non avanzare a B39 (Onboarding Wow) — quel blocco e separato
- Non implementare UX-01 primo turno caldo del tutor — sara B33.5 separato
- Non modificare la mascotte — pianificata riscrittura futura
- Non rifattorare file fuori scope
- Non aggiungere dipendenze nuove
- Non toccare il sistema di test del runner stesso
