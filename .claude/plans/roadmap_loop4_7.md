# Piano Operativo Dydat — Loop 4-7 (B22-B37)

## Contesto

Loop 1-3 completati: architettura, SSE streaming, LaTeX, storico sessioni, celebrazioni esercizio. Ora completiamo il prodotto per studio completo di Algebra 1+2 con ripasso, verifica comprensione, e atmosfera coinvolgente.

**Stato attuale**: Backend 264 test (260 pass, 4 fail pre-esistenti), Frontend 199 test (195 pass, 4 fail pre-esistenti). `flutter analyze` 0 errori. Branch attivo: `feature/frontend-b19`.

---

## LOOP 4 — Quick Wins + Robustezza (B22-B25)

### B22 — Celebrazione Promozione Nodo + SSE Event

**Problema**: La promozione nodo (il reward piu grande) non emette SSE e non ha celebrazione. `turno.py` linee 197-209 processano la promozione ma fanno solo log.

**Backend** (autorizzazione cross-stack richiesta):
- `backend/app/core/turno.py` — Dopo linea 209, aggiungere:
  ```python
  yield _evento_sse("promozione", {
      "nodo_id": nodo_promosso,
      "nodo_nome": grafo_knowledge.grafo.nodes.get(nodo_promosso, {}).get("nome", nodo_promosso),
      "nuovo_livello": promo["nuovo_livello"],
      "nodi_sbloccati": promo.get("nodi_sbloccati", []),
  })
  ```

