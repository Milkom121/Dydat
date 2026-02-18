# Dydat â€” Direzione Visiva v2

> Documento vivo. Passo 4 della Pipeline di Sviluppo.
> Validato dal fondatore: â¬œ In attesa di validazione
> Ultimo aggiornamento: 18 febbraio 2026
> Evoluzione: v2 integra le decisioni post-test E2E manuale (commit `e722059`)

---

## Indice

1. [Mood Generale](#1-mood-generale)
2. [Palette Colori](#2-palette-colori)
3. [Tipografia](#3-tipografia)
4. [Mappa Emotiva della Sessione](#4-mappa-emotiva-della-sessione)
5. [Mascotte â€” La Creatura di Luce](#5-mascotte--la-creatura-di-luce)
6. [Celebrazioni e Micro-Feedback](#6-celebrazioni-e-micro-feedback)
7. [Principi di Applicazione per Schermata](#7-principi-di-applicazione-per-schermata)
8. [Riferimenti Visivi](#8-riferimenti-visivi)
9. [Note per il Brief Tecnico](#9-note-per-il-brief-tecnico)

---

## Changelog v1 â†’ v2

| Cosa | v1 | v2 | Motivazione |
|------|----|----|-------------|
| Â§4 Mascotte | Sezione autonoma con stati generici | Integrata nella mappa emotiva per beat | Gli stati della mascotte hanno senso solo nel contesto del momento della sessione |
| Â§5 Animazioni | Scala celebrazioni generica | Mappa emotiva a 7+1 beat basata sui flussi E2E verificati | Il test ha rivelato la sequenza esatta dei momenti emotivi |
| Celebrazione erroreâ†’corretto | Identica a primo tentativo | Differenziata (Opzione C) â€” riconosce il percorso, non solo il risultato | Il backend traccia giÃ  `primo_tentativo` vs `con_guida` â€” il design deve usare questa informazione |
| Canvas durante B+C | Non definito | Segnale iniziale morbido, poi canvas normale | Evita di etichettare lo studente come "in errore" per piÃ¹ turni |
| Stato transizionale (W1) | Non previsto | Nuovo micro-beat per tool_use senza testo | Il test E2E ha rivelato che il tutor a volte emette azioni senza testo accompagnatorio |
| Gap promozione | Non identificato | Fix backend (prompt) + design che assume il tutor parlerÃ  | La celebrazione visiva accompagna le parole del tutor, non le sostituisce |

---

# 1. Mood Generale

## "Studio notturno illuminato"

Dydat Ã¨ lo spazio personale dove un adulto studia la sera dopo il lavoro. Non Ã¨ un'aula scolastica, non Ã¨ un ufficio, non Ã¨ un playground per bambini. Ãˆ un posto intimo, caldo, illuminato â€” il resto Ã¨ scuro, ma lo spazio davanti a te Ã¨ luminoso e accogliente.

### Il posizionamento

```
Duolingo â†â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€” DYDAT â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â†’ Coursera
(giocoso, infantile)   (giocoso ma adulto)   (freddo, corporate)
```

Dydat sta nel territorio del **giocoso-sofisticato**: studiare Ã¨ divertente, il feedback Ã¨ generoso, i momenti di celebrazione sono sentiti â€” ma il linguaggio visivo Ã¨ adulto, elegante, rispettoso dell'intelligenza dell'utente.

### Tre parole chiave

- **Accogliente**: questo posto Ã¨ mio, mi conoscono, mi sento a casa
- **Giocoso**: studiare Ã¨ un piacere, ogni step dÃ  soddisfazione, la curiositÃ  Ã¨ celebrata
- **Competente**: qui c'Ã¨ sostanza vera, non sono in un giochino â€” sto imparando davvero

### Sensazione target

Un adulto di 30 anni apre l'app la sera, sul divano. Non sente ansia da scuola. Sente la stessa cosa che prova aprendo Discord â€” "il mio posto" â€” ma con la stessa fiducia che prova usando Claude â€” "qui le cose funzionano bene". E con la stessa voglia di proseguire che prova su Duolingo â€” "ancora uno e basta".

### Validazione dal test E2E

Il test manuale ha confermato tutte e tre le parole chiave:
- **Accogliente**: "il tono del tutor durante l'onboarding Ã¨ molto bello: amichevole, non invadente"
- **Giocoso**: "l'achievement `primo_nodo` in tempo reale via SSE â€” come studente Ã¨ gratificante"
- **Competente**: "la spiegazione sulle potenze era davvero buona â€” partiva da esempi concreti, costruiva il concetto passo passo"

---

# 2. Palette Colori

## Schema: Ambra e Grafite

Dark mode come base. Il calore viene dai punti di luce ambra/oro che guidano l'attenzione e creano la sensazione di "lampada calda nello spazio scuro".

### Base (sfondi)

| Ruolo | Colore indicativo | Dove |
|---|---|---|
| Sfondo principale | #1A1A1E | Canvas di studio, sfondo globale |
| Superficie elevata | #242428 | Card, bottom sheet, pannello tutor |
| Superficie interattiva | #2E2E34 | Campi input, hover state, sezioni |
| Bordo/separatore | #3A3A42 | Linee sottili, divisori di sezione |

> Non nero puro (#000000) â€” il nero pieno affatica gli occhi su OLED e crea un "buco" visivo. I grigi molto scuri con sottotono leggermente caldo sono piÃ¹ accoglienti.

### Accento primario: Ambra/Oro

| Ruolo | Colore indicativo | Dove |
|---|---|---|
| Accento primario | #D4A843 | CTA, stato attivo, accenti principali |
| Accento luminoso | #F0C85A | Achievement sbloccati, celebrazioni, glow mascotte |
| Accento morbido | #A68A3A | Testo secondario ambra, icone inattive |

### Testo

| Ruolo | Colore indicativo | Dove |
|---|---|---|
| Testo primario | #E8E4DC | Corpo del testo, spiegazioni tutor |
| Testo secondario | #9B978F | Label, meta-info, note |
| Testo disabilitato | #5A5750 | Elementi non attivi |

> Bianco-crema caldo, non bianco puro (#FFFFFF). PiÃ¹ morbido per sessioni di studio lunghe, coerente con il mood "lampada calda".

### Colori semantici

| Ruolo | Colore indicativo | Dove |
|---|---|---|
| Successo/corretto | #7EBF8E | Esercizio corretto, nodo completato |
| Errore | #C97070 | Errore (mai aggressivo â€” morbido, non punitivo) |
| Warning/attenzione | #D4A843 (= ambra) | In corso, attenzione richiesta |
| Info/link | #7EA8C9 | Link, elementi informativi |

### Materie (differenziazione sottile)

Non colori nettamente diversi â€” variazioni di temperatura all'interno dello stesso mondo cromatico:

| Materia | Sfumatura | Principio |
|---|---|---|
| Matematica | Ambra base | Il colore "casa" |
| Fisica | Sfumatura leggermente piÃ¹ fredda (oro â†’ bronzo) | PiÃ¹ strutturale |
| Chimica | Sfumatura leggermente piÃ¹ calda (ambra â†’ rame) | PiÃ¹ organica |

> La differenziazione materie Ã¨ sottile e secondaria â€” Dydat non Ã¨ un'app a tre colori. Ãˆ un mondo coerente con sfumature.

### Light Mode

Esiste, ma Ã¨ secondario. Il dark mode Ã¨ l'esperienza primaria su cui si investe di piÃ¹ in cura estetica. Il light mode inverte: sfondo bianco-crema caldo, testi scuri, accenti ambra che restano invariati. Da definire in fase di implementazione.

---

# 3. Tipografia

## Font principale: Plus Jakarta Sans

Sans-serif con angoli leggermente arrotondati che comunicano calore e accessibilitÃ  senza perdere professionalitÃ . Non Ã¨ generico come Inter, non Ã¨ freddo come Space Grotesk â€” Ã¨ il font di un posto serio ma amichevole.

### Gerarchia

| Livello | Peso | Uso | Dimensione indicativa |
|---|---|---|---|
| H1 â€” Titolo pagina | Bold (700) | Nome tab, titolo sessione | 24-28sp |
| H2 â€” Sezione | SemiBold (600) | Sezioni profilo, titoli card | 20sp |
| H3 â€” Sotto-sezione | Medium (500) | Label gruppi, sotto-titoli | 16-18sp |
| Body | Regular (400) | Testo tutor, spiegazioni, corpo | 16sp |
| Caption | Regular (400) | Meta-info, timestamp, note | 13-14sp |
| Gamification | Bold (700) | Numeri streak, contatori, XP | 20-28sp |

### LaTeX

Le formule matematiche sono renderizzate da `flutter_math_fork` con il font nativo KaTeX. Il contrasto tipografico tra "testo conversazionale" (Plus Jakarta) e "formula matematica" (KaTeX serif) Ã¨ intenzionale â€” supporta il dual coding (canale verbale vs canale formale).

Le formule devono essere **belle da vedere** â€” dimensionate generosamente, con spaziatura corretta, integrate nel flusso del testo ma visivamente distinte. Non sono un afterthought â€” sono il contenuto core.

### Principi

- Niente testo sotto i 13sp â€” accessibilitÃ 
- Line-height generoso (1.5-1.6 per il corpo) â€” sessioni di lettura lunghe
- Spaziatura tra sezioni generosa â€” l'app respira, non affolla

---

# 4. Mappa Emotiva della Sessione

## Il principio: progettare per beat, non per stati

La v1 definiva gli stati della mascotte come una tabella isolata. Ma la sessione di studio Ã¨ una **sequenza narrativa** con un ritmo emotivo preciso. Ogni momento ha un tono diverso, e il design dell'intero canvas â€” non solo la mascotte â€” deve accompagnarlo.

Questa mappa Ã¨ basata sui flussi verificati nel test E2E manuale. Non Ã¨ una lista astratta â€” Ã¨ la sequenza reale che lo studente vive.

## I 7 beat + 1 micro-beat

### Beat 1 â€” Apertura: "Bentornato a casa"

| Aspetto | Descrizione |
|---|---|
| **Momento** | Lo studente apre l'app. Il tutor lo saluta, propone cosa fare |
| **Tono emotivo** | Caldo, rilassato, zero pressione |
| **Canvas** | Glow ambra stabile, luminositÃ  morbida. Il canvas Ã¨ "acceso ma calmo" |
| **Mascotte** | Accogliente â€” forma rilassata, glow caldo stabile, occhi dolci |
| **Ritmo** | Lento. Nessuna urgenza. Lo studente sceglie i suoi tempi |
| **Suono/aptico** | Nessuno â€” silenzio accogliente |

### Beat 2 â€” Spiegazione: "Sto imparando"

| Aspetto | Descrizione |
|---|---|
| **Momento** | Il tutor spiega con testo streaming e formule LaTeX. Lo studente legge, segue, assorbe |
| **Tono emotivo** | Concentrato ma guidato. Il professore parla, tu ascolti attivamente |
| **Canvas** | Immersivo â€” il testo emerge dallo sfondo scuro, le formule brillano. Cursore ambra che pulsa durante lo streaming |
| **Mascotte** | Attenta â€” forma stabile, occhi aperti, leggero glow. Discreta, non compete per l'attenzione |
| **Ritmo** | Medio. Il testo appare token per token â€” abbastanza veloce da non annoiare, abbastanza lento da seguire |
| **Suono/aptico** | Nessuno â€” la concentrazione non va interrotta |

### Beat 3 â€” Transizione: "Ok, tocca a me"

| Aspetto | Descrizione |
|---|---|
| **Momento** | Il tutor dice "vuoi provare?". Passaggio da passivo ad attivo |
| **Tono emotivo** | Micro-eccitazione. Lo studente si attiva |
| **Canvas** | Cambio sottile: la card esercizio emerge con un'animazione morbida. Lo sfondo attorno si attenua leggermente â€” il focus si stringe |
| **Mascotte** | Si anima leggermente â€” un piccolo rimbalzo, un cambio di espressione da "attenta" a "curiosa" |
| **Ritmo** | Breve â€” ~0.5s di transizione. Abbastanza per segnalare il cambio, non abbastanza per interrompere |
| **Suono/aptico** | Feedback aptico leggero (soft tap) alla comparsa della card esercizio |

### Beat 3.5 â€” Preparazione (micro-beat W1): "Sta arrivando qualcosa"

| Aspetto | Descrizione |
|---|---|
| **Momento** | Il tutor emette un tool_use (proponi_esercizio, mostra_formula) senza testo accompagnatorio |
| **Tono emotivo** | Attesa naturale â€” come un professore che sfoglia gli appunti prima di mostrare qualcosa |
| **Canvas** | Shimmer effect sulla zona dove apparirÃ  il contenuto. Non un loader â€” un'anticipazione |
| **Mascotte** | Pensierosa â€” espressione concentrata, come se stesse preparando qualcosa |
| **Ritmo** | Breve â€” max 1-2 secondi. Se il contenuto arriva prima, la transizione si accorcia |
| **Suono/aptico** | Nessuno |

> Questo beat compensa il warning W1 emerso dal test E2E. Il frontend lo attiva quando riceve tool_use senza testo dal backend. Non Ã¨ un workaround â€” Ã¨ buon design: anche un tutor umano ha micro-pause.

### Beat 4 â€” Esercizio: "Ci sto provando"

| Aspetto | Descrizione |
|---|---|
| **Momento** | Lo studente ragiona sull'esercizio e formula la risposta |
| **Tono emotivo** | Concentrazione attiva. Lo studente Ã¨ il protagonista |
| **Canvas** | Focalizzato sulla card esercizio â€” bordo ambra sottile (glow leggero), tutto il resto si attenua. Lo spazio Ã¨ dello studente |
| **Mascotte** | Pensierosa â€” in sincronia con lo studente. Non distrae |
| **Ritmo** | Fermo. Il canvas aspetta. Nessuna animazione in loop, nessun timer visivo aggressivo |
| **Suono/aptico** | Nessuno fino alla risposta |

### Beat 5a â€” Feedback positivo (primo tentativo): "Ce l'ho fatta!"

| Aspetto | Descrizione |
|---|---|
| **Momento** | Risposta corretta al primo tentativo |
| **Tono emotivo** | Gratificazione immediata. Breve e intensa |
| **Canvas** | Burst di particelle dorate dalla card, flash verde morbido (#7EBF8E) sul bordo. Il canvas "si accende" per un istante |
| **Mascotte** | Celebrativa â€” forma che brilla, piccola esplosione di luce, occhi grandi |
| **Ritmo** | ~1 secondo â€” giusto per sentirlo, non per interrompere il flow |
| **Suono/aptico** | Feedback aptico medio (medium tap). Nessun suono â€” non disturba chi studia in silenzio |

### Beat 5b â€” Errore: "Va bene, ragioniamoci"

| Aspetto | Descrizione |
|---|---|
| **Momento** | Risposta sbagliata. Il tutor inizia il pattern B+C (maieutico) |
| **Tono emotivo** | Transizione delicata. Il design deve dire: "Ã¨ tutto ok, stiamo ragionando insieme" |
| **Canvas** | Il bordo della card passa da ambra a neutro (#3A3A42). Nessun rosso, nessuno scuotimento, nessun flash negativo. La transizione Ã¨ morbida (~0.3s ease) |
| **Mascotte** | Incoraggiante â€” forma che si espande leggermente, glow piÃ¹ caldo, espressione gentile |
| **Ritmo** | Morbido. La transizione visiva dura ~0.3s, poi il canvas torna normale per i turni successivi del B+C |
| **Suono/aptico** | Nessuno. Mai feedback negativo |

> **Decisione v2**: dopo il segnale iniziale morbido, il canvas torna alla modalitÃ  normale per i turni B+C successivi. Il tutor fa il lavoro di accompagnamento con le parole â€” il design non deve insistere visivamente "sei in modalitÃ  errore". Il riconoscimento arriva alla fine (Beat 5c).

### Beat 5c â€” Corretto dopo guida: "Ce l'hai fatta, e l'hai capito"

| Aspetto | Descrizione |
|---|---|
| **Momento** | Lo studente arriva alla risposta corretta dopo il percorso B+C |
| **Tono emotivo** | Riconoscimento del percorso, non solo del risultato. PiÃ¹ caldo e piÃ¹ lento del 5a |
| **Canvas** | Transizione graduale: il bordo torna ambra, poi un glow caldo che si espande lentamente dalla card verso l'esterno. Non burst â€” diffusione. Il verde Ã¨ presente ma morbido |
| **Mascotte** | Incoraggiante â†’ soddisfatta â€” la transizione Ã¨ lenta, come un sorriso che cresce. Glow caldo, non esplosivo |
| **Ritmo** | ~1.5-2 secondi â€” piÃ¹ lento del Beat 5a. Il tempo extra dice: "questo percorso ha valore" |
| **Suono/aptico** | Feedback aptico medio (stesso del 5a). Il riconoscimento Ã¨ visivo, non sonoro |

> **Decisione v2 â€” Opzione C**: la celebrazione dopo guida Ã¨ *diversa* dal primo tentativo, non *minore*. Il primo tentativo Ã¨ un burst di gratificazione rapida. La guida completata Ã¨ una diffusione calda di soddisfazione. Lo studente che ha sbagliato e poi capito merita un riconoscimento che dice "il percorso conta, non solo il risultato". Il backend fornisce giÃ  l'informazione (`esito: primo_tentativo` vs `esito: con_guida` in `storico_esercizi`).

### Beat 6 â€” Promozione: "Sto crescendo davvero"

| Aspetto | Descrizione |
|---|---|
| **Momento** | 3 esercizi completati, nodo promosso a `operativo`. Achievement inviato via SSE. Il tutor riconosce verbalmente il traguardo (fix backend commit post-E2E) |
| **Tono emotivo** | Il momento piÃ¹ grande della sessione. Pausa, celebrazione, soddisfazione profonda |
| **Canvas** | Esplosione di luce ambra che si espande dal centro. Il canvas si illumina. Se il tab Percorso Ã¨ visibile, il nodo corrispondente "si accende". Pausa di 2-3 secondi prima di introdurre il nuovo nodo |
| **Mascotte** | Entusiasta â€” forma che vibra/pulsa, occhi grandi, piccola esplosione di luce propria. Momento speciale della mascotte |
| **Ritmo** | ~2-3 secondi. Questo Ã¨ il momento dove il design si prende tempo. Non si salta |
| **Suono/aptico** | Feedback aptico forte (heavy tap). L'unico momento dove l'aptico Ã¨ deciso |

> Il tutor introduce il nuovo nodo *dopo* la celebrazione, non durante. La sequenza Ã¨: celebrazione visiva â†’ tutor che riconosce â†’ breve pausa â†’ "ora passiamo a...". Il design e le parole lavorano insieme.

### Beat 7 â€” Chiusura: "Ho fatto bene oggi"

| Aspetto | Descrizione |
|---|---|
| **Momento** | Lo studente termina la sessione. Statistiche, recap, achievement finali |
| **Tono emotivo** | Calmo, soddisfatto, conclusivo. Come chiudere un libro dopo un buon capitolo |
| **Canvas** | Il glow si attenua gradualmente. Le statistiche appaiono con animazione gentile. Numeri che contano fino al valore finale |
| **Mascotte** | Soddisfatta â†’ sonnolenta. Un mini-saluto, un occhiolino |
| **Ritmo** | Lento. L'app non ha fretta di chiuderti fuori. I numeri hanno tempo di apparire |
| **Suono/aptico** | Feedback aptico leggero sulle statistiche. Poi silenzio |

## Riassunto visivo della mappa

```
APERTURA â”€â”€â†’ SPIEGAZIONE â”€â”€â†’ TRANSIZIONE â”€â”€â†’ ESERCIZIO
  caldo         immersivo       micro-burst      focalizzato
  lento         medio           breve (~0.5s)    fermo

              â”Œâ”€â”€â†’ 5a CORRETTO (burst rapido, ~1s)
              â”‚
ESERCIZIO â”€â”€â†’ â”œâ”€â”€â†’ 5b ERRORE (segnale morbido, ~0.3s)
              â”‚      â”‚
              â”‚      â””â”€â”€â†’ B+C (canvas normale) â”€â”€â†’ 5c CORRETTO DOPO GUIDA
              â”‚                                      (diffusione calda, ~1.5-2s)
              â”‚
              â””â”€â”€â†’ [LOOP: torna a Beat 4 per il prossimo esercizio]

PROMOZIONE â”€â”€â†’ CHIUSURA
  esplosivo       calmo
  ~2-3s           lento
```

---

# 5. Mascotte â€” La Creatura di Luce

## Riferimento: 22 di Soul (Pixar)

La mascotte di Dydat Ã¨ una creatura amorfa, luminescente, con personalitÃ  ricca espressa attraverso forma, luce e occhi minimi. Non Ã¨ un animale, non Ã¨ un umanoide, non Ã¨ un logo â€” Ã¨ un'entitÃ  di luce che vive nel canvas di Dydat.

### Principi di design

| Aspetto | Principio |
|---|---|
| **Forma** | Organica, morbida, leggermente amorfa â€” non geometrica, non simmetrica. Una goccia di luce con personalitÃ  |
| **Tratti** | Occhi espressivi (canale emotivo principale). Bocca minima o assente. Nessun arto permanente â€” "braccia" o appendici emergono dalla forma quando serve |
| **Luminescenza** | Emette luce propria. Toni ambra/oro come colore base, che variano con lo stato emotivo |
| **Dimensione** | Piccola e discreta durante lo studio attivo. PiÃ¹ presente nei momenti di transizione, accoglienza, celebrazione |
| **PersonalitÃ ** | Curiosa, incoraggiante, intelligente, leggermente giocosa. Mai saccente, mai condiscendente, mai punitiva |

### Come la mascotte partecipa ai beat

La mascotte non ha "stati" isolati â€” ha **reazioni ai beat della sessione**. Ogni espressione Ã¨ ancorata a un momento preciso del flusso:

| Beat | Espressione mascotte | Dettaglio |
|---|---|---|
| 1 â€” Apertura | Accogliente | Forma rilassata, glow caldo stabile, occhi dolci |
| 2 â€” Spiegazione | Attenta | Forma stabile, occhi aperti, leggero glow. Discreta |
| 3 â€” Transizione | Curiosa | Piccolo rimbalzo, occhi che si aprono |
| 3.5 â€” Preparazione | Pensierosa | Espressione concentrata, come se preparasse qualcosa |
| 4 â€” Esercizio | Pensierosa | In sincronia con lo studente â€” non distrae |
| 5a â€” Corretto | Celebrativa | Forma che brilla, piccola esplosione di luce |
| 5b â€” Errore | Incoraggiante | Forma che si espande, glow piÃ¹ caldo, espressione gentile |
| 5c â€” Corretto dopo guida | Soddisfatta | Transizione lenta, come un sorriso che cresce |
| 6 â€” Promozione | Entusiasta | Forma che vibra/pulsa, occhi grandi, esplosione di luce propria |
| 7 â€” Chiusura | Sonnolenta | Mini-saluto, occhiolino, si rilassa |

### Posizione e interazione

- **Angolo basso-destra** del canvas â€” sempre nello stesso posto (prevedibilitÃ  = comfort)
- **~40-48dp** â€” abbastanza grande da tappare, non tanto da oscurare contenuto
- **Tap singolo**: apre il tools tray (bottom sheet)
- Durante visualizzazioni a schermo intero: si riduce a ~24dp o diventa semitrasparente
- Non scompare mai del tutto â€” l'utente deve sempre poter accedere al tools tray

### Cosa NON Ã¨ la mascotte

- Non Ã¨ un assistente vocale con avatar realistico
- Non Ã¨ un animale carino (non Ã¨ Duo il gufo)
- Non Ã¨ una clip-art o un emoji
- Non Ã¨ sempre al centro dell'attenzione â€” sa farsi da parte quando il contenuto Ã¨ protagonista
- Non Ã¨ mai sarcastica, non Ã¨ mai frustrante

### Evoluzione futura (post-MVP)

- Animazioni Rive per fluiditÃ  e interattivitÃ 
- Variazioni contestuali (la creatura assume sfumature diverse per materia)
- Personalizzazione (lo studente sceglie aspetti della creatura come reward)
- Reazioni alla risposta in tempo reale (la creatura "pensa" mentre lo studente scrive)
- Easter egg nelle animazioni per sorprendere e deliziare

---

# 6. Celebrazioni e Micro-Feedback

## Principio: l'intensitÃ  scala con l'importanza

Le celebrazioni non sono tutte uguali. Un esercizio corretto Ã¨ un applauso. Un nodo completato Ã¨ un brindisi. Un achievement sbloccato Ã¨ una festa. L'errore non Ã¨ mai una punizione.

### Scala delle celebrazioni

| Evento | IntensitÃ  | Elementi | Durata |
|---|---|---|---|
| **Esercizio corretto (primo tentativo)** | Media-alta | Burst particelle dorate, flash verde morbido, mascotte celebra, aptico medio | ~1s |
| **Esercizio corretto (dopo guida)** | Media-calda | Glow caldo che si diffonde lentamente, verde morbido, mascotte soddisfatta, aptico medio | ~1.5-2s |
| **Esercizio con guida (in corso)** | Bassa-nulla | Nessuna celebrazione. Segnale morbido iniziale, poi canvas normale | ~0.3s |
| **Nodo completato** (promozione) | Alta | Esplosione luce ambra, nodo si "accende", mascotte entusiasta, pausa, aptico forte | ~2-3s |
| **Achievement sbloccato** | Molto alta | Confetti di luce, mascotte speciale, sigillo/spilla con animazione, aptico forte | ~3-4s |
| **Streak mantenuta** | Media | Fiamma che cresce, mascotte accogliente, numero che pulsa | ~1.5s |
| **Errore** | Nessuna | Bordo card da ambra a neutro. Mascotte incoraggiante. Mai scuotimento, mai rosso aggressivo, mai suono negativo | Transizione morbida ~0.3s |

### La differenza tra 5a e 5c â€” il design che riconosce il percorso

Questa Ã¨ una decisione deliberata. Quando uno studente sbaglia, ragiona con il tutor, e poi capisce â€” il suo apprendimento Ã¨ spesso *piÃ¹ profondo* di chi ha azzeccato al primo colpo. Il design deve riflettere questo.

| | Primo tentativo (5a) | Dopo guida (5c) |
|---|---|---|
| **Tipo di celebrazione** | Burst â€” rapido, esplosivo | Diffusione â€” lento, caldo |
| **Messaggio implicito** | "Bravo, lo sai!" | "Ce l'hai fatta, e l'hai capito" |
| **Colore dominante** | Verde + oro (successo immediato) | Ambra caldo (percorso completato) |
| **Mascotte** | Celebrativa (flash) | Soddisfatta (sorriso crescente) |
| **Tempo** | ~1s | ~1.5-2s |
| **Dato backend** | `esito: primo_tentativo` | `esito: con_guida` |

Il frontend legge il campo `esito` dall'evento SSE e sceglie la variante. Nessuna logica complessa â€” Ã¨ un `if`.

### Animazioni di navigazione

- **Transizioni tra tab**: fluide, non istantanee â€” slide orizzontale o fade-through
- **Bottom sheet**: slide-up con spring animation (leggero rimbalzo)
- **Card espansione**: espansione inline con animazione fluida
- **Apertura sessione**: la mascotte si "sveglia", il canvas si illumina progressivamente

### Animazione speciale: Piano Onboarding (Fase 6)

Il momento wow dell'onboarding: il percorso si costruisce visivamente davanti all'utente. I nodi appaiono uno alla volta, le connessioni si disegnano, il sentiero prende forma. La mascotte accompagna con entusiasmo crescente. Questa animazione maschera la latenza del calcolo del path planner e crea il primo momento emotivo dell'esperienza.

> **Spettacolare nel contenuto, sobrio nella tecnica**: l'effetto wow viene dal significato (il TUO percorso personalizzato prende forma) non da effetti pirotecnici gratuiti.

### Implementazione

- **MVP**: AnimationController e AnimatedWidget di Flutter per le transizioni e gli stati della mascotte. Particelle con CustomPainter. Feedback aptico con HapticFeedback API
- **Iterazione**: migrazione a Rive per la mascotte (animazioni vettoriali fluide, interattive, leggere) e per le celebrazioni piÃ¹ complesse
- **Sempre**: 60fps come target, nessuna animazione che blocca l'interazione

---

# 7. Principi di Applicazione per Schermata

## Canvas di Studio (Tab Studio)

Il canvas Ã¨ lo spazio piÃ¹ importante dell'app. I principi di design si applicano diversamente in base al beat attivo.

### Principi generali

- **Sfondo scuro, contenuto luminoso**: il testo e le formule "emergono" dallo sfondo
- **Mascotte posizionata lateralmente**: non al centro, non sopra il contenuto â€” accompagna senza invadere
- **LaTeX**: dimensione generosa, centrato quando Ã¨ formula standalone, inline quando Ã¨ nel flusso del testo
- **Streaming del tutor**: il testo appare token per token con un cursore ambra che pulsa

### Beat-specific: come il canvas cambia durante la sessione

**Durante la spiegazione (Beat 2):**
Il canvas Ã¨ in modalitÃ  lettura. Massimo spazio per il testo. Le formule LaTeX emergono con un leggero fade-in. La mascotte Ã¨ piccola e discreta nell'angolo. Nessun elemento interattivo compete per l'attenzione.

**Durante l'esercizio (Beat 4):**
La card esercizio Ã¨ al centro, con bordo ambra sottile. Lo sfondo attorno si attenua leggermente (opacity ~0.7 sugli elementi non-card). Il campo input Ã¨ generoso e ben visibile. La mascotte Ã¨ pensierosa.

**Transizione errore â†’ B+C (Beat 5b):**
Il bordo della card passa da ambra a neutro in ~0.3s con ease-out. Nessun altro cambio visivo. Dal turno successivo il canvas Ã¨ identico a qualsiasi altro turno di conversazione â€” lo studente non Ã¨ etichettato come "in errore".

**Stato transizionale W1 (Beat 3.5):**
Quando il frontend riceve tool_use senza testo: shimmer effect nella zona dove apparirÃ  il contenuto (card esercizio o formula). La mascotte passa a "pensierosa". Appena il contenuto arriva, lo shimmer si dissolve e il contenuto appare con il suo beat normale.

**Promozione (Beat 6):**
Il canvas si prende una pausa di 2-3 secondi. L'esplosione di luce parte dalla card dell'ultimo esercizio e si espande. Il tutor inizia a parlare solo dopo che l'animazione Ã¨ in fase calante. La sequenza Ã¨: animazione â†’ parole del tutor che riconosce â†’ pausa â†’ introduzione nuovo nodo.

### Feedback immediato

Ogni risposta produce una reazione visiva entro 200ms â€” prima che arrivi la risposta del backend. Il frontend non aspetta l'LLM per dare un segnale. Il cambio avviene in due fasi:
1. **Fase 1 (0-200ms)**: feedback locale â€” la card "riceve" la risposta (leggera animazione di conferma invio)
2. **Fase 2 (1-3s)**: feedback semantico â€” il Beat 5a, 5b, o 5c si attiva basandosi sulla risposta dell'LLM

## Tab Percorso (Sentiero)

- Sfondo scuro, nodi come punti di luce
- Nodo attuale: glow ambra pulsante, piÃ¹ grande
- Nodi completati: luce stabile, caldi
- Nodi futuri: sagome scure, avvolte in "nebbia" (gradiente di opacitÃ )
- Il sentiero ha una verticalitÃ  narrativa â€” si scorre come un viaggio
- Separatori di area (Algebra â†’ Geometria): sottili, eleganti, non invadenti
- Quando un nodo viene promosso durante la sessione, se il tab Percorso Ã¨ visibile successivamente, il nodo appena completato ha un glow residuo ("appena acceso")

## Tab Profilo

- Ritmo lento, consultivo â€” niente pulsazioni, niente urgenza
- Card statistiche: compatte, con mini-grafici ambra su sfondo scuro
- Bacheca achievement: sagome grigie per i non sbloccati (mai vuota, piena di potenziale), colori caldi per gli sbloccati
- Lo scroll Ã¨ lungo ma fluido â€” sezioni ben separate con spazio

## Onboarding

- Canvas-centrico: il tutor parla nel canvas, non in un flusso di schermate carousel
- La mascotte Ã¨ protagonista: si presenta, si anima, guida
- Progress indicator: barra sottile ambra, morbida, non ansiogena
- Il momento del piano (Fase 6): l'animazione piÃ¹ spettacolare dell'app â€” il percorso che si costruisce visivamente

---

# 8. Riferimenti Visivi

### Cosa prendere da ciascun riferimento

| Riferimento | Cosa prendiamo | Cosa NON prendiamo |
|---|---|---|
| **Claude** | Pulizia, spazio generoso, competenza calma, tipografia chiara | La sobrietÃ  estrema â€” Dydat Ã¨ piÃ¹ giocoso |
| **Discord** | "Posto mio", dark mode calda, punti di colore come personalitÃ , senso di community | La densitÃ  informativa dei server complessi |
| **Manus** | Interfaccia moderna AI-native, design che non distrae dal contenuto | â€” |
| **Brilliant** | Gamification per adulti, percorsi visuali, animazioni celebrative (Rive), interattivitÃ  come metodo | Il tono da "sito web educativo", il paywall aggressivo |
| **Duolingo** | Il principio del feedback costante, la giocositÃ , la dipendenza positiva | L'estetica infantile, la densitÃ  visiva, il tono da cartone |
| **22 di Soul (Pixar)** | La mascotte â€” forma amorfa luminescente con personalitÃ  ricca, range emotivo completo | â€” (Ã¨ solo un riferimento di partenza, la creatura di Dydat avrÃ  la sua identitÃ ) |

---

# 9. Note per il Brief Tecnico

### Per Rocket.new / Cursor AI

Questo documento definisce la direzione visiva. Per l'implementazione:

- **Dark mode first**: costruire il tema scuro come primario, light mode come inversione secondaria
- **CSS/Design tokens**: tutti i colori come variabili/costanti del tema Flutter, mai hardcoded
- **Font**: Plus Jakarta Sans da Google Fonts, con fallback su sistema
- **LaTeX**: `flutter_math_fork` per rendering nativo, no WebView
- **Animazioni MVP**: AnimationController + CustomPainter. Rive come upgrade post-MVP
- **Mascotte MVP**: sprite/immagini statiche per gli stati base, animazione semplice di transizione tra stati. Rive per la versione fluida in iterazione successiva
- **ResponsivitÃ **: layout adattivo mobile (5.5") â†’ tablet (12.9"), canvas di studio come prioritÃ 
- **Haptic feedback**: leggero per interazioni quotidiane, forte per achievement e celebrazioni

### Implementazione celebrazione differenziata (Beat 5a vs 5c)

Il frontend riceve l'esito dell'esercizio dall'evento SSE (campo `esito` nel segnale `risposta_esercizio`). La logica Ã¨:

```
if esito == "primo_tentativo":
    â†’ celebrazione burst (Beat 5a)
elif esito == "con_guida":
    â†’ celebrazione diffusione calda (Beat 5c)
elif esito == "non_risolto":
    â†’ nessuna celebrazione, transizione gentile
```

### Implementazione stato transizionale W1

Il frontend monitora gli eventi SSE. Quando riceve un evento `azione` (tool_use) senza evento `testo` nello stesso chunk:

```
if (evento.tipo == "azione" && testo_corrente == null):
    â†’ attivare shimmer + mascotte pensierosa (Beat 3.5)
    â†’ al prossimo evento testo o azione con contenuto: dissolvi shimmer
```

### Decisioni aperte per il wireframe ad alta fedeltÃ 

| Decisione | Da definire con |
|---|---|
| Hex esatti della palette | Test su device reali (OLED vs LCD) |
| Dimensione e posizione esatta mascotte nel canvas | Wireframe ad alta fedeltÃ  |
| Animazione specifica del piano onboarding | Implementazione iterativa |
| Stile esatto delle particelle celebrative | Prototipazione |
| Tipografia per numeri/contatori gamification | Valutare se usare un weight diverso o un font numerico dedicato |
| IntensitÃ  effetto "nebbia" sui nodi futuri | Test con contenuto reale |
| Durata esatta transizione shimmer W1 | Test con latenza reale del backend |
| Differenza visiva esatta tra burst (5a) e diffusione (5c) | Prototipazione con utenti reali |

---

*Questo documento definisce la direzione visiva di Dydat â€” Passo 4 della Pipeline di Sviluppo. Si fonda sul mood "studio notturno illuminato", sulla palette Ambra e Grafite, sulla mascotte ispirata a 22 di Soul, sul principio "giocoso ma adulto", e sulla mappa emotiva a 7+1 beat validata dal test E2E manuale. Ogni decisione di implementazione che contraddice i principi qui stabiliti deve essere segnalata e discussa.*
