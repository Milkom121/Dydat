# Roadmap — Dydat

> Piano di sviluppo organizzato in fasi e blocchi. Ogni blocco corrisponde a una sessione di lavoro.
> Segna `[x]` quando un blocco e' completato, `[>]` se in corso, `[ ]` se da fare.

---

## Fase 1 — Fondamenta Frontend (Loop 1, B0-B10) — COMPLETATA

- [x] **Blocco B0** — Pulizia repo, monorepo, CLAUDE.md, fix sizer (S0)
- [x] **Blocco B1** — Dipendenze + config (S1)
- [x] **Blocco B2** — Modelli dati (9 file) (S1)
- [x] **Blocco B3** — Servizi API (8 file) (S2)
- [x] **Blocco B4** — Provider Riverpod (8 file) (S2)
- [x] **Blocco B5** — GoRouter + shell app (S3)
- [x] **Blocco B6** — Schermate auth (login, registrazione, splash) (S4)
- [x] **Blocco B7** — Tab Percorso (dati reali) (S4)
- [x] **Blocco B8** — Tab Profilo (da zero) (S5)
- [x] **Blocco B9** — Tab Studio (SSE placeholder) (S5)
- [x] **Blocco B10** — Test E2E con backend (S6)

---

## Fase 2 — SSE Streaming Reale (Loop 2, B11-B16) — COMPLETATA

- [x] **Blocco B11** — SSE Client + Modelli eventi (S7)
- [x] **Blocco B12** — Studio Screen con SSE reale (S8)
- [x] **Blocco B13** — Azioni tutor nel canvas (exercise/formula/backtrack) (S9)
- [x] **Blocco B14** — Onboarding reale con SSE + onboarding adattivo 5 fasi (S10)
- [x] **Blocco B15** — Recap sessione + App lifecycle (S11)
- [x] **Blocco B16** — Test E2E Loop 2 (S12)

---

## Fase 3 — UX Polish + LaTeX + Storico (Loop 3, B17-B21) — COMPLETATA

- [x] **Blocco B17** — LaTeX rendering (FormulaCard + inline LatexText) (S13)
- [x] **Blocco B18** — Node progression 3 stati + GET /sessione/ backend (S14)
- [x] **Blocco B19** — Session history frontend + Recap improvements (S15)
- [x] **Blocco B20** — Celebration animations + esito SSE backend (S16)
- [x] **Blocco B21** — Test E2E Loop 3 + Polish (S17)

---

## Fase 4 — Quick Wins + Robustezza (Loop 4, B22-B25) — COMPLETATA

- [x] **Blocco B22** — Celebrazione promozione nodo + SSE event (S18)
- [x] **Blocco B23** — SSE reconnect + resilienza errori (S19)
- [x] **Blocco B24** — Fix test backend/frontend + pulizia worktree (S20)
- [x] **Blocco B25** — MascotteWidget con enum MascotteState + E2E Loop 4 (S21)

---

## Fase 4.5 — Consolidamento (dall'audit, pre-Loop 5)

> Blocchi 4.5.1, 4.5.2, 4.5.4, 4.5.5, 4.5.6 rimandati a pre-produzione (siamo ancora in sviluppo).
> Il runner esegue SOLO il blocco 4.5.3, poi passa direttamente a Fase 5.

### Blocco 4.5.1 — Sicurezza (RIMANDATO)
- [ ] **Stato**: rimandato a pre-produzione
- **Complessita'**: media
- **Descrizione**: Ruotare chiave API Anthropic. Aggiungere validazione fail-fast in backend/app/config.py per JWT_SECRET e ANTHROPIC_API_KEY. Spostare credenziali DB dal docker-compose.yml a .env. Creare backend/.env.example con valori segnaposto.
- **Gate di uscita**: config.py rifiuta avvio con secrets di default, credenziali non piu in docker-compose.yml, .env.example presente

### Blocco 4.5.2 — CI/CD (RIMANDATO)
- [ ] **Stato**: rimandato a pre-produzione
- **Complessita'**: media
- **Descrizione**: Creare .github/workflows/ci.yml con: pytest backend, ruff lint, flutter analyze, flutter test. Trigger su push e PR verso develop e main.
- **Gate di uscita**: GitHub Actions esegue tutti i test automaticamente su push, badge verde

### Blocco 4.5.3 — Performance Frontend
- [x] **Stato**: completato (S22)
- **Complessita'**: alta
- **Descrizione**: Rendere iconMap statico/const in custom_icon_widget.dart (9000 righe, ricreato ad ogni build). Iniziare split di studio_screen.dart (1207 righe) in widget separati: ChatViewWidget, SessionControlWidget, HomeViewWidget.
- **Gate di uscita**: iconMap e static const, StudioScreen sotto 500 righe, flutter analyze 0, flutter test verdi

### Blocco 4.5.4 — Robustezza Backend (RIMANDATO)
- [ ] **Stato**: rimandato a pre-produzione
- **Complessita'**: media
- **Descrizione**: Aggiungere CORS middleware in main.py. Aggiungere logging nelle except bare in turno.py (linee 275-294). Aggiungere cancellation handling SSE per client disconnect. Rimuovere --reload dal Dockerfile CMD.
- **Gate di uscita**: CORS configurato, exception loggate, SSE cleanup su disconnect, Dockerfile prod-ready, pytest verde

### Blocco 4.5.5 — Robustezza Frontend (RIMANDATO)
- [ ] **Stato**: rimandato a pre-produzione
- **Complessita'**: media
- **Descrizione**: Implementare JWT token refresh nell'interceptor Dio. Aggiungere ref.onDispose() in SessionNotifier per cleanup stream. Chiudere http.Client in SseClient. Riattivare TextScaler per accessibilita (rimuovere TextScaler.linear(1.0) da main.dart).
- **Gate di uscita**: Token refresh automatico, nessun memory leak SSE, accessibilita ripristinata, flutter analyze 0, flutter test verdi

### Blocco 4.5.6 — Pulizia (RIMANDATO)
- [ ] **Stato**: rimandato a pre-produzione
- **Complessita'**: bassa
- **Descrizione**: Rimuovere dipendenze inutilizzate dal pubspec.yaml (cached_network_image, connectivity_plus, fl_chart). Aggiungere healthcheck backend al docker-compose. Aggiungere pool_size e pool_pre_ping a engine.py.
- **Gate di uscita**: 0 dipendenze inutilizzate, healthcheck backend funziona, pool DB configurato, flutter analyze 0, flutter test verdi

---

## Fase 5 — FSRS Spaced Repetition (Loop 5, B26-B29)

### Blocco B26 — Algoritmo FSRS (Backend)
- [x] **Stato**: completato (S23)
- **Complessita'**: alta
- **Descrizione**: Installare libreria `fsrs` da PyPI. Implementare `calcola_prossimo_ripasso()` e `get_nodi_da_ripassare()` in backend/app/grafo/fsrs.py. Integrare in elaborazione.py dopo update contatori esercizio.
- **Gate di uscita**: FSRS implementato, campi SR aggiornati dopo esercizi, get_nodi_da_ripassare funziona, pytest verde
- **Note**: Aggiunta colonna sr_card_json JSONB (migrazione 716b95629203) per serializzazione completa Card FSRS6. 21 nuovi test. 303 totale backend.

### Blocco B27 — Interleaving nelle Sessioni Normali (Backend)
- [x] **Stato**: completato (S24)
- **Complessita'**: media
- **Descrizione**: In sessione.py _scegli_nodo(), aggiungere interleaving probabilistico (1 ogni 2-3 nodi normali) con nodi SR scaduti. Impostare attivita_corrente="ripasso_sr" in stato_orchestratore.
- **Gate di uscita**: Interleaving funzionante, direttiva ripasso assemblata, pytest verde
- **Note**: _NodoScelto NamedTuple, PROBABILITA_INTERLEAVING=0.35, _nomi_nodi_sr helper. Interleaving anche in aggiorna_nodo_dopo_promozione (elaborazione.py) con esclusione nodo appena promosso. order_by scadenza in get_nodi_da_ripassare. 21 nuovi test (test_b27_interleaving.py + test_interleaving.py). 324 totale backend.

### Blocco B28 — Sezione Ripasso Frontend + Badge
- [x] **Stato**: completato (S25)
- **Complessita'**: media
- **Descrizione**: Nuovo endpoint GET /ripasso/nodi. Frontend: modello NodoRipasso, badge "Da ripassare" su tema_card, sezione ripasso in home con conteggio e bottone.
- **Gate di uscita**: Badge visibili, sezione ripasso in home, API funziona, analyze 0, test verdi
- **Note**: backend/app/api/ripasso.py + router in main.py. Frontend: NodoRipasso model + ripasso.g.dart, RipassoState/RipassoNotifier (ripassoProvider), badge arancione (colorScheme.tertiary) su TemaCardWidget con param nodiDaRipassare, sezione ripasso in HomeViewWidget con Container tertiaryContainer + bottone "Vai". 10 nuovi test frontend. 329 backend + 222 frontend verdi, analyze 0.

### Blocco B29 — Sessioni Ripasso Dedicate + E2E Loop 5
- [x] **Stato**: completato (S26)
- **Complessita'**: media
- **Descrizione**: Sessioni tipo "ripasso" con get_nodi_da_ripassare al posto di _scegli_nodo. E2E completo: esercizi -> promozione -> badge ripasso -> sessione ripasso -> interleaving.
- **Gate di uscita**: Sessioni ripasso E2E, interleaving visibile, badge, test verdi
- **Note**: Backend: _scegli_nodo_ripasso() con fallback a path planner se nessun nodo SR. Frontend: onRipassoTap callback in HomeViewWidget, _startRipassoSession() in StudioScreen, tipo='ripasso' in startSessionStream(). Direttiva ripasso_sr già pronta nel context builder. 12 nuovi test backend (test_b29_sessioni_ripasso.py), 8 nuovi test frontend. 341 backend + 228 frontend verdi, analyze 0.

