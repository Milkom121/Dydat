# Idee per il Progetto

Idee e intuizioni emerse durante le sessioni di sviluppo che non fanno parte del blocco corrente.
Ogni voce ha data e contesto. Verranno riprese in fase di pianificazione.

## 2026-04-08 - Onboarding ibrido a narrazione libera + estrazione AI (input obbligatorio per B39 "Momento Wow")
- **Contesto**: Emersa durante il test manuale di B33.5 del 2026-04-08. Villa stava per iniziare l'onboarding per testare il primo turno caldo e ha proposto un approccio alternativo: invece di un questionario strutturato (chi sei / perche studi / come preferisci imparare), lasciare che l'utente si racconti liberamente in prima persona e che l'AI estragga il profilo dalla narrazione, facendo domande di chiarimento solo sui buchi.
- **Motivazione di Villa**: il questionario strutturato attuale sembra "burocratico" e rompe il tono caldo del tutor prima ancora che il tutor entri in scena. Un racconto libero crea fiducia, cattura sfumature emotive (vissuto scolastico, rapporto con la materia, aspettative) che il form non raccoglie, e rispetta l'autonomia dell'utente.
- **Versione che funziona — approccio IBRIDO** (non chat libera pura — vedi sezione "rischi" sotto):
  1. **Apertura guidata ma aperta**: il tutor propone un singolo turno libero con esempio breve tra parentesi per evitare la sindrome della pagina bianca. Esempio: *"In due righe, raccontami cosa ti ha spinto a scaricare Dydat — niente formalita, mi basta capire da dove vieni. (Tipo: 'sono un quarantenne che vuole riprendere la matematica dopo anni perche mi serve sul lavoro', o 'curioso di natura, studio per piacere'.)"*
  2. **Un singolo turno di narrazione libera**, con range raccomandato (20-400 parole). L'AI estrae quello che trova nei campi strutturati che il backend richiede (`chi_e`, `motivo`, `stile_cognitivo`, eventuali altri).
  3. **1-3 domande mirate SOLO sui buchi**, senza re-chiedere quello che l'utente ha gia detto. Es. se ha raccontato tutto tranne lo stile cognitivo: *"Mi hai detto tutto quello che mi serve, manca solo una cosa: quando studi, ti viene piu facile partire da esempi concreti oppure dalla regola astratta?"*
  4. **NIENTE riepilogo verbatim finale**: non dire *"quindi se ho capito bene, sei X, Y, Z, corretto?"* — quello crea l'effetto "call center che rilegge il ticket" ed e proprio l'errore che UX-01 decisione 3 ci ha gia insegnato a evitare. L'AI usa direttamente il profilo raccolto nel primo turno caldo della prima sessione (B33.5); se ha frainteso, l'utente lo corregge conversazionalmente durante la sessione vera.
  5. **Test di posizionamento** opzionale alla fine, e questa volta lo implementiamo davvero fixando PRE-01 (oggi il tutor lo propone ma non lo eroga).
- **Peso della chat vocale in questo ragionamento**: punto critico sollevato da Villa. Un quarantenne su smartphone scrive lento, e chiedergli 300 parole di racconto via tastiera e una barriera concreta all'adozione. **Per rendere sostenibile un onboarding narrativo, la chat vocale non e un nice-to-have, e un vincolo progettuale**. L'utente deve poter **parlare** al posto di scrivere durante l'onboarding (speech-to-text nel campo di input, idealmente con feedback visivo durante il parlato). Senza chat vocale, anche l'approccio ibrido rischia di diventare una rottura di scatole. Collegare esplicitamente questa idea con la voce del 2026-02-25 *"Voice input per risposte studente"* e con B40 *"Sistema Audio Base"* di Fase 10 — B39 e B40 vanno progettati insieme, non in sequenza indipendente, perche B39 dipende dal vocale di B40 per funzionare davvero.
- **Rischi identificati che l'ibrido mitiga** (se si facesse chat libera pura sarebbero letali):
  1. **Pagina bianca** — mitigato dall'esempio tra parentesi nel prompt iniziale.
  2. **Costo di digitazione su mobile** — mitigato dalla chat vocale (vedi sopra).
  3. **Affidabilita estrazione AI** — mitigato dalle domande mirate sui buchi.
  4. **Sindrome customer care nel recap** — mitigato dall'eliminazione del recap esplicito (il profilo viene usato direttamente in B33.5).
  5. **Contenuti sensibili** (utente che si apre troppo) — va gestito con un prompt che istruisce il tutor a non approfondire temi emotivi delicati in fase di onboarding, e a spostare il focus sui temi di studio con gentilezza.
  6. **Utenti "wrong mode"** (chi lo usa come chatbot generico, chi scrive in inglese, chi chiede di Dydat invece di rispondere) — prompt guardrail chiari + rediirezione morbida.
  7. **Testabilita** — la chat libera e meno testabile della forma strutturata. Serviranno test su casi rappresentativi (racconto breve, racconto lungo, contenuto fuori tema, lingua sbagliata, ecc.) invece di unit test rigidi.
