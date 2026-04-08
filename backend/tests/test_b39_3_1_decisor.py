"""Test B39.3.1 — Rules-based decisor puro Python per forma C adattiva.

Verifica il comportamento deterministico di decidi_prossima_mossa()
su tutti gli scenari previsti dal design doc.
"""

import pytest

from app.core.onboarding import (
    TETTO_TURNI_NARRATIVI,
    decidi_prossima_mossa,
)
from app.schemas.onboarding import (
    AzioneDecisore,
    CampoConConfidenza,
    ProfiloEstratto,
)


# --- Helper per costruire profili di test ---

def _campo(valore: str | None, confidenza: str) -> CampoConConfidenza:
    return CampoConConfidenza(valore=valore, confidenza=confidenza)


def _campo_alta(valore: str = "valore") -> CampoConConfidenza:
    return _campo(valore, "alta")


def _campo_media(valore: str = "valore") -> CampoConConfidenza:
    return _campo(valore, "media")


def _campo_bassa() -> CampoConConfidenza:
    return _campo(None, "bassa")


def _profilo_vuoto() -> ProfiloEstratto:
    """Profilo con tutti i campi a bassa confidenza."""
    return ProfiloEstratto(
        chi_e=_campo_bassa(),
        motivo=_campo_bassa(),
        stile_cognitivo=_campo_bassa(),
        tempo_disponibile=_campo_bassa(),
        vissuto_scolastico=_campo_bassa(),
    )


def _profilo_completo() -> ProfiloEstratto:
    """Profilo con tutti i campi a alta confidenza."""
    return ProfiloEstratto(
        chi_e=_campo_alta("studente universitario"),
        motivo=_campo_alta("preparazione esame"),
        stile_cognitivo=_campo_alta("esempi concreti"),
        tempo_disponibile=_campo_alta("30 minuti al giorno"),
        vissuto_scolastico=_campo_alta("buon rapporto con la matematica"),
    )


# --- Scenari ---

class TestDecisoreProfiloVuoto:
    """Scenario 1: profilo completamente vuoto → chiedi chi_e (priorità massima)."""

    def test_profilo_vuoto_chiede_chi_e(self):
        d = decidi_prossima_mossa(_profilo_vuoto(), turni_fatti=0)
        assert d.azione == AzioneDecisore.chiedi_campo_mancante
        assert d.campo_da_chiedere == "chi_e"

    def test_profilo_vuoto_motivo_nel_motivo(self):
        d = decidi_prossima_mossa(_profilo_vuoto(), turni_fatti=0)
        assert "chi_e" in d.motivo


class TestDecisoreProgressione:
    """Scenari 2-5: un campo alla volta viene compilato."""

    def test_chi_e_presente_chiede_motivo(self):
        """Scenario 2."""
        profilo = _profilo_vuoto()
        profilo.chi_e = _campo_alta("adulto 40 anni")
        d = decidi_prossima_mossa(profilo, turni_fatti=1)
        assert d.azione == AzioneDecisore.chiedi_campo_mancante
        assert d.campo_da_chiedere == "motivo"

    def test_chi_e_motivo_presenti_chiede_stile(self):
        """Scenario 3a: chi_e + motivo OK → chiedi stile_cognitivo."""
        profilo = _profilo_vuoto()
        profilo.chi_e = _campo_alta("studente")
        profilo.motivo = _campo_alta("curiosità")
        d = decidi_prossima_mossa(profilo, turni_fatti=2)
        assert d.azione == AzioneDecisore.chiedi_campo_mancante
        assert d.campo_da_chiedere == "stile_cognitivo"

    def test_stile_bassa_confidenza_trattato_come_mancante(self):
        """Scenario 3b: stile_cognitivo a bassa confidenza → chiedi stile."""
        profilo = _profilo_vuoto()
        profilo.chi_e = _campo_alta("studente")
        profilo.motivo = _campo_alta("curiosità")
        profilo.stile_cognitivo = _campo("forse visivo", "bassa")
        d = decidi_prossima_mossa(profilo, turni_fatti=2)
        assert d.azione == AzioneDecisore.chiedi_campo_mancante
        assert d.campo_da_chiedere == "stile_cognitivo"

    def test_tre_obbligatori_ok_chiede_tempo(self):
        """Scenario 4: 3 obbligatori OK → chiedi tempo_disponibile."""
        profilo = _profilo_vuoto()
        profilo.chi_e = _campo_alta("studente")
        profilo.motivo = _campo_alta("esame")
        profilo.stile_cognitivo = _campo_alta("esempi")
        d = decidi_prossima_mossa(profilo, turni_fatti=3)
        assert d.azione == AzioneDecisore.chiedi_campo_mancante
        assert d.campo_da_chiedere == "tempo_disponibile"

    def test_quattro_ok_chiede_vissuto(self):
        """Scenario 5: 4 campi OK → chiedi vissuto_scolastico."""
        profilo = _profilo_vuoto()
        profilo.chi_e = _campo_alta("studente")
        profilo.motivo = _campo_alta("esame")
        profilo.stile_cognitivo = _campo_alta("esempi")
        profilo.tempo_disponibile = _campo_alta("20 min")
        d = decidi_prossima_mossa(profilo, turni_fatti=4)
        assert d.azione == AzioneDecisore.chiedi_campo_mancante
        assert d.campo_da_chiedere == "vissuto_scolastico"


