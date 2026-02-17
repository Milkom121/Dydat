"""Ciclo del turno — coordinatore delle 3 fasi.

Fase 1: Preparazione (carica stato, assembla context package)
Fase 2: Chiamata LLM (streaming, parsing, eventi SSE)
Fase 3: Post-processing (segnali, achievement)
"""


async def esegui_turno(sessione_id: str, messaggio_utente: str) -> None:
    """Esegue un turno completo: preparazione → LLM → post-processing."""
    raise NotImplementedError("Blocco 7 — flusso del turno")
