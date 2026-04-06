# Configurazione Progetto

## Identita

- **Nome progetto**: Dydat
- **Descrizione breve**: Tutor AI adattivo per matematica, fisica e chimica. App mobile Flutter + backend FastAPI + Claude API.
- **Dominio**: mobile / education / AI
- **Stato**: attivo

## Date

- **Data creazione**: 2026-02-18
- **Data ultimo aggiornamento**: 2026-04-06
- **Data ultima sessione**: 2026-04-06 (S35 — B38, Fase 9 Mascotte CustomPainter)
- **Prossima sessione**: S36 — B39 (Fase 10, Onboarding con Momento Wow)

## Stack Tecnologico (HARD CONSTRAINT)

> Queste scelte non cambiano senza decisione esplicita di Villa.

### Backend

| Componente | Tecnologia scelta | Note |
|------------|-------------------|------|
| Linguaggio | Python 3.12 | |
| Framework | FastAPI | Async-native |
| Database | PostgreSQL 16 | Async via asyncpg + SQLAlchemy 2 |
| Migrazioni | Alembic | 17 tabelle, schema stabile |
| LLM | Claude API (anthropic SDK) | Sonnet per tutor, Haiku per pipeline |
| Grafo | NetworkX | Grafo conoscenza in-memory |
| Auth | JWT (python-jose) + bcrypt | Token 720h |
| SSE | sse-starlette | Server-Sent Events per streaming |
| Container | Docker Compose | PostgreSQL + backend |

### Frontend

| Componente | Tecnologia scelta | Note |
|------------|-------------------|------|
| Framework | Flutter (mobile-first) | |
| State Management | Riverpod (flutter_riverpod) | |
| Routing | GoRouter (go_router) | Shell route con bottom nav |
| HTTP Client | Dio | + http per SSE raw |
| JWT Storage | flutter_secure_storage | |
| Responsive | sizer_extensions.dart custom (.w .h .sp) | Sostituisce sizer (incompatibile Flutter 3.41) |
| Tema | Dark-first, ThemeMode.system default | Material 3 |
| Font | Plus Jakarta Sans (Google Fonts) | |
| LaTeX | flutter_math_fork | Rendering nativo, no WebView |
| Markdown | flutter_markdown | Per messaggi tutor |

## Regole Specifiche del Progetto

- **Backend stabile**: il backend e completo e testato (282 test). Puo essere esteso per feature cross-stack (nuovi tool LLM, prompt, filtering) quando previsto dal blocco corrente in ROADMAP.md. Schema DB (tabelle/colonne) non va modificato se non esplicitamente richiesto dal blocco.
- **Fonte di verita API**: `docs/dydat_api_reference.md` — consultare sempre prima di toccare servizi/modelli frontend.
- **Widget nuovi**: usano `Theme.of(context)` — zero colori hardcoded.
- **JSON**: snake_case (backend) -> camelCase (Dart) nei fromJson/toJson.
- **Riverpod + initState**: mai modificare un provider dentro initState/build/dispose — usare `Future.microtask()`.
- **Sealed class SSE**: quando si aggiungono nuovi sottotipi `SseEvent`, aggiornare TUTTI gli switch (session_provider + onboarding_provider).

## Comandi Essenziali

```bash
# === BACKEND ===

# Avvio (SEMPRE da backend/, MAI da worktree)
cd backend
docker compose up --build -d
docker exec backend-backend-1 alembic upgrade head
docker exec backend-backend-1 python scripts/import_extraction.py data/Algebra1 data/Algebra2
# Se non parte al primo avvio: docker compose restart backend

# Test backend
docker exec backend-backend-1 python -m pytest -x -q
docker exec backend-backend-1 python -m ruff check app/

# === FRONTEND ===

# Avvio
cd frontend
flutter pub get
flutter run

# Test frontend
flutter analyze
flutter test
```

## Deployment

- **Ambiente**: sviluppo locale
- **Hosting**: Docker Compose (PostgreSQL + backend FastAPI)
- **URL produzione**: non ancora configurato

## Struttura Monorepo

```
Dydat_V1_2026/
├── backend/          # Python/FastAPI — COMPLETO (11 blocchi, 282 test)
├── frontend/         # Flutter/Dart — Loop 4 completato (210 test)
├── docs/             # Documentazione + archivio storico
├── .claude/          # Stato sessioni, decisioni, skill, metodo
├── CLAUDE.md         # Regole operative (Metodo Villa + progetto)
├── PROJECT_CONFIG.md # QUESTO FILE — stack, comandi, deploy
└── ROADMAP.md        # Fasi e blocchi con stato
```

## Link Utili

- Roadmap: ROADMAP.md
- Log decisioni: .claude/decisions.md
- Scorciatoie attive: docs/dev-shortcuts.md
- Handoff ultima sessione: .claude/handoff.md
- API Reference: docs/dydat_api_reference.md
- Direzione visiva: docs/dydat_direzione_visiva_v2.md
- Brief originale: docs/dydat_brief_rocket_new_v2.md
- Backend details: backend/CLAUDE.md
