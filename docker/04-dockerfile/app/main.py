from fastapi import FastAPI
import socket
import os

app = FastAPI()


@app.get("/")
def root():
    return {
        "message": "Docker SRE Lab v4",
        "status": "running"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


@app.get("/info")
def info():
    return {
        "hostname": socket.gethostname(),
        "environment": os.getenv("APP_ENV", "development")
    }
