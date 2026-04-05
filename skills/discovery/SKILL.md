---
name: discovery
description: "Skill per la fase pre-sviluppo: raccolta requisiti, analisi documenti cliente, intervista strutturata, creazione concept document (Word .docx) e presentazione (PowerPoint .pptx), gestione feedback iterativa con analisi impatti a cascata. Usa questa skill ogni volta che l'utente menziona: nuovo progetto, nuovo cliente, raccolta requisiti, analisi requisiti, concept, proposta, brief, kickoff, discovery, fase iniziale, intervista cliente, documento di progetto, presentazione progetto. Anche quando l'utente carica un documento di un cliente e vuole analizzarlo per definire un progetto software o digitale. Sempre quando si parla di trasformare un'idea o richiesta cliente in un piano strutturato prima dello sviluppo. English triggers: requirements gathering, project discovery, client brief, project kickoff, concept document, project proposal, stakeholder interview."
---

# Discovery — Raccolta Requisiti e Design Pre-Sviluppo

Questa skill guida la fase che precede lo sviluppo: dal documento grezzo del cliente fino ai deliverable pronti per il Metodo Villa (ROADMAP, PROJECT_CONFIG, schema DB).

## Filosofia

L'obiettivo è trasformare un'idea vaga o un documento di un cliente in un piano chiaro, condiviso e approvato, prima di scrivere una riga di codice. Il processo è iterativo: si produce, si mostra al cliente, si raccoglie feedback, si aggiorna. Il ciclo si ripete finché il cliente approva.

Lingua di default: **italiano**. Se l'utente comunica in inglese, adattarsi.

---

## Stato e Persistenza

Per non perdere il filo tra messaggi, mantieni un file **`discovery-state.md`** nella cartella di lavoro. Aggiornalo dopo ogni fase significativa. Struttura:

```markdown
# Discovery State — [Nome Progetto]
## Fase corrente: [1-9]
## Decisioni prese:
- [elenco decisioni chiave dall'intervista]
## Gap aperti:
- [domande ancora senza risposta]
## File prodotti:
- [lista file con percorsi]
## Prossimo passo:
- [cosa fare al prossimo messaggio]
```

Se la conversazione viene interrotta (limite contesto, nuova sessione), leggi `discovery-state.md` per riprendere da dove eri rimasto. Questo file è il tuo "handoff" interno.

---

## Workflow Completo

Il processo si articola in 9 fasi. Seguile in ordine, ma sii flessibile: se l'utente ha già fatto parte del lavoro (es. ha già un concept chiaro), salta le fasi coperte.

### Fase 1 — Input e Acquisizione

Raccogli tutto il materiale disponibile:
- Documenti del cliente (brief, email, PDF, appunti)
- Screenshot, mockup, riferimenti visivi
- Conversazioni precedenti (se il contesto è già nella chat)

**Cosa fare:**
1. Leggi ogni documento caricato dall'utente
2. Produci un **riassunto strutturato** (max 1 pagina) con: obiettivo del progetto, utenti target, funzionalità richieste, vincoli espliciti, punti ambigui
3. Salva il riassunto in `discovery-notes.md` (servirà come riferimento nelle fasi successive)
4. Presenta il riassunto all'utente e chiedi conferma prima di procedere

### Fase 2 — Analisi e Identificazione Gap

Analizza il materiale raccolto per trovare ciò che manca:
- Requisiti impliciti non esplicitati
- Contraddizioni tra documenti diversi
- Aspetti tecnici che il cliente potrebbe non aver considerato (scalabilità, sicurezza, integrazioni)
- Business logic non definita (cosa succede se...?)
- Tipologia di progetto (e-commerce, tool interno, SaaS, app mobile, sito vetrina, altro) — questo condiziona quali aree approfondire nell'intervista

Produci una **lista di gap** organizzata per area (UX, Business Logic, Tecnico, Integrazioni, Dati). Salva la lista in coda a `discovery-notes.md`. Questa lista guida le domande della Fase 3: non servono domande generiche su aree già coperte.

### Fase 3 — Intervista Strutturata

Questa è la fase più importante. L'intervista serve a colmare i gap e a far emergere requisiti che il cliente non sapeva di avere.

**Regole dell'intervista:**
- **Una domanda alla volta** — mai più di una domanda per messaggio
- **Contatore visibile** — mostra "Domanda 3/12" (aggiorna il totale man mano)
- **Motivazione** — spiega brevemente perché la domanda è importante
- **Opzioni suggerite** — quando possibile, offri 2-3 opzioni concrete con pro/contro
- **Adattamento** — se una risposta apre nuovi interrogativi, aggiungi domande al volo
- **Riepilogo periodico** — ogni 5 domande, fai un mini-riepilogo delle decisioni prese

