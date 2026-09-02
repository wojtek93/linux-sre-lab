from prometheus_client import Counter, start_http_server
import random
import time
import uuid

REQUESTS = Counter(
    "demo_requests_total",
    "Demo requests",
    ["endpoint", "request_id"]
)

start_http_server(8001)

while True:
    request_id = str(uuid.uuid4())

    endpoint = random.choice([
        "/",
        "/login",
        "/products"
    ])

    REQUESTS.labels(
        endpoint=endpoint,
        request_id=request_id
    ).inc()

    time.sleep(0.1)