class TestDecisoreChiusura:
    """Scenari 6-7: profilo completo → chiudi narrativa."""

    def test_profilo_completo_alta_chiude(self):
        """Scenario 6: tutti e 5 a alta → chiudi_narrativa."""
        d = decidi_prossima_mossa(_profilo_completo(), turni_fatti=2)
        assert d.azione == AzioneDecisore.chiudi_narrativa
        assert d.campo_da_chiedere is None

    def test_profilo_con_media_chiude(self):
        """Scenario 7: tutti presenti, uno a media → chiudi comunque.

        Policy: media è sufficiente (non trattata come mancante).
        """
        profilo = _profilo_completo()
        profilo.vissuto_scolastico = _campo_media("non ricordo bene")
        d = decidi_prossima_mossa(profilo, turni_fatti=3)
        assert d.azione == AzioneDecisore.chiudi_narrativa

    def test_profilo_tutti_media_chiude(self):
        """Tutti a media → chiudi (media è accettabile per tutti i campi)."""
        profilo = ProfiloEstratto(
            chi_e=_campo_media("studente"),
            motivo=_campo_media("studio"),
            stile_cognitivo=_campo_media("misto"),
            tempo_disponibile=_campo_media("poco"),
            vissuto_scolastico=_campo_media("neutro"),
        )
        d = decidi_prossima_mossa(profilo, turni_fatti=5)
        assert d.azione == AzioneDecisore.chiudi_narrativa


class TestDecisoreForza:
    """Scenari 8-9: tetto turni raggiunto → chiusura forzata."""

    def test_tetto_turni_profilo_incompleto(self):
        """Scenario 8: turni = 7, profilo incompleto → forza chiusura."""
        profilo = _profilo_vuoto()
        profilo.chi_e = _campo_alta("studente")
        d = decidi_prossima_mossa(profilo, turni_fatti=7)
        assert d.azione == AzioneDecisore.forza_chiusura_tetto_turni
        assert d.campo_da_chiedere is None

    def test_oltre_tetto_turni(self):
        """Scenario 9: turni = 8 (oltre tetto) → forza chiusura."""
        d = decidi_prossima_mossa(_profilo_vuoto(), turni_fatti=8)
        assert d.azione == AzioneDecisore.forza_chiusura_tetto_turni

    def test_tetto_turni_profilo_completo(self):
        """Turni = 7 ma profilo completo → forza chiusura (tetto ha priorità)."""
        d = decidi_prossima_mossa(_profilo_completo(), turni_fatti=7)
        assert d.azione == AzioneDecisore.forza_chiusura_tetto_turni

    def test_costante_tetto_e_sette(self):
        """Verifica che il tetto sia 7 come da design doc."""
        assert TETTO_TURNI_NARRATIVI == 7


class TestDecisoreConfidenza:
    """Scenario 10 + edge case su confidenza."""

    def test_chi_e_bassa_priorita_massima(self):
        """Scenario 10: chi_e a bassa, altri a alta → chiedi chi_e."""
        profilo = _profilo_completo()
        profilo.chi_e = _campo("forse studente", "bassa")
        d = decidi_prossima_mossa(profilo, turni_fatti=3)
        assert d.azione == AzioneDecisore.chiedi_campo_mancante
        assert d.campo_da_chiedere == "chi_e"

    def test_motivo_bassa_con_opzionali_mancanti(self):
        """Motivo bassa + opzionali mancanti → chiedi motivo (priorità obbligatorio)."""
        profilo = _profilo_vuoto()
        profilo.chi_e = _campo_alta("studente")
        profilo.motivo = _campo("boh", "bassa")
        profilo.stile_cognitivo = _campo_alta("visivo")
        # tempo e vissuto mancanti
        d = decidi_prossima_mossa(profilo, turni_fatti=2)
        assert d.campo_da_chiedere == "motivo"

    def test_due_campi_mancanti_sceglie_priorita(self):
        """Se mancano stile e vissuto → chiedi stile (priorità più alta)."""
        profilo = _profilo_completo()
        profilo.stile_cognitivo = _campo_bassa()
        profilo.vissuto_scolastico = _campo_bassa()
        d = decidi_prossima_mossa(profilo, turni_fatti=4)
        assert d.campo_da_chiedere == "stile_cognitivo"


class TestDecisoreMotivo:
    """Verifica che il motivo sia sempre informativo per il debug."""

    def test_motivo_chiusura_forzata_contiene_tetto(self):
        d = decidi_prossima_mossa(_profilo_vuoto(), turni_fatti=7)
        assert "7" in d.motivo

    def test_motivo_campo_mancante_contiene_nome_campo(self):
        d = decidi_prossima_mossa(_profilo_vuoto(), turni_fatti=0)
        assert "chi_e" in d.motivo

    def test_motivo_chiusura_parla_di_5_campi(self):
        d = decidi_prossima_mossa(_profilo_completo(), turni_fatti=2)
        assert "5" in d.motivo


class TestDecisoreEdgeCase:
    """Edge case extra per robustezza."""

    def test_turni_zero_profilo_completo(self):
        """Primo turno, profilo già completo (utente molto collaborativo) → chiudi."""
        d = decidi_prossima_mossa(_profilo_completo(), turni_fatti=0)
        assert d.azione == AzioneDecisore.chiudi_narrativa

    def test_fase_placement_ignorata(self):
        """Il parametro fase_placement non cambia il comportamento (riservato)."""
        d1 = decidi_prossima_mossa(_profilo_vuoto(), turni_fatti=0)
        d2 = decidi_prossima_mossa(
            _profilo_vuoto(), turni_fatti=0, fase_placement="attiva"
        )
        assert d1.azione == d2.azione
        assert d1.campo_da_chiedere == d2.campo_da_chiedere

    def test_turni_sei_ancora_chiede(self):
        """turni_fatti = 6 (sotto tetto) → ancora chiede campo mancante."""
        profilo = _profilo_vuoto()
        profilo.chi_e = _campo_alta("studente")
        d = decidi_prossima_mossa(profilo, turni_fatti=6)
        assert d.azione == AzioneDecisore.chiedi_campo_mancante
