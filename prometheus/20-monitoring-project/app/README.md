# PRO-20 — Reusable Prometheus Monitoring Project

## Goal

Build a reusable Prometheus monitoring setup for:

- application metrics
- host metrics
- recording rules
- alerting rules
- basic production-style monitoring

## Architecture

```text
Flask Application :8000
        |
        | /metrics
        v
    Prometheus :9090
        |
        +---- node_exporter :9100
        |
        +---- recording rules
        |
        +---- alert rules
```

## Project Structure

```text
20-monitoring-project/
├── app/
│   ├── app.py
│   └── requirements.txt
└── prometheus/
    ├── prometheus.yml
    └── rules/
        ├── alerts.yml
        └── recording_rules.yml
```

## Flask Application

The application exposes:

- `/` — basic application endpoint
- `/metrics` — Prometheus metrics endpoint

Custom application metric:

```text
app_requests_total
```

The counter increases every time the `/` endpoint is called.

Example:

```bash
curl http://localhost:8000/
curl http://localhost:8000/metrics
```

## Prometheus Targets

Prometheus scrapes three targets:

```text
prometheus
application
node_exporter
```

Prometheus configuration:

```yaml
global:
  scrape_interval: 15s

rule_files:
  - "rules/*.yml"

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "application"
    static_configs:
      - targets: ["host.docker.internal:8000"]

  - job_name: "node_exporter"
    static_configs:
      - targets: ["host.docker.internal:9100"]
```

## node_exporter

node_exporter exposes Linux host metrics including:

- CPU
- memory
- filesystem
- network
- system load

Metrics endpoint:

```text
http://localhost:9100/metrics
```

## Recording Rules

Recording rules calculate PromQL expressions and store the results as new time series.

Configured recording rules:

```text
job:app_requests_total:rate5m
instance:node_cpu_usage:rate5m
instance:node_memory_usage_percent
```

Example:

```promql
rate(app_requests_total[5m])
```

This calculates the average request rate over the last 5 minutes.

CPU usage is calculated from idle CPU time:

```promql
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

Memory usage:

```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

## Alert Rules

Configured alerts:

### ApplicationDown

Triggered when the Flask application cannot be scraped for more than 1 minute.

```promql
up{job="application"} == 0
```

### NodeExporterDown

Triggered when node_exporter cannot be scraped for more than 1 minute.

```promql
up{job="node_exporter"} == 0
```

### HighCPUUsage

Triggered when CPU usage is above 80% for 5 minutes.

```promql
instance:node_cpu_usage:rate5m > 80
```

### HighMemoryUsage

Triggered when memory usage is above 85% for 5 minutes.

```promql
instance:node_memory_usage_percent > 85
```

### DiskSpaceLow

Triggered when less than 15% filesystem space remains available.

## Alert Lifecycle

Prometheus alert states:

```text
INACTIVE
   |
   v
PENDING
   |
   v
FIRING
   |
   v
RESOLVED
```

The `for:` parameter prevents alerts from firing immediately.

Example:

```yaml
for: 1m
```

The alert condition must remain true for one minute before the alert becomes `FIRING`.

## ApplicationDown Test

The Flask application was manually stopped to simulate a production failure.

Observed flow:

```text
Application stopped
        |
        v
Prometheus scrape fails
        |
        v
Target becomes DOWN
        |
        v
ApplicationDown = PENDING
        |
        | after 1 minute
        v
ApplicationDown = FIRING
        |
        v
Application restored
        |
        v
Target returns to UP
        |
        v
Alert resolves
```

This demonstrates a basic production monitoring and incident detection flow.

## Docker Networking

Prometheus runs inside a Docker container while the application and node_exporter run on the Linux VM host.

Inside the Prometheus container:

```text
localhost
```

means the Prometheus container itself.

It does not mean the Linux VM host.

Therefore host services are accessed through:

```text
host.docker.internal
```

The Prometheus container is started with:

```bash
docker run --rm \
  --name prometheus-pro20 \
  --add-host=host.docker.internal:host-gateway \
  -p 9090:9090 \
  -v "$PWD/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro" \
  -v "$PWD/prometheus/rules:/etc/prometheus/rules:ro" \
  prom/prometheus
```

## Useful Endpoints

Prometheus:

```text
http://<VM-IP>:9090
```

Targets:

```text
http://<VM-IP>:9090/targets
```

Rules:

```text
http://<VM-IP>:9090/rules
```

Alerts:

```text
http://<VM-IP>:9090/alerts
```

Application:

```text
http://<VM-IP>:8000
```

Application metrics:

```text
http://<VM-IP>:8000/metrics
```

node_exporter metrics:

```text
http://<VM-IP>:9100/metrics
```

## Skills Practiced

- Prometheus configuration
- Prometheus scrape targets
- Flask application metrics
- node_exporter
- PromQL
- recording rules
- alert rules
- alert lifecycle
- Docker networking
- monitoring Linux host metrics
- application availability monitoring
- production-style troubleshooting
- incident detection
