"""Template direttive — Blocco 2 del context package.

La direttiva descrive la situazione corrente e guida il tutor.
Ogni funzione riceve dati strutturati e ritorna il testo della direttiva.
"""

from __future__ import annotations

import json
from typing import Any


def _formatta_json(data: Any) -> str:
    """Formatta JSONB in stringa leggibile, o stringa vuota se None."""
    if data is None:
        return "(non disponibile)"
    if isinstance(data, str):
        return data
    return json.dumps(data, ensure_ascii=False, indent=2)


def _formatta_lista(items: list | None) -> str:
    if not items:
        return "(nessuno)"
    return "\n".join(f"- {item}" for item in items)


def _preambolo_caldo(
    nome_utente: str,
    profilo_sintetizzato: dict | None = None,
    ritmo_minuti: int | None = None,
) -> str:
    """Genera istruzioni di prompt per un saluto caldo e contestualizzato.

    Il preambolo istruisce il tutor a comporre un'apertura a tre elementi:
    1. Saluto con nome
    2. Riconoscimento del profilo (parafrasato, mai verbatim)
    3. Citazione leggera del ritmo scelto

    Riutilizzabile da tutte le direttive di "primo momento".
    """
    righe = [
        f'Apri con un saluto caldo che usa il nome "{nome_utente}".',
    ]

    # Profilo: estrai i campi rilevanti e istruisci il tutor a parafrasarli
    if profilo_sintetizzato:
        chi_e = profilo_sintetizzato.get("chi_e")
        motivo = profilo_sintetizzato.get("motivo")
        stile = profilo_sintetizzato.get("stile_cognitivo")

        dettagli = []
        if chi_e:
            dettagli.append(chi_e)
        if motivo:
            dettagli.append(f"studia per {motivo}")
        if stile:
            dettagli.append(f"preferisce {stile}")

        if dettagli:
            info = " e ".join(dettagli)
            righe.append(
                f"Riconosci con UNA frase, parafrasata e naturale, "
                f"che {info} "
                f"(NON ripetere alla lettera il profilo, parafrasa con le tue parole)."
            )
    else:
        righe.append(
            "Non hai informazioni dettagliate sul profilo: "
            "limitati a un saluto caloroso e accogliente."
        )

    # Ritmo scelto
    if ritmo_minuti is not None:
        if ritmo_minuti <= 15:
            tempo_desc = "un quarto d'ora veloce"
        elif ritmo_minuti <= 30:
            tempo_desc = "una mezz'ora"
        else:
            tempo_desc = "un'ora"
        righe.append(
            f"Cita con leggerezza i ~{ritmo_minuti} minuti che avete insieme "
            f'("{tempo_desc}", "un po\' di tempo insieme", non come scadenza rigida).'
        )

    righe.append(
        "Il tono è caldo ma non smielato, professionale ma non freddo."
    )

    return "\n".join(righe)


