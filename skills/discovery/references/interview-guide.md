# Guida all'Intervista Strutturata

Questa guida contiene domande tipo organizzate per area. Non vanno poste tutte: seleziona quelle rilevanti in base al progetto e ai gap identificati nella Fase 2.

## Adattamento per Tipo di Progetto

La tipologia del progetto (identificata nella Fase 2) determina quali aree approfondire:

| Tipo progetto | Aree prioritarie | Aree secondarie |
|---------------|-----------------|-----------------|
| E-commerce | Flussi critici, Dati/Integrazioni (pagamenti), Vincoli (GDPR) | Nice-to-have |
| Tool interno | Utenti/Ruoli, Funzionalità core | Vincoli (spesso più flessibili) |
| SaaS multi-tenant | Utenti/Ruoli, Vincoli (scalabilità), Dati | Vision (modello di pricing) |
| App mobile | Flussi critici (UX mobile), Vincoli (offline?), Integrazioni (push, GPS) | Architettura |
| Sito vetrina/CMS | Vision, Funzionalità core | Meno profondità su dati e integrazioni |

Non trattare questa tabella come rigida — è un punto di partenza per decidere dove dedicare più domande.

## Formato Domanda

Ogni domanda deve seguire questo formato nel messaggio all'utente:

```
**Domanda 3/12** — Ruoli Utente

Chi sono i diversi tipi di utente che useranno il sistema? Per esempio: amministratore, operatore, cliente finale, ospite non registrato.

_Questa domanda è importante perché i ruoli determinano i permessi, le viste e i flussi di navigazione. Definirli adesso evita di dover ristrutturare l'app in seguito._

Se non sei sicuro, ecco alcune configurazioni comuni:
- **Semplice**: Admin + Utente (basta per la maggior parte dei tool interni)
- **E-commerce classico**: Admin + Venditore + Cliente + Ospite
- **SaaS multi-tenant**: Super Admin + Admin Organizzazione + Membro + Viewer
```

## Area 1 — Vision e Obiettivi

Obiettivo: capire il "perché" del progetto, non solo il "cosa".

**Domande tipo:**
1. Qual è il problema principale che questo progetto deve risolvere?
   - _Motivazione: definisce il focus e aiuta a prioritizzare le feature._
2. Come viene gestito oggi questo problema? (manualmente, con un altro software, non viene gestito)
   - _Motivazione: capire lo status quo aiuta a progettare una migrazione realistica._
3. Come saprai che il progetto è un successo? Quali numeri o risultati ti aspetti?
   - _Motivazione: definisce i KPI e aiuta a misurare l'impatto._
4. C'è una deadline o un evento che determina quando deve essere pronto?
   - _Motivazione: vincola le fasi e la prioritizzazione delle feature._

## Area 2 — Utenti e Ruoli

Obiettivo: mappare chi userà il sistema e con quali permessi.

**Domande tipo:**
1. Chi sono i diversi tipi di utente? (vedi formato sopra per opzioni suggerite)
2. Ogni tipo di utente, cosa deve poter fare e cosa NON deve poter fare?
3. Come si registrano gli utenti? (auto-registrazione, invito, creazione manuale)
4. Ci sono utenti che devono vedere i dati di altri utenti? (reporting, supervisione)

## Area 3 — Funzionalità Core

Obiettivo: definire il Minimum Viable Product.

**Domande tipo:**
1. Se dovessi scegliere solo 3 funzionalità per il lancio, quali sarebbero?
   - _Motivazione: forza la prioritizzazione e identifica il vero MVP._
2. Per ognuna di queste funzionalità, puoi descrivermi il flusso passo per passo? ("l'utente apre l'app, clicca su X, compila Y...")
3. Ci sono calcoli, regole o logiche particolari? (sconti, commissioni, punteggi, algoritmi)
4. Quali notifiche servono? (email, push, SMS, in-app) E quando vengono inviate?

## Area 4 — Flussi Critici

Obiettivo: documentare i percorsi utente più importanti end-to-end.

**Domande tipo:**
1. Qual è il percorso più frequente che un utente farà nell'app?
2. Qual è il percorso più critico per il business? (es. quello che genera revenue)
3. Cosa succede quando qualcosa va storto nel flusso? (errore pagamento, stock esaurito, utente non autorizzato)
   - _Motivazione: i flussi di errore sono spesso dimenticati ma fondamentali per la UX._
4. Ci sono flussi che richiedono approvazione da parte di un altro utente?

## Area 5 — Dati e Integrazioni

Obiettivo: capire da dove vengono i dati e dove devono andare.

**Domande tipo:**
1. Ci sono dati esistenti da importare? (Excel, database, altro software)
2. Il sistema deve comunicare con altri software? (CRM, contabilità, e-commerce, API esterne)
3. Quali dati devono essere esportabili? In che formato? (Excel, PDF, CSV)
4. Ci sono requisiti di privacy o GDPR da considerare?
   - _Motivazione: impatta architettura, storage, e feature di cancellazione/export dati._

## Area 6 — Vincoli

Obiettivo: definire i limiti del progetto.

**Domande tipo:**
1. C'è un budget definito o un range?
   - _Motivazione: aiuta a calibrare ambizione vs. fattibilità._
2. Ci sono tecnologie obbligate? (es. "deve girare su server Windows", "deve usare Oracle")
3. Il sistema deve funzionare offline o in aree con connessione scarsa?
4. Quanti utenti contemporanei prevedi al lancio? E tra 1 anno?
   - _Motivazione: dimensiona l'architettura (serverless vs. dedicato, cache, ecc.)._

## Area 7 — Nice-to-Have

Obiettivo: raccogliere desideri futuri senza prometterli.

**Domande tipo:**
1. Se il budget e il tempo non fossero un problema, cosa aggiungeresti?
2. Ci sono funzionalità che hai visto in altri prodotti e che ti piacerebbe avere?
3. Hai pensato a un'app mobile, un chatbot, o altre interfacce oltre al web?

---

## Consigli per l'Intervistatore

- **Ascolta più di quanto parli** — la risposta del cliente è più importante della tua domanda
- **Riformula** — dopo risposte complesse, riformula per confermare: "Quindi se ho capito bene..."
- **Non giudicare** — se il cliente chiede qualcosa di irrealizzabile, annota e discuti dopo, non durante l'intervista
- **Prendi nota di tutto** — anche i "sarebbe bello ma non serve" spesso diventano requisiti
- **Tempo**: un'intervista completa dura circa 10-20 domande. Adatta il numero in base alla complessità del progetto. Progetti semplici possono bastare 8-10 domande, progetti complessi possono richiederne 20+.
- **Salva sempre** — dopo ogni risposta, aggiorna `discovery-notes.md` con la decisione. Non affidarti alla memoria della conversazione.
- **Segnali di confusione** — se l'utente risponde "non so" o è vago, proponi tu una soluzione ragionevole e chiedi se va bene. Non lasciare gap aperti senza motivo.
