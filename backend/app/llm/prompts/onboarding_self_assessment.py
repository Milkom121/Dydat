"""Prompt per la fase di auto-valutazione del placement onboarding.

Dopo la fase narrativa (Forma C), il tutor chiede all'utente come si sente
su ciascuna area chiave della materia: forte / incerto / digiuno.
Le aree vengono selezionate dal grafo curriculum (temi).

Riferimento: docs/discussions/b39-onboarding-narrativo.md, Decisione 8.
"""

# Livelli di auto-valutazione — usati dal prompt, dal parser e dai test
LIVELLI_AUTOVALUTAZIONE = ("forte", "incerto", "digiuno")

# Istruzioni chiave che devono essere presenti nel prompt (usate dai test)
ISTRUZIONI_CHIAVE = [
    "forte",
    "incerto",
    "digiuno",
    "non è un test",
    "capire da che punto partire",
]

# Numero massimo di aree da presentare all'utente
MAX_AREE_AUTOVALUTAZIONE = 10


def build_self_assessment_prompt(
    aree: list[dict[str, str]],
    nome_utente: str | None = None,
) -> str:
    """Costruisce il prompt per la fase di auto-valutazione del placement.

    Il prompt istruisce il tutor a chiedere all'utente, per ciascuna area,
    se si sente forte, incerto o digiuno. Il tono è rassicurante e non
    giudicante — non è un esame, è per calibrare il percorso.

    Args:
        aree: lista di dict con chiavi 'id' e 'nome' (es. [{"id": "frazioni", "nome": "Frazioni"}]).
              Vengono dal grafo curriculum (temi o raggruppamenti di nodi).
        nome_utente: nome dell'utente se disponibile, per personalizzare il tono.

    Returns:
        Il prompt da iniettare nel system prompt o come direttiva per il tutor.
    """
    if not aree:
        return _prompt_nessuna_area()

    # Limita il numero di aree per non sovraccaricare l'utente
    aree_da_chiedere = aree[:MAX_AREE_AUTOVALUTAZIONE]

    lista_aree = "\n".join(
        f"- {area['nome']}" for area in aree_da_chiedere
    )

    saluto = f" {nome_utente}" if nome_utente else ""

    return f"""\
## FASE AUTO-VALUTAZIONE

Ora passi alla fase di auto-valutazione. Il tuo obiettivo è capire il livello \
di partenza dell'utente{saluto} su ciascuna area della materia, per calibrare \
il percorso di studio.

### TONO E APPROCCIO

- Questo NON è un test e non è un esame. Dillo esplicitamente all'utente.
- È solo per capire da che punto partire insieme.
- Tono rassicurante: non esiste una risposta sbagliata, l'onestà aiuta.
- Non giudicare mai le risposte ("digiuno" è perfettamente ok).
- Raggruppa 2-3 aree per messaggio per non annoiare con domande singole.
- Se l'utente risponde in modo ambiguo, chiedi un chiarimento gentile.

### LIVELLI DI AUTO-VALUTAZIONE

Per ogni area, l'utente deve scegliere tra:
- **forte**: "me la cavo bene, l'ho studiato e lo ricordo"
- **incerto**: "l'ho visto ma non sono sicuro di ricordarlo bene"
- **digiuno**: "non l'ho mai fatto o non ricordo nulla"

### AREE DA CHIEDERE

Chiedi all'utente come si sente su ciascuna di queste aree:

{lista_aree}

### COME PROCEDERE

1. Introduci la fase con una frase tipo: "Ora ti faccio una cosa veloce: \
ti leggo alcune aree, per ciascuna dimmi se ti senti forte, incerto, \
o completamente a digiuno. Non è un test, è solo per capire da che punto partire."
2. Presenta le aree raggruppate (2-3 alla volta), con tono conversazionale.
3. Registra mentalmente la risposta per ogni area.
4. Quando hai raccolto tutte le risposte, conferma brevemente il quadro \
e passa alla fase successiva (verifica delle aree dichiarate forti).

### FORMATO RISPOSTA ATTESO

Dopo aver raccolto tutte le auto-valutazioni, includi nel tuo messaggio \
un blocco strutturato (invisibile all'utente, per il sistema) con il formato:

[AUTOVALUTAZIONE]
area_id: livello
area_id: livello
...
[/AUTOVALUTAZIONE]

Dove area_id è l'identificativo dell'area e livello è uno tra: forte, incerto, digiuno.

Gli area_id validi sono:
{_formatta_area_ids(aree_da_chiedere)}

### IMPORTANTE

- NON saltare nessuna area.
- Se l'utente vuole saltare l'auto-valutazione, rispetta la scelta e chiudi.
- Se l'utente raggruppa le risposte ("sono digiuno su tutto"), accetta e registra."""


