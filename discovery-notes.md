# Discovery Notes — Dydat UX Redesign

## Riassunto Strutturato (Fase 1)

### Obiettivo del progetto
Ripensare completamente la UX/UI dell'app Dydat — da prototipo tecnico funzionante a esperienza utente coerente, calda e con personalità. Il motore sotto (tutor AI, FSRS, esercizi adattivi, gamification) funziona. Serve trasformare l'interfaccia da "wireframe con colori" a prodotto che gli studenti vogliono usare.

### Utenti target
1. **Studente delle superiori (15-18 anni)**: la matematica è spesso un obbligo. Energia limitata per lo studio. Metro di paragone: TikTok, giochi, Discord. Ha bisogno di ritmo veloce, gratificazione frequente, zero sensazione di "scuola".
2. **Adulto che colma lacune**: ha scelto di studiare — motivazione interna forte ma fragile. Porta una storia complicata con la materia. Ha bisogno di rispetto, profondità, sentirsi trattato da adulto intelligente.

### Principio di design concordato
**Dydat è il compagno di studio bravo, non l'insegnante.** Affianca, spiega a modo suo, non giudica quando sbagli, festeggia con te quando ci arrivi. Il tutor AI già parla così (tono amichevole, non invadente — validato dal test E2E). L'interfaccia deve riflettere lo stesso linguaggio.

### Base visiva confermata
La direzione visiva v2 è solida:
- Mood: "studio notturno illuminato"
- Palette: ambra/grafite, dark-first
- Font: Plus Jakarta Sans
- Mappa emotiva: 7+1 beat della sessione
- Mascotte: Creatura di Luce ispirata a 22 di Soul (Pixar)
- Posizionamento: tra Duolingo (giocoso/infantile) e Coursera (freddo/corporate) — giocoso-sofisticato

### Stato attuale dell'app (gap tra visione e implementazione)
- **Tema**: palette implementata correttamente nel codice, ma usata al 40% del potenziale
- **Mascotte**: 5 stati comportamentali sofisticati, ma visivamente è un cerchio ambra con Icons.school
- **Celebrazioni**: logica e tempistiche corrette (burst vs glow vs promotion), ma usa emoji e forme base
- **Superfici**: card piatte con Container + bordo, nessun gradiente/glow/profondità
- **Transizioni**: fade/slide standard 300ms, nessuna narrazione emotiva
- **Sessione di studio**: strutturata come chat (messaggi in sequenza), non come esperienza immersiva
- **Percorso**: lista di card con progress bar, non "viaggio" narrativo
- **Apertura app**: schermata statica con bottone, nessun "bentornato a casa"

### Vincoli espliciti
- Stack: Flutter + FastAPI, non cambia
- Backend stabile (341 test), non va ristrutturato
- Schema DB non va modificato se non strettamente necessario
- Direzione visiva v2 confermata come base
- Mascotte "Creatura di Luce" non implementabile come asset Rive/illustrazione in questa fase (manca designer)

### Cosa NON stiamo decidendo in questa discovery
- Specifiche di UI engineering (px, ms, curve di animazione)
- Implementazione tecnica delle transizioni
- Asset grafici della mascotte
- Dettagli di palette (hex esatti)

---

## Gap Identificati (Fase 2)

### Area: Identità e Posizionamento

| # | Gap | Perché è importante |
|---|-----|---------------------|
| G1 | Due target molto diversi (15enne vs adulto) — come si concilia in un'unica esperienza? | Rischio: troppo giocoso per l'adulto, troppo serio per il ragazzo. Serve una strategia chiara. |
| G2 | Terreno comune identificato ("nessuno vuole sentirsi a scuola") ma non tradotto in principi di design concreti | Serve una lista di "questo sì / questo no" operativa |
| G3 | Tono della comunicazione UI — l'app come "parla"? (non il tutor, l'interfaccia stessa) | Bottoni, label, messaggi vuoti, errori — tutto comunica. Oggi è neutro/generico |

### Area: Flussi e Momenti

