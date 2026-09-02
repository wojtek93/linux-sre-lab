# PRO-14 Prometheus Alert Quality Review

## Goal

Improve an alert so that it produces less noise and contains more useful context for the SRE team.

---

## Before

Initial alert:

```yaml
groups:
  - name: application-alert-rules
    rules:
      - alert: HighErrorRate
        expr: |
          (
            sum(rate(app_http_requests_total{status="500"}[1m]))
            /
            sum(rate(app_http_requests_total[1m]))
          ) > 0.05
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "High HTTP error rate"
```

Problems:

```text
short [1m] window
→ reacts strongly to short spikes

for: 0m
→ alert can fire immediately

few labels
→ less context for routing

minimal annotations
→ less information for the engineer
```

---

## After

Improved alert:

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
        for: 5m
        labels:
          severity: warning
          service: flask-app
          team: sre
        annotations:
          summary: "Sustained high HTTP 5xx error rate"
          description: "More than 5% of requests have returned HTTP 500 responses for at least 5 minutes."
          runbook: "Check application logs, target health, recent deployments and resource usage."
```

---

## Improvements

### Longer query window

Changed:

```text
[1m]
```

to:

```text
[5m]
```

This makes the calculation less sensitive to very short traffic spikes.

---

## Alert duration

Changed:

```yaml
for: 0m
```

to:

```yaml
for: 5m
```

This means the error condition must remain true for five minutes before the alert becomes FIRING.

Mental model:

```text
short spike
→ condition may briefly become true
→ alert does not fire

sustained problem
→ condition stays true for 5 minutes
→ FIRING
```

---

## Better labels

Added:

```yaml
service: flask-app
team: sre
```

Labels provide useful context and can also be used for alert routing.

Example:

```text
service=flask-app
team=sre
severity=warning
```

---

## Better annotations

The improved alert contains:

```text
summary
description
runbook
```

This gives the engineer more information when the alert fires.

Instead of only seeing:

```text
High HTTP error rate
```

the engineer can immediately understand:

```text
what happened
how long it has been happening
which service is affected
what should be checked first
```

---

## Alert noise

Alert noise means receiving alerts that do not represent meaningful problems.

Examples:

```text
temporary spike
short deployment disturbance
single failed request
brief network interruption
```

A noisy alert can cause:

```text
too many notifications
↓
engineers start ignoring alerts
↓
real incidents may be missed
```

This is why alert quality is important in SRE.

---

## Good SRE alert

A useful alert should generally be:

```text
actionable
meaningful
stable
properly labeled
easy to understand
```

The goal is not to alert on every small abnormality.

The goal is to alert when a condition is important enough that an engineer should take action.

---

## Before vs After

```text
BEFORE

1 minute window
for: 0m
few labels
minimal description

→ more sensitive
→ more noise
```

```text
AFTER

5 minute window
for: 5m
service/team labels
better description and runbook

→ more stable
→ more actionable
→ less noise
```

---

## Validation

The improved rule was validated using:

```bash
docker run --rm \
  -v "$(pwd)/alerts.yml:/etc/prometheus/alerts.yml" \
  --entrypoint promtool \
  prom/prometheus \
  check rules /etc/prometheus/alerts.yml
```

Result:

```text
SUCCESS
```

---

## Key takeaways

```text
short window
→ reacts faster but can be noisy

longer window
→ more stable signal

for duration
→ prevents immediate firing

labels
→ classify and route alerts

annotations
→ explain the problem to the engineer
```

---

## Interview summary

I improved a Prometheus alert to reduce alert noise.

The original alert used a one-minute rate window and could fire immediately.

I changed it to use a five-minute window and required the condition to remain true for five minutes before firing.

I also added service and team labels and improved the annotations so the alert provides enough context for the engineer responding to the incident.

The goal was to make the alert more stable and actionable instead of reacting to short temporary spikes.
