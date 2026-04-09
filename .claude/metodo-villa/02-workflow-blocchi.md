# Workflow a Blocchi — Il Cuore del Metodo

## Regola fondamentale

Ogni sessione di lavoro corrisponde a UN SINGOLO BLOCCO della roadmap. Non fare più di un blocco per sessione. Questo protegge la qualità del lavoro e previene la saturazione del contesto.

Esattamente UN blocco per sessione. I blocchi devono essere progettati piccoli — dimensionati per non saturare la context window. Se un blocco sembra troppo grande, va spezzato in sotto-blocchi nella roadmap prima di iniziare la sessione, non durante.

**Chiarimento su "sessione" nel contesto del ciclo automatico**: Nel contesto del ciclo automatico, ogni esecuzione di un blocco equivale a una sessione. La regola resta: un blocco per esecuzione.

## Apertura sessione — Protocollo standard

Il flusso di apertura è coerente in tutti i progetti. Versione unificata:

1. **Leggere CLAUDE.md** del progetto (convenzioni, regole specifiche)
2. **Leggere PROJECT_CONFIG.md** (stack, stato, comandi, deployment)
3. **Leggere la ROADMAP** (`ROADMAP.md`)
4. **Leggere il file di stato/handoff** se esiste (`docs/handoff.md` — spostato da `.claude/` nel 2026-04-09)
5. **Leggere documenti di riferimento** indicati nel "prossimo passo"
6. **Solo dopo, iniziare a scrivere codice**

Leggere i file esistenti che il nuovo blocco deve usare o estendere. Solo dopo, iniziare a scrivere codice.

## Durante la sessione

Regole comuni a tutti i progetti:

- **Focalizzarsi sul blocco corrente** — non divagare
- **Leggere un file PRIMA di modificarlo**
- **Verificare che compili** dopo ogni modifica significativa
- **Non creare sistemi non richiesti dal blocco corrente**
- **Non inseguire la perfezione** — il progetto deve funzionare, non essere perfetto

## Chiusura sessione — Checklist obbligatoria

La chiusura è il momento più critico. Ogni progetto la definisce, qui la versione unificata:

1. **Verifica tecnica**: build/compile/analyze deve passare
2. **Test**: eseguire i test pertinenti al blocco
3. **Guardiano di blocco**: auto-review del codice scritto
4. **Aggiornare la roadmap**: segnare il blocco come completato
5. **Aggiornare il file di stato/handoff**: cosa è stato fatto, problemi aperti, prossimo passo
6. **Aggiornare decisions.md**: se sono state prese decisioni architetturali
7. **Comunicare all'utente** un riassunto chiaro
8. **Generare il prompt per la sessione successiva** — copia-incolla pronto

Questo prompt è l'UNICA cosa che il fondatore deve incollare per avviare la sessione successiva.

## Il prompt di handoff — Formato standard

Formato unificato adottato per tutti i progetti:

```
[NomeProgetto] — Sessione SX — Blocco BY [+BZ] — [titolo]
NOME SESSIONE: [NomeProgetto] — BY[+BZ] — [attivita]

PRIMA DI SCRIVERE CODICE, leggi questi file in ordine:
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md
4. docs/handoff.md
5. [altri file rilevanti]

COSA FARE in questa sessione:
- Blocco Y: [descrizione concreta]

GATE DI USCITA:
- [criteri specifici e verificabili]

NON fare: [lista esplicita di cose da non toccare]
```

## Test manuali — Quando servono

Valuta a fine sessione se servono test manuali e comunicalo all'utente.

Formato unificato:

```
---------------------------------------------
FONDATORE: SERVE TEST MANUALE
---------------------------------------------
Cosa testare:
1. [azione concreta]
2. [azione concreta]

Cosa mi aspetto:
- [risultato atteso per ogni punto]

Se qualcosa non funziona:
- Mandami uno screenshot o descrivi cosa vedi
---------------------------------------------
```

Non procedere al passo successivo finche il fondatore non conferma l'esito del test.
