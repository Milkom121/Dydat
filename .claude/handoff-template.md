# Template Handoff — Metodo Villa Runner

Formato obbligatorio per .claude/handoff.md:

STATUS: CONTINUE | CHECKPOINT | PHASE_COMPLETE | ERROR | BLOCKED
PHASE: [numero fase]
BLOCK: [numero blocco]
SUMMARY: [cosa hai fatto]
NEXT: [prossimo blocco]
DECISIONS_NEEDED: [solo se CHECKPOINT/BLOCKED]
FILES_MODIFIED: [lista file]
TESTS: PASS | FAIL | SKIPPED

Status:
- CONTINUE = blocco ok, continua
- CHECKPOINT = serve decisione umana
- PHASE_COMPLETE = fase finita, review + PR
- ERROR = qualcosa rotto
- BLOCKED = manca info
