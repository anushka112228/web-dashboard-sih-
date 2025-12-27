import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "pranay2006"
    POSTGRES_DB: str = "sihdb"
    POSTGRES_HOST: str = "localhost"
    POSTGRES_PORT: int = 5432
    
    
    DATABASE_URL: str = "" 

    SECRET_KEY: str = "supersecretkeychangeme"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    
    # Weather API Configuration
    OPENWEATHER_API_KEY: str = ""
    AGROMONITORING_API_KEY: str = ""
    WEATHER_UPDATE_INTERVAL_HOURS: int = 6

    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

    # If you want to construct DATABASE_URL dynamically if not provided:
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        if not self.DATABASE_URL:
            self.DATABASE_URL = f"postgresql+psycopg2://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"

settings = Settings()
