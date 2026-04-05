# Commit, Branching, Naming, Lingua

## Commit policy

**Regola unificata per tutti i progetti**:

- **Commit autonomi su branch `develop`** quando i test passano. Claude non deve chiedere autorizzazione per committare sul proprio branch di lavoro o su develop.
- **Messaggi di commit in italiano**, descrittivi e discorsivi. Non serve il formato Conventional Commits — il messaggio deve spiegare chiaramente cosa è stato fatto e perché, in linguaggio naturale.
- **Branch nuovo per ogni blocco/task**. Formato: `blocco/nome-descrittivo` (es. `blocco/autenticazione-jwt`, `blocco/fix-dashboard-mobile`).
- **PR da develop verso main** alla fine di ogni fase (non di ogni blocco). La PR raccoglie tutti i blocchi della fase.
- **Merge su main solo con autorizzazione esplicita di Villa**. Questa è l'unico momento in cui serve il via libera umano.

### Esempio di messaggio di commit:

```
Implementato il sistema di login con JWT e gestione refresh token.
Aggiunto middleware di autenticazione su tutte le route protette.
Test: 12 nuovi test, tutti verdi. Blocco B4 completato.
```

## Branching — Flusso standard

**Flusso unificato**:

```
main (stabile, solo merge autorizzati da Villa)
  └── develop (integrazione, commit autonomi di Claude)
       ├── blocco/nome-descrittivo-1 (sessione 1)
       ├── blocco/nome-descrittivo-2 (sessione 2)
       └── ...
```

- Ogni sessione crea un branch `blocco/` da `develop`
- A fine blocco, merge su `develop` (autonomo se test passano)
- A fine fase, PR da `develop` verso `main` (serve autorizzazione Villa)
- Per bug fix urgenti: `fix/descrizione` da `develop`

## Convenzioni di naming nel codice

**Regola valida per tutti i progetti**:

| Cosa | Lingua | Esempio |
|------|--------|---------|
| Variabili, funzioni, classi | Inglese | `getUserById`, `PatientModel` |
| Commenti nel codice | Italiano | `// Calcola lo streak di giorni consecutivi` |
| Documentazione tecnica | Italiano | README, CLAUDE.md, docs/ |
| Stringhe UI mostrate all'utente | Italiano | `"Benvenuto"`, `"Errore di connessione"` |
| Messaggi di commit | Italiano | `"Aggiunto sistema di notifiche push"` |

## Migrazione da .cursorrules

Villa è migrato al 100% a Claude Code. Tutti i file `.cursorrules` eventualmente presenti nei progetti devono essere migrati a `CLAUDE.md` e poi rimossi. Il CLAUDE.md è l'unica fonte di verità per le istruzioni all'agente.

## Disciplina di sviluppo

Regole presenti in quasi tutti i progetti:

- **Mai pushare chiavi API, password o segreti**
- **Mai fare refactoring "bonus" non richiesto**
- **Non modificare file che non c'entrano con il blocco corrente**
- **Non aggiungere documentazione/commenti a codice che non stai modificando**
- **Non costruire feature future "perché serviranno"** — solo il blocco corrente
- **Non aggiungere dipendenze senza motivo esplicito**
