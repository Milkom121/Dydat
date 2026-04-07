import logging

from pydantic_settings import BaseSettings

logger = logging.getLogger(__name__)

_JWT_SECRET_DEFAULT = "change-me-in-production"


class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "postgresql+asyncpg://dydat:dydat_secret@db:5432/dydat"

    # Anthropic
    ANTHROPIC_API_KEY: str = ""

    # LLM Models
    LLM_MODEL_TUTOR: str = "claude-sonnet-4-5-20250929"
    LLM_MODEL_PIPELINE: str = "claude-haiku-4-5-20251001"
    LLM_MODEL_ESCALATION: str = "claude-sonnet-4-5-20250929"

    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    DEBUG: bool = False

    # Auth
    JWT_SECRET: str = _JWT_SECRET_DEFAULT
    JWT_EXPIRE_HOURS: int = 720

    # Timeouts
    TIMEOUT_LLM_SEC: int = 60

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8", "extra": "ignore"}


settings = Settings()


def validate_secrets_for_startup() -> None:
    """Validazione fail-fast dei secrets all'avvio del server.

    In modalita DEBUG emette warning, in produzione blocca l'avvio.
    I test non passano per questa funzione (viene chiamata dalla lifespan).
    """
    problemi: list[str] = []

    if settings.JWT_SECRET == _JWT_SECRET_DEFAULT:
        problemi.append(
            "JWT_SECRET ha il valore di default — chiunque puo forgiare token. "
            "Configura un valore sicuro in .env"
        )

    if not settings.ANTHROPIC_API_KEY:
        problemi.append(
            "ANTHROPIC_API_KEY non configurata — le chiamate LLM falliranno. "
            "Configura la chiave in .env"
        )

    if not problemi:
        return

    for problema in problemi:
        if settings.DEBUG:
            logger.warning("⚠ SICUREZZA: %s", problema)
        else:
            raise ValueError(f"Avvio bloccato — {problema}")
