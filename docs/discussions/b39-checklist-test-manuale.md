# B39 — Checklist Test Manuale del Fondatore

> Test manuale dell'intero flusso onboarding narrativo implementato nella catena B39.
> Da eseguire su emulatore o device fisico con utente creato da zero.
> Riportare i finding in `.claude/test-findings.md`.

---

## Prerequisiti

1. Backend avviato con Docker (`cd backend && docker compose up --build -d`)
2. Migrazione applicata (`docker exec backend-backend-1 alembic upgrade head`)
3. Dati curriculum importati (`docker exec backend-backend-1 python scripts/import_extraction.py data/Algebra1 data/Algebra2`)
4. `OPENAI_API_KEY` configurata in `backend/.env` (necessaria per la voce)
5. `ANTHROPIC_API_KEY` configurata in `backend/.env` (necessaria per il tutor Opus)
6. Frontend avviato su emulatore (`flutter run`)
7. **Nessun utente preesistente** — partire da zero (login screen)

---

## Scenario 1 — Utente collaborativo (flusso completo)

**Obiettivo**: verificare il flusso onboarding end-to-end per un utente che risponde volentieri.

### Passi

1. Aprire l'app — deve comparire la schermata di login con testo "Accedi a Dydat"
2. Toccare "Inizia senza account" (o equivalente) per avviare l'onboarding
3. **Primo turno**: il tutor deve presentarsi in prima persona ("Ciao, io sono il tuo tutor Dydat..."), menzionare il patto esplicito (perche ti faccio queste domande), menzionare la voce (microfono)
4. Rispondere con un racconto ricco: "Mi chiamo Marco, ho 42 anni, faccio il grafico. Ho sempre odiato la matematica ma voglio riprovarci da adulto. Mi piace partire da esempi concreti. Ho circa 20 minuti la sera."
5. Il tutor deve fare domande mirate solo sui campi rimasti vuoti (se qualcuno manca)
6. **Auto-valutazione**: il tutor deve chiedere forte/incerto/digiuno su aree della materia
7. **Verifica**: se hai dichiarato "forte" su qualcosa, il tutor deve proporre esercizi a scelta multipla (max 3)
8. **Chiusura**: il tutor deve salutare in modo caldo e invitare alla registrazione
9. Completare la registrazione (email + password)
10. Arrivare in Home

### Cosa mi aspetto

- [ ] Il tutor parla in prima persona, tono caldo
- [ ] Il patto esplicito e presente nel primo messaggio
- [ ] Il microfono e visibile accanto al pulsante invia
- [ ] Le domande mirate riguardano solo i campi mancanti (non ripete cose gia dette)
- [ ] L'auto-valutazione copre le aree del curriculum
- [ ] Gli esercizi di verifica sono a scelta multipla (3-4 opzioni)
- [ ] L'etichetta fase cambia durante il flusso (Benvenuto -> Conosciamoci -> Valutazione -> Pronti a partire)
- [ ] La barra di progresso avanza
- [ ] Dopo la registrazione, arrivo in Home senza errori
- [ ] Il banner onboarding NON compare (onboarding completato)

---

## Scenario 2 — Utente taciturno (risposte minime)

**Obiettivo**: verificare che il tutor insista con domande mirate e alla fine chiuda forzatamente.

### Passi

1. Avviare onboarding da zero
2. Al primo turno, rispondere solo "Ciao"
3. Ad ogni turno successivo, rispondere con 1-2 parole: "matematica", "si", "boh", "non so"
4. Continuare fino a quando il tutor non chiude forzatamente (tetto 7 turni narrativi)

### Cosa mi aspetto

- [ ] Il tutor non si arrende dopo una risposta breve, fa domande mirate
- [ ] Le domande diventano piu specifiche e guidate
- [ ] Dopo il tetto turni, il tutor chiude in modo caldo (non brusco)
- [ ] L'onboarding si chiude anche con profilo parziale
- [ ] La registrazione procede normalmente

---

## Scenario 3 — Skip immediato

**Obiettivo**: verificare il flusso skip dall'inizio.

### Passi

1. Avviare onboarding da zero
2. Toccare "Salta per ora" subito, senza rispondere al tutor
3. Completare la registrazione
4. Arrivare in Home

### Cosa mi aspetto

- [ ] Il bottone "Salta per ora" e visibile fin dalla prima schermata (in alto)
- [ ] Lo skip porta alla registrazione senza errori
- [ ] In Home compare il **banner persistente** "Inizia" (non "Riprendi", perche non ha mai risposto)
- [ ] Il banner non e dismissibile (non si puo chiudere)
- [ ] Lo studio funziona comunque (il tutor usa il fallback generico di B33.5)

---

## Scenario 4 — Skip dopo qualche turno

**Obiettivo**: verificare skip a meta conversazione.

### Passi

1. Avviare onboarding da zero
2. Rispondere a 2-3 turni normalmente
3. Toccare "Salta per ora"
4. Completare la registrazione
5. Arrivare in Home

### Cosa mi aspetto

- [ ] Lo skip funziona a meta conversazione
- [ ] In Home compare il **banner persistente** "Riprendi" (perche ha gia iniziato)
- [ ] Il banner mostra un messaggio caldo, non di colpa

---

## Scenario 5 — Dettatura vocale nell'onboarding

**Obiettivo**: verificare che il microfono funzioni nell'onboarding.

### Passi

1. Avviare onboarding da zero
2. Al primo turno, toccare il pulsante microfono
3. Concedere il permesso microfono se richiesto
4. Parlare per 5-10 secondi in italiano (es. "Mi chiamo Anna e studio per curiosita personale")
5. Toccare stop
6. Verificare che il testo trascritto appaia nel campo
7. Modificare il testo se necessario
8. Inviare con il pulsante invia

