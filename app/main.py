import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.api import achievement, auth, onboarding, percorsi, sessione, temi, utente
from app.db.engine import async_session
from app.grafo.struttura import grafo_knowledge

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    async with async_session() as db:
        await grafo_knowledge.carica(db)
        # Seed achievement definizioni (UPSERT idempotente)
        from app.core.gamification import seed_achievement
        await seed_achievement(db)
        await db.commit()
    yield


app = FastAPI(title="Dydat Backend", version="0.1.0", lifespan=lifespan)

# Routers
app.include_router(auth.router)
app.include_router(utente.router)
app.include_router(onboarding.router)
app.include_router(sessione.router)
app.include_router(percorsi.router)
app.include_router(temi.router)
app.include_router(achievement.router)


@app.get("/health")
async def health_check():
    return {"status": "ok"}
