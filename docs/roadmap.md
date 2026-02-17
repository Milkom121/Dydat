# Dydat Backend — Roadmap di sviluppo

> Aggiornamento: 2026-02-17
> Legenda: ⬚ da fare | 🔄 in corso | ✅ completato

---

## Blocco 1: Foundation (Sessione 1)

Setup progetto, Docker, database, struttura codice.

- ✅ `.gitignore`
- ✅ `pyproject.toml` con tutte le dipendenze
- ✅ `.env.example`
- ✅ `Dockerfile` (Python 3.12-slim)
- ✅ `docker-compose.yml` (backend + PostgreSQL 16)
- ✅ Struttura directory completa (`app/`, `tests/`, `scripts/`, `data/`)
- ✅ `app/config.py` (pydantic-settings)
- ✅ `app/db/engine.py` + `app/db/base.py`
- ✅ Modelli SQLAlchemy — tutte le 17 tabelle (4 file per gruppo)
- ✅ Alembic init + configurazione async
- ✅ Prima migrazione (crea tutte le tabelle)
- ✅ `app/main.py` con health check
- ✅ Router API stub (7 file, tutti 501)
- ✅ Stub moduli core (turno, sessione, contesto, elaborazione, conversazione, gamification)
- ✅ Stub moduli LLM (client, tools, prompts/system_prompt)
- ✅ Stub moduli grafo (struttura, algoritmi, stato, fsrs)
- ✅ Copiare KB JSON in `data/`
- ✅ Test base (health check + import modelli) — 3/3 pass
- ✅ Verifica: `docker-compose up` → health check OK → 17 tabelle nel DB

---

## Blocco 2: Import Knowledge Base (Sessione 2)

Caricare i dati reali nel database.

- ✅ `scripts/import_extraction.py`
  - ✅ Lettura JSON con auto-detect nomi file
  - ✅ Import nodi con mapping campi
  - ✅ Estrazione temi da `tema_id` dei nodi
  - ✅ Import relazioni (array piatto, ignorare confidence/passaggio)
  - ✅ Import esercizi con mapping campi
  - ✅ UPSERT idempotente (re-import sicuro) — verificato con doppio run
  - ✅ Skip nodi contesto per stato utente (importati nel DB, esclusi dal percorso)
  - ✅ Gestione import multipli (Algebra1 + Algebra2)
- ✅ Test import con dati reali — 8/8 unit test + import completo
- ✅ Verifica integrità: 183 nodi, 25 temi, 539 relazioni, 1470 esercizi, 0 orfani, 166/169 copertura

---

## Blocco 3: Grafo in memoria + algoritmi (Sessione 2)

Knowledge graph deterministico.

- ✅ `app/grafo/struttura.py` — GrafoKnowledge singleton con NetworkX DiGraph, caricamento da DB
- ✅ `app/grafo/algoritmi.py` — funzioni pure (no DB, no async)
  - ✅ Ordinamento topologico (sottografo bloccante, esclusi nodi contesto)
  - ✅ Verifica sblocco nodo (tutti prerequisiti bloccanti ≥ operativo)
  - ✅ Path planner (prossimo nodo non completato con prerequisiti soddisfatti)
  - ✅ Preferenza stesso tema in caso di parità
  - ✅ Gestione "percorso completato" (tutti i nodi operativi → None)
  - ✅ Cascata sblocco post-promozione (`nodi_sbloccati_dopo_promozione`)
- ✅ `app/grafo/stato.py` — `get_livelli_utente` + `aggiorna_livello` (UPSERT)
- ✅ `app/main.py` aggiornato con lifespan per caricamento grafo
- ✅ Test: 35/35 pass — topological sort, sblocco, path planner, diamante, cascata, tie-break tema

---

## Blocco 4: Auth + gestione utente (Sessione 3)

- ✅ `app/core/sicurezza.py` — hash bcrypt (diretto, no passlib) + JWT con python-jose
- ✅ `app/db/crud/utenti.py` — crea_utente, get_by_email, get_by_id, aggiorna_profilo
- ✅ `app/api/deps.py` — `get_utente_corrente` dependency (Bearer token → Utente)
- ✅ `app/schemas/auth.py` + `app/schemas/utente.py` — Pydantic v2 con EmailStr
- ✅ `app/api/auth.py` — `POST /auth/registrazione` (201) + `POST /auth/login` (JWT)
- ✅ `app/api/utente.py` — `GET /me`, `PUT /me/preferenze`, `GET /me/statistiche` (stub 501)
- ✅ Test: 8/8 pass (hash, verifica, JWT crea/verifica/manomesso/uuid) + 7 API test skippati (richiedono DB)

---

## Blocco 5: Client LLM + streaming (Sessione 3)

- ⬚ `app/llm/client.py`
  - ⬚ Wrapper Anthropic SDK
  - ⬚ Streaming response con parsing text_delta + tool_use
  - ⬚ Gestione timeout
  - ⬚ Conteggio token e costo stimato
- ⬚ `app/llm/tools.py` — Schema completo azioni + segnali per Claude API
- ⬚ `app/llm/prompts/` — System prompt + template direttive
- ⬚ Test: chiamata streaming mock, parsing tool_use

---

## Blocco 6: Context builder + direttive (Sessione 4)

- ⬚ `app/core/contesto.py` — Assembla i 6 blocchi XML
  - ⬚ Blocco 1: System prompt (fisso)
  - ⬚ Blocco 2: Direttiva (da template, situazione corrente)
  - ⬚ Blocco 3: Profilo utente
  - ⬚ Blocco 4: Contesto attivo (nodo focale + nodi supporto)
  - ⬚ Blocco 5: Conversazione nei messages (solo testo)
  - ⬚ Blocco 6: Memoria rilevante (placeholder Loop 3)
