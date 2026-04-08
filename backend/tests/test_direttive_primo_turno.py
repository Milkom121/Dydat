"""Test B33.5 — Primo turno caldo del tutor.

Verifica che _preambolo_caldo, direttiva_spiegazione (con nuovi parametri)
e direttiva_ripresa_sessione generino istruzioni corrette per il primo
messaggio contestualizzato.
"""

from __future__ import annotations

from app.llm.prompts.direttive import (
    _preambolo_caldo,
    direttiva_ripresa_sessione,
    direttiva_spiegazione,
)


# Profilo di test che simula un utente reale dopo l'onboarding
PROFILO_COMPLETO = {
    "chi_e": "adulto che sta riprendendo dopo una pausa",
    "motivo": "curiosità personale",
    "stile_cognitivo": "partire da esempi concreti",
}


# ===================================================================
# Test: _preambolo_caldo
# ===================================================================


class TestPreamboloCaldo:
    def test_contiene_nome_utente(self):
        """Il preambolo deve contenere il nome dell'utente."""
        result = _preambolo_caldo("Verdan", PROFILO_COMPLETO, 30)
        assert "Verdan" in result

    def test_profilo_none_non_crasha(self):
        """Con profilo None il preambolo genera comunque un saluto valido."""
        result = _preambolo_caldo("Marco", None, 15)
        assert "Marco" in result
        # Senza profilo deve comunque dare indicazioni di saluto
        assert "saluto" in result.lower() or "caldo" in result.lower()

    def test_ritmo_15_cita_veloce(self):
        """Con ritmo 15 minuti, il preambolo cita un tempo breve."""
        result = _preambolo_caldo("Anna", PROFILO_COMPLETO, 15)
        assert "15" in result or "quarto d'ora" in result.lower()

    def test_ritmo_30_cita_mezzora(self):
        """Con ritmo 30 minuti, il preambolo cita la mezz'ora."""
        result = _preambolo_caldo("Luca", PROFILO_COMPLETO, 30)
        assert "30" in result or "mezz'ora" in result.lower()

    def test_ritmo_60_cita_ora(self):
        """Con ritmo 60 minuti, il preambolo cita un'ora."""
        result = _preambolo_caldo("Sara", PROFILO_COMPLETO, 60)
        assert "60" in result or "ora" in result.lower()

    def test_profilo_parziale(self):
        """Con profilo parziale (solo chi_e), genera comunque istruzioni."""
        profilo = {"chi_e": "studente universitario"}
        result = _preambolo_caldo("Paolo", profilo, 30)
        assert "Paolo" in result
        assert "studente universitario" in result

    def test_ritmo_none_nessuna_citazione_tempo(self):
        """Senza ritmo, non cita il tempo."""
        result = _preambolo_caldo("Elena", PROFILO_COMPLETO, None)
        assert "Elena" in result
        # Non deve contenere riferimenti a minuti specifici
        assert "minuti" not in result.lower()

    def test_preambolo_istruisce_parafrasi(self):
        """Il preambolo deve istruire il tutor a parafrasare, non citare verbatim."""
        result = _preambolo_caldo("Test", PROFILO_COMPLETO, 30)
        assert "parafrasa" in result.lower() or "NON ripetere" in result


# ===================================================================
# Test: direttiva_spiegazione con primo turno caldo
# ===================================================================


class TestDirettivaSpiegazionePrimoTurno:
    """Test specifici per il branch primo-turno-caldo di direttiva_spiegazione."""

    def _call_spiegazione(self, **kwargs):
        """Helper per chiamare direttiva_spiegazione con parametri default."""
        defaults = dict(
            nodo_nome="Potenza di un numero relativo",
            nodo_id="potenza_num_rel",
            prerequisiti_completati=["operazioni_base"],
            livello_materia="base",
            definizioni_formali={"def": "a^n con a relativo"},
            formule_proprieta=None,
            errori_comuni=None,
        )
        defaults.update(kwargs)
        return direttiva_spiegazione(**defaults)

    def test_nodo_nuovo_con_nome_presenta_e_warmup(self):
        """Con nome_utente e nodo_presunto=False, il tutor deve presentare
        il nodo con micro-indice e chiudere con domanda warm-up."""
        result = self._call_spiegazione(
            nome_utente="Verdan",
            nodo_presunto=False,
            profilo_sintetizzato=PROFILO_COMPLETO,
            ritmo_minuti=30,
        )
        # Deve contenere il preambolo
        assert "Verdan" in result
        # Deve istruire micro-indice
        assert "micro-indice" in result.lower() or "discorsivo" in result.lower()
        # Deve istruire domanda warm-up
        assert "warm-up" in result.lower() or "domanda" in result.lower()
        # Deve essere un singolo messaggio con tre paragrafi
        assert "UN SOLO messaggio" in result

    def test_nodo_presunto_verifica_veloce(self):
        """Con nodo_presunto=True, il tutor deve fare verifica veloce
        invece di spiegazione."""
        result = self._call_spiegazione(
            nome_utente="Verdan",
            nodo_presunto=True,
            profilo_sintetizzato=PROFILO_COMPLETO,
            ritmo_minuti=30,
        )
        assert "Verdan" in result
        # Deve menzionare che il nodo è presunto/familiare
        assert "presunto" in result.lower() or "familiare" in result.lower()
        # Deve proporre verifica/domanda-sonda
        assert "verifica" in result.lower() or "domanda-sonda" in result.lower()
        # NON deve partire con spiegazione
        assert "NON partire con la spiegazione" in result

    def test_senza_nome_utente_comportamento_classico(self):
        """Senza nome_utente la direttiva mantiene il comportamento classico
        (retrocompatibilità con i test esistenti)."""
        result = self._call_spiegazione()
        # Comportamento originale: esempio concreto dalla vita reale
        assert "esempio concreto" in result.lower()
        assert "Concreto → Problema → Formale" in result

    def test_compatibilita_tempo_rimasto(self):
        """minuti_rimasti continua a funzionare anche con i nuovi parametri."""
        result = self._call_spiegazione(
            nome_utente="Test",
            minuti_rimasti=20,
        )
        assert "20 minuti" in result


# ===================================================================
# Test: direttiva_ripresa_sessione con preambolo caldo
# ===================================================================


class TestDirettivaRipresaPrimoTurno:
    def test_ripresa_con_nome_contiene_preambolo(self):
        """La ripresa con nome_utente deve includere il preambolo caldo."""
        result = direttiva_ripresa_sessione(
            nodo_nome="Equazioni",
            attivita_precedente="esercizio",
            dettaglio="Stava risolvendo un esercizio di tipo intermedio.",
            nome_utente="Marco",
            profilo_sintetizzato=PROFILO_COMPLETO,
            ritmo_minuti=30,
        )
        assert "Marco" in result
        assert "Ripresa sessione" in result
        assert "Bentornato" in result

    def test_ripresa_senza_nome_comportamento_classico(self):
        """Senza nome_utente la ripresa mantiene il comportamento classico."""
        result = direttiva_ripresa_sessione(
            nodo_nome="Equazioni",
            attivita_precedente="esercizio",
        )
        assert "Bentornato" in result
        assert "Equazioni" in result
