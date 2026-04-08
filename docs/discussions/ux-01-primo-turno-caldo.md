# UX-01 — Primo turno caldo del tutor

> Documento di sintesi della discussione strategica con il fondatore.
> Affianca il brief iniziale `ux-01-brief.md` (stessa cartella) e ne rappresenta l'esito.
> Data discussione: 2026-04-08
> Fondatore: Villa
> Stato: decisioni prese, pronto per implementazione

---

## 1. Il problema, in breve

Durante il test manuale del 6 aprile 2026, Villa ha registrato un nuovo utente, ha completato l'onboarding rispondendo in modo dettagliato (sta riprendendo dopo una pausa, studia per curiosità personale, preferisce esempi concreti prima della teoria, si sente sicuro 4/5 sulle operazioni di base) e ha avviato la prima sessione di studio scegliendo il ritmo "Normale 30 minuti". Nodo di partenza: "Potenza di un numero relativo".

Il primo messaggio del tutor è partito così:

> Ciao! 😊 Immagina di avere una scatola di cioccolatini. Se ne prendi 2 alla volta per 3 giorni consecutivi, alla fine hai raccolto 2 × 2 × 2 = 8 cioccolatini. […]

Il problema non è il contenuto dell'esempio in sé. Il problema è **tutto quello che manca prima**: nessun saluto contestualizzato, nessun uso del nome, nessun riconoscimento del profilo appena costruito nell'onboarding, nessuna presentazione del nodo, nessuna consapevolezza del ritmo scelto. Il tutor ha in mano tutte queste informazioni (sono già nel contesto che riceve a ogni turno), ma non gli viene detto da nessuna parte di usarle nel primo messaggio. Risultato: l'utente percepisce un tutor freddo, che "non si ricorda di lui" pur avendogli appena fatto otto domande di onboarding.

La causa tecnica è circoscritta e chirurgica: una funzione Python chiamata `direttiva_spiegazione` (in `backend/app/llm/prompts/direttive.py`) istruisce esplicitamente il tutor a partire dal primo turno con un esempio concreto dalla vita reale, senza menzionare saluto, nome, profilo, ritmo o presentazione. Fixare quella funzione risolve il problema alla radice.

---

## 2. Le decisioni di design prese con il fondatore

Queste sono le sette decisioni che guideranno l'implementazione. Sono tutte state discusse e approvate in conversazione.

### Decisione 1 — Struttura del primo messaggio: monolitico a tre battute

Il primo messaggio del tutor sarà **un solo messaggio**, non tre messaggi separati. Dentro quel messaggio ci saranno tre brevi paragrafi distinti: un saluto contestualizzato che usa il nome e riconosce il profilo dell'utente; una presentazione del nodo con un micro-indice di cosa si vedrà; una singola domanda aperta di warm-up che invita l'utente a rispondere.

Perché: l'utente ha appena fatto otto turni di onboarding. Se gli imponiamo altri due o tre turni prima di entrare nel merito, lo frustriamo. Un singolo messaggio in streaming, diviso visivamente in tre blocchi, dà sostanza subito senza diventare un muro di testo.

### Decisione 2 — Bilanciamento tra automatismo e intelligenza del tutor

Il primo messaggio sarà **parzialmente deterministico**. Il sistema inietterà automaticamente due ancore certe nel prompt del tutor: il nome dell'utente e il titolo esatto del nodo in arrivo. Tutto il resto (il tono, quali preferenze del profilo citare, come formulare il warm-up) sarà generato dal tutor stesso, guidato però da istruzioni molto più esplicite rispetto a oggi.

Perché: il nome sbagliato o dimenticato è l'errore più visibile e meno perdonabile. Il titolo del nodo idem. Queste due cose non vanno lasciate al caso. Il resto è voce del tutor, e se la irrigidiamo in template fissi perde calore.

### Decisione 3 — Quali informazioni del profilo usare, e come

Il tutor userà tre campi specifici del profilo utente raccolto durante l'onboarding:

1. Chi è l'utente (per esempio: "adulto che sta riprendendo dopo una pausa")
2. Il motivo per cui studia (per esempio: "curiosità personale")
3. Lo stile cognitivo preferito (per esempio: "partire da esempi concreti, poi formalizzare")

Queste informazioni andranno usate con **citazione implicita**, cioè parafrasandole nel tono del saluto, non riportandole alla lettera. Il tutor non dirà "hai detto che studi per curiosità", dirà "visto che ti sei avvicinato per curiosità, te la voglio rendere una cosa leggera".

