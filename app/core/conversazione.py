"""Conversation Manager — salvataggio turni.

contenuto = SOLO testo visibile
azioni = JSONB separato (MAI nei messages)
segnali = JSONB separato (MAI nei messages)
I messages per Claude contengono SOLO il testo dei turni precedenti.
"""


async def salva_turno(
    sessione_id: str,
    ruolo: str,
    contenuto: str | None,
    azioni: list | None = None,
    segnali: list | None = None,
) -> None:
    """Salva un turno di conversazione separando testo, azioni e segnali."""
    raise NotImplementedError("Blocco 7 — conversazione")


async def carica_conversazione(sessione_id: str) -> list[dict]:
    """Carica i turni per i messages Claude (solo testo, no azioni/segnali)."""
    raise NotImplementedError("Blocco 7 — conversazione")
