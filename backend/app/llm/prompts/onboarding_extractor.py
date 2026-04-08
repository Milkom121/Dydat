"""Prompt per l'estrattore profilo onboarding.

Dopo ogni turno utente nell'onboarding, il backend chiama Opus con questo prompt
per estrarre i 5 campi del profilo dalla conversazione. Output: JSON strutturato
con valore + confidenza per ogni campo.

Riferimento: docs/discussions/b39-onboarding-narrativo.md, Decisione 2 e 9.
"""

# I 5 campi del profilo e le relative descrizioni, riutilizzabili dai test
# e dal decisore forma C (B39.3.1)
CAMPI_PROFILO = {
    "chi_e": "Identità in una frase (età, ruolo, situazione di vita)",
    "motivo": "Perché studia, motivazione in linguaggio naturale",
    "stile_cognitivo": "Come preferisce apprendere (esempi concreti, regole astratte, mix)",
    "tempo_disponibile": "Quanto tempo può dedicare tipicamente a Dydat",
    "vissuto_scolastico": "Relazione emotiva con la materia in passato",
}

CONFIDENZE_VALIDE = ("alta", "media", "bassa")

# Schema JSON atteso dall'estrattore — usato nel prompt e nei test di contract
SCHEMA_OUTPUT_ESEMPIO = """{
  "chi_e": {
    "valore": "adulto di 42 anni, grafico freelance",
    "confidenza": "alta"
  },
  "motivo": {
    "valore": "curiosità personale, vuole riprovare la matematica da adulto",
    "confidenza": "alta"
  },
  "stile_cognitivo": {
    "valore": "esempi concreti prima delle regole, le regole astratte lo mandano in confusione",
    "confidenza": "alta"
  },
  "tempo_disponibile": {
    "valore": "15-20 minuti ogni sera dopo il lavoro",
    "confidenza": "alta"
  },
  "vissuto_scolastico": {
    "valore": "ha odiato la matematica alle superiori, ora vuole riprovare",
    "confidenza": "alta"
  }
}"""

# Esempio di output con campi mancanti (utente taciturno)
SCHEMA_OUTPUT_PARZIALE = """{
  "chi_e": {
    "valore": "studente",
    "confidenza": "bassa"
  },
  "motivo": {
    "valore": null,
    "confidenza": "bassa"
  },
  "stile_cognitivo": {
    "valore": null,
    "confidenza": "bassa"
  },
  "tempo_disponibile": {
    "valore": null,
    "confidenza": "bassa"
  },
  "vissuto_scolastico": {
    "valore": null,
    "confidenza": "bassa"
  }
}"""


def build_extractor_prompt(conversazione: list[dict]) -> str:
    """Costruisce il prompt completo per l'estrattore profilo.

    Args:
        conversazione: lista di messaggi [{role: "user"|"assistant", content: str}]

    Returns:
        Il prompt completo da passare come user message a Opus.
    """
    # Formatta la conversazione in blocco leggibile
    turni_formattati = _formatta_conversazione(conversazione)

    return f"""\
Sei un estrattore di profilo per Dydat, un tutor AI adattivo.

## COMPITO

Leggi la conversazione di onboarding qui sotto tra il tutor e un nuovo utente.
Estrai le informazioni sul profilo dell'utente organizzate nei 5 campi seguenti.
Per ogni campo, fornisci il valore estratto e una confidenza sulla qualità dell'informazione.

## I 5 CAMPI DA ESTRARRE

1. **chi_e** — {CAMPI_PROFILO["chi_e"]}
2. **motivo** — {CAMPI_PROFILO["motivo"]}
3. **stile_cognitivo** — {CAMPI_PROFILO["stile_cognitivo"]}
4. **tempo_disponibile** — {CAMPI_PROFILO["tempo_disponibile"]}
5. **vissuto_scolastico** — {CAMPI_PROFILO["vissuto_scolastico"]}

## REGOLE DI CONFIDENZA

- **alta**: l'utente ha detto qualcosa di chiaro e specifico su questo campo. \
Il valore estratto è ricco e utilizzabile per personalizzare il tutor.
- **media**: l'utente ha accennato qualcosa ma in modo vago o incompleto. \
Il valore è un'inferenza ragionevole ma potrebbe essere imprecisa.
- **bassa**: l'utente non ha detto nulla su questo campo, o ha dato una risposta \
troppo generica per essere utile (es. "matematica" come motivo). \
Risposte di una sola parola senza contesto sono sempre bassa confidenza.

## REGOLE DI ESTRAZIONE

- Estrai SOLO informazioni dette esplicitamente dall'utente. Non inventare.
- Se l'utente non ha menzionato un campo, metti valore null e confidenza "bassa".
- Il valore deve essere una frase in linguaggio naturale, NON una parola singola.
- Per chi_e: includi età, ruolo, situazione se disponibili.
- Per motivo: distingui tra "curiosità", "esame", "lavoro", "recupero", etc.
- Per stile_cognitivo: cerca preferenze esplicite (esempi vs regole, pratica vs teoria).
- Per tempo_disponibile: cerca indicazioni temporali specifiche.
- Per vissuto_scolastico: cerca emozioni, esperienze passate, relazione con la materia.
- Se un messaggio copre più campi, estraili tutti.
- Non confondere le parole del tutor con quelle dell'utente.

## FORMATO OUTPUT

Rispondi ESCLUSIVAMENTE con un oggetto JSON valido, senza testo prima o dopo.
Nessun commento, nessuna spiegazione, nessun markdown. Solo il JSON.

I 5 campi devono essere SEMPRE presenti nell'output, anche se il valore è null.
Le confidenze ammesse sono SOLO: "alta", "media", "bassa".

Esempio di output completo (utente collaborativo):
{SCHEMA_OUTPUT_ESEMPIO}

Esempio di output parziale (utente taciturno, primo turno):
{SCHEMA_OUTPUT_PARZIALE}

## CONVERSAZIONE DA ANALIZZARE

{turni_formattati}

## OUTPUT JSON"""


def _formatta_conversazione(conversazione: list[dict]) -> str:
    """Formatta la lista di messaggi in testo leggibile per il prompt."""
    if not conversazione:
        return "(conversazione vuota)"

    righe = []
    for msg in conversazione:
        role = msg.get("role", "unknown")
        content = msg.get("content", "")
        if role == "user":
            righe.append(f"UTENTE: {content}")
        elif role == "assistant":
            righe.append(f"TUTOR: {content}")
        else:
            righe.append(f"{role.upper()}: {content}")
    return "\n".join(righe)
