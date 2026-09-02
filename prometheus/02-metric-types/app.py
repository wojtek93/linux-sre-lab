from prometheus_client import start_http_server, Counter, Gauge, Histogram, Summary
import random
import time

REQUESTS = Counter(
    "demo_requests_total",
    "Total number of processed requests"
)

ACTIVE_USERS = Gauge(
    "demo_active_users",
    "Current number of active users"
)

REQUEST_DURATION = Histogram(
    "demo_request_duration_seconds",
    "Request duration in seconds",
    buckets=[0.1, 0.2, 0.5, 1, 2, 5]
)

REQUEST_SUMMARY = Summary(
    "demo_request_summary_seconds",
    "Request duration summary"
)

if __name__ == "__main__":
    start_http_server(8000)

    while True:
        REQUESTS.inc()

        ACTIVE_USERS.set(random.randint(1, 20))

        duration = random.uniform(0.05, 2.0)

        REQUEST_DURATION.observe(duration)
        REQUEST_SUMMARY.observe(duration)

        time.sleep(2)
