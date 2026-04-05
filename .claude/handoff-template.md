# Template Handoff — Metodo Villa Runner

Formato obbligatorio per .claude/handoff.md:

```
STATUS: CONTINUE | CHECKPOINT | PHASE_COMPLETE | ERROR | BLOCKED
PHASE: [numero fase]
BLOCK: [numero blocco]
SUMMARY: [cosa hai fatto]
NEXT: [prossimo blocco]
DECISIONS_NEEDED: [solo se CHECKPOINT/BLOCKED]
FILES_MODIFIED: [lista file]
TESTS: PASS | FAIL | SKIPPED
```

Status:
- CONTINUE = blocco ok, continua al prossimo
- CHECKPOINT = serve decisione umana
- PHASE_COMPLETE = fase finita, review + PR
- ERROR = qualcosa rotto
- BLOCKED = manca info

Dopo l'header strutturato, aggiungere `---` e poi una sezione di contesto dettagliato:

```
---

## Contesto dettagliato

### Cosa e stato fatto
- [elenco concreto delle modifiche]

### Stato del progetto
- [metriche: test, build, errori noti]

### Prossimo passo concreto
- [descrizione dettagliata del prossimo blocco]

### File da leggere per la prossima sessione
1. CLAUDE.md
2. PROJECT_CONFIG.md
3. ROADMAP.md
4. .claude/handoff.md
5. [altri file rilevanti]
```
