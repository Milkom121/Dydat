"""Context Builder — assembla i 6 blocchi XML per il system prompt.

Blocco 1: System prompt (fisso)
Blocco 2: Direttiva (da template, situazione corrente)
Blocco 3: Profilo utente
Blocco 4: Contesto attivo (nodo focale + nodi supporto)
Blocco 5: Conversazione nei messages (solo testo)
Blocco 6: Memoria rilevante (placeholder Loop 3)
"""


async def assembla_context_package(sessione_id: str, utente_id: str) -> dict:
    """Assembla il context package completo per una chiamata LLM."""
    raise NotImplementedError("Blocco 6 — context builder")
