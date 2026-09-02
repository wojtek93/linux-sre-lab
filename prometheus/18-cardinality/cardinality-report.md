# PRO-18 Prometheus Cardinality

## Goal

Create a high-cardinality metric design, observe the problem, and fix it.

---

## What is cardinality?

Cardinality is the number of unique time series created by a metric and its label combinations.

Example:

```text
http_requests_total{method="GET",status="200"}
http_requests_total{method="POST",status="200"}
http_requests_total{method="GET",status="500"}
```

These are three separate time series.

---

## High-cardinality problem

A metric was created with:

```python
["endpoint", "request_id"]
```

The `request_id` value was unique for every request.

Example:

```text
demo_requests_total{endpoint="/login",request_id="abc"}
demo_requests_total{endpoint="/login",request_id="def"}
demo_requests_total{endpoint="/login",request_id="ghi"}
```

Even though the endpoint is the same, every unique `request_id` creates another time series.

Mental model:

```text
unique request
↓
unique request_id
↓
new label combination
↓
new time series
```

---

## Bad metric design

```python
REQUESTS = Counter(
    "demo_requests_total",
    "Demo requests",
    ["endpoint", "request_id"]
)
```

Every request generated a new UUID:

```python
request_id = str(uuid.uuid4())
```

This means the number of time series continuously increased.

---

## Measuring the problem

The number of series was checked using:

```bash
curl -s http://localhost:8001/metrics \
  | grep '^demo_requests_total' \
  | wc -l
```

Running this command multiple times showed that the number of series kept increasing.

---

## Why this is dangerous

High cardinality can cause:

```text
high memory usage
more storage usage
slower queries
higher CPU usage
larger TSDB index
reduced Prometheus performance
```

---

## Fix

The high-cardinality label was removed.

Before:

```python
["endpoint", "request_id"]
```

After:

```python
["endpoint"]
```

Correct metric:

```python
REQUESTS = Counter(
    "demo_requests_total",
    "Demo requests",
    ["endpoint"]
)
```

Now the possible label values are limited to:

```text
/
 /login
 /products
```

So the number of series remains approximately constant.

---

## Verification

After the fix:

```bash
curl -s http://localhost:8001/metrics \
  | grep '^demo_requests_total' \
  | wc -l
```

The number of series stayed constant even though requests continued to be generated.

---

## Good vs bad labels

Good labels usually have a small, predictable number of values.

Examples:

```text
method
status
endpoint
environment
service
region
```

Potentially dangerous labels include:

```text
request_id
user_id
session_id
email
timestamp
UUID
full URL with dynamic IDs
```

---

## Important distinction

A Counter increasing is normal:

```text
requests:
100
200
500
1000
```

The dangerous situation is when the number of unique time series also continuously increases.

```text
series:
100
1000
10000
100000
```

---

## Mental model

```text
good cardinality

few predictable labels
↓
limited combinations
↓
stable number of time series
↓
Prometheus stays efficient
```

```text
high cardinality

unbounded label values
↓
new combinations continuously created
↓
huge number of time series
↓
RAM / storage / query problems
```

---

## Key takeaway

Labels should describe dimensions that have a limited and predictable set of values.

Do not use unique identifiers such as request IDs or session IDs as Prometheus labels.

---

## Interview summary

High cardinality happens when labels have too many unique values.

I demonstrated this by adding a unique `request_id` label to a Counter. Every request created a new time series and the number of series continuously increased.

I fixed the metric by removing the unbounded `request_id` label and keeping only the low-cardinality `endpoint` label.

After the fix, request counts continued to increase while the number of time series remained stable.
