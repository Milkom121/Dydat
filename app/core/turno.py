"""Ciclo del turno — coordinatore delle 3 fasi.

Fase 1: Preparazione (carica stato, assembla context package)
Fase 2: Chiamata LLM (streaming, parsing, eventi SSE)
Fase 3: Post-processing (segnali, achievement)

HARD CONSTRAINT: il flusso delle 3 fasi è visibile in un posto.
"""

from __future__ import annotations

import logging
import uuid
from collections.abc import AsyncGenerator

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.contesto import assembla_context_package
from app.core.conversazione import salva_turno
from app.core.elaborazione import (
    aggiorna_nodo_dopo_promozione,
    esegui_azione,
    processa_segnali,
)
from app.db.models.utenti import Sessione
from app.llm.client import chiama_tutor

logger = logging.getLogger(__name__)


async def esegui_turno(
    db: AsyncSession,
    sessione_id: uuid.UUID,
    utente_id: uuid.UUID,
    messaggio_utente: str | None = None,
) -> AsyncGenerator[dict, None]:
    """Esegue un turno completo: preparazione → LLM → post-processing.

    Yield eventi SSE strutturati:
        {"event": "text_delta", "data": {"testo": "..."}}
        {"event": "azione", "data": {"tipo": "...", "params": {...}}}
        {"event": "achievement", "data": {"id": "...", "nome": "..."}}
        {"event": "turno_completo", "data": {"turno_id": ..., "nodo_focale": ...}}
        {"event": "errore", "data": {"codice": "...", "messaggio": "..."}}
    """

    # =================================================================
    # FASE 1 — Preparazione
    # =================================================================
    logger.info(
        "Turno: fase 1 (preparazione) sessione=%s, utente=%s",
        sessione_id, utente_id,
    )

    # Salva messaggio utente (se presente — non c'è nel primo turno)
    if messaggio_utente:
        await salva_turno(
            db=db,
            sessione_id=sessione_id,
            ruolo="utente",
            contenuto=messaggio_utente,
        )
        await db.commit()

    # Assembla context package (blocchi 1-6)
    try:
        ctx = await assembla_context_package(
            sessione_id=sessione_id,
            utente_id=utente_id,
            db=db,
        )
    except ValueError as e:
        logger.error("Errore assemblaggio contesto: %s", e)
        yield _evento_errore("context_error", str(e))
        return

    # =================================================================
    # FASE 2 — Chiamata LLM (streaming)
    # =================================================================
    logger.info(
        "Turno: fase 2 (LLM streaming) sessione=%s, modello=%s",
        sessione_id, ctx.modello,
    )

    azioni_accumulate: list[dict] = []
    segnali_accumulati: list[dict] = []
    risultato_llm = None

    async for evento_llm in chiama_tutor(
        system=ctx.system,
        messages=ctx.messages,
        modello=ctx.modello,
    ):
        tipo = evento_llm.get("tipo")

        if tipo == "text_delta":
            yield _evento_sse("text_delta", {"testo": evento_llm["testo"]})

        elif tipo == "tool_use":
            if evento_llm["categoria"] == "azione":
                # Esegui l'azione e inoltra al frontend
                azione_raw = {
                    "name": evento_llm["name"],
                    "input": evento_llm["input"],
                }
                azioni_accumulate.append(azione_raw)

                azione_result = await esegui_azione(
                    db=db,
                    azione=azione_raw,
                    sessione_id=sessione_id,
                    utente_id=utente_id,
                )
                if azione_result:
                    yield _evento_sse("azione", azione_result)
            else:
                # Segnale — accumula per post-processing
                segnali_accumulati.append({
                    "name": evento_llm["name"],
                    "input": evento_llm["input"],
                })

        elif tipo == "stop":
            risultato_llm = evento_llm["risultato"]

        elif tipo == "errore":
            yield _evento_errore("llm_error", evento_llm["messaggio"])
            return

    if risultato_llm is None:
        yield _evento_errore("llm_error", "Stream LLM terminato senza risultato")
        return

    # =================================================================
    # FASE 3 — Post-processing
    # =================================================================
    logger.info(
        "Turno: fase 3 (post-processing) sessione=%s, "
        "%d azioni, %d segnali",
        sessione_id,
        len(azioni_accumulate),
        len(segnali_accumulati),
    )

    # Salva turno assistente (solo testo, azioni e segnali separati)
    stato_orch = None
    sess_result = await db.execute(
        select(Sessione).where(Sessione.id == sessione_id)
    )
    sess = sess_result.scalar_one_or_none()
    if sess:
        stato_orch = sess.stato_orchestratore or {}

    turno_salvato = await salva_turno(
        db=db,
        sessione_id=sessione_id,
        ruolo="assistente",
        contenuto=risultato_llm.testo_completo or None,
        azioni=azioni_accumulate if azioni_accumulate else None,
        segnali=segnali_accumulati if segnali_accumulati else None,
        nodo_focale_id=stato_orch.get("nodo_focale_id") if stato_orch else None,
        modello=risultato_llm.modello,
        token_input=risultato_llm.token_input,
        token_output=risultato_llm.token_output,
        costo_stimato=risultato_llm.costo_stimato,
    )

    # Processa segnali
    promozioni = await processa_segnali(
        db=db,
        segnali=segnali_accumulati,
        sessione_id=sessione_id,
        utente_id=utente_id,
    )

    # Gestisci promozioni
    for promo in promozioni:
        nodo_promosso = promo["nodo_id"]
        prossimo_nodo = await aggiorna_nodo_dopo_promozione(
            db=db,
            sessione_id=sessione_id,
            utente_id=utente_id,
            nodo_promosso=nodo_promosso,
        )
        logger.info(
            "Promozione %s → operativo, prossimo: %s",
            nodo_promosso, prossimo_nodo,
        )

    # Achievement check (Blocco 10 — stub, non solleva errore)
    achievement_nuovi = await _verifica_achievement_safe(utente_id, db)
    for ach in achievement_nuovi:
        yield _evento_sse("achievement", ach)

    # Commit finale
    await db.commit()

    # Evento turno_completo
    nodo_focale_id = None
    if sess:
        await db.refresh(sess)
        stato_orch = sess.stato_orchestratore or {}
        nodo_focale_id = stato_orch.get("nodo_focale_id")

    yield _evento_sse("turno_completo", {
        "turno_id": turno_salvato.id,
        "nodo_focale": nodo_focale_id,
    })

    logger.info(
        "Turno completato: sessione=%s, turno_id=%d, "
        "token_in=%d, token_out=%d, $%.4f",
        sessione_id,
        turno_salvato.id,
        risultato_llm.token_input,
        risultato_llm.token_output,
        risultato_llm.costo_stimato,
    )


# ===================================================================
# Helper
# ===================================================================


def _evento_sse(event: str, data: dict) -> dict:
    """Costruisce un evento SSE strutturato."""
    return {"event": event, "data": data}


def _evento_errore(codice: str, messaggio: str) -> dict:
    return _evento_sse("errore", {"codice": codice, "messaggio": messaggio})


async def _verifica_achievement_safe(
    utente_id: uuid.UUID,
    db: AsyncSession,
) -> list[dict]:
    """Wrapper safe per verifica achievement (Blocco 10 stub)."""
    try:
        from app.core.gamification import verifica_achievement
        return await verifica_achievement(utente_id)
    except NotImplementedError:
        # Blocco 10 non ancora implementato — ok
        return []
    except Exception:
        logger.warning(
            "Errore verifica achievement (non bloccante)",
            exc_info=True,
        )
        return []
