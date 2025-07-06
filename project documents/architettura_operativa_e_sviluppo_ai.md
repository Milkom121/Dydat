Dydat: Architettura Operativa e Strategia di Sviluppo AI-Driven
Versione: 1.0
Data: 05 luglio 2025

## 1. Introduzione e Filosofia

Questo documento descrive l'architettura operativa e la strategia di sviluppo per la piattaforma Dydat. Fa da ponte tra il "cosa" vogliamo costruire (descritto nel `documento_descrittivo_generale.md`) e il "come" lo costruiremo a livello tecnico (dettagliato nella `roadmap_generale.md` e nella `Fase0_DevOps.md`).

La nostra filosofia si basa su un principio fondamentale: la **Simbiosi Uomo-Macchina**. Un orchestratore umano definisce la strategia, l'architettura e gli obiettivi di alto livello, mentre un **Agente di Coding AI** si occupa dell'implementazione, della scrittura del codice, dei test e del deploy, il tutto accelerato da una robusta infrastruttura di automazione (CI/CD).

Questo approccio ci permette di massimizzare la velocità e la qualità, concentrando l'intelligenza umana sulla visione strategica e delegando l'esecuzione tecnica all'AI.

## 2. L'Agente di Coding AI

L'agente non è un singolo strumento, ma un sistema composto da un motore cognitivo e da un set di tool specializzati che gli permettono di interagire con l'ambiente di sviluppo.

### 2.1. Motore Cognitivo (LLM Provider)

Il cuore dell'agente è un Large Language Model (LLM) di ultima generazione. La scelta del provider è fondamentale e deve basarsi su tre criteri chiave:

1.  **Capacità di Ragionamento e Istruzioni Complesse:** L'LLM deve essere in grado di comprendere istruzioni astratte e di scomporle in passaggi tecnici concreti.
2.  **Ampia Finestra di Contesto:** Per mantere una comprensione profonda del codice e della documentazione esistente.
3.  **Affidabilità nell'Uso di Tool (Function Calling):** La capacità di usare strumenti esterni in modo preciso è il requisito più importante.

**Scelta Operativa:** Inizieremo utilizzando un modello di punta fornito da provider come **Anthropic (serie Claude 3)** o **OpenAI (serie GPT-4)**. L'architettura dell'agente sarà progettata in modo **agnostico rispetto al provider**: creeremo un "livello di astrazione" che ci permetterà di cambiare l'LLM sottostante con il minimo impatto, per poter sempre sfruttare la tecnologia migliore disponibile sul mercato.

### 2.2. Struttura e Toolkit dell'Agente

L'agente opererà all'interno di un ambiente controllato con accesso a un set di strumenti (tool) fondamentali che dovremo sviluppare o configurare. Questi tool sono le sue "mani" per interagire con il nostro progetto.

**Toolkit Essenziale da Sviluppare/Configurare:**

*   **Accesso al File System (`read`, `write`, `list`):** Lo strumento più basilare. L'agente deve poter leggere i file esistenti, scrivere nuovo codice e creare nuovi file/directory.
*   **Esecuzione di Comandi Terminale (`run_terminal_cmd`):** Fondamentale per interagire con l'ambiente di sviluppo. Questo tool verrà usato per:
    *   Gestire il controllo di versione (`git clone`, `git add`, `git commit`, `git push`).
    *   Installare dipendenze (`npm install`).
    *   Eseguire script di progetto (`npm run dev`, `npm run test`).
    *   Interagire con l'infrastruttura come codice (`terraform plan`, `terraform apply`).
    *   **Nota di Sicurezza:** Ogni comando proposto dall'agente richiederà un'approvazione esplicita da parte dell'orchestratore umano prima dell'esecuzione.
*   **Ricerca Codice (`codebase_search`, `grep_search`):** Per permettere all'agente di navigare autonomamente nella codebase, trovare definizioni di funzioni, implementazioni di interfacce o utilizzi di variabili.
*   **Ricerca Web (`web_search`):** Essenziale per permettere all'agente di cercare documentazione aggiornata su librerie, API di terze parti (es. Stripe, AWS SDK) o risolvere errori imprevisti.

## 3. Architettura Organizzativa dei Componenti

Per mantenere l'ordine e la manutenibilità, la struttura del progetto seguirà una chiara separazione delle responsabilità, sia a livello di repository che di servizi.

### 3.1. Strategia dei Repository

Inizialmente era stata valutata una strategia multi-repository. Tuttavia, per massimizzare la coerenza e la velocità di sviluppo per un agente AI, abbiamo optato per un approccio **Monorepo**.

