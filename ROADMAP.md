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
- **Note**: Aggiunta colonna sr_card_json JSONB (migrazione 716b95629203) per serializzazione completa Card FSRS6. 21 nuovi test. 295 totale backend.

### Blocco B27 — Interleaving nelle Sessioni Normali (Backend)
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: In sessione.py _scegli_nodo(), aggiungere interleaving probabilistico (1 ogni 2-3 nodi normali) con nodi SR scaduti. Impostare attivita_corrente="ripasso_sr" in stato_orchestratore.
- **Gate di uscita**: Interleaving funzionante, direttiva ripasso assemblata, pytest verde

### Blocco B28 — Sezione Ripasso Frontend + Badge
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Nuovo endpoint GET /ripasso/nodi. Frontend: modello NodoRipasso, badge "Da ripassare" su tema_card, sezione ripasso in home con conteggio e bottone.
- **Gate di uscita**: Badge visibili, sezione ripasso in home, API funziona, analyze 0, test verdi

### Blocco B29 — Sessioni Ripasso Dedicate + E2E Loop 5
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Sessioni tipo "ripasso" con get_nodi_da_ripassare al posto di _scegli_nodo. E2E completo: esercizi -> promozione -> badge ripasso -> sessione ripasso -> interleaving.
- **Gate di uscita**: Sessioni ripasso E2E, interleaving visibile, badge, test verdi

---

## Fase 6 — Feynman + Comprensione Profonda (Loop 6, B30-B33)

### Blocco B30 — Feynman Signal Processing (Backend)
- [ ] **Stato**: da fare
- **Complessita'**: alta
- **Descrizione**: Attivare tool avvia_feynman e valutazione_feynman. Implementare _processa_valutazione_feynman() in elaborazione.py. Routing azione avvia_feynman.
- **Gate di uscita**: Feynman signal processing funziona, feynman_superato aggiornato, pytest verde

### Blocco B31 — Feynman Frontend Flow
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: FeynmanCardWidget inline nel chat: invito a spiegare, lista punti chiave, TextField multi-linea, bottone "Ho finito". Tono incoraggiante.
- **Gate di uscita**: Card Feynman renderizza, studente puo inviare spiegazione, analyze 0, test verdi

### Blocco B32 — Promozione Multi-Segnale: operativo -> comprensivo
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: _verifica_promozione_comprensivo(): feynman_superato + esercizi_consecutivi_ok >= 3 + sr_ripetizioni >= 2. Chiamata da _processa_risposta_esercizio e _processa_valutazione_feynman.
- **Gate di uscita**: Livello comprensivo raggiungibile, promozione multi-segnale funziona, pytest verde

### Blocco B33 — Feynman E2E + Loop 6 Polish
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Stato comprensivo nel learning path bottom sheet. E2E: nodo operativo -> Feynman -> valutazione -> esercizi OK -> promozione comprensivo.
- **Gate di uscita**: Feynman E2E, comprensivo raggiungibile, learning path aggiornato, analyze 0, test verdi

---

## Fase 7 — Atmosfera + Polish (Loop 7, B34-B37)

### Blocco B34 — Canvas Beat-Aware
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Enum BeatState (focus, flow, review, celebrate, idle). BeatOverlay con DecoratedBox/ShaderMask animati: cambi sottili di atmosfera (opacita 0.05-0.15).
- **Gate di uscita**: Canvas cambia atmosfera per beat, nessun glitch visivo, analyze 0

### Blocco B35 — Tools Tray: Calcolatrice
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Calcolatrice scientifica base in bottom sheet da tools tray. Bottone "Inserisci nel messaggio" per copiare risultato in chat.
- **Gate di uscita**: Calcolatrice funziona, risultato inseribile in chat, analyze 0, test verdi

### Blocco B36 — Celebrazioni Achievement Potenziate
- [ ] **Stato**: da fare
- **Complessita'**: bassa
- **Descrizione**: Overlay full-screen per tipo costellazione (6s, stelle). Shimmer dorato per medaglia. Valutazione flutter_markdown_plus.
- **Gate di uscita**: Celebrazioni differenziate per tipo, decisione markdown documentata, analyze 0

### Blocco B37 — Mascotte Placeholder Upgrade + E2E Loop 7
- [ ] **Stato**: da fare
- **Complessita'**: media
- **Descrizione**: Icone per stato mascotte (auto_awesome, hearing, psychology, celebration, bedtime). Anello gradiente colorato. E2E completo Loop 7.
- **Gate di uscita**: analyze 0, test verdi, E2E Loop 7 verificato

---

## Dipendenze tra Fasi

- Fase 4.5 (Consolidamento): nessuna dipendenza esterna
- Fase 5 (FSRS): dipende da Fase 4.5 completata (baseline pulita)
- Fase 6 (Feynman): dipende da B26 (algoritmo FSRS per promozione multi-segnale)
- Fase 7 (Atmosfera): dipende da B25 (MascotteState)

## Risultato Finale

Dopo Fase 7, lo studente puo: fare onboarding AI, studiare concetti in ordine, fare esercizi adattivi, essere promosso con celebrazioni, ripassare a intervalli FSRS, dimostrare comprensione con Feynman, vivere un'esperienza immersiva.
