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
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Arricchire la Home creata in B30. (1) Mini-percorso visivo: posizione attuale nel percorso (nodo corrente, prossimo). (2) Invito contestuale: "Eravamo rimasti a [nome nodo]" usando dati sessione precedente. (3) Sezione ripasso FSRS (migrata da home_view_widget, migliorata graficamente). (4) Streak e ultimo risultato. (5) Ritorno dopo assenza: se ultima sessione > 7 giorni, messaggio gentile + lista nodi da ripassare. (6) Tono caldo, nessun senso di colpa.
- **File da toccare**: home_screen.dart (arricchire), eventuale home_widgets/ per sotto-widget
- **Gate di uscita**: Home mostra stato percorso, ripasso FSRS, ritorno contestuale, assenza lunga gestita, analyze 0, test verdi

---

## Fase 7 — UX Redesign: Sessione Ibrida (Fase A.2, B32-B33)

> Riferimento: concept v1.1 sezioni 5, 5.4, 5.5, 5.6
> Trasforma la sessione da chat a esperienza ibrida: esercizi e visualizzazioni escono dal feed.

### Blocco B32 — Modello Ibrido: Esercizi Fullscreen
- [ ] **Stato**: da fare
- **Complessita'**: alta
- **Descrizione**: Quando il tutor propone un esercizio (azione proponi_esercizio), l'ExerciseCardWidget esce dal feed e si prende lo schermo. (1) Creare ExerciseFullscreenView che wrappa ExerciseCardWidget in un layout dedicato (niente chat dietro, focus totale). (2) Transizione animata feed->fullscreen (slide up o fade). (3) Completato l'esercizio, il risultato rientra nel feed come record compatto. (4) Stessa logica per FormulaCardWidget (mostra_formula) e BacktrackCardWidget (suggerisci_backtrack): escono dal feed, tornano come record. (5) Il feed conversazionale resta scrollabile per le spiegazioni.
- **File da toccare**: studio_screen.dart, exercise_card_widget.dart, formula_card_widget.dart, backtrack_card_widget.dart, chat_view_widget.dart, nuovi file fullscreen view
- **Gate di uscita**: Esercizi in fullscreen, formule in fullscreen, record compatto nel feed dopo completamento, transizioni fluide, analyze 0, test verdi

### Blocco B33 — Transizione Sessione + Chiusura Narrativa
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: (1) Animazione di transizione Home->Studio: la mascotte "porta" lo studente dentro (< 2s). Corrisponde a Beat 1 della direzione visiva. (2) Chiusura sessione narrativa: recap_session_screen mostra prima il commento narrativo del tutor ("Oggi hai capito X, la prossima volta vedremo Y"), poi i numeri sotto (durata, esercizi, nodi). (3) Sessione a obiettivo: prima di iniziare, lo studente sceglie Veloce/Normale/Approfondita. Il tipo viene passato al backend (campo durata_obiettivo). (4) Se supera il tempo: suggerimento pausa dal tutor. Se esce prima: notifica leggera.
- **File da toccare**: studio_screen.dart (transizione), recap_session_screen.dart (narrativo+numeri), nuovo session_goal_picker.dart, mascotte_widget.dart (animazione transizione)
- **Gate di uscita**: Transizione animata funziona, recap narrativo+numeri, scelta obiettivo funziona, analyze 0, test verdi

---

## Fase 8 — UX Redesign: I Miei Studi + Quaderno (Fase A.3, B34-B35)

> Riferimento: concept v1.1 sezioni 3.2, 3.3
> Unifica Percorso e Quaderno in un unico tab con mappa e notebook per nodo.

### Blocco B34 — Percorso Unificato: Mappa + Zoom
- [ ] **Stato**: da fare
- **Complessita'**: alta
- **Descrizione**: Ridisegnare LearningPathScreen come "I miei studi". (1) Vista default: mappa lineare del percorso attuale (nodi come cerchi collegati, non card lista). (2) Zoom out: grafo completo delle connessioni tra concetti (algebra->geometria->fisica). Usa dati da pathProvider. (3) Nodi gia studiati in altri percorsi: indicatore "Gia studiato in [percorso]". (4) Ricerca per argomento: barra di ricerca che filtra nodi per nome. (5) Tap su nodo: apre quaderno (B35).
- **File da toccare**: learning_path_screen.dart (riscrittura), tema_card_widget.dart (sostituire con nodo visivo), nuovi widget mappa
- **Gate di uscita**: Mappa lineare funziona, zoom grafo funziona, ricerca funziona, tap su nodo navigabile, analyze 0, test verdi

