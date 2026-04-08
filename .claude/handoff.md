STATUS: CONTINUE
PHASE: 10
BLOCK: B39.2.4
SUMMARY: B39.2.3 completato — Funzione estrai_profilo con chiamata Opus e retry (ca67488). Prossimo: B39.2.4, unit test integrazione estrattore. Catena B39 Onboarding Narrativo in corso, 6 sub-blocchi su 38 completati (B39.1.1, B39.1.2, B39.1.3, B39.2.1, B39.2.2, B39.2.3). Handoff ripristinato dopo stop manuale del runner per patch al meccanismo di commit stato.
NEXT: B39.2.4 — Unit test integrazione estrattore (5+ scenari con mock LLM)
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: nessuno in questa preparazione
TESTS: PASS (vedi ultimo commit di codice per il count — baseline post-B39.2.3)
VERIFICATION: handoff ripristinato dopo stop manuale. Codice dei 6 sub-blocchi precedenti e tutto committato e pushato. Il runner e stato patchato per committare automaticamente i file di stato (handoff+progress+session-log) a fine di ogni blocco stabile.

---

## ⚠️ NOTA IMPORTANTE PER IL RUNNER (RIPARTENZA DOPO STOP)

Il 2026-04-09 la catena B39 e stata fermata manualmente da Villa dopo ~7 sessioni per un problema di sincronizzazione dell'handoff: alcune sessioni committavano il codice ma NON committavano `.claude/handoff.md` insieme, lasciando lo stato del runner disallineato dai commit git. Il file arrivava a dire "B39.2.1 completato" mentre git aveva gia "B39.2.3".

**Patch applicata**: `metodo-villa-runner.sh` ora include una funzione `commit_handoff_if_dirty` che viene chiamata automaticamente dopo ogni blocco stabile (CONTINUE/CHECKPOINT/PHASE_COMPLETE/BLOCKED), PRIMA del push. Questa funzione committa `.claude/handoff.md` + `docs/progress.json` + `docs/session-log.md` con un messaggio standard "Runner: aggiorna stato post blocco (...)".

