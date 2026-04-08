# Discovery Notes — B39 Onboarding Narrativo (Dydat)

## Riassunto iniziale (Fase 1)

### Problema
L'onboarding attuale di Dydat è un questionario a domande strutturate gestito da tutor LLM. È rotto a 5 livelli:
1. **ONB-01 CRITICO** — Nessuno scrive `profilo_sintetizzato`, `contesto_personale`, `preferenze_tutor` nel DB. La conversazione onboarding è persa dopo la sessione.
2. **ONB-02** — 6/8 turni del tutor onboarding hanno `contenuto=None` in DB (bug persistenza SSE).
3. **PRE-01** — Il test di posizionamento viene proposto ma non erogato mai.
4. **DEV-01** — Il bottone "Login dev" salta completamente l'onboarding.
5. **Tono burocratico** — 5 risposte telegrafiche ("matematica", "4", "mix") non producono materiale abbastanza ricco perché B33.5 "primo turno caldo" possa parafrasare nel saluto. B33.5 è tecnicamente implementato ma il suo effetto non si vede mai.

### Obiettivo del redesign
Un flusso di onboarding in cui l'utente si racconta liberamente (guidato ma non costretto), l'AI estrae un profilo strutturato dalla narrazione, e alla fine produce dati abbastanza ricchi perché il primo turno del tutor (B33.5) possa parafraseare in modo naturale.

### Utenti target
- Adulti (stima media 40-50 anni) che riprendono gli studi dopo anni di pausa
- Studenti autodidatti con obiettivi personali (curiosità, lavoro, autorealizzazione)
- Genericamente non esperti di tecnologia, non pronti a scrivere paragrafi su uno smartphone
- Materia attuale: matematica (unico curriculum caricato)

### Vincoli e conferme già date da Villa
- Dettatura vocale IN scope (pulsante mic → record → STT API → trascrizione)
- Chat vocale completa FUORI scope
- Schema profilo B33.5 (`chi_e`, `motivo`, `stile_cognitivo`) va preservato compatibile — eventuali campi aggiuntivi sono ok ma questi 3 restano.
- Il test di posizionamento, se incluso, va erogato davvero (non solo proposto)

## Gap da colmare con l'intervista

Organizzo i gap per area, una sub-fase di intervista per area.

### Area A — Struttura del flusso narrativo
- A1. Quanti turni totali (min/max) deve durare l'onboarding?
- A2. Forma: un unico turno aperto iniziale + domande mirate sui buchi, o flusso pluri-turno più guidato fin dall'inizio?
- A3. Come inizia il tutor (apertura concreta)?
- A4. Quando termina l'onboarding (criterio di "done")?
- A5. Gestione risposte troppo brevi / troppo lunghe / off-topic / lingua sbagliata.

### Area B — Dettatura vocale
- B1. Quale API STT usare (OpenAI Whisper, Google Cloud Speech, Azure, altro)?
- B2. Come si attiva nell'UI (sempre visibile, solo sui turni narrativi, toggle)?
- B3. Feedback visivo durante registrazione (waveform, timer, chip "sto ascoltando")?
- B4. Dopo la trascrizione: anteprima modificabile, invio diretto, scelta utente?
- B5. Fallback se la voce non funziona (no permessi mic, API down, rete assente)?

