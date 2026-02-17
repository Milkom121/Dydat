"""Schema completo azioni + segnali per Claude API tool use.

Le azioni vanno al frontend via SSE.
I segnali si accumulano per post-processing.
"""


def get_tool_schemas() -> list[dict]:
    """Ritorna gli schema dei tool (azioni + segnali) per messages.create()."""
    raise NotImplementedError("Blocco 5 — schema tool")
