# PRO-01 Prometheus Concepts

## Goal

Understand the core concepts behind Prometheus monitoring:

- pull model
- targets
- exporters
- time series
- labels
- scraping
- `/metrics` endpoints

---

## 1. Pull model

Prometheus mainly uses a pull model.

That means Prometheus actively connects to monitored applications or exporters and retrieves metrics from them.

```text
Prometheus
↓
GET /metrics
↓
application / exporter
↓
metrics returned
```

The application does not normally need to push metrics directly to Prometheus.

Example:

```text
Prometheus
↓ every 15 seconds
http://my-app:8080/metrics
↓
metrics
```

The process of collecting metrics from a target is called a:

```text
scrape
```

---

## 2. Target

A target is an endpoint that Prometheus monitors and scrapes.

Examples:

```text
my-app:8080
node-exporter:9100
```

Prometheus expects to be able to retrieve metrics from the target, usually from:

```text
/metrics
```

Example configuration:

```yaml
scrape_configs:
  - job_name: "my-app"
    scrape_interval: 15s
    static_configs:
      - targets:
          - "my-app:8080"
```

In this example:

```text
my-app:8080
```

is the target.

---

## 3. Exporter

An exporter is a program that exposes metrics in a format Prometheus understands.

Example:

```text
Linux server
↓
node_exporter
↓
/metrics
↓
Prometheus
```

`node_exporter` exposes host-level metrics such as:

```text
CPU
memory
disk
filesystem
network
load
```

Typical endpoint:

```text
node-exporter:9100/metrics
```

Mental model:

```text
system
↓
exporter
↓
Prometheus metrics
↓
Prometheus
```

---

## 4. Time series

Prometheus stores metric values over time.

Example:

```text
http_requests_total

17:00:00 → 100
17:00:15 → 125
17:00:30 → 160
```

Each sample contains:

```text
timestamp + value
```

A time series lets us answer questions such as:

```text
How did CPU usage change?
How many requests were received over time?
Is memory usage increasing?
How many errors occurred during the last 5 minutes?
```

---

## 5. Labels

Labels add dimensions to metrics.

Example metric:

```text
http_requests_total
```

can have different labels:

```text
http_requests_total{method="GET",status="200"} 1520
http_requests_total{method="GET",status="500"} 12
http_requests_total{method="POST",status="200"} 300
```

Labels allow Prometheus to distinguish different time series.

Example:

```text
http_requests_total{method="GET",status="200"}
```

and:

```text
http_requests_total{method="GET",status="500"}
```

are separate time series even though the metric name is the same.

Mental model:

```text
metric name
+
labels
=
specific time series
```

---

## 6. Scrape

A scrape is one metric collection operation performed by Prometheus.

Example:

```text
Prometheus
↓
GET /metrics
↓
target returns current metrics
↓
Prometheus stores samples
```

With:

```yaml
scrape_interval: 15s
```

Prometheus performs a scrape every 15 seconds.

---

## 7. Complete example

Application endpoint:

```text
http://my-app:8080/metrics
```

Returned metrics:

```text
http_requests_total{method="GET",status="200"} 1520
http_requests_total{method="GET",status="500"} 12
```

Prometheus configuration:

```yaml
scrape_configs:
  - job_name: "my-app"
    scrape_interval: 15s
    static_configs:
      - targets:
          - "my-app:8080"
```

Flow:

```text
Prometheus
↓ every 15 seconds
my-app:8080
↓
GET /metrics
↓
metrics returned
↓
samples stored as time series
```

Breakdown:

```text
my-app:8080
= target

GET /metrics every 15 seconds
= scrape / pull model

http_requests_total
= metric name

method="GET"
status="500"
= labels

values collected every 15 seconds
= time series
```

---

## 8. Full Prometheus mental model

```text
Application / Server
↓
Exporter or native /metrics endpoint
↓
Target
↓
Prometheus scrape
↓
Time series
↓
Labels distinguish series
↓
PromQL
↓
Grafana / Alerts
```

---

## Key takeaways

```text
Prometheus mainly pulls metrics

Target = monitored endpoint

Exporter = program exposing metrics

Scrape = one metric collection cycle

Time series = metric values collected over time

Labels = dimensions that distinguish series

/metrics = common endpoint used by Prometheus
```

---

## Interview summary

Prometheus primarily uses a pull-based monitoring model.

It periodically scrapes configured targets, usually by requesting a `/metrics` endpoint.

Targets can be applications that expose Prometheus metrics directly or exporters such as `node_exporter`.

Prometheus stores collected samples as time series.

Labels add dimensions to metrics and allow one metric name to represent multiple independent time series.

For example:

```text
http_requests_total{method="GET",status="200"}
```

and:

```text
http_requests_total{method="GET",status="500"}
```

are separate time series.