| # | Gap | Perché è importante |
|---|-----|---------------------|
| G4 | Momento di apertura/ritorno — non definito | Primo contatto = decisione di restare o chiudere. Oggi è piatto |
| G5 | Ritorno differenziato (giorno dopo vs settimana vs mese) — non progettato | Il ritorno dopo lungo tempo è il momento più delicato per la retention |
| G6 | Transizione da navigazione a sessione di studio — non pensata | È un cambio di stato emotivo: da "guardo" a "studio". Serve un rituale? |
| G7 | La sessione è una chat o qualcos'altro? — decisione strutturale non presa | Determina tutta l'architettura dell'esperienza di studio |
| G8 | Rapporto tra esercizio e flusso — l'esercizio è un messaggio tra tanti o un momento a sé? | Il focus dell'esercizio si perde nel feed chat |
| G9 | Sequenza promozione — celebrazione/riconoscimento/pausa/nuovo inizio non implementata come flusso | La promozione è IL momento emotivo — oggi è un overlay generico |
| G10 | Momento di chiusura sessione — come finisce? | Chiudere bene = voglia di tornare. Oggi è un recap con numeri |
| G11 | Ripasso/consultazione senza tutor — il punto sollevato da Villa su "rivedere appunti e esercizi passati" | Oggi non esiste. Dove vive? Come funziona? |

### Area: Navigazione e Struttura

| # | Gap | Perché è importante |
|---|-----|---------------------|
| G12 | Struttura a 3 tab (Studio/Percorso/Profilo) — è quella giusta? | Forse servono più tab, forse meno. La struttura deve riflettere i bisogni reali |
| G13 | Il Percorso — quanto è centrale nell'uso quotidiano? | Determina quanto investirci in design |
| G14 | Il Profilo — cruscotto statistiche o storia personale? | Determina il tipo di retention che costruisce |

### Area: Gamification e Motivazione

| # | Gap | Perché è importante |
|---|-----|---------------------|
| G15 | Streak, XP, badge — qual è la filosofia? Pressione positiva o celebrazione del percorso? | Duolingo usa la pressione ("non perdere la streak!"). È coerente con "compagno di studio"? |
| G16 | Achievement — cosa si celebra? Velocità, costanza, comprensione, coraggio? | Definisce i valori impliciti dell'app |
| G17 | Mascotte — che ruolo ha nell'esperienza? Compagna, guida, decorazione? | Oggi è un bottone per il tools tray. Potrebbe essere molto di più |

### Area: Onboarding

| # | Gap | Perché è importante |
|---|-----|---------------------|
| G18 | Primi 60 secondi — come si cattura un 15enne che ha appena scaricato l'app? | Tasso di abbandono al primo uso è altissimo nelle app edu |
| G19 | L'onboarding è una chat conversazionale — è il formato giusto? | Funziona per l'adulto curioso, forse no per il ragazzo impaziente |
| G20 | Momento "wow" dell'onboarding — il percorso che si costruisce visivamente | Previsto dalla direzione visiva, mai implementato. È ancora la scelta giusta? |

---

## Risposte dall'intervista

### D1 — Due target, una sola app (Gap G1, G2)
**Decisione:** Via di mezzo tra opzione A e B.
- **UI/UX unica** per tutti: allegra, spensierata, leggera, ma non infantile. Non cambia in base all'utente.
- **Tutor AI adattivo** nel tono e nell'approccio, calibrato su domande rapide a risposta multipla nell'onboarding (età, cosa studi, perché sei qui).
- L'interfaccia è il "posto" (uguale per tutti, accogliente). Il tutor è la "persona" (si adatta a chi ha davanti).
- Vantaggio: una sola implementazione UI, la complessità adattiva vive nei prompt del tutor.
- **Gap G1 chiuso.** G2 resta parzialmente aperto — servono i principi concreti di "allegra ma non infantile".

