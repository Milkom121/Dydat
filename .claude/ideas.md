# Idee per il Progetto

Idee e intuizioni emerse durante le sessioni di sviluppo che non fanno parte del blocco corrente.
Ogni voce ha data e contesto. Verranno riprese in fase di pianificazione.

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
