# Test Findings — Nottata B35.5.1 → B35.13

> Data: 2026-04-07
> Branch: `wip/notte-quaderno-polish-2026-04-07`
> Villa esegue, Claude raccoglie.

---

## Riepilogo finale

| Scenario | Verdetto | Bug |
|---|---|---|
| 1 Quaderno Enciclopedico | ⚠️ PASS con bug | NB-01, NB-02, NB-03, NB-04 |
| 2 Pull-to-refresh | ✅ PASS | — |
| 3 Loading skeleton | ✅ PASS | — |
| 4 Errori user-friendly | ⚠️ PASS con bug | NB-05 (+ NB-06 pre-esistente scoperto) |
| 5 Search parole chiave | ✅ PASS | — |
| 6 Testi italiani Profilo | ✅ PASS | — |
| 7 Empty states | ✅ PASS | — |
| 8 Accessibilita | ⚠️ PARZIALE | NB-07 |

**Totale**: 7 bug raccolti.

### Per gravita
- **ALTA** (UX critica): NB-01 (formule LaTeX troppo grandi), NB-02 (LaTeX esempi non renderizzato)
- **MEDIA** (UX importante): NB-04 (log personale nascosto), NB-05 (errore quaderno generico), NB-06 (lucchetto pre-esistente), NB-07 (overflow scaling)
- **BASSA**: NB-03 (singolare/plurale ricorrente)

### File piu colpiti
- `quaderno_screen/widgets/formula_curriculum_card.dart` → NB-01
- `quaderno_screen/nodo_quaderno_screen.dart` → NB-02, NB-03, NB-04, NB-05
- `learning_path_screen/widgets/linear_path_map.dart` → NB-06
- `home_screen/widgets/mini_percorso_widget.dart` → NB-07

---

## Scenario 1 — Quaderno Enciclopedico

