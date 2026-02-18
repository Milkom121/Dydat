# Dydat v4.0 - Digest Progetto

> Documento compatto che riassume tutte le decisioni chiave del progetto.
> Da leggere all'inizio di ogni nuova chat per avere il contesto completo.
> Ultimo aggiornamento: 4 febbraio 2026

---

## Cos'e Dydat

Tutor AI personale che prende l'utente da dove e -- anche da zero -- e lo accompagna in un percorso strutturato per padroneggiare **matematica, fisica e chimica** fino a livello universitario. Si adatta a come funziona la testa dell'utente, lo tiene agganciato ogni giorno, rende accessibile la bellezza di queste materie.

**Origine**: bisogno personale del fondatore -- comprensione intuitiva eccellente della fisica, manca di strumenti matematici formali. Tentativi autodidattici falliti per mancanza di struttura, feedback e continuita.

**MVP**: app mobile Flutter (iOS + Android), one-man team con AI coding agents.

**Utente target**: adulti e giovani adulti autodidatti, curiosi. Il fondatore e il primo utente.

---

## Architettura Core -- Le 3 Decisioni Fondamentali

### 1. Architettura a tre livelli

- **Layer 3 - TUTOR LLM** (agente): genera, interpreta, adatta
- **Layer 2 - ORCHESTRATORE**: traduce tra i due mondi, arbitra conflitti
- **Layer 1 - KNOWLEDGE GRAPH**: dati + algoritmi deterministici

Orchestratore ha 6 sotto-componenti: Session Manager, Context Builder, Action Executor, Signal Processor, Conversation Manager, Path Planner + Cross-Subject Coordinator. Regola d'oro: nessuno dei layer estremi parla direttamente con l'altro.

### 2. Knowledge Graph

- **Nodo** = singola abilita verificabile ("sommare frazioni con denominatore diverso")
- **Tema** = raggruppamento percepito dall'utente ("le frazioni")
- **Relazioni**: prerequisiti duri (obbligatori), prerequisiti morbidi (utili), connessioni semantiche (cross-materia)
- Tre materie in un unico grafo con connessioni cross-materia reali
- **Binario 1** (percorso aperto): ordinamento topologico del grafo
- **Binario 2** (obiettivo specifico): pathfinding dal punto attuale al target

### 3. Canvas-first, non chat-first

Il canvas di studio e il palcoscenico, il tutor e il compagno di scena. L'utente sta dentro uno spazio progettato per studiare, non dentro una chat.

---

## Modello Pedagogico

### Padronanza a 3 livelli

| Livello | Nome | Verifica |
|---|---|---|
| 1 | **Operativo** | Esercizi corretti, applicazione procedure |
| 2 | **Comprensivo** | Feynman + esercizi + SR senza errori (multi-segnale) |
| 3 | **Connesso** | Emerge naturalmente, riconosciuto dall'LLM |

### 8 tecniche didattiche

Active Recall, Spaced Repetition (SR), Interleaving, Elaborative Interrogation, Concrete Examples, Dual Coding, Feynman, Desirable Difficulty.

**SR** = Spaced Repetition: intervalli crescenti. Rispondi bene = intervallo si allunga. Sbagli = si accorcia, nodo rientra in lavorazione. Genera le "urgenze" all'apertura sessione.

### Approccio errori: B+C (Botte e Carota)

Non dare la risposta. Guidare il ragionamento. Dopo 2-3 tentativi: cambiare strategia. Chiusura sempre con successo o apprendimento.

### Metodo: Concreto - Problema - Formale

---

## Il Tutor AI

**Personalita**: onesto e pragmatico, amico competente. **Memoria** a 3 strati: strutturata (grafo), profilo sintetizzato, episodica (RAG). **Multi-modello**: Sonnet per didattica, Haiku per pipeline. **Context package** (6 blocchi): System prompt + Direttiva + Profilo + Contesto attivo + Conversazione + Memoria.

---

## UX e Schermate

### Principio trasversale: Semplice per default, profondo su richiesta

Primo impatto semplice e accessibile. Chi vuole approfondire: tap, espansione, sotto-schermata. Vale per tutta l'app.

### 3 Tab

| Tab | Funzione |
|---|---|
| **Studio** (home) | Canvas di apprendimento -- 90% del tempo |
| **Percorso** | Sentiero con temi, progresso, traguardi |
| **Profilo** | Statistiche, achievement, preferenze, impostazioni |

### Tutor: 3 strati

1. Mascotte fissa (angolo basso-destra, tap = tools tray)
2. Pannello parziale (slide-in, domande veloci)
3. Pannello completo (schermo intero, conversazione libera)

### Tab Studio

Header leggero (~5%) + Canvas fluido (~85-90%) + Mascotte (~5%) + Tab bar nascondibile. Tools tray: 6 strumenti meccanici + "Parla col tutor". Canvas flow a step sequenziali, scroll verticale. Variazioni per: spiegazione, esercizio, B+C, SR, Feynman, visualizzazione. Apertura sessione con visione panoramica cross-percorso.

### Tab Percorso -- Decisioni Chiave

**DECISIONE**: il sentiero mostra **TEMI**, non nodi singoli. 15-20 tappe significative, non 150 pallini. Il grafo ragiona per nodi, la visualizzazione per temi.

