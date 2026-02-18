"""Query sullo stato utente rispetto al grafo.

Livelli: non_iniziato -> in_corso -> operativo -> comprensivo -> connesso.
"""

import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.stato_utente import StatoNodoUtente


async def get_livelli_utente(utente_id: uuid.UUID, db: AsyncSession) -> dict[str, str]:
    """Ritorna lo stato di tutti i nodi per un utente.

    Ritorna {nodo_id: livello}. Nodi non presenti in stato_nodi_utente
    hanno livello implicito 'non_iniziato' (gestito dal chiamante).
    """
    result = await db.execute(
        select(StatoNodoUtente.nodo_id, StatoNodoUtente.livello).where(
            StatoNodoUtente.utente_id == utente_id
        )
    )
    return dict(result.all())


async def aggiorna_livello(
    utente_id: uuid.UUID,
    nodo_id: str,
    livello: str,
    db: AsyncSession,
) -> None:
    """Aggiorna il livello di un nodo per un utente (UPSERT)."""
    stmt = pg_insert(StatoNodoUtente).values(
        utente_id=utente_id,
        nodo_id=nodo_id,
        livello=livello,
        ultima_interazione=datetime.now(timezone.utc),
    )
    stmt = stmt.on_conflict_do_update(
        index_elements=["utente_id", "nodo_id"],
        set_={"livello": livello, "ultima_interazione": datetime.now(timezone.utc)},
    )
    await db.execute(stmt)
    await db.commit()
