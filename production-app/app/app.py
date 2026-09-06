from flask import Flask, request, g
from prometheus_client import Counter, Histogram, generate_latest
import time

app = Flask(__name__)

REQUESTS = Counter(
    "app_requests_total",
    "Total number of HTTP requests",
    ["method", "endpoint", "status"]
)

LATENCY = Histogram(
    "app_request_latency_seconds",
    "HTTP request latency in seconds",
    ["method", "endpoint"]
)


@app.before_request
def start_timer():
    g.start_time = time.time()


@app.after_request
def record_metrics(response):
    if request.path != "/metrics":
        REQUESTS.labels(
            method=request.method,
            endpoint=request.path,
            status=str(response.status_code)
        ).inc()

        LATENCY.labels(
            method=request.method,
            endpoint=request.path
        ).observe(time.time() - g.start_time)

    return response


@app.route("/")
def home():
    return "OK\n"


@app.route("/error")
def error():
    return "Internal Server Error\n", 500


@app.route("/slow")
def slow():
    time.sleep(1)
    return "Slow response\n"


@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {
        "Content-Type": "text/plain; version=0.0.4"
    }


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
