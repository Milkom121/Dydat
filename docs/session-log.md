# Session Log — Metodo Villa Runner

> Log sintetico delle sessioni eseguite dal runner. Le sessioni S0-S21 sono pre-Metodo Villa (storico in docs/archive/status-loop1-4.md).

---

## 2026-04-09 — S55 B39.5.2 — Endpoint POST /stt/transcribe
- **Status**: CONTINUE
- **Summary**: Nuovo endpoint POST /stt/transcribe con OpenAI Whisper. Validazione formato audio (7 estensioni), limite 25 MB, lingua italiana. Gestione errori completa (400/422/429/502/503). Dipendenze: openai, python-multipart. 13 nuovi test. 568 backend verdi, 10 skipped.
---

## 2026-04-09 — Runner B39.2.3 — Funzione estrai_profilo con Opus
- **Status**: CONTINUE
- **Summary**: estrai_profilo() con chiamata Opus, parser JSON robusto, retry 1x, fallback profilo vuoto. chiama_llm_singolo() non-streaming. LLM_MODEL_ONBOARDING. 22 nuovi test. 470 backend verdi, 10 skipped.
---

## 2026-04-08 — Runner B39.2.2 — Schema Pydantic estrattore profilo
- **Status**: CONTINUE
- **Summary**: CampoConConfidenza (valore+confidenza con model_validator) e ProfiloEstratto (5 campi + helper campi_completi/mancanti/is_completo). 24 nuovi test. 448 backend verdi, 10 skipped.
---

## 2026-04-08 — Runner B39.1.2 — Modello SQLAlchemy Utente
- **Status**: CONTINUE
- **Summary**: Enum OnboardingStato (str, Enum) con 3 valori. Campi onboarding_stato e lingua_preferita nel modello Utente. Export in __init__.py. 9 nuovi test. 386 backend verdi, 10 skipped.
---

## 2026-04-08 — Sessione S50 — B36 Impostazione dimensione font in-app
- **Status**: PHASE_COMPLETE
- **Summary**: Provider Riverpod con persistenza SharedPreferences (4 opzioni: 0.85/1.0/1.15/1.3). MediaQuery wrapper in main.dart complementare al TextScaler di sistema. Helper LaTeX per flutter_math_fork. Sezione Aspetto in Profilo con anteprima live. FormulaCurriculumCard e EsempioInlineCard convertiti a ConsumerWidget. 8 nuovi test, 588 totale frontend, analyze 0. Fase 9 COMPLETATA.
---

## 2026-04-07 — Sessione S48 — B35.13 Audit accessibilita base (Semantics)
- **Status**: CONTINUE
- **Summary**: Rimosso TextScaler.linear(1.0) da main.dart. Semantics labels su 7 widget interattivi (LinearPathMap, GraphOverview, ToolsTray, Mascotte, TutorPanel, CollapsibleText). Tooltip su 5 IconButton chiudi. Fix contrasto celebration_overlay (alpha 0.7→0.87). dev-shortcuts aggiornato. 12 nuovi test, 564 totale frontend, analyze 0.
---

## 2026-04-06 — Sessione S35 — B38 Mascotte CustomPainter
- **Status**: PHASE_COMPLETE
- **Summary**: Mascotte evoluta da cerchio ambra a blob organico CustomPainter (Bezier 8 punti). Occhi espressivi con apertura, pupilla e riflesso. MascotteVisuals con lerp() per transizioni 500ms. EntrancePortalPainter (ingresso sessione). PromotionBurstPainter (celebrazione promozione). 28 nuovi test, 448 totale frontend, analyze 0. Fase 9 COMPLETATA (B36-B38).
---

## 2026-04-06 — Sessione S32 — B35 Quaderno per Nodo
- **Status**: PHASE_COMPLETE
- **Summary**: Backend GET /quaderno/{nodo_id} aggrega stato, esercizi, formule (deduplicate), spiegazioni (>50 char, markdown). Frontend: QuadernoNodo model (5 classi), QuadernoNotifier, NodoQuadernoScreen con 4 sub-widget (StatoHeader, FormuleSection LaTeX, EserciziSection badge esito, SpiegazioniSection expand/collapse). Route /quaderno/:nodoId fullscreen. NodeDetailBottomSheet navigazione tap->quaderno. 7 test backend + 22 test frontend nuovi. 330 backend + 379 frontend verdi, analyze 0. Fase 8 COMPLETATA.
---

## 2026-04-06 — Sessione S31 — B34 Percorso Unificato: Mappa + Zoom
- **Status**: CONTINUE
- **Summary**: LearningPathScreen riscritta da lista card a mappa visiva nodi. LinearPathMap, GraphOverview, NodeDetailBottomSheet, ricerca argomento. 14 nuovi test, 357 frontend verdi, analyze 0.
---

## 2026-04-06 — Preparazione Sessione S31 — Kickoff B34
- **Status**: READY
- **Summary**: Fase 7 chiusa con B33 (S30). Handoff, progress.json e session-log predisposti per Fase 8 B34 (Percorso Unificato: Mappa + Zoom). Test manuali B33 rimandati su richiesta di Villa; runner autorizzato a procedere su develop. Baseline: 341 backend + 343 frontend verdi, analyze 0.
---

