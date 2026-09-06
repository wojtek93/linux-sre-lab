# GRA-04 — Golden Signals Monitoring

## Goal

Build and use a Grafana dashboard based on the Four Golden Signals:

- Latency
- Traffic
- Errors
- Saturation

The dashboard monitors the Production Application SRE Lab and is used not only for visualization, but also for practical troubleshooting.

---

## Dashboard

Dashboard name:

```text
Production App Golden Signals
```

The dashboard was created from the existing Production App Overview dashboard and reorganized around the Four Golden Signals.

---

# 1. Traffic

Panel:

```text
Traffic — Request Rate
```

Query:

```promql
sum(rate(app_requests_total[5m]))
```

Traffic shows how many requests the application is processing.

A sudden increase or decrease may indicate:

- increased user activity
- unexpected load
- traffic loss
- upstream problems

---

# 2. Errors

Panel:

```text
Errors — 5xx Error Rate
```

Query:

```promql
sum(rate(app_requests_total{status=~"5.."}[5m]))
```

This shows the rate of HTTP 5xx responses.

Controlled errors were generated using:

```bash
for i in {1..10}; do
  curl -s http://127.0.0.1:8000/error > /dev/null
done
```

The dashboard showed an increase in error rate.

---

## Error Investigation

To identify which endpoint generated the errors, the metric was grouped by endpoint:

```promql
sum by (endpoint) (
  rate(app_requests_total{status=~"5.."}[5m])
)
```

The result identified:

```text
/error
```

as the endpoint generating HTTP 500 responses.

Application logs confirmed:

```text
GET /error HTTP/1.1" 500
```

This created the troubleshooting flow:

```text
Grafana
→ Errors increased
→ PromQL grouped by endpoint
→ /error identified
→ application logs confirmed HTTP 500
```

---

## Current vs Historical Errors

A five-minute window was compared with a one-minute window.

Broader trend:

```promql
sum(rate(app_requests_total{status=~"5.."}[5m]))
```

Current state:

```promql
sum(rate(app_requests_total{status=~"5.."}[1m]))
```

The one-minute query returned to zero while the five-minute query still contained the previous spike.

Conclusion:

```text
The error burst was temporary and was no longer occurring.
```

Useful operational pattern:

```text
5m = broader trend and context
1m = what is happening now
```

---

# 3. Latency

Panel:

```text
Latency — p95
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

p95 latency shows the response time below which approximately 95% of requests complete.

Controlled slow requests were generated using:

```bash
for i in {1..10}; do
  curl -s http://127.0.0.1:8000/slow > /dev/null
done
```

---

## Latency Investigation

To identify which endpoint was slow:

```promql
histogram_quantile(
  0.95,
  sum by (le, endpoint) (
    rate(app_request_latency_seconds_bucket[5m])
  )
)
```

The result showed that:

```text
/slow
```

had significantly higher p95 latency than the other endpoints.

This allowed the problem to be isolated to a specific endpoint instead of assuming that the whole application was slow.

---

## Current vs Historical Latency

The same query was repeated with a shorter window:

```promql
histogram_quantile(
  0.95,
  sum by (le, endpoint) (
    rate(app_request_latency_seconds_bucket[1m])
  )
)
```

The high latency disappeared from the current one-minute window.

Conclusion:

```text
The latency problem was temporary and was no longer active.
```

Troubleshooting flow:

```text
Grafana
→ high p95 detected
→ latency grouped by endpoint
→ /slow identified
→ shorter time window checked
→ spike confirmed as temporary
```

---

# 4. Saturation

Saturation shows how close system resources are to their limits.

Two infrastructure panels were used:

```text
Saturation — CPU Usage
Saturation — Memory Usage
```

---

## CPU

Query:

```promql
instance:node_cpu_usage:rate5m
```

Artificial CPU load was generated using:

```bash
for i in {1..4}; do
  yes > /dev/null &
