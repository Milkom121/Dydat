# B39 — Onboarding Narrativo con Momento Wow

> Documento di design per il ridisegno dell'onboarding di Dydat.
> Esito della sessione di discovery con il fondatore del 2026-04-08.
> Base operativa per la scrittura degli handoff del runner Metodo Villa.
> Fase roadmap: **10** (Fase A.5 UX Redesign — Onboarding + Audio).
> Versione: **v1.0**.

---

## 1. Il problema, in breve

L'onboarding attuale di Dydat è rotto a cinque livelli, tutti emersi dal test manuale del 2026-04-08 dell'utente `dev@dydat.dev` e documentati in `.claude/test-findings.md`:

1. **ONB-01 CRITICO** — Il backend non salva `profilo_sintetizzato`, `contesto_personale` ne `preferenze_tutor` per nessun utente. Il frontend chiama `completeOnboarding()` senza argomenti, lo schema API non prevede i campi, e la funzione `completa_onboarding` in core non scrive mai `profilo_sintetizzato`. L'intera conversazione di onboarding viene persa dopo la sessione. Conseguenza diretta: il ramo "primo turno caldo" di B33.5 (implementato la notte del 2026-04-07) **non si attiva mai in produzione** perche il profilo e sempre vuoto.

2. **ONB-02** — I turni del tutor di onboarding vengono salvati con `contenuto = None` in 6 casi su 8, probabilmente per un bug nella persistenza dello streaming SSE quando ci sono tool use. La conversazione e visibile all'utente ma irrecuperabile dal DB.

3. **PRE-01** — Il test di posizionamento viene proposto dal tutor ma non eroga mai esercizi veri. L'utente lo accetta, il tutor finge di proseguire, e il percorso riparte dal nodo di default.

4. **DEV-01** — Il bottone "Login dev" bypassa completamente l'onboarding, rendendo i test manuali di B33.5 impossibili senza workaround.

5. **Tono burocratico** — Anche se funzionasse, l'onboarding attuale pone 5 domande strutturate con risposte telegrafiche ("matematica", "4", "mix"). Il materiale raccolto e troppo povero perche il primo turno caldo del tutor possa davvero parafrase e creare un saluto memorabile. L'onboarding burocratico e incoerente con l'identita calda di Dydat.

**Conseguenza di prodotto**: il primo contatto con Dydat e freddo, il tutor sembra un modulo digitale travestito, e l'infrastruttura di personalizzazione costruita in B33.5 resta inerte.

---

## 2. La visione del nuovo onboarding

Un flusso in cui l'utente **si racconta liberamente** (guidato ma non costretto), l'AI **estrae un profilo strutturato** dalla narrazione, eroga un **test di posizionamento leggero**, e alla fine produce dati abbastanza ricchi perche il primo turno del tutor (B33.5) possa davvero parafrase in modo naturale.

Il tutor e **personificato in prima persona** (io sono il tuo tutor Dydat), apre con un **patto esplicito** che dichiara cosa sta chiedendo e perche, e offre la **dettatura vocale** fin dal primo messaggio per abbattere la barriera della digitazione su smartphone. Il flusso e **adattivo** — chi e collaborativo chiude in pochi turni, chi e taciturno viene accompagnato con domande mirate, e chi vuole saltare lo puo fare con un banner in Home che lo inviterà a tornare.

**Obiettivo di prodotto**: il primo messaggio del tutor nella prima sessione di studio deve poter dire qualcosa come *"Ciao Marco, bentornato agli studi. Mi hai detto che stai riprendendo dopo una pausa e che ti piace partire dagli esempi concreti — perfetto, partiremo proprio da li"* — dimostrando al primo colpo che il tutor si ricorda dell'utente e ne conosce lo stile. E questo deve accadere per tutti gli utenti, non per quelli fortunati.

---

## 3. Le 12 decisioni di design prese con il fondatore

Queste sono le decisioni strategiche che guidano l'implementazione. Sono tutte state discusse e approvate in sessione di discovery il 2026-04-08. Per il dettaglio completo di ogni decisione con motivazioni, vedi `b39-discovery-notes.md`.

### Decisione 1 — Forma adattiva ibrida (Forma C)

L'onboarding si apre con **un turno libero iniziale** in cui il tutor invita l'utente a raccontarsi. Dopo questo primo turno, l'AI estrae quello che puo dal racconto e il tutor fa **domande mirate intelligenti solo sui campi rimasti vuoti o poveri**. Non e un questionario fisso, non e chat totalmente libera — il numero di turni varia tra 2 (per utenti molto collaborativi) e 7 (tetto massimo). L'esperienza si adatta all'utente, chi e pronto parte fulmineo, chi ha bisogno di guida viene accompagnato.

### Decisione 2 — Schema profilo a 5 campi

Il profilo raccolto dall'onboarding ha **5 campi**:

1. `chi_e` — identita in una frase (es. "adulto di 40 anni che riprende dopo anni di pausa")
2. `motivo` — perche studia, in linguaggio naturale (es. "curiosita personale, non per lavoro")
3. `stile_cognitivo` — come preferisce apprendere (es. "esempi concreti prima delle regole")
4. `tempo_disponibile` — quanto puo dedicare a Dydat tipicamente (es. "15-20 minuti ogni sera")
5. `vissuto_scolastico` — relazione emotiva con la materia in passato (es. "ho sempre odiato la matematica alle superiori, voglio riprovare da adulto con un approccio diverso")

I primi 3 sono compatibili con lo schema usato da B33.5 (il lavoro del 2026-04-07). Gli ultimi 2 sono nuovi e arricchiscono la personalizzazione del path planner e del tono del tutor.

**Nessuna distinzione obbligatori/opzionali**: tutti e 5 pesano uguale. L'onboarding e `completato` solo quando tutti e 5 sono presenti con contenuto **ricco** (non bassa confidenza).

### Decisione 3 — Tutor personificato in prima persona (Filosofia A)

Il tutor si presenta come **"io sono il tuo tutor Dydat"**, in prima persona, in modo personificante. Non come uno strumento, non come un assistente. Villa ha esplicitamente scelto questa direzione: *"non mi interessa che l'adulto possa avere il problema di parlare con una macchina. Il mondo va in questa direzione, devono adattarsi tutti. Voglio uno stile piu caldo e migliore."*

### Decisione 4 — Criterio di fine rigoroso + gestione edge case + skip rinviabile

**Criterio di fine**: onboarding `completato` solo quando tutti e 5 i campi sono presenti con contenuto ricco. Tetto massimo di 7 turni; oltre quel limite chiusura forzata con profilo parziale e `onboarding_stato = in_corso`.

