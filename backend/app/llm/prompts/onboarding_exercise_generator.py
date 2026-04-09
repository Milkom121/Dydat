"""Prompt per la generazione di esercizi compound nel placement onboarding.

Dopo l'auto-valutazione, le aree dichiarate "forte" vengono verificate con
esercizi a scelta multipla. Ogni esercizio copre fino a 2 concetti (compound).
Il tutor Opus genera gli esercizi usando questo prompt.

Riferimento: docs/discussions/b39-onboarding-narrativo.md, Decisione 8.
"""

import json

# --- Costanti usate dal prompt, dalla funzione genera e dai test ---

# Cap massimo esercizi di verifica per l'intero placement
MAX_ESERCIZI_VERIFICA = 3

# Numero massimo di concetti coperti da un singolo esercizio compound
MAX_CONCETTI_PER_ESERCIZIO = 2

# Numero di opzioni di risposta
MIN_OPZIONI = 3
MAX_OPZIONI = 4

# Istruzioni chiave che devono essere presenti nel prompt (usate dai test)
ISTRUZIONI_CHIAVE = [
    "scelta multipla",
    "risposta corretta",
    "concetti",
    "JSON",
]

# Schema JSON dell'output atteso per un singolo esercizio
SCHEMA_ESERCIZIO_ESEMPIO = {
    "testo": "Se un rettangolo ha base 6 cm e altezza 4 cm, qual è il suo perimetro?",
    "concetti": ["perimetro", "rettangolo"],
    "opzioni": [
        {"lettera": "A", "testo": "20 cm"},
        {"lettera": "B", "testo": "24 cm"},
        {"lettera": "C", "testo": "10 cm"},
        {"lettera": "D", "testo": "48 cm"},
    ],
    "risposta_corretta": "A",
    "spiegazione_breve": "Il perimetro è 2*(base+altezza) = 2*(6+4) = 20 cm.",
}

# Schema JSON dell'output atteso (lista di esercizi)
SCHEMA_OUTPUT_ESEMPIO = [SCHEMA_ESERCIZIO_ESEMPIO]


def build_exercise_prompt(
    coppie_concetti: list[list[str]],
    nomi_concetti: dict[str, str] | None = None,
) -> str:
    """Costruisce il prompt per generare esercizi compound di verifica.

    Ogni coppia di concetti diventa un esercizio a scelta multipla.
    Se una coppia ha un solo concetto, l'esercizio copre solo quello.

    Args:
        coppie_concetti: lista di liste di concept_id. Ogni sotto-lista
                         contiene 1 o 2 concept_id da coprire con un esercizio.
                         Es. [["frazioni", "proporzioni"], ["equazioni_primo_grado"]]
        nomi_concetti: dict opzionale {concept_id: nome_leggibile}.
                       Se non fornito, si usa il concept_id umanizzato.

    Returns:
        Il prompt da passare come user message a Opus.
    """
    if not coppie_concetti:
        return _prompt_nessun_esercizio()

    # Limita al cap
    coppie = coppie_concetti[:MAX_ESERCIZI_VERIFICA]
    nomi = nomi_concetti or {}

    blocchi_esercizi = []
    for i, coppia in enumerate(coppie, 1):
        concetti_nomi = [
            nomi.get(c, _umanizza_id(c)) for c in coppia[:MAX_CONCETTI_PER_ESERCIZIO]
        ]
        concetti_ids = [c for c in coppia[:MAX_CONCETTI_PER_ESERCIZIO]]
        blocchi_esercizi.append(
            f"### Esercizio {i}\n"
            f"- Concetti da coprire: {', '.join(concetti_nomi)}\n"
            f"- ID concetti: {json.dumps(concetti_ids, ensure_ascii=False)}"
        )

    lista_esercizi = "\n\n".join(blocchi_esercizi)
    schema_json = json.dumps(SCHEMA_OUTPUT_ESEMPIO, indent=2, ensure_ascii=False)

    return f"""\
Sei un generatore di esercizi per Dydat, un tutor AI adattivo.

## COMPITO

Genera {len(coppie)} esercizio/i a scelta multipla per verificare il livello di \
uno studente che ha dichiarato di sentirsi "forte" su alcune aree.

Ogni esercizio deve coprire i concetti indicati, combinandoli in un unico quesito \
quando sono 2 concetti (esercizio compound). L'obiettivo è verificare se lo \
studente padroneggia davvero quei concetti, senza essere un esame formale.

## REGOLE

- Ogni esercizio ha {MIN_OPZIONI}-{MAX_OPZIONI} opzioni di risposta (lettere A, B, C, D).
- Esattamente 1 risposta corretta per esercizio.
- Le opzioni sbagliate devono essere plausibili (errori comuni, non assurde).
- Il testo dell'esercizio deve essere chiaro, conciso, autosufficiente.
- Livello: adatto a chi dice di "saperlo fare" — non troppo facile, non troppo difficile.
- Se l'esercizio copre 2 concetti, il quesito deve richiedere entrambi per rispondere.
- La spiegazione_breve spiega la risposta corretta in 1-2 frasi.
- Lingua: italiano.

## ESERCIZI DA GENERARE

{lista_esercizi}

## FORMATO OUTPUT

Rispondi ESCLUSIVAMENTE con un array JSON valido, senza testo prima o dopo.
Nessun commento, nessuna spiegazione, nessun markdown. Solo il JSON.

Ogni elemento dell'array ha questa struttura:

{schema_json}

Dove:
- "testo": il testo del quesito
- "concetti": array con gli ID dei concetti coperti (1 o 2, come indicato sopra)
- "opzioni": array di {MIN_OPZIONI}-{MAX_OPZIONI} oggetti con "lettera" e "testo"
- "risposta_corretta": la lettera della risposta corretta (es. "A")
- "spiegazione_breve": spiegazione della risposta corretta in 1-2 frasi

## IMPORTANTE

- L'array deve contenere esattamente {len(coppie)} esercizio/i.
- Ogni esercizio deve usare gli ID concetti esatti indicati nel campo "concetti".
- NON aggiungere concetti extra oltre a quelli richiesti.
- Le opzioni devono avere lettere consecutive (A, B, C oppure A, B, C, D).
- La risposta_corretta deve corrispondere a una delle lettere nelle opzioni.

## OUTPUT JSON"""


