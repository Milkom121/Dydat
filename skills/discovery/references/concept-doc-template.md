# Template — Concept Document

Questo template definisce la struttura del concept document da produrre in formato .docx usando la skill `docx`.

## Specifiche Documento

- **Formato**: .docx (usa la skill docx per la creazione)
- **Font**: Calibri o simile, corpo 11pt, titoli 14-18pt
- **Margini**: 2.5cm su tutti i lati
- **Intestazione**: Nome progetto + versione su ogni pagina
- **Piè di pagina**: Numero pagina
- **Naming**: `[nome-progetto]-concept-v[X.Y].docx`

## Struttura Sezioni

### 1. Copertina (1 pagina)

```
[NOME PROGETTO]
Concept Document

Cliente: [nome cliente]
Versione: v1.0
Data: [data]
Preparato da: [nome]
```

Stile: centrato, pulito, professionale. No grafica eccessiva.

### 2. Executive Summary (½ pagina)

Un singolo paragrafo che risponde a:
- Cos'è il progetto?
- Quale problema risolve?
- Chi lo userà?
- Qual è il risultato atteso?

Scrivi come se il lettore avesse solo 30 secondi. Evita tecnicismi.

### 3. Obiettivi e KPI (½-1 pagina)

Tabella a due colonne:

| Obiettivo | KPI / Metrica |
|-----------|---------------|
| Ridurre tempi di gestione ordini | Da 15 min a 3 min per ordine |
| Aumentare prenotazioni online | +30% nel primo trimestre |

Ogni obiettivo deve essere misurabile. Se il cliente non ha definito KPI, proponi metriche ragionevoli.

### 4. Utenti e Ruoli (½-1 pagina)

Per ogni ruolo utente:
- **Nome ruolo**
- **Descrizione**: chi è, in che contesto usa il sistema
- **Azioni principali**: cosa può fare
- **Restrizioni**: cosa NON può fare

Formato consigliato: una sottosezione per ruolo, oppure tabella se i ruoli sono semplici.

### 5. Funzionalità (2-4 pagine)

Organizza per modulo/area funzionale. Per ogni funzionalità:

**[Nome Funzionalità]** — Priorità: Must/Should/Could

Descrizione in 2-3 frasi di cosa fa. Scrivi dal punto di vista dell'utente ("L'operatore può..."), non dal punto di vista tecnico ("Il sistema espone un endpoint...").

Se ci sono regole di business particolari, aggiungile come sotto-punto.

### 6. Flussi Principali (1-2 pagine)

Per ogni flusso critico (3-5 flussi):

**Flusso: [Nome]** (es. "Prenotazione tavolo")

1. L'utente apre l'app e seleziona la data
2. Il sistema mostra le disponibilità
3. L'utente sceglie orario e numero persone
4. Il sistema verifica la capienza
5. L'utente conferma → notifica email/push
6. L'operatore vede la prenotazione nella dashboard

Note: descrivi anche il caso di errore principale (es. "Se non ci sono posti disponibili...").

### 7. Architettura di Massima (1 pagina)

Non un progetto tecnico dettagliato, ma una vista d'insieme:
- **Frontend**: Web? Mobile? Entrambi? Quale tecnologia?
- **Backend**: API? Monolite? Microservizi?
- **Database**: Relazionale? Che tipo di dati?
- **Servizi esterni**: Pagamenti? Email? Push? Mappe?

Se possibile, includi un diagramma a blocchi semplice (descrivi i componenti e le connessioni, la skill docx può inserire un'immagine se disponibile).

### 8. Piano di Massima (1 pagina)

Tabella con fasi:

| Fase | Descrizione | Durata Stimata | Deliverable |
|------|-------------|----------------|-------------|
| 1 - Setup | Struttura progetto, DB, auth | 1-2 settimane | Backend base funzionante |
| 2 - Core | Funzionalità Must | 3-4 settimane | MVP funzionante |
| 3 - Completamento | Funzionalità Should | 2-3 settimane | Versione completa |
| 4 - Testing e Launch | Test, fix, deploy | 1-2 settimane | Produzione |

Le stime sono indicative. Aggiungi una nota che saranno raffinate dopo il concept.

### 9. Rischi e Mitigazioni (½ pagina)

Tabella:

| Rischio | Probabilità | Impatto | Mitigazione |
|---------|-------------|---------|-------------|
| Requisiti non chiari su X | Media | Alto | Prototipo rapido per validare |
| Integrazione con sistema Y complessa | Alta | Medio | Mockup iniziale, integrazione in fase dedicata |

Includi almeno 3-5 rischi realistici, non generici.

### 10. Prossimi Passi (½ pagina)

Lista di azioni concrete:
1. Approvazione concept da parte del cliente
2. Setup progetto e ambiente di sviluppo
3. Inizio Fase 1 — [descrizione]
4. Primo checkpoint dopo [tempo]

### 11. Glossario (opzionale, se si usano termini tecnici)

Tabella:

| Termine | Significato |
|---------|-------------|
| API | Interfaccia che permette a due software di comunicare tra loro |
| MVP | Minimum Viable Product — la versione minima del prodotto con solo le funzionalità essenziali |
| Backend | La parte del sistema che gira sul server, non visibile all'utente |

Includi solo i termini effettivamente usati nel documento. Se il cliente è tecnico e li conosce, ometti questa sezione.

### 12. Changelog (in fondo, dopo le revisioni)

| Versione | Data | Modifiche |
|----------|------|-----------|
| v1.0 | [data] | Prima versione |
| v1.1 | [data] | Aggiunto modulo X su richiesta cliente |

---

## Note di Stile

- **Tono**: professionale ma comprensibile. Il documento potrebbe essere letto da un CEO non tecnico.
- **Lunghezza**: 8-15 pagine ideali. Sotto le 8 probabilmente manca qualcosa, sopra le 15 è troppo verboso.
- **Visual**: usa tabelle per dati strutturati, evita wall of text.
- **Coerenza**: mantieni gli stessi termini in tutto il documento (se chiami "operatore" un ruolo, non chiamarlo "staff" altrove).
