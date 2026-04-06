STATUS: CONTINUE
PHASE: 9
BLOCK: B38.5
SUMMARY: Fase 9 chiusa con B38 (S35). Test manuale post-Fase-9 completato: 7 bug UI cosmetici raccolti in .claude/test-findings.md. B38.5 e un blocco di consolidamento chirurgico per fixarli tutti prima di passare a Fase 10.
NEXT: B39 — Onboarding con Momento Wow (Fase 10)
DECISIONS_NEEDED: Nessuna — Villa ha approvato il blocco fix. Merge develop->main rimandato a dopo B39+ / Fase 10. Le issue strategiche UX-01 (primo turno caldo) e UX-02 (quaderno enciclopedico) sono registrate in ideas.md e NON fanno parte di questo blocco.
FILES_MODIFIED: (nessuno in questa preparazione — solo aggiornamento handoff/progress/session-log per kickoff B38.5)
TESTS: PASS (341 backend, 448 frontend, flutter analyze 0 — baseline da B38)
VERIFICATION: baseline verde. Test manuale ha confermato che funzionalmente B33-B38 sono completi; i bug sono tutti cosmetici o di layout.

---

## Contesto dettagliato

### Perche B38.5 e non B39
Dopo la chiusura di Fase 9 (B36+B37+B38), Villa ha eseguito un test manuale su emulatore con utente creato da zero tramite onboarding reale. Sono emersi 7 bug UI cosmetici che impattano la prima impressione dell'app. Prima di passare a Fase 10 (B39 Onboarding Wow), consolidiamo con un blocco di fix dedicato. NON e un blocco di feature nuove: e pulizia chirurgica con gate di uscita stretto.

### Input obbligatorio
Prima di scrivere codice, leggi `.claude/test-findings.md` (committato su develop). Contiene il dettaglio di ogni bug con file, riga, sintomo, causa probabile, fix proposto, severita. E la fonte di verita di questo blocco.

### I 7 bug da fixare

**BUG-01 — Overflow 58px in MiniPercorsoWidget** (severita MEDIA)
- File: `frontend/lib/presentation/home_screen/widgets/mini_percorso_widget.dart` righe 77-103 (metodo `_buildNodeRow`)
- Sintomo: il Row dei nodi sborda a destra di ~58px quando il percorso ha >=5 nodi nella finestra
- Causa: lo `spacing` e `clamp(8.0, 40.0)` ma non protegge da availableWidth insufficienti
- Fix: preferire `SingleChildScrollView` orizzontale (physics `ClampingScrollPhysics`) cosi se sborda l'utente puo scrollare. Oppure calcolare dinamicamente il numero massimo di nodi mostrabili dato `availableWidth` e ridurre la finestra. Soluzione 1 piu semplice.
- Test: scrivere widget test che verifica che con nodi=5 e width=300 il Row NON lancia RenderFlex overflow.

**BUG-02 — "Riprendi a studiare" mostrato anche per utente nuovo** (severita BASSA)
- File: `frontend/lib/presentation/home_screen/home_screen.dart`
- Sintomo: utente appena onboardato, 0 sessioni precedenti, ma il bottone dice "Riprendi a studiare"
- Fix: condizionare il testo su `sessionState.sessionHistory.isNotEmpty` (o `statsState.sessioniTotali > 0`). Se 0 sessioni, mostrare "Inizia a studiare". Se >= 1 sessione, mostrare "Riprendi a studiare".
- Test: widget test con sessionHistory vuoto -> "Inizia a studiare", con sessionHistory non vuoto -> "Riprendi a studiare".

**BUG-03 — "Bentornato!" in LoginScreen alla prima apertura** (severita BASSA)
- File: `frontend/lib/presentation/login_screen/login_screen.dart`
- Sintomo: dice "Bentornato!" anche alla prima apertura assoluta dell'app, senza aver mai registrato un utente
- Fix: testo statico neutro. Sostituire "Bentornato!" con "Accedi a Dydat" (o simile). Sostituire il subtitle "Accedi per continuare il tuo percorso di apprendimento" con "Accedi al tuo account" oppure "Entra nel tuo tutor personale". Non e necessario logica di tracking prima apertura: basta testo neutro.
- Test: widget test che verifica che il titolo e "Accedi a Dydat" (o quello che decidi).

**BUG-04 — LinearPathMap sembra una lista, non una mappa** (severita MEDIA)
- File: `frontend/lib/presentation/learning_path_screen/widgets/linear_path_map.dart`
- Sintomo: l'implementazione attuale e un ListView.builder di _NodeRow con cerchio piccolo a sinistra + card rettangolare col nome a destra. Visivamente sembra una lista, non una mappa.
- Fix (RIDISEGNO):
  1. Ingrandire i cerchi a ~56px (da piccoli a dominanti)
  2. Stato del nodo comunicato con icona/colore dentro il cerchio (check per completato, play per corrente, lucchetto per bloccato, puntino per da iniziare)
  3. Spostare il nome del nodo SOTTO il cerchio come testo centrato, massimo 2 righe, non in una card separata
  4. Linea di connessione verticale tra i cerchi piu spessa e con gradient (primary se completato, outline se no)
  5. Layout verticale centrato (non a due colonne)
  6. Mantenere i badge ripasso se applicabili