**Qualita non solo presenza**: l'estrattore LLM produce per ogni campo un valore + una **confidenza** (`alta` / `media` / `bassa`). I campi a bassa confidenza sono trattati come mancanti. Risposte povere come "matematica" nel campo `motivo` non vengono scambiate per risposte sufficienti.

**Edge case**:
- **Utente taciturno**: dopo 5 turni senza progresso, tentativo con chip/pulsanti selezionabili; al turno 7, chiusura forzata.
- **Utente dilungato**: se al primo turno libero tutti i 5 campi sono riempiti con alta confidenza, il tutor chiude in 2 turni.
- **Off-topic**: il tutor risponde gentile, riporta al punto. Dopo 3 off-topic consecutivi, chiusura forzata.
- **Lingua diversa**: se rilevata lingua != italiano con alta confidenza, il tutor propone di impostare la lingua preferita per il futuro (salvando in un nuovo campo `lingua_preferita` sull'utente come placeholder per la futura localizzazione), continuando comunque in italiano.

**Skip**: l'onboarding NON e un muro obbligatorio. Bottone "Salta per ora" disponibile dalla prima schermata. Chi salta va dritto in Home con `onboarding_stato = in_corso` o `non_iniziato`. In Home compare una **card persistente non dismissibile** finche l'onboarding non e `completato`, con CTA "Riprendi" (se in corso) o "Inizia" (se non iniziato). Il "Riprendi" riapre la conversazione precedente intatta. Se l'utente avvia una sessione di studio senza profilo, B33.5 usa il ramo fallback (saluto caloroso generico).

**Hook gamification (registrato per futuro)**: completare l'onboarding sara il **primo achievement** di Dydat, integrato quando si tocchera il sistema achievement.

### Decisione 5 — Dettatura vocale ovunque (UX)

La dettatura vocale e una **feature trasversale** dell'applicazione, disponibile ovunque ci sia un campo di testo significativo. Pulsante microfono sempre visibile accanto al pulsante invia nei campi input (non nascosto in un menu "altro").

**UX del microfono**:
1. Tocco → campo input in "stato registrazione": wave animata sul volume della voce, timer secondi, pulsante stop rosso pulsante
2. Utente parla liberamente. **Nessun limite di tempo imposto** (solo i limiti tecnici dell'API STT e del dispositivo)
3. Stop → spinner di trascrizione
4. Testo trascritto appare nel campo di input, **modificabile prima di inviare** (no auto-invio)
5. Utente conferma con il normale pulsante invia

**Fallimenti** (permesso mic negato, rete assente, API giu): degradazione silenziosa, messaggio breve "La voce non e disponibile in questo momento — puoi continuare a scrivere", no blocchi.

### Decisione 6 — Scope della voce: widget riutilizzabile su 3 schermate

Nuovo widget Flutter `VoiceInputField` in `frontend/lib/widgets/` che incapsula tutto il comportamento vocale. Usato in:
1. Onboarding (campo chat del tutor)
2. Sessione di studio (campo chat del tutor durante studio)
3. Ricerca in "I miei studi" (campo di ricerca per nodi/parole chiave)

**Non incluso** in login/registrazione (inadeguato per email/password) e in campi molto corti.

**Dettatura di formule matematiche** (es. "x al quadrato + 3x - 2 = 0" → LaTeX): **rimandata** a un blocco futuro dedicato dopo B39, perche richiede un parser semantico separato dall'STT. Whisper produce testo grezzo, la traduzione verso LaTeX e problema a se.

### Decisione 7 — OpenAI Whisper come provider STT

Scelta: **Whisper** via API OpenAI. Motivi: qualita italiano eccellente, costo ~$0.006/minuto (3-4x inferiore ad Azure/Google), integrazione semplice, latenza trascurabile. Nuovo segreto `OPENAI_API_KEY` da aggiungere al backend. La chiave vive SOLO server-side, l'app chiama un endpoint proxy `/stt/transcribe`.

### Decisione 8 — Test di posizionamento: auto-valutazione + verifica mirata compound

**Fase auto-valutazione**: durante la parte narrativa, il tutor chiede per ogni area chiave `forte` / `incerto` / `digiuno`.

**Fase verifica selettiva** (solo aree "forte"):
- **Cap duro**: massimo 3 esercizi di verifica, ciascuno copre fino a 2 concetti (max 6 aree verificate)
- Se l'utente dichiara forte su piu di 6 aree, verifichiamo le 6 piu fondazionali (partendo dai nodi piu "in basso" nel grafo curriculum); le rimanenti sono accettate come "forte senza verifica"
- Scala adattiva: 1-2 aree → 1-2 esercizi singoli; 3-4 → 2 esercizi compound; 5-6 → 3 esercizi compound; 7+ → 3 esercizi sulle 6 fondazionali
- Tipo esercizio: scelta multipla con 3-4 opzioni, 1 risposta corretta

Le aree `incerto` e `digiuno` NON vengono verificate (trust sull'onestà dell'utente).

**Provenienza esercizi**: (a) quelli gia nel DB curriculum se presenti, (b) generazione on-the-fly via Opus per le aree senza esercizi.

**Regola fallimento**: compound exercise sbagliato → entrambi i concetti retrocedono a `incerto`. Tono in caso di fallimento: **trasparente-caldo** (*"sai, su questo ho trovato un po' di incertezza — non e niente, capita, lo rivedremo insieme"*).

**Conteggio turni**: le verifiche stanno **fuori dal conteggio dei 7 turni narrativi**. Hanno il proprio cap (max 3 esercizi).

**Skip del placement**: valido come per la narrativa.

**Evoluzione futura registrata**: estensione del placement con domande Feynman-style *"spiega il tuo ragionamento"* **rimandata a B43 Feynman Signal Processing** o blocco successivo della stessa famiglia. Motivo: duplicherebbe il lavoro di B43 e esploderebbe lo scope di B39.

### Decisione 9 — Estrazione del profilo: singola chiamata LLM post-turno (Strada 1)

Dopo ogni turno utente dell'onboarding, il backend fa **una chiamata LLM** che legge la conversazione completa finora e restituisce il JSON strutturato con 5 campi + confidenze. Il risultato alimenta il decisore della Forma C. Retry su fallimento (1 volta); se fallisce ancora, il decisore usa lo stato precedente o accetta profilo vuoto. Niente crash.

**Scartato**: tool use in-stream (troppi punti di fallimento, difficile da debuggare). Single-call post-turno e piu semplice, piu testabile, latenza trascurabile.

### Decisione 10 — Opus 4.6 per tutto l'onboarding e il placement

**Decisione direttiva di Villa**: Opus 4.6 per tutte le chiamate LLM del flusso onboarding e placement. Niente Haiku, niente Sonnet.

Ripartizione concreta:
- **Tutor che conduce la conversazione narrativa** → Opus 4.6
- **Estrattore profilo (single call post-turno)** → Opus 4.6
- **Decisore forma C** → **zero LLM, pure regole Python** (deterministico, gratis, testabile)
- **Generatore esercizi compound per il placement** → Opus 4.6
- **Correttore esercizi scelta multipla** → **zero LLM, confronto deterministico**

**Costo stimato**: ~$0.30-$0.50 per onboarding completo. Con 1000 nuovi utenti/mese → ~$300-500/mese di spesa Opus onboarding. Accettabile per una fase critica e infrequente (ogni utente la fa una volta sola).

**Rationale di Villa**: *"Serve molta intelligenza per gestire questa fase. Non te lo sto chiedendo, te lo sto dicendo."*

### Decisione 11 — Refactor progressivo del codice onboarding esistente

Manteniamo lo scheletro esistente (endpoint `/onboarding/inizia`, `/onboarding/turno`, `/onboarding/completa`, `onboarding_screen.dart`, `onboarding_provider.dart`) e lo modifichiamo chirurgicamente. Non cancelliamo e riscriviamo. Lo scheletro attuale e decente come struttura — i problemi erano nei comportamenti. Refactor progressivo = meno lavoro, meno rischio di reintrodurre bug.

### Decisione 12 — Ordine: onboarding prima della registrazione (flusso attuale mantenuto)

Il flusso resta: `login screen → onboarding (utente temp) → registrazione (converte temp in reale) → home`. L'utente puo chattare col tutor senza aver ancora creato un account. Al termine (o al momento dello skip) viene invitato a registrarsi con email/password. Il backend esistente gia supporta la conversione `utente_temp → utente_reale` via `utente_temp_id`. Nessun guest mode.

**Rationale**: il tutor chattante come prima esperienza e memorabile, la registrazione anticipata la rovinerebbe.

### Decisione implicita — System prompt

- **Tutor di onboarding**: **system prompt riscritto da zero** in B39.8.3, per supportare Forma C adattiva, patto esplicito, menzione voce, tono personificato (filosofia A).
- **Tutor di sessione**: invariato. Il system prompt attuale (`backend/app/llm/prompts/system_prompt.py`) e gia compatibile con il nuovo profilo arricchito — B33.5 attiva il ramo caldo quando il profilo e presente, e funzionera automaticamente una volta che il profilo sara popolato dal nuovo onboarding.

---

## 4. Come sara, concretamente, il nuovo onboarding

Ecco un esempio di flusso completo per un utente "medio" (non troppo taciturno, non troppo dilungato):

### Primo turno — Apertura con patto esplicito
> **Tutor**: *"Ciao, piacere di conoscerti, io sono il tuo tutor Dydat. Prima di metterci a studiare voglio essere onesto con te: il modo in cui ti conoscero adesso determina quanto potro davvero aiutarti. Raccontami di te, fammi capire chi sei e cosa ti ha portato qui. Ti faccio anche qualche domanda veloce per capire da che punto partire. Sono pochi minuti, ma fanno una vera differenza. Se preferisci saltare e vedere prima l'app, puoi farlo — troverai il mio invito a tornare qui quando vorrai. Se ti va, puoi anche dettarmi le risposte a voce, vedi il pulsante del microfono qui sotto. Iniziamo?"*

(Il pulsante microfono e visibile accanto al pulsante invia.)

> **Utente** (*dettando a voce*): "Ciao, sono Marco, ho 42 anni, faccio il grafico freelance. Ho sempre avuto un brutto rapporto con la matematica alle superiori, l'ho odiata per anni perche non capivo niente. Adesso voglio riprovarci da adulto, in tranquillita, senza nessuno che mi dia voti. Vorrei capire un po' le basi che mi mancano, ma ho poco tempo — al massimo venti minuti a sera dopo che ho chiuso il lavoro."

(L'estrattore Opus legge questa risposta e riempie: `chi_e` (alta), `motivo` (alta), `vissuto_scolastico` (alta), `tempo_disponibile` (alta). Manca solo `stile_cognitivo`.)

### Secondo turno — Domanda mirata sul buco
> **Tutor**: *"Grazie Marco, mi hai dato un'immagine chiara di chi sei. Ti faccio una sola domanda in piu prima di partire: quando devi capire qualcosa di nuovo, ti viene piu facile partire da esempi concreti ("guarda, se hai 3 mele e ne mangi 1...") o da regole astratte ("vale la regola che a + b = b + a")? Anche una via di mezzo va bene, dimmi come ti trovi meglio."*

> **Utente**: "Parto sempre da esempi concreti, le regole astratte mi mandano in confusione subito."

(Profilo `stile_cognitivo` estratto con alta confidenza. Tutti e 5 i campi sono pieni e ricchi. L'onboarding narrativo e **completo**.)

### Terzo turno — Transizione all'auto-valutazione
> **Tutor**: *"Perfetto, ho capito cosa ti serve. Ora ti faccio una cosa veloce: ti leggo alcune aree della matematica di base, per ciascuna dimmi se ti senti forte, incerto, o completamente a digiuno. Non e un test, e solo per capire da che punto partire."*

> **Tutor**: *"Come ti senti su: operazioni con le frazioni?"* → **Utente**: "Incerto."
> **Tutor**: *"Potenze e radici?"* → **Utente**: "Forte."
> **Tutor**: *"Equazioni di primo grado?"* → **Utente**: "Digiuno."
> **Tutor**: *"Geometria di base?"* → **Utente**: "Forte."
> **Tutor**: *"Percentuali e proporzioni?"* → **Utente**: "Incerto."

(L'utente ha dichiarato "forte" su 2 aree: potenze e geometria. Scala: 1-2 aree → 1-2 esercizi singoli. Verifichiamo entrambe.)

### Quarto turno — Verifica su potenze
> **Tutor**: *"Quanto fa 2 elevato alla terza meno 3 elevato alla seconda? Scegli una risposta:*
> *A) -1*
> *B) 0*
> *C) 17*
> *D) 35"*

> **Utente**: "A) -1"

(Corretto → `potenze` confermato come forte.)

### Quinto turno — Verifica su geometria
> **Tutor**: *"L'area di un triangolo con base 6 e altezza 4 e:*
> *A) 10*
> *B) 12*
> *C) 24*
> *D) 48"*

