# PRO-09 Prometheus Latency and Histogram Quantiles

## Goal

Learn how to calculate and interpret latency percentiles using Prometheus Histograms and `histogram_quantile()`.

Covered:

- p50
- p95
- p99
- histogram buckets
- `le`
- latency interpretation

---

## What is latency?

Latency is the time required to process a request and return a response.

Example:

```text
request sent
↓
application processes request
↓
response returned after 0.4 seconds
```

Then:

```text
latency = 0.4 s
```

---

## What are percentiles?

Percentiles describe how request durations are distributed.

### p50

```text
50% of requests were completed within this time
```

This is approximately the median request.

### p95

```text
95% of requests were completed within this time
5% were slower
```

### p99

```text
99% of requests were completed within this time
1% were slower
```

---

## Example

If:

```text
p95 = 0.45 s
```

then:

```text
95% of requests
→ <= 0.45 seconds

5% of requests
→ > 0.45 seconds
```

---

## Why use percentiles?

An average can hide slow requests.

Example:

```text
most requests → 0.2 s
some requests → 2 s
```

The average may still look acceptable.

p95 and p99 make the slow part of the traffic more visible.

---

## Histogram buckets

The application exposes a Histogram:

```text
app_http_request_duration_seconds
```

Prometheus creates bucket metrics such as:

```text
app_http_request_duration_seconds_bucket{le="0.1"}
app_http_request_duration_seconds_bucket{le="0.25"}
app_http_request_duration_seconds_bucket{le="0.5"}
app_http_request_duration_seconds_bucket{le="1"}
app_http_request_duration_seconds_bucket{le="+Inf"}
```

---

## What does `le` mean?

`le` means:

```text
less than or equal
```

Example:

```text
le="0.5"
```

means:

```text
requests with duration <= 0.5 seconds
```

Example observations:

```text
0.1
0.3
0.4
0.8
1.2
```

Then:

```text
le="0.5" → 3
le="1.0" → 4
le="+Inf" → 5
```

Histogram buckets are cumulative.

---

## p50 query

```promql
histogram_quantile(
  0.50,
  sum by (le) (
    rate(app_http_request_duration_seconds_bucket[5m])
  )
)
```

Interpretation:

```text
50% of requests completed within the returned latency
```

---

## p95 query

```promql
histogram_quantile(
  0.95,
  sum by (le) (
    rate(app_http_request_duration_seconds_bucket[5m])
  )
)
```

Interpretation:

```text
95% of requests completed within the returned latency
```

---

## p99 query

```promql
histogram_quantile(
  0.99,
  sum by (le) (
    rate(app_http_request_duration_seconds_bucket[5m])
  )
)
```

Interpretation:

```text
99% of requests completed within the returned latency
```

---

## Query breakdown

```text
app_http_request_duration_seconds_bucket
↓
Histogram bucket data

rate(...[5m])
↓
calculate bucket observation rates over 5 minutes

sum by (le)
↓
aggregate while preserving bucket boundaries

histogram_quantile()
↓
estimate percentile
```

---

## Understanding `[5m]`

The query uses:

```text
[5m]
```

Prometheus calculates the result using a moving five-minute window.

Example:

```text
12:10
→ data from 12:05–12:10

12:11
→ data from 12:06–12:11

12:12
→ data from 12:07–12:12
```

Each point on the graph therefore represents a newly calculated percentile.

---

## Reading the graph

The horizontal axis represents:

```text
time
```

The vertical axis represents:

```text
latency in seconds
```

Example:

```text
p95 = 0.47 s
```

means:

```text
95% of requests
→ <= approximately 0.47 seconds

5%
→ slower than approximately 0.47 seconds
```

---

## Lower is better

If the graph changes from:

```text
0.47 s
↓
0.37 s
```

the latency improved.

Mental model:

```text
higher percentile latency
→ slower application

lower percentile latency
→ faster application
```

---

## p99 example from the lab

The p99 graph showed values around:

```text
0.47–0.49 seconds
```

A lower point around:

```text
0.475 seconds
```

meant that during that five-minute observation window:

```text
99% of requests
→ completed in approximately 0.475 seconds or less

1%
→ were slower
```

This does not mean one individual request took exactly 0.475 seconds.

It describes the request latency distribution.

---

## p50 vs p95 vs p99

```text
p50
→ typical request

p95
→ focuses on slower 5%

p99
→ focuses on slower 1%
```

As the percentile increases, we examine further into the slow tail of the request distribution.

---

## Practical SRE interpretation

If:

```text
p50 = 0.15 s
p95 = 0.45 s
p99 = 1.8 s
```

then:

```text
most users
→ fast experience

some users
→ noticeably slower experience

slowest 1%
→ potentially serious latency problem
```

This is why p95 and p99 are commonly useful for SRE monitoring.

---

## Key takeaways

```text
latency
→ request response time

p50
→ 50% of requests completed within this time

p95
→ 95% completed within this time

p99
→ 99% completed within this time

le
→ less than or equal

histogram_quantile()
→ estimates percentiles from Histogram buckets
```

---

## Interview summary

I used Prometheus Histograms to monitor HTTP request latency.

The Histogram exposed cumulative buckets using the `le` label.

I used `rate()`, `sum by (le)` and `histogram_quantile()` to calculate p50, p95 and p99 latency.

For example, a p95 of 0.45 seconds means that approximately 95% of requests completed in 0.45 seconds or less, while 5% were slower.

Percentiles are useful because they expose slow requests that may not be visible when looking only at average latency.
