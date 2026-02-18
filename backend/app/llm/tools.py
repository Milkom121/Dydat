"""Schema completo azioni + segnali per Claude API tool use.

Le azioni vanno al frontend via SSE.
I segnali si accumulano per post-processing.
"""

# ---------------------------------------------------------------------------
# Azioni — visibili allo studente (inviate via SSE al frontend)
# ---------------------------------------------------------------------------

AZIONI_LOOP_1: list[dict] = [
    {
        "name": "proponi_esercizio",
        "description": (
            "Proponi un esercizio allo studente dal banco dati. "
            "L'esercizio viene selezionato dal backend in base a nodo e difficoltà. "
            "NON inventare esercizi — usa sempre questa azione."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "nodo_id": {
                    "type": "string",
                    "description": "ID del nodo focale per l'esercizio.",
                },
                "difficolta": {
                    "type": "string",
                    "enum": ["base", "intermedio", "avanzato"],
                    "description": "Livello di difficoltà desiderato.",
                },
                "evita_ids": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "ID di esercizi già proposti da evitare.",
                },
            },
            "required": ["nodo_id"],
        },
    },
    {
        "name": "mostra_formula",
        "description": (
            "Mostra una formula matematica allo studente"
            " (rendering LaTeX nel frontend)."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "latex": {
                    "type": "string",
                    "description": "Espressione LaTeX da visualizzare.",
                },
                "etichetta": {
                    "type": "string",
                    "description": "Etichetta opzionale per la formula.",
                },
            },
            "required": ["latex"],
        },
    },
    {
        "name": "suggerisci_backtrack",
        "description": (
            "Suggerisci allo studente di tornare a rivedere un concetto prerequisito."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "nodo_id": {
                    "type": "string",
                    "description": "ID del nodo a cui tornare.",
                },
                "motivo": {
                    "type": "string",
                    "description": "Spiegazione del perché tornare a questo concetto.",
                },
            },
            "required": ["nodo_id", "motivo"],
        },
    },
    {
        "name": "chiudi_sessione",
        "description": "Chiudi la sessione di studio corrente.",
        "input_schema": {
            "type": "object",
            "properties": {
                "riepilogo": {
                    "type": "string",
                    "description": "Riepilogo di cosa è stato fatto nella sessione.",
                },
                "prossimi_passi": {
                    "type": "string",
                    "description": "Suggerimenti per la prossima sessione.",
                },
            },
            "required": ["riepilogo"],
        },
    },
    {
        "name": "onboarding_domanda",
        "description": (
            "SOLO DURANTE ONBOARDING. Presenta una domanda allo studente "
            "con un formato UI specifico. Usa questa azione per OGNI domanda "
            "durante l'onboarding. Il testo descrittivo va nel messaggio "
            "testuale, la domanda strutturata va qui."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "tipo_input": {
                    "type": "string",
                    "enum": ["scelta_singola", "testo_libero", "scala"],
                    "description": (
                        "Tipo di interfaccia: scelta_singola (card cliccabili), "
                        "testo_libero (campo di testo aperto), "
                        "scala (valore numerico con etichette)."
                    ),
                },
                "domanda": {
                    "type": "string",
                    "description": "Il testo della domanda da mostrare.",
                },
                "opzioni": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Opzioni per scelta_singola (2-5 opzioni).",
                },
                "placeholder": {
                    "type": "string",
                    "description": "Placeholder per testo_libero.",
                },
                "scala_min": {
                    "type": "integer",
                    "description": "Valore minimo della scala (default 1).",
                },
                "scala_max": {
                    "type": "integer",
                    "description": "Valore massimo della scala (default 5).",
                },
                "scala_labels": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Etichette per i due estremi [min_label, max_label].",
                },
            },
            "required": ["tipo_input", "domanda"],
        },
    },
]