Perché: la citazione verbatim suona come un addetto al servizio clienti che rilegge il ticket. La parafrasi caldo e naturale mostra comprensione invece di archivio.

### Decisione 4 — Presentazione del nodo con micro-indice

Il tutor aprirà una riga di micro-indice discorsivo, del tipo: "Oggi vediamo cosa succede alle potenze quando ci mettiamo dentro i numeri negativi. Prima un paio di esempi, poi la regola, e ci giochiamo un po'." Non un elenco puntato formale, non un sommario accademico. Una frase discorsiva, due o tre tappe, linguaggio colloquiale.

Perché: la "sorpresa pedagogica" non funziona con l'adulto che studia per curiosità: disorienta. Una mappa breve riduce l'ansia e costruisce fiducia, senza uccidere il coinvolgimento.

### Decisione 5 — Riconoscimento del ritmo scelto (15 / 30 / 60 minuti)

Il tutor **citerà esplicitamente il tempo** nel primo messaggio, in modo leggero: "abbiamo una mezz'ora insieme, usiamola bene" o formulazione equivalente. Inoltre **modulerà il ritmo** dei turni successivi in modo coerente (più rapido se Veloce, più disteso se Approfondita).

In questo intervento **non** si implementa un vero "piano sessione" strutturato con budget di tempo passati all'orchestratore. Quella è una riprogettazione più grande, che merita di essere affrontata a parte (vedi sezione 5 di questo documento, "Idee parcheggiate per il futuro"). Qui ci si limita alla citazione del tempo e alla modulazione morbida via istruzioni del prompt.

Perché: citare il tempo è un gesto di rispetto verso l'utente, costa poco e si fa subito. Il piano strutturato costa molto di più, tocca l'orchestratore e non solo i prompt, e ha senso solo se prima si studia come funziona davvero l'apprendimento breve su smartphone (neuroscienze, micro-sessioni, ripetizione distanziata). Si fa dopo, con calma.

### Decisione 6 — Nodi che l'utente "sa già" (presunti padroneggiati)

Durante l'onboarding, il placement test può marcare alcuni nodi come "presunti padroneggiati" — lo studente probabilmente li sa già. Quando entra in una sessione su un nodo di questo tipo, **il primo messaggio del tutor dovrà essere diverso**: invece di partire con la spiegazione, il tutor saluterà, riconoscerà che quel nodo risulta già familiare ("dal test iniziale sembra che queste cose tu le sappia già, facciamo una verifica veloce così confermiamo e andiamo avanti"), e proporrà subito una domanda-sonda sul concetto. Se l'utente risponde bene, si va avanti. Se risponde male, il tutor scende in modalità spiegazione normale.

Perché: trattare un nodo presunto come uno nuovo è un insulto allo studente e uno spreco del suo tempo. Il profilo onboarding è stato fatto apposta per evitare proprio questo.

**Nota sullo scope di questo intervento**: in questa prima implementazione si aggiunge alla direttiva un parametro che segnala "nodo presunto sì/no" e si genera un ramo testuale diverso per il primo messaggio. La logica completa di "verifica veloce + promozione automatica se corretto + discesa a spiegazione se sbagliato" è più ampia e può essere consolidata in un secondo passaggio se necessario. L'importante è che dal giorno uno l'utente, sui nodi presunti, non si senta trattato come un principiante.

### Decisione 7 — Riuso tra diversi "primi momenti" del tutor

Esistono diverse situazioni in Dydat in cui il tutor inizia qualcosa: il primo turno di spiegazione di un nuovo nodo (il caso che stiamo sistemando), il primo turno quando si riprende una sessione interrotta dopo una pausa, il primo turno di una sessione di ripasso, il primo esercizio su un nodo già spiegato. Oggi queste situazioni sono trattate in modo incoerente: alcune hanno già un saluto (la ripresa), altre no (la prima spiegazione).

La soluzione è creare **un "preambolo caldo" riutilizzabile**: una funzione helper che genera la parte di saluto contestualizzato + riconoscimento profilo + citazione del ritmo, e che viene chiamata da tutte le direttive di "primo momento". Ogni direttiva poi aggiunge la sua parte specifica (spiegazione, ripresa, esercizio, eccetera) dopo il preambolo.

In questo intervento si costruisce il preambolo e lo si applica a due direttive: la spiegazione di un nuovo nodo (il nostro caso principale) e la ripresa di sessione interrotta (che già ha un saluto ma guadagnerebbe dal profilo utente). Gli altri casi (primo esercizio, sessione di ripasso) si agganciano quando i relativi blocchi arrivano nella roadmap.

