# PRO-11 Availability SLI

## Goal

Create a basic availability SLI using successful HTTP requests.

---

## What is availability?

Availability tells us what percentage of requests were successful.

Example:

```text
100 total requests
98 successful requests
2 failed requests
```

Then:

```text
availability = 98%
```

---

## SLI

SLI means:

```text
Service Level Indicator
```

It is a measurable value describing service performance.

In this lab the SLI is:

```text
successful HTTP request ratio
```

---

## Successful request rate

Query:

```promql
sum(rate(app_http_requests_total{status="200"}[5m]))
```

This calculates the rate of successful HTTP requests.

---

## Total request rate

Query:

```promql
sum(rate(app_http_requests_total[5m]))
```

This calculates the rate of all HTTP requests.

---

## Availability ratio

Query:

```promql
sum(rate(app_http_requests_total{status="200"}[5m]))
/
sum(rate(app_http_requests_total[5m]))
```

Example result:

```text
0.98
```

means:

```text
98% availability
```

---

## Availability percentage

Query:

```promql
100 *
sum(rate(app_http_requests_total{status="200"}[5m]))
/
sum(rate(app_http_requests_total[5m]))
```

Example:

```text
96
```

means:

```text
availability = 96%
```

---

## Mental model

```text
successful requests
/
all requests
× 100
=
availability %
```

---

## Relationship to error rate

If:

```text
error rate = 5%
```

then approximately:

```text
availability = 95%
```

For this simple lab:

```text
availability
=
1 - error ratio
```

or in percentage form:

```text
availability %
=
100% - error %
```

---

## Why use rate()?

The request metric is a Counter.

The raw Counter tells us how many requests have occurred in total.

Using:

```promql
rate(...[5m])
```

lets us calculate recent request activity over a five-minute window.

---

## Practical SRE use

Availability SLI can be used for:

```text
SLO monitoring
dashboards
alerts
error budgets
service reliability reporting
```

Example:

```text
SLI = 99.95%
```

can be compared against an SLO such as:

```text
SLO = 99.9%
```

---

## Important limitation

In this simple lab only HTTP 200 is treated as successful.

In a real application, other successful HTTP statuses may also be valid, such as:

```text
201
202
204
```

The exact definition of success depends on the service.

---

## Key takeaways

```text
SLI
→ measurable reliability indicator

availability
→ successful requests / all requests

higher availability
→ better reliability
```

---

## Interview summary

I created a basic availability SLI in Prometheus by dividing the rate of successful HTTP requests by the rate of all HTTP requests.

For example:

```promql
100 *
sum(rate(app_http_requests_total{status="200"}[5m]))
/
sum(rate(app_http_requests_total[5m]))
```

This returns the percentage of successful traffic during the selected time window.

The SLI can then be compared against an SLO and used for reliability monitoring.
