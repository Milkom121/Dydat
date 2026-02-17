from pydantic_settings import BaseSettings


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
    JWT_SECRET: str = "change-me-in-production"
    JWT_EXPIRE_HOURS: int = 720

    # Timeouts
    TIMEOUT_LLM_SEC: int = 60

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
