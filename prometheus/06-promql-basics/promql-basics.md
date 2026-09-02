# PRO-06 PromQL Basics

## Goal

Learn the basic PromQL query types used to inspect and aggregate Prometheus metrics.

Covered topics:

- instant vectors
- range vectors
- label filters
- aggregations

---

## 1. Instant vector

Query:

```promql
app_http_requests_total
```

An instant vector returns the current value of all matching time series at a specific evaluation time.

Mental model:

```text
metric
→ current value
```

Example:

```promql
app_http_requests_total
```

may return separate series for:

```text
status="200"
status="500"
endpoint="/"
endpoint="/error"
```

---

## 2. Range vector

Query:

```promql
app_http_requests_total[1m]
```

A range vector returns multiple samples from a time window.

Here:

```text
[1m]
```

means:

```text
last 1 minute
```

Mental model:

```text
metric
→ one current sample

metric[1m]
→ samples from the last minute
```

Range vectors are commonly used by functions such as:

```promql
rate()
increase()
```

---

## 3. Label filtering

Prometheus metrics can be filtered using labels.

Example:

```promql
app_http_requests_total{status="500"}
```

This selects only request series with:

```text
status = 500
```

---

### Filter by endpoint

```promql
app_http_requests_total{endpoint="/"}
```

---

### Multiple filters

```promql
app_http_requests_total{method="GET",status="200"}
```

All conditions must match.

Mental model:

```text
metric
+
{label="value"}
=
selected time series
```

---

## 4. Negative filter

Query:

```promql
app_http_requests_total{status!="200"}
```

This selects all series where:

```text
status is not 200
```

---

## 5. Important observation about missing series

A labeled metric series may not exist until that specific label combination has been used.

Example:

```promql
app_http_requests_total{method="GET",status="200"}
```

initially returned:

```text
Empty query result
```

because no successful request had been generated after the application restarted.

After:

```bash
curl http://localhost:8000/
```

the corresponding series appeared.

Mental model:

```text
no event with given labels
↓
series does not exist yet
↓
Empty query result
```

---

## 6. sum()

Query:

```promql
sum(app_http_requests_total)
```

This adds the values of all matching time series.

Example:

```text
200 requests = 10
500 requests = 3
```

then:

```text
sum = 13
```

Mental model:

```text
many series
↓
sum()
↓
one combined value
```

---

## 7. sum by()

Query:

```promql
sum by (status) (app_http_requests_total)
```

This sums the metric while preserving the selected label.

Example result:

```text
status="200" → 10
status="500" → 3
```

Mental model:

```text
sum everything
BUT
keep groups separated by status
```

---

## 8. avg()

Query:

```promql
avg(app_http_request_duration_seconds_sum)
```

`avg()` calculates the arithmetic average of the values of matching time series.

Important:

This is an average across series.

It is not automatically the average HTTP request latency.

For request latency based on Histogram data, a more meaningful query is:

```promql
rate(app_http_request_duration_seconds_sum[1m])
/
rate(app_http_request_duration_seconds_count[1m])
```

---

## 9. count()

Query:

```promql
count(app_http_requests_total)
```

`count()` returns the number of matching time series.

It does not return the number of requests.

Example:

```text
series 1:
status="200"

series 2:
status="500"
```

Then:

```promql
count(app_http_requests_total)
```

returns:

```text
2
```

even if the actual request counters contain much larger values.

Mental model:

```text
count(metric)
=
how many time series exist?
```

---

## 10. Instant vector vs range vector

```text
app_http_requests_total
```

means:

```text
current samples
```

while:

```text
app_http_requests_total[1m]
```

means:

```text
samples collected during the last minute
```

---

## 11. Filters vs aggregations

Filters reduce the selected data:

```promql
app_http_requests_total{status="500"}
```

Aggregation combines selected data:

```promql
sum(app_http_requests_total)
```

They can also be combined:

```promql
sum(app_http_requests_total{status="500"})
```

Mental model:

```text
filter
→ select data

aggregation
→ combine data
```

---

## 12. Useful queries from the lab

All request series:

```promql
app_http_requests_total
```

Last minute of samples:

```promql
app_http_requests_total[1m]
```

Only 500 responses:

```promql
app_http_requests_total{status="500"}
```

Only successful GET requests:

```promql
app_http_requests_total{method="GET",status="200"}
```

Everything except HTTP 200:

```promql
app_http_requests_total{status!="200"}
```

Total requests across all series:

```promql
sum(app_http_requests_total)
```

Requests grouped by status:

```promql
sum by (status) (app_http_requests_total)
```

Number of request time series:

```promql
count(app_http_requests_total)
```

Average request latency using Histogram sum/count:

```promql
rate(app_http_request_duration_seconds_sum[1m])
/
rate(app_http_request_duration_seconds_count[1m])
```

---

## 13. Key takeaways

```text
instant vector
→ current samples

range vector
→ samples from a time window

{label="value"}
→ filter series

!=
→ negative filter

sum()
→ add series values

sum by()
→ aggregate while preserving a label

avg()
→ average across matching series

count()
→ number of matching series
```

---

## Interview summary

PromQL is the query language used by Prometheus.

An instant vector returns current samples, while a range vector returns samples collected over a specified time window.

Label matchers are used to select specific time series.

Aggregation operators such as `sum`, `avg`, and `count` combine multiple series.

Using `by(...)` preserves selected labels during aggregation.

Range vectors are commonly used with functions such as `rate()` to calculate changes over time.