- ⬚ Template direttive (sezione 9 brief):
  - ⬚ Spiegazione concetto nuovo
  - ⬚ Esercizio in corso
  - ⬚ Onboarding (accoglienza / conoscenza / conclusione)
  - ⬚ Ripresa sessione sospesa
  - ⬚ Verifica Feynman (stub Loop 3)
  - ⬚ Ripasso SR (stub Loop 2)
- ⬚ Troncamento conversazione (>50 turni: primi 2 + ultimi 20)
- ⬚ Test: assemblaggio context package con dati mock

---

## Blocco 7: Flusso del turno — IL CUORE (Sessione 4-5)

- ⬚ `app/core/turno.py` — `esegui_turno()`
  - ⬚ Fase 1: Preparazione (carica stato, assembla contesto)
  - ⬚ Fase 2: Chiamata LLM (streaming, parsing, eventi SSE)
  - ⬚ Fase 3: Post-processing (segnali, achievement)
- ⬚ `app/core/elaborazione.py`
  - ⬚ Action Executor
    - ⬚ `proponi_esercizio` (selezione dal banco, mapping difficoltà)
    - ⬚ `mostra_formula` (passthrough)
    - ⬚ `suggerisci_backtrack` (passthrough)
    - ⬚ `chiudi_sessione` (chiusura sessione)
    - ⬚ Stub azioni Loop 2-3
  - ⬚ Signal Processor
    - ⬚ `concetto_spiegato` → aggiorna spiegazione_data, livello in_corso
    - ⬚ `risposta_esercizio` → storico, contatori, verifica promozione
    - ⬚ `confusione_rilevata` → log
    - ⬚ `energia_utente` → log
    - ⬚ `prossimo_passo_raccomandato` → salva in sessione
    - ⬚ `punto_partenza_suggerito` → match nel grafo
    - ⬚ Stub segnali Loop 3
- ⬚ `app/core/conversazione.py` — Salvataggio turni (testo/azioni/segnali separati)
- ⬚ Logica promozione: in_corso → operativo (spiegazione + 3 esercizi + 1 primo_tentativo)
- ⬚ Cascata sblocco post-promozione
- ⬚ Test: promozione, sblocco cascata, signal processing

---

## Blocco 8: API sessione con SSE (Sessione 5)

- ⬚ `app/api/sessione.py`
  - ⬚ `POST /sessione/inizia` → SSE stream (sessione_creata + primo turno tutor)
  - ⬚ `POST /sessione/{id}/turno` → SSE stream (risposta tutor)
  - ⬚ `POST /sessione/{id}/sospendi` → salva stato orchestratore
  - ⬚ `POST /sessione/{id}/termina` → chiudi sessione
  - ⬚ `GET /sessione/{id}` → stato sessione
- ⬚ `app/core/sessione.py`
  - ⬚ Scelta nodo a inizio sessione (sospesa → in_corso → path planner)
  - ⬚ Sessione unica attiva (409 / auto-sospensione)
  - ⬚ Transizioni attività (spiegazione ↔ esercizio ↔ ...)
  - ⬚ Salvataggio/ripristino stato orchestratore
- ⬚ Formato eventi SSE (text_delta, azione, achievement, turno_completo, errore)
- ⬚ Gestione errori (timeout LLM, tool invalidi, esercizio non trovato)
- ⬚ Test: flusso sessione end-to-end con LLM mock

---

## Blocco 9: Onboarding (Sessione 6)

- ⬚ `app/api/onboarding.py`
  - ⬚ `POST /onboarding/inizia` → crea utente temp + sessione onboarding + SSE
  - ⬚ `POST /onboarding/turno` → turno conversazione onboarding
  - ⬚ `POST /onboarding/completa` → finalizza, crea percorso
- ⬚ Gestione fasi: accoglienza → conoscenza (automatico dopo 1° scambio) → conclusione
- ⬚ Punto di partenza personalizzato (segnale `punto_partenza_suggerito`)
  - ⬚ Match tema/nodo nel grafo
  - ⬚ `nodo_iniziale_override` nel percorso
  - ⬚ Nodi precedenti marcati operativo + presunto=true
- ⬚ Al completamento: salva profilo, crea percorso binario_1, inizializza stato_nodi_utente
- ⬚ Test: flusso onboarding completo

---

## Blocco 10: Gamification (Sessione 6)

- ⬚ `app/core/gamification.py`
  - ⬚ Achievement checker (verifica condizioni dopo ogni turno)
  - ⬚ Seed definizioni achievement iniziali (8 achievement dal brief)
  - ⬚ Calcolo streak (giorni consecutivi obiettivo raggiunto)
  - ⬚ Aggiornamento statistiche_giornaliere
- ⬚ `app/api/achievement.py` — `GET /achievement` (sbloccati + prossimi)
- ⬚ Test: condizioni achievement, calcolo streak

---

## Blocco 11: API restanti + rifinitura (Sessione 7)

- ⬚ `app/api/percorsi.py` — lista percorsi, mappa nodi
- ⬚ `app/api/temi.py` — dettaglio tema con progresso
- ⬚ `GET /utente/me/statistiche` — stats settimana/mese/sempre
- ⬚ Test end-to-end completo (walkthrough sezione 18 del brief)
- ⬚ Review generale, cleanup TODO, documentazione endpoint

---

## Note

- Ogni blocco aggiorna questo file e `CLAUDE.md` al completamento
- I test critici di dominio vengono scritti CON il codice, non dopo
- I blocchi 5-6-7-8 sono strettamente accoppiati — preferire sessioni dedicate con contesto pieno
- Ralph Loop utilizzabile per sotto-task ripetitivi dentro un blocco (es. "scrivi tutti i test di promozione")
