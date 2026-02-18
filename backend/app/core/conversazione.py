"""Conversation Manager — salvataggio turni.

contenuto = SOLO testo visibile
azioni = JSONB separato (MAI nei messages)
segnali = JSONB separato (MAI nei messages)
I messages per Claude contengono SOLO il testo dei turni precedenti.
"""

from __future__ import annotations

import logging
import uuid

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.utenti import TurnoConversazione

logger = logging.getLogger(__name__)


async def salva_turno(
    db: AsyncSession,
    sessione_id: uuid.UUID,
    ruolo: str,
    contenuto: str | None,
    azioni: list | None = None,
    segnali: list | None = None,
    nodo_focale_id: str | None = None,
    modello: str | None = None,
    token_input: int | None = None,
    token_output: int | None = None,
    costo_stimato: float | None = None,
) -> TurnoConversazione:
    """Salva un turno di conversazione separando testo, azioni e segnali.

    Args:
        ruolo: "utente" o "assistente"
        contenuto: SOLO testo visibile
        azioni: lista azioni (JSONB separato, MAI nei messages)
        segnali: lista segnali (JSONB separato, MAI nei messages)
    """
    # Calcola prossimo ordine
    result = await db.execute(
        select(func.coalesce(func.max(TurnoConversazione.ordine), 0)).where(
            TurnoConversazione.sessione_id == sessione_id
        )
    )
    ordine_corrente = result.scalar_one()

    turno = TurnoConversazione(
        sessione_id=sessione_id,
        ordine=ordine_corrente + 1,
        ruolo=ruolo,
        contenuto=contenuto,
        azioni=azioni,
        segnali=segnali,
        nodo_focale_id=nodo_focale_id,
        modello=modello,
        token_input=token_input,
        token_output=token_output,
        costo_stimato=costo_stimato,
    )
    db.add(turno)
    await db.flush()

    logger.debug(
        "Turno salvato: sessione=%s, ordine=%d, ruolo=%s, %d chars",
        sessione_id,
        turno.ordine,
        ruolo,
        len(contenuto) if contenuto else 0,
    )

    return turno


async def carica_conversazione(
    db: AsyncSession,
    sessione_id: uuid.UUID,
) -> list[dict]:
    """Carica i turni per i messages Claude (solo testo, no azioni/segnali)."""
    result = await db.execute(
        select(
            TurnoConversazione.ruolo,
            TurnoConversazione.contenuto,
        )
        .where(TurnoConversazione.sessione_id == sessione_id)
        .order_by(TurnoConversazione.ordine)
    )
    messages = []
    for ruolo, contenuto in result.all():
        if contenuto:
            messages.append({
                "role": "user" if ruolo == "utente" else "assistant",
                "content": contenuto,
            })
    return messages