---

## Fase 6 — UX Redesign: Struttura e Navigazione (Fase A.1, B30-B31)

> Riferimento: docs/dydat-ux-redesign-concept-v1.1.docx (sezioni 3, 6)
> Prima sotto-fase del redesign UX. Ridisegna la struttura dell'app: 3 tab (Home, I miei studi, Profilo) + Studio come modalita' immersiva.

### Blocco B30 — Nuova Navigazione: 3 Tab + Studio Modale
- [x] **Stato**: completato (S27)
- **Complessita'**: alta
- **Descrizione**: Ristrutturare la navigazione dell'app. (1) Creare HomeScreen come nuovo Tab 1 con contenuto base (benvenuto, nodi da ripassare FSRS, invito a riprendere, streak). Migrare logica da home_view_widget.dart. (2) Rinominare tab Percorso in "I miei studi" (label e icona). (3) Convertire StudioScreen da tab a route fullscreen modale (push, non tab). I tab spariscono in sessione. (4) Aggiornare app_router.dart: shell con 3 tab (Home, I miei studi, Profilo) + route '/studio' fuori dalla shell. (5) Aggiornare custom_bottom_bar.dart con nuovi nomi e icone. (6) La Home ha un bottone "Riprendi a studiare" che naviga a /studio.
- **File da toccare**: app_router.dart, custom_bottom_bar.dart, nuovo home_screen.dart (presentation/home_screen/), studio_screen.dart (rimuovere home_view), home_view_widget.dart (migrare contenuto)
- **Gate di uscita**: 3 tab funzionanti, Studio si apre come fullscreen modale, tab spariscono in sessione, navigazione Home->Studio->Home funziona, flutter analyze 0, flutter test verdi

### Blocco B31 — Home Calda con Ritorno Intelligente
- [x] **Stato**: completato (S28)
- **Complessita'**: media
- **Descrizione**: Arricchire la Home creata in B30. (1) Mini-percorso visivo: posizione attuale nel percorso (nodo corrente, prossimo). (2) Invito contestuale: "Eravamo rimasti a [nome nodo]" usando dati sessione precedente. (3) Sezione ripasso FSRS (migrata da home_view_widget, migliorata graficamente). (4) Streak e ultimo risultato. (5) Ritorno dopo assenza: se ultima sessione > 7 giorni, messaggio gentile + lista nodi da ripassare. (6) Tono caldo, nessun senso di colpa.
- **File da toccare**: home_screen.dart (arricchire), eventuale home_widgets/ per sotto-widget
- **Gate di uscita**: Home mostra stato percorso, ripasso FSRS, ritorno contestuale, assenza lunga gestita, analyze 0, test verdi
- **Note**: Estratti 4 sub-widget in home_screen/widgets/: WelcomeHeader (saluto contestuale + card assenza), MiniPercorsoWidget (percorso visivo con cerchi e connessioni, finestra 5 nodi), StreakCard (streak + esercizi settimanali + nodi da statsProvider), RipassoSection (con chip nomi nodi). Caricamento mappa percorso + stats in initState. 41 nuovi test (4 file). 274 frontend verdi, analyze 0.

---

## Fase 7 — UX Redesign: Sessione Ibrida (Fase A.2, B32-B33)

> Riferimento: concept v1.1 sezioni 5, 5.4, 5.5, 5.6
> Trasforma la sessione da chat a esperienza ibrida: esercizi e visualizzazioni escono dal feed.

### Blocco B32 — Modello Ibrido: Esercizi Fullscreen
- [x] **Stato**: completato (S29)
- **Complessita'**: alta
- **Descrizione**: Quando il tutor propone un esercizio (azione proponi_esercizio), l'ExerciseCardWidget esce dal feed e si prende lo schermo. (1) Creare ExerciseFullscreenView che wrappa ExerciseCardWidget in un layout dedicato (niente chat dietro, focus totale). (2) Transizione animata feed->fullscreen (slide up o fade). (3) Completato l'esercizio, il risultato rientra nel feed come record compatto. (4) Stessa logica per FormulaCardWidget (mostra_formula) e BacktrackCardWidget (suggerisci_backtrack): escono dal feed, tornano come record. (5) Il feed conversazionale resta scrollabile per le spiegazioni.
- **File da toccare**: studio_screen.dart, exercise_card_widget.dart, formula_card_widget.dart, backtrack_card_widget.dart, chat_view_widget.dart, nuovi file fullscreen view
- **Gate di uscita**: Esercizi in fullscreen, formule in fullscreen, record compatto nel feed dopo completamento, transizioni fluide, analyze 0, test verdi
- **Note**: FullscreenActionOverlay wrappa card esistenti (ExerciseCardWidget, FormulaCardWidget, BacktrackCardWidget) con animazione slide-up+fade. CompactActionRecord mostra record compatto nel feed. StudioScreen gestisce coda fullscreen (_fullscreenQueue). ChatViewWidget: rimossi inline exercise/formula/backtrack, aggiunti _record compatti. onShowFullscreen via addPostFrameCallback in session_sync_helper. 22 nuovi test (296 totale), analyze 0.

### Blocco B33 — Transizione Sessione + Chiusura Narrativa
- [x] **Stato**: completato (S30)
- **Complessita'**: media
- **Descrizione**: (1) Animazione di transizione Home->Studio: la mascotte "porta" lo studente dentro (< 2s). Corrisponde a Beat 1 della direzione visiva. (2) Chiusura sessione narrativa: recap_session_screen mostra prima il commento narrativo del tutor ("Oggi hai capito X, la prossima volta vedremo Y"), poi i numeri sotto (durata, esercizi, nodi). (3) Sessione a obiettivo: prima di iniziare, lo studente sceglie Veloce/Normale/Approfondita. Il tipo viene passato al backend (campo durata_obiettivo). (4) Se supera il tempo: suggerimento pausa dal tutor. Se esce prima: notifica leggera.
- **File da toccare**: studio_screen.dart (transizione), recap_session_screen.dart (narrativo+numeri), nuovo session_goal_picker.dart, mascotte_widget.dart (animazione transizione)
- **Gate di uscita**: Transizione animata funziona, recap narrativo+numeri, scelta obiettivo funziona, analyze 0, test verdi
- **Note**: StudioTransitionOverlay (singolo AnimationController 1150ms, Interval): scale-in mascotte + fade-out overlay. HomeScreen usa Stack+Positioned.fill per l'overlay prima della navigazione. SessionGoalPicker (dialog): 3 opzioni Veloce/Normale/Approfondita, restituisce durataMsMin passato a startSessionStream. recap_session_screen: narrativa tutor in cima (recapBuildNarrativa), poi stats. Notifica snackbar quando si supera l'obiettivo. app_router.dart: CustomTransitionPage slide-up+fade per route /studio. 47 nuovi test (343 totale), analyze 0.

