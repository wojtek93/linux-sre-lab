# PRO-13 Prometheus Alert Rules

## Goal

Create and test a Prometheus alert for sustained high HTTP error rate.

---

## What is an alert rule?

An alert rule evaluates a PromQL condition.

If the condition is true for a configured amount of time, the alert changes state.

Mental model:

```text
metric condition
↓
PENDING
↓
condition stays true
↓
FIRING
```

---

## Alert definition

```yaml
groups:
  - name: application-alert-rules
    rules:
      - alert: HighErrorRate
        expr: |
          (
            sum(rate(app_http_requests_total{status="500"}[5m]))
            /
            sum(rate(app_http_requests_total[5m]))
          ) > 0.05
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High HTTP error rate"
          description: "HTTP 5xx error rate is above 5% for 2 minutes."
```

---

## Expression

The alert checks:

```promql
sum(rate(app_http_requests_total{status="500"}[5m]))
/
sum(rate(app_http_requests_total[5m]))
```

This calculates the HTTP error ratio.

The condition:

```text
> 0.05
```

means:

```text
error rate > 5%
```

---

## for: 2m

```yaml
for: 2m
```

means that the condition must remain true for two minutes.

This prevents short spikes from immediately triggering an alert.

---

## Alert states

### Inactive

The condition is false.

```text
error rate <= 5%
```

### Pending

The condition is true, but the configured duration has not yet passed.

```text
error rate > 5%
↓
PENDING
```

### Firing

The condition remained true for the full configured duration.

```text
error rate > 5%
for 2 minutes
↓
FIRING
```

---

## Labels

```yaml
labels:
  severity: warning
```

Labels help classify and route alerts.

Example:

```text
severity=warning
```

---

## Annotations

```yaml
annotations:
  summary: "High HTTP error rate"
  description: "HTTP 5xx error rate is above 5% for 2 minutes."
```

Annotations provide readable information for the engineer responding to the alert.

---

## Validation

The alert file was validated using:

```bash
docker run --rm \
  -v "$(pwd)/alerts.yml:/etc/prometheus/alerts.yml" \
  --entrypoint promtool \
  prom/prometheus \
  check rules /etc/prometheus/alerts.yml
```

Expected result:

```text
SUCCESS
```

---

## Prometheus configuration

The alert rule file was loaded using:

```yaml
rule_files:
  - "/etc/prometheus/alerts.yml"
```

---

## Test procedure

Errors were generated intentionally:

```bash
while true; do
  curl -s http://localhost:8000/error > /dev/null
  sleep 1
done
```

This increased the HTTP 500 error rate above the 5% threshold.

The alert first changed to:

```text
PENDING
```

After the condition stayed above the threshold for two minutes, it changed to:

```text
FIRING
```

The test traffic was stopped using:

```text
Ctrl+C
```

---

## Why `for:` is useful

Without:

```yaml
for: 2m
```

a short error spike could immediately trigger the alert.

With the duration configured:

```text
temporary spike
→ no firing alert

sustained problem
→ firing alert
```

This helps reduce alert noise.

---

## Practical SRE use

Alert rules can be used to detect:

```text
high error rate
high latency
service unavailability
target down
resource exhaustion
SLO violations
```

---

## Key takeaways

```text
expr
→ condition to evaluate

for
→ how long the condition must stay true

labels
→ classify the alert

annotations
→ human-readable description

PENDING
→ condition is true but duration has not passed

FIRING
→ condition stayed true long enough
```

---

## Interview summary

I created and tested a Prometheus alert rule for sustained HTTP 5xx error rate.

The alert calculated the ratio of HTTP 500 requests to all requests and triggered when the error rate stayed above 5% for two minutes.

I tested the rule by generating HTTP 500 traffic and observed the alert transition from PENDING to FIRING.

Using a `for` duration helps avoid alerts caused by short temporary spikes.
