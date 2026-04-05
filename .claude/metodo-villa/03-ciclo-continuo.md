# Automazione del Ciclo e Checkpoint

## Esecuzione automatica dei blocchi

Il workflow a blocchi può essere automatizzato con diversi livelli di sofisticazione:

- **Claude Code `/loop`** — comando nativo per scheduling di task ripetitivi dentro la sessione. Utile per ripetere operazioni all'interno di un singolo blocco, non per orchestrare blocchi in sequenza.
- **Ralph Loop** (plugin Claude Code) — intercetta la fine di una sessione e rilancia automaticamente il blocco successivo, mantenendo contesto e storia git. È il livello di automazione più naturale per il Metodo Villa.
- **Continuous Claude v3** — sistema più avanzato con gestione stato persistente tramite "ledger" e orchestrazione multi-agente. Adatto a progetti grandi con blocchi interdipendenti e necessità di parallelismo.

## Decisione: Ciclo semi-automatico

I blocchi si susseguono automaticamente se i test passano. Il ciclo si ferma ai checkpoint obbligatori (fine fase, test falliti, decisioni architetturali non previste) e notifica Villa. Questo preserva il principio del pensiero critico — Claude si ferma quando c'è qualcosa su cui riflettere — senza richiedere a Villa di fare copia-incolla ogni volta.

## Checkpoint obbligatori nel ciclo

Indipendentemente dal livello di automazione scelto, ci sono momenti in cui il ciclo DEVE fermarsi e richiedere validazione umana:

### Stop obbligatorio — il ciclo si ferma e aspetta Villa:

- Prima di commit/push su branch principali (`main`, `develop`)
- Prima di passare da una fase del progetto alla successiva (es. da Loop 1 a Loop 2, da sviluppo a testing)
- Quando un test fallisce e il fix non è banale
- Quando il blocco richiede decisioni architetturali non previste dalla roadmap
- Quando il contesto si avvicina al 60% della finestra (rischio perdita di contesto)
- Quando emergono dubbi che richiedono il pensiero critico

### Avanzamento automatico — il ciclo procede senza intervento:

- Tra blocchi della stessa fase, se tutti i test passano
- Dopo aggiornamento automatico di roadmap e handoff
- Dopo commit su feature branch (se la commit policy del progetto lo permette)

**Principio**: automatizzare il meccanico, fermarsi sull'intelligente. Se il blocco è routine e i test passano, il ciclo avanza. Se serve una decisione, il ciclo si ferma.
