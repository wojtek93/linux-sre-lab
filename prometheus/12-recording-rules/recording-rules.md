# PRO-12 Prometheus Recording Rules

## Goal

Create recording rules for commonly used PromQL queries.

---

## What is a recording rule?

A recording rule lets Prometheus regularly evaluate a PromQL expression and store the result as a new time series.

Instead of repeatedly running:

```promql
sum(rate(app_http_requests_total[5m]))
```

Prometheus can store the result as:

```text
app:http_requests:rate5m
```

Mental model:

```text
complex PromQL
↓
recording rule
↓
Prometheus evaluates it regularly
↓
result is stored as a new metric
↓
future queries are shorter and faster
```

---

## rules.yml

```yaml
groups:
  - name: application-recording-rules
    rules:
      - record: app:http_requests:rate5m
        expr: sum(rate(app_http_requests_total[5m]))

      - record: app:http_errors:rate5m
        expr: sum(rate(app_http_requests_total{status="500"}[5m]))

      - record: app:availability:ratio5m
        expr: |
          sum(rate(app_http_requests_total{status="200"}[5m]))
          /
          sum(rate(app_http_requests_total[5m]))
```

---

## Rule validation

The rules file was validated using `promtool`:

```bash
docker run --rm \
  -v "$(pwd)/rules.yml:/etc/prometheus/rules.yml" \
  --entrypoint promtool \
  prom/prometheus \
  check rules /etc/prometheus/rules.yml
```

Expected result:

```text
SUCCESS
```

---

## Loading the rules into Prometheus

The Prometheus configuration was extended with:

```yaml
rule_files:
  - "/etc/prometheus/rules.yml"
```

The Prometheus container was started with both configuration files mounted:

```bash
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  --add-host=host.docker.internal:host-gateway \
  -v "$(pwd)/../04-scrape-config/prometheus.yml:/etc/prometheus/prometheus.yml" \
  -v "$(pwd)/rules.yml:/etc/prometheus/rules.yml" \
  prom/prometheus
```

---

## Recorded metrics

### Request rate

```promql
app:http_requests:rate5m
```

Equivalent expression:

```promql
sum(rate(app_http_requests_total[5m]))
```

---

### Error rate

```promql
app:http_errors:rate5m
```

Equivalent expression:

```promql
sum(rate(app_http_requests_total{status="500"}[5m]))
```

---

### Availability ratio

```promql
app:availability:ratio5m
```

Equivalent expression:

```promql
sum(rate(app_http_requests_total{status="200"}[5m]))
/
sum(rate(app_http_requests_total[5m]))
```

---

## Why recording rules are useful

Recording rules are useful when the same PromQL query is used repeatedly.

Typical use cases:

```text
dashboards
alerts
SLIs
SLO calculations
expensive aggregations
frequently reused queries
```

They improve readability and can reduce repeated query computation.

---

## Troubleshooting performed

During the lab, the recording rules were loaded correctly, but queries initially returned no data.

The configuration was verified using:

```text
Status → Rules
```

and:

```text
Status → Configuration
```

The Flask application and Prometheus target configuration were also checked.

A time synchronization problem on the Linux VM was discovered.

The VM used `chrony`, and the system clock had a significant offset.

The clock was corrected using:

```bash
sudo chronyc makestep
```

After correcting the system time and restarting Prometheus, the recording rules started returning data.

This showed why accurate time synchronization is important for monitoring systems such as Prometheus.

---

## Key takeaways

```text
recording rule
→ precomputes PromQL

record
→ name of the new metric

expr
→ PromQL expression being evaluated

rule_files
→ tells Prometheus where the rules are stored
```

---

## Interview summary

I used Prometheus recording rules to precompute commonly used PromQL expressions such as request rate, error rate and availability.

For example, instead of repeatedly calculating:

```promql
sum(rate(app_http_requests_total[5m]))
```

I created a recording rule that stored the result as:

```text
app:http_requests:rate5m
```

This makes dashboards and alerts easier to read and avoids repeatedly evaluating the same expressions.
