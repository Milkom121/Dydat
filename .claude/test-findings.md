# Test Findings — Sessione Manuale 2026-04-06

> Bug e anomalie trovati durante i test manuali su Fasi 7-8-9.
> Villa (fondatore) esegue, Claude raccoglie.
> Utente di test: `mariomattiadimuro@gmail.com` (Verdan), percorso matematica creato via onboarding.

---

## Sessione Manuale 2026-04-09 — pre-test B39

### BUG-B39-01 — CRITICO — Enum OnboardingStato Python/PostgreSQL mismatch (risolto)
- **Severita**: CRITICA (rompe qualsiasi lettura ORM di utenti dal DB — login, dashboard, onboarding tutti falliscono con `LookupError`)
- **Scoperto durante**: verifica pre-test manuale del 2026-04-09 dopo chiusura catena B39
- **File**: `backend/app/db/models/utenti.py:40-49`
- **Sintomo**: Qualsiasi `SELECT` ORM su `Utente` crasha con `LookupError: 'not_started' is not among the defined enum values. Enum name: onboarding_stato_enum. Possible values: NOT_STARTED, IN_PROGRESS, COMPLETED`.
- **Causa**: l'enum Python `OnboardingStato` ha nomi uppercase (`NOT_STARTED`) e valori lowercase (`"not_started"`). Il tipo PostgreSQL `onboarding_stato_enum` e stato creato dalla migrazione B39.1.1 con valori lowercase (`not_started`, `in_progress`, `completed`). Di default, `sqlalchemy.Enum(OnboardingStato, ...)` usa i NOMI Python (uppercase) come valori PostgreSQL, non i `value`. Risultato: quando SQLAlchemy legge `'not_started'` dal DB, cerca un nome Python `not_started` che non esiste → crash.
- **Perche i 768 test unitari non l'hanno beccato**: i test del modello di B39.1.2 testano la creazione di utenti ma non la lettura via ORM dopo persistenza. I test di business logic fanno mock di utenti. Nessun test unitario pre-test-manuale faceva un `SELECT` con filtro su utente esistente con il campo `onboarding_stato` valorizzato. La suite verde non garantiva che il mapping funzionasse in practice.
- **Fix**: aggiunto `values_callable=lambda enum_cls: [e.value for e in enum_cls]` al costruttore `SAEnum` per usare i `value` dell'enum Python (lowercase) invece dei `name`. Fix di una riga.
- **Verifica post-fix**: la query `SELECT * FROM utenti` torna `OnboardingStato.NOT_STARTED` correttamente. 768 test backend verdi, nessuna regressione.
- **Lesson learned**: aggiungere un test di smoke che fa create + read round-trip di Utente con tutti i campi enum valorizzati, per catturare subito questa classe di bug.