## 2026-04-06 — Sessione S30 — B33 Transizione Sessione + Chiusura Narrativa
- **Status**: PHASE_COMPLETE
- **Summary**: StudioTransitionOverlay (1150ms, AnimationController Interval), SessionGoalPicker (Veloce/Normale/Approfondita + durata backend), narrativa tutor nel recap, notifica pausa obiettivo, CustomTransitionPage su route /studio. 47 nuovi test, 343 totale, analyze 0. Fase 7 COMPLETATA.
---

## 2026-04-05 — Allineamento Metodo Villa
- **Status**: CHECKPOINT
- **Summary**: Migrazione completa dei file di gestione al Metodo Villa. Creati PROJECT_CONFIG.md, ROADMAP.md (con fase 4.5 consolidamento), handoff.md, decisions.md, ideas.md, dev-shortcuts.md. Runner integrato. Branch develop creato.
---

## 2026-04-05 03:16:25 — Blocco F4.5B4.5.3
- **Status**: CONTINUE
- **Summary**: [DRY RUN]
---

## 2026-04-05 03:17:39 — Blocco F0B0
- **Status**: CONTINUE
- **Summary**: [DRY RUN]
---

## 2026-04-05 03:31:56 — Blocco F4.5B4.5.3
- **Status**: CONTINUE
- **Summary**: Blocco 4.5.3 completato (S22). iconMap reso static const in custom_icon_widget.dart. studio_screen.dart ridotto da 1207 a 480 righe con split in 6 nuovi file. Fase 4.5 COMPLETATA.
---

## 2026-04-05 03:44:21 — Blocco F5BB26
- **Status**: CONTINUE
- **Summary**: Blocco 4.5.3 completato (S22). iconMap reso static const in custom_icon_widget.dart. studio_screen.dart ridotto da 1207 a 480 righe con split in 6 nuovi file. Fase 4.5 COMPLETATA.
---

## 2026-04-05 03:48:25 — Blocco F5BB26
- **Status**: CONTINUE
- **Summary**: Blocco 4.5.3 completato (S22). iconMap reso static const in custom_icon_widget.dart. studio_screen.dart ridotto da 1207 a 480 righe con split in 6 nuovi file. Fase 4.5 COMPLETATA.
---

## 2026-04-05 03:56:08 — Blocco F5BB26
- **Status**: CONTINUE
- **Summary**: Blocco 4.5.3 completato (S22). iconMap reso static const in custom_icon_widget.dart. studio_screen.dart ridotto da 1207 a 480 righe con split in 6 nuovi file. Fase 4.5 COMPLETATA.
---

## 2026-04-05 04:01:13 — Blocco F5BB26
- **Status**: CONTINUE
- **Summary**: Blocco B27 completato (S24). Interleaving SR probabilistico implementato in _scegli_nodo() e aggiorna_nodo_dopo_promozione(). _NodoScelto NamedTuple, PROBABILITA_INTERLEAVING=0.35, direttiva ripasso assemblata tramite contesto.py.
---

## 2026-04-05 04:09:42 — Blocco F5BB26
- **Status**: CONTINUE
- **Summary**: Blocco B28 completato (S25). Endpoint GET /ripasso/nodi. NodoRipasso model + ripassoProvider. Badge SR su TemaCardWidget. Sezione ripasso in HomeViewWidget. 10 nuovi test frontend. 329 backend + 220 frontend verdi.
---

## 2026-04-05 04:11:26 — Blocco F5BB27
- **Status**: CONTINUE
- **Summary**: Blocco B28 completato (S25). Endpoint GET /ripasso/nodi. NodoRipasso model + ripassoProvider. Badge SR su TemaCardWidget. Sezione ripasso in HomeViewWidget. 10 nuovi test frontend. 329 backend + 220 frontend verdi.
---

## 2026-04-05 04:17:10 — Blocco F5BB28
- **Status**: PHASE_COMPLETE
- **Summary**: Blocco B29 completato (S26). Loop 5 FSRS completo. Sessioni ripasso dedicate: tipo=ripasso instrada su _scegli_nodo_ripasso() (100% SR, fallback path planner). Frontend: bottone Vai avvia sessione ripasso. 8 nuovi test backend + 4 widget test. 336 backend + 226 frontend verdi, analyze 0.
---

## 2026-04-05 04:22:06 — Blocco F5BB28
- **Status**: PHASE_COMPLETE
- **Summary**: Blocco B29 completato (S26). Loop 5 FSRS completo. Sessioni ripasso dedicate: _scegli_nodo_ripasso() con fallback path planner. Frontend: bottone Vai avvia sessione ripasso. 12 nuovi test backend + 8 nuovi frontend. 341 backend + 228 frontend verdi, analyze 0.
---

## 2026-04-06 03:49:27 — Blocco F6BB30
- **Status**: CONTINUE
- **Summary**: Fase 5 (FSRS) completata in S26. UX Redesign pianificato: concept document v1.1 approvato dal fondatore, ROADMAP aggiornata con Fasi 6-14 (Fase A UX in 6 sotto-fasi + Feynman + Visualizzazioni). Pronto per primo blocco implementativo.
---