Perché: evita duplicazione, garantisce coerenza di tono tra tutti i momenti di apertura, e ogni direttiva resta leggibile perché contiene solo la logica specifica del suo caso.

---

## 3. Come sarà, concretamente, il nuovo primo messaggio

Per dare un'idea visiva di cosa cambierà, ecco come potrebbe suonare il nuovo primo messaggio per l'utente del test del 6 aprile (adulto che riprende, curiosità personale, preferisce esempi concreti, ritmo Normale 30 minuti, nodo "Potenza di un numero relativo"):

> Ciao Verdan, bentornato agli studi. So che stai riprendendo dopo una pausa e che lo fai per curiosità — niente voti, niente corse. Andiamo con calma.
>
> Nella mezz'ora di oggi vediamo cosa succede alle potenze quando ci entrano dentro i numeri negativi. Ti propongo di partire da qualche esempio concreto come preferisci tu, poi tiriamo fuori la regola, e chiudiamo con un piccolo esercizio per vedere se ha attecchito.
>
> Tanto per partire: se ti dico "due elevato alla terza", cosa ti viene in mente? Anche solo la prima cosa che ti passa per la testa va bene.

Questo è il tono target. Tre paragrafi brevi, saluto con nome, riconoscimento del profilo senza citazione verbatim, mappa colloquiale del nodo, domanda aperta di warm-up che non richiede di sapere già nulla di nuovo. L'implementazione non genererà esattamente queste parole (è il tutor a scriverle, guidato dalle istruzioni), ma il risultato deve somigliare a questo.

Per confronto, il messaggio attuale (quello del test del 6 aprile) partiva dritto con l'esempio dei cioccolatini, senza nessuna delle tre prime battute.

---

## 4. Cosa va toccato nel codice

In linguaggio comprensibile, senza scendere in dettagli implementativi:

**File principale da modificare**: `backend/app/llm/prompts/direttive.py`. Qui vive la funzione `direttiva_spiegazione` che oggi istruisce il tutor a partire con l'esempio concreto. Va riscritta la parte "istruzioni primo turno" perché chieda al tutor di produrre il messaggio a tre battute descritto sopra. Vanno aggiunti due parametri in ingresso alla funzione: il nome dell'utente e l'indicazione se il nodo è "presunto padroneggiato" o no. Va creata, sempre in questo file, una piccola funzione helper privata (il "preambolo caldo" della decisione 7) che genera le righe di saluto+profilo+ritmo.

**File secondario**: `backend/app/core/contesto.py`. Qui c'è il punto in cui il backend costruisce il contesto da passare al tutor. Va assicurato che il nome utente venga effettivamente passato come parametro esplicito alla direttiva (oggi è nel contesto XML ma non arriva come argomento diretto alla funzione direttiva). Va assicurato anche che l'informazione "questo nodo è presunto padroneggiato" arrivi.

**Direttiva di ripresa sessione**: `backend/app/llm/prompts/direttive.py`, funzione `direttiva_ripresa_sessione`. Va adattata per chiamare anche lei la nuova funzione helper "preambolo caldo", così il saluto che già esiste diventa arricchito dal profilo utente.

**File di test**: va aggiunta una batteria di test unitari sulla nuova versione della `direttiva_spiegazione` (verificare che con certi input produce certe sezioni nel prompt) e sul preambolo helper. Questi test sono semplici da scrivere perché le direttive sono funzioni pure che ritornano stringhe.

**Cosa NON va toccato**:

- Il `SYSTEM_PROMPT` globale (`backend/app/llm/prompts/system_prompt.py`) non cambia. Il carattere del tutor va già bene, il problema era solo nelle istruzioni puntuali del primo turno.
- Il frontend non cambia. Il messaggio arriva via streaming come qualsiasi altro messaggio del tutor, non serve nessuna modifica all'interfaccia.
- Lo schema del database non cambia. Tutti i dati del profilo utente sono già nel DB e già passati al contesto del tutor. Va solo istruito il tutor a usarli.
- L'onboarding non cambia. Raccogliere le informazioni funziona già, il problema era solo che poi il tutor le ignorava nel primo messaggio di studio.

---

## 5. Idee parcheggiate per il futuro

Durante questa conversazione sono emerse idee che sono più grandi del fix che stiamo facendo oggi e che il fondatore ha deciso esplicitamente di **non** implementare adesso. Vanno registrate qui perché non vadano perse, e andranno riprese in un futuro tavolo dedicato.

