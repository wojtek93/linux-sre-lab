from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {
        "message": "Docker layers lab",
        "version": "1.2"
    }
