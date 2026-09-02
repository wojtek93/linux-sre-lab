from prometheus_client import Counter, start_http_server
import random
import time

REQUESTS = Counter(
    "demo_requests_total",
    "Demo requests",
    ["endpoint"]
)

start_http_server(8001)

while True:
    endpoint = random.choice([
        "/",
        "/login",
        "/products"
    ])

    REQUESTS.labels(
        endpoint=endpoint
    ).inc()

    time.sleep(0.1)
