"""API ripasso — nodi SR scaduti per l'utente corrente (B28)."""

from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_utente_corrente
from app.db.engine import get_db
from app.db.models.grafo import Nodo, NodoTema, Tema
from app.db.models.stato_utente import StatoNodoUtente
from app.db.models.utenti import Utente

router = APIRouter(prefix="/ripasso", tags=["ripasso"])


@router.get("/nodi")
async def nodi_da_ripassare(
    utente: Utente = Depends(get_utente_corrente),
    db: AsyncSession = Depends(get_db),
):
    """Ritorna i nodi con sr_prossimo_ripasso scaduto oggi.

    Restituisce solo nodi che hanno almeno una review SR completata
    (sr_card_json IS NOT NULL), ordinati per urgenza (più scaduti per primi).
    Un nodo appare una sola volta anche se appartiene a più temi
    (si usa il primo tema trovato in ordine di visualizzazione).
    """
    now = datetime.now(timezone.utc)

    result = await db.execute(
        select(
            StatoNodoUtente.nodo_id,
            StatoNodoUtente.sr_prossimo_ripasso,
            StatoNodoUtente.sr_ripetizioni,
            Nodo.nome.label("nodo_nome"),
            NodoTema.tema_id,
            Tema.nome.label("tema_nome"),
        )
        .join(Nodo, Nodo.id == StatoNodoUtente.nodo_id)
        .join(NodoTema, NodoTema.nodo_id == Nodo.id)
        .join(Tema, Tema.id == NodoTema.tema_id)
        .where(
            StatoNodoUtente.utente_id == utente.id,
            StatoNodoUtente.sr_prossimo_ripasso <= now,
            StatoNodoUtente.sr_card_json.is_not(None),
        )
        .order_by(
            StatoNodoUtente.sr_prossimo_ripasso,
            Tema.ordine_visualizzazione.asc().nulls_last(),
        )
    )

    rows = result.all()

    # Deduplica: un nodo può essere in più temi, teniamo il primo (più urgente/visualizzato)
    seen: set[str] = set()
    risposta = []
    for row in rows:
        if row.nodo_id not in seen:
            seen.add(row.nodo_id)
            risposta.append({
                "nodo_id": row.nodo_id,
                "nodo_nome": row.nodo_nome,
                "tema_id": row.tema_id,
                "tema_nome": row.tema_nome,
                "sr_prossimo_ripasso": (
                    row.sr_prossimo_ripasso.isoformat()
                    if row.sr_prossimo_ripasso
                    else None
                ),
                "sr_ripetizioni": row.sr_ripetizioni or 0,
            })

    return risposta