def _prompt_nessun_esercizio() -> str:
    """Fallback se non ci sono coppie da verificare."""
    return """\
Nessun esercizio da generare. L'utente non ha dichiarato aree "forte" \
da verificare, oppure tutte le aree sono già confermate."""


def _umanizza_id(concept_id: str) -> str:
    """Converte un concept_id in nome leggibile."""
    return concept_id.replace("_", " ").capitalize()


def parse_exercise_response(testo_llm: str) -> list[dict] | None:
    """Parsa la risposta JSON di Opus con gli esercizi generati.

    Tenta di estrarre un array JSON dalla risposta.
    Gestisce il caso in cui la risposta sia wrappata in markdown (```json...```).

    Args:
        testo_llm: risposta grezza di Opus.

    Returns:
        Lista di dict con gli esercizi, o None se il parsing fallisce.
    """
    if not testo_llm or not testo_llm.strip():
        return None

    testo = testo_llm.strip()

    # Rimuovi eventuale wrapper markdown
    if testo.startswith("```"):
        # Cerca la prima riga dopo ```json o ```
        primo_newline = testo.find("\n")
        if primo_newline != -1:
            testo = testo[primo_newline + 1:]
        # Rimuovi ``` finale
        if testo.rstrip().endswith("```"):
            testo = testo.rstrip()[:-3].rstrip()

    try:
        risultato = json.loads(testo)
    except json.JSONDecodeError:
        return None

    if not isinstance(risultato, list):
        return None

    # Validazione base di ogni esercizio
    esercizi_validi = []
    for ex in risultato:
        if not isinstance(ex, dict):
            continue
        # Campi obbligatori
        if not all(k in ex for k in ("testo", "concetti", "opzioni", "risposta_corretta")):
            continue
        if not isinstance(ex["concetti"], list) or len(ex["concetti"]) == 0:
            continue
        if not isinstance(ex["opzioni"], list) or len(ex["opzioni"]) < MIN_OPZIONI:
            continue
        # Verifica che risposta_corretta sia tra le lettere
        lettere_opzioni = {
            o.get("lettera") for o in ex["opzioni"] if isinstance(o, dict)
        }
        if ex["risposta_corretta"] not in lettere_opzioni:
            continue
        esercizi_validi.append(ex)

    return esercizi_validi if esercizi_validi else None