### Area C — Test di posizionamento
- C1. Copertura (solo matematica? solo operazioni base? scala di livelli?)
- C2. Numero e forma degli item (es. 5 esercizi a risposta multipla, 10 vero/falso, auto-valutazione)?
- C3. Adattivo (l'item successivo dipende dal precedente) o fisso?
- C4. Proposto / raccomandato / obbligatorio?
- C5. Se rifiutato, cosa succede al profilo (punto di partenza default)?
- C6. Dove si salvano i risultati e come li usa il path planner?

### Area D — Estrazione e salvataggio del profilo
- D1. Strategia di estrazione: post-hoc (una call LLM a fine onboarding), tool use in-stream, ibrida?
- D2. Quale modello LLM per l'estrazione (Haiku vs Sonnet)?
- D3. Campi output del profilo (teniamo solo 3 attuali o ampliamo)?
- D4. Gestione fallimenti di estrazione (JSON invalido, timeout, rate limit)?
- D5. Validazione output con Pydantic?

### Area E — Integrazione con il flusso esistente
- E1. L'onboarding resta PRIMA della registrazione (utente temp → convert) o dopo?
- E2. Guest mode possibile (l'utente usa Dydat senza registrarsi)?
- E3. Recoverability: l'utente può tornare indietro / rifare l'onboarding?
- E4. Cosa fa B39 con il codice onboarding esistente (cancella e riscrive, o refactor progressivo)?

### Area F — Test strategy
- F1. Unit test delle funzioni di estrazione (deterministiche su input fissi)?
- F2. Integration test con LLM reale marcati come `@integration` skip default?
- F3. Test manuale checklist (che dati attendiamo nel DB dopo onboarding completato)?

### Area G — Scope e spezzettatura del blocco
- G1. B39 in un blocco unico o spezzato in sub-blocchi (backend/frontend/STT)?
- G2. Dipendenze con altri blocchi (B40 audio? B33.5? altri)?

## Risposte intervista

### A1 — Forma del flusso narrativo
**Scelta**: Forma C — ibrido adattivo (1 turno libero iniziale + domande mirate intelligenti generate dinamicamente sulla base dei buchi nel profilo).
**Note di Villa**: "come punto di partenza. Eventualmente poi andremo a costruire su questo approccio."
**Implicazioni**:
- L'architettura del backend onboarding deve supportare uno stato "quali campi del profilo sono già coperti".
- Serve un "decisore" che, dopo ogni turno utente, valuta se l'estrazione copre abbastanza campi per terminare o se serve un'altra domanda.
- Il numero di turni NON è fisso — va stabilito un tetto massimo (es. 7) per evitare loop infiniti.
- I test di integrazione dovranno coprire più scenari: utente molto collaborativo (2-3 turni), utente medio (4-5 turni), utente taciturno (max 7 turni).

### A3 — Tono e persona del tutor in onboarding
**Scelta**: Filosofia A — **tutor personificato in prima persona**. Il tutor si presenta come "io sono il tuo tutor Dydat", costruisce relazione emotiva, invita l'utente a raccontarsi in modo caldo e amichevole. La menzione della voce ("se ti va puoi anche dettarmi la risposta a voce") è inclusa nell'apertura, non scoperta dopo.
**Note di Villa**: "Non mi interessa che l'adulto possa avere il problema di parlare con una macchina. Il mondo va in questa direzione e devono adattarsi tutti. Non voglio rimanere ancorato a un approccio passato. Voglio uno stile più caldo e migliore."
**Implicazioni**:
- Il system_prompt del tutor di onboarding deve essere allineato con questa voce personificata, e **deve essere coerente** con il system_prompt del tutor di sessione (quello usato in B33.5) — non può esserci rottura di tono tra i due momenti.
- Vista la direzione "tutto avanti verso il nuovo", possiamo permetterci di essere più audaci nel linguaggio (meno "gentile ad ogni costo", più "amico informato che ti tratta da adulto").
- Il primo messaggio deve menzionare la voce esplicitamente: l'utente deve sapere del microfono PRIMA di aver iniziato a digitare, altrimenti la feature arriva tardi.

### A4 — Criterio di fine, edge case e skip
**Criterio di fine `completato`**: tutti e 5 i campi del profilo presenti e con contenuto ricco (non bassa confidenza da parte dell'estrattore).
**Tetto massimo**: 7 turni. Oltre i 7 turni il tutor chiude educatamente anche se i dati sono incompleti; l'utente torna in Home con `onboarding_stato = in_corso`.

**Qualità, non solo presenza**: l'estrattore LLM produce per ogni campo un valore + una confidenza (`alta` / `media` / `bassa`). I campi a bassa confidenza sono trattati come mancanti dal decisore. Questo garantisce che risposte povere come "matematica" nel campo `motivo` non vengano scambiate per risposte sufficienti.

**Gestione dei 4 edge case**:
- **Caso 1 — utente taciturno**: il tutor fa domande mirate sui campi mancanti. Dopo 5 turni senza progresso, prova un'ultima strategia a chip/pulsanti selezionabili. Se anche quelli falliscono, chiusura forzata al turno 7 con profilo incompleto e banner in Home che invita al completamento.
- **Caso 2 — utente dilungato**: se al primo turno libero tutti i 5 campi sono estratti con confidenza alta, il tutor riconosce ("mi hai dato abbastanza") e chiude in 2 turni totali.
- **Caso 3 — off-topic**: il tutor risponde brevemente con gentilezza e riporta al punto. Dopo 3 off-topic consecutivi, chiusura forzata con profilo parziale.
- **Caso 4 — lingua diversa**: l'AI rileva la lingua dell'input. Se diversa da italiano e confidenza di rilevamento alta, il tutor propone esplicitamente di cambiare la lingua di sistema ("vedo che scrivi in inglese — vuoi che imposti Dydat in inglese per il futuro?"). Se l'utente accetta, salviamo la preferenza in un nuovo campo `lingua_preferita` sull'utente (placeholder per la futura localizzazione). Il tutor continua comunque in italiano perché l'app è ancora solo in italiano, ma il dato è tracciato per il futuro.

**Skip rinviabile — design chiave del prodotto**:
- L'onboarding NON è un muro obbligatorio. Fin dalla prima schermata dell'onboarding è disponibile un bottone **"Salta per ora"** (discreto ma visibile).
- Chi salta va dritto in Home con `onboarding_stato = in_corso` (se aveva già fatto qualche turno) o `non_iniziato`.
- In Home compare una **card persistente non dismissibile** finché `onboarding_stato != completato`. Contenuto tipo: *"🌟 Completa il tuo racconto — Dydat potrà personalizzare meglio l'esperienza (2 minuti)"*. Pulsante "Riprendi" se `in_corso`, "Inizia" se `non_iniziato`.
- Se l'utente ha già fatto qualche turno e ha saltato, "Riprendi" riapre l'onboarding con la **conversazione precedente intatta** — niente ricominciamento da zero. Questo richiede persistenza dello stato conversazione sulla sessione onboarding.
- Se l'utente avvia una sessione di studio senza aver completato l'onboarding, B33.5 si attiva con il **ramo fallback senza profilo** (già implementato stanotte): saluto caloroso ma generico, senza parafrasi. Il sistema degrada con grazia.

**Hook di gamification**:
- Completare l'onboarding è il **primo achievement** di Dydat ("Il tuo primo racconto" o nome equivalente).
- Implementazione vera rimandata al momento in cui tocchiamo il sistema achievement, ma registriamo qui l'intenzione.

**Campi DB aggiuntivi da creare**:
- `utenti.onboarding_stato` (enum: `non_iniziato` / `in_corso` / `completato`, default `non_iniziato`)
- `utenti.lingua_preferita` (string opzionale, default `it`, placeholder per localizzazione futura)
- Persistenza stato conversazione sulla `sessione` di tipo `onboarding` per supportare il "riprendi" — probabilmente già fattibile con `stato_orchestratore` esistente, da verificare in implementazione.

### B1 — UX della dettatura vocale (flusso utente)
**Design approvato**: pulsante microfono sempre visibile accanto al pulsante invia nel campo di input dell'onboarding. I due pulsanti convivono, non è un toggle — l'utente sceglie turno per turno.
**Flusso registrazione**:
1. Tocco al microfono → campo input entra in "stato registrazione": sfondo leggermente diverso, pulsante mic rosso pulsante, wave animata sul volume della voce, timer secondi.
2. Utente parla liberamente. **Nessun limite di tempo imposto da noi**; valgono solo i limiti tecnici dell'API STT (tipicamente minuti, non secondi) e del dispositivo.
3. Utente preme stop (stesso pulsante ora rosso, oppure "Stop" accanto) per terminare.
4. Spinner di trascrizione, poi il testo trascritto popola il campo di input.
5. **Trascrizione modificabile prima di inviare**: l'utente legge, corregge refusi fonetici se serve, eventualmente aggiunge a tastiera, poi preme invia normalmente. Nessun auto-invio.
**Fallimenti** (permesso mic negato, rete assente, API STT giù): pulsante microfono mostra icona errore, al tap un messaggio breve *"La voce non è disponibile in questo momento — puoi continuare a scrivere"*. Degradazione silenziosa, nessun blocco, l'utente prosegue a tastiera.
**Principi di design chiave**:
- Voce visibile, non nascosta (stesse dimensioni del pulsante invia)
- Controllo utente dopo trascrizione (può correggere prima di inviare)
- Cambio di stato molto visibile (registrazione → stop → trascrizione → modifica → invio)
**Note di Villa**: approvato integralmente tranne la rimozione del riferimento a "60 secondi" — nessun limite di tempo da parte nostra.

### B2 — Scope di applicazione della voce (dove appare il microfono)
**Scelta**: la voce è una **feature trasversale** dell'applicazione, deve apparire ovunque ci sia un campo di testo significativo.
**Implementazione in B39**:
- Nuovo widget Flutter riutilizzabile `VoiceInputField` (nuovo file in `frontend/lib/widgets/`) che incapsula: `TextFormField` standard + pulsante microfono + UX di registrazione/trascrizione descritta in B1 + gestione errori + chiamata al backend.
- Nuovo endpoint backend `POST /stt/transcribe` che riceve audio (multipart o base64), chiama l'API STT esterna, restituisce il testo trascritto. La chiave API STT vive SOLO lato backend (come ANTHROPIC_API_KEY) per sicurezza — l'app non ha mai accesso diretto.
- Integrazione del widget nelle 3 schermate chiave al primo giro:
  1. Onboarding (campo chat del tutor)
  2. Sessione di studio (campo chat del tutor durante studio)
  3. Ricerca in "I miei studi" (campo di ricerca per nodi/parole chiave)
- Schermate NON incluse (per inadeguatezza o sicurezza): login, registrazione (email/password non vanno dettate a voce), campi molto corti (es. nome utente).
**Rationale scope**: costruire un widget riutilizzabile rende l'estensione a più schermate un costo marginale (+30% di scope B39), non raddoppiato. Lo sforzo vero è nel widget stesso e nell'endpoint backend.

### B3 — Dettatura di formule matematiche (RIMANDATA)
**Decisione**: NON inclusa in B39. Rimandata a un blocco futuro dedicato.
**Motivazione**: la trascrizione di "x al quadrato più 3x meno 2" verso la formula LaTeX `x^2 + 3x - 2 = 0` non è un problema di STT puro, ma richiede un secondo passaggio di parsing semantico del parlato matematico. Le opzioni tecniche (modello specializzato, parser a regole, LLM post-processing) sono tutte ricerca non banale e non affrontabili come sotto-problema di B39.
**Piano**: in B39 la voce produce testo grezzo in qualsiasi campo di input. Per i futuri campi di risposta a esercizi matematici, un blocco dedicato (candidato nome: **"B-voice-matematica"**, da collocare dopo l'implementazione degli esercizi veri in Fase 12+) aggiungerà il passaggio di traduzione parlato-matematico→LaTeX sopra l'infrastruttura voce esistente.
**Note di Villa**: "l'utente deve poter dettare anche la matematica o la chimica o la fisica a voce e il sistema deve poterla capire e tradurre in formule latex". Accettata l'idea come obiettivo di prodotto, rimandata come implementazione.

### B4 — Scelta del provider STT
**Scelta**: **OpenAI Whisper** (via API OpenAI).
**Motivazioni**:
- Qualità italiano eccellente (praticamente indistinguibile da Google/Azure per parlato naturale)
- Costo ~$0.006/minuto — 3-4x inferiore rispetto ad Azure/Google
- Integrazione semplice (POST con audio, ritorno testo, una riga di codice)
- Per il nostro design (registra → stop → trascrizione) non serve streaming real-time, quindi gli altri provider non offrono vantaggi utili
- Stima costo reale: ~12 centesimi/anno per utente attivo (~20 min dettatura/mese); ~$1200/anno per 10.000 utenti attivi — trascurabile rispetto ad altri costi
**Implicazioni tecniche**:
- Nuovo secret `OPENAI_API_KEY` da aggiungere al backend (`.env` + `.env.example` + `config.py` validate_secrets_for_startup)
- Nuovo account OpenAI con billing configurato separatamente da Anthropic (due bollette diverse)
- Backend deve esporre `POST /stt/transcribe` che proxy-a verso Whisper con autenticazione server-side (la chiave OpenAI non finisce mai nell'app)
- Registrare la dipendenza da OpenAI API in `dev-shortcuts.md` come nuova dipendenza esterna
**Note di Villa**: "Assolutamente sì, utilizziamo Whisper".

### C1 — Strategia placement test in B39
**Scelta**: **approccio ibrido auto-valutazione + verifica selettiva** (formato compound, con cap).

**Fase auto-valutazione**: durante la parte narrativa dell'onboarding, il tutor chiede all'utente, per le aree chiave della materia, se si sente `forte` / `incerto` / `digiuno`. Queste risposte popolano una mappa iniziale delle conoscenze auto-dichiarate.

**Fase verifica selettiva** (solo aree "forte"):
- **Cap duro**: massimo 3 esercizi di verifica, ciascuno copre fino a 2 concetti → max 6 aree verificate.
- Se l'utente dichiara forte su più di 6 aree, verifichiamo le **6 più fondazionali** (partendo dai nodi del grafo più "in basso" nell'albero dei prerequisiti), le rimanenti sono accettate come "forte senza verifica" (trust sull'utente).
- Scala adattiva: 1-2 aree → 1-2 esercizi singoli; 3-4 → 2 esercizi compound; 5-6 → 3 esercizi compound; 7+ → 3 esercizi sulle 6 fondazionali.
- Tipo esercizio: **scelta multipla con 3-4 opzioni, 1 risposta corretta**. Niente formati complessi (niente riempi-il-blanco, niente step-by-step con grading granulare).
- Le aree "incerto" e "digiuno" NON vengono verificate — trust sull'onestà dell'utente.

**Provenienza degli esercizi**: (a) usiamo quelli già esistenti nel DB curriculum se presenti, (b) per le aree senza esercizi in DB generiamo compound exercises al volo via LLM.

**Regola fallimento verifica**: se l'utente sbaglia un compound exercise, **entrambi** i concetti coperti da quell'esercizio retrocedono a `incerto`. Pragmatico: non possiamo sapere quale dei 2 ha sbagliato, quindi li trattiamo entrambi come da verificare in seguito.

**Tono in caso di fallimento**: **trasparente-caldo**, tipo *"sai, su questo ho trovato un po' di incertezza — non è niente, capita, lo rivedremo insieme così fai un ripasso veloce"*. Mai svilente, mai umoristico, mai nascosto.

**Turni count**: le verifiche stanno **fuori dal conteggio dei 7 turni narrativi**. Hanno il proprio cap (max 3 esercizi) e non consumano il budget narrativo.

**Skip del placement**: l'utente può saltare anche la fase di verifica (non solo la narrativa). Skip comporta:
- Se l'utente salta prima dell'auto-valutazione → path planner parte da nodo default (es. "operazioni base" per matematica).
- Se l'utente fa l'auto-valutazione ma salta la verifica → path planner usa i dati auto-dichiarati (senza conferma oggettiva), parte dal nodo suggerito da quelli.
- Banner in Home evoluto: può essere unificato ("Completa onboarding + verifica") o in due card separate — dettaglio UI da decidere in implementazione.

**Patto esplicito all'inizio**: il primo messaggio del tutor dichiara esplicitamente cosa sta chiedendo e perché. Esempio di tono (non parole esatte):
> *"Ciao, piacere di conoscerti, io sono il tuo tutor Dydat. Prima di metterci a studiare voglio essere onesto con te: il modo in cui ti conoscerò adesso determina quanto potrò davvero aiutarti. Raccontami di te, fammi capire chi sei e cosa ti ha portato qui. Ti faccio anche qualche domanda veloce per capire da dove partire. Sono pochi minuti, ma fanno una vera differenza. Se preferisci saltare e vedere prima l'app, puoi farlo — troverai il mio invito a tornare qui quando vorrai. Iniziamo?"*

Il primo messaggio deve contenere anche la menzione del microfono (come decisione A3).

### C2 — Evoluzione futura (RIMANDATA a B43 Feynman)
**Idea di Villa**: arricchire il placement test con domande narrative tipo *"spiega il tuo ragionamento su questo esercizio"*, valutando la comprensione dalla spiegazione libera dell'utente.

**Decisione**: **rimandata a B43 "Feynman Signal Processing"** o blocco successivo della stessa famiglia. Motivazione:
- È esattamente la tecnica Feynman che B43 è pianificato per costruire (con LLM grader, distinzione "sa ripetere" vs "ha interiorizzato", gestione edge case della valutazione narrativa)
- Implementarla in B39 duplicherebbe il lavoro con B43
- B39 ha già scope grosso (narrativa + voce + skip + estrazione + placement); aggiungere mini-Feynman lo esploderebbe in un blocco ingovernabile
- Quando arriverà B43 avremo l'infrastruttura di valutazione matura e potremo retroattivamente aggiornare il placement test usandola

**Nota per B43**: quando si aprirà la discovery di B43, leggere questa sezione delle note B39 e integrare l'estensione del placement test come uno degli use case dell'infrastruttura Feynman. Il placement test diventa quindi un "cliente" dell'infrastruttura Feynman, non un sistema parallelo.

**Decisione di Villa**: "accetto di rimandare... registrando l'idea appena emersa, in modo da ritornarci quando arriveremo a quel punto".

### D1 — Strategia di estrazione del profilo
**Scelta**: **Strada 1 — estrazione post-hoc con singola chiamata LLM a fine di ogni turno utente**.
- Durante la conversazione il tutor chatta liberamente con l'utente.
- Dopo ogni turno utente, una chiamata LLM legge la conversazione completa finora e restituisce il JSON strutturato con i 5 campi + confidenze (`alta` / `media` / `bassa`).
- Il risultato alimenta il decisore della Forma C, che decide se chiedere ancora o chiudere.
**Retry e fallimenti**: se la chiamata di estrazione fallisce (timeout, rate limit, JSON malformato) facciamo **un retry**. Se fallisce ancora, il decisore usa lo stato del profilo dell'estrazione precedente (se presente) o accetta profilo vuoto. Niente crash, niente blocco, l'utente non si accorge.
**Perché Strada 1 invece di Strada 2 (tool use in-stream)**: più semplice da scrivere e testare, un solo punto di fallimento, unit test deterministici su input fissi, latenza trascurabile per il nostro caso (~1s per call).

### D2 — Scelta dei modelli LLM per ogni fase
**Decisione di Villa (direttiva, non negoziabile)**: **Opus 4.6** per tutta la fase di onboarding e tutta la fase di test (placement).

**Ripartizione concreta**:
1. **Tutor che conduce la conversazione narrativa in onboarding** → **Opus 4.6**
2. **Estrattore profilo (singola call post-turno)** → **Opus 4.6**
3. **Decisore forma C (giudice "chiudi o continua")** → **zero LLM, pure regole Python** (deterministico, testabile, gratis)
4. **Generatore esercizi compound per il placement test** → **Opus 4.6**
5. **Correttore esercizi a scelta multipla** → **zero LLM, confronto stringa deterministico**

**Rationale della direttiva di Villa**: l'onboarding e il placement test sono fasi critiche per costruire l'esperienza personalizzata dell'utente; sottovalutare l'intelligenza richiesta per conversare con calore e per estrarre bene il profilo significa compromettere la qualità dell'intero flusso successivo. Opus è la scelta giusta per garantire il massimo risultato anche a costo maggiore.

**Implicazioni di costo**: stimando ~10-15 chiamate Opus totali per utente onboardato (conversazione tutor + estrazioni + generazione esercizi), il costo per utente si aggira intorno a **$0.30-$0.50 per onboarding completo**. Con 1000 nuovi utenti/mese siamo a **$300-500/mese di spesa Opus per onboarding** — significativo ma accettabile per una fase così cruciale e infrequente (ogni utente la fa una volta sola).

**Implicazione architetturale**: i prompt devono essere ben progettati per massimizzare il valore di Opus — vale a dire, istruzioni chiare, esempi few-shot solo se servono davvero, output JSON rigidamente validato con Pydantic lato backend.

### E1 — Approccio ingegneristico al codice onboarding esistente
**Scelta**: **refactor progressivo** (non rewrite da zero).
- Manteniamo lo scheletro esistente: endpoint `/onboarding/inizia`, `/onboarding/turno`, `/onboarding/completa`, schermata Flutter `onboarding_screen.dart`, provider `onboarding_provider.dart`.
- Interveniamo chirurgicamente per cambiare i comportamenti: fix del salvataggio profilo (ONB-01), fix persistenza streaming (ONB-02), aggiunta estrattore Opus, aggiunta fase placement test, aggiunta skip + banner home, aggiunta voce.
- Lo scheletro attuale è decente (SSE, sessioni, Riverpod pulito). I problemi erano nel "che cosa fa", non nel "come è strutturato".
**Rationale**: meno lavoro, meno rischio di reintrodurre bug, riuso infrastruttura esistente, migrazione più sicura.

### E2 — Ordine onboarding/registrazione
**Scelta**: **manteniamo l'ordine attuale**: `login screen → onboarding (utente temp) → registrazione (converte temp in reale) → home`.
- L'utente può iniziare a chattare col tutor senza aver ancora creato un account (utente temporaneo).
- Al termine dell'onboarding (o al momento dello skip) viene invitato a registrarsi con email/password. Il backend esistente già supporta la conversione utente_temp → utente reale tramite `utente_temp_id`.
- Messaggio di registrazione onesto: *"Per tenere traccia del tuo percorso Dydat ha bisogno di sapere chi sei — bastano email e password, due secondi"*. No coercizione.
**Nessun guest mode**: sconsigliato in B39, rimandato a futuro se mai servirà. Complessità di stato sproporzionata rispetto al beneficio.
**Rationale**: il tutor chattante come prima esperienza è memorabile, la registrazione anticipata la rovinerebbe. Inoltre cambiare il flusso richiederebbe riscrivere parte dell'autenticazione, lavoro evitabile.

### F1 — Strategia di test
**Scelta**:
- **Controlli automatici dopo ogni sub-blocco**: Claude esegue unit test + integration test (con LLM mockato dove possibile) + lint check prima di segnare un sub-blocco come completato. Se un test fallisce, il sub-blocco non avanza.
- **Integration test con LLM reale**: skippati di default (`@pytest.mark.integration`), eseguibili manualmente per smoke test occasionali. Non rallentano il runner notturno e non bruciano token Opus gratuitamente.
- **Test manuale del fondatore**: **una volta sola alla fine** di tutta la catena dei sub-blocchi, con checklist precisa che Claude prepara. Villa non viene disturbato ogni 20 minuti.
**Note di Villa**: "sono d'accordo con Claude che fa i suoi controlli automatici e poi io alla fine faccio i controlli manuali".

### G1 — Divisione in sub-blocchi e scope operativo
**Scelta**: blocchi **piccoli, tanti, focalizzati**. Principio del Metodo Villa — meno context window si satura in ogni sessione Claude Code, più il modello performa meglio.
**Numero**: **38 sub-blocchi totali** organizzati in **11 fasi tematiche**.
**Tempo**: **non è un vincolo**. Villa lancia il runner e aspetta; si spezza su tutte le notti necessarie.

**Piano dei 38 sub-blocchi**:

#### Fase 1 — Preparazione DB (3 blocchi)
1. **B39.1.1** — Migrazione Alembic: aggiungi campi `onboarding_stato` (enum: not_started / in_progress / completed) + `lingua_preferita` alla tabella `utenti`
2. **B39.1.2** — Aggiorna modello SQLAlchemy `Utente` per esporre i nuovi campi + unit test modello
3. **B39.1.3** — Aggiorna schemi Pydantic API per serializzare i nuovi campi in `/utente/me` e simili

#### Fase 2 — Cervello estrattore profilo (4 blocchi)
4. **B39.2.1** — Crea `backend/app/llm/prompts/onboarding_extractor.py` con il prompt di estrazione in italiano (istruzioni chiare, specifica JSON output, esempi few-shot minimal)
5. **B39.2.2** — Crea schema Pydantic `ProfiloEstratto` con 5 campi + confidenze (alta/media/bassa)
6. **B39.2.3** — Funzione `estrai_profilo(conversazione)` che chiama Opus con il prompt, parsa JSON, valida, gestisce retry su errore
7. **B39.2.4** — Unit test per l'estrattore (mocked LLM con risposte JSON prefabbricate)

#### Fase 3 — Decisore forma C (2 blocchi)
8. **B39.3.1** — Funzione `decidi_prossima_mossa(profilo, turni_fatti)` rules-based Python pura + unit test (nessun LLM)
9. **B39.3.2** — Integrazione decisore nell'endpoint `/onboarding/turno` esistente

#### Fase 4 — Fix bug onboarding esistenti (3 blocchi)
10. **B39.4.1** — Fix `completa_onboarding` per chiamare estrattore e scrivere `profilo_sintetizzato` + `contesto_personale` + `preferenze_tutor` (ONB-01)
11. **B39.4.2** — Fix persistenza streaming turni SSE: il `contenuto` del turno assistente deve essere salvato alla fine dello streaming anche con tool use (ONB-02)
12. **B39.4.3** — Rimozione codice onboarding legacy non più utilizzato (pulizia)

#### Fase 5 — Motore voce Whisper (3 blocchi)
13. **B39.5.1** — Aggiungi `OPENAI_API_KEY` a config + .env.example + docker-compose + `validate_secrets_for_startup` in config.py
14. **B39.5.2** — Crea endpoint `POST /stt/transcribe` che accetta audio multipart, chiama Whisper via client OpenAI, ritorna testo
15. **B39.5.3** — Test endpoint STT (mocked) + un test di integrazione `@pytest.mark.integration` con audio reale di smoke

#### Fase 6 — Placement test backend (6 blocchi)
16. **B39.6.1** — Prompt di auto-valutazione (tutor chiede "forte/incerto/digiuno" per le aree chiave della materia) in `backend/app/llm/prompts/onboarding_self_assessment.py`
17. **B39.6.2** — Logica di identificazione aree da verificare (partendo dal grafo curriculum, sceglie le N più fondazionali tra quelle auto-dichiarate "forte")
18. **B39.6.3** — Prompt generatore esercizi compound (max 2 concetti per esercizio, scelta multipla 3-4 opzioni) in `backend/app/llm/prompts/onboarding_exercise_generator.py`
19. **B39.6.4** — Funzione `genera_esercizi_verifica(aree_da_verificare)` + schema Pydantic per gli esercizi
20. **B39.6.5** — Logica di grading deterministico (risposta utente vs corretta, retrocessione concetti in caso di fail)
21. **B39.6.6** — Aggiornamento `stato_orchestratore` con mappa finale `{concetto: forte_confermato/forte_unverified/incerto/digiuno}` + integrazione path planner

#### Fase 7 — Widget VoiceInputField (6 blocchi)
22. **B39.7.1** — Crea scheletro `frontend/lib/widgets/voice_input_field.dart` (TextFormField + pulsante mic disabilitato come placeholder)
23. **B39.7.2** — Aggiungi registrazione audio (libreria `record` o equivalente, gestione permesso mic per Android/iOS)
24. **B39.7.3** — Stato registrazione con feedback visivo: wave animata sul volume, timer secondi, pulsante stop rosso pulsante
25. **B39.7.4** — Chiamata a `/stt/transcribe` con audio registrato + spinner durante la trascrizione
26. **B39.7.5** — Popolamento del campo testo con trascrizione modificabile (no auto-invio, utente conferma)
27. **B39.7.6** — Gestione errori (mic denied, rete assente, API down, audio troppo corto) + widget test

#### Fase 8 — Integrazione onboarding (4 blocchi)
28. **B39.8.1** — Aggiorna `onboarding_provider.dart` per passare dati reali a `completeOnboarding` (attualmente chiamato senza argomenti)
29. **B39.8.2** — Riscrittura `onboarding_screen.dart` per usare `VoiceInputField` + aggiunta skip button discreto
30. **B39.8.3** — Integrazione del "patto esplicito" nel primo messaggio del tutor (system prompt onboarding aggiornato)
31. **B39.8.4** — Widget test integrazione onboarding + test flusso completo mockato

#### Fase 9 — Banner Home (3 blocchi)
32. **B39.9.1** — Crea widget `OnboardingPendingBanner` (card persistente, non dismissibile, con messaggio caldo + CTA)
33. **B39.9.2** — Integrazione banner in `home_screen.dart` condizionale su `onboarding_stato != completato`
34. **B39.9.3** — Logica "Riprendi" che apre `/onboarding` con lo stato conversazione precedente preservato + widget test

#### Fase 10 — Voce trasversale (3 blocchi)
35. **B39.10.1** — Integrazione `VoiceInputField` nel campo chat di sessione studio
36. **B39.10.2** — Integrazione `VoiceInputField` nella ricerca di "I miei studi"
37. **B39.10.3** — Widget test integrazione trasversale

#### Fase 11 — Test manuale finale (1 blocco)
38. **B39.11.1** — Claude prepara una checklist di test manuale dettagliata (scenari: utente collaborativo, utente taciturno, utente off-topic, skip, voce, placement, banner) e la consegna a Villa in un file dedicato `docs/discussions/b39-checklist-test-manuale.md`. Villa esegue i test e riporta i finding in `.claude/test-findings.md`.

**Dopo B39.11.1**: se emergono bug dal test manuale, vengono risolti in blocchi successivi `B39.fix.1`, `B39.fix.2`, ecc. Non sono inclusi in questo piano iniziale.

### G2 — System prompt del tutor
**Scelta**:
- **System prompt del tutor di ONBOARDING**: **riscritto da zero** in B39.8.3. Motivo: l'attuale è tarato sul questionario strutturato, e deve supportare Forma C adattiva + patto esplicito + menzione della voce + tono personificato (filosofia A).
- **System prompt del tutor di SESSIONE** (il file `backend/app/llm/prompts/system_prompt.py` usato in B33.5): **invariato**. Motivo: è già compatibile con il nuovo profilo arricchito — B33.5 attiva il ramo "caldo" quando il profilo è presente, e quello funzionerà automaticamente una volta che il profilo sarà popolato correttamente dal nuovo onboarding. Non serve toccarlo.
- **Nota architetturale**: i due system prompt restano **allineati nel tono** (personificato, caldo, professionale). La differenza è nel contenuto istruzioni specifiche della fase (conoscere l'utente vs insegnargli).
**Note di Villa**: decisione presa a fine discovery, approvata con "sì, mi torna".

### A2 — Schema del profilo (quali campi raccogliamo)
**Scelta**: set minimo di **5 campi**:
1. `chi_e` — identità in una frase (obbligatorio per B33.5)
2. `motivo` — perché studia, in linguaggio naturale (obbligatorio per B33.5)
3. `stile_cognitivo` — come preferisce apprendere (obbligatorio per B33.5)
4. `tempo_disponibile` — quanto tipicamente può dedicare a Dydat (ritmo/frequenza)
5. `vissuto_scolastico` — relazione emotiva con la materia in passato
**Note di Villa**: "mi sembrano candidati naturali, vanno bene".
**Scartati dal set iniziale**: `obiettivo_personale` (troppo vago), `contesto_personale` (molti utenti non lo dichiarano spontaneamente), `livello_percepito` (meglio misurato dal placement test oggettivo).
**Nota architetturale**: questi 5 campi vanno tutti in `profilo_sintetizzato` come JSONB. I campi DB `contesto_personale` e `preferenze_tutor` restano per usi futuri ma in B39 non vengono popolati direttamente (eventuali derivati possono essere calcolati post-hoc).
**Implicazioni per il "decisore" di Forma C (aggiornate dopo domanda 4)**: l'onboarding è `completato` solo quando **tutti e 5 i campi sono presenti con contenuto ricco** (non bassa confidenza). Se dopo 7 turni alcuni campi sono ancora vuoti o a bassa confidenza, il tutor chiude educatamente e l'utente viene rilasciato in Home con `onboarding_stato = in_corso`; il banner persistente continuerà a invitarlo a tornare finché non sono tutti completi. Nessuna distinzione tra campi obbligatori e opzionali — tutti e 5 hanno lo stesso peso.