### D2 — Tono dell'interfaccia (Gap G3)
**Decisione:** Registro "serio nelle cose importanti, leggero nelle cose secondarie".
- **Azioni core (studio, sessione, esercizi):** tono diretto, funzionale, rispettoso. No ammiccamenti. Es: "Inizia a studiare".
- **Accoglienza e relazione (ritorno, saluti, incoraggiamenti):** tono caldo, affettuoso, senza giudizio. Mai notare le assenze in modo che generi senso di colpa. Es: "Bentornato! Eravamo rimasti alle equazioni."
- **Problemi e errori (connessione, caricamento, stati vuoti):** tono leggero, un po' giocoso, l'app non si prende troppo sul serio. L'errore non è un dramma. Es: "Oops! Non riesco a connettermi."
- **Principio generale:** Dydat parla come una persona equilibrata — seria quando conta, spiritosa quando non conta. Non infantile, non corporate.
- **Gap G3 chiuso.**

### D3 — Struttura della sessione di studio (Gap G7, G8)
**Decisione:** Modello C — Ibrido.
- Il **feed conversazionale** esiste e si può scrollare (spiegazioni, dialogo tutor-studente).
- Gli **esercizi escono dal feed** e si prendono lo schermo — l'esercizio è un momento a sé, non un messaggio tra tanti.
- Le **visualizzazioni generate dal tutor** (nuova feature) escono dal feed allo stesso modo.
- Finite le interazioni (esercizio completato, visualizzazione consultata), il risultato torna nel feed come record.
- La transizione dentro/fuori feed deve essere fluida e non disorientante.
- **Gap G7 chiuso. Gap G8 chiuso.**

### D3b — Tutor con capacità agentiche visive (nuova feature strategica)
**Decisione:** Sì, nella visione del prodotto. Implementazione graduale.
- Il tutor AI può generare visualizzazioni in tempo reale: grafici di funzioni, costruzioni geometriche, animazioni fisiche, rappresentazioni chimiche.
- **Architettura:** estensione del sistema tool-use esistente. Nuovi tool (es: `mostra_grafico`, `mostra_animazione`) → evento SSE con dati strutturati → widget Flutter dedicato per ogni tipo.
- **Vincolo:** set finito di tipi di visualizzazione, ognuno con widget dedicato. Si parte con 3-4 tipi per algebra/geometria.
- **Rischi da gestire:** scope creep (partire piccolo), qualità visualizzazioni (widget robusti), prompt engineering (il tutor deve sapere quando usarle e quando no).
- **Posizionamento:** questa è una feature differenziante — nessuna app mainstream ha un tutor AI che genera visualizzazioni in tempo reale. "Il compagno di studio che ti disegna le cose mentre te le spiega."
- **Priorità:** non immediata — prima si sistema l'esperienza base, poi si aggiungono le capacità visive.

### D4 — Strategia di implementazione in fasi
**Decisione:** tre fasi sequenziali, ognuna autosufficiente.
- **Fase A — Esperienza base:** ridisegno flussi, modello ibrido (esercizi escono dal feed), atmosfera visiva (gradienti, glow, profondità), beat emotivi, mascotte con CustomPainter, apertura/ritorno caldi. Niente WebView. Trasforma il prototipo in prodotto.
- **Fase B — Visualizzazioni native:** 4-5 tipi di widget Flutter nativi (grafico funzione, piano cartesiano, geometria, animazione fisica base). Tutor li invoca via tool-use con dati strutturati. Controllati, testabili, affidabili.
- **Fase C — Motore generativo:** WebView + JavaScript. Capacità illimitata di generare visualizzazioni. Feature differenziante, da implementare quando A e B sono solide.
- Ogni fase produce un prodotto migliore del precedente anche se non si arriva alle successive.

### D5 — Pricing e modello di business (idea preliminare)
**Idea (non decisione finale):** le visualizzazioni generative (Fase C) come feature premium.
- Piano base: tutor con Sonnet + visualizzazioni native (Fase B). Buona esperienza, costi sostenibili.
- Piano premium: tutor con Opus per visualizzazioni generative (Fase C). Qualità superiore, capacità illimitata.
- Motivazioni: copre costi maggiori del modello, differenzia i piani, qualità percepita coerente col prezzo.
- **Decisione rimandata** a quando il prodotto base è solido e ci sono utenti reali.

