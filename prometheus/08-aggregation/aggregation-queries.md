# PRO-08 PromQL Aggregation

## Goal

Learn how to aggregate Prometheus time series using:

- `sum`
- `sum by`
- `avg`
- `count`
- `topk`

---

## Why aggregation is useful

Prometheus often stores many separate time series.

Example:

```text
status="200", endpoint="/"
status="200", endpoint="/login"
status="500", endpoint="/error"
```

Aggregation allows us to combine those series into more useful results.

Mental model:

```text
many time series
↓
aggregation
↓
simpler result
```

---

## sum()

Query:

```promql
sum(app_http_requests_total)
```

This adds values from all matching time series.

Example:

```text
series A = 10
series B = 5
series C = 3
```

Result:

```text
18
```

Use this when you want one total value.

---

## sum by()

Query:

```promql
sum by (status) (app_http_requests_total)
```

This sums the values but keeps separate groups for the selected label.

Example:

```text
status="200" → 15
status="500" → 3
```

Mental model:

```text
sum everything
but keep groups separated by status
```

---

## Group by endpoint

Query:

```promql
sum by (endpoint) (app_http_requests_total)
```

Example result:

```text
endpoint="/" → 20
endpoint="/error" → 5
```

This makes it easy to see which endpoint receives the most traffic.

---

## avg()

Query:

```promql
avg(app_http_requests_total)
```

This calculates the average value across matching time series.

Example:

```text
10
20
30
```

Result:

```text
20
```

Important:

This is the average of series values.

It is not automatically the same as average request latency.

---

## count()

Query:

```promql
count(app_http_requests_total)
```

This returns the number of matching time series.

Example:

```text
series 1
series 2
series 3
```

Result:

```text
3
```

Important:

`count()` counts series, not HTTP requests.

---

## topk()

Query:

```promql
topk(2, app_http_requests_total)
```

This returns the 2 time series with the highest values.

Mental model:

```text
topk(2, metric)
=
show the 2 biggest series
```

Typical uses:

```text
highest traffic endpoints
highest CPU consumers
largest error counters
most active instances
```

---

## Example aggregation queries

Total requests:

```promql
sum(app_http_requests_total)
```

Requests grouped by HTTP status:

```promql
sum by (status) (app_http_requests_total)
```

Requests grouped by endpoint:

```promql
sum by (endpoint) (app_http_requests_total)
```

Average Counter value across series:

```promql
avg(app_http_requests_total)
```

Number of request series:

```promql
count(app_http_requests_total)
```

Two largest request series:

```promql
topk(2, app_http_requests_total)
```

---

## Combining filters and aggregation

Only 500 responses:

```promql
sum(app_http_requests_total{status="500"})
```

Grouped 500 responses:

```promql
sum by (endpoint) (
  app_http_requests_total{status="500"}
)
```

This lets us first select relevant series and then aggregate them.

Mental model:

```text
filter
↓
select useful series
↓
aggregation
↓
combine result
```

---

## Key takeaways

```text
sum()
→ total value

sum by()
→ total grouped by a label

avg()
→ average value across series

count()
→ number of series

topk()
→ highest-valued series
```

---

## Interview summary

PromQL aggregation operators are used to combine multiple time series.

`sum()` returns a total value, while `sum by()` preserves selected labels and creates grouped totals.

`avg()` calculates an average across series.

`count()` counts matching time series.

`topk()` is useful for finding the highest-valued series, for example endpoints with the most traffic or instances with the highest resource usage.
