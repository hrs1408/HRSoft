from pydantic_settings import BaseSettings
from typing import Optional
import os

class Settings(BaseSettings):
    # Application
    app_name: str = "HRSOFT"
    debug: bool = False
    version: str = "1.0.0"
    
    # Database
    database_url: str = "postgresql://hrsoft_user:hrsoft_password@localhost/hrsoft_db"
    database_echo: bool = False
    
    # Redis
    redis_url: str = "redis://localhost:6379"
    
    # JWT
    jwt_secret_key: str = "your-super-secret-jwt-key-here"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7
    
    # Security
    bcrypt_rounds: int = 12
    
    # Service Communication
    auth_service_url: str = "http://localhost:8001"
    user_service_url: str = "http://localhost:8002"
    
    # Logging
    log_level: str = "INFO"
    log_format: str = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    
    # CORS
    cors_origins: list = ["http://localhost:3000", "http://localhost:8080"]
    
    class Config:
        env_file = ".env"
        case_sensitive = False

# Singleton instance
settings = Settings()

def get_settings() -> Settings:
    return settings
