STATUS: CONTINUE
PHASE: 10
BLOCK: B39.1.2
SUMMARY: B39.1.1 completato — Migrazione Alembic a1b2c3d4e5f6 per onboarding_stato (enum not_started/in_progress/completed) e lingua_preferita (varchar 10, default it) sulla tabella utenti. Upgrade, downgrade e re-upgrade verificati via psql. 377 test backend verdi, 10 skipped.
NEXT: B39.1.2 — Aggiornamento modello SQLAlchemy Utente
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: backend/alembic/versions/a1b2c3d4e5f6_add_onboarding_stato_and_lingua_preferita.py
TESTS: PASS (377 backend verdi, 10 skipped)
VERIFICATION: 377 passed, 10 skipped. Migrazione upgrade/downgrade/re-upgrade testata. Schema verificato via psql.

---

## ISTRUZIONI CRITICHE PER IL RUNNER NOTTURNO — CATENA B39

### Branch
Lavora su **develop**. NON cambiare branch.

### Il design doc e la tua bibbia
**FONTE DI VERITA PRINCIPALE**: docs/discussions/b39-onboarding-narrativo.md

### Ordine dei sub-blocchi
Fase 1 — B39.1.1 (DONE), B39.1.2, B39.1.3
Fase 2 — B39.2.1, B39.2.2, B39.2.3, B39.2.4
Fase 3 — B39.3.1, B39.3.2
Fase 4 — B39.4.1, B39.4.2, B39.4.3
Fase 5 — B39.5.1, B39.5.2, B39.5.3
Fase 6 — B39.6.1, B39.6.2, B39.6.3, B39.6.4, B39.6.5, B39.6.6
Fase 7 — B39.7.1, B39.7.2, B39.7.3, B39.7.4, B39.7.5, B39.7.6
Fase 8 — B39.8.1, B39.8.2, B39.8.3, B39.8.4
Fase 9 — B39.9.1, B39.9.2, B39.9.3
Fase 10 — B39.10.1, B39.10.2, B39.10.3
Fase 11 — B39.11.1 (ultimo)

### Regole generali
- UN sub-blocco per sessione
- Commit atomico per sub-blocco
- Test verdi obbligatori prima di CONTINUE
- Consulta il design doc per dubbi
- Aggiorna ROADMAP.md a completamento di ogni fase tematica

---

## Stato baseline
- Branch: develop (pushato dopo B39.1.1)
- Backend: 377 test verdi, 10 skipped
- Frontend: 588 test verdi, analyze 0

---

# SUB-BLOCCO CORRENTE: B39.1.2 — Aggiornamento modello SQLAlchemy Utente

## Obiettivo
Esporre i nuovi campi onboarding_stato e lingua_preferita nel modello Python Utente in backend/app/db/models/utenti.py.

## Specifiche
- onboarding_stato: tipo Enum SQLAlchemy mappato a onboarding_stato_enum PostgreSQL. Default not_started.
- lingua_preferita: tipo String(10). Default it.
- Entrambi NOT NULL con server_default coerente con la migrazione.

## Test
- Unit test che verifica accesso ai nuovi campi con default
- Tutti i 377 test backend esistenti continuano a passare

## Gate di uscita
1. Modello aggiornato con i due nuovi campi
2. Test nuovi + esistenti verdi
3. Commit atomico
4. Handoff con NEXT: B39.1.3

## NON fare
- Non toccare API o schemi Pydantic (quello e B39.1.3)
- Non avanzare a B39.1.3

## File da leggere
1. CLAUDE.md, PROJECT_CONFIG.md
2. docs/discussions/b39-onboarding-narrativo.md (sezione 7 Fase 1)
3. backend/app/db/models/utenti.py
4. backend/alembic/versions/a1b2c3d4e5f6_add_onboarding_stato_and_lingua_preferita.py