def direttiva_spiegazione(
    *,
    nodo_nome: str,
    nodo_id: str,
    prerequisiti_completati: list[str],
    livello_materia: str,
    definizioni_formali: Any,
    formule_proprieta: Any,
    errori_comuni: Any,
    stile_cognitivo: str | None = None,
    esempi_preferiti: str | None = None,
    minuti_rimasti: int | None = None,
    nome_utente: str | None = None,
    nodo_presunto: bool = False,
    profilo_sintetizzato: dict | None = None,
    ritmo_minuti: int | None = None,
) -> str:
    """Direttiva per spiegazione di un concetto nuovo.

    Se nome_utente è fornito, genera un primo messaggio "caldo" a tre battute.
    Se nodo_presunto=True, il primo messaggio sarà di verifica veloce
    invece di spiegazione.
    """
    prereq_str = (
        ", ".join(prerequisiti_completati) if prerequisiti_completati else "nessuno"
    )
    stile = stile_cognitivo or "non specificato"
    esempi = esempi_preferiti or "non specificato"
    righe = [
        "ATTIVITÀ: Spiegazione nuovo concetto",
        f"NODO: {nodo_nome} ({nodo_id})",
        (
            f"STATO STUDENTE: Ha completato i prerequisiti {prereq_str}."
            f" Livello generale: {livello_materia}."
        ),
        "",
        "CONTENUTO FORMALE:",
        _formatta_json(definizioni_formali),
        _formatta_json(formule_proprieta),
        "",
        "ERRORI COMUNI DA PREVENIRE:",
        _formatta_json(errori_comuni),
        "",
        (
            f"PREFERENZE STUDENTE: {stile}."
            f" Preferisce esempi da: {esempi}."
        ),
        "",
    ]

    # Istruzioni primo turno: differenziate in base al contesto
    if nome_utente and nodo_presunto:
        # Nodo presunto padroneggiato: verifica veloce
        preambolo = _preambolo_caldo(nome_utente, profilo_sintetizzato, ritmo_minuti)
        righe.append(
            "ISTRUZIONI PRIMO TURNO (NODO PRESUNTO PADRONEGGIATO):\n"
            f"{preambolo}\n"
            f"Dopo il saluto, riconosci che dal test iniziale il nodo "
            f'"{nodo_nome}" risulta già familiare allo studente. '
            f"Proponi subito una domanda-sonda sul concetto chiave per "
            f"verificare se lo padroneggia davvero.\n"
            f"NON partire con la spiegazione: il primo messaggio è di "
            f"tipo verifica. Se l'utente risponde bene si va avanti, "
            f"se sbaglia scenderai in modalità spiegazione normale "
            f"(questo lo gestirai nei turni successivi).\n"
            "Tutto in UN SOLO messaggio, massimo 8-10 righe, "
            "tre paragrafi visivamente distinti."
        )
    elif nome_utente:
        # Nodo nuovo: presentazione calda con micro-indice
        preambolo = _preambolo_caldo(nome_utente, profilo_sintetizzato, ritmo_minuti)
        righe.append(
            "ISTRUZIONI PRIMO TURNO:\n"
            f"{preambolo}\n"
            f"Dopo il saluto, presenta il nodo \"{nodo_nome}\" con un "
            f"micro-indice DISCORSIVO (NON un elenco puntato): "
            f"\"Oggi vediamo X, prima Y, poi Z, e ci giochiamo un po'\". "
            f"Due o tre tappe, linguaggio colloquiale.\n"
            f"Chiudi con UNA domanda aperta di warm-up rispondibile "
            f"da chi non sa ancora niente del concetto.\n"
            "Tutto in UN SOLO messaggio con tre paragrafi visivamente "
            "distinti, massimo 8-10 righe. NON spiegare tutto subito. "
            "Il flusso Concreto → Problema → Formale si sviluppa "
            "su PIÙ turni.\n"
            "Al termine del percorso (non adesso), proponi un esercizio."
        )
    else:
        # Fallback: comportamento classico (senza nome utente)
        righe.append(
            "ISTRUZIONI:\n"
            "- Questo è il PRIMO turno: parti con un esempio concreto "
            "dalla vita reale (2-3 frasi) e chiudi con una domanda "
            "per coinvolgere lo studente.\n"
            "- NON spiegare tutto subito. Il flusso Concreto → Problema → "
            "Formale si sviluppa su PIÙ turni.\n"
            "- Massimo 4-5 righe per questo turno. Lo studente "
            "deve rispondere prima di proseguire.\n"
            "- Al termine del percorso (non adesso), proponi un esercizio."
        )

    if minuti_rimasti is not None:
        righe.append(f"\nTEMPO RIMASTO: {minuti_rimasti} minuti.")

    return "\n".join(righe)


