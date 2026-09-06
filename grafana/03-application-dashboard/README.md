# GRA-03 — Production App Overview Dashboard

## Goal

Build the first Grafana application overview dashboard for the Production Application SRE Lab.

The dashboard is based on real metrics collected by Prometheus from:

- Production Flask application
- node_exporter
- Prometheus

---

## Production Application

The monitored application is located in:

```text
production-app/app/
```

The application exposes:

```text
/
```

Normal HTTP 200 response.

```text
/error
```

Controlled HTTP 500 response used for monitoring tests.

```text
/slow
```

Artificially delayed response used for latency tests.

```text
/metrics
```

Prometheus metrics endpoint.

---

## Application Metrics

The application exposes a request counter:

```text
app_requests_total
```

with labels:

```text
method
endpoint
status
```

Example:

```promql
app_requests_total{status="500"}
```

The application also exposes request latency as a Prometheus histogram:

```text
app_request_latency_seconds
```

---

## Dashboard

Dashboard name:

```text
Production App Overview
```

The dashboard contains six panels.

---

## 1. Application Status

Visualization:

```text
Stat
```

Query:

```promql
up{job="application"}
```

Interpretation:

```text
1 = Prometheus can successfully scrape the application
0 = Prometheus cannot scrape the application
```

---

## 2. Request Rate

Visualization:

```text
Time series
```

Query:

```promql
rate(app_requests_total[5m])
```

This shows the request rate handled by the application.

---

## 3. Error Rate

Visualization:

```text
Time series
```

Query:

```promql
sum(rate(app_requests_total{status=~"5.."}[5m]))
```

This shows how frequently HTTP 5xx errors are occurring.

Important lesson:

`rate()` does not show the total number of errors.

It shows the average rate per second calculated over the selected time window.

For example:

```text
5 errors / 300 seconds ≈ 0.0167 errors per second
```

To see the total number of HTTP 500 responses:

```promql
sum(app_requests_total{status="500"})
```

---

## 4. p95 Latency

Visualization:

```text
Time series
```

Query:

```promql
histogram_quantile(
  0.95,
  sum by (le) (
    rate(app_request_latency_seconds_bucket[5m])
  )
)
```

p95 means that approximately 95% of requests completed faster than the displayed value, while the slowest 5% took longer.

This is useful for detecting degraded user experience even when average latency still looks acceptable.

---

## 5. Node CPU Usage

Visualization:

```text
Time series
```

Query:

```promql
instance:node_cpu_usage:rate5m
```

This metric is based on a Prometheus recording rule created in the previous monitoring labs.

It is useful for observing resource saturation.

---

## 6. Node Memory Usage

Visualization:

```text
Time series
```

Query:

```promql
instance:node_memory_usage_percent
```

This shows host memory utilization.

---

## Generated Traffic

Normal requests were generated using:

```bash
for i in {1..20}; do
  curl -s http://127.0.0.1:8000/ > /dev/null
done
```

HTTP 500 errors:

```bash
for i in {1..5}; do
  curl -s http://127.0.0.1:8000/error > /dev/null
done
```

Slow requests:

```bash
for i in {1..5}; do
  curl -s http://127.0.0.1:8000/slow > /dev/null
done
```

This allowed the dashboard to display real application behavior instead of static example data.

---

## Troubleshooting Lesson

Initially the Error Rate panel returned:

```text
No data
```

The original application metric did not contain a `status` label.

The metric was inspected first:

```promql
app_requests_total
```

The application instrumentation was then extended to include:

```text
method
endpoint
status
```

This demonstrated an important monitoring principle:

> Never assume that a metric contains a particular label. Inspect the actual metric schema before writing PromQL queries.

---

## Observability Context

The dashboard already covers several important operational signals:

### Availability

```promql
up{job="application"}
```

### Traffic

```promql
rate(app_requests_total[5m])
```

### Errors

```promql
sum(rate(app_requests_total{status=~"5.."}[5m]))
```

### Latency

```promql
histogram_quantile(
  0.95,
  sum by (le) (
    rate(app_request_latency_seconds_bucket[5m])
  )
)
```

### Saturation

CPU and memory utilization from node_exporter.

These metrics form the foundation for later Golden Signals and production incident scenarios.

---

## Architecture

```text
Production Application
        |
        | /metrics
        v
    Prometheus
        |
        | PromQL
        v
      Grafana
        |
        v
Production App Overview Dashboard
```

---

## Dashboard Export

The dashboard was exported as JSON:

```text
production-app-overview.json
```

The training artifact is stored in:

```text
grafana/03-application-dashboard/production-app-overview.json
```

The live project copy is stored
