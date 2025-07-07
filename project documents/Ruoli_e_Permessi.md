# **Dydat: Ruoli, Permessi e Interazioni dell\'Ecosistema**

## **1. Introduzione** {#introduzione}

Questo documento definisce la struttura sociale e operativa della
piattaforma Dydat. L\'obiettivo è dettagliare i ruoli degli utenti, i
permessi associati a ciascun ruolo e i flussi di interazione chiave che
governano l\'ecosistema. Questo serve come blueprint per
l\'implementazione della logica di business e del controllo degli
accessi (Role-Based Access Control - RBAC).

## **2. Struttura dei Ruoli** {#struttura-dei-ruoli}

La piattaforma prevede una gerarchia di ruoli che un utente può
assumere. Alcuni ruoli sono di base, altri sono specializzati o legati a
un\'organizzazione.

### **A. Ruoli di Base** {#a.-ruoli-di-base}

- **Guest (Utente non autenticato):** Qualsiasi visitatore del sito.

- **Studente (Ruolo di Default):** Il ruolo base per ogni utente
  > registrato. È il \"consumatore\" di conoscenza.

### **B. Ruoli Specializzati (Aggiuntivi al ruolo di Studente)** {#b.-ruoli-specializzati-aggiuntivi-al-ruolo-di-studente}

Un utente può \"guadagnare\" o richiedere questi ruoli per diventare un
\"produttore\" di conoscenza o servizi.

- **Creatore di Contenuti:** Un utente approvato che può creare e
  > pubblicare corsi sul marketplace.

- **Tutor:** Uno Studente con un alto Livello di Maestria in una
  > specifica disciplina, approvato per offrire sessioni di tutoraggio
  > nel Mercatino.

### **C. Ruoli Organizzativi (All\'interno di un\'Azienda o Istituto)** {#c.-ruoli-organizzativi-allinterno-di-unazienda-o-istituto}

