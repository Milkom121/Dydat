"""Test B39.1.3 — Verifica schemi Pydantic con onboarding_stato e lingua_preferita."""

import uuid
from unittest.mock import MagicMock

from app.db.models.utenti import OnboardingStato
from app.schemas.utente import UtenteResponse


class TestUtenteResponseNuoviCampi:
    """Verifica che UtenteResponse serializzi onboarding_stato e lingua_preferita."""

    def test_campi_default(self):
        """I nuovi campi hanno i default corretti."""
        resp = UtenteResponse(
            id=uuid.uuid4(),
            email="test@example.com",
            nome="Test",
            obiettivo_giornaliero_min=20,
        )
        assert resp.onboarding_stato == "not_started"
        assert resp.lingua_preferita == "it"

    def test_onboarding_stato_stringa(self):
        """onboarding_stato accetta stringa direttamente."""
        resp = UtenteResponse(
            id=uuid.uuid4(),
            email="test@example.com",
            nome="Test",
            obiettivo_giornaliero_min=20,
            onboarding_stato="in_progress",
            lingua_preferita="en",
        )
        assert resp.onboarding_stato == "in_progress"
        assert resp.lingua_preferita == "en"

    def test_onboarding_stato_da_enum(self):
        """onboarding_stato accetta valore enum OnboardingStato (str enum)."""
        resp = UtenteResponse(
            id=uuid.uuid4(),
            email="test@example.com",
            nome="Test",
            obiettivo_giornaliero_min=20,
            onboarding_stato=OnboardingStato.COMPLETED,
        )
        # L'enum e un str, Pydantic lo serializza come stringa
        assert resp.onboarding_stato == "completed"

    def test_serializzazione_json_nuovi_campi(self):
        """model_dump include i nuovi campi."""
        resp = UtenteResponse(
            id=uuid.uuid4(),
            email="test@example.com",
            nome="Test",
            obiettivo_giornaliero_min=20,
            onboarding_stato="completed",
            lingua_preferita="it",
        )
        data = resp.model_dump()
        assert "onboarding_stato" in data
        assert "lingua_preferita" in data
        assert data["onboarding_stato"] == "completed"
        assert data["lingua_preferita"] == "it"

    def test_from_attributes_con_enum(self):
        """from_attributes converte correttamente l'enum dal modello ORM."""
        # Simuliamo un oggetto Utente ORM con attributi
        mock_utente = MagicMock()
        mock_utente.id = uuid.uuid4()
        mock_utente.email = "orm@example.com"
        mock_utente.nome = "ORM User"
        mock_utente.preferenze_tutor = None
        mock_utente.contesto_personale = None
        mock_utente.materie_attive = None
        mock_utente.obiettivo_giornaliero_min = 20
        mock_utente.onboarding_stato = OnboardingStato.IN_PROGRESS
        mock_utente.lingua_preferita = "it"

        resp = UtenteResponse.model_validate(mock_utente, from_attributes=True)
        assert resp.onboarding_stato == "in_progress"
        assert resp.lingua_preferita == "it"

    def test_from_attributes_default_orm(self):
        """from_attributes con valori default ORM."""
        mock_utente = MagicMock()
        mock_utente.id = uuid.uuid4()
        mock_utente.email = "default@example.com"
        mock_utente.nome = None
        mock_utente.preferenze_tutor = None
        mock_utente.contesto_personale = None
        mock_utente.materie_attive = None
        mock_utente.obiettivo_giornaliero_min = 20
        mock_utente.onboarding_stato = OnboardingStato.NOT_STARTED
        mock_utente.lingua_preferita = "it"

        resp = UtenteResponse.model_validate(mock_utente, from_attributes=True)
        assert resp.onboarding_stato == "not_started"
        assert resp.lingua_preferita == "it"

    def test_tutti_e_tre_gli_stati(self):
        """Verifica serializzazione per ogni valore dell'enum."""
        for stato in OnboardingStato:
            resp = UtenteResponse(
                id=uuid.uuid4(),
                email="test@example.com",
                nome="Test",
                obiettivo_giornaliero_min=20,
                onboarding_stato=stato,
            )
            assert resp.onboarding_stato == stato.value

    def test_json_schema_include_campi(self):
        """Lo JSON schema del modello include i nuovi campi."""
        schema = UtenteResponse.model_json_schema()
        props = schema["properties"]
        assert "onboarding_stato" in props
        assert "lingua_preferita" in props
