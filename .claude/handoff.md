STATUS: CONTINUE
PHASE: 10
BLOCK: B39.3.1
SUMMARY: B39.2.4 completato — Unit test integrazione estrattore profilo con 18 nuovi test su 7 scenari realistici (utente collaborativo 5/5 campi, utente parziale 2/5, off-topic, conversazione minimale, fallimento LLM con retry, confidenze miste, conversazione lunga). 488 test backend verdi, 10 skipped. Fase 2 chiusa al 100%.
NEXT: B39.3.1 — Rules-based decisor puro Python (nessun LLM, regole deterministiche)
DECISIONS_NEEDED: nessuna
FILES_MODIFIED: nessuno in questa preparazione
TESTS: PASS (488 backend verdi, 10 skipped)
VERIFICATION: B39.2.4 committato in 5bdf41b. Commit di codice del blocco gia su origin/develop.

---

## ⚠️ ISTRUZIONI CRITICHE PER LA PROSSIMA SESSIONE DEL RUNNER

### Leggi il design doc
Fonte di verita per le specs di ogni sub-blocco: **`docs/discussions/b39-onboarding-narrativo.md` sezione 7**. Leggi SEMPRE la sezione del sub-blocco che stai per eseguire prima di toccare codice.

### Avanzamento della catena
Sub-blocchi gia completati (7/38):
- ✅ Fase 1 (DB) — B39.1.1, B39.1.2, B39.1.3
- ✅ Fase 2 (Estrattore) — B39.2.1, B39.2.2, B39.2.3, B39.2.4
- ⏳ **Fase 3 (Decisore) — B39.3.1 ← TU SEI QUI**
- Resto da fare: B39.3.2, B39.4.*, B39.5.*, B39.6.*, B39.7.*, B39.8.*, B39.9.*, B39.10.*, B39.11.1

### Regola d'oro: scrivi SEMPRE il nuovo handoff a fine blocco

Dopo aver eseguito il lavoro del blocco corrente e committato il codice con un commit atomico, **devi obbligatoriamente riscrivere `.claude/handoff.md`** con il nuovo stato. Questo e il passaggio piu importante: se non aggiorni l'handoff, il runner ripartira dallo stesso blocco nella sessione successiva.

**Cosa scrivere nel nuovo handoff a fine blocco**:
- `STATUS: CONTINUE` (oppure CHECKPOINT/ERROR/BLOCKED/PHASE_COMPLETE secondo il caso)
- `BLOCK:` → il **prossimo** sub-blocco da eseguire (es. se hai appena finito B39.3.1, scrivi `BLOCK: B39.3.2`). NON lasciare il numero del blocco appena finito.
- `SUMMARY:` → cosa hai appena completato, in una o piu frasi
- `NEXT:` → descrizione breve del prossimo sub-blocco (stesso numero del BLOCK)
- Aggiorna anche il contenuto strutturato del contesto dettagliato sotto, riferendoti alla sezione pertinente del design doc

**Chi committa `.claude/handoff.md`**: il runner (funzione `commit_handoff_if_dirty`) lo fa automaticamente a fine blocco, PRIMA del push. Tu NON devi fare `git add .claude/handoff.md` ne `git commit` del file — ma **devi scriverlo**, altrimenti non c'e nulla da committare.

Stesso discorso per `docs/progress.json` e `docs/session-log.md`: il runner li aggiorna da solo, tu non li devi toccare.

### File che DEVI committare tu
- Tutti i file di codice nuovi o modificati per il blocco corrente
- Eventuali nuovi test
- Aggiornamenti a ROADMAP.md se chiudi una fase tematica

### Comandi backend utili
```
docker exec backend-backend-1 python -m pytest -x -q
docker exec backend-backend-1 python -m ruff check app/
```

---

# SUB-BLOCCO CORRENTE: B39.3.1 — Rules-based decisor puro Python

## Obiettivo
Scrivere una funzione Python pura (nessun LLM) che, dato lo stato corrente del profilo estratto + numero di turni fatti, decide la prossima mossa del tutor di onboarding. Funzione deterministica, totalmente testabile con unit test fissi.

## File da toccare
- **NUOVO o ESTENDI**: `backend/app/core/onboarding.py` — aggiungi funzione `decidi_prossima_mossa(profilo_stato, turni_fatti, fase_placement=None) -> Decisione`
- **NUOVO**: `backend/tests/test_b39_3_1_decisor.py` — unit test esaustivi sulla funzione (almeno 10 scenari)
- Eventualmente un nuovo schema Pydantic `Decisione` in `backend/app/schemas/onboarding.py` se serve