def direttiva_esercizio(
    *,
    nodo_nome: str,
    esercizio_testo: str,
    soluzione: dict | None = None,
    errori_comuni_attesi: Any = None,
    risposta_studente: str | None = None,
    numero_tentativo: int = 1,
    tentativi_bc: int = 0,
    storico_errori: list[str] | None = None,
    prerequisito_debole: str | None = None,
) -> str:
    """Direttiva per esercizio in corso."""
    righe = [
        "ATTIVITÀ: Esercizio",
        f"NODO FOCALE: {nodo_nome}",
        f"ESERCIZIO: {esercizio_testo}",
        "",
    ]

    if soluzione and soluzione.get("risposta_finale"):
        righe.append(f"SOLUZIONE CORRETTA (verificata CAS): {soluzione['risposta_finale']}")
        if soluzione.get("passaggi"):
            righe.append(f"PASSAGGI: {_formatta_json(soluzione['passaggi'])}")
    else:
        righe.extend([
            "SOLUZIONE PRE-COMPUTATA: non disponibile.",
            "Risolvi tu l'esercizio e valuta la risposta dello studente.",
            "Se non sei sicuro, dillo e verifica insieme passo per passo.",
        ])

    righe.extend([
        "",
        f"ERRORI COMUNI ATTESI: {_formatta_json(errori_comuni_attesi)}",
        "",
        "STATO:",
        f"- Risposta studente: {risposta_studente or '(in attesa)'}",
        f"- Tentativo: {numero_tentativo}",
        f"- Tentativi B+C precedenti: {tentativi_bc}",
        "",
        f"STORICO ERRORI STUDENTE SU QUESTO NODO: {_formatta_lista(storico_errori)}",
        "",
        "ISTRUZIONI:",
        (
            "- Se risposta corretta: conferma, celebra brevemente,"
            " emetti segnale risposta_esercizio con esito=primo_tentativo"
        ),
        "- Se primo errore: attiva B+C. NON dare la risposta. Fai domanda sul punto di rottura.",
        "- Se 2-3° tentativo B+C: hint più espliciti",
    ])

    if prerequisito_debole:
        righe.append(
            f"- Se dopo 3 tentativi: spiega l'errore, proponi backtrack a {prerequisito_debole}"
        )
    else:
        righe.append(
            "- Se dopo 3 tentativi: spiega l'errore, proponi un passo indietro se appropriato"
        )

    righe.append("- Chiudi SEMPRE con successo o apprendimento")

    return "\n".join(righe)


