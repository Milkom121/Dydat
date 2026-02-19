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
) -> str:
    """Direttiva per spiegazione di un concetto nuovo."""
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
        (
            "ISTRUZIONI:\n"
            "- Questo è il PRIMO turno: parti con un esempio concreto "
            "dalla vita reale (2-3 frasi) e chiudi con una domanda "
            "per coinvolgere lo studente.\n"
            "- NON spiegare tutto subito. Il flusso Concreto → Problema → "
            "Formale si sviluppa su PIÙ turni.\n"
            "- Massimo 4-5 righe per questo turno. Lo studente "
            "deve rispondere prima di proseguire.\n"
            "- Al termine del percorso (non adesso), proponi un esercizio."
        ),
    ]

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
) -> str:
    """Direttiva per le fasi di onboarding.

    Il tutor usa l'azione `onboarding_domanda` per presentare domande
    strutturate allo studente. Ogni turno: breve commento + una domanda.
    """
    if fase == "accoglienza":
        return (
            "ATTIVITÀ: Onboarding — Accoglienza\n"
            "FASE: accoglienza\n\n"
            "⚠️ VINCOLO ASSOLUTO — LEGGI CON ATTENZIONE:\n"
            "DEVI chiamare il tool `onboarding_domanda` in OGNI turno.\n"
            "NON scrivere MAI domande nel testo. Le domande vanno SOLO "
            "nel tool. Il testo serve solo per brevi commenti (max 2 frasi).\n"
            "Se non chiami il tool, il turno è considerato FALLITO.\n\n"
            "FORMATO TURNO OBBLIGATORIO:\n"
            "1. Testo: 1-2 frasi BREVI di presentazione (NO domande, "
            "NO elenchi, NO asterischi, NO formattazione elaborata)\n"
            "2. Tool call: `onboarding_domanda` con UNA domanda\n\n"
            "REGOLA TIPO INPUT:\n"
            "- Preferisci SEMPRE `scelta_singola`. Aggiungi 'Altro' come "
            "ultima opzione se lo studente potrebbe voler rispondere liberamente.\n"
            "- Usa `scala` solo per misurare confidenza/livello numerico.\n"
            "- Usa `testo_libero` SOLO se nessuna delle precedenti funziona "
            "(es: 'Come ti chiami?').\n\n"
            "CHECKLIST (cose da scoprire):\n"
            "- Chi è: studente, lavoratore, adulto che torna a studiare?\n"
            "- Materia: matematica, fisica, chimica (o più di una)\n"
            "- Livello attuale: dove si trova? Ultimo argomento?\n"
            "- Confidenza: come si sente con la materia?\n"
            "- Urgenza: esame vicino? curiosità? obiettivo?\n"
            "- Stile: teoria prima, esercizi subito, o mix?\n"
            "- Punto di partenza: da dove vuole cominciare?\n\n"
            "Obiettivo: 5-8 turni. Se una risposta copre più punti, "
            "salta avanti.\n\n"
            "ORA: Presentati brevemente (2 frasi), poi chiama "
            "`onboarding_domanda` con tipo_input='scelta_singola', "
            "domanda='Come ti descriveresti?', "
            "opzioni=['Sono uno studente', 'Voglio imparare per conto mio', "
            "'Sto riprendendo dopo tanto tempo']."
        )
    elif fase == "conoscenza":
        return (
            "ATTIVITÀ: Onboarding — Conoscenza\n"
            "FASE: conoscenza\n\n"
            f"INFO RACCOLTE FINORA: {info_raccolte or '(nessuna)'}\n\n"
            "⚠️ VINCOLO ASSOLUTO:\n"
            "DEVI chiamare il tool `onboarding_domanda` in questo turno.\n"
            "NON scrivere domande nel testo. Solo nel tool.\n\n"
            "FORMATO TURNO OBBLIGATORIO:\n"
            "1. Testo: commenta la risposta (1-2 frasi BREVI, "
            "interesse genuino, NO elenchi, NO formattazione elaborata)\n"
            "2. Tool call: `onboarding_domanda` con la prossima domanda\n\n"
            "REGOLA TIPO INPUT:\n"
            "- Preferisci SEMPRE `scelta_singola`. Aggiungi 'Altro' come "
            "ultima opzione se servono risposte libere.\n"
            "- Usa `scala` solo per misurare confidenza/livello (1-5).\n"
            "- Usa `testo_libero` SOLO come ultima risorsa.\n\n"
            "CHECKLIST (scopri ciò che non sai ancora):\n"
            "- Chi è: studente, lavoratore, adulto che torna a studiare?\n"
            "- Materia: matematica, fisica, chimica?\n"
            "- Livello attuale: ultimo argomento studiato/capito?\n"
            "- Confidenza: come si sente (usa scala 1-5)\n"
            "- Urgenza/obiettivo: esame, concorso, curiosità, recupero?\n"
            "- Stile: teoria-poi-pratica, subito-esercizi, mix?\n"
            "- Punto di partenza: da dove vuole cominciare?\n\n"
            "REGOLE:\n"
            "- UNA domanda per turno, MAI di più\n"
            "- Se la risposta copre più punti, salta domande già coperte\n"
            "- Adatta il linguaggio: a uno studente 'cosa fate in classe?', "
            "a un adulto 'qual è l'ultima cosa che ricordi bene?'"
        )
    elif fase == "conclusione":
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
) -> str:
    """Direttiva per ripresa di una sessione sospesa."""
    return (
        "ATTIVITÀ: Ripresa sessione\n"
        f"NODO: {nodo_nome}\n"
        f"ATTIVITÀ PRECEDENTE: {attivita_precedente}\n"
        f"CONTESTO: Lo studente aveva sospeso la sessione. {dettaglio or ''}\n\n"
        "ISTRUZIONI: Riaccoglilo brevemente (\"Bentornato! Stavamo lavorando su...\"). "
        "Riprendi da dove vi eravate fermati senza ripetere spiegazioni già date. "
        "Se l'attività era un esercizio, riproponi lo stesso esercizio."
    )


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
