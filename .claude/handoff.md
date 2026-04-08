STATUS: CONTINUE
PHASE: 9
BLOCK: B33.5
SUMMARY: Catena notturna 2 blocchi: (1) B33.5 Primo turno caldo del tutor (backend prompts), (2) fix-bug-cosmetici (frontend). Baseline pulita su develop dopo merge wip/B36-font-scale.
NEXT: B33.5 — implementare primo turno caldo seguendo decisioni UX-01
DECISIONS_NEEDED: nessuna — tutte le decisioni di design sono in docs/discussions/ux-01-primo-turno-caldo.md
FILES_MODIFIED: nessuno in questa preparazione
TESTS: PASS (588 frontend verdi, 363 backend verdi, analyze 0)
VERIFICATION: baseline verde su develop al merge commit di wip/B36-font-scale

---

## ⚠️ ISTRUZIONI CRITICHE PER IL RUNNER NOTTURNO

### Branch
Lavora su **`develop`**. NON cambiare branch. Commit autonomi su develop sono OK (Metodo Villa).

### Catena di 2 blocchi
Questa sessione runner deve eseguire **2 blocchi in sequenza**:
1. **B33.5 — Primo turno caldo del tutor** (backend, vedi sotto)
2. **fix-bug-cosmetici — 5 bug UI dal test manuale 6 aprile** (frontend, specifiche piu sotto)

Quando completi B33.5 con test verdi e ti senti pronto per il secondo blocco:
- scrivi `STATUS: CONTINUE` nell'handoff
- nel campo `NEXT:` indica `fix-bug-cosmetici`
- USA IL TEMPLATE per il blocco 2 che trovi nella sezione "PROSSIMO BLOCCO" piu sotto e copialo dentro l'handoff come nuove istruzioni per la prossima iterazione del runner

Quando completi anche il blocco 2 con test verdi:
- scrivi `STATUS: PHASE_COMPLETE`
- il runner si ferma

Se uno dei due blocchi rompe i test e non riesci a fixare: `STATUS: ERROR`, il runner si ferma e Villa interviene di mattina.

### Regole generali catena
- Commit atomici separati per ogni blocco (mai mescolare backend B33.5 e frontend bug-fix nello stesso commit)
- Aggiorna ROADMAP.md a fine di ogni blocco
- Aggiorna `.claude/decisions.md` solo se prendi una decisione architetturale non gia documentata
- NON toccare main, NON fare merge verso main, NON cambiare branch

---

# BLOCCO 1 — B33.5 Primo turno caldo del tutor

## Contesto
Durante il test manuale del 2026-04-06 Villa ha registrato un nuovo utente, completato l'onboarding rispondendo in dettaglio (sta riprendendo dopo una pausa, studia per curiosita personale, preferisce esempi concreti, sicuro 4/5 sulle operazioni base) e ha avviato la prima sessione di studio. Il tutor e partito direttamente con l'esempio dei cioccolatini, senza saluto contestualizzato, senza usare il nome, senza riconoscere il profilo dell'onboarding, senza presentare il nodo, senza riconoscere il ritmo scelto.

Il fix e chirurgico: la funzione `direttiva_spiegazione` in `backend/app/llm/prompts/direttive.py` istruisce esplicitamente il tutor a partire con un esempio concreto. Va riscritta perche generi un primo messaggio "caldo" a tre battute.

## File da leggere PRIMA di toccare codice
1. `CLAUDE.md` (regole progetto)
2. `PROJECT_CONFIG.md` (stack)
3. `docs/discussions/ux-01-primo-turno-caldo.md` ⭐ **FONTE DI VERITA per le 7 decisioni di design** — leggilo TUTTO
4. `.claude/test-findings.md` (sezione UX-01)
5. `backend/app/llm/prompts/direttive.py` (codice attuale)
6. `backend/app/llm/prompts/system_prompt.py` (NON modificare, solo leggere per capire il tono del tutor)
7. `backend/app/core/contesto.py` (per capire come arriva il contesto al tutor)
8. `backend/tests/test_direttive.py` se esiste, altrimenti cerca test di prompt esistenti per pattern

## Cosa implementare

### A. Helper `_preambolo_caldo` (NUOVO, in `direttive.py`)

