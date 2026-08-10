from fastapi import FastAPI
import os

app = FastAPI()

@app.get("/")
def root():
    return {
        "app_env": os.getenv("APP_ENV", "development"),
        "app_version": os.getenv("APP_VERSION", "unknown"),
        "api_url": os.getenv("API_URL", "not-set")
    }
