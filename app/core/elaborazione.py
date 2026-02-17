"""Action Executor + Signal Processor.

Action Executor: processa le azioni fire-and-forget dal tutor LLM.
Signal Processor: aggiorna stati in base ai segnali accumulati.
"""


async def esegui_azione(azione: dict) -> dict | None:
    """Esegue un'azione del tutor (proponi_esercizio, mostra_formula, ecc.)."""
    raise NotImplementedError("Blocco 7 — elaborazione azioni")


async def processa_segnali(segnali: list[dict], sessione_id: str, utente_id: str) -> None:
    """Processa i segnali accumulati: aggiorna stato nodi, storico, achievement."""
    raise NotImplementedError("Blocco 7 — elaborazione segnali")
