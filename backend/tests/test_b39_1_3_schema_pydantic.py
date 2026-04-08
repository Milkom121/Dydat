"""Test B39.1.3 — Verifica schemi Pydantic UtenteResponse: onboarding_stato + lingua_preferita."""

from unittest.mock import MagicMock

from app.db.models.utenti import OnboardingStato
from app.schemas.utente import UtenteResponse


class TestUtenteResponseSchema:
    """Verifica che UtenteResponse serializza i nuovi campi."""

    def test_campi_presenti_nello_schema(self):
        """onboarding_stato e lingua_preferita sono nel model_fields."""
        fields = UtenteResponse.model_fields
        assert "onboarding_stato" in fields
        assert "lingua_preferita" in fields

    def test_default_onboarding_stato(self):
        """Il default di onboarding_stato e 'not_started'."""
        assert UtenteResponse.model_fields["onboarding_stato"].default == "not_started"

    def test_default_lingua_preferita(self):
        """Il default di lingua_preferita e 'it'."""
        assert UtenteResponse.model_fields["lingua_preferita"].default == "it"

    def test_serializzazione_da_dict(self):
        """Costruzione da dict con i nuovi campi."""
        import uuid

        data = {
            "id": uuid.uuid4(),
            "email": "test@example.com",
            "nome": "Test User",
            "obiettivo_giornaliero_min": 20,
            "onboarding_stato": "in_progress",
            "lingua_preferita": "en",
        }
        resp = UtenteResponse(**data)
        assert resp.onboarding_stato == "in_progress"
        assert resp.lingua_preferita == "en"

    def test_serializzazione_enum_onboarding_stato(self):
        """Se il valore arriva come OnboardingStato enum, si serializza come stringa."""
        import uuid

        data = {
            "id": uuid.uuid4(),
            "email": "test@example.com",
            "nome": "Test",
            "obiettivo_giornaliero_min": 20,
            "onboarding_stato": OnboardingStato.COMPLETED,
            "lingua_preferita": "it",
        }
        resp = UtenteResponse(**data)
        assert resp.onboarding_stato == "completed"
        # Verifica che il JSON contiene la stringa, non la repr dell'enum
        json_data = resp.model_dump()
        assert json_data["onboarding_stato"] == "completed"

    def test_serializzazione_da_mock_orm(self):
        """Simula from_attributes con un oggetto ORM-like (mock)."""
        import uuid

        mock_utente = MagicMock()
        mock_utente.id = uuid.uuid4()
        mock_utente.email = "orm@example.com"
        mock_utente.nome = "ORM User"
        mock_utente.preferenze_tutor = None
        mock_utente.contesto_personale = None
        mock_utente.materie_attive = None
        mock_utente.obiettivo_giornaliero_min = 30
        mock_utente.onboarding_stato = OnboardingStato.IN_PROGRESS
        mock_utente.lingua_preferita = "it"

        resp = UtenteResponse.model_validate(mock_utente, from_attributes=True)
        assert resp.onboarding_stato == "in_progress"
        assert resp.lingua_preferita == "it"

    def test_serializzazione_json_completa(self):
        """model_dump produce i campi nella response JSON."""
        import uuid

        data = {
            "id": uuid.uuid4(),
            "email": "json@example.com",
            "nome": "JSON User",
            "obiettivo_giornaliero_min": 15,
            "onboarding_stato": "completed",
            "lingua_preferita": "fr",
        }
        resp = UtenteResponse(**data)
        dumped = resp.model_dump()
        assert "onboarding_stato" in dumped
        assert "lingua_preferita" in dumped
        assert dumped["onboarding_stato"] == "completed"
        assert dumped["lingua_preferita"] == "fr"

    def test_valori_default_senza_campi_espliciti(self):
        """Se i campi non vengono passati, usano i default."""
        import uuid

        data = {
            "id": uuid.uuid4(),
            "email": "default@example.com",
            "nome": "Default",
            "obiettivo_giornaliero_min": 20,
        }
        resp = UtenteResponse(**data)
        assert resp.onboarding_stato == "not_started"
        assert resp.lingua_preferita == "it"

    def test_from_attributes_true(self):
        """Il model_config ha from_attributes=True."""
        assert UtenteResponse.model_config.get("from_attributes") is True
