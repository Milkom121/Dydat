STATUS: CONTINUE
PHASE: 10
BLOCK: B39.1.1
SUMMARY: Catena notturna B39 Onboarding Narrativo — 38 sub-blocchi in 11 fasi. Primo sub-blocco: migrazione Alembic per aggiungere onboarding_stato e lingua_preferita alla tabella utenti. Design doc completo in docs/discussions/b39-onboarding-narrativo.md.
NEXT: B39.1.1 — Migrazione Alembic per nuovi campi utente
DECISIONS_NEEDED: nessuna — tutte le decisioni strategiche sono in docs/discussions/b39-onboarding-narrativo.md
FILES_MODIFIED: nessuno in questa preparazione
TESTS: PASS (377 backend verdi, 10 skipped, 588 frontend verdi, analyze 0)
VERIFICATION: baseline verde su develop dopo test pre-lancio

---

## ⚠️ ISTRUZIONI CRITICHE PER IL RUNNER NOTTURNO — CATENA B39

### Branch
Lavora su **`develop`**. NON cambiare branch. Commit autonomi su develop sono OK (Metodo Villa). Auto-push su develop a fine di ogni sub-blocco stabile e automatico (gia configurato nel runner).

### Catena lunga — 38 sub-blocchi in sequenza
Questa sessione runner deve eseguire **38 sub-blocchi di B39 Onboarding Narrativo** in sequenza. Il runner andra avanti finche i test restano verdi. Si fermera solo su ERROR, CHECKPOINT, BLOCKED, o a completamento totale (PHASE_COMPLETE).

### Il design doc e la tua bibbia
**FONTE DI VERITA PRINCIPALE**: `docs/discussions/b39-onboarding-narrativo.md`.

Questo file contiene:
- Le 12 decisioni di design prese con il fondatore (sezioni 3)
- L'esempio concreto di come sara l'onboarding (sezione 4)
- Cosa va toccato nel codice (sezione 5)
- **Il piano dei 38 sub-blocchi con specs per ognuno** (sezione 7)
- I vincoli architetturali (sezione 10)

**Prima di eseguire qualsiasi sub-blocco, LEGGI la sezione 7 del design doc e trova lo specifico sub-blocco (es. B39.1.1) con obiettivo, file, test, gate di uscita.**

