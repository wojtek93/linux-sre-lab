# PRO-02 Prometheus Metric Types

## Goal

Understand and demonstrate the four main Prometheus metric types:

- Counter
- Gauge
- Histogram
- Summary

The lab also includes a small Python application exposing all four types through a `/metrics` endpoint.

---

## 1. Counter

A Counter is a metric that normally only increases.

Typical examples:

```text
number of HTTP requests
number of errors
number of processed jobs
number of login attempts
```

Example:

```text
demo_requests_total
```

Observed values:

```text
10
15
20
25
```

The value increases as more events happen.

A Counter may reset when the application process restarts.

Mental model:

```text
Counter
=
how many times something happened
```

Example Prometheus metric:

```text
http_requests_total
```

---

## 2. Gauge

A Gauge represents a value that can increase or decrease.

Typical examples:

```text
current memory usage
current temperature
active connections
queue size
number of logged-in users
```

Example:

```text
demo_active_users
```

Possible values:

```text
7
15
3
20
8
```

Mental model:

```text
Gauge
=
what is the current value?
```

---

## 3. Histogram

A Histogram measures the distribution of observed values.

A common use case is request duration.

Example:

```text
demo_request_duration_seconds
```

The Histogram divides observations into buckets.

Example buckets:

```text
<= 0.1 s
<= 0.2 s
<= 0.5 s
<= 1 s
<= 2 s
<= 5 s
```

Prometheus exposes them as metrics such as:

```text
demo_request_duration_seconds_bucket{le="0.1"}
demo_request_duration_seconds_bucket{le="0.2"}
demo_request_duration_seconds_bucket{le="0.5"}
demo_request_duration_seconds_bucket{le="1.0"}
demo_request_duration_seconds_bucket{le="2.0"}
demo_request_duration_seconds_bucket{le="5.0"}
demo_request_duration_seconds_bucket{le="+Inf"}
```

The label:

```text
le
```

means:

```text
less than or equal
```

Example:

```text
demo_request_duration_seconds_bucket{le="0.5"} 20
```

means:

```text
20 observations had a duration <= 0.5 seconds
```

---

## Histogram count and sum

Histogram also exposes:

```text
_count
_sum
```

Example:

```text
demo_request_duration_seconds_count 100
demo_request_duration_seconds_sum 42
```

This means:

```text
100 observations
total duration = 42 seconds
```

The average can be calculated as:

```text
sum / count
```

So:

```text
42 / 100
=
0.42 seconds
```

---

## 4. Summary

A Summary also measures observed values such as request duration.

Example:

```text
demo_request_summary_seconds
```

The general Prometheus Summary model can expose:

```text
count
sum
quantiles
```

Quantiles describe thresholds below which a given percentage of observations fall.

Examples:

```text
0.5
=
50th percentile / median

0.9
=
90th percentile

0.99
=
99th percentile
```

Example:

```text
p99 = 2.5 seconds
```

means:

```text
99% of observations were <= 2.5 seconds
```

and the slowest 1% were above that value.

---

## Python client note

In this lab we used the Python `prometheus_client` library.

Its default `Summary` implementation exposes mainly:

```text
_count
_sum
```

For example:

```text
demo_request_summary_seconds_count
demo_request_summary_seconds_sum
```

The Python client does not expose quantiles by default.

---

## Counter vs Gauge

The simplest distinction:

```text
Counter
→ only increases

Gauge
→ increases and decreases
```

Example:

```text
http_requests_total
→ Counter
```

because the total number of requests increases.

Example:

```text
active_users
→ Gauge
```

because users can connect and disconnect.

---

## Histogram vs Summary

Both can measure distributions such as request duration.

Simplified difference:

```text
Histogram
→ uses buckets

Summary
→ can calculate quantiles on the client side
```

Histogram example:

```text
How many requests were <= 0.5 seconds?
```

Summary example:

```text
What was the 99th percentile?
```

---

## Demo application

The lab uses a Python application exposing Prometheus metrics on:

```text
http://localhost:8000/metrics
```

Application:

```python
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
```

---

## Virtual environment