- **Direzione**: **questa idea va trattata come input obbligatorio della sessione di discovery di B39** "Onboarding con Momento Wow" in Fase 10. Non va implementata ora. Quando inizieremo a progettare B39, questa nota va letta insieme a:
  - `docs/discussions/ux-01-primo-turno-caldo.md` (decisioni di design gia prese su profilo utente e primo turno caldo)
  - `.claude/test-findings.md` PRE-01 (placement test non erogato — va fixato qui)
  - B40 Sistema Audio Base (dipendenza — il vocale deve essere disponibile prima che B39 sia davvero usabile)
  - Questa voce stessa
- **Priorita**: alta come input di design, ma non urgente — si attiva quando si apre la sessione di discovery di B39.

## 2026-04-08 - Modello temporale Dydat e neuroscienze dell'apprendimento mobile (macro-riprogettazione)
- **Contesto**: Emersa durante la sessione Cowork di design del "primo turno caldo" (UX-01). Discutendo del "piano sessione" da 15/30/60 minuti, Villa ha sollevato il punto piu grosso: quei numeri sono gia enormi per come funziona l'attenzione su smartphone, e dovremmo ripensare da zero il modello temporale di Dydat tenendo conto delle neuroscienze dell'apprendimento e del modo in cui gli esseri umani usano davvero il telefono.
- **Direzione**: spostare da "sessione lunga monolitica" a "contenitore che ospita tanti micro-cicli brevi":
  1. **Micro-cicli di 3-7 minuti** di focus reale, seguiti da micro-pause o da cambi di modalita
  2. **Richiamo attivo** al posto dell'ascolto passivo (lo studente DEVE fare qualcosa, non assistere)
  3. **Ripetizione distanziata** integrata DENTRO la sessione corrente, non solo tra sessioni diverse — recupero in 30-60 secondi di cose viste nei giorni precedenti
  4. **Alternanza rapida** input nuovo / richiamo / pratica, invece di un unico flusso espositivo lungo
  5. **Smartphone come device di micro-momenti**, non surrogato del libro di testo
  6. **Ridefinizione del "successo sessione"**: non piu "hai completato i 30 minuti" ma "hai completato N cicli utili"
- **Impatti stimati** (se si procedera):
  - Ripensare come il tutor distribuisce le mosse nel tempo (direttive, orchestratore, signal di transizione)
  - Probabile introduzione di indicatori visivi nel frontend (ciclo 2 di 6, micro-pause esplicite, forse anche micro-notifiche per ripasso distanziato)
  - Rivedere la logica "ora basta spiegare, facciamo un esercizio" — oggi implicita nel prompt, dovrebbe diventare signal-driven con budget per micro-ciclo
  - Integrare un meccanismo di FSRS/SRS light anche intra-sessione, non solo inter-sessione
- **Vincolo esplicito del fondatore**: NON partire di pancia. Prima serve una sessione di discovery vera con la ricerca sull'apprendimento mobile sotto mano (paper, linee guida, esempi di app che lo fanno bene) per decidere numeri concreti, strutture e meccanismi. Solo DOPO si progettano i blocchi di sviluppo.
- **Priorita**: alta strategica ma NON urgente. Non blocca niente di oggi. Va ripresa quando si chiude la fase UX Redesign in corso.
- **Collegamento**: decisione presa nel contesto di UX-01 (`docs/discussions/ux-01-primo-turno-caldo.md`, sezione 5). Il primo turno caldo di oggi implementa solo la citazione leggera del tempo + modulazione morbida, NON un vero piano sessione strutturato, proprio per lasciare spazio a questa riprogettazione piu grande.

## 2026-04-07 - Impostazione dimensione font in-app
- **Contesto**: Discussione post-test manuale B35.14 con Villa. L'app ora rispetta il TextScaler di sistema (B35.13), ma molti utenti non sanno che esiste o vorrebbero scalare solo Dydat indipendentemente dal sistema.
- **Proposta blocco**: **B36 - Impostazione dimensione font in-app** (~30-45 min runner)
- **Cosa serve**:
  1. Provider Riverpod `fontScaleProvider` con persistenza in SharedPreferences
  2. Wrapper sopra MaterialApp che applica `MediaQuery.copyWith(textScaler: TextScaler.linear(scale))`
  3. Sezione "Aspetto" nelle impostazioni del Profilo con 4 opzioni (Piccolo / Normale / Grande / Molto grande) o slider 0.85-1.4
  4. Helper per LaTeX (`flutter_math_fork` non rispetta TextScaler, usa CustomPainter): moltiplicare il `fontSize` di `Math.tex` per il fattore scelto, applicato a `FormulaCurriculumCard` ed `EsempioInlineCard`