**Frontend**:
- `frontend/lib/models/sse_events.dart` — Nuova classe `PromozioneEvent extends SseEvent` (nodoId, nodoNome, nuovoLivello, nodiSbloccati)
- `frontend/lib/providers/session_provider.dart` — Aggiungere `latestPromotion: PromozioneEvent?` a `SessionScreenState` + `clearPromotion()` + case nel switch SSE
- `frontend/lib/providers/onboarding_provider.dart` — Aggiungere case `PromozioneEvent` (ignorato, per exhaustiveness)
- `frontend/lib/presentation/studio_screen/widgets/celebration_overlay.dart` — Nuova funzione `showPromotionCelebration()`:
  - Overlay full-screen con icona trofeo pulsante al centro
  - Nome nodo in headline + "Concetto completato!"
  - 40+ particelle (pioggia piu intensa dell'esercizio)
  - Durata 2500ms, `HapticFeedback.heavyImpact()` doppio
  - Auto-dismiss
- `frontend/lib/presentation/studio_screen/studio_screen.dart` — Rilevamento promozione in `_syncTutorMessages()` analogo a esito

**Test**: 2-3 test backend (emissione evento), 2-3 test frontend (parsing + provider state)

**Gate**: Evento SSE `promozione` emesso + celebrazione visibile + analyze 0 + test verdi

---

### B23 — SSE Reconnect + Resilienza Errori

**Problema**: Se lo stream SSE cade (cambio rete, timeout), la sessione si perde. Nessun retry.

**Frontend**:
- `frontend/lib/services/sse_client.dart` — Aggiungere:
  - `maxRetries: 2`, `retryDelay: Duration(seconds: 3)` al costruttore
  - Retry loop su `TimeoutException` e errori rete (non su 4xx)
  - Yield `ReconnectingEvent` durante i tentativi
  - Tracking `lastEventId` (future-proof)
  - `connectTimeout` separato da overall timeout
- `frontend/lib/models/sse_events.dart` — Nuova classe `ReconnectingEvent extends SseEvent`
- `frontend/lib/providers/session_provider.dart` — Aggiungere `isReconnecting: bool` a state + handle `ReconnectingEvent`
- `frontend/lib/presentation/studio_screen/studio_screen.dart` — Banner "Riconnessione in corso..." quando `isReconnecting == true`

**Test**: 3-4 test sse_client (retry su timeout, retry su network error, no retry su 4xx, max retries superati)

**Gate**: SSE reconnect funzionante + banner visibile + analyze 0 + test verdi

---

### B24 — Fix Test Backend + Pulizia Worktree

**Problema**: 4 test falliti in `TestCalcoloInattivita` (signature mismatch: `_calcola_inattivita` refactored da sync/1-arg a async/2-arg). Worktree `nostalgic-hertz` crea confusione Docker.

**Backend**:
- `backend/tests/test_sessione.py` — Riscrivere `TestCalcoloInattivita` (4 test) come async con mock DB:
  ```python
  @pytest.mark.asyncio
  async def test_sessione_recente(self):
      db = AsyncMock()
      # Mock query TurnoConversazione.created_at
      ...
  ```

**Frontend**: Investigare e fixare i 4 test pre-esistenti (3 theme_provider + 1 session_service mock)

**Cleanup**: `git worktree remove` di `nostalgic-hertz`

**Gate**: `pytest tests/` 0 failures + `flutter test` 0 failures + worktree rimosso

---

### B25 — Interfaccia MascotteWidget + Test E2E Loop 4

**Frontend**:
- `frontend/lib/presentation/studio_screen/widgets/mascotte_widget.dart` — Refactor con:
  ```dart
  enum MascotteState { idle, listening, thinking, celebrating, sleeping }
  ```
  - Accetta `mascotteState` parameter
  - AnimationController cambia comportamento per stato (velocita pulse, scala, opacita)
  - Visualmente resta il cerchio placeholder — solo le animazioni cambiano
- `frontend/lib/presentation/studio_screen/studio_screen.dart` — Computa `MascotteState` da session state:
  - `isStreaming` -> `thinking`
  - promozione/esito corretto recente -> `celebrating`
  - nessuna sessione -> `sleeping`
  - default -> `idle`

**E2E manuale Loop 4**:
1. Sessione -> promozione nodo -> celebrazione intensa (2.5s)
2. SSE drop -> "Riconnessione..." -> auto-recovery
3. Mascotte cambia stato durante streaming/celebrazione
4. Tutti i test backend e frontend passano (0 failures)

**Gate**: analyze 0 + test 0 failures + mascotte reattiva + E2E verificato

---

### Pipeline Loop 4

| Sessione | Blocco | Gate | Branch |
|----------|--------|------|--------|
| S18 | B22 | Promozione SSE + celebrazione | `feature/loop4-b22` |
| S19 | B23 | SSE reconnect + banner | `feature/loop4-b23` |
| S20 | B24 | 0 test failures + worktree rimosso | `feature/loop4-b24` |
| S21 | B25 | MascotteState + E2E Loop 4 | `feature/loop4-b25` |

---

## LOOP 5 — FSRS Spaced Repetition (B26-B29)

### B26 — Algoritmo FSRS (Backend)

**Infrastruttura esistente**: 6 campi DB pronti in `StatoNodoUtente` (sr_prossimo_ripasso, sr_intervallo_giorni, sr_facilita, sr_stabilita, sr_difficolta, sr_ripetizioni) + indice. Stub in `fsrs.py`. Direttiva `direttiva_ripasso_sr()` completa. Branch `attivita == "ripasso_sr"` GIA in `contesto.py` linee 389-394.

**Backend** (autorizzazione cross-stack):
- Installare libreria `fsrs` da PyPI nel Docker
- `backend/app/grafo/fsrs.py` — Sostituire stub con implementazione reale:
  - `calcola_prossimo_ripasso(db, utente_id, nodo_id, esito)` — Mappa esito a FSRS Rating (primo_tentativo->Easy, con_guida->Good, non_risolto->Again), calcola scheduling, ritorna dict con campi SR aggiornati
  - `get_nodi_da_ripassare(db, utente_id)` — Query `StatoNodoUtente WHERE sr_prossimo_ripasso <= now() AND livello >= operativo`
- `backend/app/core/elaborazione.py` — In `_processa_risposta_esercizio()`, dopo update contatori, chiamare `calcola_prossimo_ripasso()` per aggiornare campi SR (try/except, non-blocking)

**Test**: 8-10 test in nuovo `backend/tests/test_fsrs.py` (scheduling, query nodi scaduti, roundtrip campi)

**Gate**: FSRS implementato + campi SR aggiornati dopo esercizi + get_nodi_da_ripassare funziona + pytest verde

---

### B27 — Interleaving nelle Sessioni Normali (Backend)

**Backend**:
- `backend/app/core/sessione.py` — In `_scegli_nodo()`, aggiungere check interleaving PRIMA del path planner:
  - Se la sessione ha gia lavorato almeno 1 nodo normale E ci sono nodi SR scaduti -> probabilisticamente (1 ogni 2-3 nodi normali) scegliere un nodo di ripasso
  - Impostare `stato_orchestratore["attivita_corrente"] = "ripasso_sr"` e `concetti_scadenza`
- `backend/app/core/turno.py` — Nel tool override (linee 92-103), aggiungere check `tipo_sessione == "ripasso"` per filtrare tool appropriati

**Test**: 5-6 test (interleaving triggerato, interleaving non triggerato quando nessun nodo scaduto, contesto SR assemblato correttamente)

**Gate**: Sessioni normali interleaving SR + direttiva ripasso assemblata + pytest verde

---

### B28 — Sezione Ripasso Frontend + Badge "Da Ripassare"

**Backend** (autorizzazione cross-stack):
- Nuovo endpoint `GET /ripasso/nodi` — Ritorna lista nodi scaduti con nome e tema_id

**Frontend**:
- `frontend/lib/config/api_config.dart` — Aggiungere endpoint `/ripasso/nodi`
- Nuovo `frontend/lib/models/ripasso.dart` — Modello `NodoRipasso` (nodoId, nome, temaId)
- `frontend/lib/services/path_service.dart` — Aggiungere `getNodiDaRipassare()`
- `frontend/lib/providers/path_provider.dart` — Aggiungere `nodiDaRipassare` a state + `loadNodiRipasso()`
- `frontend/lib/presentation/learning_path_screen/widgets/tema_card_widget.dart` — Badge "Da ripassare" (punto ambra) se il tema ha nodi scaduti
- `frontend/lib/presentation/learning_path_screen/widgets/tema_detail_bottom_sheet.dart` — 4o stato nodo: `da_ripassare` con icona refresh e colore tertiary
- `frontend/lib/presentation/studio_screen/studio_screen.dart` — Nella home view, sezione "Ripasso" sopra storico sessioni se ci sono nodi scaduti: card con conteggio + bottone "Inizia ripasso"

**Test**: 3 test backend endpoint, 3 test frontend modello, 2 test provider

**Gate**: Badge visibili su learning path + sezione ripasso in home + API funziona + analyze 0 + test verdi

---

### B29 — Sessioni Ripasso Dedicate + Test E2E Loop 5

**Backend**:
- `backend/app/core/sessione.py` — In `inizia_sessione()`, quando `tipo == "ripasso"`:
  - Chiamare `get_nodi_da_ripassare()` invece di `_scegli_nodo()`
  - Impostare `stato_orchestratore["attivita_corrente"] = "ripasso_sr"` con `concetti_scadenza`

**Frontend**:
- `frontend/lib/services/session_service.dart` — `startStream()` accetta parametro `tipo` opzionale
- `frontend/lib/providers/session_provider.dart` — `startSessionStream()` accetta `tipo` e lo passa

**E2E manuale Loop 5**:
1. Completare esercizi -> nodo promosso -> campi SR popolati
2. Learning path mostra badge "Da ripassare" (simulare sr_prossimo_ripasso nel passato)
3. Home mostra sezione "Ripasso" con conteggio
4. Avviare sessione ripasso -> tutor fa verifica rapida
5. Sessione normale -> interleaving visibile (tutor propone ripasso intermezzato)

**Gate**: Sessioni ripasso E2E + interleaving visibile + badge + tutti test verdi

---

### Pipeline Loop 5

| Sessione | Blocco | Gate | Branch |
|----------|--------|------|--------|
| S22 | B26 | FSRS algoritmo + SR fields aggiornati | `feature/loop5-b26` |
| S23 | B27 | Interleaving + direttiva ripasso | `feature/loop5-b27` |
| S24 | B28 | Sezione ripasso + badge + API | `feature/loop5-b28` |
| S25 | B29 | Sessioni ripasso dedicate + E2E | `feature/loop5-b29` |

---

## LOOP 6 — Feynman + Comprensione Profonda (B30-B33)

### B30 — Feynman Signal Processing (Backend)

**Infrastruttura esistente**: Tool schema `avvia_feynman` (tools.py linee 184-203) e segnale `valutazione_feynman` (linee 501-526) COMPLETI. Direttiva `direttiva_feynman()` COMPLETA con 3 fasi (invito/ascolto/feedback). Branch `attivita == "feynman"` GIA in `contesto.py` linee 379-387. Campi DB: feynman_superato, feynman_data, esercizi_consecutivi_ok, ripasso_post_feynman_ok.

**Backend** (autorizzazione cross-stack):
- `backend/app/core/elaborazione.py` — Sostituire else branch (linee 231-233) con:
  - `_processa_valutazione_feynman(db, params, utente_id, sessione_id)` — Se esito=="positivo": feynman_superato=True, feynman_data=now. Se "parziale": log, tutor riprova. Se "insufficiente": log, tutor guida.
  - `esegui_azione()`: gestire `avvia_feynman` — impostare stato_orchestratore con attivita_corrente="feynman", fase_feynman="invito", punti_chiave
- `backend/app/llm/tools.py` — Rimuovere `[NON ANCORA ATTIVO]` da avvia_feynman e valutazione_feynman. Spostare avvia_feynman nei tool attivi.

**Test**: 6-8 test (valutazione positivo/parziale/insufficiente, avvia_feynman routing, stato_orchestratore aggiornato)

**Gate**: Feynman signal processing funziona + feynman_superato aggiornato + pytest verde

---

### B31 — Feynman Frontend Flow

**Frontend**:
- `frontend/lib/models/sse_events.dart` — Aggiungere `AvviaFeynmanAction` typed accessor su `AzioneEvent`:
  - `asAvviaFeynman` con nodoId, puntiChiave
- Nuovo `frontend/lib/presentation/studio_screen/widgets/feynman_card_widget.dart`:
  - Card inline nel chat: "Prova a spiegare [concetto] come se lo insegnassi a qualcuno"
  - Lista punti chiave come checklist guida
  - TextField multi-linea grande per la spiegazione
  - Bottone "Ho finito" che invia il testo come turno
  - Tono incoraggiante, bordo tertiary
- `frontend/lib/presentation/studio_screen/studio_screen.dart`:
  - In `_buildChatItem()`, case `type: 'feynman'` -> `FeynmanCardWidget`
  - In `_syncTutorMessages()`, riconoscere azione `avvia_feynman` e aggiungere a _messages

**Test**: 2-3 test parsing azione, widget test rendering

**Gate**: Card Feynman renderizza nel chat + studente puo inviare spiegazione + analyze 0 + test verdi

---

### B32 — Promozione Multi-Segnale: operativo -> comprensivo

**Backend**:
- `backend/app/core/elaborazione.py` — Nuova funzione `_verifica_promozione_comprensivo()`:
  ```
  operativo -> comprensivo QUANDO:
  1. feynman_superato = True
  2. esercizi_consecutivi_ok >= 3 (post-Feynman)
  3. sr_ripetizioni >= 2 (ripassato almeno 2 volte)
  ```
  - Chiamata da `_processa_risposta_esercizio()` quando livello == "operativo"
  - Chiamata anche da `_processa_valutazione_feynman()` quando esito == "positivo"

**Test**: 5-6 test (tutte 3 condizioni soddisfatte -> promozione, ciascuna condizione mancante -> no promozione)

**Gate**: Livello comprensivo raggiungibile + promozione multi-segnale funziona + pytest verde

---

### B33 — Feynman E2E + Loop 6 Polish

**Frontend**:
- Learning path: aggiungere stato `comprensivo` (5a icona/colore) nel bottom sheet
- `tema_detail_bottom_sheet.dart` — Aggiornare stati nodo per includere comprensivo

**E2E manuale Loop 6**:
1. Nodo a livello operativo -> tutor propone Feynman
2. Studente spiega -> tutor valuta (tono incoraggiante)
3. Valutazione positiva -> feynman_superato aggiornato
4. Dopo esercizi OK + SR stabile -> promozione a comprensivo
5. Learning path mostra livello comprensivo

**Gate**: Feynman E2E + comprensivo raggiungibile + learning path aggiornato + analyze 0 + test verdi

---

### Pipeline Loop 6

| Sessione | Blocco | Gate | Branch |
|----------|--------|------|--------|
| S26 | B30 | Feynman signal processing backend | `feature/loop6-b30` |
| S27 | B31 | Feynman card frontend | `feature/loop6-b31` |
| S28 | B32 | Multi-segnale promozione comprensivo | `feature/loop6-b32` |
| S29 | B33 | E2E Feynman + Loop 6 polish | `feature/loop6-b33` |

---

## LOOP 7 — Atmosfera + Polish (B34-B37)

### B34 — Canvas Beat-Aware

**Frontend**:
- `studio_screen.dart` — Aggiungere enum `_BeatState { focus, flow, review, celebrate, idle }`
- Computare beat da session state (isStreaming->flow, exercise visible->focus, ripasso->review, celebration->celebrate)
- Nuovo widget `_BeatOverlay` che wrappa il contenuto con `DecoratedBox`/`ShaderMask` animati:
  - `focus`: shimmer sottile su exercise card, sfondo leggermente dimmed
  - `flow`: shift gradiente piu caldo (molto sottile)
  - `review`: toni piu freddi, accento refresh
  - `celebrate`: glow dorato breve sullo scaffold
  - Cambiamenti SOTTILI (opacita 0.05-0.15) per non distrarre

**Gate**: Canvas cambia atmosfera per beat + nessun glitch visivo + analyze 0

---

### B35 — Tools Tray: Calcolatrice

**Frontend**:
- `frontend/lib/presentation/studio_screen/widgets/tools_tray_widget.dart` — Quando `calculator` selezionato, aprire bottom sheet
- Nuovo `frontend/lib/presentation/studio_screen/widgets/calculator_widget.dart`:
  - Calcolatrice scientifica base: +, -, *, /, parentesi, potenza, radice
  - Display con espressione e risultato
  - Bottone "Inserisci nel messaggio" che copia risultato nell'input chat
  - Dark-themed, matching app theme
- `frontend/pubspec.yaml` — Aggiungere `math_expressions` (o parser espressioni simile)

**Test**: Unit test evaluazione espressioni, widget test rendering

**Gate**: Calcolatrice funziona da tools tray + risultato inseribile in chat + analyze 0 + test verdi

---

### B36 — Celebrazioni Achievement Potenziate + Valutazione flutter_markdown

**Frontend**:
- `achievement_toast_widget.dart` — Per tipo `costellazione` (piu raro): overlay full-screen con animazione stelle, durata 6s
- Per tipo `medaglia`: toast attuale + shimmer dorato breve
- Per tipo `sigillo`: toast attuale (comune, non serve enhancement)
- Valutazione `flutter_markdown`: verificare se `flutter_markdown_plus` e sostituzione stabile. Documentare decisione.

**Gate**: Celebrazioni achievement differenziate per tipo + decisione markdown documentata + analyze 0

---

### B37 — Mascotte Placeholder Upgrade + Test E2E Loop 7

**Frontend**:
- `mascotte_widget.dart` — Sostituire icona statica `school` con icone per stato:
  - idle: `auto_awesome`, listening: `hearing`, thinking: `psychology`, celebrating: `celebration`, sleeping: `bedtime`
- Anello gradiente colorato intorno al cerchio che cambia per stato
- Speech bubble "tip" occasionale quando idle ("Ricorda di ripassare!")

**E2E manuale Loop 7**:
1. Atmosfera canvas cambia durante beat sessione
2. Calcolatrice funziona da tools tray
3. Achievement celebrazioni differenziate per tipo
4. Mascotte cambia icona/colore per stato
5. Flusso completo senza regressioni

**Gate**: analyze 0 + test verdi + E2E Loop 7 verificato

---

### Pipeline Loop 7

| Sessione | Blocco | Gate | Branch |
|----------|--------|------|--------|
| S30 | B34 | Beat-aware canvas | `feature/loop7-b34` |
| S31 | B35 | Calcolatrice tools tray | `feature/loop7-b35` |
| S32 | B36 | Achievement celebration + markdown eval | `feature/loop7-b36` |
| S33 | B37 | Mascotte upgrade + E2E Loop 7 | `feature/loop7-b37` |

---

## Riepilogo Roadmap B22-B37

| Loop | Blocchi | Focus | Sessioni | Effort |
|------|---------|-------|----------|--------|
| 4 | B22-B25 | Quick wins + robustezza | S18-S21 | ~4 sessioni |
| 5 | B26-B29 | FSRS Spaced Repetition | S22-S25 | ~4 sessioni |
| 6 | B30-B33 | Feynman + Comprensione | S26-S29 | ~4 sessioni |
| 7 | B34-B37 | Atmosfera + Polish | S30-S33 | ~4 sessioni |

**Totale: 16 blocchi in 16 sessioni**

## Dipendenze tra Loop

- Loop 4: nessuna dipendenza esterna
- Loop 5: dipende da B24 (fix test backend — serve baseline pulita prima di aggiungere test FSRS)
- Loop 6: dipende da B26 (algoritmo FSRS — promozione multi-segnale richiede dati SR)
- Loop 7: dipende da B25 (interfaccia MascotteState)

## Modifiche Backend Richieste (servono autorizzazione fondatore)

| Loop | Modifica | File |
|------|----------|------|
| 4 | Evento SSE `promozione` | `turno.py` |
| 5 | FSRS implementazione, `GET /ripasso/nodi`, interleaving, `pip install fsrs` | `fsrs.py`, `sessione.py`, `elaborazione.py`, nuovo `api/ripasso.py` |
| 6 | Feynman signal processing, avvia_feynman azione, promozione multi-segnale | `elaborazione.py`, `tools.py` |
| 7 | Nessuna | — |

## Risultato Finale

Dopo Loop 7, lo studente puo:
- Fare onboarding personalizzato con AI (gia fatto)
- Studiare concetti in ordine corretto (gia fatto)
- Fare esercizi con guida adattiva (gia fatto)
- Essere promosso con celebrazione gratificante (Loop 4)
- Ripassare a intervalli ottimali con interleaving (Loop 5)
- Dimostrare comprensione profonda con Feynman (Loop 6)
- Vivere un'esperienza immersiva con atmosfera dinamica (Loop 7)