Funzione privata che genera un preambolo riutilizzabile composto da:
1. **Saluto contestualizzato** che usa il nome utente
2. **Riconoscimento del profilo** parafrasato (NON verbatim) usando i campi `chi_e`, `motivo`, `stile_cognitivo` dal profilo onboarding
3. **Citazione leggera del ritmo scelto** (Veloce 15 / Normale 30 / Approfondita 60 minuti)

Parametri della funzione:
- `nome_utente: str`
- `profilo_sintetizzato: dict | None` (puo essere None se utente non ha completato onboarding)
- `ritmo_minuti: int | None` (puo essere None)

Output: stringa di istruzioni in italiano per il tutor, che gli dice COME comporre queste tre cose nel suo primo messaggio. NON e un template fisso, sono istruzioni di prompt.

Esempio di output (concettuale):
```
Apri con un saluto caldo che usa il nome "Verdan". Riconosci con UNA frase, parafrasata e naturale, che l'utente sta riprendendo dopo una pausa e che studia per curiosita personale (NON ripetere alla lettera, parafrasa). Cita con leggerezza i ~30 minuti che avete insieme oggi ("una mezz'ora", "un po' di tempo insieme", non come scadenza). Il tono e caldo ma non smielato, professionale ma non freddo.
```

### B. Riscrittura `direttiva_spiegazione`

Aggiungi 2 nuovi parametri:
- `nome_utente: str`
- `nodo_presunto: bool = False`

Comportamento:
- Chiama `_preambolo_caldo(nome_utente, profilo, ritmo)` per generare la prima parte
- Aggiunge istruzioni specifiche per il primo messaggio di SPIEGAZIONE NUOVO NODO:
  - dopo il preambolo caldo, presentare il nodo con un **micro-indice discorsivo** (NON bullet list): "Oggi vediamo X, prima Y, poi Z, e ci giochiamo un po'"
  - chiudere con UNA domanda aperta di warm-up rispondibile da chi non sa ancora niente
  - tutto in **un singolo messaggio** con tre paragrafi visivamente distinti
  - 8-10 righe massimo, niente muri di testo
- **Branch nodo_presunto=True**: variante del messaggio che NON parte con la spiegazione ma con una "verifica veloce" — dopo il saluto, tutor riconosce che dal placement test il nodo risulta gia familiare, propone una domanda-sonda sul concetto. Se l'utente risponde bene si va avanti, se sbaglia il tutor "scende" in modalita spiegazione normale (questo lato e gestito in turni successivi, qui basta che il PRIMO messaggio sia di tipo verifica).

### C. Riscrittura `direttiva_ripresa_sessione`

Modifica per chiamare anche lei `_preambolo_caldo`. Oggi ha gia un saluto: arricchiscilo con riconoscimento del profilo e citazione del ritmo, mantenendo la sua specificita di "ripresa di una sessione interrotta" (la mappa breve e diversa: "ripartiamo da dove ci siamo fermati").

### D. Pass-through in `contesto.py`

