from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {
        "message": "Multi-stage Docker lab",
        "status": "running"
    }