The Ubuntu system Python was configured as an externally managed environment.

Instead of installing packages globally, a virtual environment was used.

Install support:

```bash
sudo apt install python3-venv
```

Create virtual environment:

```bash
python3 -m venv .venv
```

Activate:

```bash
source .venv/bin/activate
```

Install dependency:

```bash
pip install prometheus-client
```

---

## Run the application

Start:

```bash
python app.py
```

The application starts the metrics HTTP server on:

```text
localhost:8000
```

---

## Inspect metrics

In another terminal:

```bash
curl http://localhost:8000/metrics
```

To show only demo metrics:

```bash
curl http://localhost:8000/metrics | grep demo_
```

Example metrics:

```text
demo_requests_total
demo_active_users

demo_request_duration_seconds_bucket
demo_request_duration_seconds_count
demo_request_duration_seconds_sum

demo_request_summary_seconds_count
demo_request_summary_seconds_sum
```

---

## Counter behavior test

Running:

```bash
curl http://localhost:8000/metrics | grep demo_requests_total
```

multiple times shows that:

```text
demo_requests_total
```

keeps increasing.

Example:

```text
10
15
20
```

This confirms Counter behavior.

---

## Gauge behavior test

Running:

```bash
curl http://localhost:8000/metrics | grep demo_active_users
```

multiple times can show values such as:

```text
7
16
4
11
```

The value can move in both directions.

This confirms Gauge behavior.

---

## Histogram behavior test

Histogram output contains several bucket metrics:

```text
demo_request_duration_seconds_bucket{le="0.1"}
demo_request_duration_seconds_bucket{le="0.2"}
demo_request_duration_seconds_bucket{le="0.5"}
demo_request_duration_seconds_bucket{le="1.0"}
demo_request_duration_seconds_bucket{le="2.0"}
demo_request_duration_seconds_bucket{le="5.0"}
demo_request_duration_seconds_bucket{le="+Inf"}
```

Buckets are cumulative.

That means:

```text
le="0.5"
```

includes all observations that were also:

```text
<= 0.1
<= 0.2
```

as well as observations between those values and 0.5 seconds.

---

## Complete mental model

```text
Application
↓
Prometheus client library
↓
metrics
↓
/metrics endpoint
```

Metrics:

```text
Counter
→ number of events

Gauge
→ current state

Histogram
→ distribution using buckets

Summary
→ distribution with count/sum and potentially quantiles
```

---

## When to use each type

### Counter

Use for:

```text
requests
errors
jobs processed
restarts
events
```

Question answered:

```text
How many times did something happen?
```

---

### Gauge

Use for:

```text
memory usage
active connections
queue length
temperature
current users
```

Question answered:

```text
What is the current state?
```

---

### Histogram

Use for:

```text
request latency
response size
job execution duration
```

Question answered:

```text
How are the observed values distributed?
```

Especially useful when you want to calculate percentiles later with PromQL.

---

### Summary

Use for:

```text
latency
duration
observed value distributions
```

Question answered:

```text
What are the client-calculated statistics or quantiles?
```

Support depends on the client library.

---

## Key takeaways

```text
Counter
= monotonically increasing value

Gauge
= current value that may rise or fall

Histogram
= observations grouped into cumulative buckets

Summary
= observed values represented using count/sum and optionally quantiles
```

For this lab:

```text
demo_requests_total
→ Counter

demo_active_users
→ Gauge

demo_request_duration_seconds
→ Histogram

demo_request_summary_seconds
→ Summary
```

---

## Interview summary

Prometheus supports several metric types for different monitoring use cases.

A Counter represents a cumulative value that normally increases, such as the total number of requests or errors.

A Gauge represents a current value that may increase or decrease, such as memory usage or the number of active connections.

A Histogram records observations in configurable cumulative buckets and also exposes a count and sum. It is commonly used for request latency and allows percentile calculations using PromQL.

A Summary also records observations and exposes count and sum. Depending on the client library, it may calculate quantiles on the client side.

Choosing the correct metric type is important because it determines how the metric should be interpreted and queried later in PromQL.
