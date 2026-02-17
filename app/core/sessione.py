"""Session Manager + Path Planner.

Gestisce creazione, sospensione, ripresa di sessioni.
Scelta nodo a inizio sessione: sospesa → in_corso → path planner.
Sessione unica attiva per utente (409 / auto-sospensione).
"""


async def inizia_sessione(utente_id: str) -> None:
    """Crea una nuova sessione o riprende una sospesa."""
    raise NotImplementedError("Blocco 8 — API sessione")


async def sospendi_sessione(sessione_id: str) -> None:
    """Salva lo stato dell'orchestratore e sospende la sessione."""
    raise NotImplementedError("Blocco 8 — API sessione")


async def termina_sessione(sessione_id: str) -> None:
    """Chiude la sessione e genera riepilogo."""
    raise NotImplementedError("Blocco 8 — API sessione")