def _prompt_nessuna_area() -> str:
    """Fallback se non ci sono aree da chiedere (grafo vuoto o errore)."""
    return """\
## FASE AUTO-VALUTAZIONE

Non ci sono aree specifiche da valutare per questa materia. \
Passa direttamente alla fase successiva comunicando all'utente \
che il percorso verrà calibrato durante le prime sessioni di studio."""


def _formatta_area_ids(aree: list[dict[str, str]]) -> str:
    """Formatta gli area_id per il blocco strutturato."""
    return "\n".join(f"- {area['id']}" for area in aree)


def parse_autovalutazione(testo_tutor: str) -> dict[str, str]:
    """Parsa il blocco [AUTOVALUTAZIONE] dal messaggio del tutor.

    Estrae la mappa {area_id: livello} dal blocco strutturato.
    Livelli non validi vengono ignorati.

    Args:
        testo_tutor: il testo completo del messaggio del tutor.

    Returns:
        dict {area_id: livello} con solo livelli validi.
        Dict vuoto se il blocco non è presente o malformato.
    """
    # Cerca il blocco tra i marker
    marker_inizio = "[AUTOVALUTAZIONE]"
    marker_fine = "[/AUTOVALUTAZIONE]"

    idx_inizio = testo_tutor.find(marker_inizio)
    if idx_inizio == -1:
        return {}

    idx_fine = testo_tutor.find(marker_fine, idx_inizio)
    if idx_fine == -1:
        return {}

    blocco = testo_tutor[idx_inizio + len(marker_inizio):idx_fine].strip()
    if not blocco:
        return {}

    risultato: dict[str, str] = {}
    for riga in blocco.splitlines():
        riga = riga.strip()
        if not riga or ":" not in riga:
            continue
        parti = riga.split(":", 1)
        area_id = parti[0].strip()
        livello = parti[1].strip().lower()
        if livello in LIVELLI_AUTOVALUTAZIONE:
            risultato[area_id] = livello

    return risultato


def seleziona_aree_da_grafo(
    grafo_nodi: list[dict],
) -> list[dict[str, str]]:
    """Seleziona le aree (temi) dal grafo per l'auto-valutazione.

    Prende la lista di nodi del grafo raggruppati per tema e restituisce
    le aree uniche ordinate per numero di nodi (le più grandi prima,
    perché sono le più importanti nel curriculum).

    Args:
        grafo_nodi: lista di dict con almeno 'tema_id' e 'tema_nome'.
                    Tipicamente dal GrafoKnowledge.

    Returns:
        Lista di dict [{"id": tema_id, "nome": tema_nome_umanizzato}]
        limitata a MAX_AREE_AUTOVALUTAZIONE.
    """
    # Conta nodi per tema per ordinare per importanza
    temi_conteggio: dict[str, int] = {}
    temi_nomi: dict[str, str] = {}

    for nodo in grafo_nodi:
        tema_id = nodo.get("tema_id")
        tema_nome = nodo.get("tema_nome")
        if not tema_id:
            continue
        temi_conteggio[tema_id] = temi_conteggio.get(tema_id, 0) + 1
        if tema_id not in temi_nomi and tema_nome:
            temi_nomi[tema_id] = tema_nome

    # Ordina per numero di nodi decrescente (aree più grandi = più importanti)
    temi_ordinati = sorted(
        temi_conteggio.keys(),
        key=lambda t: temi_conteggio[t],
        reverse=True,
    )

    aree = []
    for tema_id in temi_ordinati[:MAX_AREE_AUTOVALUTAZIONE]:
        nome = temi_nomi.get(tema_id, _umanizza_tema_id(tema_id))
        aree.append({"id": tema_id, "nome": nome})

    return aree


def _umanizza_tema_id(tema_id: str) -> str:
    """Converte un tema_id in nome leggibile (underscore -> spazi, capitalize)."""
    return tema_id.replace("_", " ").capitalize()