Verifica che `nome_utente` e `nodo_presunto` arrivino come argomenti espliciti alla `direttiva_spiegazione`. Se oggi non arrivano:
- estrai `nome_utente` dal dato dell'utente che gia transita nel contesto
- estrai `nodo_presunto` dal nodo corrente (campo che indica se il placement test l'ha marcato come padroneggiato — verifica come si chiama nel modello, candidati: `presunto_padroneggiato`, `placement_known`, ecc.)

NON modificare lo schema DB. NON modificare il system_prompt. NON toccare il frontend.

### E. Test obbligatori

Crea `backend/tests/test_direttive_primo_turno.py` con almeno **6 test**:

1. `_preambolo_caldo` con tutti i campi presenti contiene il nome utente
2. `_preambolo_caldo` con profilo None genera comunque un saluto valido (no crash)
3. `_preambolo_caldo` con ritmo 15 cita "veloce" o "quindici" o equivalente; con 30 cita "mezz'ora" o "trenta"; con 60 cita "un'ora"
4. `direttiva_spiegazione` con `nodo_presunto=False` istruisce il tutor a fare presentazione + warm-up
5. `direttiva_spiegazione` con `nodo_presunto=True` istruisce il tutor a fare verifica veloce invece di spiegazione
6. `direttiva_ripresa_sessione` chiama `_preambolo_caldo` (verifica che il preambolo sia presente nell'output)

I test sono semplici: le direttive sono funzioni pure che ritornano stringhe, basta verificare che certe sottostringhe siano presenti.

## Gate di uscita B33.5
1. `_preambolo_caldo` implementato e testato
2. `direttiva_spiegazione` riscritta con nuovi parametri e branch nodo_presunto
3. `direttiva_ripresa_sessione` aggiornata
4. `contesto.py` pass-through dei nuovi parametri
5. 6+ test nuovi verdi
6. **TUTTI i 363 test backend continuano a passare**
7. `docker exec backend-backend-1 python -m ruff check app/` 0 errori
8. Commit atomico unico: "B33.5 — Primo turno caldo del tutor (preambolo helper + direttive aggiornate)"
9. Aggiorna ROADMAP.md aggiungendo B33.5 sotto Fase 9 (o crea sezione UX dedicata se preferisci)
10. Scrivi nuovo handoff con `STATUS: CONTINUE` e usa il TEMPLATE BLOCCO 2 sotto

## NON fare in B33.5
- Non toccare `system_prompt.py` (carattere tutor va gia bene)
- Non toccare il frontend
- Non toccare lo schema DB
- Non implementare la logica completa di "verifica veloce + promozione automatica" — qui basta che il PRIMO messaggio sia differenziato per nodi presunti
- Non avanzare al blocco 2 prima di aver chiuso B33.5 con commit + test verdi

## Comandi backend utili
```
docker exec backend-backend-1 python -m pytest -x -q
docker exec backend-backend-1 python -m ruff check app/
docker exec backend-backend-1 python -m pytest tests/test_direttive_primo_turno.py -v
```

---

# PROSSIMO BLOCCO — fix-bug-cosmetici (template per nuovo handoff)

> Quando hai finito B33.5, riscrivi questo file `.claude/handoff.md` con il contenuto qui sotto, partendo da `STATUS: CONTINUE`. Aggiorna il SUMMARY con quello che hai effettivamente fatto in B33.5. Mantieni intatte le sezioni "Branch" e "Catena di 2 blocchi" sopra (semplificate per indicare che resta solo il blocco 2).

## BLOCCO 2 — fix-bug-cosmetici (frontend)

### Contesto
Cinque bug UI cosmetici emersi dal test manuale 2026-04-06 (vedi `.claude/test-findings.md`). Sono bug di basso/medio impatto, isolati, fixabili in modo chirurgico. Frontend Flutter only, nessuna modifica backend.

Bug da chiudere:
- **BUG-01** Overflow 58px in `MiniPercorsoWidget`
- **BUG-02** "Riprendi a studiare" mostrato anche per utente nuovo
- **BUG-03** "Bentornato!" in LoginScreen alla prima apertura
- **BUG-05** GraphOverview: nomi nodi troncati e sovrapposti (FIX PRUDENTE — solo wrapping)
- **BUG-07** GraphOverview: vastita orizzontale eccessiva (FIX MINIMO — solo zoom out iniziale)

### File da leggere PRIMA
1. `.claude/test-findings.md` (riferimento bug)
2. `frontend/lib/presentation/home_screen/widgets/mini_percorso_widget.dart` (BUG-01)
3. `frontend/lib/presentation/home_screen/home_screen.dart` (BUG-02)
4. `frontend/lib/presentation/login_screen/login_screen.dart` (BUG-03)
5. `frontend/lib/presentation/learning_path_screen/widgets/graph_overview.dart` (BUG-05, BUG-07)

### Fix specifici

**BUG-01 — Overflow MiniPercorsoWidget**
- File: `frontend/lib/presentation/home_screen/widgets/mini_percorso_widget.dart` (~riga 93)
- Causa: il `Row` dei nodi sborda quando `nodeSize*5 + spacing*4 > availableWidth`
- Fix proposto: wrappa il Row in un `SingleChildScrollView` orizzontale con `physics: ClampingScrollPhysics()` e `clipBehavior: Clip.hardEdge`. In alternativa: usa `LayoutBuilder` per calcolare dinamicamente quanti nodi mostrare. Scegli la prima opzione per semplicita.

**BUG-02 — "Riprendi a studiare" per utente nuovo**
- File: `frontend/lib/presentation/home_screen/home_screen.dart` (bottone principale)
- Fix: condiziona il testo del bottone. Se `sessionState.sessionHistory.isEmpty` (o equivalente — verifica il nome reale nello stato) → "Inizia a studiare" / "Comincia il tuo percorso". Altrimenti → "Riprendi a studiare". Verifica il nome esatto del campo nello state provider.

**BUG-03 — "Bentornato!" in LoginScreen alla prima apertura**
- File: `frontend/lib/presentation/login_screen/login_screen.dart`
- Fix: sostituisci il testo fisso con qualcosa di neutro alla prima apertura. Opzione semplice: testo generico tipo "Accedi a Dydat" + sottotitolo "Il tuo tutor personale per matematica, fisica e chimica" SEMPRE (rinunci all'effetto "bentornato" anche per chi torna — semplicissimo, zero stato). Se preferisci differenziare: usa flag `flutter_secure_storage` per capire se c'e gia un token salvato.

**BUG-05 — GraphOverview nomi tagliati (FIX PRUDENTE)**
- File: `frontend/lib/presentation/learning_path_screen/widgets/graph_overview.dart`
- Fix: ai widget Text dei nomi nodo aggiungi `maxLines: 2` e `overflow: TextOverflow.ellipsis`. NON ridimensionare il font, NON allargare lo spacing colonne — solo wrapping. Se serve, leggi un margine extra al `SizedBox` che contiene il nome per dare spazio alle 2 righe.

**BUG-07 — GraphOverview vastita orizzontale (FIX MINIMO)**
- File: `frontend/lib/presentation/learning_path_screen/widgets/graph_overview.dart`
- Fix: se non c'e gia un `InteractiveViewer`, wrappa il grafo. Imposta `minScale: 0.3`, `maxScale: 2.0`, e all'apertura applica uno zoom-out iniziale (es. `TransformationController` con scale 0.6) cosi l'utente vede subito una vista panoramica. NIENTE minimap — solo zoom out iniziale.

### Test obbligatori
Crea `frontend/test/widgets/fix_bug_cosmetici_test.dart` con almeno **5 test**:
1. `MiniPercorsoWidget` con 8 nodi non genera overflow exception (test render in viewport stretto)
2. Bottone home mostra "Inizia a studiare" quando sessionHistory e vuota
3. Bottone home mostra "Riprendi a studiare" quando sessionHistory ha almeno una sessione
4. LoginScreen mostra il nuovo testo neutro
5. GraphOverview con nodi a nome lungo non lancia overflow exception (textoverflow gestito)

### Gate di uscita BLOCCO 2
1. Tutti e 5 i bug fixati con commit atomico unico: "fix-bug-cosmetici — 5 fix UI post test manuale (BUG-01/02/03/05/07)"
2. 5+ test nuovi verdi
3. **TUTTI i 588 test frontend continuano a passare**
4. `flutter analyze` 0 errori
5. Aggiorna ROADMAP.md aggiungendo il blocco fix-bug-cosmetici
6. Aggiorna `.claude/test-findings.md` marcando BUG-01/02/03/05/07 come ✅ FIXED in fix-bug-cosmetici 2026-04-08
7. Scrivi handoff con `STATUS: PHASE_COMPLETE` — il runner si ferma

### NON fare nel blocco 2
- Non toccare il backend
- Non toccare BUG-04 (LinearPathMap ridisegno) — Villa lo vuole valutare separatamente
- Non toccare BUG-06 (evidenziazione percorso attuale nel grafo) — fuori scope
- Non rifattorare codice fuori scope
- Non aggiungere dipendenze
- Non fare merge verso main

### Comandi frontend utili
```
cd frontend
flutter analyze
flutter test
flutter test test/widgets/fix_bug_cosmetici_test.dart
```

---

## Stato baseline al lancio (2026-04-08)
- Branch: `develop` (post merge wip/B36-font-scale)
- Backend: 363 test verdi, 10 skipped
- Frontend: 588 test verdi, analyze 0
- Decisioni di design B33.5 documentate in `docs/discussions/ux-01-primo-turno-caldo.md`
- Catena: B33.5 → fix-bug-cosmetici → STOP

## Riepilogo finale di cosa NON fare in tutta la catena
- NON cambiare branch (resta su develop)
- NON fare merge verso main
- NON anticipare blocchi futuri (Fase 10, mascotte, beat-aware canvas)
- NON aggiungere dipendenze pesanti
- NON modificare lo schema DB
- NON toccare il `system_prompt.py` del tutor
- NON mescolare backend B33.5 e frontend bug-fix nello stesso commit
- NON proseguire oltre i 2 blocchi di questa catena
