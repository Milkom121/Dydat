"""Test B39.2.2 — Schema Pydantic CampoConConfidenza e ProfiloEstratto.

Verifica serializzazione, deserializzazione, validazione errori,
e metodi helper (campi_completi, campi_mancanti, is_completo).
"""

import json

import pytest
from pydantic import ValidationError

from app.schemas.onboarding import CampoConConfidenza, ProfiloEstratto

# === CampoConConfidenza ===


class TestCampoConConfidenza:
    """Test per il singolo campo con confidenza."""

    def test_campo_valido_alta(self):
        campo = CampoConConfidenza(valore="adulto di 42 anni", confidenza="alta")
        assert campo.valore == "adulto di 42 anni"
        assert campo.confidenza == "alta"

    def test_campo_valido_media(self):
        campo = CampoConConfidenza(valore="forse studente", confidenza="media")
        assert campo.valore == "forse studente"
        assert campo.confidenza == "media"

    def test_campo_nullo_bassa(self):
        campo = CampoConConfidenza(valore=None, confidenza="bassa")
        assert campo.valore is None
        assert campo.confidenza == "bassa"

    def test_campo_nullo_alta_rifiutato(self):
        """valore=None con confidenza alta è un errore logico."""
        with pytest.raises(ValidationError, match="confidenza deve essere 'bassa'"):
            CampoConConfidenza(valore=None, confidenza="alta")

    def test_campo_nullo_media_rifiutato(self):
        """valore=None con confidenza media è un errore logico."""
        with pytest.raises(ValidationError, match="confidenza deve essere 'bassa'"):
            CampoConConfidenza(valore=None, confidenza="media")

    def test_confidenza_invalida(self):
        """Confidenza non prevista dal Literal viene rifiutata."""
        with pytest.raises(ValidationError):
            CampoConConfidenza(valore="test", confidenza="altissima")

    def test_serializzazione_json(self):
        campo = CampoConConfidenza(valore="test", confidenza="alta")
        data = json.loads(campo.model_dump_json())
        assert data == {"valore": "test", "confidenza": "alta"}

    def test_deserializzazione_da_dict(self):
        campo = CampoConConfidenza.model_validate(
            {"valore": "prova", "confidenza": "media"}
        )
        assert campo.valore == "prova"
        assert campo.confidenza == "media"

    def test_valore_stringa_vuota_ammesso(self):
        """Stringa vuota è distinta da None — il decisore valuterà."""
        campo = CampoConConfidenza(valore="", confidenza="bassa")
        assert campo.valore == ""


# === ProfiloEstratto ===


def _profilo_completo() -> ProfiloEstratto:
    """Helper: profilo con tutti i campi a confidenza alta."""
    return ProfiloEstratto(
        chi_e=CampoConConfidenza(valore="adulto di 42 anni, grafico freelance", confidenza="alta"),
        motivo=CampoConConfidenza(valore="curiosità personale", confidenza="alta"),
        stile_cognitivo=CampoConConfidenza(valore="esempi concreti", confidenza="alta"),
        tempo_disponibile=CampoConConfidenza(valore="15-20 min ogni sera", confidenza="alta"),
        vissuto_scolastico=CampoConConfidenza(valore="odiava la matematica", confidenza="alta"),
    )


def _profilo_parziale() -> ProfiloEstratto:
    """Helper: profilo con 2 campi alti e 3 bassi."""
    return ProfiloEstratto(
        chi_e=CampoConConfidenza(valore="studente universitario", confidenza="alta"),
        motivo=CampoConConfidenza(valore="preparare esame", confidenza="media"),
        stile_cognitivo=CampoConConfidenza(valore=None, confidenza="bassa"),
        tempo_disponibile=CampoConConfidenza(valore=None, confidenza="bassa"),
        vissuto_scolastico=CampoConConfidenza(valore=None, confidenza="bassa"),
    )


def _profilo_vuoto() -> ProfiloEstratto:
    """Helper: profilo completamente vuoto (primo turno taciturno)."""
    bassa = CampoConConfidenza(valore=None, confidenza="bassa")
    return ProfiloEstratto(
        chi_e=bassa,
        motivo=bassa,
        stile_cognitivo=bassa,
        tempo_disponibile=bassa,
        vissuto_scolastico=bassa,
    )