### Ripensare il modello temporale di Dydat alla luce delle neuroscienze dell'apprendimento mobile

Oggi Dydat propone all'utente tre ritmi: Veloce 15 minuti, Normale 30, Approfondita 60. Questi numeri sono già molto alti per come funziona davvero l'attenzione su smartphone. Un adulto, su un telefono, raramente regge trenta minuti di attenzione continua su materiale nuovo.

Quello che la ricerca suggerisce per l'apprendimento mobile efficace va in una direzione diversa: **micro-cicli brevi** (tipicamente tre-sette minuti di focus reale), seguiti da micro-pause o da cambi di modalità; **richiamo attivo** al posto dell'ascolto passivo (l'utente deve fare qualcosa, non assistere); **ripetizione distanziata** che recupera cose viste nelle sessioni precedenti per un minuto, invece di rispiegarle daccapo; **cicli multipli e veloci** dentro la stessa sessione invece di un unico flusso lungo; uso consapevole dello smartphone come "device di micro-momenti" piuttosto che come surrogato del libro di testo.

In questa prospettiva, i 15/30/60 minuti non scomparirebbero, ma diventerebbero **contenitori** che ospitano tanti piccoli cicli da 3-5 minuti ciascuno, ognuno con un mini-obiettivo, alternando richiamo, input nuovo e pratica. La sessione acquisterebbe una struttura a "battiti" invece che a "capitoli".

Questo cambiamento implica:

- ripensare come il tutor distribuisce le sue mosse nel tempo;
- probabilmente introdurre indicatori visivi nel frontend (per esempio "stai nel ciclo 2 di 6", micro-pause esplicite);
- rivedere la logica con cui il sistema decide "ora basta spiegare, facciamo un esercizio";
- ridefinire cosa conta come "sessione riuscita" (non più "hai finito i 30 minuti", ma "hai completato n cicli utili");
- integrare meccanismi di ripetizione distanziata dentro la sessione corrente, non solo tra sessioni diverse.

**Cosa fare con questa idea**: il fondatore ha chiesto esplicitamente di parcheggiarla e riprenderla dopo. Prima di toccare codice, servirà una sessione di discovery vera, con la ricerca sull'apprendimento mobile sotto mano, per decidere numeri, strutture e meccanismi concreti. Non si parte di pancia. Questa voce è anche registrata in `.claude/ideas.md` come promemoria permanente.

### Verifica veloce completa per nodi presunti padroneggiati

La decisione 6 di questo documento introduce il trattamento differenziato dei nodi presunti, ma si limita al primo messaggio del tutor. Manca ancora la logica completa: cosa succede se l'utente risponde bene alla domanda-sonda? Il nodo si marca come confermato e si salta a quello successivo automaticamente? Se risponde male, in quale stato si finisce? Questi dettagli meritano un piccolo blocco dedicato successivo, non vanno infilati in questo intervento per non farlo esplodere.

### Estensione del preambolo caldo agli altri "primi momenti"

In questo intervento il preambolo caldo viene applicato solo a due direttive (spiegazione nuovo nodo, ripresa sessione). Gli altri casi (primo esercizio su nodo già spiegato, primo turno di sessione di ripasso basata su ripetizione distanziata) andranno agganciati mano a mano che i rispettivi blocchi di sviluppo arrivano nella roadmap.

---

## 6. Come Villa testerà il risultato sul telefono

Il test si fa con lo stesso identico flusso che ha rivelato il problema il 6 aprile, così il confronto è diretto.

Prima di tutto, Villa dovrà registrare un utente nuovo dall'app (non riutilizzare l'utente Verdan, per partire dal profilo pulito). Durante l'onboarding, dare risposte ricche e distintive: specificare di essere un adulto che sta riprendendo dopo una pausa, indicare un motivo personale preciso ("curiosità personale" o simile), dichiarare uno stile di apprendimento preferito ("esempi concreti prima della teoria" o simile), e dire un livello di confidenza specifico sulle operazioni base. Queste risposte sono importanti perché sono quelle che il tutor dovrà riconoscere nel primo messaggio.

Finito l'onboarding, Villa avvia la prima sessione di studio scegliendo il ritmo "Normale 30 minuti" e lascia che il sistema scelga il nodo di partenza. Quando si apre la schermata di studio, Villa legge attentamente il primo messaggio del tutor. Deve verificare concretamente queste cose:

