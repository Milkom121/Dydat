# Stato Progetto, Ripresa Dopo Pausa, Dipendenze, Deployment

## Stato progetto

Ogni CLAUDE.md locale deve avere un campo "Stato" che indica lo stato attuale del progetto:

```
## Stato
- **Progetto**: [attivo | in pausa | archiviato]
- **Data ultimo aggiornamento**: YYYY-MM-DD
- **Data ultima sessione**: YYYY-MM-DD
```

Questo campo consente a Claude di capire rapidamente se il progetto è in sviluppo attivo, temporaneamente in pausa, o archiviato.

## Protocollo risveglio (per sessioni dopo pausa > 2 settimane)

Quando un progetto riprende dopo 2 o più settimane di inattività, eseguire la seguente checklist prima di iniziare il blocco effettivo:

1. **Verifica compilazione**: `cargo build` / `npm build` / equivalente — assicurarsi che il progetto compili ancora senza errori
2. **Esecuzione test**: lanciare la suite di test per verificare che non ci siano regressioni silenziose
3. **Lettura handoff**: leggere attentamente l'ultimo handoff per riprendere il contesto
4. **Verifica file citati**: assicurarsi che i file citati nel handoff esistano ancora (non siano stati spostati/cancellati)
5. **Controllo dipendenze critiche**: verificare che le dipendenze importanti (database, servizi esterni, librerie) siano ancora disponibili e funzionanti
6. **Revisione scorciatoie**: aprire `docs/dev-shortcuts.md` e verificare quante scorciatoie non risolte rimangono — se troppe, potrebbe esserci debito tecnico da gestire

Solo dopo questa checklist, procedere col blocco previsto.

## Gestione dipendenze

**Regola unificata**:

- **Versioni pinnate**: ogni dipendenza importante deve avere una versione specifica pinnata nel file di configurazione (`package.json`, `pyproject.toml`, `Cargo.toml`, etc.)
- **Giustificazione**: se una dipendenza è pinnata a una versione non ultima, aggiungere un commento che spiega il motivo (es. "# 1.4.2: versione più recente ha bug nel rendering")
- **Aggiornamenti conservativi**: non aggiornare dipendenze a meno che non sia richiesto dal blocco corrente o per risolvere vulnerabilità di sicurezza note
- **Segnalazione**: se una dipendenza è deprecata o ha vulnerabilità note, segnalarlo nel handoff perché Villa possa valutare se aggiornare

### Esempio in `package.json`:

```json
{
  "dependencies": {
    "express": "4.18.2",           // versione stabile, niente breaking change da v5
    "lodash": "4.17.21",            // pinnata, v5 ha cambi in API non compatibili
    "axios": "1.6.0"                // ultimo, aggiornabile quando spunta una fix
  }
}
```

## Deployment — Template minimale

Ogni progetto che si prevede di deployare deve documentare il deployment nel CLAUDE.md:

```markdown
## Deployment

### Dove si deploya
- Ambienti: [sviluppo | staging | produzione]
- Hosting: [AWS | DigitalOcean | Docker on Server | Vercel | altro]
- Domini: [lista domini usati]

### Comandi deployment
[comandi esatti per fare il deploy, copia-incolla pronti]

### Checklist pre-deploy
- [ ] Tutti i test passano localmente
- [ ] docs/dev-shortcuts.md: zero voci ad alta priorità irrisolte
- [ ] Environment variables configurate su target environment
- [ ] Database migrations eseguite (se applicabile)
- [ ] Backup del database precedente (se applicabile)

### Rollback
[Procedura per rollare indietro di una versione, in caso di problema]
```

## Gestione errori e sessioni interrotte

### Blocco a metà

Se la sessione finisce nel mezzo di un blocco:
- Nella roadmap: marcare con 🔄 le voci in corso, ⬚ quelle ancora da fare
- Nel "Prossimo passo": elencare esattamente i file già scritti e quelli mancanti
- Se ci sono test che falliscono o problemi aperti, documentarli esplicitamente

Se fallita: commit su branch `wip/` con nota nel handoff.

Il pattern di branch `wip/` per sessioni fallite è pragmatico e consente di non perdere il lavoro parziale.

### Log delle decisioni

**OBBLIGATORIO in ogni progetto**. Claude genera automaticamente il log a fine sessione nel file `.claude/decisions.md` del progetto. Formato strutturato con quattro colonne:

```
| Data | Decisione | Motivazione | Alternative scartate |
|------|-----------|-------------|----------------------|
| YYYY-MM-DD | Cosa si è deciso | Perché questa scelta | Cosa si è valutato e scartato |
```

### Esempio:

```
| 2026-02-18 | Docker Compose per ambiente dev | Isolamento completo dall'host, riproducibilità | Venv locale (troppo fragile), Podman (meno supportato) |
| 2026-02-18 | JSONB esplicito ovunque | Evitare ambiguità JSON vs JSONB in PostgreSQL | JSON generico (manca indicizzazione), TEXT (niente validazione) |
```

La colonna "Alternative scartate" è fondamentale: evita che in sessioni future si riconsiderino opzioni già valutate e scartate con buone ragioni.
