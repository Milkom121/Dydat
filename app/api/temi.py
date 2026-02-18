"""API temi — dettaglio tema con nodi e progresso."""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_utente_corrente
from app.db.engine import get_db
from app.db.models.grafo import Nodo, NodoTema, Tema
from app.db.models.stato_utente import StatoNodoUtente
from app.db.models.utenti import Utente

router = APIRouter(prefix="/temi", tags=["temi"])


@router.get("/")
async def lista_temi(
    utente: Utente = Depends(get_utente_corrente),
    db: AsyncSession = Depends(get_db),
):
    """Lista tutti i temi con progresso sintetico."""
    result = await db.execute(
        select(Tema).order_by(Tema.ordine_visualizzazione.asc().nulls_last())
    )
    temi = result.scalars().all()

    risposta = []
    for tema in temi:
        # Conta nodi totali e completati per questo tema
        result_totale = await db.execute(
            select(func.count())
            .select_from(NodoTema)
            .join(Nodo, Nodo.id == NodoTema.nodo_id)
            .where(NodoTema.tema_id == tema.id, Nodo.tipo_nodo != "contesto")
        )
        totale = result_totale.scalar_one()

        result_completati = await db.execute(
            select(func.count())
            .select_from(NodoTema)
            .join(Nodo, Nodo.id == NodoTema.nodo_id)
            .join(
                StatoNodoUtente,
                (StatoNodoUtente.nodo_id == Nodo.id)
                & (StatoNodoUtente.utente_id == utente.id)
                & (StatoNodoUtente.livello == "operativo"),
            )
            .where(NodoTema.tema_id == tema.id, Nodo.tipo_nodo != "contesto")
        )
        completati = result_completati.scalar_one()

        risposta.append({
            "id": tema.id,
            "nome": tema.nome,
            "materia": tema.materia,
            "descrizione": tema.descrizione,
            "nodi_totali": totale,
            "nodi_completati": completati,
            "completato": completati >= totale if totale > 0 else False,
        })

    return risposta


@router.get("/{tema_id}")
async def dettaglio_tema(
    tema_id: str,
    utente: Utente = Depends(get_utente_corrente),
    db: AsyncSession = Depends(get_db),
):
    """Dettaglio tema con nodi e progresso per ciascun nodo."""
    result = await db.execute(select(Tema).where(Tema.id == tema_id))
    tema = result.scalar_one_or_none()
    if not tema:
        raise HTTPException(status_code=404, detail="Tema non trovato")

    # Nodi di questo tema con stato utente
    result_nodi = await db.execute(
        select(Nodo.id, Nodo.nome, Nodo.tipo, Nodo.tipo_nodo)
        .join(NodoTema, NodoTema.nodo_id == Nodo.id)
        .where(NodoTema.tema_id == tema_id, Nodo.tipo_nodo != "contesto")
    )
    nodi_db = result_nodi.all()

    # Carica stati utente per i nodi di questo tema
    nodo_ids = [n.id for n in nodi_db]
    stati: dict = {}
    if nodo_ids:
        result_stati = await db.execute(
            select(
                StatoNodoUtente.nodo_id,
                StatoNodoUtente.livello,
                StatoNodoUtente.presunto,
                StatoNodoUtente.spiegazione_data,
                StatoNodoUtente.esercizi_completati,
            ).where(
                StatoNodoUtente.utente_id == utente.id,
                StatoNodoUtente.nodo_id.in_(nodo_ids),
            )
        )
        stati = {row.nodo_id: row for row in result_stati.all()}

    nodi_dettaglio = []
    for nodo in nodi_db:
        stato = stati.get(nodo.id)
        nodi_dettaglio.append({
            "id": nodo.id,
            "nome": nodo.nome,
            "tipo": nodo.tipo,
            "livello": stato.livello if stato else "non_iniziato",
            "presunto": stato.presunto if stato else False,
            "spiegazione_data": stato.spiegazione_data if stato else False,
            "esercizi_completati": stato.esercizi_completati if stato else 0,
        })

    completati = sum(1 for n in nodi_dettaglio if n["livello"] == "operativo")

    return {
        "id": tema.id,
        "nome": tema.nome,
        "materia": tema.materia,
        "descrizione": tema.descrizione,
        "nodi_totali": len(nodi_dettaglio),
        "nodi_completati": completati,
        "completato": completati >= len(nodi_dettaglio) if nodi_dettaglio else False,
        "nodi": nodi_dettaglio,
    }