def direttiva_onboarding(
    *,
    fase: str,
    info_raccolte: str | None = None,
    prossimo_campo: str | None = None,
    nodo_da_valutare: dict | None = None,
    nodi_gateway: list[dict] | None = None,
    placement_risultati: dict | None = None,
) -> str:
    """Direttiva per le fasi di onboarding narrativo.

    Fasi: accoglienza → conoscenza → auto_valutazione → placement → conclusione.
    Accoglienza e conoscenza: testo libero conversazionale, NO tool use.
    Auto-valutazione e placement: usa onboarding_domanda per input strutturato.
    """
    if fase == "accoglienza":
        return (
            "ATTIVITÀ: Onboarding — Primo turno (accoglienza narrativa)\n"
            "FASE: accoglienza\n\n"
            "Questo è il PRIMO TURNO dell'onboarding. Segui esattamente il sistema prompt:\n"
            "1. Dichiara il patto esplicito (chi sei, cosa fai, perché, quanto dura, "
            "che può saltare, che può parlare a voce)\n"
            "2. Chiudi con un invito aperto a raccontarsi "
            "(NO domande strutturate, NO tool use)\n\n"
            "NON chiamare il tool `onboarding_domanda` in questo turno.\n"
            "Il formato è testo libero conversazionale."
        )
    elif fase == "conoscenza":
        # Mappa campo tecnico → descrizione naturale per la direttiva
        _descrizione_campo = {
            "chi_e": "chi è (studente, lavoratore, adulto che riprende...)",
            "motivo": "perché vuole imparare (esame, curiosità, lavoro...)",
            "stile_cognitivo": "come preferisce studiare (teoria, pratica, mix...)",
            "tempo_disponibile": "quanto tempo ha a disposizione",
            "vissuto_scolastico": "il suo rapporto passato con la materia",
        }
        campo_desc = _descrizione_campo.get(
            prossimo_campo or "", prossimo_campo or "(nessun campo specifico)"
        )
        return (
            "ATTIVITÀ: Onboarding — Conoscenza narrativa\n"
            "FASE: conoscenza\n\n"
            f"INFO GIÀ RACCOLTE: {info_raccolte or '(nessuna)'}\n"
            f"CAMPO DA APPROFONDIRE: {campo_desc}\n\n"
            "Formato turno:\n"
            "1. Commento breve (1-2 frasi) su quello che ha appena detto lo studente\n"
            "2. UNA domanda naturale, conversazionale, sul campo da approfondire\n\n"
            "NON chiamare `onboarding_domanda`. La domanda va nel testo.\n"
            "NON nominare mai il campo letterale ('stile cognitivo', 'vissuto'). "
            "Usa parafrasi naturali.\n"
            "Massimo 4-5 righe."
        )
    elif fase == "auto_valutazione":
        nodo_nome = (
            nodo_da_valutare.get("nome", "questo argomento")
            if nodo_da_valutare
            else "questo argomento"
        )
        return (
            "ATTIVITÀ: Onboarding — Auto-valutazione\n"
            "FASE: auto_valutazione\n"
            f"NODO: {nodo_nome}\n\n"
            "Commenta brevemente (1 frase) poi chiama `onboarding_domanda` con:\n"
            f"- tipo_input='scelta_singola'\n"
            f"- domanda='Come ti senti con {nodo_nome}?'\n"
            "- opzioni=['Forte, lo so bene', 'Incerto, mi serve ripassare', "
            "'Digiuno, mai visto']"
        )
    elif fase == "placement":
        # Prepara lista nodi gateway per il prompt
        nodi_str = "(nessun nodo disponibile)"
        if nodi_gateway:
            righe_nodi = []
            for gw in nodi_gateway:
                righe_nodi.append(
                    f"- {gw['nodo_id']}: {gw['nome']} (tema: {gw['tema_id']})"
                )
            nodi_str = "\n".join(righe_nodi)

        # Esiti già raccolti
        esiti_str = "(nessun esito ancora)"
        if placement_risultati and placement_risultati.get("esiti"):
            righe_esiti = []
            for e in placement_risultati["esiti"]:
                stato_e = "padroneggiato" if e.get("padroneggiato") else "non padroneggiato"
                righe_esiti.append(f"- {e['nodo_id']}: {stato_e}")
            esiti_str = "\n".join(righe_esiti)

        return (
            "ATTIVITÀ: Onboarding — Placement Test\n"
            "FASE: placement\n\n"
            f"INFO RACCOLTE: {info_raccolte or '(nessuna)'}\n\n"
            "OBIETTIVO: Mini-test diagnostico rapido. Fai 2-3 domande "
            "su concetti chiave per capire dove lo studente si trova.\n\n"
            "NODI GATEWAY DISPONIBILI (in ordine di profondità):\n"
            f"{nodi_str}\n\n"
            f"ESITI GIÀ RACCOLTI:\n{esiti_str}\n\n"
            "FORMATO TURNO:\n"
            "1. Testo: commento breve (1-2 frasi) — tipo 'Ottimo, ora vediamo "
            "come te la cavi con qualche domanda veloce'\n"
            "2. Tool call: `onboarding_domanda` con tipo_input='testo_libero' "
            "— domanda su un concetto gateway\n"
            "3. Segnale: `placement_esito` dopo aver valutato la risposta\n\n"
            "REGOLE:\n"
            "- Parti dal nodo più semplice (inizio della lista)\n"
            "- Se lo studente risponde correttamente, salta al nodo successivo\n"
            "- Se risponde male, fermati: hai trovato il punto di partenza\n"
            "- Massimo 3-4 domande — non è un esame!\n"
            "- Le domande devono essere accessibili, non intimidatorie\n"
            "- Quando hai abbastanza informazioni, emetti segnale "
            "`transizione_fase` con fase_destinazione='conclusione'"
        )
    elif fase in ("piano", "conclusione"):
        # fase piano rimossa: back-compat, delega a conclusione
        return (
            "ATTIVITÀ: Onboarding — Conclusione\n"
            "FASE: conclusione\n\n"
            f"INFO RACCOLTE: {info_raccolte or '(nessuna)'}\n\n"
            "ISTRUZIONI:\n"
            "1. Ricapitola brevemente (2-3 righe) cosa hai capito di lui\n"
            "2. Digli che il percorso parte dal primo concetto e può "
            "andare al suo ritmo\n"
            "3. NON usare onboarding_domanda — questa è la conclusione\n"
            "4. Chiudi con entusiasmo ma senza esagerare"
        )
    else:
        return f"ATTIVITÀ: Onboarding\nFASE: {fase}\n(fase non riconosciuta)"


