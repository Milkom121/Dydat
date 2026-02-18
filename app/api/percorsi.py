"""API percorsi — lista percorsi utente, mappa nodi con stato."""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_utente_corrente
from app.db.engine import get_db
from app.db.models.grafo import Nodo, NodoTema
from app.db.models.stato_utente import StatoNodoUtente
from app.db.models.utenti import PercorsoUtente, Utente

router = APIRouter(prefix="/percorsi", tags=["percorsi"])


@router.get("/")
async def lista_percorsi(
    utente: Utente = Depends(get_utente_corrente),
    db: AsyncSession = Depends(get_db),
):
    """Lista percorsi dell'utente autenticato."""
    result = await db.execute(
        select(PercorsoUtente).where(PercorsoUtente.utente_id == utente.id)
    )
    percorsi = result.scalars().all()
    return [
        {
            "id": p.id,
            "tipo": p.tipo,
            "materia": p.materia,
            "nome": p.nome,
            "stato": p.stato,
            "nodo_iniziale_override": p.nodo_iniziale_override,
            "created_at": p.created_at.isoformat() if p.created_at else None,
        }
        for p in percorsi
    ]


@router.get("/{percorso_id}/mappa")
async def mappa_nodi(
    percorso_id: int,
    utente: Utente = Depends(get_utente_corrente),
    db: AsyncSession = Depends(get_db),
):
    """Nodi del percorso con stato utente per mappa visuale.

    Ritorna tutti i nodi operativi (no contesto) con:
    - livello corrente dell'utente
    - tema associato
    - se è sbloccato o meno
    """
    # Verifica che il percorso appartenga all'utente
    result = await db.execute(
        select(PercorsoUtente).where(
            PercorsoUtente.id == percorso_id,
            PercorsoUtente.utente_id == utente.id,
        )
    )
    percorso = result.scalar_one_or_none()
    if not percorso:
        raise HTTPException(status_code=404, detail="Percorso non trovato")

    # Carica tutti i nodi operativi con il loro tema
    result_nodi = await db.execute(
        select(Nodo.id, Nodo.nome, Nodo.tipo, Nodo.tipo_nodo, NodoTema.tema_id)
        .outerjoin(NodoTema, NodoTema.nodo_id == Nodo.id)
        .where(Nodo.tipo_nodo != "contesto")
    )
    nodi_db = result_nodi.all()

    # Carica stati utente
    result_stati = await db.execute(
        select(
            StatoNodoUtente.nodo_id,
            StatoNodoUtente.livello,
            StatoNodoUtente.presunto,
            StatoNodoUtente.spiegazione_data,
            StatoNodoUtente.esercizi_completati,
        ).where(StatoNodoUtente.utente_id == utente.id)
    )
    stati = {row.nodo_id: row for row in result_stati.all()}

    nodi_mappa = []
    for nodo_id, nome, tipo, tipo_nodo, tema_id in nodi_db:
        stato = stati.get(nodo_id)
        nodi_mappa.append({
            "id": nodo_id,
            "nome": nome,
            "tipo": tipo,
            "tema_id": tema_id,
            "livello": stato.livello if stato else "non_iniziato",
            "presunto": stato.presunto if stato else False,
            "spiegazione_data": stato.spiegazione_data if stato else False,
            "esercizi_completati": stato.esercizi_completati if stato else 0,
        })

    return {
        "percorso_id": percorso.id,
        "materia": percorso.materia,
        "nodo_iniziale_override": percorso.nodo_iniziale_override,
        "nodi": nodi_mappa,
    }