- Test: widget test esistenti di LinearPathMap vanno aggiornati. Aggiungere test che verifica che i cerchi hanno il colore giusto per ogni stato.

**BUG-05 — GraphOverview: nomi nodi troncati e sovrapposti** (severita MEDIA)
- File: `frontend/lib/presentation/learning_path_screen/widgets/graph_overview.dart`
- Sintomo: nomi lunghi troncati/sovrapposti ai cerchi ("Funzioni definite per casi ... inuita")
- Fix: wrap nomi su 2 righe con `maxLines: 2`, `overflow: TextOverflow.ellipsis`, `textAlign: center`. Posizionare il testo SOTTO il cerchio con spaziatura adeguata. Ridurre font size a bodySmall. Aumentare spacing verticale tra i cerchi per dare spazio al testo.
- Test: widget test che verifica che i nodi con nome lungo hanno `maxLines: 2`.

**BUG-06 — GraphOverview: percorso attuale non evidenziato** (severita MEDIA)
- File: `frontend/lib/presentation/learning_path_screen/widgets/graph_overview.dart`
- Sintomo: la vista grafo mostra tutti i temi ma non evidenzia il percorso attuale dell'utente ne il nodo corrente
- Fix:
  1. Accedere al pathProvider per ottenere il percorso attivo dell'utente e il nodo corrente
  2. Evidenziare i nodi del percorso attivo con glow ambra (reuse `DydatSurface.glowCircle`)
  3. Marcare il nodo corrente con un bordo pulsante piu spesso (o icona "pin")
  4. All'apertura del grafo, centrare la vista sul nodo corrente usando InteractiveViewer transformationController
- Test: widget test con mock pathProvider che ritorna un percorso e verifica che il nodo corrente ha il glow.

**BUG-07 — GraphOverview: vastita orizzontale eccessiva** (severita BASSA)
- File: `frontend/lib/presentation/learning_path_screen/widgets/graph_overview.dart`
- Sintomo: il grafo si estende molto in orizzontale
- Fix:
  1. Avvolgere il grafo in `InteractiveViewer` con `boundaryMargin: EdgeInsets.all(200)`, `minScale: 0.3`, `maxScale: 2.5`, scale iniziale 0.6 per mostrare piu contesto al primo accesso
  2. (Opzionale) minimap in basso a destra con riquadro dell'area visibile — solo se fattibile rapidamente, altrimenti rimandare
- Test: widget test che verifica che l'InteractiveViewer esiste e ha i parametri corretti.

### Gate di uscita

1. Tutti i 7 bug fixati come descritto
2. `flutter analyze` 0 errori
3. `flutter test` verde (aggiornare test esistenti dove necessario)
4. Almeno 1 nuovo widget test per ciascun bug (7 test nuovi minimi)
5. Nessun refactoring bonus su altri file
6. Commit su `develop` con messaggio tipo "B38.5 — Fix UI post test manuale: 7 bug cosmetici"
7. Aggiornare ROADMAP.md aggiungendo il blocco B38.5 completato sotto Fase 9

### Constraint importanti

- **NON toccare**: backend, session flow, mascotte, beat, studio_screen, app_router, tema (app_theme.dart). Solo i file elencati sopra.
- **NON implementare**: UX-01 (primo turno caldo), UX-02 (quaderno enciclopedico), B39 onboarding wow. Sono blocchi separati pianificati in ideas.md.
- **Theme.of(context) obbligatorio** — zero colori hardcoded nuovi. Usare DydatSurface per le superfici.
- **Metodo Villa**: leggi sempre il file prima di modificare. Non divagare. Un commit atomico per il blocco intero (non un commit per ogni bug).

### File da leggere per la sessione

1. `CLAUDE.md` (regole Metodo Villa + progetto)
2. `PROJECT_CONFIG.md`
3. `.claude/handoff.md` (questo file)
4. `.claude/test-findings.md` (fonte di verita dei bug)
5. `frontend/lib/presentation/home_screen/widgets/mini_percorso_widget.dart`
6. `frontend/lib/presentation/home_screen/home_screen.dart`
7. `frontend/lib/presentation/login_screen/login_screen.dart`
8. `frontend/lib/presentation/learning_path_screen/widgets/linear_path_map.dart`
9. `frontend/lib/presentation/learning_path_screen/widgets/graph_overview.dart`
10. `frontend/lib/theme/surface_decorations.dart` (per glow e superfici)
11. `frontend/lib/providers/path_provider.dart` (per BUG-06)

### Stato baseline
- Frontend: 448 test verdi, analyze 0
- Backend: 341 test verdi (invariato)
- Branch: `develop`, ultimo commit `dd9dfeb` (findings committati)

### NON fare
- Non toccare backend
- Non affrontare UX-01 / UX-02 (sono issue strategiche da discutere prima)
- Non aggiungere dipendenze
- Non fare refactoring bonus
- Non toccare ROADMAP delle fasi successive
- Non toccare test manuali passati (PASS/FAIL in test-findings.md resta storico)