### Cosa mi aspetto

- [ ] Il microfono e visibile e tappabile
- [ ] La richiesta permesso microfono compare (la prima volta)
- [ ] Durante la registrazione: wave animata, timer, pulsante stop rosso
- [ ] Dopo lo stop: spinner "Trascrizione in corso..."
- [ ] Il testo trascritto appare nel campo input
- [ ] Il testo e modificabile prima dell'invio
- [ ] L'invio funziona normalmente

---

## Scenario 6 — Dettatura vocale nella sessione studio

**Obiettivo**: verificare che il microfono funzioni nella chat tutor durante lo studio.

### Passi

1. Completare l'onboarding (o skiparlo)
2. Avviare una sessione di studio dalla Home
3. Attendere il primo messaggio del tutor
4. Toccare il microfono nel campo input della chat
5. Parlare e fermare
6. Verificare trascrizione e invio

### Cosa mi aspetto

- [ ] Il microfono e visibile nella chat di sessione
- [ ] Il flusso registrazione -> trascrizione -> modifica -> invio funziona
- [ ] Il tutor risponde normalmente al testo trascritto

---

## Scenario 7 — Dettatura vocale nella ricerca "I miei studi"

**Obiettivo**: verificare che il microfono funzioni nella barra di ricerca.

### Passi

1. Andare nel tab "I miei studi"
2. Toccare il microfono nella barra di ricerca
3. Dettare il nome di un nodo/argomento (es. "frazioni")
4. Verificare che il testo appaia e la ricerca filtri i risultati

### Cosa mi aspetto

- [ ] Il microfono e visibile nella barra di ricerca
- [ ] Il testo trascritto appare nel campo e filtra i nodi in tempo reale
- [ ] L'icona di ricerca (lente) e visibile come prefisso
- [ ] Se il testo non e vuoto, appare l'icona per cancellare

---

## Scenario 8 — Primo turno caldo del tutor (B33.5)

**Obiettivo**: verificare che il tutor usi il profilo onboarding nella prima sessione di studio.

### Passi

1. Completare l'onboarding con risposte ricche (Scenario 1)
2. Completare la registrazione
3. Avviare la prima sessione di studio
4. Leggere il primo messaggio del tutor

### Cosa mi aspetto

- [ ] Il tutor cita qualcosa che l'utente ha detto nell'onboarding (parafrasato, non verbatim)
- [ ] Il tono e caldo e personale
- [ ] Il tutor menziona lo stile cognitivo scelto (es. "partiamo da un esempio come piace a te")
- [ ] Il nodo di partenza riflette la mappa placement (non il default)

---

## Scenario 9 — Errore voce (microfono negato)

**Obiettivo**: verificare la gestione errori.

### Passi

1. Avviare l'onboarding
2. Toccare il microfono
3. **Negare** il permesso microfono
4. Verificare il comportamento

### Cosa mi aspetto

- [ ] Messaggio breve e gentile (tipo "La voce non e disponibile — puoi continuare a scrivere")
- [ ] L'utente puo continuare a scrivere normalmente
- [ ] Nessun crash o blocco

---

## Scenario 10 — Banner in Home: visibilita e navigazione

**Obiettivo**: verificare il banner persistente onboarding in Home.

### Passi

1. Skipare l'onboarding (Scenario 3)
2. In Home, verificare la presenza del banner
3. Toccare il CTA del banner

### Cosa mi aspetto

- [ ] Il banner e visibile in Home, sotto il saluto di benvenuto
- [ ] Il banner ha un glow/stile visivamente prominente
- [ ] Il testo dice "Inizia" (per utente che non ha mai risposto) o "Riprendi" (se ha risposto)
- [ ] Il tap sul CTA porta a /onboarding
- [ ] Il banner NON compare per utenti con onboarding completato

---

## Scenario 11 — Placement test (esercizi verifica)

**Obiettivo**: verificare che gli esercizi di verifica compound funzionino.

### Passi

1. Completare la fase narrativa dell'onboarding
2. Nella fase auto-valutazione, dichiarare "forte" su almeno 2-3 aree
3. Attendere gli esercizi di verifica

### Cosa mi aspetto

- [ ] Gli esercizi sono a scelta multipla (3-4 opzioni)
- [ ] Max 3 esercizi proposti
- [ ] Se rispondo correttamente: conferma positiva
- [ ] Se rispondo erroneamente: tono caldo, non punitivo ("ho trovato un po' di incertezza, lo rivedremo insieme")
- [ ] Dopo gli esercizi, il tutor procede alla chiusura

---

## Scenario 12 — App offline / errore rete

**Obiettivo**: verificare i messaggi di errore user-friendly.

### Passi

1. Avviare l'onboarding
2. Disattivare la connessione di rete (modalita aereo)
3. Provare a inviare un messaggio
4. Provare a usare il microfono

### Cosa mi aspetto

- [ ] Messaggio di errore in italiano, gentile (non tecnico)
- [ ] Nessun crash
- [ ] L'utente capisce cosa fare (riconnettere)

---

## Note per il fondatore

- **B39.9.3 (Riprendi con stato preservato)** non e ancora implementato: il tap su "Riprendi" nel banner avvia un nuovo onboarding, non riprende la conversazione precedente. Questo sara fixato in un blocco separato.
- **Dettatura formule LaTeX** non inclusa in B39 — la voce trascrive solo testo naturale.
- Se trovi bug, documenta in `.claude/test-findings.md` con formato: codice bug (es. ONB-XX), gravita (critico/medio/basso), descrizione, screenshot se possibile.

---

*Generato per B39.11.1 — 2026-04-09*