- **Modello "torcia nella nebbia"**: passato luminoso, presente eroe visivo, prossimo faro, futuro nebbia
- **Bottom sheet** al tap: riassunto AI pre-generato (Haiku, a fine sessione) + progresso + nodi + "Studia questo"
- **Swipe laterale** tra percorsi, dots in header, ordine intelligente (urgenza)
- **Traguardo vicino** nell'header ("Prossima Medaglia: Algebra - 2 temi")
- 3 orizzonti: MVP sentiero lineare, upgrade viste locali, futuro il Cervello

### Tab Profilo -- Decisioni Chiave

**6 sezioni scrollabili**: Identita, Snapshot (3 numeri grandi), Bacheca achievement, Statistiche, Preferenze tutor, Impostazioni.

- **Bacheca a vetrina**: 4 file (Sigilli-Costellazioni-Medaglie-Spille), bloccati come **sagome grigie** (mai vuota, piena di potenziale)
- **Statistiche a 2 livelli**: 4 card compatte + espansione al tap
- **3 preferenze tutor strutturate**: input (testo/voce/auto), velocita (sodo/bene/decidi tu), incoraggiamento (molto/equilibrato/fatti)
- **NO custom instructions MVP** -- rischio interferenza con direttive pedagogiche
- **Memoria tutor trasparente** e resettabile (reset non tocca il grafo)
- **Impostazioni**: Account, Materie/percorsi, Obiettivo giornaliero, Promemoria, Memoria tutor, Accessibilita, Abbonamento, Privacy

---

## Gamification -- 4 Livelli

Spille (alta), Medaglie (media), Costellazioni (bassa), Sigilli (molto bassa). La gamification e il ponte, non la destinazione. Stampella cognitiva reale per ADHD.

---

## Onboarding -- 7 Fasi (~5 minuti)

1. **Lancio** (~2-3s): splash minimale, zero carousel, logo poi mascotte
2. **Accoglienza** (~30s): tutor nel canvas, scelta voce/testo
3. **Conoscenza** (~1-2min): conversazione naturale
4. **Assessment** (~1-2min): card risposta multipla adattive, nessun punteggio visibile
5. **Obiettivo** (~30-60s): proposte calibrate + opzione libera
6. **Piano + Wow** (~30-60s): animazione sentiero -- spettacolare nel contenuto, sobrio nella tecnica
7. **Assaggio** (~30s): visualizzazione interattiva dal percorso

Registrazione nel canvas, "Sei pronto? Si parte", tab bar appare, prima sessione. Progress indicator morbido (barra sottile).

---

## Pipeline di Sviluppo -- Backend-First

### Approccio

Il frontend e un layer di rendering per il backend AI. Backend first: si valida l'esperienza AI prima di investire nel frontend. La documentazione e il prodotto piu critico -- e il briefing per gli agenti AI che scrivono il codice.

### Strumenti

- **Backend**: Cursor AI (AI coding agent)
- **Frontend**: Rocket.new (AI agent per Flutter)

### I 5 Passi

| # | Cosa | Output |
|---|---|---|
| 1 | **Specifica Tecnica** -- schema KG, contratti API, pattern LLM, infrastruttura | Doc per Cursor AI |
| 2 | **Backend core** -- KG con nodi reali, orchestratore base, integrazione LLM | Backend testabile |
| 3 | **Validazione AI** -- sessione reale end-to-end | Conferma esperienza |
| 4 | **Direzione visiva** -- palette, mood, riferimenti, mascotte (5-6 decisioni) | Brief per Rocket.new |
| 5 | **Frontend Flutter** -- wireframe + API + visuals con Rocket.new | App completa |

Fase 3C originale (design system completo) ridotta al Passo 4 -- direzione visiva leggera.

---

## Stack Tecnico

- **Frontend**: Flutter mobile+tablet (MVP)
- **Backend**: API + database (da definire in Passo 1)
- **AI**: Claude API (Sonnet + Haiku), model-agnostic
- **Team**: one-man con AI coding agents (Cursor + Rocket.new)

---

## Stato di Avanzamento

- Fase 3A Logica Funzionale: COMPLETA (Step 1-8)
- Fase 3B Wireframe: COMPLETA (Step 9-13)
- **PROSSIMO: Specifica Tecnica (Passo 1 pipeline)**

---

## Documenti di Riferimento

| Documento | Contenuto |
|---|---|
| dydat_concept_document_complete.md | Concept Document (Fase 1-2) |
| dydat_architettura_sistema.md | Architettura core (Fase 3A) |
| dydat_mappa_schermate.md | Mappa schermate (Step 9) |
| dydat_wireframe_studio.md | Wireframe Tab Studio (Step 10) |
| dydat_wireframe_percorso.md | Wireframe Tab Percorso (Step 11) |
| dydat_wireframe_profilo.md | Wireframe Tab Profilo (Step 12) |
| dydat_wireframe_onboarding.md | Wireframe Onboarding (Step 13) |
| dydat_fase3_piano.md | Piano Fase 3 |

---

## Profilo del Fondatore

ADHD, autistico tipo 1, plusdotato, bipolare tipo 1 (in cura). Stile visivo, narrativo, intuitivo. Sviluppatore/designer con AI. Gamification = stampella cognitiva reale.

---

*Questo digest e la mappa. Per dettagli, consultare i documenti completi.*
