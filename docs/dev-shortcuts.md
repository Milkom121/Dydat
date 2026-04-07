# Scorciatoie di Sviluppo

Registro delle scorciatoie prese durante lo sviluppo da risolvere prima della produzione.

## ~~2026-04-05 - JWT_SECRET con valore di default debole~~ RISOLTO (2026-04-07, B35.12)
- **File**: backend/app/config.py
- **Riga**: ~22
- **Tipo**: credenziale-hardcoded
- **Dettaglio**: `JWT_SECRET: str = "change-me-in-production"` — se .env manca o non configura la variabile, l'app parte con un secret indovinabile. Chiunque potrebbe forgiare token JWT validi.
- **Priorità di risoluzione**: ~~alta (sicurezza)~~ risolto
- **Risoluzione**: `validate_secrets_for_startup()` in config.py, chiamata dalla lifespan di main.py. In DEBUG emette warning, in produzione blocca l'avvio.

## ~~2026-04-05 - ANTHROPIC_API_KEY con default vuoto~~ RISOLTO (2026-04-07, B35.12)
- **File**: backend/app/config.py
- **Riga**: ~9
- **Tipo**: credenziale-hardcoded
- **Dettaglio**: `ANTHROPIC_API_KEY: str = ""` — default stringa vuota. Se non configurata, le chiamate LLM falliscono silenziosamente in runtime invece di bloccare l'avvio.
- **Priorità di risoluzione**: ~~alta (sicurezza)~~ risolto
- **Risoluzione**: `validate_secrets_for_startup()` in config.py. In DEBUG emette warning, in produzione blocca l'avvio.

## ~~2026-04-05 - Credenziali PostgreSQL nel docker-compose.yml~~ RISOLTO (2026-04-07, B35.12)
- **File**: backend/docker-compose.yml
- **Riga**: ~5-7
- **Tipo**: credenziale-hardcoded
- **Dettaglio**: `POSTGRES_USER: dydat` e `POSTGRES_PASSWORD: dydat_secret` hardcoded nel file tracciato da git. Chiunque legga il repo conosce le credenziali DB.
- **Priorità di risoluzione**: ~~alta (sicurezza)~~ risolto
- **Risoluzione**: Interpolazione `${VAR:-default}` da .env in docker-compose.yml. Creato .env.example con segnaposto. I default rimangono come fallback per dev locale.

## 2026-04-05 - CORS non configurato
- **File**: backend/app/main.py
- **Riga**: (mancante)
- **Tipo**: cors-permissivo
- **Dettaglio**: Nessun middleware CORS aggiunto. Se il frontend fosse servito da un'origine diversa (es. web), le richieste verrebbero bloccate dal browser. Per ora non impatta l'app mobile Flutter, ma blocca qualsiasi client web futuro.
- **Priorità di risoluzione**: media (funzionalita)

## 2026-04-05 - Dockerfile con --reload in produzione
- **File**: backend/Dockerfile
- **Riga**: ~20
- **Tipo**: altro
- **Dettaglio**: `CMD ["uvicorn", ..., "--reload"]` — il flag --reload e pensato per sviluppo (auto-restart su cambio file). In produzione spreca CPU e rallenta l'avvio. Servono due CMD o un entrypoint condizionale.
- **Priorità di risoluzione**: media (funzionalita)

## 2026-04-05 - Exception silenziose in turno.py
- **File**: backend/app/core/turno.py
- **Riga**: ~275-294
- **Tipo**: altro
- **Dettaglio**: Due blocchi `except Exception: pass` su aggiornamento statistiche e verifica achievement. Se qualcosa va storto, l'errore viene ingoiato senza log — impossibile diagnosticare problemi in produzione.
- **Priorità di risoluzione**: media (funzionalita)

## 2026-04-05 - TextScaler disabilitato nel frontend
- **File**: frontend/lib/main.dart
- **Riga**: ~116
- **Tipo**: altro
- **Dettaglio**: `TextScaler.linear(1.0)` impedisce agli utenti di ingrandire il testo tramite impostazioni di sistema. Viola WCAG AA (accessibilita). Potrebbe essere segnalato in review App Store.
- **Priorità di risoluzione**: bassa (pulizia)

## 2026-04-05 - Dipendenze inutilizzate nel frontend
- **File**: frontend/pubspec.yaml
- **Riga**: (varie)
- **Tipo**: altro
- **Dettaglio**: `cached_network_image`, `connectivity_plus`, `fl_chart` — aggiunte ma mai utilizzate nel codice. Appesantiscono inutilmente il build.
- **Priorità di risoluzione**: bassa (pulizia)

## 2026-04-06 - Colore pupilla hardcoded nel mascotte painter
- **File**: frontend/lib/presentation/studio_screen/widgets/mascotte_painter.dart
- **Riga**: ~241
- **Tipo**: colore-hardcoded
- **Dettaglio**: `Color(0xFF1A1A2E)` usato per la pupilla della mascotte. Non viene dal tema perché è un dettaglio grafico interno (non UI). In produzione potrebbe essere estratto come token del tema.
- **Priorità di risoluzione**: bassa (pulizia)
