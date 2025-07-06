Dydat: Roadmap Operativa per Sviluppo AI-Driven
Versione: 1.0 (AI-Driven)
Data: 05 luglio 2025

Introduzione
Questo documento delinea il piano di sviluppo operativo per la piattaforma Dydat, strutturato specificamente per un flusso di lavoro guidato da un agente di coding AI (come Cursor). L'Orchestratore (l'utente umano) fornirà all'agente una sequenza di istruzioni (meta-prompt) per costruire la piattaforma in modo iterativo e sequenziale. Ogni sprint dura 2 settimane.

Fase 0: Fondamenta Lean per Sviluppo AI-Driven (Durata: 2 Settimane / 1 Sprint)
Obiettivo Generale: Creare una "catena di montaggio" automatizzata e minimale per massimizzare la velocità dell'agente AI, permettendo test e deploy rapidi e continui.

Sprint 0.1 (Settimane 1-2)
Focus Primario dell'Agente: DevOps & Setup

Istruzioni/Meta-Prompts per l'Agente AI:

Infrastruttura come Codice (IaC): "Utilizzando Terraform, genera gli script per creare l'infrastruttura cloud essenziale su AWS: un database PostgreSQL gestito (RDS), un servizio per eseguire container serverless (Fargate), uno storage per file (S3) e un registro privato per le immagini Docker (ECR)."

Pipeline CI/CD Essenziale: "Crea una pipeline base su GitHub Actions. La pipeline deve attivarsi a ogni push, eseguire i test, costruire un'immagine Docker e fare il deploy del servizio sull'ambiente Fargate di test."

Scaffolding dei Progetti: "Crea due repository Git. Nel primo, genera lo scaffolding di un'applicazione frontend con Next.js e TypeScript. Nel secondo, genera lo scaffolding di un microservizio backend con NestJS e TypeScript, già configurato per connettersi al database PostgreSQL."

Contratto API Iniziale: "Definisci un file openapi.yaml nel repository backend per descrivere gli endpoint iniziali del servizio Utenti (es. POST /register, POST /login, GET /me)."

Deliverable Verificabile: Un'infrastruttura base è attiva. Una modifica al codice in uno dei repository triggera con successo una pipeline che esegue test e deploy nell'ambiente di test.

Fase 1: Sviluppo del MVP di Dydat Public (Durata: 6 Mesi / 12 Sprint)
Obiettivo Generale: Costruire sequenzialmente la versione pubblica della piattaforma, validando ogni componente prima di passare al successivo.

Sprint 1.1 - 1.2: Nucleo Utenti e Autenticazione (4 settimane)
Focus Primario dell'Agente: Core Backend, Frontend.

Istruzioni per l'Agente AI:

(Backend): "Implementa la logica del Servizio Utenti & Autenticazione in NestJS. Crea le entità del database, la logica di registrazione con hashing delle password, il login con generazione di token JWT e gli endpoint API definiti nel contratto OpenAPI."

(Frontend): "Crea le pagine di Registrazione e Login in React. Implementa la logica per chiamare le API di backend, gestire i token JWT (salvandoli in modo sicuro) e implementa un sistema di routing protetto per le pagine private."

Deliverable Verificabile: Un utente può creare un account, effettuare il login e accedere a una pagina "dashboard" protetta.

Sprint 1.3 - 1.4: Catalogo e Creazione Corsi (4 settimane)
Focus Primario dell'Agente: Core Backend, Frontend.

Istruzioni per l'Agente AI:

(Backend): "Crea il Servizio Catalogo Corsi (v1). Definisci le tabelle per corsi e lezioni. Implementa le API CRUD per i creator per gestire i loro corsi. Integra il servizio con S3 per l'upload dei video."

(Frontend): "Sviluppa le pagine pubbliche del Catalogo e del Dettaglio Corso. Crea l'interfaccia dello Studio di Creazione Corsi per permettere ai creator di compilare i form, definire la struttura e caricare i video."

Deliverable Verificabile: Un utente "creator" può creare un corso completo di lezioni e video. Qualsiasi utente può sfogliare il catalogo.

Sprint 1.5 - 1.8: Apprendimento, Progresso e Gamification (8 settimane)
Focus Primario dell'Agente: Core Backend, Frontend, AI.

Istruzioni per l'Agente AI:

(Backend): "Sviluppa il Servizio Iscrizioni & Progressi e il Servizio Gamification (v1) per XP/Livelli, facendoli comunicare in modo asincrono tramite il Message Broker."

