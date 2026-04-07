"""Test B35.12 — Validazione fail-fast dei secrets all'avvio."""

from unittest.mock import patch

import pytest

from app.config import Settings, _JWT_SECRET_DEFAULT, validate_secrets_for_startup


class TestValidateSecrets:
    """Verifica che validate_secrets_for_startup blocchi o avvisi correttamente."""

    def test_produzione_blocca_con_jwt_default(self):
        """In produzione (DEBUG=False), JWT_SECRET di default blocca l'avvio."""
        mock_settings = Settings(
            JWT_SECRET=_JWT_SECRET_DEFAULT,
            ANTHROPIC_API_KEY="sk-ant-test-key",
            DEBUG=False,
        )
        with patch("app.config.settings", mock_settings):
            with pytest.raises(ValueError, match="JWT_SECRET"):
                validate_secrets_for_startup()

    def test_produzione_blocca_con_api_key_vuota(self):
        """In produzione (DEBUG=False), ANTHROPIC_API_KEY vuota blocca l'avvio."""
        mock_settings = Settings(
            JWT_SECRET="un-secret-sicuro-per-test",
            ANTHROPIC_API_KEY="",
            DEBUG=False,
        )
        with patch("app.config.settings", mock_settings):
            with pytest.raises(ValueError, match="ANTHROPIC_API_KEY"):
                validate_secrets_for_startup()

    def test_produzione_ok_con_secrets_configurati(self):
        """In produzione con secrets validi, nessun errore."""
        mock_settings = Settings(
            JWT_SECRET="un-secret-sicuro-per-test",
            ANTHROPIC_API_KEY="sk-ant-test-key",
            DEBUG=False,
        )
        with patch("app.config.settings", mock_settings):
            # Non deve sollevare eccezioni
            validate_secrets_for_startup()

    def test_debug_warning_jwt_default(self, caplog):
        """In DEBUG, JWT_SECRET di default emette warning senza bloccare."""
        mock_settings = Settings(
            JWT_SECRET=_JWT_SECRET_DEFAULT,
            ANTHROPIC_API_KEY="sk-ant-test-key",
            DEBUG=True,
        )
        with patch("app.config.settings", mock_settings):
            validate_secrets_for_startup()
            assert "JWT_SECRET" in caplog.text

    def test_debug_warning_api_key_vuota(self, caplog):
        """In DEBUG, ANTHROPIC_API_KEY vuota emette warning senza bloccare."""
        mock_settings = Settings(
            JWT_SECRET="un-secret-sicuro-per-test",
            ANTHROPIC_API_KEY="",
            DEBUG=True,
        )
        with patch("app.config.settings", mock_settings):
            validate_secrets_for_startup()
            assert "ANTHROPIC_API_KEY" in caplog.text

    def test_debug_ok_senza_warning(self, caplog):
        """In DEBUG con secrets validi, nessun warning."""
        mock_settings = Settings(
            JWT_SECRET="un-secret-sicuro-per-test",
            ANTHROPIC_API_KEY="sk-ant-test-key",
            DEBUG=True,
        )
        with patch("app.config.settings", mock_settings):
            validate_secrets_for_startup()
            assert "SICUREZZA" not in caplog.text

    def test_produzione_blocca_con_entrambi_invalidi(self):
        """In produzione, se entrambi i secrets sono invalidi, blocca al primo."""
        mock_settings = Settings(
            JWT_SECRET=_JWT_SECRET_DEFAULT,
            ANTHROPIC_API_KEY="",
            DEBUG=False,
        )
        with patch("app.config.settings", mock_settings):
            with pytest.raises(ValueError):
                validate_secrets_for_startup()
