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
            "ISTRUZIONI: Spiega il concetto usando il flusso"
            " Concreto → Problema → Formale. Adatta gli esempi alle"
            " preferenze. Al termine, proponi un esercizio base"
            " per verificare la comprensione."
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
    """Direttiva per le fasi di onboarding."""
    if fase == "accoglienza":
        return (
            "ATTIVITÀ: Onboarding — Conoscenza\n"
            "FASE: accoglienza\n\n"
            "ISTRUZIONI: Presentati brevemente. Spiega che Dydat è il suo tutor personale. "
            "Rassicura: niente voti, niente stress, il percorso si adatta a lui. "
            "Chiedigli come preferisce studiare (testo/voce, tanti esempi o subito pratica). "
            "Tono caldo e informale."
        )
    elif fase == "conoscenza":
        return (
            "ATTIVITÀ: Onboarding — Conoscenza\n"
            "FASE: conoscenza\n\n"
            "ISTRUZIONI: Conosci lo studente con 3-4 domande naturali (non un questionario):\n"
            "- Cosa studia/fa nella vita?\n"
            "- Perché vuole ripassare/imparare matematica?\n"
            "- C'è qualcosa che lo preoccupa o lo ha sempre messo in difficoltà?\n"
            "- Ha un obiettivo concreto (esame, concorso, curiosità)?\n"
            "Ascolta e rispondi con interesse genuino. Non fare tutte le domande insieme.\n\n"
            "AGGIUNTA: Verso la fine della conversazione, chiedi allo studente se ha già "
            "esperienza con gli argomenti e da dove vorrebbe partire. Se lo studente indica "
            "un punto di partenza specifico, emetti il segnale `punto_partenza_suggerito` "
            "con il tema o concetto indicato."
        )
    elif fase == "conclusione":
        return (
            "ATTIVITÀ: Onboarding — Conoscenza\n"
            "FASE: conclusione\n\n"
            f"INFO RACCOLTE: {info_raccolte or '(nessuna)'}\n\n"
            "ISTRUZIONI: Ricapitola brevemente cosa hai capito di lui. "
            "Digli che il percorso partirà dal primo concetto e che potrà andare al suo ritmo. "
            "Chiudi con entusiasmo ma senza esagerare."
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
