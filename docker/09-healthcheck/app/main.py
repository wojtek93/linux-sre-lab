from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {
        "message": "Docker healthcheck lab",
        "status": "running"
    }

@app.get("/health")
def health():
    return {
        "status": "healthy"
    }