### D6 — Momento di apertura / ritorno (Gap G4)
**Decisione:** Home dedicata (opzione B).
- Lo studente che torna vede una **home di benvenuto**, non il tab Studio direttamente.
- La home mostra: dove sei nel percorso, un invito a riprendere, nodi da ripassare, ultimo risultato, streak.
- Da lì lo studente sceglie cosa fare: riprendere a studiare, ripassare, guardare il percorso, rivedere sessioni precedenti.
- **Perché:** supporta entrambi i target (il quindicenne va dritto, l'adulto si orienta), dà senso di controllo, non forza nessuno dentro una sessione.
- **Implicazione sulla navigazione:** la home potrebbe diventare il tab principale al posto del tab Studio attuale, oppure essere una schermata sopra i tab. Da definire.
- **Gap G4 chiuso.**

### D6b — Contenuti accessibili fuori dalla sessione (Gap G11 + nuovo requisito)
**Decisione:** tutto il lavoro dello studente deve essere accessibile fuori dalla chat.
- **"Quaderno" dello studente:** una sezione dedicata dove sono raccolti tutti i contenuti prodotti durante lo studio — appunti, esercizi svolti, formule viste, spiegazioni chiave, visualizzazioni generate.
- Non è la cronologia delle chat — è un archivio organizzato per argomento/nodo, consultabile e ricercabile.
- Lo studente deve poter rivedere cosa ha fatto su un concetto specifico senza riaprire una sessione col tutor.
- **Principio:** chi studia ha bisogno di un quaderno. Dydat deve essere anche quello.
- Questo vale per qualsiasi percorso — matematica, fisica, chimica, o percorsi generati da una domanda curiosa.
- **Implicazione sulla navigazione:** serve una sezione dedicata nella struttura dell'app (tab? sezione della home? da definire).
- **Gap G11 chiuso.**

### D6c — Percorsi generati da domande (nuova feature nella visione)
**Idea (non decisione finale):** lo studente fa una domanda curiosa ("perché aceto e bicarbonato fanno la schiuma?") e l'app genera un percorso personalizzato per arrivare a comprendere quel fenomeno, partendo dal livello attuale dello studente.
- Implica che il sistema di path planning possa generare percorsi on-demand, non solo dalla struttura curricolare predefinita.
- **Priorità:** visione futura, non Fase A. Da documentare e tenere a mente nelle decisioni architetturali.

### D6d — Architettura del quaderno: per nodo, non per percorso (Gap G11 evoluzione)
**Decisione:** il quaderno è organizzato per concetto (nodo del grafo), non per percorso.
- Ogni **nodo** del grafo ha il suo quaderno unico: appunti, esercizi svolti, formule, spiegazioni, visualizzazioni.
- I **percorsi** sono viste di navigazione sopra il grafo — mostrano i nodi nell'ordine di quel percorso.
- Se un nodo è condiviso tra percorsi (es: "proporzioni" in Algebra e in Chimica), il quaderno è lo stesso. Lo studente vede continuità, non duplicazione.
- Nodi già studiati in un percorso precedente mostrano un indicatore ("Già studiato in Algebra base") quando compaiono in un nuovo percorso.
- Il tutor gestisce il contesto: se lo studente arriva a un nodo già noto da un altro percorso, spiega come si applica nel nuovo contesto. Il nuovo materiale si aggiunge allo stesso quaderno del nodo.
- **Coerenza con architettura backend:** il grafo è già uno, i nodi hanno già stato per utente, esercizi e sessioni sono già collegati a nodi. Il quaderno è un'estensione naturale.
- **Principio:** la conoscenza è una, i percorsi sono cammini diversi attraverso la stessa conoscenza.

### D7 — Ritorno dopo assenza lunga (Gap G5)
**Decisione:** Mix di B e C — riconoscimento gentile + FSRS come meccanismo di rientro.
- L'app riconosce l'assenza **senza drammatizzarla**: tono caldo, nessun senso di colpa.
- Usa il sistema FSRS (già esistente nel backend) per calcolare cosa lo studente ha probabilmente dimenticato.
- Propone un rientro facilitato: "È passato un po' — questi concetti probabilmente ti servono un ripasso" con lista dei nodi da ripassare.
- Lo studente sceglie: ripassare prima, oppure riprendere da dove era.
- **Perché B+C:** il riconoscimento gentile (B) dà il tono giusto. L'FSRS adattivo (C) dà utilità concreta senza richiedere logica nuova — il backend calcola già i nodi da ripassare.
- **Gap G5 chiuso.**

### D8 — Struttura di navigazione (Gap G12)
**Decisione:** 3 tab + modalità Studio immersiva.
- **Tab 1 — Home:** punto di ingresso. Accoglienza, stato, suggerimenti (riprendere, ripassare), mini-percorso visivo, streak.
- **Tab 2 — I miei studi:** unifica Percorso (mappa) e Quaderno (contenuti). Vista default = mappa dei nodi. Tap su nodo = quaderno di quel nodo (appunti, esercizi, formule, spiegazioni). Ricerca per argomento.
- **Tab 3 — Profilo:** achievement, statistiche, storia, impostazioni.
- **Modalità Studio:** non è un tab — è una modalità a schermo intero. I tab spariscono. Si entra dalla Home o da un nodo. Si esce a fine sessione o con gesto esplicito.
- **Perché 3 tab:** semplice, chiaro, ogni tab ha un ruolo preciso. Lo Studio come modalità evita un tab vuoto quando non c'è sessione attiva.
- **Gap G12 chiuso.**

### D9 — Ruolo della mascotte (Gap G17)
**Decisione:** La mascotte è il tutor reso visibile (opzione B).
- La mascotte è l'incarnazione grafica del tutor AI. Quando il tutor parla, la mascotte reagisce. I suoi stati emotivi riflettono i beat della sessione (già definiti nella direzione visiva v2).
- Per ora resta un cerchio con animazioni di stato. In futuro: forma organica, espressioni, animazioni Rive.
- Mantiene anche la funzione di accesso al tools tray (tap → apre strumenti).
- **Gap G17 chiuso.**

### D10 — Filosofia gamification (Gap G15, G16)
**Decisione:** Celebrare la comprensione e il coraggio, mai punire l'assenza o l'errore.
- **Obiettivo della gamification:** togliere la paura dalla materia e mostrarne il fascino. Non rendere la matematica un gioco — cambiare il rapporto dello studente con la materia.
- **Streak:** esiste come riconoscimento positivo ("bello, 5 giorni di fila") ma la sua perdita non è drammatizzata. Nessun senso di colpa, nessuna notifica "hai perso la streak".
- **Achievement:** celebrano comprensione e coraggio, non performance.
  - SÌ: "Hai capito le equazioni di primo grado", "Hai collegato algebra e geometria", "Hai spiegato un concetto con le tue parole"
  - NO: "Hai fatto 100 esercizi", "Hai risposto in meno di 10 secondi"
- **Errore:** mai penalizzato. Mai. La celebrazione post-guida (Beat 5c) è speciale, non ridotta.
- **Idea — Collezione di intuizioni:** ogni concetto capito potrebbe avere un titolo evocativo che cattura l'essenza ("Le equazioni sono bilance"). Lo studente colleziona intuizioni, non punti.
- **Principio:** la gamification riflette i valori dell'app — curiosità, comprensione, perseveranza. Non produttività, velocità, competizione.
- **Gap G15 chiuso. Gap G16 parzialmente chiuso** (da definire i tipi concreti di achievement).
- **Eccezione — ripasso FSRS:** il ripasso scientifico è un impegno, non una vanità. Se lo studente accetta un piano di ripasso, l'app lo tiene responsabile. Quando salta un ripasso, glielo comunica con tono costruttivo ("questo concetto sta scivolando via, riprendiamolo") — non punitivo, ma onesto. È la differenza tra streak cosmetica (perderla non cambia niente) e ripasso scientifico (non farlo ha conseguenze reali sull'apprendimento).
- **Principio:** gentile sull'assenza generica, onesta sugli impegni di ripasso presi.