## 2026-04-06 03:50:35 — Blocco F6BB30
- **Status**: CONTINUE
- **Summary**: Fase 5 (FSRS) completata in S26. UX Redesign pianificato: concept document v1.1 approvato dal fondatore, ROADMAP aggiornata con Fasi 6-14 (Fase A UX in 6 sotto-fasi + Feynman + Visualizzazioni). Pronto per primo blocco implementativo.
---

## 2026-04-06 03:59:23 — Blocco F6BB30
- **Status**: CONTINUE
- **Summary**: Fase 5 (FSRS) completata in S26. UX Redesign pianificato: concept document v1.1 approvato dal fondatore, ROADMAP aggiornata con Fasi 6-14 (Fase A UX in 6 sotto-fasi + Feynman + Visualizzazioni). Pronto per primo blocco implementativo.
---

## 2026-04-06 — Blocco F6BB31 (S28)
- **Status**: CONTINUE
- **Summary**: B31 — Home Calda con Ritorno Intelligente. 4 sub-widget estratti (WelcomeHeader, MiniPercorsoWidget, StreakCard, RipassoSection). statsProvider per streak reale. Mini-percorso visivo con cerchi/connessioni. Ripasso con chip nomi nodi. Saluto contestuale + gestione assenza >7 giorni. 274 frontend verdi, analyze 0.
---

## 2026-04-06 04:01:33 — Blocco F6BB30
- **Status**: CONTINUE
- **Summary**: Fase 5 (FSRS) completata in S26. UX Redesign pianificato: concept document v1.1 approvato dal fondatore, ROADMAP aggiornata con Fasi 6-14 (Fase A UX in 6 sotto-fasi + Feynman + Visualizzazioni). Pronto per primo blocco implementativo.
---

## 2026-04-06 — Sessioni S27-S28 (riepilogo)
- **Status**: CONTINUE
- **Summary**: B30 completato (S27) — Nuova navigazione 3 tab + Studio modale fullscreen. B31 completato (S28) — Home Calda con 4 sub-widget (WelcomeHeader, MiniPercorsoWidget, StreakCard, RipassoSection), 41 nuovi test. 274 frontend verdi, analyze 0.
---

## 2026-04-06 — S29 — Blocco B32
- **Status**: CONTINUE
- **Summary**: B32 completato (S29). Modello ibrido: FullscreenActionOverlay con slide-up+fade, CompactActionRecord nel feed, coda azioni in StudioScreen, ChatViewWidget ripulito dai widget inline. 22 nuovi test (296 totale). Flutter analyze 0.
---

## 2026-04-06 04:11:26 — Blocco F6BB30
- **Status**: CONTINUE
- **Summary**: B32 completato (S29). Modello ibrido implementato: esercizi/formule/backtrack escono dal feed in FullscreenActionOverlay (slide-up + fade). Record compatti nel feed post-azione. Coda fullscreen in StudioScreen. 22 nuovi test, 296 totale, analyze 0.
---

## 2026-04-06 04:11:56 — Blocco F6BB30
- **Status**: CONTINUE
- **Summary**: B32 completato (S29). Modello ibrido implementato: esercizi/formule/backtrack escono dal feed in FullscreenActionOverlay (slide-up + fade). Record compatti nel feed post-azione. Coda fullscreen in StudioScreen. 22 nuovi test, 296 totale, analyze 0.
---

## 2026-04-06 04:25:16 — Blocco F7BB33
- **Status**: CONTINUE
- **Summary**: B33 completato (S30). StudioTransitionOverlay (1150ms), SessionGoalPicker, recap narrativo tutor, notifica pausa obiettivo. 47 nuovi test, 343 totale, analyze 0.
---

## 2026-04-06 04:27:16 — Blocco F7BB33
- **Status**: PHASE_COMPLETE
- **Summary**: B33 completato (S30). StudioTransitionOverlay (1150ms), SessionGoalPicker, recap narrativo tutor, notifica pausa obiettivo. 47 nuovi test, 343 totale, analyze 0.
---

## 2026-04-06 17:31:28 — Blocco F8BB34
- **Status**: FAILED
- **Summary**: Errore o timeout
---

## 2026-04-06 17:38:15 — Blocco F8BB34
- **Status**: FAILED
- **Summary**: Errore o timeout
---

## 2026-04-06 19:12:41 — Blocco F8BB34
- **Status**: FAILED
- **Summary**: Errore o timeout
---

## 2026-04-06 — Nota: fallimenti F8BB34 precedenti
- **Status**: INFO
- **Summary**: I 3 tentativi falliti di F8BB34 (17:31, 17:38, 19:12) sono dovuti a token OAuth Claude Code scaduto (HTTP 401). Nessun codice toccato, develop pulito. Dopo rilogin, progress.json riportato a CONTINUE per permettere rilancio del runner su B34.
---

## 2026-04-06 19:29:21 — Blocco F8BB34
- **Status**: CONTINUE
- **Summary**: B34 completato (S31). Riscritta LearningPathScreen da lista card a mappa visiva nodi con vista lineare, zoom grafo, ricerca argomento e tap nodo con placeholder quaderno. 14 nuovi test, 357 totale frontend, analyze 0.
---

## 2026-04-06 19:46:35 — Blocco F8BB35
- **Status**: CONTINUE
- **Summary**: B34 completato (S31). Riscritta LearningPathScreen da lista card a mappa visiva nodi con vista lineare, zoom grafo, ricerca argomento e tap nodo con placeholder quaderno. 14 nuovi test, 357 totale frontend, analyze 0.
---

