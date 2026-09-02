# PRO-05 Application Metrics

## Goal

Instrument a real HTTP application with Prometheus metrics and expose:

- HTTP request count
- HTTP error count
- HTTP request latency

The application uses Flask and the Python `prometheus_client` library.

---

## Architecture

```text
Client
↓
Flask application
↓
application metrics
↓
/metrics endpoint
↓
Prometheus scrape
↓
PromQL
```

---

## Flask

Flask is a lightweight Python web framework.

It allows us to create HTTP endpoints such as:

```text
/
```

```text
/error
```

```text
/metrics
```

In this lab Flask is used only to provide a simple HTTP application that can generate real application traffic.

---

## Application endpoints

### Healthy endpoint

```text
GET /
```

Returns:

```text
HTTP 200
```

This endpoint generates normal successful traffic.

---

### Error endpoint

```text
GET /error
```

Returns:

```text
HTTP 500
```

This endpoint intentionally generates application errors.

---

### Metrics endpoint

```text
GET /metrics
```

Exposes application metrics in Prometheus format.

---

## Application metrics

Three main monitoring areas were implemented.

### Request count

```text
app_http_requests_total
```

Type:

```text
Counter
```

Labels:

```text
method
endpoint
status
```

Example:

```text
app_http_requests_total{
  method="GET",
  endpoint="/",
  status="200"
}
```

This metric answers:

```text
How many HTTP requests were processed?
```

---

## Error count

Metric:

```text
app_http_errors_total
```

Type:

```text
Counter
```

Label:

```text
endpoint
```

Example:

```text
app_http_errors_total{endpoint="/error"}
```

This metric answers:

```text
How many application errors occurred?
```

---

## Request latency

Metric:

```text
app_http_request_duration_seconds
```

Type:

```text
Histogram
```

Label:

```text
endpoint
```

The Histogram exposes:

```text
_bucket
_count
_sum
```

Example:

```text
app_http_request_duration_seconds_bucket
app_http_request_duration_seconds_count
app_http_request_duration_seconds_sum
```

This allows analysis of request duration.

---

## Application code

```python
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
```

---

## Python environment

A Python virtual environment was used.

Create:

```bash
python3 -m venv .venv
```

Activate:

```bash
source .venv/bin/activate
```

Install dependencies:

```bash
pip install flask prometheus-client
```

---

## Run the application

```bash
python app.py
```

The application listens on:

```text
0.0.0.0:8000
```

Using:

```python
host="0.0.0.0"
```

allows the application to be reached not only through localhost, but also from other network interfaces, including Docker networking.

---

## Test application traffic

Successful requests:

```bash
curl http://localhost:8000/
```

Generate multiple successful requests:

```bash
for i in {1..10}; do
  curl -s http://localhost:8000/ > /dev/null
done
```

Generate errors:

```bash
for i in {1..3}; do
  curl -s http://localhost:8000/error > /dev/null
done
```

---

## Inspect raw metrics

```bash
curl http://localhost:8000/metrics | grep app_http
```

Example metrics:

```text
app_http_requests_total
app_http_errors_total
app_http_request_duration_seconds_bucket
app_http_request_duration_seconds_count
app_http_request_duration_seconds_sum
```

---

## Prometheus configuration

```yaml
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets:
          - "localhost:9090"

  - job_name: "flask-app"
    static_configs:
      - targets:
          - "host.docker.internal:8000"
```

---

## Docker networking

Prometheus runs inside a Docker container while Flask runs directly on the Linux VM.

Therefore:

```text
localhost:8000
```

inside the Prometheus container would refer to the container itself.

The container was started using:

```bash
--add-host=host.docker.internal:host-gateway
```

This allows Prometheus to reach the host application using:

```text
host.docker.internal:8000
```

Flow:

```text
Prometheus container
↓
host.docker.internal
↓
Linux VM
↓
Flask :8000
```

---

## Target verification

Prometheus target:

```text
flask-app
```

was verified using:

```promql
up{job="flask-app"}
```

Result:

```text
1
```

Meaning:

```text
Prometheus can successfully scrape the Flask application.
```

---

## Request count query

```promql
app_http_requests_total
```

This returns request counters grouped by labels.

Example labels:

```text
endpoint="/"
method="GET"
status="200"
```

and:

```text
endpoint="/error"
method="GET"
status="500"
```

---

## Error query

```promql
app_http_errors_total
```

Example:

```text
app_http_errors_total{endpoint="/error"} 3
```

This means three requests to the error endpoint generated HTTP errors.

---

## Important observation about labels

Metrics using labels may not expose a particular labeled time series until that label combination has actually been used.

For example:

```text
app_http_errors_total{endpoint="/error"}
```

did not initially exist because no request had been sent to:

```text
/error
```

After generating an error request:

```bash
curl http://localhost:8000/error
```

the labeled Counter appeared.

---

## Latency query

Number of recorded latency observations:

```promql
app_http_request_duration_seconds_count
```

Total observed request duration:

```promql
app_http_request_duration_seconds_sum
```

---

## Average latency

Average latency can be calculated with:

```promql
rate(app_http_request_duration_seconds_sum[1m])
/
rate(app_http_request_duration_seconds_count[1m])
```

Mental model:

```text
total request duration per second
/
number of requests per second
=
average request duration
```

---

## Troubleshooting

During the lab the target temporarily showed:

```promql
up{job="flask-app"} = 0
```

The cause was that the Flask application was not running.

A local test confirmed the problem:

```bash
curl http://localhost:8000/metrics
```

returned a connection error.

After starting:

```bash
python app.py
```

the target changed back to:

```text
UP
```

This demonstrated an important troubleshooting workflow:

```text
Prometheus says target DOWN
↓
check target application
↓
check listening port
↓
check /metrics locally
↓
check connectivity from Prometheus
↓
check scrape configuration
```

---

## Complete monitoring flow

```text
HTTP request
↓
Flask endpoint
↓
application code updates metrics
↓
prometheus_client
↓
/metrics
↓
Prometheus scrapes every 5 seconds
↓
time series stored
↓
PromQL
```

---

## Key takeaways

```text
Application metrics
→ describe application behavior

Counter
→ requests and errors

Histogram
→ latency distribution

labels
→ split metrics by dimensions such as endpoint and status

/metrics
→ endpoint scraped by Prometheus

up = 1
→ scrape succeeds

up = 0
→ scrape fails
```

---

## Interview summary

Application instrumentation means adding metrics directly to application code.

In this lab a Flask application was instrumented using the Prometheus Python client.

Counters were used for HTTP requests and errors, while a Histogram was used for request latency.

Metrics were exposed through `/metrics` and scraped by Prometheus using a static target.

Labels such as HTTP method, endpoint and status code allow the same metric to represent multiple application dimensions.

The `up` metric was also used to diagnose a failed scrape when the Flask application was not running.