Tutto il codice della piattaforma risiederà in un unico repository (`dydat`), gestito con strumenti moderni come pnpm workspaces e Turborepo.

La struttura sarà la seguente:
1.  **`dydat/apps`**: Conterrà le applicazioni eseguibili.
    *   `backend`: Il progetto NestJS.
    *   `frontend`: Il progetto Next.js.
2.  **`dydat/packages`**: Conterrà il codice condiviso tra le applicazioni.
    *   `common-types`: Definizioni TypeScript e interfacce condivise.
    *   `eslint-config-custom`: Configurazioni di linting riutilizzabili.
    *   `ui`: Componenti React condivisi (es. bottoni, card).
3.  **`dydat/infra`**: Verrà creata una cartella `infra` alla radice per contenere il codice per l'Infrastruttura come Codice (Terraform).

Questo approccio facilita i commit atomici, la condivisione dei tipi e una visione olistica dell'intera codebase.

### 3.2. Decomposizione dei Servizi Backend

Il backend sarà progettato come un'architettura a microservizi (o moduli logicamente separati), ognuno con una responsabilità specifica. La comunicazione tra i servizi avverrà tramite:
*   **API REST/gRPC (Sincrona):** Per richieste dirette e immediate (es. il frontend che chiede al backend il profilo utente).
*   **Message Broker - RabbitMQ (Asincrona):** Per disaccoppiare i servizi e gestire operazioni lunghe o che non richiedono una risposta immediata (es. quando un utente completa un corso, il servizio "Progressi" pubblica un evento `course_completed`, e il servizio "Gamification" lo ascolta per assegnare XP e Badge).

I servizi principali saranno:
*   **API Gateway:** Unico punto di ingresso per tutte le richieste esterne.
*   **Servizio Utenti & Autenticazione:** Gestisce registrazioni, login, profili, permessi.
*   **Servizio Catalogo Corsi:** Gestisce la creazione, lettura e aggiornamento dei corsi e delle lezioni.
*   **Servizio Iscrizioni & Progressi:** Traccia a quali corsi un utente è iscritto e il suo stato di avanzamento.
*   **Servizio Gamification:** Gestisce XP, livelli, badge, neuroni e classifiche.
*   **Servizio Pagamenti:** Integra Stripe per la gestione degli acquisti.
*   **Layer AI:** Un servizio specializzato (scritto in Python/FastAPI) che orchestra le chiamate agli LLM, gestisce il Vector DB per il RAG e fornisce le funzionalità AI.
*   **Layer Blockchain:** Un servizio isolato che gestisce i wallet, l'interazione con gli smart contract e l'archiviazione su IPFS per i certificati NFT.

## 4. Flusso di Lavoro Operativo

Il ciclo di sviluppo seguirà un "balletto" coordinato tra l'Orchestratore, l'Agente e la Pipeline CI/CD.

1.  **Definizione del Task (Orchestratore):** L'orchestratore umano prende un obiettivo dalla `roadmap_generale.md` (es. "Implementa la logica di registrazione").
2.  **Meta-Prompt (Orchestratore -> Agente):** L'orchestratore traduce l'obiettivo in un'istruzione dettagliata (meta-prompt) per l'agente. Esempio: "Nel servizio `Utenti & Autenticazione`, crea un endpoint `POST /auth/register`. Deve accettare email e password. La password deve essere sottoposta a hashing con bcrypt prima di salvarla nel database. Utilizza l'entità `User` di TypeORM. Crea i test unitari per questo servizio."
3.  **Esecuzione (Agente):** L'agente AI:
    a. Usa `read` e `codebase_search` per analizzare il codice esistente.
    b. Usa `write` per creare/modificare i file necessari (controller, service, DTO, test).
    c. Usa `run_terminal_cmd` per installare eventuali dipendenze (es. `npm install bcrypt`) e per eseguire i test (`npm run test`).
    d. Se i test passano, usa `run_terminal_cmd` per committare il codice (`git add .`, `git commit ...`).
4.  **Automazione e Feedback (Pipeline CI/CD):** Non appena il codice viene committato, la pipeline di GitHub Actions si attiva automaticamente. Esegue linter, test, build dell'immagine Docker e deploy nell'ambiente di staging.
5.  **Verifica (Orchestratore):** L'orchestratore riceve una notifica di deploy avvenuto con successo e può verificare la nuova funzionalità nell'ambiente di staging.

Questo ciclo continuo, che va dall'istruzione al deploy in pochi minuti, è il cuore della nostra strategia di sviluppo AI-Driven e l'obiettivo primario della Fase 0. 