**Ordine delle domande:**
1. Vision e obiettivi (perché questo progetto? cosa cambia se va bene?)
2. Utenti e ruoli (chi usa il sistema? con quali permessi?)
3. Funzionalità core (cosa DEVE fare il sistema al lancio?)
4. Flussi critici (i 3-5 percorsi utente più importanti)
5. Dati e integrazioni (quali dati esistono? quali sistemi esterni?)
6. Vincoli (budget, tempi, tecnologie obbligate, compliance)
7. Nice-to-have (cosa vorresti ma potresti rimandare?)

**Salvataggio risposte:** Dopo ogni risposta dell'utente, aggiorna `discovery-notes.md` con la decisione presa. Non affidarti solo alla memoria della conversazione — le risposte devono essere persistite. Se la conversazione si interrompe, le risposte salvate permettono di riprendere senza rifare l'intervista.

Per i dettagli e gli esempi di domande, leggi `references/interview-guide.md`.

### Fase 4 — Concept Document (Word .docx)

Dopo l'intervista, produci il **Concept Document** — il deliverable principale per il cliente.

**Struttura del documento** (leggi `references/concept-doc-template.md` per il template completo):

1. **Copertina** — Nome progetto, cliente, data, versione
2. **Executive Summary** — 1 paragrafo che spiega il progetto a chi non ha tempo
3. **Obiettivi e KPI** — Cosa si vuole ottenere e come si misura il successo
4. **Utenti e Ruoli** — Chi usa il sistema e cosa può fare
5. **Funzionalità** — Organizzate per modulo, con priorità (Must/Should/Could)
6. **Flussi Principali** — I percorsi utente chiave, descritti passo-passo
7. **Architettura di Massima** — Stack tecnologico proposto, diagramma componenti
8. **Piano di Massima** — Fasi, milestone, tempistiche indicative
9. **Rischi e Mitigazioni** — Cosa potrebbe andare storto e come prevenirlo
10. **Prossimi Passi** — Cosa serve per partire

**Formato:** Prima di creare il file, leggi la skill `docx` (il suo SKILL.md) per seguire le best practice di creazione. Il documento deve essere professionale ma leggibile da non-tecnici. Evita gergo tecnico dove possibile, o spiegalo. Se usi termini tecnici, aggiungi un glossario come appendice.

Presenta il documento all'utente per revisione prima di andare avanti.

### Fase 5 — Presentazione (PowerPoint .pptx)

Produci una **presentazione sintetica** per il cliente, derivata dal concept document.

**Quando produrla:** Di default, produci la presentazione solo DOPO che il concept document ha ricevuto almeno un primo giro di feedback (Fase 6). Questo evita di rifare due documenti. Tuttavia, se l'utente chiede esplicitamente la presentazione subito, producila — la flessibilità è più importante della procedura.

**Struttura slides** (leggi `references/presentation-template.md` per il template):

1. Titolo e sottotitolo
2. Il problema / l'opportunità (1-2 slide)
3. La soluzione proposta (2-3 slide)
4. Funzionalità chiave con visual (2-4 slide)
5. Architettura semplificata (1 slide)
6. Timeline e fasi (1 slide)
7. Prossimi passi (1 slide)

**Target:** max 12-15 slide. Il cliente deve poter capire il progetto in 10 minuti.

**Formato:** Prima di creare il file, leggi la skill `pptx` (il suo SKILL.md) per seguire le best practice di creazione. Design pulito, poco testo per slide, visual dove possibile.

### Fase 6 — Raccolta Feedback

Dopo che il cliente ha visto concept document e/o presentazione:

1. Chiedi feedback specifico, sezione per sezione
2. Per ogni feedback, classifica:
   - **Chiarimento** — il cliente ha capito male qualcosa, basta spiegare
   - **Modifica minore** — cambiamento che non impatta altro
   - **Modifica strutturale** — cambiamento che ha impatti a cascata
3. Per le modifiche strutturali, esegui l'analisi impatti (Fase 7) prima di applicare

### Fase 7 — Analisi Impatti a Cascata

Quando una modifica tocca un elemento che è collegato ad altri, analizza cosa cambia:

