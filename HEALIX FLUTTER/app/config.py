"""
Application settings – loaded from environment variables / .env file.
"""
import os
from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "ClinicAI Disease Prediction API"
    app_version: str = "1.0.0"
    debug: bool = False

    # Directory where trained .pkl model files live (models/ next to ClinicAI/)
    models_dir: str = os.path.join(
        os.path.dirname(__file__), "..", "models"
    )

    # CORS – tighten in production
    allowed_origins: list[str] = ["*"]

    # .NET backend base URL (used for future cross-service calls if needed)
    backend_url: str = "http://localhost:5001"

    # Security - API Key (Set in .env for production)
    api_key: str = "clinic_secret_key_2024"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
    )


@lru_cache()
def get_settings() -> Settings:
    return Settings()