AZIONI_LOOP_2_3: list[dict] = [
    {
        "name": "mostra_visualizzazione",
        "description": (
            "[NON ANCORA ATTIVO] Mostra una visualizzazione interattiva "
            "(grafico, piano cartesiano, ecc.)."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "tipo": {
                    "type": "string",
                    "enum": [
                        "plotter_funzione",
                        "piano_cartesiano",
                        "grafico_barre",
                        "diagramma_venn",
                    ],
                    "description": "Tipo di visualizzazione.",
                },
                "parametri": {
                    "type": "object",
                    "description": "Parametri specifici della visualizzazione.",
                },
                "istruzioni": {
                    "type": "string",
                    "description": "Istruzioni per lo studente sulla visualizzazione.",
                },
            },
            "required": ["tipo"],
        },
    },
    {
        "name": "avvia_feynman",
        "description": (
            "[NON ANCORA ATTIVO] Avvia una verifica Feynman: "
            "lo studente spiega il concetto come se lo insegnasse."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "nodo_id": {
                    "type": "string",
                    "description": "ID del nodo da verificare.",
                },
                "punti_chiave": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Punti chiave che la spiegazione dovrebbe coprire.",
                },
            },
            "required": ["nodo_id", "punti_chiave"],
        },
    },
    {
        "name": "mostra_connessione",
        "description": (
            "[NON ANCORA ATTIVO] Mostra una connessione tra due concetti."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "nodo_a": {"type": "string"},
                "nodo_b": {"type": "string"},
                "tipo_connessione": {
                    "type": "string",
                    "enum": ["applicazione", "evoluzione", "analogia", "fondamento"],
                },
                "spiegazione": {"type": "string"},
            },
            "required": ["nodo_a", "nodo_b"],
        },
    },
    {
        "name": "mostra_percorso",
        "description": (
            "[NON ANCORA ATTIVO] Mostra una mappa del percorso di apprendimento."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "nodi": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Lista ordinata di nodi nel percorso.",
                },
                "obiettivo": {
                    "type": "string",
                    "description": "Descrizione dell'obiettivo del percorso.",
                },
                "stima_tempo": {
                    "type": "string",
                    "description": "Stima del tempo necessario.",
                },
            },
            "required": ["nodi", "obiettivo"],
        },
    },
]

# ---------------------------------------------------------------------------
# Segnali — invisibili allo studente (post-processing server-side)
# ---------------------------------------------------------------------------

SEGNALI_LOOP_1: list[dict] = [
    {
        "name": "concetto_spiegato",
        "description": (
            "SEGNALE INTERNO (invisibile allo studente). "
            "Emetti quando hai completato la spiegazione di un concetto. "
            "Il sistema aggiorna lo stato del nodo."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "nodo_id": {
                    "type": "string",
                    "description": "ID del nodo spiegato.",
                },
                "punti_coperti": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Punti chiave coperti nella spiegazione.",
                },
                "livello_dettaglio": {
                    "type": "string",
                    "enum": ["introduttivo", "completo", "approfondito"],
                    "description": "Livello di dettaglio della spiegazione.",
                },
            },
            "required": ["nodo_id", "punti_coperti"],
        },
    },
    {
        "name": "risposta_esercizio",
        "description": (
            "SEGNALE INTERNO (invisibile allo studente). "
            "Emetti dopo aver valutato la risposta dello studente a un esercizio."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "esercizio_id": {
                    "type": "string",
                    "description": "ID dell'esercizio valutato.",
                },
                "nodo_focale": {
                    "type": "string",
                    "description": "ID del nodo focale dell'esercizio.",
                },
                "esito": {
                    "type": "string",
                    "enum": ["primo_tentativo", "con_guida", "non_risolto"],
                    "description": "Esito della valutazione.",
                },
                "nodi_coinvolti": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Nodi coinvolti nella risoluzione.",
                },
                "nodo_causa": {
                    "type": "string",
                    "description": "Nodo causa dell'errore, se identificabile.",
                },
                "tipo_errore": {
                    "type": "string",
                    "description": "Tipo di errore commesso.",
                },
            },
            "required": ["esercizio_id", "nodo_focale", "esito"],
        },
    },
    {
        "name": "confusione_rilevata",
        "description": (
            "SEGNALE INTERNO. "
            "Emetti quando rilevi che lo studente è confuso su un concetto."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "nodo_id": {
                    "type": "string",
                    "description": "Nodo principale fonte di confusione.",
                },
                "nodi_coinvolti": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Altri nodi eventualmente coinvolti.",
                },
                "descrizione": {
                    "type": "string",
                    "description": "Descrizione della confusione rilevata.",
                },
                "severita": {
                    "type": "string",
                    "enum": ["lieve", "moderata", "significativa"],
                    "description": "Gravità della confusione.",
                },
            },
            "required": ["nodo_id", "descrizione"],
        },
    },
    {
        "name": "energia_utente",
        "description": (
            "SEGNALE INTERNO. "
            "Emetti per segnalare il livello di energia/motivazione dello studente."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "livello": {
                    "type": "string",
                    "enum": ["alta", "normale", "bassa", "frustrazione"],
                    "description": "Livello di energia percepito.",
                },
                "segnali": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Segnali osservati che indicano il livello.",
                },
                "suggerimento": {
                    "type": "string",
                    "description": "Azione suggerita (es. pausa, cambio attività).",
                },
            },
            "required": ["livello"],
        },
    },
    {
        "name": "prossimo_passo_raccomandato",
        "description": (
            "SEGNALE INTERNO. "
            "Emetti per raccomandare cosa fare nel prossimo turno."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "tipo": {
                    "type": "string",
                    "enum": [
                        "continua_spiegazione",
                        "esercizio",
                        "feynman",
                        "ripasso",
                        "backtrack",
                        "pausa",
                        "chiudi_sessione",
                        "cambio_materia",
                    ],
                    "description": "Tipo di attività raccomandata.",
                },
                "nodo_id": {
                    "type": "string",
                    "description": "Nodo di riferimento, se applicabile.",
                },
                "motivazione": {
                    "type": "string",
                    "description": "Perché raccomandi questa attività.",
                },
            },
            "required": ["tipo"],
        },
    },
    {
        "name": "punto_partenza_suggerito",
        "description": (
            "SEGNALE INTERNO (solo onboarding). "
            "Emetti quando lo studente indica da dove vuole partire. "
            "Il backend cercherà il tema/nodo più vicino nel grafo."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "tema_o_concetto": {
                    "type": "string",
                    "description": "Tema o concetto indicato dallo studente.",
                },
                "motivazione": {
                    "type": "string",
                    "description": "Perché lo studente vuole partire da qui.",
                },
            },
            "required": ["tema_o_concetto"],
        },
    },
]

