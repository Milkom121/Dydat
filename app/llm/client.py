"""Wrapper Anthropic SDK — streaming, timeout, conteggio token.

Ogni turno = UNA singola chiamata messages.create() con streaming.
NON si rimanda tool_result a Claude (fire-and-forget).
"""

from collections.abc import AsyncGenerator


async def chiama_tutor(
    system: str,
    messages: list[dict],
    tools: list[dict],
) -> AsyncGenerator[dict, None]:
    """Chiama Claude in streaming. Yield eventi: text_delta, tool_use, stop."""
    raise NotImplementedError("Blocco 5 — client LLM")
    yield  # noqa: F401 — rende questa funzione un async generator
