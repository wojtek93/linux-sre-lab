from fastapi import FastAPI
import os

app = FastAPI()

@app.get("/")
def root():
    return {
        "message": "Non-root Docker lab",
        "uid": os.getuid(),
        "gid": os.getgid()
    }
