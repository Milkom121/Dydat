"""Achievement checker + statistiche.

Verifica condizioni achievement dopo ogni turno.
Calcolo streak (giorni consecutivi obiettivo raggiunto).
Aggiornamento statistiche_giornaliere.
"""


async def verifica_achievement(utente_id: str) -> list[dict]:
    """Verifica e sblocca achievement dopo un turno. Ritorna lista di nuovi achievement."""
    raise NotImplementedError("Blocco 10 — gamification")


async def calcola_streak(utente_id: str) -> int:
    """Calcola lo streak corrente (giorni consecutivi con obiettivo raggiunto)."""
    raise NotImplementedError("Blocco 10 — gamification")


async def aggiorna_statistiche_giornaliere(utente_id: str) -> None:
    """Aggiorna le statistiche della giornata corrente."""
    raise NotImplementedError("Blocco 10 — gamification")