**Conseguenza per Claude in ogni sessione**: NON e piu necessario che Claude committi handoff/progress/session-log manualmente. Puo farlo come parte del proprio commit di codice (se e' logico), oppure lasciarli dirty e il runner li committera automaticamente a fine sessione. La cosa importante e che il CODICE del blocco venga committato da Claude, il resto lo sistema il runner.

---

## ⚠️ ISTRUZIONI CRITICHE PER IL RUNNER — CATENA B39 (in corso)

### Branch
Lavora su **`develop`**. Tutto committato e pushato fino a B39.2.3 compreso. Auto-push gia configurato.

### Il design doc e la tua bibbia
**FONTE DI VERITA PRINCIPALE**: `docs/discussions/b39-onboarding-narrativo.md`.

Questo file contiene:
- Le 12 decisioni di design prese con il fondatore (sezione 3)
- L'esempio concreto di come sara l'onboarding (sezione 4)
- Cosa va toccato nel codice (sezione 5)
- **Il piano dei 38 sub-blocchi con specs per ognuno** (sezione 7)
- I vincoli architetturali (sezione 10)

**Prima di eseguire qualsiasi sub-blocco, LEGGI la sezione 7 del design doc e trova lo specifico sub-blocco (es. B39.2.4) con obiettivo, file, test, gate di uscita.**

### Stato di avanzamento della catena
- ✅ B39.1.1 — Migrazione Alembic (onboarding_stato + lingua_preferita) — commit: a1b2c3d4e5f6 (migrazione) + 148c336
- ✅ B39.1.2 — Modello SQLAlchemy Utente — commit: 148c336
- ✅ B39.1.3 — Schema Pydantic UtenteResponse — commit: b12bd73 / b41715c (9 test contract)
- ✅ B39.2.1 — Prompt estrattore profilo in `onboarding_extractor.py` — commit: 3bb4e41 (21 test)
- ✅ B39.2.2 — Schema Pydantic `CampoConConfidenza`/`ProfiloEstratto` — commit: b114e34
- ✅ B39.2.3 — Funzione `estrai_profilo` con chiamata Opus e retry — commit: ca67488
- ⏳ **B39.2.4** — Unit test integrazione estrattore ← **TU SEI QUI**
- Da fare: B39.3.1 in poi (vedi sezione 7 del design doc)

### Flusso per ogni sub-blocco
1. Leggi `docs/discussions/b39-onboarding-narrativo.md` sezione 7, trova il sub-blocco corrente
2. Leggi CLAUDE.md, PROJECT_CONFIG.md, e gli altri file citati nel sub-blocco
3. Esegui il lavoro del sub-blocco (modifica/crea file, scrivi test, ecc.)
4. Esegui i test obbligatori e verifica che passino
5. Commit atomico del codice con messaggio descrittivo in italiano (es. "B39.2.4 — Unit test integrazione estrattore")
6. Scrivi nuovo `.claude/handoff.md` con STATUS: CONTINUE e NEXT che indica il **prossimo sub-blocco nella sequenza** (consulta la sezione 7 del design doc per l'ordine)
7. Il runner committera automaticamente handoff/progress/session-log con la nuova funzione `commit_handoff_if_dirty`

### Regole generali per la catena
- **UN sub-blocco per sessione** — non tentare di fare piu sub-blocchi insieme
- **Commit atomico del codice** — ogni sub-blocco ha il suo commit di codice separato
- **Test verdi obbligatori** — ogni sub-blocco chiude con tutti i test esistenti + i suoi nuovi test in verde. Se i test falliscono, STATUS: ERROR e il runner si ferma
- **Non anticipare altri sub-blocchi** — rispetta la segmentazione
- **Consulta il design doc per dubbi** — e la fonte di verita

---

# SUB-BLOCCO CORRENTE: B39.2.4 — Unit test integrazione estrattore

## Obiettivo
Aggiungere test di integrazione della funzione `estrai_profilo` (gia scritta in B39.2.3) che verifichino il comportamento su scenari realistici, usando mock LLM con JSON prefabbricati.

## File da creare/modificare
- **NUOVO** (o ESTENDI se esiste): `backend/tests/test_b39_2_4_extractor_integration.py` (oppure estensione di `test_b39_2_3_extractor_function.py` se gia esiste — verifica)

## Scenari da coprire (almeno 5)
1. **Utente collaborativo ricco**: conversazione completa con 5 campi estratti ad alta confidenza
2. **Utente parziale**: conversazione dove l'estrattore trova solo 2-3 campi, gli altri mancanti
3. **Utente off-topic**: conversazione con messaggi irrilevanti, estrattore ritorna profilo quasi vuoto
4. **Conversazione vuota o minimale**: solo un messaggio del tutor, estrattore gestisce il caso senza crash
5. **Fallimento LLM**: mock che ritorna JSON malformato alla prima chiamata, estrattore esegue retry e poi ritorna profilo vuoto (verifica la retry logic gia implementata in B39.2.3)

Bonus (se il tempo lo permette):
6. Utente con contenuto a confidenza mista (alcuni campi alta, altri bassa)
7. Estrazione con conversazione molto lunga (molti turni)

## Specifiche test
- Usa `unittest.mock.patch` o pytest-mock per mockare la chiamata al client Anthropic
- I mock ritornano oggetti/risposte realistiche (non solo stringhe)
- Ogni test verifica: struttura output (ProfiloEstratto), campi corretti, confidenze corrette, nessun crash
- **Marcato come unit test** (non `@pytest.mark.integration`), deve girare nel CI senza chiamate LLM reali

## Test
- Almeno 5 nuovi test (uno per ogni scenario sopra) verdi
- **Tutti i test backend esistenti continuano a passare**
- Ruff pulito sui file modificati
- `docker exec backend-backend-1 python -m pytest -x -q` verde

## Gate di uscita
1. File di test creato/esteso con 5+ nuovi test
2. Tutti i test verdi
3. Commit atomico del codice: `"B39.2.4 — Unit test integrazione estrattore"`
4. Scrivi nuovo handoff con:
   - STATUS: CONTINUE
   - BLOCK: B39.3.1 (prossimo sub-blocco)
   - SUMMARY: descrizione sintetica di cosa hai fatto
   - NEXT: B39.3.1 — Rules-based decisor puro Python
   - Consulta `docs/discussions/b39-onboarding-narrativo.md` sezione 7 Fase 3 per le specs del prossimo sub-blocco
5. Il runner committera automaticamente handoff/progress/session-log (non devi pensarci tu)

## NON fare in B39.2.4
- Non toccare la funzione `estrai_profilo` — e gia fatta in B39.2.3
- Non scrivere nuovi prompt — il prompt estrattore e gia in B39.2.1
- Non avanzare a B39.3.1 — fermati qui dopo il commit

## File da leggere a inizio sessione
1. `CLAUDE.md`
2. `PROJECT_CONFIG.md`
3. `docs/discussions/b39-onboarding-narrativo.md` (sezione 7 Fase 2 B39.2.4)
4. `.claude/handoff.md` (questo file)
5. `backend/app/llm/prompts/onboarding_extractor.py` (prompt da B39.2.1 — per capire l'output atteso)
6. `backend/app/schemas/onboarding.py` (schema ProfiloEstratto da B39.2.2)
7. `backend/app/core/onboarding.py` o dove vive `estrai_profilo` (funzione da B39.2.3 — per capire cosa testare)
8. Test esistenti di B39.2.3 (se ci sono, per non duplicare)