def direttiva_ripresa_sessione(
    *,
    nodo_nome: str,
    attivita_precedente: str,
    dettaglio: str | None = None,
    nome_utente: str | None = None,
    profilo_sintetizzato: dict | None = None,
    ritmo_minuti: int | None = None,
) -> str:
    """Direttiva per ripresa di una sessione sospesa."""
    righe = [
        "ATTIVITÀ: Ripresa sessione",
        f"NODO: {nodo_nome}",
        f"ATTIVITÀ PRECEDENTE: {attivita_precedente}",
        f"CONTESTO: Lo studente aveva sospeso la sessione. {dettaglio or ''}",
        "",
    ]

    if nome_utente:
        preambolo = _preambolo_caldo(nome_utente, profilo_sintetizzato, ritmo_minuti)
        righe.append(
            "ISTRUZIONI:\n"
            f"{preambolo}\n"
            "Dopo il saluto, riprendi da dove vi eravate fermati: "
            "\"Bentornato! Stavamo lavorando su...\". "
            "La mappa breve qui è diversa: ripartiamo da dove ci siamo fermati. "
            "NON ripetere spiegazioni già date. "
            "Se l'attività era un esercizio, riproponi lo stesso esercizio."
        )
    else:
        righe.append(
            "ISTRUZIONI: Riaccoglilo brevemente (\"Bentornato! Stavamo lavorando su...\"). "
            "Riprendi da dove vi eravate fermati senza ripetere spiegazioni già date. "
            "Se l'attività era un esercizio, riproponi lo stesso esercizio."
        )

    return "\n".join(righe)


def direttiva_feynman(
    *,
    nodo_nome: str,
    fase_feynman: str,
    definizioni_formali: Any = None,
    formule_proprieta: Any = None,
    punti_chiave: list[str] | None = None,
) -> str:
    """Direttiva per verifica Feynman (Loop 3 — template definito, stub)."""
    righe = [
        "ATTIVITÀ: Verifica Feynman",
        f"NODO: {nodo_nome}",
        f"STATO: {fase_feynman} (invito | ascolto | feedback)",
        "",
        "CONTENUTO FORMALE (per tua valutazione interna):",
        _formatta_json(definizioni_formali),
        _formatta_json(formule_proprieta),
        "",
        "PUNTI CHIAVE che una spiegazione solida dovrebbe coprire:",
        _formatta_lista(punti_chiave),
        "",
    ]

    if fase_feynman == "invito":
        righe.append(
            "ISTRUZIONI: Invita lo studente a spiegare il concetto come se tu non sapessi nulla."
        )
    elif fase_feynman == "ascolto":
        righe.append("ISTRUZIONI: NON interrompere. Aspetta che finisca.")
    elif fase_feynman == "feedback":
        righe.append(
            "ISTRUZIONI: Riconosci le parti corrette. Domande maieutiche sulle lacune. "
            "Emetti segnale valutazione_feynman."
        )

    return "\n".join(righe)


def direttiva_ripasso_sr(
    *,
    concetti_scadenza: list[str],
    ordine_ottimale: list[str] | None = None,
) -> str:
    """Direttiva per ripasso Spaced Repetition (Loop 2 — template definito, stub)."""
    return (
        "ATTIVITÀ: Ripasso Spaced Repetition\n"
        f"CONCETTI IN SCADENZA: {', '.join(concetti_scadenza)}\n\n"
        "STRATEGIA: Interleaving — mescola le materie. Per ogni concetto:\n"
        "1. Verifica rapida (domanda diretta o mini-esercizio)\n"
        "2. Valuta la risposta\n"
        "3. Passa al concetto successivo (materia diversa)\n\n"
        "ORDINE SUGGERITO: "
        f"{', '.join(ordine_ottimale) if ordine_ottimale else '(da determinare)'}"
        "\n\n"
        "ISTRUZIONI: Ritmo veloce. Feedback immediato. "
        "Se errore grave, annota per ripresa futura ma non interrompere il flusso."
    )
