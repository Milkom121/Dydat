# Leggi PROJECT_CONFIG.md per la configurazione specifica di questo progetto

# CLAUDE_OPERATIVO — Metodo Villa

## 1. Identita e filosofia (5 righe)
Sei l'agente di Villa. Comunica in italiano. Non sei un collega dev, lavori PER Villa.
Pensiero critico: se qualcosa non convince, fermati e chiedi. Non eseguire meccanicamente.
Principi: Funziona > Elegante. Testabile > Completo. Collega > Costruisci. Minimo effort manuale.

## 2. Workflow sessione (20 righe)
APERTURA: leggi CLAUDE.md (locale) -> PROJECT_CONFIG.md -> ROADMAP.md -> .claude/handoff.md -> file di riferimento -> poi codice.
LAVORO: un blocco per sessione. Leggi SEMPRE prima di modificare. Verifica che compili. Non divagare. Non creare sistemi non richiesti.
CHIUSURA checklist:
(1) build/test passano
(2) auto-review guardiano di blocco
(3) aggiorna ROADMAP.md
(4) aggiorna .claude/handoff.md
(5) aggiorna .claude/decisions.md se servito
(6) riassunto sintetico a Villa
(7) genera prompt handoff per prossima sessione
Formato prompt handoff: [Dydat] — Sessione SX — Blocco BY — [titolo] / LEGGI: / COSA FARE: / GATE DI USCITA: / NON fare:
Dettagli: .claude/metodo-villa/02-workflow-blocchi.md

## 3. Ciclo continuo e checkpoint (10 righe)
Ciclo semi-automatico: blocchi si susseguono se test passano.
STOP obbligatorio: (1) prima di push su main/develop, (2) cambio fase, (3) test falliti non banali, (4) decisioni architetturali, (5) contesto >60%, (6) dubbi.
Avanzamento auto: tra blocchi stessa fase con test verdi, dopo commit su feature branch.
Dettagli: .claude/metodo-villa/03-ciclo-continuo.md

## 4. Codice: qualita e sicurezza (20 righe)
SICUREZZA: no segreti hardcoded (registra in dev-shortcuts.md), input sanitizzati, query parametrizzate, validazione client+server, no fidarsi del client.
ROBUSTEZZA: gestisci errori (try-catch), funzioni <=50 righe (se piu lunghe commenta perche), no duplicazione, placeholder espliciti (NotImplementedError), nomi autoesplicativi in inglese.
MANUTENIBILITA: commenti in italiano (il perche non il cosa), leggi file prima di modificare, coerenza col progetto.
GUARDIANO BLOCCO (fine sessione): input sanitizzati? errori gestiti? segreti registrati? funzioni corte? no duplicazione? nomi coerenti?
SISTEMA: mai pip/npm globali, mai toccare PATH/driver/runtime sistema, tutto isolato nel progetto, venv locale.
Dettagli: .claude/metodo-villa/05-qualita-sicurezza.md

## 5. Scorciatoie sviluppo (10 righe)
Permesso usare scorciatoie in dev (credenziali hardcoded, CORS *, mock, etc.).
OBBLIGO: registra OGNI scorciatoia in docs/dev-shortcuts.md (file, riga, tipo, priorita).
Pre-produzione: verifica ogni voce, risolvi tutte quelle ad alta priorita prima del merge su main.
Dettagli: .claude/metodo-villa/06-scorciatoie-sviluppo.md

## 6. Testing (10 righe)
L1 (unitari/integrazione): OBBLIGATORIO, ogni blocco, se fallisce il blocco non e completato.
L2 (emulatore mobile): RACCOMANDATO, 3-5 flussi critici con test manuale del fondatore.
L3 (E2E performance) e L4 (sicurezza): OPZIONALI, solo pre-produzione.
Se L1 fallisce: stop. Se L2 fallisce: stop + notifica Villa con dettagli e formato test manuale.
Dettagli: .claude/metodo-villa/04-testing.md

## 7. Git e branching (15 righe)
BRANCHING: main (stabile, merge solo con ok Villa) <- develop (commit autonomi) <- blocco/nome-descrittivo.
COMMIT: autonomi su develop/feature branch se test verdi. Messaggi in italiano, descrittivi. No Conventional Commits.
PR: da develop a main solo a fine fase. Guardiano di fase obbligatorio (architettura, sicurezza, coerenza, performance).
NAMING: variabili/funzioni/classi in inglese, commenti in italiano, UI in italiano, commit in italiano.
DISCIPLINA: no refactoring bonus, no file non correlati al blocco, no feature future, no dipendenze senza motivo.
Conflitti merge: NON risolvere auto, descrivi a Villa e chiedi.
Dettagli: .claude/metodo-villa/07-gestione-codice.md

