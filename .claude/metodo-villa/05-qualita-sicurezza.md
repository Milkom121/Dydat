# Standard di Qualità e Sicurezza del Codice + Sicurezza di Sistema

## Regole preventive — come Claude deve scrivere il codice

### Sicurezza:

- Mai inserire credenziali, API key o segreti nel codice sorgente — usare variabili d'ambiente via `.env`. **ECCEZIONE**: in fase di sviluppo attivo è permesso per velocità, ma DEVE essere registrato nel file `docs/dev-shortcuts.md`
- Sempre sanitizzare gli input dell'utente prima di processarli
- Sempre usare query parametrizzate per il database (mai concatenare stringhe SQL)
- Gestire autenticazione e autorizzazione in modo esplicito — mai assumere che il client sia affidabile
- Mai fidarsi dei dati che arrivano dal client/browser
- Validare i dati sia lato client che lato server

SQL injection: solo query parametrizzate, mai concatenazione stringhe.

Input Mai Fidato.

### Robustezza:

- Ogni funzione deve gestire i casi di errore (input nullo, rete assente, timeout, dati malformati)
- Funzioni corte e con un solo scopo
- Nomi di variabili e funzioni autoesplicativi (in inglese, come da convenzione)
- Nessuna duplicazione di codice — se una logica si ripete, estrarre in funzione riutilizzabile
- Gestione esplicita delle Promise/async con try-catch
- Placeholder espliciti per funzionalità non ancora implementate: signature + docstring + `raise NotImplementedError` (o equivalente nel linguaggio), mai implementazioni vuote silenziose

Signature + docstring + `raise NotImplementedError`, mai implementazioni vuote silenziose.

Mai `unwrap()` o `expect()` nel codice di produzione — usare `?` o match.

### Manutenibilità:

- Le funzioni dovrebbero tendenzialmente stare sotto le 50 righe. Se una funzione supera questa soglia, Claude deve valutare se è ragionevolmente spezzabile in sotto-funzioni. Se lo è, la spezza. Se non lo è (perché il flusso è intrinsecamente sequenziale e spezzarlo peggiorerebbe la leggibilità), la mantiene così ma aggiunge un commento che spiega perché la funzione è più lunga del normale.
- Separazione chiara tra logica, dati e interfaccia (vedi architettura a layer)
- Commenti in italiano che spiegano il "perché", non il "cosa"
- Struttura del codice coerente con il resto del progetto — leggere i file esistenti PRIMA di scrivere codice nuovo
- Se un file supera le 500 righe, valutare se spezzarlo (ma solo se fa parte del blocco corrente)

## Guardiano di blocco — auto-review a fine sessione

Prima di chiudere ogni sessione, Claude deve fare un'auto-review rapida del codice scritto nella sessione, verificando:

- [ ] Input sanitizzati dove necessario
- [ ] Errori gestiti (try-catch, error handling, fallback)
- [ ] Nessun segreto hardcoded non registrato in `docs/dev-shortcuts.md`
- [ ] Funzioni tendenzialmente sotto le 50 righe (se superano, giustificato con commento)
- [ ] Nessuna duplicazione introdotta
- [ ] Nomi chiari e coerenti con il resto del progetto

Il risultato va nel report di fine sessione. Se una voce non passa, Claude lo segnala esplicitamente nel handoff — non nasconde i problemi.

## Guardiano di fase — review approfondita prima della PR su main

Prima della PR da `develop` verso `main`, Claude deve fare una review completa e strutturata:

- **Architettura**: il codice rispetta il design iniziale? I layer comunicano correttamente?
- **Sicurezza**: superficie di attacco, flussi di autenticazione, gestione dati sensibili, `docs/dev-shortcuts.md` pulito
- **Coerenza**: il nuovo codice si integra bene col resto della codebase? Naming, stile, pattern rispettati?
- **Performance**: query N+1, memory leak, operazioni bloccanti sul thread principale
- **Usare `/security-review`** integrato in Claude Code (gratuito) per un'analisi automatizzata

Il report del guardiano di fase va nella PR come commento, in modo che Villa possa leggerlo prima di autorizzare il merge.

## Sicurezza di sistema — Non installare NULLA a livello di sistema

**Non installare NULLA a livello di sistema.** Tutto deve essere isolato e rimovibile cancellando una singola cartella.

### Cosa NON fare MAI (universale):

- NON fare `pip install` globali — usare sempre un venv locale
- NON modificare variabili d'ambiente di sistema (PATH, CUDA_HOME, ecc.)
- NON installare o aggiornare driver
- NON toccare il Python/Node/runtime di sistema
- NON installare pacchetti npm globali
- NON modificare il registry di Windows
- NON creare servizi Windows o task schedulati di sistema

### Cosa fare SEMPRE:

- Usare versioni portable/standalone quando possibile
- Tenere tutto dentro la cartella del progetto
- Se servono dipendenze, creare un venv locale dentro la repo
- Verificare i prerequisiti in modo **read-only** — solo controllare, mai modificare

Questa regola è eccellente e dovrebbe essere copiata verbatim nel Metodo Villa globale. Si applica a QUALSIASI progetto.

## Compressione contesto e sessioni lunghe

**Configurazione**: compressione automatica al 50% della context window.
Se il contesto si avvicina al limite, dare priorità al mantenere: il blocco corrente, i file modificati, i risultati dei test.

**IMPORTANT**: Quando compatti o il contesto viene compresso, preserva SEMPRE:
- Numero del blocco corrente e cosa stai facendo
- Lista dei file modificati/creati nella sessione
- Problemi aperti e decisioni prese con l'utente

**Regola unificata per la compattazione** — preservare SEMPRE:

1. Numero del blocco corrente e obiettivo
2. Lista dei file modificati/creati nella sessione
3. Risultati dei test (passano? falliscono? quali?)
4. Problemi aperti e decisioni prese con l'utente
5. Stack tecnologico e vincoli hard del progetto