### NB-01 — Formule LaTeX troppo grandi, sbordano lateralmente
- **Severita**: ALTA (UX, l'utente non vede meta della formula)
- **File**: `frontend/lib/presentation/quaderno_screen/widgets/formula_curriculum_card.dart`
- **Sintomo**: Le formule renderizzate da `flutter_math_fork` (Math.tex) sono enormi (font size molto grande) e sbordano a destra dalla card. L'utente deve scrollare orizzontalmente per leggerle. Esempio: `a^n = a · a · a` viene tagliato a meta.
- **Causa probabile**: nessun `textScaleFactor` o `textStyle` con dimensione adeguata applicato a `Math.tex`. Default troppo grande.
- **Fix proposto**:
  1. Wrap del Math.tex in `FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft)` cosi le formule grandi vengono ridotte automaticamente per stare nella card
  2. Oppure imporre `textStyle: TextStyle(fontSize: 18)` o simili a Math.tex
  3. Oppure entrambi (FittedBox + textStyle ragionevole)

### NB-02 — LaTeX negli esempi NON renderizzato (codice grezzo visibile)
- **Severita**: ALTA (UX, esempi illeggibili)
- **File**: `frontend/lib/presentation/quaderno_screen/nodo_quaderno_screen.dart` (sezione Esempi)
- **Sintomo**: La sezione "Esempi" mostra gli `esempi_applicazione` come stringhe testuali plain. Quando un esempio contiene LaTeX inline (es. `(-2)^{-3} = \frac{1}{(-2)^3} = -\frac{1}{8}`), si vede il codice LaTeX grezzo, non la formula renderizzata.
- **Causa**: il widget Esempi usa Text() invece di un parser inline che riconosca segmenti LaTeX.
- **Fix proposto**:
  1. Soluzione semplice: usare `Math.tex` su tutto l'esempio se contiene `\\` o `^{` o `_{`. Funziona se l'esempio e tutto LaTeX.
  2. Soluzione migliore: parser semplice che divide l'esempio in segmenti testo + LaTeX e li renderizza con `RichText` + `Math.tex` come WidgetSpan. Pattern di delimitazione tipo `$...$` o intelligente.
  3. Soluzione minima: provare `Math.tex(esempio)` con `onErrorFallback: (e) => Text(esempio)` — se l'esempio e tutto LaTeX renderizza, altrimenti fallback a testo plain.

### NB-03 — Singolare/plurale italiano sbagliato (ricorrente)
- **Severita**: BASSA (UX, ma ricorrente in piu schermate)
- **File**: vari (almeno `nodo_quaderno_screen.dart`, `profile_screen.dart` o le sue widget)
- **Sintomo**: Numerose stringhe non gestiscono il singolare. Esempi:
  - Quaderno chip: "1 sessioni" (atteso: "1 sessione")
  - Profilo statistiche: "1 Sessioni" (atteso: "1 Sessione")
  - Profilo statistiche: "1 Giorni" (atteso: "1 Giorno")
- **Fix proposto**: helper italiano centralizzato `frontend/lib/utils/pluralize.dart` con funzioni tipo `String sessione(int n)`, `String giorno(int n)`, `String esercizio(int n)`, ecc. Usarlo ovunque ci sia un conteggio. Esempio:
  ```dart
  String sessione(int n) => n == 1 ? '$n sessione' : '$n sessioni';
  String giorno(int n) => n == 1 ? '$n giorno' : '$n giorni';
  ```
- **Punti d'uso noti**: chip statistiche profilo, chip quaderno, eventualmente recap, storico.

### Cose che funzionano in Scenario 1
- ✅ Header con back e nome nodo
- ✅ Breadcrumb con tema parent + chip stato
- ✅ Chip parole chiave (potenza, esponente, base, ecc.)
- ✅ Sezione "Cosa imparerai" con preview + bottone "Mostra tutto"
- ✅ Sezione "Formule chiave" presente (con bug NB-01 sulla dimensione)
- ✅ Sezione "Esempi" presente (con bug NB-02 sul rendering)
- ✅ Sezione "Attenzione a..." con card errori comuni complete (tipo, descrizione, errore tipico, corretto, suggerimento)
- ✅ Sezione "Le mie note" con textfield placeholder
- ✅ Salvataggio nota persiste (testato 1A)

### NB-04 — Sezioni log personale nascoste se vuote (manca empty state)
- **Severita**: MEDIA (UX)
- **File**: `frontend/lib/presentation/quaderno_screen/nodo_quaderno_screen.dart` righe 197-224
- **Sintomo**: Quando l'utente apre il quaderno di un nodo su cui non ha mai fatto sessione, sotto "Le mie note" non c'e piu niente. Mancano il separator "— I tuoi appunti —" e le 3 sezioni log personale (formule viste in sessione, esercizi svolti, spiegazioni del tutor). L'utente non capisce nemmeno che dovrebbero esserci.
- **Causa**: il codice usa `if (_hasLogPersonale(quaderno)) ...` per mostrare separator + sezioni — se non c'e nessun esercizio/formula/spiegazione, niente viene renderizzato. La spec del B35.5.5 diceva invece di mostrare un empty state gentile: "Non hai ancora fatto esercizi su questo nodo — inizia una sessione per popolare i tuoi appunti."
- **Fix proposto**:
  1. Mostrare SEMPRE il separator + un empty state gentile se `_hasLogPersonale` e false
  2. Layout suggerito: separator → card grigia con icona libro + testo invitante + bottone "Inizia una sessione" che porta a `/studio`
  3. Quando ci sono dati, mostrare le sezioni come ora

## Scenario 2 — Pull-to-refresh
- ✅ PASS: indicatore di refresh appare in Home e in I miei studi al gesto pull-down. Confermato da Villa.

## Scenario 3 — Loading skeleton
- ✅ PASS: skeleton placeholder visibili sia su pull-to-refresh sia su riapertura completa dell'app. Confermato da Villa.

## Scenario 4 — Errori user-friendly

### NB-05 — Messaggio errore quaderno generico, non sfrutta helper di B35.8
- **Severita**: MEDIA (UX)
- **File**: `frontend/lib/presentation/quaderno_screen/nodo_quaderno_screen.dart` (gestione errore stato)
- **Sintomo**: In modalita aereo, aprire il quaderno di un nodo non in cache mostra "Errore caricamento quaderno" con bottone "Riprova". Il messaggio e in italiano e c'e un retry, ma e GENERICO. Non riconosce che il problema e l'assenza di rete e non sfrutta l'helper `userFriendlyError` di B35.8 che dovrebbe restituire "Connessione assente. Controlla la rete e riprova."
- **Causa probabile**: la gestione errore della schermata quaderno usa una stringa hardcoded invece di chiamare l'helper centralizzato.
- **Fix proposto**: sostituire il messaggio hardcoded con `userFriendlyError(state.error)` cosi diventa contestuale (rete assente vs server down vs altro).
- **Note**: il quaderno e una delle prime cose dove l'utente vede un errore in offline; e importante che il messaggio sia chiaro.

### Cosa funziona in Scenario 4
- ✅ Messaggio errore in italiano (non tecnico)
- ✅ Bottone "Riprova" presente
- ✅ Icona warning chiara
- ⚠️ Messaggio generico, vedi NB-05

---

## Scoperto in Scenario 4 (bug pre-esistente di B38.5, non della nottata)

### NB-06 — Icona lucchetto sui nodi "da iniziare" semanticamente sbagliata
- **Severita**: MEDIA (UX, fuorviante)
- **File**: `frontend/lib/presentation/learning_path_screen/widgets/linear_path_map.dart`
- **Sintomo**: Nella mappa lineare di "I miei studi", tutti i nodi "Da iniziare" hanno un'icona LUCCHETTO dentro il cerchio. Il lucchetto comunica "bloccato / non accessibile" — ma in realta tutti i nodi sono perfettamente tappabili e portano al bottom sheet. Semantica errata.
- **Causa**: il fix B38.5 (BUG-04 LinearPathMap ridisegno) ha mappato lo stato `da_iniziare` all'icona `lock` invece che a un puntino neutro o cerchio vuoto.
- **Fix proposto**: cambiare l'icona per stato `da_iniziare`. Suggerimenti:
  1. Cerchio vuoto (nessuna icona dentro, solo bordo)
  2. Puntino piccolo al centro (Icons.circle, size: 8)
  3. Numero progressivo del nodo nel percorso (1, 2, 3...)
- **Riservare lucchetto** solo per nodi REALMENTE bloccati (es. prerequisiti non soddisfatti). Per ora possiamo non implementare lo stato "bloccato" del tutto.

## Scenario 5 — Search con parole chiave
- ✅ PASS: cercando "esponente" (parola chiave non presente nel nome) il nodo "Potenza di un numero relativo" rimane evidenziato mentre gli altri sbiadiscono. Funzionalita B35.10 verificata.

## Scenario 6 — Testi "Serie" e "Traguardi"
- ✅ PASS: nel Profilo card Statistiche c'e "Serie" (non "Streak"), card achievement c'e "Traguardi" (non "Achievement"). Funzionalita B35.11 verificata.
- ⚠️ Nota: scoperto pero che il problema NB-03 (singolare/plurale) si manifesta in piu punti, esteso il bug.

## Scenario 7 — Empty states vari
- ✅ PASS Profilo statistiche zero: gestiti in modo accettabile (numero grosso 0 + label, niente messaggio mancante)
- ✅ PASS Search senza match: cercando "pippozinfandel" appare messaggio empty state appropriato
- ✅ PASS Sezione ripasso assente in Home quando 0 nodi da ripassare (gia gestito da B35.6)
- Funzionalita B35.6 verificata.

## Scenario 8 — Accessibilita

- ✅ TextScaler effettivamente sbloccato: aumentando la dimensione carattere dalle impostazioni del sistema operativo, i testi di Dydat si scalano davvero (prima erano fissi). B35.13 verificato.
- ⚠️ PARZIALE: lo scaling provoca un overflow di layout su Home.

### NB-07 — Home: overflow 6.6px in MiniPercorsoWidget con TextScaler aumentato
- **Severita**: MEDIA (UX, regressione visiva quando l'utente scala i caratteri)
- **File**: `frontend/lib/presentation/home_screen/widgets/mini_percorso_widget.dart:130`
- **Sintomo**: Aumentando la dimensione caratteri dalle impostazioni di sistema, sulla Home appare overflow "RenderFlex overflowed by 6.6 pixels on the bottom" sulla Column del MiniPercorsoWidget (riga 130).
- **Causa**: la Column del widget ha altezza fissa o vincoli che non considerano testi piu grandi.
- **Storia**: BUG-01 di B38.5 aveva fixato un overflow orizzontale dello stesso widget. Ora con TextScaler abilitato in B35.13 emerge un overflow verticale separato.
- **Fix proposto**:
  1. Rimuovere altezze fisse dalla Column, usare `IntrinsicHeight` o `Flexible`/`Expanded`
  2. Oppure wrappare la Column in un `LayoutBuilder` + `FittedBox(fit: BoxFit.scaleDown)` per gli elementi testuali
  3. Verificare che il widget rispetti `MediaQuery.of(context).textScaler` nei calcoli di altezza
- **Test consigliato**: aggiungere widget test che verifica MiniPercorsoWidget con `textScaler: TextScaler.linear(1.5)` non genera overflow.