## 2026-04-06 20:02:57 — Blocco F8BB35
- **Status**: CONTINUE
- **Summary**: B36 completato (S33). Creato surface_decorations.dart con 6 metodi factory (backgroundGradient, card, glowCard, section, glowCircle, depthShadows). Token surfaceInteractive aggiunto al tema. Applicato gradienti, glow ambra e profondita a 4 schermate (Home, I miei studi, Profilo, Studio). Zero colori hardcoded. 10 nuovi test, 389 totale frontend, analyze 0.
---

## 2026-04-06 20:13:04 — Blocco F9BB37
- **Status**: CONTINUE
- **Summary**: B37 completato (S34). BeatState enum con 10 stati emotivi dalla mappa emotiva v2. BeatNotifier (Riverpod) calcola il beat corrente dalla sessione con priorita (promozione > esito > fullscreen > chiusura > attesa > streaming > accoglienza) e durate minime per beat transitori. BeatOverlayWidget renderizza gradiente radiale animato sotto il contenuto (opacita 0.03-0.15, mai invasivo). mascotteStateFromBeat() mappa beat->MascotteState secondo tabella direzione visiva. Studio screen integrato: overlay + mascotte reagisce ai beat. 31 nuovi test (3 file), 420 totale frontend, analyze 0.
---

## 2026-04-06 20:24:15 — Blocco F9BB38
- **Status**: PHASE_COMPLETE
- **Summary**: B38 completato (S35). Mascotte evoluta da cerchio ambra a forma organica con CustomPainter. MascottePainter: blob con 8 punti di controllo Bezier cubici, deformazione animata (wobble), gradiente radiale per profondita, glow luminescente esterno. Occhi espressivi: sclera ovale, pupilla con riflesso di luce, apertura controllata da eyeOpenness (linea quando quasi chiusi). MascotteVisuals con lerp() per transizioni smooth 500ms tra stati. EntrancePortalPainter per animazione ingresso sessione (3 cerchi concentrici sfalsati). PromotionBurstPainter per celebrazione promozione (12 raggi + cerchio espansione). Studio screen integrato con showEntrance e showPromotionBurst. 28 nuovi test (2 file), 448 totale frontend, analyze 0. Fase 9 (Atmosfera e Mascotte) COMPLETATA.
---

## 2026-04-06 — Test manuale Fasi 7-9 + kickoff B38.5
- **Status**: READY
- **Summary**: Test manuale eseguito da Villa su emulatore con utente creato da zero via onboarding reale. 7 scenari testati su 10 (4-5 sospesi per issue strategiche UX-01 "primo turno caldo" e UX-02 "quaderno enciclopedico"). Raccolti 7 bug UI cosmetici in .claude/test-findings.md. Handoff predisposto per B38.5 — fix chirurgico dei 7 bug prima di avanzare a Fase 10.
---

## 2026-04-07 00:56:11 — Blocco F9BB38.5
- **Status**: CONTINUE
- **Summary**: Fix chirurgico di 7 bug UI cosmetici emersi dal test manuale Fasi 7-9. Tutti i bug risolti, 11 nuovi test, 459 totale frontend verdi, analyze 0.
---

## 2026-04-07 — Predisposizione nottata: B35.5 + B35.6
- **Status**: READY
- **Summary**: Discussione strategica con Villa post test manuale. Decisi due blocchi consecutivi: B35.5 Quaderno Enciclopedico (riscrittura schermata con scheda intrinseca + log personale + note utente editabili) e B35.6 Polish empty states (bonus). Spec concordata con Villa, handoff dettagliato pronto. Issue UX-01 (primo turno caldo del tutor) rimandata a sessione futura.
---

## 2026-04-07 — Ricalibrazione granularita: B35.5 spezzato in 5 sub-blocchi
- **Status**: READY
- **Summary**: Cambio metodologico chiesto da Villa. B35.5 monolitico spezzato in 5 sub-blocchi piccoli (B35.5.1-B35.5.5) per consentire al runner di lavorare con context ridotto (max meta del modello). Aggiunto --model opus al runner. Nottata pianificata per 6 blocchi consecutivi (5 sub + B35.6). Notifiche Telegram attive su ogni blocco completato.
---

## 2026-04-07 — Espansione nottata: 13 blocchi totali
- **Status**: READY
- **Summary**: Villa ha chiesto di riempire meglio la nottata. Aggiunti 7 sub-blocchi extra di polish/UX a basso rischio: B35.7 pull-to-refresh, B35.8 snackbar errori user-friendly, B35.9 loading skeleton, B35.10 search mappa con parole_chiave, B35.11 coerenza tono di voce italiana, B35.12 audit dev-shortcuts priorita alta, B35.13 audit accessibilita base. Totale 13 blocchi consecutivi per la nottata, ~5-7 ore di lavoro stimate.
---

## 2026-04-07 02:27:27 — Blocco F9BB35.5.1
- **Status**: CONTINUE
- **Summary**: B35.5.1 completato. GET /quaderno/{nodo_id} esteso con scheda intrinseca (definizione_testo, formule, esempi, errori_comuni, parole_chiave da JSONB nodi) + nota_utente (testo + updated_at da tabella note_utente). 3 nuovi test, 7 aggiornati.
---