Questi ruoli esistono solo all\'interno di un\'entità \"Organizzazione\"
(sia essa un\'azienda su Dydat Public o un istituto su Dydat Scholar).

- **Membro del Team:** Uno Studente che è stato invitato e appartiene a
  > un\'organizzazione.

- **Manager:** Un Membro del Team con permessi aggiuntivi per gestire un
  > gruppo specifico di utenti (es. il proprio reparto).

- **Amministratore (Admin):** L\'utente con il massimo controllo
  > sull\'area dell\'organizzazione. Gestisce utenti, fatturazione,
  > permessi e le interazioni strategiche con l\'ecosistema.

## **3. Matrice dei Permessi (Sintetica)** {#matrice-dei-permessi-sintetica}

Questa matrice illustra le capacità principali per ogni ruolo.

| **Azione / Funzionalità**                | **Guest** | **Studente** | **Creatore** | **Tutor** | **Membro** | **Manager** | **Admin** |
|------------------------------------------|-----------|--------------|--------------|-----------|------------|-------------|-----------|
| **Navigazione e Fruizione**              |           |              |              |           |            |             |           |
| Visualizzare Catalogo Pubblico           | ✅        | ✅           | ✅           | ✅        | ✅         | ✅          | ✅        |
| Acquistare/Iscriversi a Corsi Pubblici   | ❌        | ✅           | ✅           | ✅        | ✅         | ✅          | ✅        |
| Seguire Lezioni e Corsi                  | ❌        | ✅           | ✅           | ✅        | ✅         | ✅          | ✅        |
| **Tool di Apprendimento**                |           |              |              |           |            |             |           |
| Usare la Suite di Apprendimento Avanzato | ❌        | ✅           | ✅           | ✅        | ✅         | ✅          | ✅        |
| **Gamification e Profilo**               |           |              |              |           |            |             |           |
| Guadagnare XP, N, Badge                  | ❌        | ✅           | ✅           | ✅        | ✅         | ✅          | ✅        |
| Spendere Neuroni (N)                     | ❌        | ✅           | ✅           | ✅        | ✅         | ✅          | ✅        |
| **Creazione e Gestione Contenuti**       |           |              |              |           |            |             |           |
| Creare e Pubblicare Corsi Pubblici       | ❌        | ❌           | ✅           | ❌        | ❌         | ❌          | ❌        |
| Caricare Corsi Privati (per l\'Org.)     | ❌        | ❌           | ❌           | ❌        | ❌         | ❌          | ✅        |
| Visualizzare Analytics dei Propri Corsi  | ❌        | ❌           | ✅           | ❌        | ❌         | ❌          | ❌        |
| **Interazioni Ecosistema**               |           |              |              |           |            |             |           |
| Offrire Tutoraggio nel Mercatino         | ❌        | ❌           | ❌           | ✅        | ❌         | ❌          | ❌        |
| Richiedere Tutoraggio                    | ❌        | ✅           | ✅           | ✅        | ✅         | ✅          | ✅        |
| Commissionare un Corso (Bacheca)         | ❌        | ❌           | ❌           | ❌        | ❌         | ❌          | ✅        |
| Rispondere a una Commissione             | ❌        | ❌           | ✅           | ❌        | ❌         | ❌          | ❌        |
| **Gestione Organizzazione**              |           |              |              |           |            |             |           |
| Visualizzare Dashboard Organizzazione    | ❌        | ❌           | ❌           | ❌        | ❌         | ✅          | ✅        |
| Assegnare Corsi ai Membri                | ❌        | ❌           | ❌           | ❌        | ❌         | ✅          | ✅        |
| Gestire Utenti e Ruoli dell\'Org.        | ❌        | ❌           | ❌           | ❌        | ❌         | ❌          | ✅        |
| Gestire Fatturazione e Abbonamenti       | ❌        | ❌           | ❌           | ❌        | ❌         | ❌          | ✅        |

## **4. Flussi di Interazione Chiave dell\'Ecosistema** {#flussi-di-interazione-chiave-dellecosistema}

Questi flussi descrivono come i diversi ruoli collaborano per creare un
mercato della conoscenza dinamico.

### **Flusso 1: Commissione di un Corso Personalizzato**

- **Trigger:** Un\'azienda (tramite il suo **Admin**) ha bisogno di un
  > corso specifico non disponibile nel catalogo.

1.  **Pubblicazione:** L\'**Admin** utilizza il tool **\"Bacheca Corsi
    > su Commissione\"** per pubblicare un annuncio dettagliato
    > (argomento, obiettivi, durata, budget).

2.  **Notifica e Candidatura:** I **Creatori** con competenze pertinenti
    > ricevono una notifica. Possono visualizzare l\'annuncio nella loro
    > **\"Dashboard Opportunità\"** e candidarsi, allegando il loro
    > profilo Dydat come portfolio.

3.  **Selezione e Accordo:** L\'**Admin** valuta le candidature e
    > seleziona il Creatore più adatto. La piattaforma facilita la
    > formalizzazione di un accordo (che può includere il blocco di un
    > acconto tramite il Servizio Pagamenti).

4.  **Sviluppo e Revisione:** Il **Creatore** sviluppa il corso nel suo
    > Studio e lo condivide privatamente con l\'**Admin** per la
    > revisione.

5.  **Approvazione e Consegna:** Una volta approvato, il corso viene
    > aggiunto alla libreria privata dell\'azienda e il pagamento finale
    > viene sbloccato per il Creatore.

### **Flusso 2: Tutoraggio tra Pari nel Mercatino**

- **Trigger:** Uno **Studente** (Utente A) incontra una difficoltà su un
  > argomento specifico.

1.  **Ricerca:** L\'Utente A accede al **\"Mercatino del Tutoraggio\"**
    > e cerca tutor per quella disciplina.

2.  **Selezione:** Il sistema mostra una lista di utenti con il ruolo di
    > **Tutor** (es. Utente B), evidenziando il loro Livello di
    > Maestria, le recensioni e la tariffa in Neuroni (N).

3.  **Prenotazione:** L\'Utente A prenota una sessione con l\'Utente B.
    > I Neuroni necessari vengono \"congelati\" dal suo account.

4.  **Sessione:** La sessione di tutoraggio si svolge all\'interno di
    > Dydat, utilizzando un **Canvas Collaborativo** condiviso e una
    > chat/videochiamata.

5.  **Completamento e Feedback:** Al termine della sessione, l\'Utente A
    > conferma il completamento. I Neuroni vengono trasferiti al wallet
    > dell\'Utente B. Entrambi possono lasciare una recensione, che
    > influenzerà la reputazione del Tutor.

### **Flusso 3: Ciclo di Vita e Qualità di un Corso Pubblico**

- **Trigger:** Un **Creatore** decide di creare un nuovo corso per il
  > marketplace.

1.  **Stato Bozza:** Il corso viene creato nello Studio di Creazione. È
    > visibile solo al Creatore.

2.  **Stato Beta (Opzionale):** Il Creatore può invitare un gruppo
    > ristretto di Studenti a testare il corso (gratuitamente o a prezzo
    > ridotto) per raccogliere feedback preziosi prima del lancio.

3.  **Stato Pubblicato:** Il Creatore pubblica il corso, che diventa
    > visibile e acquistabile da tutti nel marketplace di Dydat Public.

4.  **Stato Aggiornato:** Il Creatore può pubblicare nuove versioni del
    > corso. Gli studenti già iscritti ricevono una notifica e hanno
    > accesso ai nuovi contenuti.

5.  **Stato Archiviato:** Se un corso diventa obsoleto, il Creatore può
    > archiviarlo. Il corso non sarà più in vendita, ma rimarrà
    > accessibile per sempre nella libreria di chi lo ha già acquistato.