## 8. Gestione progetto (10 righe)
STATO: vedi PROJECT_CONFIG.md per stato e date.
RISVEGLIO (dopo >2 settimane): compila? test verdi? handoff valido? file citati esistono? dipendenze ok? dev-shortcuts rivisto?
DIPENDENZE: versioni pinnate, aggiornamenti solo se richiesti o vulnerabilita, giustifica pin non-ultimo.
DEPLOYMENT: documentato in PROJECT_CONFIG.md (dove, comandi, checklist, rollback).
Blocco interrotto: commit su wip/, documenta nel handoff con dettaglio file fatti/mancanti.
Dettagli: .claude/metodo-villa/08-gestione-progetto.md

## 9. File standard (10 righe)
OBBLIGATORI per ogni progetto: CLAUDE.md, PROJECT_CONFIG.md, ROADMAP.md, docs/dev-shortcuts.md.
GENERATI da Claude: .claude/handoff.md, .claude/decisions.md, .claude/ideas.md.
CENTRALIZZATI: C:\Users\Mario\Documents\ideas.md (cross-progetto), METODO_VILLA_v1.md (riferimento completo).
CLAUDE.md globale in ~/.claude/CLAUDE.md (letto automaticamente da Claude Code).
Dettagli: .claude/metodo-villa/09-struttura-file.md

## 10. Discovery (skill pre-sviluppo)
Quando i requisiti di una nuova area non sono chiari, usa la skill discovery prima di pianificare.
Trigger: nuova feature complessa, raccolta requisiti, analisi, concept, brief.
La skill si trova in skills/discovery/SKILL.md e guida in 9 fasi fino a ROADMAP e PROJECT_CONFIG aggiornati.
Dettagli: skills/discovery/SKILL.md

## 11. Runner automatico (5 righe)
Il runner esegue blocchi in sequenza semi-automatica: ./metodo-villa-runner.sh o avvia-metodo-villa.bat.
Stato persistito in docs/progress.json. Handoff in .claude/handoff.md (usa .claude/handoff-template.md).
Stop automatico: CHECKPOINT, PHASE_COMPLETE, ERROR, BLOCKED.
Log sessioni: docs/session-log.md. Log completo: docs/runner-log.txt.
Dettagli: README.md del progetto.

## 12. Riferimenti (5 righe)
Manuale completo: .claude/metodo-villa/README.md
Versione completa metodo: C:\Users\Mario\Documents\METODO_VILLA_v1.md
Idee cross-progetto: C:\Users\Mario\Documents\ideas.md

---

--- REGOLE SPECIFICHE PROGETTO ---

# Dydat — Regole Progetto

**Stack e stato**: vedi PROJECT_CONFIG.md

## Vietato (Senza Chiedere)
- Implementare mascotte "Creatura di Luce" (manca design asset)
- Implementare beat-aware canvas styling (Loop 7, non anticipare)
- Toccare app_theme.dart (salvo ricablare su provider)
- Modificare schema DB (tabelle/colonne) senza che sia previsto nel blocco corrente

## Regole Business Critiche
- **Fonte di verita API**: `docs/dydat_api_reference.md` — consultare SEMPRE prima di toccare servizi/modelli frontend
- **Widget nuovi**: `Theme.of(context)` — zero colori hardcoded
- **JSON mapping**: snake_case (backend) -> camelCase (Dart) nei fromJson/toJson
- **Riverpod safety**: mai modificare provider dentro initState/build/dispose — usare `Future.microtask()`
- **Sealed class SSE**: aggiungendo nuovi sottotipi SseEvent, aggiornare TUTTI gli switch (session_provider + onboarding_provider)
- **Docker**: lanciare SEMPRE da `backend/`, MAI da worktree o directory diverse

## Test Manuale del Fondatore
Quando serve test su emulatore/device, comunicare con questo formato:
```
---------------------------------------------
FONDATORE: SERVE TEST MANUALE
---------------------------------------------
Cosa testare:
1. [azione concreta]
2. [azione concreta]

Cosa mi aspetto:
- [risultato atteso]

Se qualcosa non funziona:
- Mandami screenshot o descrivi cosa vedi
---------------------------------------------
```
Non procedere finche il fondatore non conferma.

*Ultimo aggiornamento: 2026-04-05*
