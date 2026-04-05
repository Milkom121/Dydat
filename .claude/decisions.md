# Log Decisioni Tecniche

| Data | Decisione | Motivazione | Alternative Scartate |
|------|-----------|-------------|---------------------|
| 2026-02-18 | Approccio chirurgico: tieni widget UI, ricostruisci architettura | Widget Rocket.new buoni esteticamente, manca tutto il resto | Riscrittura totale da zero |
| 2026-02-18 | Monorepo backend/ + frontend/ + docs/ | Tutto in un posto, struttura chiara | Repo separati per backend e frontend |
| 2026-02-18 | Rimossi 5 worktrees, tenuto solo nostalgic-hertz | 3 vuoti, 2 superseded dal backend completo | Tenerli tutti |
| 2026-02-18 | SSE come fase futura, non nel primo piano | Prima fondamenta (REST), poi streaming | SSE subito dall'inizio |
| 2026-02-18 | Sostituito sizer con sizer_extensions.dart custom | sizer ^2.0.15 incompatibile con Flutter 3.41 | Fork di sizer, MediaQuery diretto |
| 2026-02-18 | Rimossi web e universal_html | Non necessari, causavano conflitti | Tenerli per supporto web futuro |
| 2026-02-18 | Pipeline 6 sessioni da 1-2 blocchi | Contesto pulito, test dopo ogni sessione | Sessioni piu lunghe con piu blocchi |
| 2026-02-18 | Branch per sessione + PR verso main | Rollback facile, review before merge | Commit diretti su main |
| 2026-02-19 | Backend modificabile per feature cross-stack | B14-bis richiede tool LLM + prompt + filtering nel backend | Backend immutabile |
| 2026-02-19 | Docker SEMPRE da backend/, MAI dal worktree | Worktree nostalgic-hertz ha codice vecchio, causa mismatch | - |
| 2026-02-19 | Aggiunto flutter_markdown per rendering testo tutor | Raw **, - nel testo senza parsing markdown | Rendering custom, HTML WebView |
| 2026-02-19 | Onboarding esteso a 5 fasi (placement + piano) | Test diagnostico + piano studio personalizzato prima di completare onboarding | 3 fasi (accoglienza, conoscenza, conclusione) |
| 2026-02-19 | Transizioni signal-driven per fasi avanzate | LLM decide quando passare da placement a piano e da piano a conclusione | Timer o conteggio turni fisso |
| 2026-02-19 | Zero migrazioni DB per onboarding continuo | Tutto in stato_orchestratore JSONB, nessun schema change | Nuove colonne/tabelle |
| 2026-02-19 | Flag _handling409 per race condition 409 | onDone del SSE stream azzerava stato prima che il fallback REST completasse | Mutex, debounce |
| 2026-02-19 | FormulaCard mostra LaTeX raw — fix in Loop 3 | Rendering LaTeX richiede pacchetto dedicato, non fix cosmetico temporaneo | Fix immediato con regex |
| 2026-02-19 | Loop 2 completato — tutti i 6 blocchi B11-B16 | E2E manuale su emulatore: streaming, azioni, lifecycle, 409, recap verificati | - |
| 2026-02-19 | Loop 3 pianificato — 5 blocchi B17-B21 | LaTeX, storico sessioni, node progression, recap improvements, celebrazioni | - |
| 2026-02-19 | Mascotte deferita a Loop 4 | Mancano asset di design (SVG/Rive), il placeholder circolare resta | Implementare subito con placeholder |
| 2026-02-19 | Backend modifiche autorizzate per Loop 3 | GET /sessione/ (list) + esito_esercizio SSE event | - |
| 2026-02-19 | flutter_math_fork per LaTeX rendering | Rendering nativo Flutter, leggero | WebView (pesante), katex_flutter (meno mantenuto) |
| 2026-02-19 | LatexText widget per inline math | Parsa $...$ e $$...$$, fallback su MarkdownText per plain text, fallback monospace per LaTeX malformato | Un unico renderer per tutto |
| 2026-02-19 | Streaming bubble resta MarkdownText | Delimitatori $ possono arrivare split durante SSE streaming | Buffering completo prima di renderizzare |
| 2026-02-19 | SessionHistoryWidget nella home sotto "Inizia" | Mostra sessioni recenti con date relative, durata, stato — tap naviga a recap | Schermata separata per storico |
| 2026-02-19 | Tema completato nel recap con pathProvider.loadTopics() | Cross-reference nodiLavorati con temi completati — card celebrativa con trofeo | Query backend dedicata |
| 2026-02-19 | Auto-reload session history su ritorno alla home | StudioScreen rileva stato vuoto e ricarica in build() con Future.microtask | Pull-to-refresh manuale |
| 2026-02-19 | esito_esercizio SSE event nel backend | processa_segnali ritorna tupla (promozioni, esiti), turno.py emette evento | Segnale client-side senza backend |
| 2026-02-19 | EsitoEsercizioEvent sealed class nel frontend | Nuova variante con corretto, primoTentativo, conGuida | Map generico |
| 2026-02-19 | Celebration overlay (burst + glow) | showCelebrationOverlay() con particle burst per primo_tentativo, radial glow per con_guida | Snackbar semplice, vibrazione sola |
| 2026-02-19 | Haptic feedback differenziato per esito | heavyImpact per primo_tentativo, mediumImpact per con_guida | Haptic uniforme |
| 2026-02-19 | ExerciseCard colori hardcoded fixati | Color(0xFF7EBF8E) -> theme.colorScheme.secondary, Color(0xFFC97070) -> theme.colorScheme.error | Lasciare hardcoded |
| 2026-02-27 | Roadmap Loop 4-7 (B22-B37) pianificata | 16 blocchi in 16 sessioni — quick wins, FSRS, Feynman, atmosfera | Piano incrementale senza roadmap |
| 2026-02-27 | FSRS duale: interleaving + sezione ripasso | Fondatore vuole entrambi gli approcci per completezza pedagogica | Solo interleaving, solo sezione dedicata |
| 2026-02-27 | Feynman tono incoraggiante | Mai giudicante, "buona intuizione, prova ad approfondire..." | Tono neutro/valutativo |
| 2026-02-27 | Mascotte asset con AI generativa (track separato) | Midjourney/DALL-E per PNG, Flutter code per glow/transizioni | Designer umano, asset pack |
| 2026-02-27 | promozione SSE event nel backend | turno.py yield dopo ogni promozione con nodo_id, nodo_nome, nuovo_livello, nodi_sbloccati | Polling client |
| 2026-02-27 | PromozioneEvent sealed class nel frontend | Nuovo sottotipo SSE con 4 campi, registrato nel parser | Map generico |
| 2026-02-27 | showPromotionCelebration() celebrazione full-screen | 48 particelle, trofeo pulsante, 2500ms, doppio heavyImpact, nome nodo + nodi sbloccati | Toast semplice |
| 2026-02-27 | SSE retry con backoff esponenziale in SseClient | max 3 retry, 1s/2s/4s, retry su timeout/network/5xx, NO retry su 4xx | Retry fisso, nessun retry |
| 2026-02-27 | ReconnectingEvent generato client-side | Non e un evento backend — SseClient lo yield prima di ogni retry | Stato separato nel provider |
| 2026-02-27 | isReconnecting in SessionScreenState | Banner giallo "Riconnessione in corso..." nello studio_screen | Snackbar |
| 2026-02-27 | Snackbar errore fatale dopo retry esauriti | _lastShownError tracker evita duplicati | Dialog modale |
| 2026-02-27 | _calcola_inattivita async con DB query | Usa timestamp ultimo turno (non solo created_at) per calcolo inattivita | Calcolo sincrono approssimato |
| 2026-02-27 | ThemeNotifier initial state ThemeMode.dark | Dark-first design, test aggiornati di conseguenza | ThemeMode.system |
| 2026-02-27 | DioAdapter non supporta ResponseType.plain | JSON-encodes body, escapa newlines. Fix: Dio InterceptorsWrapper per test SSE plain text | Mock HTTP diretto |
| 2026-02-27 | Worktree nostalgic-hertz rimosso da git | git worktree prune — directory fisica locked, rimuovere manualmente | Tenerlo come riferimento |
| 2026-04-05 | Allineamento al Metodo Villa | Standardizzare gestione progetto cross-progetto, file piu snelli, runner automatico | Mantenere sistema custom |
| 2026-04-05 | Branch develop per commit autonomi | Piu velocita per Claude, Villa come gate su main | Autorizzazione esplicita per ogni commit |
| 2026-04-05 | Fase 4.5 Consolidamento prima di Loop 5 | Risolvere debito tecnico dall'audit prima di aggiungere feature | Procedere con Loop 5 e fixare dopo |
