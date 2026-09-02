# PRO-10 Prometheus HTTP 5xx Error Rate

## Goal

Calculate the HTTP 5xx error ratio using PromQL.

---

## What is error rate?

Error rate tells us what part of all requests ended with an error.

Example:

```text
100 total requests
5 errors

error rate = 5%
```

Formula:

```text
errors
/
all requests
=
error ratio
```

---

## Error request rate

Query:

```promql
sum(rate(app_http_requests_total{status="500"}[5m]))
```

This calculates the per-second rate of HTTP 500 responses.

Mental model:

```text
HTTP 500 Counter
↓
rate()
↓
errors per second
```

---

## Total request rate

Query:

```promql
sum(rate(app_http_requests_total[5m]))
```

This calculates the per-second rate of all requests.

Mental model:

```text
all request Counters
↓
rate()
↓
requests per second
```

---

## Error ratio

Query:

```promql
sum(rate(app_http_requests_total{status="500"}[5m]))
/
sum(rate(app_http_requests_total[5m]))
```

This returns a ratio.

Example:

```text
0.05
```

means:

```text
5%
```

---

## Error percentage

To return the result directly as a percentage:

```promql
100 *
sum(rate(app_http_requests_total{status="500"}[5m]))
/
sum(rate(app_http_requests_total[5m]))
```

Example:

```text
20
```

means:

```text
20% of requests ended with HTTP 500
```

---

## Lab traffic

Traffic was generated using:

```bash
for i in {1..20}; do
  curl -s http://localhost:8000/ > /dev/null
done
```

Errors were generated using:

```bash
for i in {1..5}; do
  curl -s http://localhost:8000/error > /dev/null
done
```

Example:

```text
20 successful requests
5 failed requests
25 total requests
```

Error ratio:

```text
5 / 25
=
0.20
```

Error percentage:

```text
20%
```

---

## Why use rate()?

`app_http_requests_total` is a Counter.

The Counter contains the cumulative number of requests.

Example:

```text
100
120
150
180
```

For monitoring, we usually care about what happened recently.

Therefore:

```promql
rate(...[5m])
```

calculates how quickly the Counter increased over the last five minutes.

---

## Why divide error rate by total rate?

The absolute number of errors alone can be misleading.

Example:

```text
100 errors out of 1,000,000 requests
```

is very different from:

```text
100 errors out of 200 requests
```

The error ratio gives context.

Mental model:

```text
number of errors
+
total traffic
↓
error ratio
```

---

## Practical SRE use

Error rate can be used for:

```text
dashboards
alerts
SLIs
SLO monitoring
incident detection
```

Example alert idea:

```text
error rate > 5%
for 5 minutes
```

could indicate a service degradation.

---

## Key takeaways

```text
error rate
=
failed request rate
/
total request rate
```

```text
0.01
=
1%
```

```text
0.05
=
5%
```

```text
0.20
=
20%
```

---

## Interview summary

I calculated HTTP error rate in Prometheus by dividing the rate of HTTP 5xx requests by the rate of all HTTP requests.

For example:

```promql
sum(rate(app_http_requests_total{status="500"}[5m]))
/
sum(rate(app_http_requests_total[5m]))
```

This gives the proportion of traffic that ends with an HTTP 500 response.

I also multiplied the ratio by 100 when I wanted the result directly as a percentage.
