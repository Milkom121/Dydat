# ROADMAP OPERATIVA - PROGETTO DYDAT

*Questo documento è generato e mantenuto da un agente AI per tracciare il progresso dello sviluppo. Viene aggiornato dopo il completamento di ogni task significativo.*

## 🎯 OBIETTIVO STRATEGICO
L'obiettivo è costruire la piattaforma Dydat, un ecosistema di apprendimento AI-driven, partendo da fondamenta solide basate su un'infrastruttura cloud moderna, un'architettura a microservizi e un flusso di lavoro DevOps completamente automatizzato. L'approccio mira a massimizzare la velocità di sviluppo e la qualità del software, consentendo iterazioni rapide e deploy continui.

## 🧪 REGOLA FONDAMENTALE: TESTING OBBLIGATORIO
⚠️ CRITICO: Dopo ogni completamento di task di sviluppo, eseguire test automatici accurati PRIMA di procedere al task successivo!

### Protocollo di Testing per ogni Task:
1. Test Funzionale: Verificare che la feature funzioni come specificato
2. Test Edge Cases: Testare scenari limite e input non validi  
3. Test Integration: Verificare che non rompa funzionalità esistenti
4. Test UX: Controllare che l'esperienza utente sia fluida
5. Test Performance: Verificare che non degradi le performance
6. Documentazione: Aggiornare eventuali docs/esempi

❌ Non procedere MAI al task successivo senza aver completato tutti i test del task corrente!

## 📝 TRACKING E DOCUMENTAZIONE
🔄 PROCESSO: Dopo ogni task completato, aggiornare questo file con:

### Status Update per ogni Task:
```
✅ [COMPLETATO] Task X.X.X: Nome Task
📅 Data: [DATA COMPLETAMENTO]
👤 Implementato da: [CHI]
🧪 Test Status: [PASSED/FAILED/PARTIAL]

📊 Report Breve:
- Cosa è stato implementato
- Funzionalità chiave aggiunte
- Test eseguiti e risultati
- Issues/limitazioni identificate
- Note per future implementazioni

📂 File Modificati:
- /path/to/file1
- /path/to/file2

🎯 Pronto per: [PROSSIMO TASK]
```

⚠️ Mantenere sempre questo file aggiornato per tracking accurato del progresso!

---

## 🚀 STATO CORRENTE IMPLEMENTAZIONE

### 📍 POSIZIONE ATTUALE:
- **Milestone:** 1 - Fondamenta Tecniche e Operative
- **Fase:** 0 - DevOps, Infrastruttura e CI/CD
- **Task Corrente:** Completamento della Fase 0.
- **Status:** <span style="color:green">**FASE 0 COMPLETATA**</span>

### 📈 PROGRESSO OVERALL:
- **Completati:** 1/4 fasi principali (25%)
- **Prossimo:** Fase 1 - Sviluppo del MVP di Dydat Public

### 🏆 TASK COMPLETATI RECENTI:
- **Task 0.5**: Implementazione del workflow di deploy su Pull Request. `COMPLETATO`
- **Task 0.4**: Configurazione e deploy su cluster EKS. `COMPLETATO`
- **Task 0.3**: Containerizzazione delle applicazioni (Docker). `COMPLETATO`
- **Task 0.2**: Creazione dell'infrastruttura su AWS (Terraform). `COMPLETATO`
- **Task 0.1**: Scaffolding del Monorepo (pnpm, NestJS, Next.js). `COMPLETATO`

---

## 📋 MILESTONES E FASI

### ✔️ MILESTONE 1: Fondamenta Tecniche e Operative
*Timeline: 2 Settimane | Obiettivo: Creare una "catena di montaggio" automatizzata per massimizzare la velocità di sviluppo.*