class TestProfiloEstratto:
    """Test per il profilo completo estratto."""

    def test_profilo_completo_valido(self):
        profilo = _profilo_completo()
        assert profilo.chi_e.confidenza == "alta"
        assert profilo.vissuto_scolastico.valore == "odiava la matematica"

    def test_profilo_parziale_valido(self):
        profilo = _profilo_parziale()
        assert profilo.chi_e.confidenza == "alta"
        assert profilo.stile_cognitivo.valore is None

    def test_profilo_vuoto_valido(self):
        profilo = _profilo_vuoto()
        assert all(
            getattr(profilo, c).confidenza == "bassa"
            for c in ("chi_e", "motivo", "stile_cognitivo",
                      "tempo_disponibile", "vissuto_scolastico")
        )

    def test_campo_mancante_rifiutato(self):
        """Se manca un campo obbligatorio, Pydantic rifiuta."""
        with pytest.raises(ValidationError):
            ProfiloEstratto(
                chi_e=CampoConConfidenza(valore="test", confidenza="alta"),
                # mancano motivo, stile_cognitivo, tempo_disponibile, vissuto_scolastico
            )

    def test_serializzazione_roundtrip(self):
        """Serializzazione e deserializzazione mantengono i dati."""
        originale = _profilo_completo()
        json_str = originale.model_dump_json()
        ricostruito = ProfiloEstratto.model_validate_json(json_str)
        assert ricostruito == originale

    def test_deserializzazione_da_json_llm(self):
        """Simula il JSON che arriva dal LLM estrattore."""
        from app.llm.prompts.onboarding_extractor import SCHEMA_OUTPUT_ESEMPIO
        profilo = ProfiloEstratto.model_validate_json(SCHEMA_OUTPUT_ESEMPIO)
        assert profilo.chi_e.confidenza == "alta"
        assert "42" in profilo.chi_e.valore

    def test_deserializzazione_output_parziale_llm(self):
        """Simula il JSON parziale dal LLM."""
        from app.llm.prompts.onboarding_extractor import SCHEMA_OUTPUT_PARZIALE
        profilo = ProfiloEstratto.model_validate_json(SCHEMA_OUTPUT_PARZIALE)
        assert profilo.chi_e.confidenza == "bassa"
        assert profilo.motivo.valore is None


class TestProfiloEstrattoHelper:
    """Test per i metodi helper del profilo."""

    def test_campi_completi_profilo_pieno(self):
        profilo = _profilo_completo()
        completi = profilo.campi_completi()
        assert len(completi) == 5
        assert "chi_e" in completi

    def test_campi_completi_profilo_parziale(self):
        profilo = _profilo_parziale()
        completi = profilo.campi_completi()
        assert completi == ["chi_e", "motivo"]

    def test_campi_mancanti_profilo_parziale(self):
        profilo = _profilo_parziale()
        mancanti = profilo.campi_mancanti()
        assert mancanti == ["stile_cognitivo", "tempo_disponibile", "vissuto_scolastico"]

    def test_campi_mancanti_profilo_vuoto(self):
        profilo = _profilo_vuoto()
        mancanti = profilo.campi_mancanti()
        assert len(mancanti) == 5

    def test_is_completo_true(self):
        assert _profilo_completo().is_completo() is True

    def test_is_completo_false_parziale(self):
        assert _profilo_parziale().is_completo() is False

    def test_is_completo_false_vuoto(self):
        assert _profilo_vuoto().is_completo() is False

    def test_media_conta_come_completo(self):
        """Campi con confidenza media sono 'completi' (non mancanti)."""
        profilo = ProfiloEstratto(
            chi_e=CampoConConfidenza(valore="studente", confidenza="media"),
            motivo=CampoConConfidenza(valore="esame", confidenza="media"),
            stile_cognitivo=CampoConConfidenza(valore="pratica", confidenza="media"),
            tempo_disponibile=CampoConConfidenza(valore="poco", confidenza="media"),
            vissuto_scolastico=CampoConConfidenza(valore="neutro", confidenza="media"),
        )
        assert profilo.is_completo() is True
        assert len(profilo.campi_completi()) == 5