- **Note**: Da fare DOPO chiusura e merge di B35.14 su develop. Bonus: complementare al TextScaler di sistema (l'utente puo scegliere quale usare).

## 2026-04-06 - Quaderno enciclopedico (UX strategica)
- **Contesto**: Test manuale post-Fase 9. Villa osserva che il quaderno per nodo (B35) dovrebbe essere "fruibile anche senza averlo studiato" — una scheda enciclopedica + log personale, non solo log.
- **Stato DB**: la tabella `nodi` contiene gia tutti i dati intrinseci (definizioni_formali, formule_proprieta, errori_comuni, esempi_applicazione, parole_chiave) come JSONB, importati da data/Algebra1 + Algebra2. L'endpoint B35 li ignora.
- **Proposta blocco**: **B35.5 "Quaderno enciclopedico"** — estendere endpoint + frontend per renderizzare scheda intrinseca del nodo sopra al log personale. Formule in LaTeX.
- **Impatto**: trasforma Dydat da "tutor conversazionale" a "tutor + libro di testo personale". Dato gia in DB, serve solo renderlo.
- **Priorita**: alta. Rende senso immediato al tab "I miei studi" e al Quaderno anche per utente al primo accesso.
- **File detail**: vedi `.claude/test-findings.md` UX-02.

## 2026-04-06 - Primo turno caldo di sessione (UX strategica)
- **Contesto**: Test manuale post-Fase 9. Villa osserva che il primo turno del tutor dopo onboarding e "troppo immediato" — parte direttamente con esempio + definizione + domande, senza ponte con l'onboarding ne presentazione del nodo.
- **Cosa manca**: continuita con info raccolte nell'onboarding, presentazione del nodo e dei tempi, warm-up esplorativo prima di esporre, ponte conversazionale caldo, riconoscimento del ritmo (Veloce/Normale/Approfondita) scelto.
- **Proposta**: blocco dedicato **B33.5 "Primo turno caldo"** oppure integrazione nel redesign onboarding di Fase 10 B39. Approccio: primo turno parzialmente deterministico (template "accoglienza + presentazione nodo + proposta") prima di lasciare il timone all'LLM + iniezione esplicita del profilo utente nel contesto.
- **Priorita**: alta. Impatta la prima impressione dell'utente e il senso di "tutor che ti conosce".
- **File detail**: vedi `.claude/test-findings.md` UX-01.
- **AGGIORNAMENTO 2026-04-08**: discussione strategica completata con Villa in sessione Cowork. Prese le 7 decisioni di design (struttura monolitica a tre battute, approccio parzialmente deterministico con iniezione nome + titolo nodo, uso parafrasato di chi_e/motivo/stile_cognitivo, micro-indice discorsivo del nodo, citazione leggera del ritmo + modulazione morbida, trattamento differenziato per nodi presunti padroneggiati, helper preambolo caldo riutilizzabile). Documento di sintesi completo pronto per implementazione in `docs/discussions/ux-01-primo-turno-caldo.md`. File codice principali: `backend/app/llm/prompts/direttive.py` (riscrittura `direttiva_spiegazione` + nuovo helper `_preambolo_caldo`), `backend/app/core/contesto.py` (pass-through nome utente e flag nodo presunto), `direttiva_ripresa_sessione` (anche lei usa il nuovo helper).


## 2026-02-19 - Mascotte "Creatura di Luce"
- **Contesto**: Discussione design mascotte durante Loop 2
- **Idea**: Mascotte animata tipo creatura di luce che reagisce allo stato dello studente. Richiede asset design (SVG/Rive). Attualmente placeholder circolare con animazioni stato-driven.

## 2026-02-27 - Voice Input per lo studente
- **Contesto**: Riflessione UX durante pianificazione Loop 4-7
- **Idea**: Permettere allo studente di rispondere a voce oltre che per testo. Speech-to-text integrato nel campo input. Utile soprattutto per spiegazioni Feynman (piu naturale parlare che scrivere).

## 2026-02-27 - Beat-aware canvas styling
- **Contesto**: Pianificazione Loop 7 (Atmosfera)
- **Idea**: Lo sfondo e i colori del canvas cambiano sottilmente in base al "ritmo" della sessione (focus, flow, review, celebrate). Gia pianificato come B34, ma potrebbe evolvere in qualcosa di piu sofisticato con audio/musica.

## 2026-02-27 - Mascotte asset con AI generativa
- **Contesto**: Pianificazione asset mascotte
- **Idea**: Usare Midjourney/DALL-E per generare i PNG della mascotte in vari stati, poi Flutter code per glow/transizioni. Track separato dal codice — serve sessione dedicata di design.

## 2026-04-05 - Widget test e integration test frontend
- **Contesto**: Audit completo del codice
- **Idea**: Aggiungere widget test per i flussi critici (login -> onboarding -> studio -> recap). Attualmente solo unit test per provider/servizi. I widget test richiederebbero un investimento significativo ma aumenterebbero la confidenza sui rilasci.

## 2026-04-05 - Paginazione storico sessioni
- **Contesto**: Audit performance frontend
- **Idea**: La session history carica tutto in una volta. Con molte sessioni (50+) potrebbe rallentare. Implementare paginazione lato backend (offset/limit) e lazy loading lato frontend.

## 2026-04-05 - Deep linking con parametri route
- **Contesto**: Audit routing frontend
- **Idea**: Aggiungere parametri dinamici alle route GoRouter (/studio/:sessionId, /percorso/:topicId) per supportare deep linking e restore dello stato. Utile se un giorno si aggiungono notifiche push con link diretti.
