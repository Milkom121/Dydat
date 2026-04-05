---
name: chiusura-blocco
description: "Chiude il blocco di lavoro corrente: test, guardiano di blocco, aggiorna ROADMAP.md e handoff, riassume il lavoro. Da invocare automaticamente alla fine di ogni sessione di lavoro, SENZA che l'utente lo chieda."
user-invocable: false
---

# Chiusura blocco di lavoro — Metodo Villa

Questa skill viene invocata automaticamente quando il lavoro del blocco corrente e' completato.

## Sequenza obbligatoria

### 1. Test (L1 obbligatorio)
Eseguire i test pertinenti al lavoro svolto:
```bash
# Backend (se toccato)
cd backend && docker exec backend-backend-1 python -m pytest -x -q

# Frontend (se toccato)
cd frontend && flutter analyze && flutter test
```
Se i test falliscono, correggere i problemi PRIMA di procedere. Il blocco NON e' completato se L1 fallisce.

### 2. Guardiano di blocco (auto-review)
Checklist obbligatoria prima di procedere:
- [ ] Input sanitizzati dove serve?
- [ ] Errori gestiti (try-catch)?
- [ ] Nessun segreto hardcoded non registrato in docs/dev-shortcuts.md?
- [ ] Funzioni <=50 righe (o giustificate con commento)?
- [ ] Nessuna duplicazione?
- [ ] Nomi chiari e coerenti col progetto?
Se una scorciatoia e' stata presa, registrarla SUBITO in docs/dev-shortcuts.md.

### 3. Aggiornare ROADMAP.md
Segnare il blocco corrente come completato con:
- Checkbox [x]
- Eventuali note o problemi riscontrati

### 4. Aggiornare .claude/handoff.md
Creare/aggiornare il file `.claude/handoff.md` con formato strutturato:
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
Poi, sotto `---`, aggiungere contesto dettagliato sufficiente perche' la prossima sessione possa partire senza rileggere tutto.

### 5. Aggiornare .claude/decisions.md (se servito)
Se durante il blocco sono state prese decisioni architetturali, aggiungerle al log con:
Data | Decisione | Motivazione | Alternative Scartate

### 6. Commit e push
- Committare tutto il lavoro con un messaggio chiaro in italiano
- Pushare su origin (branch blocco/ o develop, MAI su main senza autorizzazione)

### 7. Riassunto e prompt per la prossima sessione
Comunicare all'utente in modo chiaro e conciso:
- Cosa e' stato fatto
- Se i test sono passati
- Qual e' il prossimo passo

Poi, SEMPRE, scrivere direttamente in chat il prompt handoff per la prossima sessione:

---
**Prompt per la prossima sessione** (copialo e incollalo per avviare la prossima sessione):

> Dydat — Sessione SX — Blocco BY — [titolo]
>
> PRIMA DI SCRIVERE CODICE, leggi questi file in ordine:
> 1. CLAUDE.md
> 2. PROJECT_CONFIG.md
> 3. ROADMAP.md
> 4. .claude/handoff.md
>
> COSA FARE in questa sessione:
> - Blocco Y: [descrizione concreta]
>
> GATE DI USCITA:
> - [criteri specifici e verificabili]
>
> NON fare: [lista esplicita di cose da non toccare]

---
