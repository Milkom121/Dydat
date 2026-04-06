# Idee per il Progetto

Idee e intuizioni emerse durante le sessioni di sviluppo che non fanno parte del blocco corrente.
Ogni voce ha data e contesto. Verranno riprese in fase di pianificazione.

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
