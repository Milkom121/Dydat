# Dydat

Tutor AI adattivo per matematica, fisica e chimica. App mobile Flutter con backend FastAPI e Claude come LLM.

## Struttura

```
backend/    — API REST + SSE (Python/FastAPI/PostgreSQL)
frontend/   — App mobile (Flutter/Dart)
docs/       — Documentazione progetto
```

## Setup Sviluppo

### Backend
```bash
cd backend
docker compose up --build -d
alembic upgrade head
python scripts/import_extraction.py data/Algebra1 data/Algebra2
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## Documentazione

- `docs/dydat_api_reference.md` — Riferimento API completo
- `docs/dydat_digest.md` — Overview del progetto
- `CLAUDE.md` — Stato corrente e regole di sviluppo
