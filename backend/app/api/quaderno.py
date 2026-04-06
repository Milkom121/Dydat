"""API quaderno — raccoglie appunti, esercizi, formule per nodo (B35)."""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_utente_corrente
from app.db.engine import get_db
from app.db.models.grafo import Esercizio, Nodo, NodoTema, Tema
from app.db.models.stato_utente import StatoNodoUtente, StoricoEsercizi
from app.db.models.utenti import Sessione, TurnoConversazione, Utente

router = APIRouter(prefix="/quaderno", tags=["quaderno"])


@router.get("/{nodo_id}")
async def get_quaderno_nodo(
    nodo_id: str,
    utente: Utente = Depends(get_utente_corrente),
    db: AsyncSession = Depends(get_db),
):
    """Ritorna il quaderno aggregato per un nodo specifico.

    Aggrega: stato utente sul nodo, storico esercizi svolti,
    formule mostrate dal tutor, spiegazioni chiave.
    Il quaderno e uno per nodo (non per percorso).
    """
    # Verifica che il nodo esista
    nodo_result = await db.execute(select(Nodo).where(Nodo.id == nodo_id))
    nodo = nodo_result.scalar_one_or_none()
    if nodo is None:
        raise HTTPException(status_code=404, detail="Nodo non trovato")

    # Tema del nodo (primo trovato)
    tema_result = await db.execute(
        select(Tema.nome)
        .join(NodoTema, NodoTema.tema_id == Tema.id)
        .where(NodoTema.nodo_id == nodo_id)
        .order_by(Tema.ordine_visualizzazione.asc().nulls_last())
        .limit(1)
    )
    tema_nome = tema_result.scalar_one_or_none()

    # Stato utente sul nodo
    stato_result = await db.execute(
        select(StatoNodoUtente).where(
            StatoNodoUtente.utente_id == utente.id,
            StatoNodoUtente.nodo_id == nodo_id,
        )
    )
    stato = stato_result.scalar_one_or_none()

    # Storico esercizi svolti su questo nodo
    esercizi_result = await db.execute(
        select(
            StoricoEsercizi.id,
            StoricoEsercizi.esercizio_id,
            StoricoEsercizi.esito,
            StoricoEsercizi.created_at,
            Esercizio.testo.label("esercizio_testo"),
            Esercizio.tipo.label("esercizio_tipo"),
            Esercizio.difficolta.label("esercizio_difficolta"),
        )
        .outerjoin(Esercizio, Esercizio.id == StoricoEsercizi.esercizio_id)
        .where(
            StoricoEsercizi.utente_id == utente.id,
            StoricoEsercizi.nodo_focale_id == nodo_id,
        )
        .order_by(StoricoEsercizi.created_at.desc())
        .limit(50)
    )
    esercizi_rows = esercizi_result.all()

    # Formule mostrate dal tutor per questo nodo (azione mostra_formula nei turni)
    formule_result = await db.execute(
        select(
            TurnoConversazione.azioni,
            TurnoConversazione.created_at,
        )
        .join(Sessione, Sessione.id == TurnoConversazione.sessione_id)
        .where(
            Sessione.utente_id == utente.id,
            TurnoConversazione.nodo_focale_id == nodo_id,
            TurnoConversazione.azioni.is_not(None),
        )
        .order_by(TurnoConversazione.created_at.desc())
        .limit(100)
    )
    formule_rows = formule_result.all()

    # Estrai formule dalle azioni dei turni
    formule = []
    seen_formule: set[str] = set()
    for row in formule_rows:
        azioni = row.azioni if isinstance(row.azioni, list) else []
        for azione in azioni:
            if not isinstance(azione, dict):
                continue
            if azione.get("tipo") != "mostra_formula":
                continue
            dati = azione.get("dati", {})
            titolo = dati.get("titolo", "")
            # Deduplica per titolo
            if titolo and titolo not in seen_formule:
                seen_formule.add(titolo)
                formule.append({
                    "titolo": titolo,
                    "formula": dati.get("formula", ""),
                    "spiegazione": dati.get("spiegazione", ""),
                    "data": row.created_at.isoformat() if row.created_at else None,
                })

    # Spiegazioni chiave (turni tutor con contenuto su questo nodo)
    spiegazioni_result = await db.execute(
        select(
            TurnoConversazione.contenuto,
            TurnoConversazione.created_at,
            Sessione.id.label("sessione_id"),
        )
        .join(Sessione, Sessione.id == TurnoConversazione.sessione_id)
        .where(
            Sessione.utente_id == utente.id,
            TurnoConversazione.nodo_focale_id == nodo_id,
            TurnoConversazione.ruolo == "tutor",
            TurnoConversazione.contenuto.is_not(None),
            func.length(TurnoConversazione.contenuto) > 50,
        )
        .order_by(TurnoConversazione.created_at.desc())
        .limit(20)
    )
    spiegazioni_rows = spiegazioni_result.all()

    # Conteggio sessioni in cui e stato lavorato questo nodo
    sessioni_count_result = await db.execute(
        select(func.count(func.distinct(TurnoConversazione.sessione_id)))
        .join(Sessione, Sessione.id == TurnoConversazione.sessione_id)
        .where(
            Sessione.utente_id == utente.id,
            TurnoConversazione.nodo_focale_id == nodo_id,
        )
    )
    sessioni_count = sessioni_count_result.scalar_one()

    return {
        "nodo_id": nodo_id,
        "nodo_nome": nodo.nome,
        "tema_nome": tema_nome,
        "stato": {
            "livello": stato.livello if stato else "non_iniziato",
            "presunto": stato.presunto if stato else False,
            "spiegazione_data": stato.spiegazione_data if stato else False,
            "esercizi_completati": stato.esercizi_completati if stato else 0,
            "sr_prossimo_ripasso": (
                stato.sr_prossimo_ripasso.isoformat()
                if stato and stato.sr_prossimo_ripasso
                else None
            ),
            "sr_ripetizioni": stato.sr_ripetizioni if stato else 0,
            "ultima_interazione": (
                stato.ultima_interazione.isoformat()
                if stato and stato.ultima_interazione
                else None
            ),
        },
        "sessioni_count": sessioni_count,
        "esercizi": [
            {
                "id": row.id,
                "esercizio_id": row.esercizio_id,
                "esito": row.esito,
                "testo": row.esercizio_testo,
                "tipo": row.esercizio_tipo,
                "difficolta": row.esercizio_difficolta,
                "data": row.created_at.isoformat() if row.created_at else None,
            }
            for row in esercizi_rows
        ],
        "formule": formule,
        "spiegazioni": [
            {
                "contenuto": row.contenuto,
                "sessione_id": str(row.sessione_id),
                "data": row.created_at.isoformat() if row.created_at else None,
            }
            for row in spiegazioni_rows
        ],
    }
