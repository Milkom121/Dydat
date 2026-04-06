# Test Findings — Sessione Manuale 2026-04-06

> Bug e anomalie trovati durante i test manuali su Fasi 7-8-9.
> Villa (fondatore) esegue, Claude raccoglie.
> Utente di test: `mariomattiadimuro@gmail.com` (Verdan), percorso matematica creato via onboarding.

---

## Scenario 1 — Home

### BUG-01 — Overflow 58px in MiniPercorsoWidget
- **Severita**: MEDIA (UI visibilmente rotto ma app funzionante)
- **File**: `frontend/lib/presentation/home_screen/widgets/mini_percorso_widget.dart:93`
- **Sintomo**: Row dei nodi sborda a destra di 58px con striscia gialla/nera "RIGHT OVERFLOWED".
- **Causa probabile**: Lo `spacing` tra nodi e clampato a `clamp(8.0, 40.0)` ma il clamp non protegge da width insufficienti — se nodeSize*5 + spacing*4 > availableWidth, il Row sborda.
- **Fix proposto**: wrap del Row in SingleChildScrollView orizzontale (scrollabile manualmente), oppure calcolo dinamico di quanti nodi mostrare in base alla width, oppure FittedBox con scaleDown.
- **Riproducibile**: sempre, con percorso che ha >= 5 nodi visibili in finestra.
- **Schermata**: Home, card "Il tuo percorso — matematica"

### BUG-02 — "Riprendi a studiare" mostrato anche per utente nuovo
- **Severita**: BASSA (UX)
- **File**: `frontend/lib/presentation/home_screen/home_screen.dart` (bottone principale)
- **Sintomo**: Utente appena onboardato, 0 sessioni precedenti, ma il bottone recita "Riprendi a studiare" invece di "Inizia a studiare" / "Comincia il tuo percorso".
- **Fix proposto**: condizionare il testo del bottone su `sessionState.sessionHistory.isNotEmpty` oppure su `statsState.esercizi > 0`.

### NOTA-01 — Welcome header generico
- **Severita**: MINIMALE
- **Sintomo**: Mostra "Benvenuto su Dydat!" senza nome utente. Per utente nuovo e atteso — il saluto contestuale (es. "Bentornato Verdan") dovrebbe apparire solo dopo la prima sessione.
- **Da verificare**: dopo la prima sessione il saluto diventa personalizzato?

---

## Bug pre-esistenti (fuori scope B33-B38)

### PRE-01 — Test di posizionamento promesso ma non erogato
- **Severita**: MEDIA (onboarding pre-esistente)
- **Sintomo**: Durante l'onboarding, il tutor propone "Vuoi fare un test per capire il punto giusto?". Villa accetta ("Fammi fare un test per capire il punto giusto"). Il tutor risponde ma il test non viene mai erogato — il flusso prosegue direttamente su "Inizia il tuo percorso".
- **Nota**: Non fa parte della Fase 7-9. Registrato per eventuale blocco futuro sull'onboarding (Fase 10 B39 potrebbe gia rivedere l'onboarding).

---

## BUG trovati in piu schermate

### BUG-03 — "Bentornato!" in LoginScreen alla prima apertura
- **Severita**: BASSA (UX)
- **File**: `frontend/lib/presentation/login_screen/login_screen.dart`
- **Sintomo**: La LoginScreen mostra "Bentornato!" con subtitle "Accedi per continuare il tuo percorso di apprendimento" anche alla PRIMA apertura dell'app, quando l'utente non e mai stato registrato.
- **Fix proposto**: condizionare il testo su presenza di token salvato o su flag "prima apertura". In alternativa, testo generico neutro tipo "Dydat" + "Accedi al tuo account".

---

## Scenario 2 — confermato nella sessione 1
- Overlay transizione mascotte: VISTO (Villa ha confermato)
- SessionGoalPicker con 3 opzioni: APPARSO (Villa ha scelto Veloce nel primo tentativo)
- Resume intelligente: OK (se sessione attiva esiste, non riappare il goal picker)
- **Verdetto Scenario 2**: ✅ PASS