## 2026-04-07 02:31:27 — Blocco F9BB35.5.2
- **Status**: CONTINUE
- **Summary**: B35.5.2 completato. Nuovo endpoint PUT /quaderno/{nodo_id}/nota con upsert (SELECT + UPDATE/INSERT). Validazione Pydantic NotaUtenteRequest (min 1, max 10000 char). 5 nuovi test. 356 backend verdi, 10 skipped, ruff pulito.
---

## 2026-04-07 03:00:00 — Blocco F9BB35.5.3
- **Status**: CONTINUE
- **Summary**: B35.5.3 completato. 4 nuovi modelli Dart (FormulaCurriculum, ErroreComune, SchedaNodo, NotaUtente) + QuadernoNodo esteso con scheda/notaUtente/copyWith. QuadernoState con isSaving. PathService.saveNotaUtente(). QuadernoNotifier.saveNota(). 15 nuovi test. 474 frontend verdi, analyze 0.
---

## 2026-04-07 02:39:27 — Blocco F9BB35.5.3
- **Status**: CONTINUE
- **Summary**: B35.5.3 completato. 4 nuovi modelli Dart (FormulaCurriculum, ErroreComune, SchedaNodo, NotaUtente) + QuadernoNodo esteso con scheda/notaUtente/copyWith. QuadernoState con isSaving. PathService.saveNotaUtente() PUT. QuadernoNotifier.saveNota(). 15 nuovi test. 474 frontend verdi, analyze 0.
---

## 2026-04-07 02:46:11 — Blocco F9BB35.5.4
- **Status**: CONTINUE
- **Summary**: B35.5.3 completato. 4 nuovi modelli Dart (FormulaCurriculum, ErroreComune, SchedaNodo, NotaUtente) + QuadernoNodo esteso con scheda/notaUtente/copyWith. QuadernoState con isSaving. PathService.saveNotaUtente() PUT. QuadernoNotifier.saveNota(). 15 nuovi test. 474 frontend verdi, analyze 0.
---

## 2026-04-07 02:53:42 — Blocco F9BB35.5.4
- **Status**: CONTINUE
- **Summary**: B35.5.5 completato. Riscrittura NodoQuadernoScreen con layout 10 sezioni integrando widget B35.5.3/4. Fix lint B35.5.4. 11 nuovi test integrazione. 500 frontend verdi, analyze 0.
---

## 2026-04-07 03:15:00 — Blocco F9BB35.6
- **Status**: CONTINUE
- **Summary**: B35.6 completato. Audit + fix empty states in 4 schermate: EmptyStateWidget (rimosso URL Unsplash), SessionHistoryWidget (messaggio storico vuoto), ProfileScreen (achievement + stats utente nuovo). 6 nuovi widget test. 506 frontend verdi, analyze 0.
---

## 2026-04-07 03:00:57 — Blocco F9BB35.5.5
- **Status**: CONTINUE
- **Summary**: B35.6 completato. Audit + fix empty states in 4 schermate: EmptyStateWidget (rimosso URL Unsplash), SessionHistoryWidget (messaggio storico vuoto), ProfileScreen (achievement + stats utente nuovo). 6 nuovi widget test. 506 frontend verdi, analyze 0.
---

## 2026-04-07 03:07:44 — Blocco F9BB35.6
- **Status**: CONTINUE
- **Summary**: B35.6 completato. Audit + fix empty states in 4 schermate: EmptyStateWidget (rimosso URL Unsplash), SessionHistoryWidget (messaggio storico vuoto), ProfileScreen (achievement + stats utente nuovo). 6 nuovi widget test. 506 frontend verdi, analyze 0.
---

## 2026-04-07 03:16:40 — Blocco F9BB35.6
- **Status**: CONTINUE
- **Summary**: B35.8 completato. Helper centralizzato userFriendlyError() per convertire errori tecnici in messaggi italiani user-friendly. Applicato in 7 punti (widget + provider). Fix leak in SSE client. Riscritto custom_error_widget.dart in italiano. 20 nuovi test. 530 frontend verdi, analyze 0.
---

## 2026-04-07 03:24:32 — Blocco F9BB35.8
- **Status**: CONTINUE
- **Summary**: B35.8 completato. Helper centralizzato userFriendlyError() per convertire errori tecnici in messaggi italiani user-friendly. Applicato in 7 punti (widget + provider). Fix leak in SSE client. Riscritto custom_error_widget.dart in italiano. 20 nuovi test. 530 frontend verdi, analyze 0.
---

## 2026-04-07 — Blocco F9BB35.10
- **Status**: CONTINUE
- **Summary**: B35.10 completato. Search mappa percorso estesa alle parole_chiave dei nodi. Backend: aggiunto parole_chiave a GET /percorsi/{id}/mappa. Frontend: NodoMappa con paroleChiave, ricerca estesa. 11 nuovi test. 552 frontend verdi, analyze 0.
---

## 2026-04-07 03:31:22 — Blocco F9BB35.8
- **Status**: CONTINUE
- **Summary**: B35.10 completato. Search mappa percorso estesa alle parole_chiave dei nodi. Backend: aggiunto campo parole_chiave alla response GET /percorsi/{id}/mappa. Frontend: NodoMappa con paroleChiave, ricerca estesa nome+keyword in LearningPathScreen. 11 nuovi test. 552 frontend verdi, analyze 0.
---