### D11 — Onboarding: primi 60 secondi (Gap G18, G19, G20)
**Decisione:** "Mostra, non raccontare" — un micro-momento di fascino prima di qualsiasi conversazione.
- **Sequenza onboarding:**
  1. **Momento wow (30-60s):** l'app mostra una domanda curiosa e la risponde con una visualizzazione che si costruisce sullo schermo. Lo studente guarda, non deve fare niente. Scopo: far sentire che "la matematica può essere così".
  2. **Domande rapide (30s):** età, cosa studi, perché sei qui. Risposte multiple, veloci. Servono a calibrare il tutor.
  3. **Conversazione col tutor:** il tutor (incarnato dalla mascotte) saluta e inizia l'esplorazione delle conoscenze. Da qui il flusso esistente funziona già bene.
  4. **Costruzione del percorso:** il momento visivo dove il percorso si costruisce davanti allo studente (già previsto dalla direzione visiva v2).
  5. **Registrazione:** alla fine, non all'inizio. Lo studente si registra dopo aver visto il valore.
- **Principio:** lo studente deve sperimentare Dydat prima di doversi fidare. La fiducia si guadagna con un momento, non con una promessa.
- **Da definire:** la domanda/visualizzazione specifica del momento wow. Deve essere universalmente affascinante, non troppo tecnica, non banale.
- **Gap G18 chiuso. G19 chiuso. G20 chiuso.**