(AI): "Sviluppa il Layer AI (v1) con il RAG Globale sui contenuti dei corsi e l'API per il Q&A dell'AI Companion."

(Frontend): "Sviluppa il Player Lezione interattivo, la dashboard "I miei corsi" e integra la visualizzazione di XP/Livelli e il box di chat dell'AI Companion."

Deliverable Verificabile: Uno studente può iscriversi a un corso, seguirlo, vedere i suoi progressi e il suo livello aumentare, e porre domande all'AI.

Sprint 1.9 - 1.10: Monetizzazione (4 settimane)
Focus Primario dell'Agente: Core Backend, Frontend.

Istruzioni per l'Agente AI:

(Backend): "Sviluppa il Servizio Pagamenti integrando l'SDK di Stripe per gestire gli acquisti singoli."

(Frontend): "Sviluppa il carrello e il flusso di checkout completo, dalla pagina del corso fino alla conferma del pagamento."

Deliverable Verificabile: Un utente può completare l'acquisto di un corso a pagamento.

Sprint 1.11 - 1.12: Stabilizzazione MVP (4 settimane)
Focus Primario dell'Agente: Testing, Ottimizzazione.

Istruzioni per l'Agente AI:

"Analizza l'intera codebase e genera test di integrazione e test E2E (con Cypress) per coprire i flussi utente principali (registrazione, acquisto, fruizione)."

"Esegui test di carico (usando k6 o simili) sugli endpoint critici e identifica i colli di bottiglia. Ottimizza le query del database e implementa strategie di caching con Redis dove necessario."

Deliverable Verificabile: La piattaforma è stabile, testata e pronta per un lancio controllato.

Fase 2: Espansione (Durata: 6 Mesi / 12 Sprint)
Sprint 2.1 - 2.3: Dydat Scholar e Suite di Apprendimento (6 settimane)
Focus Primario dell'Agente: Core Backend, AI, Frontend.

Istruzioni per l'Agente AI:

(Backend/AI): "Estendi il Servizio Utenti per gestire Istituti e Classi. Implementa il RAG Personale nel Layer AI, con un'architettura multi-tenant nel Vector DB."

(Frontend): "Sviluppa la Dashboard Professore e il Canvas Infinito (v1) con le funzioni AI di generazione mappe e flashcard."

Deliverable Verificabile: Le scuole possono usare Dydat. Gli studenti possono usare il Canvas intelligente.

Sprint 2.4 - 2.7: Integrazione Blockchain (8 settimane)
Focus Primario dell'Agente: Blockchain & Web3, Core Backend.

Istruzioni per l'Agente AI: "Sviluppa l'intero Layer Blockchain per i certificati NFT: scrivi e testa lo Smart Contract ERC-721 in Solidity, crea il Wallet Service, il servizio di interazione IPFS e l'Indexer. Infine, integra il tutto con il Core Backend."

Deliverable Verificabile: Al completamento di un corso, un certificato NFT viene correttamente generato e associato all'utente.

Sprint 2.8 - 2.12: Gamification Completa, WebXR e Stabilizzazione (10 settimane)
Focus Primario dell'Agente: Core Backend, Frontend, Testing.

Istruzioni per l'Agente AI: "Implementa il Servizio Gamification (v2) con Neuroni, Badge e Mastery Paths. Sviluppa il player WebXR nel frontend. Successivamente, dedica due sprint alla stabilizzazione e al testing di integrazione di tutte le nuove funzionalità."

Deliverable Verificabile: L'ecosistema di gamification è completo. La piattaforma supporta corsi immersivi.

Fase 3: Intelligence (Durata: 6 Mesi / 12 Sprint)
Sprint 3.1 - 3.12: Funzionalità Premium e Ottimizzazione (Sequenziale)
Focus Primario dell'Agente: AI, Core Backend, Frontend.

Istruzioni Sequenziali per l'Agente AI:

"Sviluppa il Tool di Analisi Contenuti Video/Audio come funzionalità premium."

"Crea il microservizio Bacheca Annunci e il Talent Hub."

"Implementa gli Agenti AI Proattivi (Agenda, Quest Giver)."

"Completa la Suite di Apprendimento Avanzato con la Ripetizione Dilazionata e la Modalità 'Insegna all'AI'."

"Dedica gli ultimi sprint all'ottimizzazione su larga scala, al refactoring e alla sicurezza avanzata."

Deliverable Verificabile: Al termine della fase, tutte le funzionalità definite nel documento di design sono state implementate, testate e ottimizzate.