SEGNALI_LOOP_3: list[dict] = [
    {
        "name": "valutazione_feynman",
        "description": (
            "SEGNALE INTERNO [NON ANCORA ATTIVO]. "
            "Emetti dopo aver valutato una spiegazione Feynman dello studente."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "nodo_id": {"type": "string"},
                "esito": {
                    "type": "string",
                    "enum": ["positivo", "parziale", "insufficiente"],
                },
                "punti_coperti": {
                    "type": "array",
                    "items": {"type": "string"},
                },
                "lacune": {
                    "type": "array",
                    "items": {"type": "string"},
                },
                "note": {"type": "string"},
            },
            "required": ["nodo_id", "esito"],
        },
    },
    {
        "name": "connessione_seminata",
        "description": (
            "SEGNALE INTERNO [NON ANCORA ATTIVO]. "
            "Emetti quando semini una connessione tra concetti."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "nodo_a": {"type": "string"},
                "nodo_b": {"type": "string"},
                "tipo": {
                    "type": "string",
                    "enum": ["applicazione", "evoluzione", "analogia", "fondamento"],
                },
                "reazione_studente": {
                    "type": "string",
                    "enum": ["interessato", "neutro", "non_colto"],
                },
            },
            "required": ["nodo_a", "nodo_b"],
        },
    },
]

# ---------------------------------------------------------------------------
# Nomi azioni vs segnali (per discriminare in fase di parsing)
# ---------------------------------------------------------------------------

NOMI_AZIONI: frozenset[str] = frozenset(
    t["name"] for t in AZIONI_LOOP_1 + AZIONI_LOOP_2_3
)

NOMI_SEGNALI: frozenset[str] = frozenset(
    t["name"] for t in SEGNALI_LOOP_1 + SEGNALI_LOOP_3
)


def get_tool_schemas() -> list[dict]:
    """Ritorna gli schema dei tool (azioni + segnali) per messages.create()."""
    return AZIONI_LOOP_1 + AZIONI_LOOP_2_3 + SEGNALI_LOOP_1 + SEGNALI_LOOP_3


def is_azione(tool_name: str) -> bool:
    """True se il tool è un'azione (da inoltrare al frontend via SSE)."""
    return tool_name in NOMI_AZIONI


def is_segnale(tool_name: str) -> bool:
    """True se il tool è un segnale (da accumulare per post-processing)."""
    return tool_name in NOMI_SEGNALI