### D12 — Transizione dentro la sessione (Gap G6)
**Decisione:** Momento di transizione breve con la mascotte protagonista.
- Il passaggio da Home a sessione non è istantaneo — c'è un'animazione di transizione dove la mascotte "porta" lo studente dentro lo spazio di studio.
- Deve essere veloce (< 1-2 secondi) — non un caricamento, un cambio di stato percepibile.
- La mascotte è il tutor → è lei che ti apre la porta della sessione. Coerente col ruolo (D9).
- Corrisponde al Beat 1 della direzione visiva ("Bentornato a casa").
- **Da definire in fase UI:** l'animazione specifica (mascotte che attraversa lo schermo, canvas che si illumina, etc).
- **Gap G6 chiuso.**

### D13 — Promozione: momento di picco (Gap G9)
**Decisione:** Celebrazione breve dentro il canvas, con scelta dello studente.
- La promozione avviene **nel canvas**, non come overlay separato. È un momento che succede nello spazio di studio.
- La mascotte ha un momento celebrativo (animazione speciale, espressiva, divertente).
- Si mostra l'accumulo di gamification: punti, achievement sbloccati, progressi.
- Durata breve — celebra ma non interrompe troppo il ritmo.
- **Dopo la celebrazione, lo studente sceglie:** continuare al prossimo nodo o fermarsi qui. Non si va avanti automaticamente.
- **Perché la scelta:** rispetta il senso di controllo dello studente. Chi ha energia continua. Chi è stanco si ferma con soddisfazione, non con frustrazione.
- **Gap G9 chiuso.**

### D14 — Chiusura della sessione (Gap G10)
**Decisione:** Recap narrativo + numeri (opzione C).
- Il tutor fa un **commento narrativo breve** che riassume cosa è stato fatto e anticipa cosa verrà ("Oggi hai capito X, la prossima volta vedremo Y").
- Sotto, i **numeri** per chi vuole vederli: durata, esercizi, nodi, achievement.
- Il narrativo dà la sensazione di chiusura emotiva. I numeri danno la gratificazione concreta.
- **Principio:** lo studente chiude l'app con una sensazione di "ho fatto qualcosa di significativo", non solo "ho fatto 45 minuti".
- **Gap G10 chiuso.**

### D15 — Visualizzazione del percorso (Gap G13)
**Decisione:** Vista adattiva con due livelli di zoom (opzione C).
- **Default:** il percorso attuale dello studente, visualizzato in modo lineare e semplice. Chiaro, navigabile, non intimidatorio.
- **Zoom out:** lo studente può "allargare" e vedere il grafo completo delle connessioni tra concetti. Algebra che si collega a geometria che si collega a fisica.
- **Perché:** il livello semplice serve per l'uso quotidiano ("dove sono, cosa c'è dopo"). Il grafo serve per la curiosità e la motivazione ("guarda quante cose ci sono da scoprire, e guarda come sono collegate").
- Coerente con la visione dei percorsi generati da domande: nel grafo espanso lo studente vedrebbe come un percorso curiosità si intreccia col percorso principale.
- **Gap G13 chiuso.**

