from flask import Flask
from prometheus_client import Counter, generate_latest

app = Flask(__name__)

REQUESTS = Counter(
    "app_requests_total",
    "Total number of requests"
)

@app.route("/")
def home():
    REQUESTS.inc()
    return "OK\n"

@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {
        "Content-Type": "text/plain; version=0.0.4"
    }

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