### BUG-B39-02 — CRITICO — Package `record` v5.x con sotto-dip `record_linux` incompatibile (risolto)
- **Severita**: CRITICA (build Android fallisce in compilazione, impossibile lanciare l'app su emulatore)
- **Scoperto durante**: primo `flutter run` dopo fix enum + cambio porta backend, 2026-04-09
- **File**: `frontend/pubspec.yaml:35`
- **Sintomo**: `flutter run` su emulatore Android fallisce con errore Kotlin/Dart compilation:
  ```
  record_linux-0.7.2/lib/record_linux.dart:12: The non-abstract class 'RecordLinux' is missing implementations for these members:
    - RecordMethodChannelPlatformInterface.startStream
  record_linux-0.7.2/lib/record_linux.dart:36: The method 'RecordLinux.hasPermission' has fewer named arguments than those of overridden method
  ```
- **Causa**: `record ^5.1.2` (pinnato in B39.7.2) risolveva nel lock `record 5.2.1` + `record_linux 0.7.2` + `record_platform_interface 1.5.0`. La versione 0.7.2 di `record_linux` era ferma alla vecchia interfaccia (`hasPermission(String)`), mentre `record_platform_interface 1.5.0` richiedeva la nuova firma (`hasPermission(String, {bool request = true})`) e un nuovo metodo `startStream(...)`. Dart compile-time crasha perche la subclass non implementa i metodi astratti.
- **Ironia**: `record_linux` non viene usato su Android (e esclusivo per Linux desktop), ma il resolver Dart lo include comunque nel dependency graph per tutte le piattaforme, quindi il build fallisce ovunque.
- **Perche i test unitari non l'hanno beccato**: `flutter test` gira su host Windows e NON compila il codice platform-specific Android/iOS/Linux — usa mock delle piattaforme. Gli analyze passano perche record_linux ha comunque sintassi valida, e la classe astratta del platform_interface non e checked in staticamente per la VM host. Solo `flutter run` (build reale) trigera la compilazione Dart del graph completo per il target, che scopre l'incompatibilita.
- **Fix**: aggiornato `record` da `^5.1.2` a `^6.2.0` in `pubspec.yaml`. La v6 aggiorna automaticamente `record_linux` a 1.3.0 (compatibile con platform_interface 1.5.0). Zero breaking changes sull'API usata da Dydat (`AudioRecorder`, `start/stop`, `onAmplitudeChanged`, `dispose`, `RecordConfig`, `AudioEncoder.aacLc` — verificato dal changelog v6.0.0).
- **Verifica post-fix**: `flutter pub get` ok, `flutter analyze` 0 issues, `flutter test` 753 verdi (zero regressioni).
- **Lesson learned**: quando si pinna un package con sotto-dipendenze specifiche per piattaforma (record_*, path_provider_*, ecc.), non basta eseguire `flutter test` su host per garantire la compatibilita. Serve anche almeno un `flutter build apk --debug` o `flutter run` su un target reale per testare la compilazione del graph completo. Questo e stato il secondo "bug verde nei test ma rotto in produzione" della giornata — fa il paio con BUG-B39-01 dell'enum SQLAlchemy.

### BUG-B39-03 — MINORE — Porta backend 8001 in conflitto con software esterni (workaround)
- **Severita**: BASSA (workaround ambientale, non bug di codice)
- **File**: `backend/docker-compose.yml` + `frontend/lib/config/api_config.dart`
- **Sintomo**: Villa ha altri software in esecuzione sul sistema (Whisper for Windows, altro) che occupano sia la porta 8000 che la 8001. Il backend Dydat non puo avviarsi sulla porta che aveva di default (8001).
- **Fix**: spostata la porta host del backend a **18000** (porta container interna resta 8000, mapping `18000:8000`). Aggiornato anche `ApiConfig.baseUrl` del frontend (`10.0.2.2:18000` per Android emulator, `localhost:18000` per altri).
- **Nota**: questo non e un bug vero di Dydat, e un conflitto ambientale dovuto ad altri software sul sistema del fondatore. Pero il default di 8001 era comunque una scelta discutibile visto che 8000/8001 sono porte molto comuni. Porta 18000 (mnemonica 8000+10000) e piu sicura come default.

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

---

# Test manuale 2026-04-08 — primi finding

## DEV-01 — Bottone "Login dev" salta completamente l'onboarding anche per utenti freschi
- **Severita**: MEDIA (blocca i test manuali di B33.5 e ogni altra verifica che richiede un utente nuovo con profilo onboardato)
- **Dove**: `frontend/lib/presentation/login_screen/login_screen.dart` funzione `_handleDevLogin` (~riga 369)
- **Sintomo**: Premendo "Login dev" su un DB senza utenti, l'app prova login → fallisce → fa `register()` via authProvider → autenticazione OK → il router globale fa redirect a `/home`. L'onboarding (`/onboarding`) non viene MAI raggiunto, quindi il nuovo utente atterra su home con profilo vuoto. Confermato il 2026-04-08 durante il tentativo di test B33.5: dopo wipe DB + Login dev, schermata Home visibile con "Benvenuto su Dydat!" generico e 0/0/0 stats, nessuna traccia di onboarding.
- **Causa tecnica**: due concause:
  1. `_handleDevLogin` dopo il ramo `register()` non naviga a `/onboarding`, si limita a fare `HapticFeedback.lightImpact()`.
  2. Il router (`app_router.dart` `redirect` ~riga 91) non ha nessun check "ha completato l'onboarding?" — se `isAuthenticated == true` e sei su login/splash/registration, vieni sparato su `/home`, indipendentemente dallo stato del profilo. Il flusso normale funziona solo perche LoginScreen ha il link "Nuovo utente? Inizia qui" che porta a `/onboarding` PRIMA dell'autenticazione, e l'onboarding stesso termina con un handoff a `/registration`.
- **Fix proposto**: due opzioni, non esclusive:
  - (a) In `_handleDevLogin`, dopo una `register()` riuscita (quindi solo al primo login dev con DB vuoto), navigare a `/onboarding` invece di lasciare che il router rediriga a home. Riconoscere che e una registrazione fresca usando lo stato pre-login (se il login iniziale fallisce ed e stato necessario il register, allora e nuovo).
  - (b) Piu pulito ma piu invasivo: il router controlla `profilo_sintetizzato` dell'utente autenticato; se e `null`, rediriga a `/onboarding` invece che a `/home`. Cosi il fix vale per QUALSIASI utente appena creato, non solo il dev. Richiede che lo stato utente sia disponibile nel router (probabilmente gia lo e via `authProvider`).
- **Workaround per test odierno**: non usare Login dev, usare "Nuovo utente? Inizia qui" nella LoginScreen e fare registrazione manuale con `dev@dydat.dev` / `dev12345` / `Dev User` alla fine dell'onboarding.
- **Candidato blocco**: `fix-dev-login-onboarding` (basso complesso, 20 min) — oppure integrarlo nel redesign onboarding di Fase 10 B39 scegliendo l'opzione (b).

## UX-03 — Messaggio errore password troncato nella RegistrationScreen
- **Severita**: MEDIA (blocca l'utente perche non capisce come correggere)
- **Dove**: `frontend/lib/presentation/registration_screen/registration_screen.dart` (campo password, messaggio errore di validazione)
- **Sintomo**: Quando la password non rispetta le regole (almeno 8 caratteri, una maiuscola, un numero), sotto il campo compare il messaggio *"La password deve contenere almeno una letter..."* troncato con tre puntini. L'utente vede "almeno una letter..." e non sa se deve aggiungere una lettera, una maiuscola, o altro. Sotto c'e un helper text che spiega le regole complete ma visivamente sembra scollegato e puo passare inosservato.
- **Causa probabile**: il Text dell'errore di validazione ha probabilmente `maxLines: 1` o comunque un constraint di larghezza troppo stretto. Il messaggio originale e piu lungo di quanto il campo puo mostrarlo.
- **Fix proposto**: rimuovere il constraint di riga singola sul messaggio errore (`maxLines: 2` o nessun limite), oppure accorciare il messaggio a qualcosa che sta su una riga ("Serve maiuscola e numero, min 8 caratteri"), oppure unificare errore + helper text in un unico blocco multiriga sempre visibile.
- **Screenshot**: fornito da Villa 2026-04-08 durante test manuale.

## DEV-02 — Password hardcoded del Login dev non rispetta le regole di validazione
- **Severita**: MEDIA (rende il Login dev inutilizzabile per il primo accesso dopo un reset DB)
- **Dove**: `frontend/lib/config/app_config.dart:14` — `static const String devPassword = 'dev12345';`
- **Sintomo**: La password hardcoded `dev12345` e tutta minuscola e non rispetta la regola "almeno una maiuscola" richiesta dalla RegistrationScreen. Finche esiste gia un utente `dev@dydat.dev` nel DB con quella password il Login dev funziona (passa dal ramo login diretto). Ma dopo un wipe del DB, il Login dev va nel ramo register, chiama il provider `register()` con `dev12345`, e a seconda di dove vive la validazione fallisce silenziosamente:
  - Se la validazione e solo frontend nella form di registrazione: il provider `register()` probabilmente non la esegue, chiama direttamente il backend, e a seconda del backend il register riesce (password debole accettata lato server) o fallisce con errore generico.
  - Confermato il 2026-04-08 che al primo tentativo dopo il wipe, la Login dev "sembra funzionare" (l'utente finiva su home con profilo vuoto), quindi il backend probabilmente NON valida la password e l'accetta com'e. Pero questo e incoerente con il frontend.
- **Problema derivato**: la validazione frontend e backend sono disallineate. Se in futuro rafforziamo la validazione backend, il Login dev smettera di funzionare completamente.
- **Fix proposto**: 
  1. **Immediato**: cambiare `devPassword` in `app_config.dart` a qualcosa che rispetta le regole (es. `Dev12345!`). Cambiare anche la eventuale documentazione/README che menziona la password.
  2. **Strutturale**: aggiungere la stessa validazione password lato backend (`backend/app/schemas/` e/o `backend/app/core/auth.py`) e centralizzare le regole in un unico posto condiviso. Registrato anche come voce `dev-shortcuts.md` priorita media.
- **Workaround per test odierno**: registrarsi a mano con `Dev12345` come password (maiuscola D), non via Login dev.

## UX-04 — Errore password non sparisce dopo aver corretto l'input
- **Severita**: BASSA-MEDIA (l'utente registra comunque se il form lo lascia procedere, ma vede un errore che sembra ancora attivo — confusione visiva)
- **Dove**: `frontend/lib/presentation/registration_screen/registration_screen.dart` (campo password, validation state)
- **Sintomo**: Dopo aver inserito una password invalida (`dev12345`) e visto l'errore "La password deve contenere almeno una letter...", correggendo la password con un valore valido (`Dev12345`) il messaggio rosso sotto il campo **non sparisce**. Resta visibile anche se l'input e ora corretto. Il bottone "Crea account" permette comunque la registrazione — l'errore e visuale, non funzionale.
- **Causa probabile**: il `TextFormField` ha un `validator` che gira solo su submit (default `AutovalidateMode.disabled`) o su `onUserInteraction` non configurato correttamente. Oppure il messaggio errore e salvato in uno stato locale del widget e non viene resettato a ogni modifica del controller.
- **Fix proposto**: aggiungere `autovalidateMode: AutovalidateMode.onUserInteraction` al TextFormField della password, in modo che la validazione giri a ogni modifica del testo e l'errore scompaia appena il contenuto diventa valido. Fix di una riga.
- **Screenshot**: fornito da Villa 2026-04-08, stesso screenshot di UX-03.

## ONB-01 — CRITICO — L'onboarding non salva il profilo utente da nessuna parte
- **Severita**: CRITICA (blocca l'attivazione di B33.5 primo turno caldo e impedisce qualsiasi personalizzazione basata sul profilo utente)
- **Dove**: integrazione tra
  - `frontend/lib/presentation/onboarding_screen/onboarding_screen.dart:144-145` (chiama `completeOnboarding()` senza argomenti)
  - `frontend/lib/providers/onboarding_provider.dart:220` (firma con parametri opzionali ma mai passati dal chiamante)
  - `frontend/lib/services/onboarding_service.dart:45` (passa i dati opzionali al backend)
  - `backend/app/schemas/onboarding.py:18` (schema ha solo `contesto_personale` e `preferenze_tutor`, NON ha `profilo_sintetizzato`)
  - `backend/app/core/onboarding.py:220-295` (`completa_onboarding` scrive `contesto_personale` e `preferenze_tutor` se presenti, ma il frontend li manda sempre null; e NON scrive `profilo_sintetizzato` mai, neanche se arrivasse)
- **Sintomo**: Durante il test manuale B33.5 del 2026-04-08, dopo aver completato tutto l'onboarding conversazionale col tutor (5 turni di risposte ricche: "voglio imparare per conto mio", "matematica", "lavoro ma voglio recuperare", "operazioni base", "mix teoria e pratica"), lo stato finale dell'utente `dev@dydat.dev` in DB risultava:
  ```
  profilo_sintetizzato: {}
  contesto_personale:   {}
  preferenze_tutor:     {}
  materie_attive:       ['matematica']   # unico dato salvato
  obiettivo_giornaliero_min: 20
  ```
  Le uniche cose che sopravvivono sono la materia scelta e l'obiettivo di default (20 min), tutto il resto della conversazione onboarding viene perso dal punto di vista del profilo.
- **Conseguenza diretta su B33.5**: l'helper `_preambolo_caldo` ha un branch per quando `profilo_sintetizzato is None` (fallback con saluto generico) e un branch per quando e presente (parafrasi dei campi `chi_e`, `motivo`, `stile_cognitivo`). Dato che il campo e sempre vuoto per ogni utente, **il branch "caldo con profilo" non si attiva mai in produzione**. B33.5 e tecnicamente implementato correttamente (14 test unitari verdi, pass-through in contesto.py corretto) ma il suo effetto visibile non puo manifestarsi finche ONB-01 non e fixato.
- **Cosa manca nel codice**:
  1. **Nessun tool LLM** che il tutor di onboarding puo chiamare per salvare campi del profilo durante la conversazione (es. `salva_chi_e`, `salva_motivo`, `salva_stile_cognitivo`).
  2. **Nessuna estrazione post-hoc**: alla fine dell'onboarding manca una call LLM (idealmente Haiku per costo) che legge la conversazione completa e produce il JSON del profilo strutturato.
  3. **Schema API incompleto**: `OnboardingCompletaRequest` non ha `profilo_sintetizzato` ne accetta il conversazione grezza.
  4. **`completa_onboarding` non scrive `profilo_sintetizzato`** anche se il campo fosse passato.
- **Fix proposto — ibrido (raccomandato)**:
  1. Aggiungere alla funzione `completa_onboarding` una chiamata Haiku che prende tutti i turni della sessione onboarding e ne estrae un JSON strutturato con `chi_e`, `motivo`, `stile_cognitivo`, `contesto_personale`, `preferenze_tutor`. Prompt di estrazione chiaro, output validato con Pydantic, fallback a dict vuoti se estrazione fallisce (no crash).
  2. Salvare il risultato in `utente.profilo_sintetizzato`, `utente.contesto_personale`, `utente.preferenze_tutor`.
  3. Niente modifiche al frontend (o modifiche minime a schemi).
- **Collegamenti**:
  - Questa e la causa radice per cui B33.5 non e testabile funzionalmente oggi.
  - E anche la barriera per far funzionare l'idea "onboarding narrativo" pensata per B39 (vedi `.claude/ideas.md` 2026-04-08).
  - PRE-01 (placement test non erogato) e nello stesso cluster di lacune dell'onboarding.
- **Candidato blocco**: `fix-onboarding-profile-extraction` (complessita media, 30-60 min) OPPURE integrarlo come primo sub-blocco di Fase 10 B39 "Onboarding con Momento Wow".

## ONB-02 — Turni del tutor di onboarding salvati con `contenuto = None`
- **Severita**: MEDIA (la conversazione e visualizzata correttamente all'utente durante la sessione, ma dopo la sessione 6 turni su 8 sono irrecuperabili dal DB)
- **Dove**: probabilmente `backend/app/core/onboarding.py` — funzione che gestisce lo streaming SSE del turno di onboarding, oppure il conversation manager
- **Sintomo**: Ispezionando i `turni_conversazione` della sessione onboarding di `dev@dydat.dev` (sessione `afcfa97f-...`) risultano 15 turni totali, 7 del tutor. Di questi 7, solo 2 hanno `contenuto` valorizzato ("Ciao! Sono il tuo tutor Dydat..." e "Perfetto, matematica! E un viaggio fantastico."). Gli altri 5 hanno `contenuto = None` nel DB anche se Villa li ha visti effettivamente sullo schermo durante l'onboarding (quindi il testo e stato streamato al client ma non persistito).
- **Causa probabile**: pattern classico dello streaming SSE — il turno assistente viene creato come riga placeholder nel DB all'inizio dello stream, poi il contenuto si accumula in memoria chunk per chunk, e **solo alla fine dello stream** viene fatta una singola UPDATE. Se quella UPDATE finale ha un bug (exception swallowed, condizione sbagliata, chiamata mancante in un path), il placeholder resta `None`. Notare che i 2 turni che invece sono salvati sono probabilmente quelli generati DAI LLM senza tool use (solo testo), mentre i 5 mancanti potrebbero essere quelli con tool use (ogni tool use spezza il flusso dello stream e probabilmente interrompe la logica di save finale).
- **Fix proposto**: trovare il punto dove il contenuto streamato viene persistito a fine turno, garantire che l'UPDATE avvenga anche quando ci sono tool use, e aggiungere logging se lo stream finisce senza contenuto. Aggiungere test unitario che simula uno stream con tool use e verifica la persistenza finale.
- **Impatto collaterale**: se lo stesso bug esiste nelle sessioni di studio normali (stessa infrastruttura streaming), ogni sessione di apprendimento potrebbe perdere parti della conversazione del tutor dalla storia persistita, con impatto sul contesto dei turni successivi e sui test di promozione che potrebbero basarsi sul contenuto delle risposte.
- **Da verificare**: fare lo stesso controllo su una sessione di studio reale per vedere se il problema e isolato all'onboarding o diffuso.
- **Candidato blocco**: `fix-streaming-persistence` (bassa complessita, 20 min) — prioritario se confermato impatto anche su sessioni di studio.



