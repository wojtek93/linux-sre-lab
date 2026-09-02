from flask import Flask, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import random
import time

app = Flask(__name__)

REQUESTS = Counter(
    "app_http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"]
)

ERRORS = Counter(
    "app_http_errors_total",
    "Total HTTP errors",
    ["endpoint"]
)

LATENCY = Histogram(
    "app_http_request_duration_seconds",
    "HTTP request latency",
    ["endpoint"]
)


@app.route("/")
def home():
    start = time.time()

    time.sleep(random.uniform(0.05, 0.5))

    duration = time.time() - start
    LATENCY.labels(endpoint="/").observe(duration)

    REQUESTS.labels(
        method="GET",
        endpoint="/",
        status="200"
    ).inc()

    return "Application is running\n"


@app.route("/error")
def error():
    start = time.time()

    time.sleep(random.uniform(0.05, 0.3))

    duration = time.time() - start
    LATENCY.labels(endpoint="/error").observe(duration)

    ERRORS.labels(endpoint="/error").inc()

    REQUESTS.labels(
        method="GET",
        endpoint="/error",
        status="500"
    ).inc()

    return "Internal Server Error\n", 500


@app.route("/metrics")
def metrics():
    return Response(
        generate_latest(),
        mimetype=CONTENT_TYPE_LATEST
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