## Comportamento della funzione
Input:
- `profilo_stato`: dict o ProfiloEstratto con i 5 campi (chi_e, motivo, stile_cognitivo, tempo_disponibile, vissuto_scolastico) ognuno con valore + confidenza (alta/media/bassa), o vuoti
- `turni_fatti`: int, numero di turni narrativi gia eseguiti (per applicare il tetto di 7)
- `fase_placement`: opzionale, per estensioni future (placement test)

Output: oggetto `Decisione` con almeno:
- `azione`: enum con valori come `chiedi_campo_mancante`, `chiudi_narrativa`, `forza_chiusura_tetto_turni`, `passa_a_placement`
- `campo_da_chiedere`: optional, nome del campo mancante o a bassa confidenza (se azione == chiedi_campo_mancante)
- `motivo`: stringa di log per debug

## Regole deterministiche da implementare
1. Se **tutti e 5 i campi** sono presenti con **confidenza alta** → `chiudi_narrativa` (passa a placement se disponibile, altrimenti chiudi)
2. Se almeno **un campo obbligatorio** (chi_e, motivo, stile_cognitivo) manca o e a **bassa confidenza** → `chiedi_campo_mancante` con quel campo
3. Se i 3 obbligatori sono OK ma almeno uno dei 2 opzionali (tempo_disponibile, vissuto_scolastico) manca → `chiedi_campo_mancante` con quello
4. Se `turni_fatti >= 7` → `forza_chiusura_tetto_turni` (chiude comunque anche se profilo incompleto)
5. **Priorita tra campi mancanti**: chi_e > motivo > stile_cognitivo > tempo_disponibile > vissuto_scolastico

## Test obbligatori
Crea `backend/tests/test_b39_3_1_decisor.py` con **almeno 10 scenari**:
1. Profilo vuoto → chiedi chi_e
2. chi_e presente alta → chiedi motivo
3. chi_e + motivo presenti alta, stile_cognitivo a bassa confidenza → chiedi stile_cognitivo
4. 3 obbligatori alta, tempo_disponibile mancante → chiedi tempo_disponibile
5. 4 campi alta, vissuto_scolastico mancante → chiedi vissuto_scolastico
6. Tutti e 5 alta → chiudi_narrativa
7. Tutti e 5 ma uno a media → ok comunque (o policy a scelta, documenta)
8. Turni_fatti = 7, profilo incompleto → forza_chiusura_tetto_turni
9. Turni_fatti = 8 (oltre tetto) → forza_chiusura_tetto_turni
10. Profilo parziale ma chi_e a bassa confidenza → tratta chi_e come mancante, priorita massima

## Gate di uscita
1. Funzione `decidi_prossima_mossa` implementata, pura Python, nessuna dipendenza da LLM
2. Schema `Decisione` definito in Pydantic se necessario
3. 10+ unit test verdi nel nuovo file di test
4. **Tutti i 488+ test backend esistenti continuano a passare**
5. Ruff pulito sui file toccati
6. Commit atomico: `"B39.3.1 — Rules-based decisor puro Python per forma C adattiva"`
7. **Scrivi nuovo `.claude/handoff.md` con**:
   - `STATUS: CONTINUE`
   - `BLOCK: B39.3.2`
   - `SUMMARY: B39.3.1 completato — ...` (descrivi cosa hai fatto)
   - `NEXT: B39.3.2 — Integrazione decisore nell'endpoint /onboarding/turno`
   - Aggiorna la sezione dell'avanzamento catena (segna B39.3.1 come fatto)
8. Il runner committera handoff/progress/session-log automaticamente

## NON fare in B39.3.1
- Non toccare l'estrattore (fatto in B39.2.*)
- Non chiamare LLM da questa funzione (deve essere pura)
- Non integrare ancora il decisore nell'endpoint /onboarding/turno — quello e B39.3.2
- Non avanzare a B39.3.2 — fermati dopo il commit di questo blocco

## File da leggere a inizio sessione
1. `CLAUDE.md`
2. `PROJECT_CONFIG.md`
3. `docs/discussions/b39-onboarding-narrativo.md` (sezione 7 Fase 3 B39.3.1)
4. `.claude/handoff.md` (questo file)
5. `backend/app/schemas/onboarding.py` (schema ProfiloEstratto da B39.2.2)
6. `backend/app/core/onboarding.py` (dove aggiungere la nuova funzione)
7. `backend/app/llm/prompts/onboarding_extractor.py` (per vedere i campi del profilo da B39.2.1)