> **Utente**: "B) 12"

(Corretto → `geometria` confermato come forte. Tutti gli esercizi di verifica passati.)

### Sesto turno — Chiusura
> **Tutor**: *"Perfetto Marco, ho tutto quello che mi serve. Ti ho conosciuto, ho capito dove sei e dove vogliamo andare. Ora ti propongo di creare il tuo account in due secondi per tenere traccia dei tuoi progressi, poi ti porto dritto nella tua prima sessione di studio. Partiremo dalle frazioni — visto che mi hai detto di essere un po' incerto li — con qualche esempio concreto come preferisci tu. Ti va?"*

### Schermata di registrazione
(L'utente conferma, viene portato alla registrazione, inserisce email/password, l'utente temp viene convertito in reale, il profilo con i 5 campi + la mappa placement viene salvato sull'utente, e il path planner sceglie il nodo di partenza "frazioni base".)

### Prima sessione di studio (attiva B33.5)
> **Tutor nella sessione di studio**: *"Ciao Marco, bentornato. So che vuoi riprovarci da adulto dopo anni di frustrazioni — tranquillo, oggi parto con un esempio concreto come ti piace a te. Abbiamo venti minuti insieme, li usiamo bene. Partiamo dalle frazioni: se ti dico che hai una pizza tagliata in 8 fette e ne mangi 3, quanta pizza ti resta? Rispondi come ti viene, anche a intuito."*

Questo e il tono target. E' l'esito concreto di tutto il lavoro di B39 + B33.5 messi insieme.

---

## 5. Cosa va toccato nel codice

### 5.1 Backend (Python/FastAPI)

**Database**:
- Nuova migrazione Alembic: aggiungi `onboarding_stato` (enum: `not_started`/`in_progress`/`completed`, default `not_started`) e `lingua_preferita` (string, default `it`) alla tabella `utenti`
- Aggiornare modello SQLAlchemy `Utente` (`backend/app/db/models/utenti.py`)
- Aggiornare schemi Pydantic API per serializzare i nuovi campi

**Prompt files nuovi** (`backend/app/llm/prompts/`):
- `onboarding_system_prompt.py` — NUOVO. System prompt del tutor di onboarding (personificato, patto esplicito, forma C adattiva)
- `onboarding_extractor.py` — NUOVO. Prompt di estrazione profilo da conversazione. Output: JSON `{campo: {valore, confidenza}}` per i 5 campi
- `onboarding_self_assessment.py` — NUOVO. Prompt per la fase di auto-valutazione (domande forte/incerto/digiuno sulle aree curriculum)
- `onboarding_exercise_generator.py` — NUOVO. Prompt per generare esercizi compound (max 2 concetti, scelta multipla)

**Core onboarding** (`backend/app/core/onboarding.py`):
- Nuova funzione `estrai_profilo(conversazione: list[dict]) -> ProfiloEstratto` che chiama Opus
- Nuova funzione `decidi_prossima_mossa(profilo_stato, turni_fatti, fase_placement) -> Decisione` — rules-based, pura Python
- Nuova funzione `genera_esercizi_verifica(aree_forte, grafo) -> list[EsercizioCompound]` che chiama Opus
- Nuova funzione `valuta_risposta_esercizio(esercizio, risposta_utente) -> bool` — deterministica
- Modifica `completa_onboarding` per scrivere `profilo_sintetizzato`, `contesto_personale`, `preferenze_tutor` usando i risultati dell'estrazione
- Fix persistenza streaming turni (ONB-02) dove il contenuto del turno assistente resta None

**API onboarding** (`backend/app/api/onboarding.py`):
- Modifica endpoint `/onboarding/turno` per chiamare l'estrattore dopo ogni turno utente e il decisore per determinare la prossima mossa
- Nuovi payload di risposta che includono la fase corrente (conoscenza / auto-valutazione / verifica / chiusura), la prossima azione, gli esercizi proposti

**Endpoint STT nuovo** (`backend/app/api/stt.py` — NUOVO):
- `POST /stt/transcribe` — accetta audio multipart, chiama Whisper via client OpenAI, ritorna testo trascritto
- Validazione dimensione/formato audio, gestione errori, rate limiting base

**Config** (`backend/app/config.py`):
- Aggiungere `OPENAI_API_KEY` alla config + `validate_secrets_for_startup`
- Aggiornare `.env.example` con la nuova variabile + commento esplicativo
- Aggiornare `docker-compose.yml` per passare la nuova variabile

**Schemi Pydantic** (`backend/app/schemas/onboarding.py`):
- `OnboardingCompletaRequest` → schema per conversione temp user, senza `contesto_personale` / `preferenze_tutor` (che ora sono derivati dall'estrazione, non passati dal frontend)
- Nuovi schemi: `ProfiloEstratto`, `CampoConConfidenza`, `EsercizioCompound`, `RispostaEsercizio`, `MappaPlacement`

### 5.2 Frontend (Flutter/Dart)

**Widget nuovi** (`frontend/lib/widgets/`):
- `voice_input_field.dart` — NUOVO. Widget riutilizzabile che sostituisce `TextFormField` con:
  - Campo testo classico
  - Pulsante microfono accanto al pulsante invia
  - Stato registrazione: wave animata, timer, pulsante stop
  - Chiamata a `/stt/transcribe` con upload audio
  - Trascrizione modificabile prima di inviare
  - Gestione errori silenziosa
- `onboarding_pending_banner.dart` — NUOVO. Banner persistente per la Home con CTA "Riprendi" / "Inizia"

**Schermate da modificare**:
- `frontend/lib/presentation/onboarding_screen/onboarding_screen.dart` — riscrittura per usare `VoiceInputField`, aggiunta skip button, nuovo flusso adattivo (conoscenza → auto-valutazione → verifica → chiusura)
- `frontend/lib/presentation/home_screen/home_screen.dart` — integrazione `OnboardingPendingBanner` condizionale su `onboarding_stato != completato`
- `frontend/lib/presentation/session_screen/` (dove e il campo input chat) — sostituire `TextFormField` con `VoiceInputField`
- `frontend/lib/presentation/learning_path_screen/` (dove e il campo ricerca) — sostituire con `VoiceInputField`

**Provider**:
- `frontend/lib/providers/onboarding_provider.dart` — aggiornare `completeOnboarding()` per passare i dati reali, gestire le nuove fasi, gestire lo skip

**Modelli**:
- `frontend/lib/models/onboarding.dart` — nuovi campi per rappresentare profilo estratto, mappa placement, esercizi compound

### 5.3 Cose che NON vanno toccate

- **`backend/app/llm/prompts/system_prompt.py`** (tutor di sessione) — resta invariato, e gia compatibile
- **Schema DB del grafo curriculum** (tabella `nodi`) — non tocchiamo il curriculum
- **B33.5** (`direttiva_spiegazione`, `_preambolo_caldo`, `direttiva_ripresa_sessione`) — resta invariato, si attivera automaticamente con il nuovo profilo
- **Login/Registrazione** — i campi email/password non hanno dettatura vocale
- **Login dev button** (`_handleDevLogin`) — fuori scope di B39. Il fix di DEV-01 va in un blocco auth dedicato successivo

---

## 6. Idee parcheggiate per il futuro (NON fanno parte di B39)

### 6.1 Dettatura di formule matematiche

Trasformare il parlato matematico ("x al quadrato piu 3x meno 2 uguale zero") in LaTeX (`x^2 + 3x - 2 = 0`) richiede un parser semantico separato dall'STT. Candidato: blocco futuro dedicato dopo l'implementazione degli esercizi veri in Fase 12+. Nome provvisorio: **"B-voice-matematica"**. L'infrastruttura voce di B39 sara la base su cui costruire questo passaggio.

### 6.2 Estensione Feynman del placement test

Arricchire il placement test con domande narrative tipo *"spiega il tuo ragionamento"*, valutate da un LLM grader che distingue "sa ripetere" da "ha interiorizzato". Rimandato a **B43 Feynman Signal Processing** (Fase 12). Quando si aprira la discovery di B43, leggere questo documento e integrare l'estensione come uno degli use case dell'infrastruttura Feynman.

### 6.3 Primo achievement di gamification

Completare l'onboarding sara il **primo achievement** di Dydat ("Il tuo primo racconto" o nome equivalente). Implementazione vera rimandata al momento in cui si toccera il sistema achievement. Registrato qui come intenzione di design.

### 6.4 Localizzazione

Il campo `lingua_preferita` introdotto in B39 e un placeholder. Quando si decidera di aggiungere l'inglese (o altre lingue), gli utenti che hanno gia dichiarato una preferenza saranno automaticamente etichettati. Zero lavoro retroattivo.

### 6.5 Revisione del modello temporale Dydat

Idea gia registrata in `.claude/ideas.md` (macro-riprogettazione basata su neuroscienze apprendimento mobile, micro-cicli 3-7 min, richiamo attivo). NON e collegata a B39, ma B39 potrebbe dover essere rivisto quando arriverà quella riprogettazione piu grande.

---

## 7. Il piano di esecuzione — 38 sub-blocchi in 11 fasi

Ogni sub-blocco ha: **ID**, **obiettivo**, **file principali da toccare**, **test obbligatori**, **gate di uscita**. Il runner esegue i sub-blocchi in ordine sequenziale. Ogni sub-blocco chiude con commit atomico + push (regola auto-push runner gia configurata).

### Fase 1 — Preparazione Database (3 sub-blocchi)

**B39.1.1** — Migrazione Alembic per nuovi campi utente
- Obiettivo: aggiungere `onboarding_stato` (enum) e `lingua_preferita` (string) alla tabella `utenti`
- File: nuova migrazione in `backend/alembic/versions/`
- Test: eseguire migrazione, verificare schema; rollback; re-upgrade
- Gate: migrazione applicata in ambiente docker locale, schema verificato con `\d utenti`

**B39.1.2** — Aggiornamento modello SQLAlchemy `Utente`
- Obiettivo: esporre i nuovi campi nel modello Python
- File: `backend/app/db/models/utenti.py`
- Test: unit test che verifica accesso ai nuovi campi con default, serializzazione
- Gate: modello aggiornato, tutti i test utenti esistenti continuano a passare

**B39.1.3** — Aggiornamento schemi Pydantic API
- Obiettivo: serializzare i nuovi campi nelle response API di `/utente/me` e simili
- File: `backend/app/schemas/utente.py`
- Test: integration test endpoint `/utente/me` verifica i nuovi campi presenti
- Gate: endpoint ritorna i nuovi campi, contract test verde

### Fase 2 — Cervello estrattore profilo (4 sub-blocchi)

**B39.2.1** — Prompt estrattore profilo
- Obiettivo: scrivere il prompt Opus che estrae i 5 campi del profilo dalla conversazione onboarding con confidenze
- File: nuovo `backend/app/llm/prompts/onboarding_extractor.py`
- Test: unit test sul prompt (presenza delle istruzioni chiave, formato JSON atteso)
- Gate: prompt scritto in italiano, output JSON specificato rigidamente, esempi few-shot minimali se servono

**B39.2.2** — Schema Pydantic output estrattore
- Obiettivo: modelli dati per rappresentare il profilo estratto + confidenze
- File: `backend/app/schemas/onboarding.py` (aggiungere `CampoConConfidenza`, `ProfiloEstratto`)
- Test: unit test validazione, serializzazione/deserializzazione
- Gate: schemi definiti, test di validazione verdi

**B39.2.3** — Funzione `estrai_profilo` con chiamata Opus
- Obiettivo: funzione Python che prende la conversazione, chiama Opus con il prompt, parsa il JSON, gestisce retry su fallimento
- File: `backend/app/core/onboarding.py` (nuova funzione)
- Test: unit test con mock LLM (JSON prefabbricati), test retry logic, test fallimento totale
- Gate: funzione robusta, retry 1 volta, fallback a profilo vuoto su errore irrecuperabile

**B39.2.4** — Unit test integrazione estrattore
- Obiettivo: test che verifica il comportamento dell'estrattore su scenari realistici (utente ricco, utente povero, utente off-topic)
- File: `backend/tests/test_onboarding_extractor.py` (nuovo)
- Test: 5+ scenari con mock LLM
- Gate: tutti i test verdi, copertura del caso "estrazione parziale" e "estrazione totalmente fallita"

### Fase 3 — Decisore forma C (2 sub-blocchi)

**B39.3.1** — Rules-based decisor puro Python
- Obiettivo: funzione deterministica che, dato lo stato del profilo + turni fatti, decide la prossima mossa (chiedi campo X, passa a auto-valutazione, termina onboarding)
- File: `backend/app/core/onboarding.py` (nuova funzione `decidi_prossima_mossa`)
- Test: unit test esaustivi sui rami (profilo vuoto, profilo parziale con bassa confidenza, profilo completo, tetto turni raggiunto)
- Gate: 10+ test unitari verdi, zero dipendenze da LLM

**B39.3.2** — Integrazione decisore nell'endpoint `/onboarding/turno`
- Obiettivo: dopo ogni turno utente, chiamare estrattore + decisore per determinare la prossima mossa del tutor
- File: `backend/app/api/onboarding.py` (modifica endpoint turno)
- Test: integration test del flusso turno completo con mock LLM
- Gate: endpoint turno ritorna la prossima mossa, flusso completo verde

### Fase 4 — Fix bug onboarding esistenti (3 sub-blocchi)

**B39.4.1** — Fix `completa_onboarding` per scrivere il profilo (ONB-01)
- Obiettivo: la funzione deve scrivere `profilo_sintetizzato`, `contesto_personale`, `preferenze_tutor` usando i dati estratti dalla conversazione
- File: `backend/app/core/onboarding.py` (modifica `completa_onboarding`), `backend/app/api/onboarding.py` (payload schema)
- Test: integration test che verifica i 3 campi popolati nel DB dopo il completamento
- Gate: ONB-01 chiuso, i test manuali degli onboarding precedenti ora funzionano

**B39.4.2** — Fix persistenza streaming turni (ONB-02)
- Obiettivo: i turni del tutor devono essere salvati con il `contenuto` effettivo, anche in presenza di tool use
- File: `backend/app/api/onboarding.py` o `backend/app/core/onboarding.py` (dove gira lo streaming SSE)
- Test: unit test sulla persistenza con mock stream che include tool use + contenuto testuale
- Gate: test che simula uno stream con tool use verifica che il contenuto finale sia salvato nel DB

**B39.4.3** — Pulizia codice onboarding legacy
- Obiettivo: rimuovere codice dell'onboarding vecchio non piu utilizzato dopo il refactor
- File: vari in `backend/app/core/onboarding.py` e `backend/app/api/onboarding.py`
- Test: tutti i test esistenti continuano a passare
- Gate: codice piu pulito, nessuna regressione

### Fase 5 — Motore voce Whisper (3 sub-blocchi)

**B39.5.1** — Configurazione `OPENAI_API_KEY`
- Obiettivo: aggiungere la chiave OpenAI alla config del backend
- File: `backend/app/config.py`, `backend/.env.example`, `backend/docker-compose.yml`, `docs/dev-shortcuts.md` (registrare la nuova dipendenza esterna)
- Test: unit test che verifica `validate_secrets_for_startup` fallisce se la chiave manca in produzione
- Gate: chiave configurata, backend parte con la chiave presente, fallisce con errore chiaro se assente

**B39.5.2** — Endpoint `POST /stt/transcribe`
- Obiettivo: nuovo endpoint che riceve audio multipart, chiama Whisper, ritorna testo trascritto
- File: nuovo `backend/app/api/stt.py`, router registrato in `backend/app/main.py`
- Test: unit test con mock client OpenAI, test formato audio invalido, test API down
- Gate: endpoint funzionante, test unitari verdi

**B39.5.3** — Test endpoint STT con audio reale
- Obiettivo: un test di integrazione con audio reale di smoke (file WAV di test nel repo)
- File: `backend/tests/test_stt.py` (nuovo, marcato `@pytest.mark.integration`)
- Test: chiama Whisper con audio italiano di prova, verifica trascrizione plausibile
- Gate: test skippato di default, eseguibile on-demand con flag integration, verde in esecuzione manuale

### Fase 6 — Placement test backend (6 sub-blocchi)

**B39.6.1** — Prompt auto-valutazione
- Obiettivo: prompt che istruisce il tutor a chiedere forte/incerto/digiuno per le aree chiave della materia
- File: nuovo `backend/app/llm/prompts/onboarding_self_assessment.py`
- Test: unit test presenza delle istruzioni chiave
- Gate: prompt scritto, aree selezionate dal curriculum del grafo

**B39.6.2** — Logica selezione aree fondazionali
- Obiettivo: funzione che, data la lista aree dichiarate "forte" dall'utente, seleziona le N piu fondazionali usando il grafo curriculum
- File: `backend/app/core/onboarding.py` (nuova funzione `seleziona_aree_fondazionali`)
- Test: unit test con grafo mockato, verifica che le aree con meno prerequisiti vengono prima
- Gate: funzione deterministica, test verdi, integrazione con curriculum reale

**B39.6.3** — Prompt generatore esercizi compound
- Obiettivo: prompt Opus per generare un esercizio a scelta multipla che combina 2 concetti
- File: nuovo `backend/app/llm/prompts/onboarding_exercise_generator.py`
- Test: unit test presenza istruzioni (max 2 concetti, 3-4 opzioni, 1 risposta corretta)
- Gate: prompt scritto in italiano, output JSON specificato

**B39.6.4** — Funzione `genera_esercizi_verifica`
- Obiettivo: funzione Python che prende le aree da verificare (in coppie), chiama Opus per ciascuna coppia, ritorna lista di esercizi compound
- File: `backend/app/core/onboarding.py`
- Test: unit test con mock LLM, test schema output
- Gate: funzione robusta, retry su fallimento, ritorna lista vuota in caso di fallimento totale

**B39.6.5** — Logica grading deterministico
- Obiettivo: funzione che confronta la risposta dell'utente con la risposta corretta, ritorna bool + concetti retroceduti in caso di fail
- File: `backend/app/core/onboarding.py` (nuova funzione `valuta_risposta`)
- Test: unit test con risposte corrette e sbagliate, verifica retrocessione concetti
- Gate: funzione deterministica, test verdi

**B39.6.6** — Integrazione stato_orchestratore + path planner
- Obiettivo: salvare la mappa placement finale (`{concetto: forte_confermato/forte_unverified/incerto/digiuno}`) nello `stato_orchestratore` della sessione onboarding, e farla leggere al path planner per scegliere il nodo di partenza
- File: `backend/app/core/onboarding.py`, `backend/app/core/path_planner.py` (o equivalente)
- Test: integration test del flusso completo onboarding + placement + creazione percorso
- Gate: l'utente post-onboarding ha un percorso col nodo di partenza coerente con la mappa placement

### Fase 7 — Widget VoiceInputField (6 sub-blocchi)

**B39.7.1** — Scheletro widget
- Obiettivo: file Flutter con struttura base del widget (TextFormField + pulsante mic disabilitato)
- File: nuovo `frontend/lib/widgets/voice_input_field.dart`
- Test: widget test che verifica rendering base
- Gate: widget compila, rendering verde

**B39.7.2** — Integrazione libreria audio + permessi
- Obiettivo: aggiungere libreria audio (`record` o equivalente), gestire permessi microfono per Android/iOS
- File: `frontend/pubspec.yaml`, `frontend/android/app/src/main/AndroidManifest.xml`, `frontend/ios/Runner/Info.plist`, `voice_input_field.dart`
- Test: widget test con mock audio
- Gate: permessi configurati, libreria integrata, widget inizia/ferma registrazione

**B39.7.3** — UI stato registrazione (wave + timer + stop)
- Obiettivo: feedback visivo durante la registrazione (wave animata sul volume, timer secondi, pulsante stop rosso pulsante)
- File: `voice_input_field.dart`
- Test: widget test stato registrazione attivo
- Gate: UI registrazione renderizza correttamente, animazioni fluide

**B39.7.4** — Chiamata endpoint `/stt/transcribe`
- Obiettivo: dopo lo stop della registrazione, upload dell'audio al backend, gestione spinner
- File: `voice_input_field.dart`, `frontend/lib/services/stt_service.dart` (nuovo)
- Test: widget test con mock service
- Gate: upload funzionante, spinner visibile durante la chiamata

**B39.7.5** — Popolamento campo testo con trascrizione modificabile
- Obiettivo: il testo trascritto appare nel campo, l'utente puo modificarlo prima di inviare
- File: `voice_input_field.dart`
- Test: widget test flusso completo registrazione → trascrizione → modifica → invio
- Gate: l'utente puo modificare il testo dopo la trascrizione, submit normale

**B39.7.6** — Gestione errori + widget test finali
- Obiettivo: gestione permesso negato, rete assente, API STT down, audio troppo corto; fallback silenzioso
- File: `voice_input_field.dart`
- Test: widget test sui fallimenti, verifica messaggi degradati
- Gate: tutti i fallimenti gestiti, utente puo sempre scrivere a mano

### Fase 8 — Integrazione onboarding (4 sub-blocchi)

**B39.8.1** — Aggiorna `onboarding_provider.dart`
- Obiettivo: il provider deve passare i dati reali al backend, gestire le nuove fasi, gestire lo skip
- File: `frontend/lib/providers/onboarding_provider.dart`
- Test: unit test provider con nuove fasi
- Gate: provider aggiornato, test verdi

**B39.8.2** — Riscrittura `onboarding_screen.dart` con `VoiceInputField` + skip
- Obiettivo: schermata di onboarding usa il nuovo widget, ha il bottone "Salta per ora" visibile
- File: `frontend/lib/presentation/onboarding_screen/onboarding_screen.dart`
- Test: widget test nuovo flusso, test skip
- Gate: schermata renderizza correttamente, skip porta in Home con stato `in_corso`

**B39.8.3** — System prompt tutor onboarding
- Obiettivo: scrivere il system prompt del tutor di onboarding (personificato, patto esplicito, forma C adattiva, menzione voce)
- File: nuovo `backend/app/llm/prompts/onboarding_system_prompt.py`
- Test: unit test presenza delle istruzioni chiave (nome "io sono Dydat", patto, menzione voce, adattivita)
- Gate: prompt scritto in italiano, integrato nel flusso del turno

**B39.8.4** — Test integrazione onboarding completo
- Obiettivo: test end-to-end del flusso onboarding con mock LLM (utente collaborativo → completamento)
- File: `frontend/test/presentation/onboarding_screen_test.dart` (o equivalente)
- Test: widget test flusso completo
- Gate: flusso verde da inizio a fine, stato finale corretto

### Fase 9 — Banner Home (3 sub-blocchi)

**B39.9.1** — Widget `OnboardingPendingBanner`
- Obiettivo: card persistente, non dismissibile, con messaggio caldo + CTA
- File: nuovo `frontend/lib/widgets/onboarding_pending_banner.dart`
- Test: widget test rendering + tap su CTA
- Gate: widget pronto, test verdi

**B39.9.2** — Integrazione banner in `home_screen.dart`
- Obiettivo: il banner compare condizionale su `onboarding_stato != completato`
- File: `frontend/lib/presentation/home_screen/home_screen.dart`
- Test: widget test con stato vario (not_started, in_progress, completed)
- Gate: banner visibile solo quando serve

**B39.9.3** — Logica "Riprendi" con stato preservato
- Obiettivo: il tap su "Riprendi" riapre `/onboarding` con la conversazione precedente intatta (backend deve supportare il retrieval della sessione esistente)
- File: `onboarding_provider.dart`, `onboarding_screen.dart`, backend `/onboarding/inizia` (modificato per riprendere invece di creare)
- Test: integration test riprendere onboarding dopo skip
- Gate: riprendere funziona, la conversazione precedente e visibile all'utente

### Fase 10 — Voce trasversale (3 sub-blocchi)

**B39.10.1** — `VoiceInputField` in chat di sessione studio
- Obiettivo: sostituire il campo input della chat tutor in sessione con il nuovo widget
- File: schermata di session screen dove c'e il campo input
- Test: widget test integrazione
- Gate: microfono visibile e funzionante in sessione

**B39.10.2** — `VoiceInputField` in ricerca "I miei studi"
- Obiettivo: sostituire il campo di ricerca con il nuovo widget
- File: `learning_path_screen.dart` o widget search correlato
- Test: widget test integrazione
- Gate: microfono visibile e funzionante nella ricerca

**B39.10.3** — Widget test finali integrazione trasversale
- Obiettivo: test che verificano che il widget si comporta bene in tutti i contesti (onboarding, sessione, ricerca)
- File: test widget vari
- Gate: tutti i test verdi, nessuna regressione

### Fase 11 — Test manuale finale (1 sub-blocco)

**B39.11.1** — Checklist test manuale + consegna
- Obiettivo: Claude prepara un file `docs/discussions/b39-checklist-test-manuale.md` con scenari dettagliati per il test manuale di Villa (utente collaborativo, utente taciturno, off-topic, skip, voce, placement, banner)
- File: nuovo `docs/discussions/b39-checklist-test-manuale.md`
- Test: nessun test automatico — questo sub-blocco e pura documentazione
- Gate: file creato, scenari chiari con "cosa aspettarsi" e "cosa segnalare", pronto per Villa

**Dopo B39.11.1**: Villa esegue i test, riporta i finding in `.claude/test-findings.md`. Eventuali bug vengono risolti in blocchi successivi `B39.fix.*`, non inclusi in questo piano.

---

## 8. Come Villa testera il risultato

Il test manuale completo sara documentato in un file a parte (`docs/discussions/b39-checklist-test-manuale.md`) creato al sub-blocco B39.11.1. Qui anticipo solo l'essenza.

### Scenari da testare
1. **Utente collaborativo** — registra nuovo utente, dai risposte ricche, completa onboarding in 3-5 turni, verifica che il profilo in DB contenga i 5 campi popolati con contenuto sostanzioso
2. **Utente taciturno** — registra nuovo utente, dai risposte di 2-3 parole ciascuna, verifica che dopo il turno 7 l'onboarding si chiuda con profilo incompleto e il banner in Home appaia
3. **Utente off-topic** — registra nuovo utente, rispondi con cose tipo "che ora e?" o "fammi una barzelletta", verifica che il tutor riconduca al punto e dopo 3 off-topic chiuda
4. **Skip immediato** — premi subito "Salta per ora", verifica che arrivi in Home con il banner persistente, tap sul banner riapre l'onboarding
5. **Dettatura vocale** — apri il microfono nel campo, parla per 30 secondi, verifica che la trascrizione appaia modificabile e corretta (al 90%), modifica una parola, invia
6. **Placement test** — dichiara "forte" su 2-3 aree, verifica che il tutor proponga esercizi compound, rispondi giustamente, verifica nella console che la mappa placement sia aggiornata
7. **Placement fail** — dichiara "forte" su un'area, rispondi male all'esercizio, verifica il messaggio trasparente-caldo e la retrocessione a `incerto`
8. **Prima sessione post-onboarding** — dopo un onboarding completo, avvia la prima sessione di studio, verifica che il tutor saluti col nome, parafrasi qualcosa del profilo, menzioni il tempo e presenti il nodo (B33.5 deve attivarsi bene)

### Cosa consegna Villa come esito del test
- Tutti i scenari ✅ → B39 chiuso, procediamo con merge develop → main
- Almeno uno scenario ⚠️ → Villa apre finding in `.claude/test-findings.md`, si pianifica un blocco `B39.fix.*`

---

## 9. Criteri di successo e di fallimento

### Successo
- Tutti i sub-blocchi B39.1.1 → B39.11.1 completati con test automatici verdi
- Test manuale di Villa supera tutti gli 8 scenari sopra
- Il profilo di un utente dopo onboarding completo contiene i 5 campi con contenuto non banale
- Il primo turno di una sessione studio post-onboarding attiva il ramo "caldo" di B33.5 con parafrasi riconoscibile
- La dettatura vocale funziona in onboarding, sessione chat, ricerca
- Il banner in Home compare/scompare coerentemente con lo stato di onboarding
- Tutti i 377+ test backend e 588+ frontend continuano a passare

### Fallimento
- Uno o piu sub-blocchi si bloccano con errori non recuperabili dal runner
- L'estrattore Opus produce profili vuoti o mal formati in piu del 20% dei casi di test
- La trascrizione Whisper fallisce o e inaccurata al punto di rendere la voce inutilizzabile
- Il primo turno caldo di B33.5 NON parafrasa nonostante il profilo sia popolato (significa regressione a B33.5)
- Il tono del tutor onboarding e freddo/burocratico nonostante le istruzioni di calore
- Il banner in Home non compare quando dovrebbe o resta quando non dovrebbe
- Latenza eccessiva (>3 secondi) su operazioni utente critiche (invio turno, trascrizione voce, risultato esercizio)

---

## 10. Vincoli architetturali rispettati

- **Tre layer separati**: onboarding vive nel layer del tutor (prompt + core), non tocca il knowledge graph (tabella nodi intatta) e non modifica l'orchestratore in modo sostanziale
- **Singola chiamata LLM per turno**: il tutor continua a fare una chiamata per turno. L'estrattore e una chiamata AGGIUNTIVA ma disgiunta, fatta dopo il turno, non durante
- **Prompt in file separati**: `backend/app/llm/prompts/` ospita tutti i nuovi prompt
- **SSE streaming invariato**: il bug ONB-02 viene fixato ma l'architettura streaming resta
- **Schema DB minimo**: solo 2 nuovi campi su `utenti`, nessuna nuova tabella
- **Modello LLM configurabile**: Opus e la scelta, ma parametrizzabile in config per il futuro
- **Approccio parzialmente deterministico**: il decisore forma C e pure Python (deterministico), l'LLM entra solo dove serve intelligenza (conversazione, estrazione, generazione esercizi)
- **Widget Flutter riutilizzabile**: `VoiceInputField` e un componente condiviso, non codice duplicato in ogni schermata
- **Secrets gestiti**: `OPENAI_API_KEY` vive in `.env` (gitignored) + `.env.example` (tracked) + `validate_secrets_for_startup`
- **Degradazione graceful**: ogni fallimento (estrattore, STT, generatore esercizi) ha un fallback che non blocca l'utente

---

## 11. Riferimenti incrociati

- **Note di discovery complete** (domande + risposte turno per turno): `docs/discussions/b39-discovery-notes.md`
- **Stato della discovery**: `docs/discussions/b39-discovery-state.md`
- **Finding dal test manuale 2026-04-08 che hanno motivato B39**: `.claude/test-findings.md` (sezioni ONB-01, ONB-02, PRE-01, DEV-01)
- **Design doc B33.5 (primo turno caldo)**: `docs/discussions/ux-01-primo-turno-caldo.md` (il lavoro upstream che B39 va a completare)
- **Idee parcheggiate**: `.claude/ideas.md` (sezione 2026-04-08 onboarding narrativo, sezione 2026-04-08 modello temporale neuroscienze, sezione voice input)
- **Decisioni architetturali**: `.claude/decisions.md` (decisioni B33.5 del 2026-04-08 + queste nuove di B39 verranno aggiunte)
- **Codice esistente che B39 modifica**:
  - `backend/app/core/onboarding.py` — refactor progressivo
  - `backend/app/api/onboarding.py` — endpoint `/turno` e `/completa`
  - `backend/app/core/contesto.py` — gia modificato in B33.5, resta compatibile
  - `backend/app/llm/prompts/system_prompt.py` — tutor di sessione, NON modificato
  - `backend/app/llm/prompts/direttive.py` — B33.5, NON modificato
  - `frontend/lib/presentation/onboarding_screen/onboarding_screen.dart` — riscrittura
  - `frontend/lib/providers/onboarding_provider.dart` — aggiornamento
- **Documentazione API esterna**: OpenAI Whisper API reference
- **Metodo Villa — runner script**: `metodo-villa-runner.sh` (con auto-push gia configurato)
- **Checklist test manuale** (da creare in B39.11.1): `docs/discussions/b39-checklist-test-manuale.md`

---

*Documento redatto a fine sessione di discovery con il fondatore — 2026-04-08. Le decisioni qui contenute sono la base per la scrittura degli handoff dei 38 sub-blocchi B39.1.1 → B39.11.1 che saranno eseguiti dal runner del Metodo Villa in sequenza autonoma.*