**Template di analisi:**
```
MODIFICA RICHIESTA: [descrizione]
IMPATTO DIRETTO: [sezioni/funzionalità direttamente modificate]
IMPATTI A CASCATA:
  → [Area 1]: [cosa cambia e perché]
  → [Area 2]: [cosa cambia e perché]
RISCHIO: [basso/medio/alto]
EFFORT AGGIUNTIVO: [stima]
RACCOMANDAZIONE: [procedere / discutere / alternativa proposta]
```

Presenta l'analisi all'utente prima di procedere con le modifiche.

### Fase 8 — Aggiornamento Documenti

Applica le modifiche approvate al concept document e alla presentazione. Per ogni ciclo di revisione:

1. Incrementa la versione del documento (v1.0 → v1.1 → v2.0 per modifiche strutturali)
2. Mantieni un changelog in fondo al concept document
3. Evidenzia le modifiche rispetto alla versione precedente nel messaggio all'utente
4. Aggiorna `discovery-state.md` con le decisioni cambiate

**Limite revisioni:** Dopo 3 cicli di feedback sullo stesso deliverable, segnala all'utente che potrebbe essere più efficiente fissare un incontro con il cliente per allinearsi dal vivo, e poi riportare le decisioni. Questo non è un blocco — se l'utente vuole continuare, continua.

### Fase 9 — Output per Sviluppo

Quando il cliente approva il concept finale, produci i file di avvio per il Metodo Villa:

1. **PROJECT_CONFIG.md** — Stack tecnologico, architettura, dipendenze, comandi essenziali. Segui lo stesso formato usato negli altri progetti Metodo Villa (vedi il PROJECT_CONFIG.md del progetto corrente come riferimento, se disponibile).
2. **ROADMAP.md** — Fasi di sviluppo con step e task concreti, derivati dalle funzionalità del concept. Ogni step deve avere: descrizione, file da creare/modificare, criterio di completamento. Questo è il file che il runner del Metodo Villa userà per l'esecuzione automatica.
3. **Schema DB iniziale** — Se emerso dall'intervista, uno schema Prisma (preferito) o SQL di partenza. Includi relazioni, indici principali e commenti che spiegano le scelte. Se il tipo di DB non è ancora deciso, produci un diagramma entità-relazione in formato testo.
4. **CLAUDE.md progetto** — Regole specifiche del progetto per Claude: stack vietato, decisioni architetturali fisse, regole business critiche, comandi essenziali. Segui la struttura del CLAUDE.md del Metodo Villa (sezione "Regole specifiche progetto").
5. **dev-shortcuts.md** — File vuoto con intestazione, pronto per registrare scorciatoie di sviluppo durante la fase di coding.

Questi file vanno nella root del nuovo progetto e sono il punto di partenza per il runner del Metodo Villa. Prima di generarli, chiedi all'utente dove vuole creare la cartella del nuovo progetto.

---

## File Prodotti durante il Processo

Durante la discovery, vengono creati questi file nella cartella di lavoro:

| Fase | File | Scopo |
|------|------|-------|
| 1-2 | `discovery-notes.md` | Riassunto iniziale + gap + risposte intervista |
| 1-9 | `discovery-state.md` | Stato corrente del processo (per ripresa sessione) |
| 4 | `[nome]-concept-v1.0.docx` | Concept document per il cliente |
| 5 | `[nome]-presentazione-v1.0.pptx` | Presentazione per il cliente |
| 9 | `PROJECT_CONFIG.md`, `ROADMAP.md`, `CLAUDE.md`, `schema.prisma`, `dev-shortcuts.md` | File di avvio sviluppo |

## Note Operative

- **Non saltare la conferma utente** dopo ogni fase principale (riassunto, intervista, concept, feedback)
- **Tono professionale ma accessibile** — il cliente potrebbe non essere tecnico
- **Quando in dubbio, chiedi** — meglio una domanda in più che un'assunzione sbagliata
- **Versioning** — ogni deliverable ha un numero di versione, sempre visibile
- **File naming** — `[nome-progetto]-concept-v1.0.docx`, `[nome-progetto]-presentazione-v1.0.pptx`
- **Dipendenze skill** — questa skill usa le skill `docx` e `pptx` per produrre i file. Leggi i rispettivi SKILL.md PRIMA di creare i documenti.

---

## Riferimenti

- `references/interview-guide.md` — Domande tipo per ogni area, con motivazioni e opzioni suggerite
- `references/concept-doc-template.md` — Template dettagliato del concept document
- `references/presentation-template.md` — Template dettagliato della presentazione