## 2026-04-07 05:00:00 — Blocco B35.12
- **Status**: CONTINUE
- **Summary**: B35.12 completato. Risolte 3 voci alta priorita dev-shortcuts: validate_secrets_for_startup() per JWT_SECRET e ANTHROPIC_API_KEY, credenziali PostgreSQL spostate a .env, creato .env.example. 7 nuovi test backend. 363 backend, 552 frontend verdi, analyze 0.
---

## 2026-04-07 04:00:00 — Blocco B35.11
- **Status**: CONTINUE
- **Summary**: B35.11 completato. Audit testi UI italiani. 3 fix: Streak>Serie (profilo+recap), Achievement>Traguardi. Creato docs/tone-of-voice.md. 552 frontend verdi, analyze 0.
---

## 2026-04-07 03:37:28 — Blocco F9BB35.10
- **Status**: CONTINUE
- **Summary**: B35.11 completato. Audit testi UI italiani su 119 file Dart. 3 fix applicati: 'Streak' > 'Serie' (profilo + recap), 'Achievement' > 'Traguardi' (profilo). Creato docs/tone-of-voice.md con terminologia standard e regole tono. 552 frontend verdi, analyze 0.
---

## 2026-04-07 03:45:00 — Blocco F9BB35.11
- **Status**: CONTINUE
- **Summary**: B35.11 completato. Audit testi UI italiani su 119 file Dart. 3 fix applicati: 'Streak' > 'Serie' (profilo + recap), 'Achievement' > 'Traguardi' (profilo). Creato docs/tone-of-voice.md con terminologia standard e regole tono. 552 frontend verdi, analyze 0.
---

## 2026-04-07 03:54:58 — Blocco F9BB35.13
- **Status**: CONTINUE (limite 13 blocchi raggiunto)
- **Summary**: B35.13 completato. Audit accessibilita base: rimosso TextScaler.linear(1.0) da main.dart, aggiunto Semantics labels su 7 widget interattivi, tooltip su 5 IconButton chiudi, fix contrasto celebration_overlay. 12 nuovi test. 564 frontend verdi, analyze 0.
---

## 2026-04-07 — NOTTATA COMPLETATA
- **Status**: SUCCESS
- **Summary**: Tutti i 13 blocchi pianificati eseguiti in 92 minuti totali. B35.5.1-B35.5.5 (Quaderno enciclopedico) + B35.6 (polish empty states) + B35.7-B35.13 (polish UX vari). Frontend: 459 → 564 test verdi (+105). Backend: 341 → 363 test verdi (+22). flutter analyze 0. Tutti i commit su branch wip/notte-quaderno-polish-2026-04-07. Pronti per review e merge su develop.
---

## 2026-04-07 22:34:44 — Blocco F9BB35.14
- **Status**: PHASE_COMPLETE
- **Summary**: Fix chirurgico 7 bug UI post test manuale nottata. NB-01: FittedBox su FormulaCurriculumCard (formule LaTeX non sbordano piu). NB-02: nuovo EsempioInlineCard con rendering LaTeX intelligente (Math.tex + fallback Text). NB-03: nuovo pluralize.dart con 5 funzioni singolare/plurale, applicato in stato_header e welcome_header. NB-04: separator log personale sempre visibile + empty state gentile quando nessun log. NB-05: verificato che userFriendlyError era gia presente (nessun fix necessario). NB-06: icona nodi non iniziati da lock_outline a circle_outlined. NB-07: rimosso SizedBox(height:80) fisso in MiniPercorsoWidget + FittedBox su nomi nodo per TextScaler aumentato.
---

## 2026-04-08 00:50:42 — Blocco F9BB36
- **Status**: CONTINUE
- **Summary**: Aggiunge un'impostazione utente per scalare la dimensione dei font dell'app indipendentemente dal TextScaler di sistema. Provider Riverpod con persistenza, sezione Aspetto in Profilo, helper LaTeX coordinato. Branch dedicato wip/B36-font-scale.
---

## 2026-04-08 00:52:43 — Blocco F9BB36
- **Status**: CONTINUE
- **Summary**: Aggiunge un'impostazione utente per scalare la dimensione dei font dell'app indipendentemente dal TextScaler di sistema. Provider Riverpod con persistenza, sezione Aspetto in Profilo, helper LaTeX coordinato. Branch dedicato wip/B36-font-scale.
---

## 2026-04-08 00:54:37 — Blocco F9BB36
- **Status**: CONTINUE
- **Summary**: Aggiunge un'impostazione utente per scalare la dimensione dei font dell'app indipendentemente dal TextScaler di sistema. Provider Riverpod con persistenza, sezione Aspetto in Profilo, helper LaTeX coordinato. Branch dedicato wip/B36-font-scale.
---

## 2026-04-08 04:43:40 — Blocco F9BB33.5
- **Status**: PHASE_COMPLETE
- **Summary**: Catena notturna completata. B33.5 implementato (primo turno caldo del tutor). Blocco fix-bug-cosmetici skippato: tutti e 5 i bug (BUG-01/02/03/05/07) erano gia stati fixati nel blocco B38.5 (S36). Codice verificato: i fix sono tutti presenti nei file sorgente.
---