## Scenario 3 — Beat overlay + mascotte
- **Beat overlay (B37)**: ✅ CONFERMATO DA VILLA (visibile a occhio, poco evidente negli screenshot JPG)
- **Mascotte CustomPainter (B38)**: ⏸️ RIMANDATO — Villa ha deciso che la mascotte sara riscritta in futuro con vere animazioni, non e priorita del test manuale attuale
- **Verdetto Scenario 3**: ✅ PASS (limitato al beat overlay)

## Focus nuovo — Esperienza di conversazione
Villa vuole valutare la qualita della conversazione con il tutor (non piu pixel-perfect UI).
Priorita test: Scenari 4 (esercizio fullscreen), 5 (recap narrativo), 6 (mappa), 7 (quaderno).

## Scenario 4 — Esercizio fullscreen + conversazione

### UX-01 (STRATEGICA) — Primo turno di sessione troppo immediato
- **Severita**: ALTA (esperienza d'uso, non bug tecnico)
- **Dove**: primo turno del tutor all'ingresso in Studio dopo onboarding
- **Sintomo**: Il tutor parte direttamente con un esempio concreto (cioccolatini) + definizione + due domande di verifica. Nessun saluto contestualizzato, nessun ponte con l'onboarding, nessuna presentazione del nodo, nessun warm-up esplorativo, nessun riferimento al ritmo scelto (Veloce/Normale/Approfondita).
- **Cosa manca**:
  1. Continuita con onboarding (riprendere info raccolte: "hai detto che stai riprendendo dopo una pausa, che ti piace partire da esempi, che ti senti 4/5 con le frazioni")
  2. Presentazione del nodo ("oggi affrontiamo Potenza di un numero relativo, in ~30 min vedremo X Y Z")
  3. Warm-up esplorativo prima di esporre ("raccontami cosa ricordi delle potenze normali, poi vediamo i relativi")
  4. Ponte conversazionale ("Bentornato Verdan, ripartiamo insieme da qui")
  5. Riconoscimento del ritmo scelto ("abbiamo 30 min, ti propongo di usarli cosi")
- **Causa probabile**: prompt di sistema del tutor non ha una fase "inizio sessione" strutturata, e il contesto dell'onboarding (profilo_sintetizzato) non viene inniettato nel primo turno in modo esplicito.
- **Fix proposto**: NON un quick-fix. Serve:
  - Revisione prompt di sistema per fase "inizio sessione"
  - Probabile introduzione di un primo turno parzialmente deterministico (template "accoglienza + presentazione nodo + proposta") prima di lasciare il timone all'LLM
  - Integrazione esplicita del profilo utente (preferenze, sicurezza, materia, tipo sessione) nel contesto del primo turno
  - Eventualmente beat "accoglienza" piu lungo e strutturato
- **Da affrontare come**: blocco dedicato — candidati: B33.5 "Primo turno caldo" (nuovo), oppure integrazione in Fase 10 B39 (Onboarding Wow che gia rivede primo contatto).
- **Villa osservazione testuale**: "quella che vedi e la prima interazione dell'utente con il tutor, mi sembra che sia un po' troppo immediato come approccio, bisognerebbe forse fare qualche riflessione sul flusso reale dell'utente".

**Test scenario 4 SOSPESO** in attesa di decisione strategica sul primo turno.

---

## Scenario 6 — I miei studi (mappa percorso)

### BUG-04 — LinearPathMap sembra una lista, non una mappa
- **Severita**: MEDIA (UX, non blocca la funzionalita)
- **File**: `frontend/lib/presentation/learning_path_screen/widgets/linear_path_map.dart`
- **Sintomo**: La vista "mappa lineare" implementata in B34 e un ListView.builder dove ogni riga ha un cerchio piccolo + linea a sinistra e una card rettangolare con il nome a destra. L'impatto visivo e quello di una "lista con indicatore laterale", non di una vera mappa del percorso.
- **Causa**: scelta di layout — cerchi piccoli affiancati a card testuali grandi. La mappa e tecnicamente corretta (cerchi connessi da linee) ma visivamente dominata dalle card.
- **Fix proposto**:
  1. Ingrandire i cerchi (da 20px a ~48px) e renderli visivamente il focus
  2. Ridurre le card nome a chip testuali o tooltip sotto il cerchio
  3. Oppure: layout alternato (sx/dx come un "sentiero") con nome sotto il cerchio, non accanto
  4. Stato del nodo comunicato con colore/icona nel cerchio, non con testo "Da iniziare"
- **Verdetto funzionale**: ✅ gate di uscita B34 soddisfatto (mappa, ricerca, tap, zoom)
- **Verdetto visivo**: ⚠️ da ridisegnare

### BUG-05 — GraphOverview: nomi nodi troncati e sovrapposti
- **Severita**: MEDIA
- **File**: `frontend/lib/presentation/learning_path_screen/widgets/graph_overview.dart`
- **Sintomo**: Nella vista grafo (toggle da lineare a graph), i nomi dei nodi sono troppo lunghi e vengono tagliati/sovrapposti al cerchio ("Funzioni definite per casi ... inuita", "representazione di ... one"). Testi illeggibili.
- **Fix proposto**:
  1. Wrappa nomi su piu righe con `maxLines: 2` e `overflow: ellipsis`
  2. Oppure mostra solo icona nel grafo e nome solo in tooltip/tap
  3. Oppure riduci font size e allarga lo spacing tra colonne

### BUG-06 — GraphOverview: percorso attuale non evidenziato
- **Severita**: MEDIA (UX)
- **File**: `frontend/lib/presentation/learning_path_screen/widgets/graph_overview.dart`
- **Sintomo**: La vista grafo mostra colonne tematiche generali (Funzioni, Polinomi, Relazioni) ma non evidenzia il percorso attuale dell'utente ne il nodo corrente ("Potenza di un numero relativo"). Non c'e un "dove sono io" nel grafo.
- **Fix proposto**:
  1. Evidenzia con colore/glow i nodi del percorso attuale dell'utente
  2. Marca il nodo corrente con un cerchio pulsante o badge
  3. Eventualmente apri il grafo gia centrato sul nodo corrente

### BUG-07 — GraphOverview: vastita orizzontale eccessiva
- **Severita**: BASSA (UX)
- **File**: `frontend/lib/presentation/learning_path_screen/widgets/graph_overview.dart`
- **Sintomo**: Il grafo si estende molto in orizzontale, richiede molto scroll laterale per esplorare.
- **Fix proposto**: InteractiveViewer con zoom out iniziale + minimap in angolo per orientarsi.

---

## Scenario 7 — Quaderno per nodo (B35)

### UX-02 (STRATEGICA) — Quaderno come scheda enciclopedica + log personale
- **Severita**: ALTA (design di prodotto)
- **Osservazione Villa**: "dovremmo poter vedere il contenuto del nodo in maniera dettagliata e completa, dovrebbe essere pensato per poter essere fruito"
- **Sintomo attuale**: NodoQuadernoScreen e un LOG dell'attivita personale dell'utente (formule viste, esercizi svolti, spiegazioni ricevute). Un nodo mai studiato mostra un empty state vuoto "Il quaderno si riempira man mano che studi questo argomento".
- **Come dovrebbe essere**: un MANUALE PERSONALE PER ARGOMENTO, esistente dal primo accesso, composto da:
  1. **Scheda intrinseca del nodo** (dal curriculum, sempre presente): definizioni_formali, formule_proprieta, errori_comuni, esempi_applicazione, parole_chiave. Gia presenti nel DB tabella `nodi`.
  2. **Log personale** (quello che c'e oggi): esercizi svolti, formule viste nelle sessioni, spiegazioni specifiche del tutor per TE.
- **Verifica backend**: la tabella `nodi` contiene gia tutti i dati necessari come JSONB. L'endpoint `GET /quaderno/{nodo_id}` e costruito solo sul log personale e ignora questi campi.
- **Fix proposto (blocco dedicato B35.5 "Quaderno enciclopedico")**:
  1. Backend: modificare `GET /quaderno/{nodo_id}` per includere anche i campi intrinseci dalla tabella nodi (definizioni_formali, formule_proprieta, errori_comuni, esempi_applicazione).
  2. Frontend: aggiungere sezioni nella NodoQuadernoScreen: "Cosa imparerai", "Definizioni", "Formule chiave", "Esempi", "Errori comuni". Queste vanno SOPRA al log personale.
  3. Rendering LaTeX per le formule_proprieta (gia disponibile flutter_math_fork).
  4. Empty state del log personale separato: "Non hai ancora fatto esercizi su questo nodo" ma la scheda intrinseca resta visibile.
- **Impatto**: trasforma Dydat da "tutor conversazionale" a "tutor + libro di testo personale". Stesso dato gia in DB, serve solo renderlo.
- **Candidato blocco**: B35.5 "Quaderno enciclopedico" — probabilmente prima di Fase 10 o come parte del blocco fix bug UI consolidato.

**Test Scenario 7 — verdetto funzionale**: ✅ endpoint e frontend funzionano come progettati in B35
**Test Scenario 7 — verdetto prodotto**: ⚠️ scope troppo stretto, vedi UX-02

---

## Scenario 10 — Tab Profilo
- Card account (avatar, email, materia): ✅
- Statistiche coerenti (streak, nodi, sessioni, stats settimanali): ✅
- Achievement system con primo achievement sbloccato: ✅
- Toggle tema (sole/luna/sistema): ✅
- Bottone Esci: ✅
- Superfici B36: ✅ coerenti con Home e I miei studi
- **Verdetto**: ✅ PASS, nessun bug nuovo

---

# Riepilogo finale test manuale

## Scenari testati
| # | Scenario | Verdetto | Note |
|---|----------|----------|------|
| 1 | Home calda + superfici | ⚠️ PASS con bug | BUG-01, BUG-02 |
| 2 | Transizione + Goal Picker | ✅ PASS | tutto OK |
| 3 | Beat overlay | ✅ PASS | mascotte rimandata al futuro |
| 4 | Esercizio fullscreen | ⏸️ SOSPESO | vedi UX-01 |
| 5 | Recap narrativo | ⏸️ SOSPESO | sospeso con 4 |
| 6 | Mappa + zoom + ricerca | ⚠️ PASS funzionale | BUG-04/05/06/07 |
| 7 | Quaderno | ⚠️ PASS funzionale | vedi UX-02 |
| 10 | Tab Profilo | ✅ PASS | tutto OK |

## Bug UI/UX cosmetici (fixabili in un blocco dedicato)
- **BUG-01** overflow mini_percorso_widget 58px
- **BUG-02** "Riprendi a studiare" per utente nuovo
- **BUG-03** "Bentornato!" in LoginScreen alla prima apertura
- **BUG-04** LinearPathMap sembra lista, non mappa (ridisegno visivo)
- **BUG-05** GraphOverview: nomi nodi troncati/sovrapposti
- **BUG-06** GraphOverview: percorso attuale non evidenziato
- **BUG-07** GraphOverview: vastita orizzontale eccessiva

## Issue STRATEGICHE (richiedono decisione + blocco dedicato)
- **UX-01** Primo turno caldo di sessione — candidato B33.5
- **UX-02** Quaderno enciclopedico — candidato B35.5

## Pre-esistenti (fuori scope Fase 7-9)
- **PRE-01** Test di posizionamento promesso ma non erogato (onboarding)