done
```

Grafana showed an increase in CPU utilization.

To identify the processes consuming CPU:

```bash
ps -eo pid,comm,%cpu --sort=-%cpu | head
```

The output showed multiple:

```text
yes
```

processes using large amounts of CPU.

The artificial load was stopped with:

```bash
pkill yes
```

The process list was checked again:

```bash
ps -eo pid,comm,%cpu --sort=-%cpu | head
```

and the high-CPU processes were gone.

---

## Important Saturation Lesson

High CPU by itself does not explain the root cause.

Grafana tells us:

```text
CPU usage increased
```

Linux tools help answer:

```text
Which process is using the CPU?
```

Operational flow:

```text
Grafana
→ CPU anomaly
→ Linux process inspection
→ responsible process identified
→ mitigation
→ verification
```

---

## Memory

Query:

```promql
instance:node_memory_usage_percent
```

Memory usage remained relatively stable during the CPU test.

This was important because it showed that the observed saturation was mainly CPU-related rather than a general resource exhaustion problem.

---

# Generating Test Traffic

Normal traffic:

```bash
for i in {1..30}; do
  curl -s http://127.0.0.1:8000/ > /dev/null
done
```

HTTP 500 errors:

```bash
for i in {1..10}; do
  curl -s http://127.0.0.1:8000/error > /dev/null
done
```

Slow requests:

```bash
for i in {1..10}; do
  curl -s http://127.0.0.1:8000/slow > /dev/null
done
```

These tests created visible changes in the Golden Signals dashboard.

---

# Monitoring Troubleshooting — Time Drift

During the lab Grafana unexpectedly showed:

```text
No data
```

even though:

- the application was running
- Prometheus was running
- node_exporter was running

Prometheus target health showed:

```text
application    UP
node_exporter  UP
prometheus     UP
```

Prometheus then reported:

```text
Server time is out of sync
```

The VM clock was inspected with:

```bash
timedatectl
```

It showed:

```text
System clock synchronized: no
NTP service: active
```

Time synchronization was restored.

This demonstrated an important troubleshooting lesson:

```text
No data does not always mean the application is down.
```

Monitoring systems depend heavily on correct timestamps.

A useful troubleshooting sequence is:

```text
No data
→ check application
→ check Prometheus targets
→ check Prometheus directly
→ check VM time synchronization
→ check Grafana
```

---

# Golden Signals Interpretation

## Latency

How long requests take.

Questions:

```text
Is latency increasing?
Does it affect the entire application or one endpoint?
Is the problem still happening?
```

## Traffic

How much work the system is receiving.

Questions:

```text
Did traffic increase?
Did traffic suddenly disappear?
Does traffic correlate with other problems?
```

## Errors

How many requests are failing.

Questions:

```text
Which HTTP status codes increased?
Which endpoint is failing?
Is the failure continuous or temporary?
```

## Saturation

How close resources are to their limits.

Questions:

```text
Is CPU high?
Is memory increasing?
Which process is consuming resources?
Is resource pressure affecting latency or errors?
```

---

# Practical Troubleshooting Pattern

The main operational pattern practiced in this lab was:

```text
1. Observe the dashboard
2. Identify the abnormal signal
3. Narrow the metric down
4. Correlate it with another signal
5. Move one level deeper
6. Identify the source
7. Mitigate
8. Verify recovery
```

Examples:

```text
Errors
→ endpoint
→ logs

Latency
→ endpoint
→ current vs historical window

CPU
→ Linux processes
→ mitigation
→ verification
```

---

# Interview Context

A useful explanation:

> I use the Four Golden Signals to understand the health of a service: latency, traffic, errors and saturation. If I see an anomaly, I first correlate the metrics and then narrow the investigation down. For example, I can group errors or latency by endpoint, inspect application logs, or move to the operating system level to identify processes consuming CPU.

Another useful statement:

> I would monitor not only hard failures, but also trends that may indicate an upcoming issue, such as increasing latency, error rate or resource saturation.

---

# Dashboard Export

The Grafana dashboard was exported as:

```text
production-app-golden-signals.json
```

Training artifact:

```text
grafana/04-golden-signals/production-app-golden-signals.json
```

Production Application SRE Lab copy:

```text
production-app/monitoring/grafana/production-app-golden-signals.json
```

---

# Result

GRA-04 completed successfully.

Practiced:

- Four Golden Signals
- traffic analysis
- HTTP 5xx analysis
- error investigation by endpoint
- application log correlation
- p95 latency
- latency investigation by endpoint
- short vs long PromQL time windows
- CPU saturation
- Linux process investigation
- mitigation and verification
- memory monitoring
- Prometheus target troubleshooting
- VM time drift troubleshooting
- practical Grafana → Prometheus → Linux investigation flow