## 2026-04-08 23:39:25 — Blocco F10BB39.1.1
- **Status**: CONTINUE
- **Summary**: B39.1.1 completato — Migrazione Alembic a1b2c3d4e5f6 per onboarding_stato (enum not_started/in_progress/completed) e lingua_preferita (varchar 10, default it) sulla tabella utenti. Upgrade, downgrade e re-upgrade verificati via psql. 377 test backend verdi, 10 skipped.
---

## 2026-04-08 23:44:07 — Blocco F10BB39.1.2
- **Status**: CONTINUE
- **Summary**: B39.1.2 completato — Aggiunto enum OnboardingStato (str, Enum) con 3 valori (not_started, in_progress, completed) al modello SQLAlchemy Utente. Campo lingua_preferita String(10) con default 'it'. Entrambi NOT NULL con server_default. Export in __init__.py. 9 nuovi test.
---

## 2026-04-08 23:47:03 — Blocco F10BB39.1.3
- **Status**: CONTINUE
- **Summary**: B39.1.2 completato — Aggiunto enum OnboardingStato (str, Enum) con 3 valori (not_started, in_progress, completed) al modello SQLAlchemy Utente. Campo lingua_preferita String(10) con default 'it'. Entrambi NOT NULL con server_default. Export in __init__.py. 9 nuovi test.
---

## 2026-04-08 23:48:32 — Blocco F10BB39.1.3
- **Status**: CONTINUE
- **Summary**: B39.1.2 completato — Aggiunto enum OnboardingStato (str, Enum) con 3 valori (not_started, in_progress, completed) al modello SQLAlchemy Utente. Campo lingua_preferita String(10) con default 'it'. Entrambi NOT NULL con server_default. Export in __init__.py. 9 nuovi test.
---

## 2026-04-08 23:52:20 — Blocco F10BB39.1.3
- **Status**: CONTINUE
- **Summary**: B39.1.3 completato — Schema Pydantic UtenteResponse già aggiornato in B39.1.2 con campi onboarding_stato (str, default "not_started") e lingua_preferita (str, default "it"). Scritti 9 test di contract: presenza campi, default, serializzazione da dict/enum/mock ORM, model_dump JSON, from_attributes.
---

## 2026-04-08 23:56:22 — Blocco F10BB39.1.3
- **Status**: CONTINUE
- **Summary**: B39.2.1 completato - Prompt estrattore profilo onboarding scritto in onboarding_extractor.py. Il prompt istruisce Opus a estrarre 5 campi (chi_e, motivo, stile_cognitivo, tempo_disponibile, vissuto_scolastico) con confidenze (alta/media/bassa) dalla conversazione onboarding. Output JSON rigido con 2 esempi few-shot (completo e parziale). Costanti CAMPI_PROFILO e CONFIDENZE_VALIDE esportate per riuso dal decisore forma C.
---

## 2026-04-09 00:00:16 — Blocco F10BB39.2.1
- **Status**: CONTINUE
- **Summary**: B39.2.1 completato - Prompt estrattore profilo onboarding scritto in onboarding_extractor.py. Il prompt istruisce Opus a estrarre 5 campi (chi_e, motivo, stile_cognitivo, tempo_disponibile, vissuto_scolastico) con confidenze (alta/media/bassa) dalla conversazione onboarding. Output JSON rigido con 2 esempi few-shot (completo e parziale). Costanti CAMPI_PROFILO e CONFIDENZE_VALIDE esportate per riuso dal decisore forma C.
---

## 2026-04-09 00:06:43 — Blocco F10BB39.2.1
- **Status**: CONTINUE
- **Summary**: B39.2.1 completato - Prompt estrattore profilo onboarding scritto in onboarding_extractor.py. Il prompt istruisce Opus a estrarre 5 campi (chi_e, motivo, stile_cognitivo, tempo_disponibile, vissuto_scolastico) con confidenze (alta/media/bassa) dalla conversazione onboarding. Output JSON rigido con 2 esempi few-shot (completo e parziale). Costanti CAMPI_PROFILO e CONFIDENZE_VALIDE esportate per riuso dal decisore forma C.
---

## 2026-04-09 00:57:55 — Blocco F10BB39.2.4
- **Status**: CONTINUE
- **Summary**: B39.2.3 completato — Funzione estrai_profilo con chiamata Opus e retry (ca67488). Prossimo: B39.2.4, unit test integrazione estrattore. Catena B39 Onboarding Narrativo in corso, 6 sub-blocchi su 38 completati (B39.1.1, B39.1.2, B39.1.3, B39.2.1, B39.2.2, B39.2.3). Handoff ripristinato dopo stop manuale del runner per patch al meccanismo di commit stato.
---

## 2026-04-09 00:59:32 — Blocco F10BB39.2.4
- **Status**: CONTINUE
- **Summary**: B39.2.3 completato — Funzione estrai_profilo con chiamata Opus e retry (ca67488). Prossimo: B39.2.4, unit test integrazione estrattore. Catena B39 Onboarding Narrativo in corso, 6 sub-blocchi su 38 completati (B39.1.1, B39.1.2, B39.1.3, B39.2.1, B39.2.2, B39.2.3). Handoff ripristinato dopo stop manuale del runner per patch al meccanismo di commit stato.
---