- **FASE 0: DevOps, Infrastruttura e CI/CD** → <span style="color:green">**COMPLETATA**</span>
  - **Task 0.1: Scaffolding Monorepo** → ✅ `COMPLETATO`
    - Creazione di un monorepo gestito con `pnpm`.
    - Scaffolding dell'applicazione backend in `apps/backend` con NestJS e TypeScript.
    - Scaffolding dell'applicazione frontend in `apps/frontend` con Next.js e TypeScript.
  - **Task 0.2: Infrastruttura come Codice (IaC) con Terraform** → ✅ `COMPLETATO`
    - Creazione di una VPC dedicata con subnet pubbliche e private.
    - Provisioning di un cluster Amazon EKS (`dydat-main-cluster`).
    - Provisioning di un Node Group EKS per le istanze di calcolo.
    - Creazione dei repository su Amazon ECR (`dydat-backend`, `dydat-frontend`) per le immagini Docker.
  - **Task 0.3: Containerizzazione con Docker** → ✅ `COMPLETATO`
    - Creazione di `Dockerfile` multi-stage ottimizzati per backend e frontend.
    - Creazione di un file `.dockerignore` per ottimizzare il contesto di build.
  - **Task 0.4: Deploy Iniziale su Kubernetes** → ✅ `COMPLETATO`
    - Creazione dei manifesti Kubernetes (`deployment.yaml`, `service.yaml`) per entrambe le applicazioni.
    - Configurazione dei servizi per esporre le applicazioni (LoadBalancer per il frontend).
    - Deploy manuale iniziale per validare il funzionamento sul cluster EKS.
  - **Task 0.5: Pipeline CI/CD con GitHub Actions** → ✅ `COMPLETATO`
    - **Continuous Integration (CI):** Creazione del workflow `pr-check.yml` che, su ogni Pull Request, installa le dipendenze ed esegue la build di entrambi i progetti per validare il codice.
    - **Continuous Deployment (CD):** Creazione del workflow `cd.yml` che, al merge su `main`, esegue i seguenti passaggi:
      1. Si autentica su AWS ECR.
      2. Costruisce le immagini Docker per backend e frontend.
      3. Le carica (push) sui rispettivi repository ECR con il tag `latest`.
      4. Si autentica sul cluster EKS.
      5. Esegue un `rollout restart` dei deployment, forzando Kubernetes a scaricare e utilizzare le nuove immagini.

---

### 🔹 MILESTONE 2: Sviluppo del MVP di Dydat Public
*Timeline: 6 Mesi | Obiettivo: Costruire sequenzialmente la versione pubblica della piattaforma.*

- **FASE 1: Nucleo Utenti e Autenticazione** → ⬜ `DA INIZIARE`
  - **Task 1.1: Setup Database e ORM**
    - Aggiungere al Terraform la creazione di un database PostgreSQL (AWS RDS).
    - Configurare TypeORM nel backend NestJS per la connessione al database.
  - **Task 1.2: Sviluppo Modulo Utenti (Backend)**
    - Creare l'entità `User` con TypeORM.
    - Implementare il servizio `UsersService` con la logica CRUD.
    - Implementare il controller `UsersController` con gli endpoint API.
  - **Task 1.3: Sviluppo Modulo Autenticazione (Backend)**
    - Implementare la logica di registrazione con hashing delle password (bcrypt).
    - Implementare la logica di login con generazione di token JWT.
    - Creare le guardie (`guards`) per proteggere gli endpoint.
  - **Task 1.4: Pagine di Autenticazione (Frontend)**
    - Creare la pagina e il form di Registrazione.
    - Creare la pagina e il form di Login.
    - Implementare la logica per chiamare le API di backend.
    - Gestire i token JWT (salvataggio sicuro e invio nelle richieste successive).
  - **Task 1.5: Routing Protetto (Frontend)**
    - Creare una pagina "Dashboard" o "Profilo" accessibile solo agli utenti loggati.
    - Implementare un sistema di routing che ridirezioni gli utenti non autenticati alla pagina di login.

- **FASE 2: Catalogo e Creazione Corsi** → ⬜ `DA INIZIARE`
  - ... (dettagli da definire)

- **FASE 3: Apprendimento, Progresso e Gamification** → ⬜ `DA INIZIARE`
  - ... (dettagli da definire)

- **FASE 4: Monetizzazione con Stripe** → ⬜ `DA INIZIARE`
  - ... (dettagli da definire)

- **FASE 5: Stabilizzazione MVP e Testing E2E** → ⬜ `DA INIZIARE`
  - ... (dettagli da definire)

---

*Ultimo aggiornamento: 06 luglio 2025*

## 📊 SUMMARY & TIMELINE

Totale: [DURATA TOTALE]

🎯 SUCCESS METRICS

🔄 DELIVERY APPROACH

- Sprint Length: [DURATA SPRINT]
- Demo Frequency: [FREQUENZA DEMO]
- Testing Strategy: [STRATEGIA TEST]
- Deployment: [STRATEGIA DEPLOYMENT]

---

*Generated by Template @ [DATA]*
