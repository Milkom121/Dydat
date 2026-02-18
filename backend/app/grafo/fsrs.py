"""FSRS — Spaced Repetition (Loop 2, predisposto).

Interfaccia definita, implementazione stub.
Usa la libreria `fsrs` su PyPI quando implementato.
"""


async def calcola_prossimo_ripasso(utente_id: str, nodo_id: str, esito: str) -> dict:
    """Calcola il prossimo ripasso con FSRS. Ritorna {prossimo_ripasso, intervallo, facilita}."""
    raise NotImplementedError("Loop 2 — FSRS non ancora implementato")


async def get_nodi_da_ripassare(utente_id: str) -> list[str]:
    """Ritorna i nodi che necessitano ripasso oggi."""
    raise NotImplementedError("Loop 2 — FSRS non ancora implementato")