## 2026-04-09 01:03:08 — Blocco F10BB39.2.4
- **Status**: CONTINUE
- **Summary**: B39.2.3 completato — Funzione estrai_profilo con chiamata Opus e retry (ca67488). Prossimo: B39.2.4, unit test integrazione estrattore. Catena B39 Onboarding Narrativo in corso, 6 sub-blocchi su 38 completati (B39.1.1, B39.1.2, B39.1.3, B39.2.1, B39.2.2, B39.2.3). Handoff ripristinato dopo stop manuale del runner per patch al meccanismo di commit stato.
---

## 2026-04-09 01:04:52 — Blocco F10BB39.2.4
- **Status**: CONTINUE
- **Summary**: B39.2.3 completato — Funzione estrai_profilo con chiamata Opus e retry (ca67488). Prossimo: B39.2.4, unit test integrazione estrattore. Catena B39 Onboarding Narrativo in corso, 6 sub-blocchi su 38 completati (B39.1.1, B39.1.2, B39.1.3, B39.2.1, B39.2.2, B39.2.3). Handoff ripristinato dopo stop manuale del runner per patch al meccanismo di commit stato.
---

## 2026-04-09 01:18:48 — Blocco F10BB39.3.1
- **Status**: CONTINUE
- **Summary**: B39.2.4 completato — Unit test integrazione estrattore profilo con 18 nuovi test su 7 scenari realistici (utente collaborativo 5/5 campi, utente parziale 2/5, off-topic, conversazione minimale, fallimento LLM con retry, confidenze miste, conversazione lunga). 488 test backend verdi, 10 skipped. Fase 2 chiusa al 100%.
---

## 2026-04-09 01:20:32 — Blocco F10BB39.3.1
- **Status**: CONTINUE
- **Summary**: B39.2.4 completato — Unit test integrazione estrattore profilo con 18 nuovi test su 7 scenari realistici (utente collaborativo 5/5 campi, utente parziale 2/5, off-topic, conversazione minimale, fallimento LLM con retry, confidenze miste, conversazione lunga). 488 test backend verdi, 10 skipped. Fase 2 chiusa al 100%.
---

## 2026-04-09 01:46:26 — Blocco F10BB39.3.2
- **Status**: CONTINUE
- **Summary**: B39.3.2 completato - Integrazione decisore nell'endpoint /onboarding/turno. Dopo ogni turno utente in fase conoscenza, l'estrattore Opus aggiorna il profilo e il decisore rules-based decide la prossima mossa. Evento SSE decisione_onboarding emesso. 13 nuovi test, 2 aggiornati. 524 backend verdi, 10 skipped.
---

## 2026-04-09 01:52:17 — Blocco F10BB39.4.1
- **Status**: CONTINUE
- **Summary**: B39.4.1 completato - Fix completa_onboarding scrittura profilo (ONB-01). La funzione ora legge profilo_estratto dallo stato_orchestratore, costruisce profilo_sintetizzato (dict piatto con valori), contesto_personale (chi_e/motivo/vissuto_scolastico) e preferenze_tutor (stile_cognitivo/tempo_disponibile). Parametri payload hanno priorita'. onboarding_stato aggiornato a COMPLETED. 16 nuovi test. 540 backend verdi, 10 skipped.
---

## 2026-04-09 02:04:33 — Blocco F10BB39.4.2
- **Status**: CONTINUE
- **Summary**: B39.4.1 completato - Fix completa_onboarding scrittura profilo (ONB-01). La funzione ora legge profilo_estratto dallo stato_orchestratore, costruisce profilo_sintetizzato (dict piatto con valori), contesto_personale (chi_e/motivo/vissuto_scolastico) e preferenze_tutor (stile_cognitivo/tempo_disponibile). Parametri payload hanno priorita'. onboarding_stato aggiornato a COMPLETED. 16 nuovi test. 540 backend verdi, 10 skipped.
---

## 2026-04-09 02:11:48 — Blocco F10BB39.4.2
- **Status**: CONTINUE
- **Summary**: B39.4.1 completato - Fix completa_onboarding scrittura profilo (ONB-01). La funzione ora legge profilo_estratto dallo stato_orchestratore, costruisce profilo_sintetizzato (dict piatto con valori), contesto_personale (chi_e/motivo/vissuto_scolastico) e preferenze_tutor (stile_cognitivo/tempo_disponibile). Parametri payload hanno priorita'. onboarding_stato aggiornato a COMPLETED. 16 nuovi test. 540 backend verdi, 10 skipped.
---

## 2026-04-09 03:06:40 — Blocco F10BB39.5.1
- **Status**: CONTINUE
- **Summary**: B39.4.3 completato - Pulizia codice onboarding legacy. Rimosso TURNI_CONOSCENZA_MAX (non piu usato, il decisore forma C usa TETTO_TURNI_NARRATIVI). Rimosso AzioneDecisore.passa_a_placement (mai generato dal decisore). Aggiornate docstring modulo e aggiorna_fase_onboarding per riflettere il flusso attuale. 540 backend verdi, 10 skipped. Fase 4 chiusa al 100%.
---
