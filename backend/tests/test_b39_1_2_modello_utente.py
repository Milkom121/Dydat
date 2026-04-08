"""Test B39.1.2 — Verifica campi onboarding_stato e lingua_preferita nel modello Utente."""

from app.db.models.utenti import OnboardingStato, Utente


class TestOnboardingStatoEnum:
    """Verifica che l'enum OnboardingStato sia corretto."""

    def test_valori_enum(self):
        assert OnboardingStato.NOT_STARTED.value == "not_started"
        assert OnboardingStato.IN_PROGRESS.value == "in_progress"
        assert OnboardingStato.COMPLETED.value == "completed"

    def test_enum_e_stringa(self):
        """OnboardingStato e un str enum — usabile come stringa."""
        assert isinstance(OnboardingStato.NOT_STARTED, str)
        assert OnboardingStato.COMPLETED == "completed"

    def test_enum_da_stringa(self):
        """Costruzione da stringa funziona."""
        assert OnboardingStato("not_started") is OnboardingStato.NOT_STARTED
        assert OnboardingStato("in_progress") is OnboardingStato.IN_PROGRESS
        assert OnboardingStato("completed") is OnboardingStato.COMPLETED

    def test_tre_valori(self):
        """Esattamente 3 stati."""
        assert len(OnboardingStato) == 3


class TestModelloUtenteCampi:
    """Verifica che il modello Utente esponga i nuovi campi."""

    def test_colonna_onboarding_stato_esiste(self):
        """Il modello ha la colonna onboarding_stato."""
        col = Utente.__table__.columns["onboarding_stato"]
        assert col is not None
        assert col.nullable is False

    def test_colonna_lingua_preferita_esiste(self):
        """Il modello ha la colonna lingua_preferita."""
        col = Utente.__table__.columns["lingua_preferita"]
        assert col is not None
        assert col.nullable is False

    def test_server_default_onboarding_stato(self):
        """Il server_default di onboarding_stato e 'not_started'."""
        col = Utente.__table__.columns["onboarding_stato"]
        assert col.server_default is not None
        # server_default.arg e un TextClause
        assert "not_started" in str(col.server_default.arg)

    def test_server_default_lingua_preferita(self):
        """Il server_default di lingua_preferita e 'it'."""
        col = Utente.__table__.columns["lingua_preferita"]
        assert col.server_default is not None
        assert "it" in str(col.server_default.arg)

    def test_tipo_colonna_lingua_preferita(self):
        """lingua_preferita e String(10)."""
        col = Utente.__table__.columns["lingua_preferita"]
        assert col.type.length == 10