### Flusso per ogni sub-blocco
1. Leggi `docs/discussions/b39-onboarding-narrativo.md` sezione 7, trova il sub-blocco corrente
2. Leggi CLAUDE.md, PROJECT_CONFIG.md, e gli altri file citati nel sub-blocco
3. Esegui il lavoro del sub-blocco (modifica/crea file, scrivi test, ecc.)
4. Esegui i test obbligatori e verifica che passino
5. Commit atomico con messaggio descrittivo in italiano (es. "B39.1.1 — Migrazione Alembic: onboarding_stato + lingua_preferita")
6. Scrivi nuovo handoff con STATUS: CONTINUE e NEXT che indica il **prossimo sub-blocco nella sequenza** (consulta la sezione 7 del design doc per l'ordine)
7. Il runner rileggera l'handoff e lancerà la prossima sessione per il prossimo sub-blocco

### Ordine dei sub-blocchi (per riferimento)
Fase 1 — B39.1.1, B39.1.2, B39.1.3
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

Al completamento di B39.11.1 scrivi `STATUS: PHASE_COMPLETE`, e il runner si ferma.

### Regole generali per la catena
- **UN sub-blocco per sessione** — non tentare di fare piu sub-blocchi insieme, anche se sembrano piccoli. Il punto dei sub-blocchi piccoli e mantenere il contesto pulito per ogni sessione Claude.
- **Commit atomico per sub-blocco** — ogni sub-blocco ha il suo commit, non mescolare modifiche di sub-blocchi diversi
- **Test verdi obbligatori** — ogni sub-blocco chiude con tutti i test esistenti + i suoi nuovi test in verde. Se i test falliscono, STATUS: ERROR e il runner si ferma
- **Non avanzare con test rotti** — mai CONTINUE con test falliti
- **Non anticipare altri sub-blocchi** — se stai facendo B39.2.3 e ti viene voglia di toccare anche B39.3.1, NON farlo. Rispetta la segmentazione
- **Consulta il design doc per dubbi** — e la fonte di verita. Se il sub-blocco non e chiaro, rileggi la sezione pertinente invece di improvvisare
- **Scorciatoie**: se introduci debito (es. mock temporaneo, segreto hardcoded), registralo in `docs/dev-shortcuts.md`
- **Aggiorna ROADMAP.md** a completamento di ogni fase tematica (non per ogni sub-blocco, solo quando passi da Fase N a Fase N+1)

### In caso di ERROR o BLOCKED
Se un sub-blocco si rompe:
- STATUS: ERROR se qualcosa e rotto tecnicamente e non riesci a fixare
- STATUS: BLOCKED se manca informazione per procedere
- STATUS: CHECKPOINT se serve decisione umana su un trade-off
- In tutti i casi, descrivi chiaramente nel SUMMARY cosa e successo e cosa serve per ripartire
- Il runner si ferma e Villa interviene la mattina dopo

### Dipendenze tra sub-blocchi
- **B39.1.** deve venire prima di tutto il resto (DB foundation)
- **B39.2.** dipende da B39.1. (usa i nuovi campi modello)
- **B39.3.** dipende da B39.2. (usa l'estrattore)
- **B39.4.** dipende da B39.3. (fix del completa_onboarding usa l'estrattore e il decisore)
- **B39.5.** (STT) e relativamente indipendente, ma deve venire prima di B39.7. (widget)
- **B39.6.** (placement backend) dipende da B39.3. (decisore)
- **B39.7.** (widget voce) dipende da B39.5. (endpoint STT)
- **B39.8.** (integrazione onboarding frontend) dipende da B39.3., B39.4., B39.7.
- **B39.9.** (banner home) dipende da B39.1. (campo onboarding_stato) e B39.8. (skip)
- **B39.10.** (voce trasversale) dipende da B39.7. (widget)
- **B39.11.1** (checklist manuale) e l'ultimo

**Rispetta l'ordine sequenziale.** Non tentare di eseguire blocchi fuori sequenza anche se tecnicamente possibile.

---

## Stato baseline al lancio
- Branch: `develop` (allineato a origin dopo push)
- Backend: 377 test verdi, 10 skipped
- Frontend: 588 test verdi, analyze 0
- Design doc: `docs/discussions/b39-onboarding-narrativo.md` v1.0 completo
- Note di discovery: `docs/discussions/b39-discovery-notes.md` complete

---

# SUB-BLOCCO CORRENTE: B39.1.1 — Migrazione Alembic per nuovi campi utente

## Obiettivo
Aggiungere due nuovi campi alla tabella `utenti`:
1. `onboarding_stato` — enum con valori `not_started`, `in_progress`, `completed`. Default `not_started`.
2. `lingua_preferita` — stringa opzionale, default `it`.

## File da creare/modificare
- **NUOVO**: `backend/alembic/versions/<timestamp>_add_onboarding_stato_and_lingua_preferita.py` — migrazione Alembic (il nome file segue la convenzione Alembic, genera con `alembic revision --autogenerate -m "..."` oppure manualmente)
- Eventualmente: `backend/app/db/models/utenti.py` se serve aggiornare il modello per permettere l'autogenerate (ma il modello formale sara aggiornato in B39.1.2, qui basta la migrazione)

## Specifiche migrazione
- Nome migrazione: `add_onboarding_stato_and_lingua_preferita`
- `upgrade()`:
  - Aggiungi colonna `onboarding_stato` con tipo Enum PostgreSQL (`'not_started', 'in_progress', 'completed'`) NOT NULL default `'not_started'`
  - Aggiungi colonna `lingua_preferita` con tipo `VARCHAR` lunghezza ragionevole (es. 10) NOT NULL default `'it'`
- `downgrade()`:
  - Drop colonna `onboarding_stato`
  - Drop colonna `lingua_preferita`
  - Drop enum type `onboarding_stato_enum` se creato esplicitamente

## Test
- Applicare la migrazione nell'ambiente docker locale: `docker exec backend-backend-1 alembic upgrade head`
- Verificare che la colonna sia presente: query di controllo SQL o ispezione con psql
- Verificare che il rollback funzioni: `alembic downgrade -1` → verifica assenza colonne → `alembic upgrade head`
- **Tutti i 377 test backend esistenti continuano a passare** dopo la migrazione applicata

## Gate di uscita
1. Migrazione creata e applicata con successo
2. Upgrade e downgrade funzionanti (verificati)
3. Tutti i test backend continuano a passare
4. Commit atomico: `"B39.1.1 — Migrazione Alembic: onboarding_stato + lingua_preferita"`
5. Push automatico su develop (gia configurato nel runner)
6. Scrivi nuovo handoff con:
   - STATUS: CONTINUE
   - BLOCK: B39.1.2
   - NEXT: B39.1.2 — Aggiornamento modello SQLAlchemy Utente
   - Consulta `docs/discussions/b39-onboarding-narrativo.md` sezione 7 Fase 1 per le specs del prossimo sub-blocco

## NON fare in B39.1.1
- Non modificare il modello SQLAlchemy `Utente` in modo sostanziale — la migrazione crea le colonne, il modello Python le espone in B39.1.2
- Non toccare codice API o core
- Non avanzare a B39.1.2 — fermati qui dopo il commit

## File da leggere a inizio sessione
1. `CLAUDE.md`
2. `PROJECT_CONFIG.md`
3. `docs/discussions/b39-onboarding-narrativo.md` **(sezione 7 Fase 1 e sezione 5.1 Database)**
4. `.claude/handoff.md` (questo file)
5. `backend/alembic/versions/` (dai un'occhiata alle migrazioni esistenti per seguire lo stesso stile)
6. `backend/app/db/models/utenti.py` (per capire la struttura attuale della tabella)
