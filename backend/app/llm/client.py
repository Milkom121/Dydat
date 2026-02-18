"""Wrapper Anthropic SDK — streaming, timeout, conteggio token.

Ogni turno = UNA singola chiamata messages.create() con streaming.
NON si rimanda tool_result a Claude (fire-and-forget).
"""

from __future__ import annotations

import asyncio
import json
import logging
from collections.abc import AsyncGenerator
from dataclasses import dataclass, field

import anthropic

from app.config import settings
from app.llm.tools import get_tool_schemas, is_azione, is_segnale

logger = logging.getLogger(__name__)

# Costi per milione di token (USD) — aggiornare se cambiano i pricing
_COSTI_PER_MILIONE: dict[str, tuple[float, float]] = {
    # (input, output)
    "claude-sonnet-4-5-20250929": (3.0, 15.0),
    "claude-haiku-4-5-20251001": (0.80, 4.0),
}

MAX_TOKENS_DEFAULT = 4096


@dataclass
class ToolUseAccumulatore:
    """Accumula i blocchi parziali di un tool_use durante lo streaming."""

    id: str
    name: str
    input_json_parts: list[str] = field(default_factory=list)

    @property
    def input_json(self) -> str:
        return "".join(self.input_json_parts)


@dataclass
class RisultatoTurno:
    """Metadata del turno LLM restituita dopo il completamento dello stream."""

    testo_completo: str
    azioni: list[dict]
    segnali: list[dict]
    token_input: int
    token_output: int
    costo_stimato: float
    modello: str
    stop_reason: str | None = None


def _stima_costo(modello: str, token_input: int, token_output: int) -> float:
    costi = _COSTI_PER_MILIONE.get(modello, (3.0, 15.0))
    return (token_input * costi[0] + token_output * costi[1]) / 1_000_000


def _get_client() -> anthropic.AsyncAnthropic:
    return anthropic.AsyncAnthropic(api_key=settings.ANTHROPIC_API_KEY)


async def chiama_tutor(
    system: str,
    messages: list[dict],
    tools: list[dict] | None = None,
    modello: str | None = None,
    max_tokens: int = MAX_TOKENS_DEFAULT,
) -> AsyncGenerator[dict, None]:
    """Chiama Claude in streaming. Yield eventi strutturati.

    Eventi generati:
        {"tipo": "text_delta", "testo": "..."}
        {"tipo": "tool_use", "name": "...", "input": {...}, "categoria": "azione"|"segnale"}
        {"tipo": "stop", "risultato": RisultatoTurno}
        {"tipo": "errore", "messaggio": "..."}
    """
    modello = modello or settings.LLM_MODEL_TUTOR
    tool_schemas = tools if tools is not None else get_tool_schemas()
    client = _get_client()

    testo_parti: list[str] = []
    azioni: list[dict] = []
    segnali: list[dict] = []
    tool_corrente: ToolUseAccumulatore | None = None
    token_input = 0
    token_output = 0
    stop_reason: str | None = None

    try:
        async with asyncio.timeout(settings.TIMEOUT_LLM_SEC):
            async with client.messages.stream(
                model=modello,
                max_tokens=max_tokens,
                system=system,
                messages=messages,
                tools=tool_schemas,
            ) as stream:
                async for event in stream:
                    # --- Text delta ---
                    if event.type == "content_block_delta":
                        if hasattr(event.delta, "text"):
                            testo_parti.append(event.delta.text)
                            yield {"tipo": "text_delta", "testo": event.delta.text}
                        elif hasattr(event.delta, "partial_json"):
                            if tool_corrente is not None:
                                tool_corrente.input_json_parts.append(
                                    event.delta.partial_json
                                )

                    # --- Inizio nuovo content block ---
                    elif event.type == "content_block_start":
                        if hasattr(event.content_block, "type"):
                            if event.content_block.type == "tool_use":
                                tool_corrente = ToolUseAccumulatore(
                                    id=event.content_block.id,
                                    name=event.content_block.name,
                                )

                    # --- Fine content block (tool_use completo) ---
                    elif event.type == "content_block_stop":
                        if tool_corrente is not None:
                            try:
                                tool_input = json.loads(tool_corrente.input_json)
                            except json.JSONDecodeError:
                                tool_input = {}
                                logger.warning(
                                    "JSON invalido per tool %s: %s",
                                    tool_corrente.name,
                                    tool_corrente.input_json,
                                )

                            tool_data = {
                                "name": tool_corrente.name,
                                "input": tool_input,
                                "id": tool_corrente.id,
                            }

                            if is_azione(tool_corrente.name):
                                azioni.append(tool_data)
                                yield {
                                    "tipo": "tool_use",
                                    "name": tool_corrente.name,
                                    "input": tool_input,
                                    "categoria": "azione",
                                }
                            elif is_segnale(tool_corrente.name):
                                segnali.append(tool_data)
                                yield {
                                    "tipo": "tool_use",
                                    "name": tool_corrente.name,
                                    "input": tool_input,
                                    "categoria": "segnale",
                                }
                            else:
                                logger.warning(
                                    "Tool sconosciuto: %s", tool_corrente.name
                                )

                            tool_corrente = None

                    # --- Messaggio completo ---
                    elif event.type == "message_start":
                        if hasattr(event, "message") and hasattr(event.message, "usage"):
                            token_input = event.message.usage.input_tokens

                    elif event.type == "message_delta":
                        if hasattr(event, "usage") and event.usage:
                            token_output = event.usage.output_tokens
                        if hasattr(event, "delta") and hasattr(event.delta, "stop_reason"):
                            stop_reason = event.delta.stop_reason

    except TimeoutError:
        logger.error("Timeout LLM dopo %d secondi", settings.TIMEOUT_LLM_SEC)
        yield {"tipo": "errore", "messaggio": f"Timeout dopo {settings.TIMEOUT_LLM_SEC}s"}
        return
    except anthropic.APIError as e:
        logger.error("Errore API Anthropic: %s", e)
        yield {"tipo": "errore", "messaggio": f"Errore API: {e.message}"}
        return

    risultato = RisultatoTurno(
        testo_completo="".join(testo_parti),
        azioni=azioni,
        segnali=segnali,
        token_input=token_input,
        token_output=token_output,
        costo_stimato=_stima_costo(modello, token_input, token_output),
        modello=modello,
        stop_reason=stop_reason,
    )

    logger.info(
        "Turno LLM completato: %d token in, %d token out, $%.4f, %d azioni, %d segnali",
        token_input,
        token_output,
        risultato.costo_stimato,
        len(azioni),
        len(segnali),
    )

    yield {"tipo": "stop", "risultato": risultato}