### Blocco B33.5 — Primo Turno Caldo del Tutor (UX-01)
- [x] **Stato**: completato (S50)
- **Complessita'**: media
- **Descrizione**: Fix del primo messaggio del tutor che partiva freddo (esempio cioccolatini senza saluto ne' contesto). (1) Helper `_preambolo_caldo` riutilizzabile: saluto con nome, riconoscimento profilo parafrasato (chi_e, motivo, stile_cognitivo da profilo_sintetizzato), citazione leggera del ritmo scelto (15/30/60 min). (2) Riscrittura `direttiva_spiegazione` con 3 branch: nodo nuovo (presentazione + micro-indice discorsivo + warm-up), nodo presunto padroneggiato (verifica veloce), fallback classico. (3) Aggiornamento `direttiva_ripresa_sessione` per integrare preambolo caldo. (4) Pass-through in `contesto.py`: nome_utente, profilo_sintetizzato, ritmo_minuti, nodo_presunto (da StatoNodoUtente.presunto).
- **File toccati**: backend/app/llm/prompts/direttive.py, backend/app/core/contesto.py, backend/tests/test_contesto.py, nuovo backend/tests/test_direttive_primo_turno.py
- **Gate di uscita**: _preambolo_caldo testato, direttiva_spiegazione con 3 branch, direttiva_ripresa aggiornata, contesto.py pass-through, 14 nuovi test, 377 backend verdi (10 skipped), ruff pulito
- **Note**: Decisioni di design in docs/discussions/ux-01-primo-turno-caldo.md. Tutti i parametri nuovi sono opzionali per retrocompatibilita' con test e codice esistenti. Il preambolo istruisce il tutor a parafrasare il profilo (mai verbatim). Per nodi presunti, il tutor propone domanda-sonda invece di spiegazione.

---

## Fase 8 — UX Redesign: I Miei Studi + Quaderno (Fase A.3, B34-B35)

> Riferimento: concept v1.1 sezioni 3.2, 3.3
> Unifica Percorso e Quaderno in un unico tab con mappa e notebook per nodo.

### Blocco B34 — Percorso Unificato: Mappa + Zoom
- [x] **Stato**: completato (S31)
- **Complessita'**: alta
- **Descrizione**: Ridisegnare LearningPathScreen come "I miei studi". (1) Vista default: mappa lineare del percorso attuale (nodi come cerchi collegati, non card lista). (2) Zoom out: grafo completo delle connessioni tra concetti (algebra->geometria->fisica). Usa dati da pathProvider. (3) Nodi gia studiati in altri percorsi: indicatore "Gia studiato in [percorso]". (4) Ricerca per argomento: barra di ricerca che filtra nodi per nome. (5) Tap su nodo: apre quaderno (B35).
- **File da toccare**: learning_path_screen.dart (riscrittura), tema_card_widget.dart (sostituire con nodo visivo), nuovi widget mappa
- **Gate di uscita**: Mappa lineare funziona, zoom grafo funziona, ricerca funziona, tap su nodo navigabile, analyze 0, test verdi
- **Note**: Riscritta LearningPathScreen da lista TemaCardWidget a mappa visiva nodi. LinearPathMap (cerchi + linee verticali), GraphOverview (InteractiveViewer + CustomPainter raggruppato per tema), NodeDetailBottomSheet con placeholder quaderno (B35). Ricerca client-side case-insensitive con highlight. Badge "Già studiato in [percorso]" non implementato (API non espone dato cross-percorso) — segnalato per B35 o futuro. 14 nuovi test (357 totale frontend), analyze 0.

### Blocco B35 — Quaderno per Nodo
- [x] **Stato**: completato (S32)
- **Complessita'**: alta
- **Descrizione**: Creare il Quaderno associato a ogni nodo del grafo. (1) NodoQuadernoScreen: raccoglie appunti, esercizi svolti, formule viste, spiegazioni chiave dal tutor per quel nodo. (2) Backend: nuovo endpoint GET /nodi/{id}/quaderno che aggrega sessioni, esercizi, azioni formula per quel nodo. (3) Frontend: schermata con sezioni (Appunti, Esercizi, Formule). Dati organizzati per tipo, non per sessione. (4) Il quaderno e uno per nodo (non per percorso): se "proporzioni" appare in algebra e chimica, il quaderno e lo stesso. (5) Da "I miei studi", tap su nodo apre il quaderno.
- **File da toccare**: nuovo nodo_quaderno_screen.dart, nuovo quaderno_service.dart, nuovo quaderno_provider.dart, backend endpoint, learning_path_screen.dart (navigazione)
- **Gate di uscita**: Quaderno mostra dati reali per nodo, aggregazione corretta, nodo condiviso = stesso quaderno, backend+frontend, analyze 0, test verdi
- **Note**: Backend: GET /quaderno/{nodo_id} aggrega stato utente, storico esercizi (limit 50), formule deduplicate per titolo, spiegazioni tutor (>50 char), conteggio sessioni. Frontend: QuadernoNodo model (5 classi), QuadernoNotifier/QuadernoState, NodoQuadernoScreen con 4 sub-widget (StatoHeader, FormuleSection con LaTeX, EserciziSection con badge esito, SpiegazioniSection con expand/collapse markdown). Route /quaderno/:nodoId fullscreen. NodeDetailBottomSheet aggiornato con navigazione tap->quaderno. 7 nuovi test backend, 22 nuovi test frontend. 330 backend (+ 20 skipped), 379 frontend verdi, analyze 0.

---

## Fase 9 — UX Redesign: Atmosfera e Mascotte (Fase A.4, B36-B38)

> Riferimento: concept v1.1 sezioni 5.4, 8, 11
> Porta personalita visiva all'app: superfici, beat emotivi, mascotte evoluta.

### Blocco B36 — Superfici: Gradienti, Glow, Profondita
- [x] **Stato**: completato (S33)
- **Complessita'**: media
- **Descrizione**: Aggiornare le superfici dell'app per riflettere il mood "studio notturno illuminato". (1) Card con gradienti sottili e bordi luminosi (glow ambra). (2) Profondita sulle superfici: ombre realistiche, layering. (3) Sfondi con gradienti radiali/lineari invece di colori piatti. (4) Applicare a: Home, I miei studi, Profilo, Studio. (5) Rispettare Theme.of(context) — zero colori hardcoded.
- **File da toccare**: app_theme.dart (nuovi token), widget delle varie schermate, possibile nuovo file surface_decorations.dart per mixin/widget condivisi
- **Gate di uscita**: Superfici con profondita, gradienti coerenti, zero colori hardcoded, analyze 0, test verdi
- **Note**: Creato surface_decorations.dart con 6 metodi factory (backgroundGradient, card, glowCard, section, glowCircle, depthShadows). Aggiunto token surfaceInteractive (#2E2E34 dark / #EDE9E3 light) ad app_theme.dart. Applicato a 4 schermate: Home (sfondo radiale, card gradiente, glow nodo corrente, sezione ripasso con tint), I miei studi (sfondo radiale, nodi con glow, card nodo gradiente), Profilo (sfondo radiale, card con gradiente e profondita), Studio (header gradiente, exercise/formula/backtrack con glow ambra, tools tray con ombre profonde). 10 nuovi test surface_decorations. 389 frontend verdi, analyze 0.

### Blocco B37 — Beat Emotivi + Transizioni
- [x] **Stato**: completato (S34)
- **Complessita'**: alta
- **Descrizione**: Implementare il sistema di beat emotivi dalla direzione visiva v2. (1) Enum BeatState: accoglienza, spiegazione, esercizio, attesa, esito_corretto, esito_errato, esito_dopo_guida, promozione, chiusura, scoperta. (2) BeatProvider (Riverpod) che calcola il beat corrente dallo stato sessione. (3) BeatOverlay: sottile cambio di atmosfera nel canvas (gradient overlay, animazione mascotte, tono colori). Opacita 0.05-0.15, mai invasivo. (4) Transizioni tra beat: animate, < 500ms. (5) La mascotte reagisce ai beat (collegamento con MascotteState esistente).
- **File da toccare**: nuovo beat_provider.dart, nuovo beat_overlay_widget.dart, studio_screen.dart, mascotte_widget.dart
- **Gate di uscita**: Beat si aggiornano con lo stato sessione, overlay visibile ma sottile, mascotte reagisce, analyze 0, test verdi
- **Note**: BeatState enum con 10 stati (dalla mappa emotiva v2). BeatNotifier con priorita: promozione > esito > fullscreen > chiusura > attesa > streaming > accoglienza. Durate minime per beat transitori (evita flickering). BeatOverlayWidget con gradiente radiale animato per ogni beat (opacita 0.03-0.15). mascotteStateFromBeat() mappa beat->MascotteState secondo tabella direzione visiva. 31 nuovi test (3 file). 420 frontend verdi, analyze 0.

### Blocco B38 — Mascotte CustomPainter
- [x] **Stato**: completato (S35)
- **Complessita'**: alta
- **Descrizione**: Evolvere la mascotte da cerchio ambra a forma organica. (1) CustomPainter per forma morbida, organica (blob con curve di Bezier). (2) Occhi espressivi che riflettono il beat corrente. (3) Transizioni di forma/espressione per ogni beat. (4) Mantenere tap per tools tray. (5) Animazione di transizione "la mascotte ti apre la porta" (Beat 1, ingresso sessione). (6) Celebrazione speciale per promozione.
- **File da toccare**: mascotte_widget.dart (riscrittura), nuovo mascotte_painter.dart
- **Gate di uscita**: Forma organica renderizza, occhi espressivi, transizioni beat, animazione ingresso, analyze 0, test verdi
- **Note**: MascottePainter con blob Bezier (8 punti, deformazione animata), gradiente radiale per profondita, glow luminescente. Occhi espressivi: sclera ovale, pupilla con riflesso, apertura controllata da eyeOpenness (linea quando quasi chiusi). MascotteVisuals con lerp per transizioni smooth 500ms tra stati. EntrancePortalPainter (cerchi concentrici sfalsati) per ingresso sessione. PromotionBurstPainter (12 raggi + cerchio espansione) per celebrazione promozione. Studio screen integrato con showEntrance e showPromotionBurst. 28 nuovi test (2 file). 448 frontend verdi, analyze 0.

### Blocco B38.5 — Fix UI post test manuale (consolidamento)
- [x] **Stato**: completato (S36)
- **Complessita'**: media
- **Descrizione**: Blocco di consolidamento dopo test manuale di Fasi 7-9. Fix chirurgico di 7 bug UI cosmetici emersi durante il test su emulatore con utente creato da zero. Dettaglio in `.claude/test-findings.md`.
- **Bug da fixare**: BUG-01 overflow mini_percorso_widget, BUG-02 testo "Riprendi" per utente nuovo, BUG-03 "Bentornato" in login alla prima apertura, BUG-04 LinearPathMap ridisegno visivo (da lista a mappa vera), BUG-05 GraphOverview nomi troncati, BUG-06 GraphOverview percorso attuale non evidenziato, BUG-07 GraphOverview vastita orizzontale (InteractiveViewer).
- **File da toccare**: mini_percorso_widget.dart, home_screen.dart, login_screen.dart, linear_path_map.dart, graph_overview.dart
- **Gate di uscita**: 7 bug fixati, `flutter analyze` 0, `flutter test` verdi, 7+ nuovi widget test
- **NON fare**: non toccare UX-01 (primo turno caldo, B33.5 candidato) ne UX-02 (quaderno enciclopedico, B35.5 candidato). Registrati in `.claude/ideas.md`.
- **Note**: BUG-01: SingleChildScrollView orizzontale in MiniPercorsoWidget. BUG-02: testo bottone condizionale "Inizia/Riprendi a studiare". BUG-03: "Accedi a Dydat" testo neutro in LoginScreen. BUG-04: riscrittura LinearPathMap con cerchi 56px centrati, nome sotto, connettore gradient. BUG-05: nomi nodi su 2 righe (maxLines:2, width: size*2.8). BUG-06: activePathNodeIds + currentNodeId con glow per percorso attivo. BUG-07: boundaryMargin 200, minScale 0.3, maxScale 2.5. 11 nuovi test (459 totale frontend), analyze 0.

### Blocco B35.5 — Quaderno Enciclopedico (UX-02) — RICALIBRATO
> Spezzato in 5 sub-blocchi piccoli e granulari per consentire al runner di lavorare con context ridotto. Ogni sub-blocco fattibile in una singola sessione 10-25 min.

#### Blocco B35.5.1 — Backend GET quaderno esteso
- [x] **Stato**: completato (S37)
- **Complessita'**: bassa
- **Descrizione**: Estendere `GET /quaderno/{nodo_id}` con campo `scheda` (definizione_testo, formule, esempi, errori_comuni, parole_chiave da JSONB nodi) + `nota_utente`.
- **File da toccare**: backend/app/api/quaderno.py, backend/tests/test_b35_quaderno.py
- **Note**: Aggiunta query NotaUtente + costruzione scheda da JSONB nodo. 3 nuovi test, 7 aggiornati. 351 backend verdi (10 skipped).
- **Gate**: 3+ pytest, ruff pulito, schema Pydantic aggiornato

#### Blocco B35.5.2 — Backend PUT nota utente
- [x] **Stato**: completato (S37)
- **Complessita'**: bassa
- **Descrizione**: Nuovo endpoint `PUT /quaderno/{nodo_id}/nota` upsert su `note_utente`.
- **File da toccare**: backend/app/api/quaderno.py, backend/tests/test_b35_quaderno.py
- **Gate**: 3+ pytest (create, update, unauthorized), ruff pulito
- **Note**: NotaUtenteRequest Pydantic (min 1, max 10000 char). Upsert: SELECT + UPDATE o INSERT. 5 nuovi test (create, update, 404, validazione vuoto, validazione lungo). 356 backend verdi (10 skipped).

#### Blocco B35.5.3 — Frontend modelli + provider
- [x] **Stato**: completato (S38)
- **Complessita'**: bassa
- **Descrizione**: Nuovi modelli Dart `SchedaNodo`, `FormulaCurriculum`, `ErroreComune`, `NotaUtente`. Provider esteso con `saveNota`.
- **File da toccare**: frontend/lib/models/quaderno_nodo.dart, frontend/lib/providers/quaderno_provider.dart, test relativi
- **Gate**: 3+ unit test, analyze 0
- **Note**: 4 nuovi modelli Dart in quaderno.dart + QuadernoNodo esteso con scheda/notaUtente/copyWith. QuadernoState con isSaving. PathService.saveNotaUtente() PUT. QuadernoNotifier.saveNota(). ApiConfig.quadernoNota(). 15 nuovi test. 474 frontend verdi, analyze 0.

#### Blocco B35.5.4 — Frontend widget riutilizzabili
- [x] **Stato**: completato (S39)
- **Complessita'**: media
- **Descrizione**: 4 nuovi widget isolati: `CollapsibleText`, `FormulaCurriculumCard` (LaTeX), `ErroreComuneCard` (accent rosso), `NotaUtenteEditor` (autosave debounced).
- **File da toccare**: frontend/lib/presentation/quaderno_screen/widgets/* (nuovi), test widget
- **Gate**: 4+ widget test, analyze 0
- **Note**: CollapsibleText (Markdown, maxChars configurabile, expand/collapse). FormulaCurriculumCard (Math.tex con fallback, descrizione opzionale). ErroreComuneCard (accent error, RichText labeled). NotaUtenteEditor (TextField multiline, debounce 1500ms, indicatore salvataggio). 15 nuovi test. 489 frontend verdi, analyze 0.

#### Blocco B35.5.5 — Frontend integrazione schermata
- [x] **Stato**: completato (S40)
- **Complessita'**: media
- **Descrizione**: Riscrittura `NodoQuadernoScreen` integrando widget e modelli di B35.5.3/4. Layout 10 sezioni: header, breadcrumb, chip parole chiave, Cosa imparerai (collapsible), Formule chiave, Esempi, Attenzione a..., Le mie note, separator, log personale.
- **File da toccare**: frontend/lib/presentation/quaderno_screen/nodo_quaderno_screen.dart
- **Gate**: 3+ test integrazione, tutti i test esistenti continuano a passare, analyze 0
- **Note**: Riscritta NodoQuadernoScreen con 10 sezioni: StatoHeader, breadcrumb (tema>nodo), chip parole chiave, Cosa imparerai (CollapsibleText), Formule chiave (FormulaCurriculumCard), Esempi, Attenzione a... (ErroreComuneCard), Le mie note (NotaUtenteEditor), separator "Il tuo percorso", log personale (FormuleSection+EserciziSection+SpiegazioniSection). Fix lint B35.5.4 (underscore variabile locale). 11 nuovi test integrazione. 500 frontend verdi, analyze 0.

### Blocco B35.6 — Polish empty states (bonus)
- [x] **Stato**: completato (S41)
- **Complessita'**: bassa
- **Descrizione**: Audit + fix degli stati vuoti e dei messaggi di benvenuto nelle varie schermate dell'app. Bonus block dopo B35.5 per ripulire incongruenze emerse dal test manuale (e altre potenziali non scoperte).
- **Schermate da rivedere**: Profilo (utente nuovo senza sessioni), Sezione Ripasso in Home (lista vuota), I miei studi (search senza match), Recap sessione con 0 esercizi, Storico sessioni vuoto. Login gia fixato in B38.5, onboarding rimandato a B39.
- **Gate di uscita**: empty states verificati e fixati, 2-4 widget test nuovi, analyze 0
- **NON fare**: riscrivere schermate intere, toccare backend, toccare onboarding
- **Note**: 4 fix applicati: EmptyStateWidget (rimosso URL Unsplash, icona nativa + testo caldo), SessionHistoryWidget (messaggio per storico vuoto), ProfileScreen achievement (messaggio motivazionale con icona), ProfileScreen stats (messaggio guida utente nuovo). Sezione ripasso Home e search I miei studi gia gestiti correttamente. Recap con 0 esercizi gestito dalla narrativa. 6 nuovi test. 506 frontend verdi, analyze 0.

### Blocco B35.7 — Pull-to-refresh sulle liste principali (bonus)
- [x] **Stato**: completato (S42)
- **Complessita'**: bassa
- **Descrizione**: RefreshIndicator con pull-to-refresh su Home, I miei studi, Profilo, Storico sessioni. Riusa metodi provider gia esistenti.
- **Gate di uscita**: 3-4 schermate con pull-to-refresh, 2+ widget test, analyze 0
- **Note**: HomeScreen: RefreshIndicator + AlwaysScrollableScrollPhysics + _handleRefresh (parallelo). LearningPathScreen: IconButton refresh in AppBar (GraphOverview non scrollabile per InteractiveViewer). ProfileScreen gia aveva RefreshIndicator. 4 nuovi test. 510 frontend verdi, analyze 0.

### Blocco B35.8 — Snackbar errori user-friendly (bonus)
- [x] **Stato**: completato (S43)
- **Complessita'**: bassa
- **Descrizione**: Audit + fix dei messaggi errore mostrati all'utente. Helper centralizzato `error_messages.dart` con `userFriendlyError(error)`. Sostituisce messaggi tecnici (DioException, 404, FormatException) con stringhe italiane gentili.
- **Gate di uscita**: helper creato, 5-6 punti aggiornati, 3+ unit test, analyze 0
- **Note**: Creato `utils/error_messages.dart` con `userFriendlyError()` (pattern matching su timeout, rete, HTTP 4xx/5xx, exception Dart). Applicato in 7 punti: studio_screen (2 snackbar), nodo_quaderno_screen, profile_screen, session_provider (stream + ErroreEvent), onboarding_provider (stream + ErroreEvent). Fix sse_client.dart (rimosso leak `$e` in 2 catch). Riscritto custom_error_widget.dart in italiano con Theme.of(context). 20 nuovi test (18 unit + 2 widget). 530 frontend verdi, analyze 0.

### Blocco B35.9 — Loading skeleton al posto degli spinner (bonus)
- [x] **Stato**: completato (S44)
- **Complessita'**: bassa-media
- **Descrizione**: Nuovo widget riutilizzabile `SkeletonLoader` con `SkeletonBox`, `SkeletonText`, `SkeletonCard`. Sostituisce `CircularProgressIndicator` nelle schermate principali (Home, I miei studi, Quaderno, Recap).
- **Gate di uscita**: widget riutilizzabili creati, 3-4 schermate aggiornate, 3+ widget test, analyze 0
- **Note**: Creato skeleton_loader.dart con ShimmerGroup (AnimationController condiviso via InheritedWidget), SkeletonBox (shimmer gradient animato), SkeletonLine, SkeletonCard. 4 layout pre-composti: LearningPathSkeleton, QuadernoSkeleton, RecapSkeleton, ProfileSkeleton. Sostituiti CircularProgressIndicator in 4 schermate (learning_path_screen, nodo_quaderno_screen, recap_session_screen, profile_screen). Aggiornato test b35_quaderno_screen_test. 11 nuovi test. 541 frontend verdi, analyze 0.

### Blocco B35.10 — Search mappa percorso con parole_chiave (bonus)
- [x] **Stato**: completato (S45)
- **Complessita'**: bassa
- **Descrizione**: Estende la ricerca in LearningPathScreen per cercare anche nelle parole_chiave del nodo (oltre al nome). Sfrutta i dati esposti da B35.5.1.
- **Gate di uscita**: search estesa, 2+ widget test, analyze 0
- **Note**: Backend: aggiunto parole_chiave alla response GET /percorsi/{id}/mappa. Frontend: NodoMappa con paroleChiave, ricerca estesa nome+keyword. 11 nuovi test (ricerca keyword + deserializzazione). 552 frontend verdi, analyze 0.

### Blocco B35.11 — Coerenza tono di voce italiana (bonus)
- [x] **Stato**: completato (S46)
- **Complessita'**: bassa
- **Descrizione**: Audit dei testi UI italiani. Verifica uso del "tu" coerente, traduce inglesismi residui (Login, Loading, Submit), uniforma terminologia. Crea `docs/tone-of-voice.md`.
- **Gate di uscita**: audit completato, fix applicati, file tone-of-voice creato, analyze 0
- **Note**: Audit completo su 119 file Dart. 3 fix applicati: 'Streak' → 'Serie' (profilo + recap), 'Achievement' → 'Traguardi' (profilo). Creato docs/tone-of-voice.md con terminologia standard, regole tono, parole inglesi accettate. App gia 95% italiana — uso coerente del "tu", errori gia in italiano (userFriendlyError), empty states ok. 552 frontend verdi, analyze 0.

### Blocco B35.12 — Audit dev-shortcuts.md priorita alta (bonus)
- [x] **Stato**: completato (S47)
- **Complessita'**: media
- **Descrizione**: Apre `docs/dev-shortcuts.md` e risolve almeno 2-3 voci marcate come priorita alta (credenziali hardcoded, CORS aperto, mock, TODO/FIXME). Aggiorna il file marcando come risolto.
- **Gate di uscita**: 2-3 voci risolte, file aggiornato, tutti i test continuano a passare, analyze 0
- **Note**: 3 voci alta priorita risolte: (1) JWT_SECRET + (2) ANTHROPIC_API_KEY — validate_secrets_for_startup() in config.py, warning in DEBUG, errore in produzione, chiamata dalla lifespan di main.py. (3) Credenziali PostgreSQL — interpolazione ${VAR:-default} in docker-compose.yml, variabili in .env (gitignored), creato .env.example con segnaposto. model_config extra="ignore" per tollerare variabili POSTGRES_*. 7 nuovi test backend. 363 backend (10 skipped), 552 frontend verdi, analyze 0.

### Blocco B35.13 — Audit accessibilita base (Semantics) (bonus)
- [x] **Stato**: completato (S48)
- **Complessita'**: media
- **Descrizione**: Aggiunge `Semantics` labels su widget interattivi delle schermate principali. Rimuove TextScaler.linear(1.0) bloccato. Audit contrasto colori dei testi principali.
- **Gate di uscita**: 5+ schermate con Semantics labels base, TextScaler ripristinato, 2-3 fix contrasto, analyze 0
- **Note**: Rimosso TextScaler.linear(1.0) da main.dart. Semantics su 7 widget interattivi (LinearPathMap, GraphOverview, ToolsTray, Mascotte, TutorPanel, CollapsibleText). Tooltip su 5 IconButton chiudi. Fix contrasto celebration_overlay (alpha 0.7>0.87). dev-shortcuts aggiornato. 12 nuovi test. 564 frontend verdi, analyze 0.

### Blocco B36 — Impostazione dimensione font in-app
- [x] **Stato**: completato (S50)
- **Complessita'**: bassa-media
- **Descrizione**: Aggiunge un'impostazione utente per scalare la dimensione dei font dell'app. 4 opzioni discrete (Piccolo 0.85 / Normale 1.0 / Grande 1.15 / Molto grande 1.3). Sezione "Aspetto" nel Profilo con anteprima live. Helper LaTeX per coordinare le formule (flutter_math_fork non rispetta TextScaler nativo).
- **File creati**: font_scale_provider.dart, latex_font_size.dart
- **File modificati**: main.dart, profile_screen.dart, formula_curriculum_card.dart, esempio_inline_card.dart
- **Gate di uscita**: provider con persistenza, MediaQuery wrapper, helper LaTeX, UI con 4 opzioni e anteprima, 8 test nuovi, analyze 0, 588 frontend verdi
- **Note**: Provider Riverpod + SharedPreferences (pattern identico a theme_provider). MediaQuery builder in main.dart moltiplica TextScaler di sistema per fattore Dydat (complementare, non sostitutivo). Helper scaledLatexFontSize per flutter_math_fork. FormulaCurriculumCard e EsempioInlineCard convertiti da StatelessWidget a ConsumerWidget. 2 test esistenti aggiornati con ProviderScope.

### Blocco B35.14 — Fix post-test manuale nottata (consolidamento)
- [x] **Stato**: completato (S49)
- **Complessita'**: media
- **Descrizione**: Blocco di fix chirurgico dopo test manuale Villa sulla nottata B35.5.1-B35.13. 7 bug raccolti in `.claude/test-findings-nottata.md`. Branch: `wip/notte-quaderno-polish-2026-04-07`.
- **Bug**: NB-01 formule LaTeX troppo grandi, NB-02 LaTeX esempi non renderizzato, NB-03 singolare/plurale italiano (helper centralizzato), NB-04 log personale nascosto invece di empty state, NB-05 errore quaderno offline non usa helper user-friendly, NB-06 lucchetto su nodi 'da iniziare' (regressione B38.5), NB-07 overflow MiniPercorso con TextScaler aumentato.
- **File da toccare**: formula_curriculum_card.dart, nodo_quaderno_screen.dart, linear_path_map.dart, mini_percorso_widget.dart, nuovi pluralize.dart e esempio_inline_card.dart
- **Gate di uscita**: 7 bug fixati, 6+ widget test, analyze 0, tutti i test esistenti passano, commit atomico
- **Note**: NB-01: FittedBox + fontSize 20.sp su FormulaCurriculumCard. NB-02: nuovo EsempioInlineCard con _looksLikeLaTeX + Math.tex + onErrorFallback. NB-03: nuovo pluralize.dart (sessione/giorno/esercizio/nodo/ripasso), applicato in stato_header + welcome_header. NB-04: separator sempre visibile + _buildLogEmptyState con messaggio invitante. NB-05: gia corretto (userFriendlyError gia presente). NB-06: lock_outline -> circle_outlined per nodi nonIniziato. NB-07: rimosso SizedBox(height:80) fisso + FittedBox sui nomi nodo. 13 nuovi test, 2 test aggiornati. 577 frontend verdi, analyze 0.

---

## Fase 10 — UX Redesign: Onboarding + Audio (Fase A.5, B39-B40)

> Riferimento: concept v1.1 sezioni 4, 11
> Primo contatto memorabile e sistema audio che da personalita.

### Blocco B39 — Onboarding Narrativo con Momento Wow
- [>] **Stato**: in corso (11/38 sub-blocchi completati)
- **Complessita'**: alta
- **Descrizione**: Ridisegnare l'onboarding come flusso narrativo ibrido adattivo. L'utente si racconta liberamente (anche a voce tramite OpenAI Whisper), un estrattore Opus trasforma la conversazione in un profilo strutturato a 5 campi (chi_e, motivo, stile_cognitivo, tempo_disponibile, vissuto_scolastico). Un decisore rules-based gestisce la forma C adattiva (1 turno libero + domande mirate sui buchi, max 7 turni). Placement test con auto-valutazione + verifica compound. Tutor personificato con patto esplicito, skip rinviabile con banner Home persistente.
- **Riferimento strategico**: `docs/discussions/b39-onboarding-narrativo.md` (documento di discovery con le 12 decisioni di design prese con Villa, visione, esempi concreti, rischi e criteri di successo)
- **Spezzato in 38 sub-blocchi** piccoli e granulari distribuiti in 11 fasi tematiche, per consentire al runner di lavorare con context ridotto in ogni sessione.

#### Blocco B39.1.1 — Migrazione Alembic: onboarding_stato + lingua_preferita
- [x] **Stato**: completato
- **Complessita'**: bassa
- **Descrizione**: Aggiungere due nuovi campi alla tabella `utenti`: `onboarding_stato` (enum not_started/in_progress/completed) e `lingua_preferita` (varchar, default 'it').
- **File da toccare**: nuova migrazione in `backend/alembic/versions/`
- **Gate**: migrazione applicata, upgrade/downgrade verificati, tutti i test backend continuano a passare

#### Blocco B39.1.2 — Modello SQLAlchemy Utente
- [x] **Stato**: completato
- **Complessita'**: bassa
- **Descrizione**: Aggiornare modello `Utente` in `backend/app/db/models/utenti.py` per esporre i nuovi campi con enum `OnboardingStato` e default sensati.
- **File da toccare**: `backend/app/db/models/utenti.py`
- **Gate**: 9+ unit test modello, tutti i test esistenti passano

#### Blocco B39.1.3 — Schema Pydantic UtenteResponse
- [x] **Stato**: completato
- **Complessita'**: bassa
- **Descrizione**: Aggiornare gli schemi Pydantic in `backend/app/schemas/` per serializzare i nuovi campi nelle response API.
- **File da toccare**: `backend/app/schemas/utente.py` (o file correlato)
- **Gate**: 9+ test contract (serializzazione, defaults, from_attributes), tutti i test passano

#### Blocco B39.2.1 — Prompt estrattore profilo onboarding
- [x] **Stato**: completato
- **Complessita'**: media
- **Descrizione**: Scrivere in `backend/app/llm/prompts/onboarding_extractor.py` il prompt che istruisce Opus a estrarre i 5 campi del profilo (chi_e, motivo, stile_cognitivo, tempo_disponibile, vissuto_scolastico) con confidenze (alta/media/bassa) dalla conversazione onboarding. JSON rigido con 2 esempi few-shot.
- **File da toccare**: nuovo `backend/app/llm/prompts/onboarding_extractor.py`
- **Gate**: 21+ test unitari su costanti, schema JSON, formattazione conversazione, build_extractor_prompt

#### Blocco B39.2.2 — Schema Pydantic output estrattore
- [x] **Stato**: completato
- **Complessita'**: bassa
- **Descrizione**: Modelli Pydantic `CampoConConfidenza` e `ProfiloEstratto` in `backend/app/schemas/onboarding.py` per rappresentare l'output dell'estrattore.
- **File da toccare**: `backend/app/schemas/onboarding.py`
- **Gate**: test di validazione, serializzazione, deserializzazione

#### Blocco B39.2.3 — Funzione estrai_profilo con Opus + retry
- [x] **Stato**: completato
- **Complessita'**: media
- **Descrizione**: Funzione `estrai_profilo(conversazione)` in `backend/app/core/onboarding.py` che chiama Opus con il prompt, parsa il JSON, valida con Pydantic, gestisce retry su errore. Fallback a profilo vuoto in caso di fallimento irrecuperabile.
- **File da toccare**: `backend/app/core/onboarding.py`
- **Gate**: unit test con mock LLM (JSON prefabbricati), test retry logic, test fallimento totale

#### Blocco B39.2.4 — Unit test integrazione estrattore
- [x] **Stato**: completato
- **Complessita'**: media
- **Descrizione**: Test di integrazione dell'estrattore su scenari realistici con mock LLM: utente collaborativo, parziale, off-topic, conversazione vuota, fallimento LLM con retry, confidenze miste, conversazione lunga.
- **File da toccare**: nuovo `backend/tests/test_b39_2_4_extractor_integration.py`
- **Gate**: 18+ test nuovi su 7 scenari, 488 backend verdi

#### Blocco B39.3.1 — Rules-based decisor puro Python
- [x] **Stato**: completato
- **Complessita'**: media
- **Descrizione**: Funzione `decidi_prossima_mossa(profilo_stato, turni_fatti)` pura Python (nessun LLM) che, dato lo stato del profilo + turni fatti, decide la prossima mossa del tutor: chiedi campo mancante, chiudi narrativa, forza chiusura al tetto turni. Priorita tra campi: chi_e > motivo > stile_cognitivo > tempo_disponibile > vissuto_scolastico.
- **File da toccare**: `backend/app/core/onboarding.py`, `backend/app/schemas/onboarding.py` (per enum `AzioneDecisore`)
- **Gate**: 23+ unit test su 10+ scenari, 511 backend verdi

#### Blocco B39.3.2 — Integrazione decisore nell'endpoint /onboarding/turno
- [x] **Stato**: completato
- **Complessita'**: media
- **Descrizione**: Dopo ogni turno utente nell'endpoint `/onboarding/turno`, chiamare l'estrattore di B39.2.3 per aggiornare il profilo, poi chiamare il decisore di B39.3.1 per determinare la prossima mossa del tutor. L'endpoint ritorna nella response la fase corrente e l'azione decisa.
- **File da toccare**: `backend/app/api/onboarding.py` (modifica endpoint turno), eventualmente `backend/app/core/onboarding.py`
- **Gate**: integration test del flusso turno completo con mock LLM, tutti i test esistenti passano
- **Note**: elabora_decisione_onboarding() in core/onboarding.py. Evento SSE 'decisione_onboarding' con azione/campo_da_chiedere/motivo/fase_corrente/campi_completi. aggiorna_fase_onboarding non transisce piu' da sola a placement (gestito dal decisore). 13 nuovi test, 2 aggiornati. 524 backend verdi (10 skipped).

#### Blocco B39.4.1 — Fix completa_onboarding scrittura profilo (ONB-01)
- [x] **Stato**: completato
- **Complessita'**: media
- **Descrizione**: La funzione `completa_onboarding` in `backend/app/core/onboarding.py` deve scrivere `profilo_sintetizzato`, `contesto_personale`, `preferenze_tutor` sull'utente usando i dati estratti dalla conversazione (fix del finding ONB-01: oggi non vengono mai scritti).
- **File da toccare**: `backend/app/core/onboarding.py`, `backend/app/api/onboarding.py` (schema payload)
- **Gate**: integration test verifica i 3 campi popolati nel DB dopo completamento, ONB-01 chiuso
- **Note**: 3 helper (_costruisci_profilo_sintetizzato, _costruisci_contesto_personale, _costruisci_preferenze_tutor). Profilo estratto letto da stato_orchestratore. Payload ha priorita' su profilo estratto. onboarding_stato aggiornato a COMPLETED. Gestione errore su profilo malformato. 16 nuovi test. 540 backend verdi (10 skipped).

#### Blocco B39.4.2 — Fix persistenza streaming turni (ONB-02)
- [x] **Stato**: completato (S52)
- **Complessita'**: media
- **Descrizione**: Fix del finding ONB-02: i turni del tutor in sessione onboarding vengono salvati con `contenuto = None` in presenza di tool use. Serve garantire che l'UPDATE finale del contenuto streamato avvenga anche quando ci sono tool use. Aggiungere logging se lo stream finisce senza contenuto.
- **File da toccare**: `backend/app/core/turno.py`
- **Gate**: unit test simula stream con tool use + contenuto, verifica persistenza nel DB
- **Note**: Accumulo testo indipendente (`testo_accumulato_locale`) in `esegui_turno` come rete di sicurezza. Se `risultato_llm.testo_completo` e vuoto ma `text_delta` ricevuti, usa il testo locale come fallback. Logging diagnostico per fallback (warning) e turno solo tool-use (info). 10 nuovi test. 550 backend verdi (10 skipped).

#### Blocco B39.4.3 — Pulizia codice onboarding legacy
- [x] **Stato**: completato (S53)
- **Complessita'**: bassa
- **Descrizione**: Rimuovere codice dell'onboarding vecchio non piu utilizzato dopo il refactor di B39.3.2 e B39.4.1.
- **File da toccare**: vari in `backend/app/core/onboarding.py` e `backend/app/api/onboarding.py`
- **Gate**: tutti i test esistenti continuano a passare, nessuna regressione
- **Note**: Rimosso TURNI_CONOSCENZA_MAX (sostituito da TETTO_TURNI_NARRATIVI nel decisore). Rimosso AzioneDecisore.passa_a_placement (mai usato). Aggiornate docstring e test. 550 backend verdi, 10 skipped.

#### Blocco B39.5.1 — Configurazione OPENAI_API_KEY
- [x] **Stato**: completato (S54)
- **Complessita'**: bassa
- **Descrizione**: Aggiungere segreto `OPENAI_API_KEY` al backend per uso Whisper. Aggiornare `.env.example`, `docker-compose.yml`, `validate_secrets_for_startup` in `config.py`. Registrare la nuova dipendenza esterna in `docs/dev-shortcuts.md`.
- **File da toccare**: `backend/app/config.py`, `backend/.env.example`, `backend/docker-compose.yml`, `docs/dev-shortcuts.md`
- **Gate**: unit test verifica fallimento in produzione se chiave manca, backend parte con chiave presente
- **Note**: OPENAI_API_KEY aggiunta a Settings con default vuoto. validate_secrets_for_startup estesa (warning in DEBUG, errore in produzione). docker-compose.yml non modificato (env_file: .env gia passa tutte le variabili). Registrata in dev-shortcuts.md. 5 nuovi test, 2 aggiornati. 555 backend verdi (10 skipped).

#### Blocco B39.5.2 — Endpoint POST /stt/transcribe
- [x] **Stato**: completato (S55)
- **Complessita'**: media
- **Descrizione**: Nuovo endpoint che riceve audio multipart, chiama OpenAI Whisper via client Python, restituisce il testo trascritto. Gestione errori (formato invalido, API down, rate limit).
- **File da toccare**: nuovo `backend/app/api/stt.py`, registrare router in `backend/app/main.py`
- **Gate**: unit test con mock client OpenAI, test formato invalido, test API down
- **Note**: Endpoint POST /stt/transcribe con validazione formato (7 estensioni audio), limite 25 MB, lingua italiana. Gestione errori: 400 formato/vuoto/grande, 422 nessun parlato, 429 rate limit, 502 API down, 503 chiave mancante/invalida. Dipendenze aggiunte: openai, python-multipart. 13 nuovi test. 568 backend verdi (10 skipped).

#### Blocco B39.5.3 — Test endpoint STT con audio reale
- [x] **Stato**: completato (S56)
- **Complessita'**: bassa
- **Descrizione**: Test di integrazione con audio reale di smoke (file WAV italiano di prova) per l'endpoint `/stt/transcribe`. Marcato `@pytest.mark.integration` (non gira nel runner automatico).
- **File da toccare**: nuovo `backend/tests/test_b39_5_3_stt_integration.py`
- **Gate**: test skippato di default, eseguibile con flag integration, verde in esecuzione manuale
- **Note**: 3 smoke test integration (tono WAV 440Hz, silenzio WAV, formato MP3) + 1 test helper (sempre attivo). WAV generati programmaticamente con modulo wave. Skip automatico se OPENAI_API_KEY non configurata. 569 backend verdi (13 skipped), ruff pulito.

#### Blocco B39.6.1 — Prompt auto-valutazione placement
- [x] **Stato**: completato (S57)
- **Complessita'**: bassa
- **Descrizione**: Prompt in `backend/app/llm/prompts/onboarding_self_assessment.py` che istruisce il tutor a chiedere per ogni area chiave della materia se l'utente si sente `forte` / `incerto` / `digiuno`.
- **File da toccare**: nuovo `backend/app/llm/prompts/onboarding_self_assessment.py`
- **Gate**: unit test presenza istruzioni chiave, aree selezionate dal grafo curriculum
- **Note**: build_self_assessment_prompt (direttiva tutor con aree, livelli, marker strutturato), parse_autovalutazione (parser blocco [AUTOVALUTAZIONE]), seleziona_aree_da_grafo (selezione temi ordinati per importanza). 34 nuovi test. 603 backend verdi (13 skipped), ruff pulito.

#### Blocco B39.6.2 — Logica selezione aree fondazionali
- [x] **Stato**: completato (S58)
- **Complessita'**: media
- **Descrizione**: Funzione `seleziona_aree_fondazionali(aree_forte, grafo)` che, data la lista aree dichiarate forti dall'utente, seleziona le N piu fondazionali partendo dai nodi del grafo con meno prerequisiti. Cap a 6 per la verifica.
- **File da toccare**: `backend/app/llm/prompts/onboarding_self_assessment.py`
- **Gate**: unit test deterministici con grafo mockato
- **Note**: Fondazionalita' calcolata come posizione media dei nodi del tema nell'ordine topologico (piu' bassa = piu' fondazionale). Costante MAX_AREE_FONDAZIONALI = 6. Ignora nodi contesto, aree non presenti nel grafo, nodi senza tema_id. 21 nuovi test. 624 backend verdi (13 skipped), ruff pulito.

#### Blocco B39.6.3 — Prompt generatore esercizi compound
- [x] **Stato**: completato (S59)
- **Complessita'**: media
- **Descrizione**: Prompt Opus in `backend/app/llm/prompts/onboarding_exercise_generator.py` che genera un esercizio a scelta multipla (3-4 opzioni, 1 risposta corretta) che copre fino a 2 concetti contemporaneamente.
- **File da toccare**: nuovo `backend/app/llm/prompts/onboarding_exercise_generator.py`
- **Gate**: unit test presenza istruzioni (max 2 concetti, formato multiple choice), output JSON specificato
- **Note**: build_exercise_prompt (coppie concetti -> prompt Opus con schema JSON), parse_exercise_response (parser robusto con validazione struttura, gestione markdown wrapper, fallback None). Costanti: MAX_ESERCIZI_VERIFICA=3, MAX_CONCETTI_PER_ESERCIZIO=2, MIN/MAX_OPZIONI=3/4. Schema esempio con testo/concetti/opzioni/risposta_corretta/spiegazione_breve. 36 nuovi test (costanti, prompt, parser con edge case). 660 backend verdi (13 skipped), ruff pulito.

#### Blocco B39.6.4 — Funzione genera_esercizi_verifica
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Funzione `genera_esercizi_verifica(aree_da_verificare)` che prende le aree in coppie, chiama Opus per ciascuna coppia con il prompt di B39.6.3, ritorna lista di esercizi compound. Max 3 esercizi (cap duro). Retry su fallimento, lista vuota in caso di fallimento totale.
- **File da toccare**: `backend/app/core/onboarding.py`, schema `EsercizioCompound` in `backend/app/schemas/onboarding.py`
- **Gate**: unit test con mock LLM, test schema output, test retry

#### Blocco B39.6.5 — Logica grading deterministico
- [ ] **Stato**: da fare
- **Complessita'**: bassa
- **Descrizione**: Funzione `valuta_risposta(esercizio, risposta_utente)` deterministica che confronta la scelta dell'utente con la risposta corretta. Ritorna bool + lista concetti retroceduti in caso di fail (entrambi i concetti dell'esercizio compound → incerto).
- **File da toccare**: `backend/app/core/onboarding.py`
- **Gate**: unit test con risposte corrette e sbagliate, verifica retrocessione concetti

#### Blocco B39.6.6 — Integrazione stato_orchestratore + path planner
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Salvare la mappa placement finale (`{concetto: forte_confermato/forte_unverified/incerto/digiuno}`) nello `stato_orchestratore` della sessione onboarding. Il path planner la legge per scegliere il nodo di partenza del percorso.
- **File da toccare**: `backend/app/core/onboarding.py`, `backend/app/core/path_planner.py`
- **Gate**: integration test flusso completo onboarding + placement + creazione percorso

#### Blocco B39.7.1 — Scheletro widget VoiceInputField
- [ ] **Stato**: da fare
- **Complessita'**: bassa
- **Descrizione**: File Flutter con struttura base del widget riutilizzabile: TextFormField + pulsante microfono disabilitato come placeholder. Nessuna funzionalita audio ancora.
- **File da toccare**: nuovo `frontend/lib/widgets/voice_input_field.dart`
- **Gate**: widget compila, widget test rendering base

#### Blocco B39.7.2 — Libreria audio + permessi mic
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Aggiungere libreria audio (es. `record` o equivalente), configurare permessi microfono in `AndroidManifest.xml` e `Info.plist`, integrare in `VoiceInputField` l'avvio/stop registrazione.
- **File da toccare**: `frontend/pubspec.yaml`, `frontend/android/app/src/main/AndroidManifest.xml`, `frontend/ios/Runner/Info.plist`, `voice_input_field.dart`
- **Gate**: permessi configurati, widget registra/ferma audio con mock

#### Blocco B39.7.3 — UI stato registrazione
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Feedback visivo durante registrazione: wave animata sul volume della voce, timer secondi, pulsante stop rosso pulsante, sfondo del campo leggermente diverso.
- **File da toccare**: `voice_input_field.dart`
- **Gate**: widget test stato registrazione attivo, animazioni renderizzano

#### Blocco B39.7.4 — Chiamata endpoint /stt/transcribe
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Dopo lo stop della registrazione, upload dell'audio al backend, gestione spinner durante la trascrizione.
- **File da toccare**: `voice_input_field.dart`, nuovo `frontend/lib/services/stt_service.dart`
- **Gate**: widget test con mock service, upload funzionante, spinner visibile

#### Blocco B39.7.5 — Popolamento campo testo trascritto modificabile
- [ ] **Stato**: da fare
- **Complessita'**: bassa
- **Descrizione**: Il testo trascritto popola il campo input, l'utente lo puo modificare a tastiera prima di inviare. NO auto-invio.
- **File da toccare**: `voice_input_field.dart`
- **Gate**: widget test flusso completo registrazione → trascrizione → modifica → invio

#### Blocco B39.7.6 — Gestione errori + widget test
- [ ] **Stato**: da fare
- **Complessita'**: bassa
- **Descrizione**: Gestione fallimenti: mic denied, rete assente, API STT down, audio troppo corto. Fallback silenzioso con messaggio breve "La voce non e disponibile — puoi continuare a scrivere".
- **File da toccare**: `voice_input_field.dart`
- **Gate**: widget test su ogni fallimento, utente puo sempre scrivere a mano

#### Blocco B39.8.1 — Aggiorna onboarding_provider.dart
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Il provider deve passare i dati reali al backend, gestire le nuove fasi (conoscenza/auto-valutazione/verifica/chiusura), gestire lo skip.
- **File da toccare**: `frontend/lib/providers/onboarding_provider.dart`
- **Gate**: unit test provider con nuove fasi, flussi mockati

#### Blocco B39.8.2 — Riscrittura onboarding_screen.dart con VoiceInputField + skip
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Schermata onboarding usa il nuovo widget VoiceInputField, ha il bottone "Salta per ora" visibile fin dalla prima schermata.
- **File da toccare**: `frontend/lib/presentation/onboarding_screen/onboarding_screen.dart`
- **Gate**: widget test nuovo flusso, test skip, rendering corretto

#### Blocco B39.8.3 — System prompt tutor onboarding riscritto
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Scrivere il system prompt del tutor di onboarding: personificato in prima persona, patto esplicito, menzione della voce, tono caldo, forma C adattiva.
- **File da toccare**: nuovo `backend/app/llm/prompts/onboarding_system_prompt.py`, integrato nel flusso del turno
- **Gate**: unit test presenza istruzioni chiave (io sono Dydat, patto, voce, adattivita)

#### Blocco B39.8.4 — Test integrazione onboarding completo
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Test end-to-end del flusso onboarding con mock LLM: utente collaborativo -> completamento, utente taciturno -> chiusura forzata al turno 7, utente che salta.
- **File da toccare**: `frontend/test/presentation/onboarding_screen_test.dart`
- **Gate**: widget test flusso completo verde

#### Blocco B39.9.1 — Widget OnboardingPendingBanner
- [ ] **Stato**: da fare
- **Complessita'**: bassa
- **Descrizione**: Card persistente, non dismissibile, con messaggio caldo + CTA "Riprendi" / "Inizia" a seconda dello stato onboarding.
- **File da toccare**: nuovo `frontend/lib/widgets/onboarding_pending_banner.dart`
- **Gate**: widget test rendering + tap su CTA

#### Blocco B39.9.2 — Integrazione banner in home_screen
- [ ] **Stato**: da fare
- **Complessita'**: bassa
- **Descrizione**: Il banner compare condizionale su `onboarding_stato != completato`. Nascosto quando l'onboarding e completo.
- **File da toccare**: `frontend/lib/presentation/home_screen/home_screen.dart`
- **Gate**: widget test con stati vari (not_started, in_progress, completed)

#### Blocco B39.9.3 — Logica "Riprendi" con stato preservato
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Il tap su "Riprendi" riapre `/onboarding` con la conversazione precedente intatta. Il backend deve supportare il retrieval della sessione esistente.
- **File da toccare**: `onboarding_provider.dart`, `onboarding_screen.dart`, modifica backend `/onboarding/inizia`
- **Gate**: integration test ripresa onboarding dopo skip

#### Blocco B39.10.1 — VoiceInputField in chat di sessione studio
- [ ] **Stato**: da fare
- **Complessita'**: bassa
- **Descrizione**: Sostituire il campo input della chat tutor in sessione di studio con il nuovo widget `VoiceInputField`.
- **File da toccare**: schermata session screen dove e il campo input
- **Gate**: widget test integrazione, microfono visibile e funzionante

#### Blocco B39.10.2 — VoiceInputField in ricerca "I miei studi"
- [ ] **Stato**: da fare
- **Complessita'**: bassa
- **Descrizione**: Sostituire il campo di ricerca in `learning_path_screen` con il nuovo widget `VoiceInputField`.
- **File da toccare**: `learning_path_screen.dart` o widget search correlato
- **Gate**: widget test integrazione

#### Blocco B39.10.3 — Widget test finali integrazione trasversale
- [ ] **Stato**: da fare
- **Complessita'**: bassa
- **Descrizione**: Test che verificano il comportamento di `VoiceInputField` in tutti i contesti di utilizzo (onboarding, sessione, ricerca).
- **File da toccare**: test widget vari
- **Gate**: tutti i test verdi, nessuna regressione

#### Blocco B39.11.1 — Checklist test manuale + consegna
- [ ] **Stato**: da fare
- **Complessita'**: bassa
- **Descrizione**: Claude prepara un file con scenari dettagliati per il test manuale del fondatore (utente collaborativo, taciturno, off-topic, skip, voce, placement, banner). Villa eseguira il test e riportera i finding in `.claude/test-findings.md`. Dopo B39.11.1 la catena B39 si chiude con STATUS: PHASE_COMPLETE.
- **File da toccare**: nuovo `docs/discussions/b39-checklist-test-manuale.md`
- **Gate**: file creato, scenari chiari, pronto per Villa

### Blocco B40 — Sistema Audio Base
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Aggiungere micro-suoni e feedback aptico. (1) AudioService con pool di suoni: esercizio_corretto, esercizio_errato (morbido), promozione, achievement, transizione_sessione, azione_mascotte. (2) Feedback aptico (HapticFeedback): leggero per interazioni, forte per promozioni. (3) Impostazioni: suoni on/off, volume. In Profilo > Impostazioni. (4) Suoni coerenti con mood "studio notturno" — toni caldi, non stridenti. (5) Asset audio da generare o trovare (placeholder accettabili).
- **File da toccare**: nuovo audio_service.dart, profile_screen.dart (impostazioni), studio_screen.dart (trigger suoni), celebration_overlay.dart
- **Gate di uscita**: Suoni funzionano, aptico funziona, impostazioni on/off, analyze 0, test verdi

---

## Fase 11 — UX Redesign: Integrazione + E2E (Fase A.6, B41-B42)

> Chiusura della Fase A. Integrazione, notifiche, test completo.

### Blocco B41 — Notifiche Push Base
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Implementare sistema notifiche push locale. (1) Plugin flutter_local_notifications. (2) Notifica ripasso FSRS: "Il concetto X sta scivolando via — 5 minuti bastano". Trigger: nodo con scadenza < 24h. (3) Notifica continuita: dopo N giorni senza sessione. Usa curiosita legata a cio che studiava. (4) Notifica sessione incompleta: se esce prima dell'obiettivo. (5) Configurabile da impostazioni Profilo.
- **File da toccare**: nuovo notification_service.dart, profilo impostazioni, integrazione con ripasso_provider
- **Gate di uscita**: Notifiche locali funzionano, 3 tipi implementati, configurabili, analyze 0, test verdi

### Blocco B42 — E2E Fase A + Guardiano di Fase
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Test end-to-end dell'intera Fase A. (1) Flusso completo: onboarding wow -> home -> studio (ibrido) -> esercizio fullscreen -> promozione -> chiusura narrativa -> ritorno home -> ripasso FSRS -> quaderno. (2) Guardiano di fase: architettura coerente? Sicurezza (input sanitizzati)? Nomi coerenti? Zero colori hardcoded? (3) Fix bug emersi. (4) Performance check: nessun jank, < 2s caricamenti.
- **File da toccare**: test e2e, fix vari
- **Gate di uscita**: Flusso completo funziona, guardiano superato, analyze 0, test verdi, PRONTO per PR develop->main

---

## Fase 12 — Feynman + Comprensione Profonda (B43-B46)

> Vecchia Fase 6, spostata dopo il redesign UX per costruire Feynman sulla nuova struttura ibrida.

### Blocco B43 — Feynman Signal Processing (Backend)
- [ ] **Stato**: da fare
- **Complessita'**: alta
- **Descrizione**: Attivare tool avvia_feynman e valutazione_feynman. Implementare _processa_valutazione_feynman() in elaborazione.py. Routing azione avvia_feynman.
- **Gate di uscita**: Feynman signal processing funziona, feynman_superato aggiornato, pytest verde

### Blocco B44 — Feynman Frontend Flow
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: FeynmanFullscreenView (coerente con modello ibrido B32): invito a spiegare, lista punti chiave, TextField multi-linea, bottone "Ho finito". Esce dal feed come gli esercizi.
- **Gate di uscita**: Feynman renderizza fullscreen, studente puo inviare spiegazione, record nel feed, analyze 0, test verdi

### Blocco B45 — Promozione Multi-Segnale: operativo -> comprensivo
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: _verifica_promozione_comprensivo(): feynman_superato + esercizi_consecutivi_ok >= 3 + sr_ripetizioni >= 2. Chiamata da _processa_risposta_esercizio e _processa_valutazione_feynman.
- **Gate di uscita**: Livello comprensivo raggiungibile, promozione multi-segnale funziona, pytest verde

### Blocco B46 — Feynman E2E + Loop Feynman Polish
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Stato comprensivo nel quaderno nodo e nella mappa. E2E: nodo operativo -> Feynman -> valutazione -> esercizi OK -> promozione comprensivo. Celebrazione coerente con beat system.
- **Gate di uscita**: Feynman E2E, comprensivo raggiungibile, quaderno aggiornato, analyze 0, test verdi

---

## Fase 13 — Visualizzazioni Native (Fase B, B47-B49)

> Riferimento: concept v1.1 sezione 7
> Il tutor che disegna: 3-4 widget Flutter nativi per visualizzazioni in tempo reale.

### Blocco B47 — Infrastruttura Visualizzazioni + Grafico Funzione
- [ ] **Stato**: da fare
- **Complessita'**: alta
- **Descrizione**: (1) Nuovo tool mostra_grafico nel backend con schema dati strutturato. (2) Evento SSE per visualizzazione. (3) VisualizationFullscreenView (coerente con modello ibrido). (4) Primo widget: grafico di funzione con fl_chart (y=f(x), zoom, pan).
- **Gate di uscita**: Tool funziona, SSE event, grafico renderizza, fullscreen, analyze 0, test verdi

### Blocco B48 — Piano Cartesiano + Geometria
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: (1) Widget piano cartesiano con punti, rette, intersezioni. (2) Widget geometria con CustomPainter: triangoli, cerchi, angoli, misure. (3) Tutor li invoca via tool-use con dati strutturati.
- **Gate di uscita**: Piano cartesiano e geometria funzionano, tutor li invoca correttamente, analyze 0, test verdi

### Blocco B49 — Animazione Fisica Base + E2E Fase B
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: (1) Widget animazione fisica semplice (moto rettilineo, caduta, pendolo) con AnimationController. (2) E2E: tutor spiega -> invoca visualizzazione -> studente vede -> torna al feed. (3) Guardiano di fase.
- **Gate di uscita**: Animazione fisica funziona, E2E completo, guardiano superato, analyze 0, test verdi

---

## Fase 14 — Motore Generativo (Fase C, B50-B52) — FUTURA

> Riferimento: concept v1.1 sezione 7.2 Livello 2
> WebView + JavaScript per visualizzazioni illimitate. Feature premium.

### Blocco B50 — Sandbox WebView + Primo Prototipo
- [ ] **Stato**: da fare
- **Complessita'**: alta
- **Descrizione**: WebView sandboxato in Flutter. L'AI genera codice JavaScript che viene eseguito. Comunicazione bidirezionale Flutter<->JS.

### Blocco B51 — Integrazione Tutor + Modello Opus
- [ ] **Stato**: da fare
- **Complessita'**: alta
- **Descrizione**: Il tutor con Opus genera codice per visualizzazioni arbitrarie. Pipeline: prompt -> codice JS -> sandbox -> rendering.

### Blocco B52 — E2E Fase C + Premium Flow
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Flusso premium completo. Differenziazione piano base/premium. Guardiano di fase.

---

## Dipendenze tra Fasi

- Fase 4.5 (Consolidamento): nessuna dipendenza esterna
- Fase 5 (FSRS): dipende da Fase 4.5 completata (baseline pulita)
- Fase 6 (UX Navigazione): dipende da Fase 5 completata
- Fase 7 (UX Sessione): dipende da Fase 6 (nuova navigazione)
- Fase 8 (UX Studi+Quaderno): dipende da Fase 6 (tab "I miei studi")
- Fase 9 (UX Atmosfera): dipende da Fase 7 (sessione ibrida per beat)
- Fase 10 (UX Onboarding+Audio): dipende da Fase 9 (mascotte per onboarding)
- Fase 11 (UX E2E): dipende da tutte le fasi A precedenti
- Fase 12 (Feynman): dipende da Fase 7 (modello ibrido per fullscreen Feynman)
- Fase 13 (Visualizzazioni): dipende da Fase 12 (tool-use consolidato)
- Fase 14 (Generativo): dipende da Fase 13 (infrastruttura visualizzazioni)

## Risultato Finale

Dopo Fase 14, lo studente puo: vivere un onboarding memorabile, usare un'app calda e con personalita, studiare in modalita immersiva con esercizi fullscreen, consultare il quaderno per nodo, ripassare con FSRS, dimostrare comprensione con Feynman, vedere visualizzazioni generate dal tutor in tempo reale, il tutto accompagnato da una mascotte espressiva e un sistema audio coerente.
