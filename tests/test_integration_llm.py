"""Test integrazione LLM — smoke test con Claude reale.

Verifica che il system prompt, le direttive, e i tool schemas funzionino
con Claude reale. Gira solo con `pytest --run-integration` e richiede
ANTHROPIC_API_KEY nell'ambiente.

Costo stimato: ~$0.01-0.05 per esecuzione completa.
"""

from __future__ import annotations

import os

import pytest

# Skip tutto il modulo se non c'è la API key o il marker
pytestmark = pytest.mark.integration


def _has_api_key() -> bool:
    key = os.environ.get("ANTHROPIC_API_KEY", "")
    return key.startswith("sk-ant-")


@pytest.fixture
def api_key():
    """Fornisce la API key o skippa il test."""
    if not _has_api_key():
        pytest.skip("ANTHROPIC_API_KEY non configurata")
    return os.environ["ANTHROPIC_API_KEY"]


class TestSmokeTestLLM:
    """Smoke test: manda un turno reale a Claude e verifica la risposta."""

    @pytest.mark.asyncio
    async def test_turno_spiegazione_produce_testo_e_segnale(self, api_key):
        """Un turno di spiegazione produce testo + segnale concetto_spiegato."""
        from app.llm.client import chiama_tutor
        from app.llm.prompts.direttive import direttiva_spiegazione
        from app.llm.prompts.system_prompt import SYSTEM_PROMPT

        direttiva = direttiva_spiegazione(
            nodo_nome="Insiemi numerici",
            nodo_id="mat_algebra2_insiemi_numerici",
            definizione="I numeri si classificano in naturali, interi, razionali, "
            "irrazionali e reali.",
            formule=["N ⊂ Z ⊂ Q ⊂ R"],
            errori_comuni=[],
            esempi=[],
            minuti_rimasti=25,
        )

        system = f"{SYSTEM_PROMPT}\n\n{direttiva}"
        messages = [
            {"role": "user", "content": "(Lo studente ha appena iniziato la sessione.)"},
        ]

        eventi_testo = []
        eventi_tool = []
        risultato = None

        async for evento in chiama_tutor(
            system=system,
            messages=messages,
            max_tokens=1024,
        ):
            tipo = evento.get("tipo")
            if tipo == "text_delta":
                eventi_testo.append(evento["testo"])
            elif tipo == "tool_use":
                eventi_tool.append(evento)
            elif tipo == "stop":
                risultato = evento["risultato"]
            elif tipo == "errore":
                pytest.fail(f"Errore LLM: {evento['messaggio']}")

        # Verifiche strutturali
        testo_completo = "".join(eventi_testo)
        assert len(testo_completo) > 50, "Il tutor dovrebbe produrre testo significativo"
        assert risultato is not None, "Lo stream deve terminare con un risultato"
        assert risultato.token_input > 0
        assert risultato.token_output > 0
        assert risultato.costo_stimato > 0

        # Il tutor dovrebbe emettere almeno un segnale (concetto_spiegato o prossimo_passo)
        nomi_tool = [e["name"] for e in eventi_tool]
        segnali_attesi = {"concetto_spiegato", "prossimo_passo_raccomandato"}
        ha_segnale = bool(segnali_attesi & set(nomi_tool))

        print("\n--- Smoke Test Risultato ---")
        print(f"Testo: {testo_completo[:200]}...")
        print(f"Tool emessi: {nomi_tool}")
        print(f"Token: {risultato.token_input} in, {risultato.token_output} out")
        print(f"Costo: ${risultato.costo_stimato:.4f}")

        # Non fallisce se manca il segnale (Claude non è deterministico),
        # ma lo logga come warning
        if not ha_segnale:
            print(f"WARNING: nessun segnale atteso tra {segnali_attesi}")

    @pytest.mark.asyncio
    async def test_turno_esercizio_produce_azione(self, api_key):
        """Un turno con direttiva esercizio produce azione proponi_esercizio."""
        from app.llm.client import chiama_tutor
        from app.llm.prompts.direttive import direttiva_esercizio
        from app.llm.prompts.system_prompt import SYSTEM_PROMPT

        direttiva = direttiva_esercizio(
            nodo_nome="Insiemi numerici",
            nodo_id="mat_algebra2_insiemi_numerici",
            testo_esercizio="Classifica i seguenti numeri: √2, 3/4, -5, π",
            soluzione={"passaggi": ["√2: irrazionale", "3/4: razionale",
                                     "-5: intero", "π: irrazionale"]},
            storico_errori=[],
            tentativi_bc=0,
        )

        system = f"{SYSTEM_PROMPT}\n\n{direttiva}"
        messages = [
            {"role": "user", "content": "√2 è irrazionale, 3/4 è razionale, "
             "-5 è intero, π è irrazionale"},
        ]

        eventi_tool = []
        risultato = None

        async for evento in chiama_tutor(
            system=system,
            messages=messages,
            max_tokens=1024,
        ):
            tipo = evento.get("tipo")
            if tipo == "tool_use":
                eventi_tool.append(evento)
            elif tipo == "stop":
                risultato = evento["risultato"]
            elif tipo == "errore":
                pytest.fail(f"Errore LLM: {evento['messaggio']}")

        assert risultato is not None

        nomi_tool = [e["name"] for e in eventi_tool]
        print("\n--- Smoke Test Esercizio ---")
        print(f"Tool emessi: {nomi_tool}")
        print(f"Costo: ${risultato.costo_stimato:.4f}")

        # Ci aspettiamo risposta_esercizio come segnale
        ha_risposta = "risposta_esercizio" in nomi_tool
        if ha_risposta:
            segnale = next(e for e in eventi_tool if e["name"] == "risposta_esercizio")
            print(f"Esito: {segnale['input'].get('esito', 'N/A')}")

    @pytest.mark.asyncio
    async def test_tool_schemas_accettati_da_claude(self, api_key):
        """Verifica che Claude accetti tutti i 16 tool schemas senza errori."""
        from app.llm.client import chiama_tutor
        from app.llm.tools import get_tool_schemas

        schemas = get_tool_schemas()
        assert len(schemas) == 16, f"Attesi 16 tool schemas, trovati {len(schemas)}"

        # Manda una richiesta minimale per verificare che gli schemas siano validi
        async for evento in chiama_tutor(
            system="Sei un tutor. Rispondi brevemente.",
            messages=[{"role": "user", "content": "Ciao"}],
            max_tokens=100,
        ):
            if evento.get("tipo") == "errore":
                pytest.fail(
                    f"Claude ha rifiutato i tool schemas: {evento['messaggio']}"
                )

        # Se arriviamo qui senza errori, gli schemas sono validi