### D16 — Profilo: struttura (Gap G14)
**Decisione:** Numeri in alto, storia sotto (opzione C invertita).
- **In cima:** cruscotto compatto con i numeri chiave — ore studiate, nodi completati, streak, livello. Colpo d'occhio rapido, poco spazio.
- **Sotto:** la storia dello studente — achievement, momenti chiave (primo nodo, primo Feynman, connessioni tra materie), intuizioni collezionate. Più estesa, narrativa, per chi vuole esplorare.
- **Perché questo ordine:** chi ha fretta vede i numeri e esce. Chi ha tempo scrolla e si gode il viaggio. I numeri occupano meno spazio, la storia si espande.
- **Gap G14 chiuso.**

### D17 — Notifiche push: strategia
**Decisione:** Sistema di notifiche strutturato e presente. Non aggressivo ma non timido.
- Lo studente ha scelto di studiare — Dydat lo aiuta a perseverare.
- **Tre tipi di notifica, tre toni diversi:**
  - **Ripasso FSRS (urgenza scientifica):** tono diretto, onesto. "Il concetto X sta scivolando via — 5 minuti bastano." Queste hanno priorità massima perché c'è una conseguenza reale.
  - **Continuità (richiamo motivazionale):** quando lo studente non studia da qualche giorno. Non fa pesare l'assenza — usa curiosità legata a quello che stava studiando. Ha valore in sé, non è un promemoria vuoto.
  - **Celebrazione (rinforzo positivo):** streak raggiunta, achievement sbloccato, traguardo. Rinforza il positivo.
- **Frequenza:** presente ma calibrata. Lo studente deve sentirsi cercato, non perseguitato.
- **Riferimento:** Duolingo come ispirazione per la struttura (efficace) ma con tono coerente con Dydat (compagno, non senso di colpa).

### D18 — Durata sessione e gestione del tempo
**Decisione:** Sessione a obiettivo (C) + tutor che suggerisce pause (B) + notifica se esci prima.
- **All'inizio:** lo studente sceglie un obiettivo di durata (es: veloce 10 min, normale 20 min, approfondita 40 min). Il tutor calibra il ritmo di conseguenza.
- **Se supera il tempo:** il tutor suggerisce una pausa. "Bella sessione — vuoi continuare o ci fermiamo qui?" Lo studente sceglie, ma ha il "permesso" di fermarsi.
- **Se esce prima dell'obiettivo:** dopo un po' arriva una notifica leggera che lo richiama ("Ehi, che fine hai fatto?"). Tono compagno, non punitivo.
- **Perché questo mix:** l'obiettivo iniziale dà struttura e impegno. Il suggerimento del tutor protegge dallo sfinimento. La notifica chiude il cerchio sulla responsabilità.
- Si integra col sistema notifiche (D17) come quarto tipo: **sessione incompleta.**

### D19 — Sistema audio
**Decisione:** Dydat ha un sistema di suoni completo + musica opzionale.
- **Micro-suoni:** accompagnano i momenti chiave dell'esperienza — esercizio corretto, errore (morbido, non punitivo), promozione, achievement, transizione in/out sessione, azioni mascotte.
- **Feedback aptico:** confermato dalla direzione visiva v2. Leggero per interazioni quotidiane, forte per promozioni e achievement.
- **Musica:** disponibile come opzione. Lo studente può attivare musica di sottofondo durante lo studio. Scelta dell'utente.
- **Impostazioni:** tutto configurabile dal Profilo → Impostazioni. Suoni on/off, musica on/off, volume, tipo di musica.
- **Principio:** il suono è parte del design dell'esperienza, non un accessorio. Contribuisce all'atmosfera "studio notturno illuminato".