- Il tutor saluta con il nome scelto in fase di registrazione? Il nome deve comparire esatto, non generico.
- Il tutor fa un riferimento al fatto che l'utente sta riprendendo dopo una pausa? Il riferimento deve essere naturale, non una ripetizione verbatim di quello che Villa ha scritto nell'onboarding.
- Il tutor menziona la mezz'ora a disposizione? Deve essere un accenno, non un'ossessione.
- Il tutor presenta il nodo con una piccola mappa di cosa si farà? Deve essere discorsivo, non un bullet formale.
- Il tutor termina con una domanda aperta di warm-up, e non con l'esempio dei cioccolatini o equivalente? La domanda deve essere rispondibile anche da chi non sa ancora niente del concetto.
- Il messaggio è diviso visibilmente in tre piccoli paragrafi, o è un muro di testo? Deve essere arioso.

Se uno di questi punti non torna, Villa fa screenshot e lo segnala. Il test è considerato superato solo se tutti e sei i punti sono verificati su almeno due esecuzioni consecutive con utenti diversi (per escludere che sia stato "solo un buon tiro dell'LLM").

**Test aggiuntivo sui nodi presunti padroneggiati**: per verificare la decisione 6, Villa dovrà registrare un secondo utente e durante il placement test dichiarare apertamente di sapere già alcuni argomenti di base, così che il sistema li marchi come presunti. Poi avviare una sessione su uno di quei nodi e verificare che il primo messaggio del tutor sia del tipo "verifica veloce" e non del tipo "spiegazione da zero".

---

## 7. Criteri di successo e criteri di fallimento

L'intervento è considerato **riuscito** se, dopo l'implementazione:

- il test manuale sopra passa su almeno due esecuzioni con utenti nuovi diversi;
- il test dei nodi presunti passa su almeno un'esecuzione;
- i test unitari automatici sulla direttiva passano;
- il tono del messaggio è coerente con il "carattere" Dydat (caldo ma non smielato, professionale ma non freddo) a giudizio di Villa.

L'intervento è considerato **fallito** e va rivisto se:

- il tutor dimentica o sbaglia il nome dell'utente anche solo in una esecuzione;
- il tutor cita il profilo in modo verbatim ("hai detto che studi per curiosità") anziché parafrasato;
- il messaggio supera le otto-dieci righe totali diventando un muro di testo;
- il tutor ignora la variante "nodo presunto" e parte lo stesso con la spiegazione da zero;
- il tempo di latenza percepito dall'utente peggiora in modo visibile rispetto a oggi (il primo token non arriva entro il solito intervallo di ~200-500ms).

---

## 8. Vincoli architetturali che restano rispettati

Per chiarezza, questa è la conferma che l'intervento proposto rispetta i vincoli descritti nel brief iniziale (`ux-01-brief.md`, paragrafo 3):

- I tre layer restano separati: l'intervento è solo sul layer del tutor (prompt), non tocca knowledge graph né orchestratore in modo sostanziale.
- Resta una singola chiamata LLM per turno, niente dialoghi a più round.
- I prompt restano in file separati (`backend/app/llm/prompts/`), non si hardcoda nulla nella logica applicativa.
- I turni di conversazione nel database continuano a contenere solo testo visibile.
- Lo streaming SSE non è toccato.
- Il modello LLM usato dal tutor resta Sonnet (configurabile), non si cambia modello.
- L'approccio parzialmente deterministico (nome e titolo nodo iniettati) segue un pattern già esistente in altri punti del codice.
- Ogni nuova funzione aggiunta è pura e facilmente testabile.

---

## 9. Riferimenti incrociati

- Brief originale della discussione: `docs/discussions/ux-01-brief.md`
- Idea iniziale registrata il 6 aprile: `.claude/ideas.md`, voce "Primo turno caldo di sessione"
- Nuova idea sul modello temporale e neuroscienze apprendimento mobile: `.claude/ideas.md`, voce del 2026-04-08
- Log decisioni architetturali: `.claude/decisions.md`, righe del 2026-04-08
- Issue UX di origine: `.claude/test-findings.md`, UX-01
- File di codice coinvolti: `backend/app/llm/prompts/direttive.py`, `backend/app/llm/prompts/system_prompt.py` (solo lettura), `backend/app/core/contesto.py`

---

*Documento redatto dopo sessione Cowork con il fondatore — 2026-04-08. Le decisioni qui contenute sono la base per la scrittura dell'handoff che verrà passato al runner del Metodo Villa per l'implementazione effettiva.*