### Blocco B35 — Quaderno per Nodo
- [ ] **Stato**: da fare
- **Complessita'**: alta
- **Descrizione**: Creare il Quaderno associato a ogni nodo del grafo. (1) NodoQuadernoScreen: raccoglie appunti, esercizi svolti, formule viste, spiegazioni chiave dal tutor per quel nodo. (2) Backend: nuovo endpoint GET /nodi/{id}/quaderno che aggrega sessioni, esercizi, azioni formula per quel nodo. (3) Frontend: schermata con sezioni (Appunti, Esercizi, Formule). Dati organizzati per tipo, non per sessione. (4) Il quaderno e uno per nodo (non per percorso): se "proporzioni" appare in algebra e chimica, il quaderno e lo stesso. (5) Da "I miei studi", tap su nodo apre il quaderno.
- **File da toccare**: nuovo nodo_quaderno_screen.dart, nuovo quaderno_service.dart, nuovo quaderno_provider.dart, backend endpoint, learning_path_screen.dart (navigazione)
- **Gate di uscita**: Quaderno mostra dati reali per nodo, aggregazione corretta, nodo condiviso = stesso quaderno, backend+frontend, analyze 0, test verdi

---

## Fase 9 — UX Redesign: Atmosfera e Mascotte (Fase A.4, B36-B38)

> Riferimento: concept v1.1 sezioni 5.4, 8, 11
> Porta personalita visiva all'app: superfici, beat emotivi, mascotte evoluta.

### Blocco B36 — Superfici: Gradienti, Glow, Profondita
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Aggiornare le superfici dell'app per riflettere il mood "studio notturno illuminato". (1) Card con gradienti sottili e bordi luminosi (glow ambra). (2) Profondita sulle superfici: ombre realistiche, layering. (3) Sfondi con gradienti radiali/lineari invece di colori piatti. (4) Applicare a: Home, I miei studi, Profilo, Studio. (5) Rispettare Theme.of(context) — zero colori hardcoded.
- **File da toccare**: app_theme.dart (nuovi token), widget delle varie schermate, possibile nuovo file surface_decorations.dart per mixin/widget condivisi
- **Gate di uscita**: Superfici con profondita, gradienti coerenti, zero colori hardcoded, analyze 0, test verdi

### Blocco B37 — Beat Emotivi + Transizioni
- [ ] **Stato**: da fare
- **Complessita'**: alta
- **Descrizione**: Implementare il sistema di beat emotivi dalla direzione visiva v2. (1) Enum BeatState: accoglienza, spiegazione, esercizio, attesa, esito_corretto, esito_errato, esito_dopo_guida, promozione, chiusura, scoperta. (2) BeatProvider (Riverpod) che calcola il beat corrente dallo stato sessione. (3) BeatOverlay: sottile cambio di atmosfera nel canvas (gradient overlay, animazione mascotte, tono colori). Opacita 0.05-0.15, mai invasivo. (4) Transizioni tra beat: animate, < 500ms. (5) La mascotte reagisce ai beat (collegamento con MascotteState esistente).
- **File da toccare**: nuovo beat_provider.dart, nuovo beat_overlay_widget.dart, studio_screen.dart, mascotte_widget.dart
- **Gate di uscita**: Beat si aggiornano con lo stato sessione, overlay visibile ma sottile, mascotte reagisce, analyze 0, test verdi

### Blocco B38 — Mascotte CustomPainter
- [ ] **Stato**: da fare
- **Complessita'**: alta
- **Descrizione**: Evolvere la mascotte da cerchio ambra a forma organica. (1) CustomPainter per forma morbida, organica (blob con curve di Bezier). (2) Occhi espressivi che riflettono il beat corrente. (3) Transizioni di forma/espressione per ogni beat. (4) Mantenere tap per tools tray. (5) Animazione di transizione "la mascotte ti apre la porta" (Beat 1, ingresso sessione). (6) Celebrazione speciale per promozione.
- **File da toccare**: mascotte_widget.dart (riscrittura), nuovo mascotte_painter.dart
- **Gate di uscita**: Forma organica renderizza, occhi espressivi, transizioni beat, animazione ingresso, analyze 0, test verdi

---

## Fase 10 — UX Redesign: Onboarding + Audio (Fase A.5, B39-B40)

> Riferimento: concept v1.1 sezioni 4, 11
> Primo contatto memorabile e sistema audio che da personalita.

### Blocco B39 — Onboarding con Momento Wow
- [ ] **Stato**: da fare
- **Complessita'**: alta
- **Descrizione**: Ristrutturare l'onboarding. (1) Momento wow (30-60s): l'app mostra una domanda curiosa e la risponde con una visualizzazione animata. Lo studente guarda, non interagisce. Widget nativo (CustomPainter o fl_chart). (2) Domande rapide: eta, cosa studi, perche sei qui. UI a scelta multipla, veloce. (3) Poi il flusso attuale (conversazione tutor + costruzione percorso). (4) Registrazione alla fine, non all'inizio. (5) La mascotte compare qui per la prima volta.
- **File da toccare**: onboarding_screen.dart (ristrutturazione), nuovi widget per momento wow, flow di registrazione posticipato
- **Gate di uscita**: Wow moment funziona, domande rapide, registrazione posticipata, flusso completo E2E, analyze 0, test verdi

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
