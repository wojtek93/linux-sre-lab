# PRO-07 PromQL: rate, irate and increase

## Goal

Understand the difference between:

- `rate()`
- `irate()`
- `increase()`

when working with Prometheus Counters.

---

## Counter

A Counter normally increases over time.

Example:

```text
100
105
110
120
```

PromQL functions can calculate how this Counter changed during a time window.

---

## rate()

Example:

```promql
rate(app_http_requests_total[1m])
```

`rate()` calculates the average per-second growth of a Counter over the selected time range.

Mental model:

```text
Counter growth during window
/
window duration
=
average growth per second
```

Example:

```text
100 → 112 during 60 seconds
```

Approximately:

```text
12 / 60
=
0.2 requests per second
```

Use `rate()` when you want a relatively stable view of traffic over time.

---

## irate()

Example:

```promql
irate(app_http_requests_total[1m])
```

`irate()` calculates the per-second growth rate using the most recent samples in the selected range.

It reacts faster to sudden changes.

Mental model:

```text
rate()
→ smoother trend

irate()
→ latest short-term behavior
```

`irate()` is therefore usually more volatile than `rate()`.

---

## increase()

Example:

```promql
increase(app_http_requests_total[1m])
```

`increase()` calculates how much the Counter increased during the selected time window.

Example:

```text
100 → 112
```

Result:

```text
increase ≈ 12
```

Mental model:

```text
rate()
→ requests per second

increase()
→ number of additional requests
```

---

## Comparison

```text
rate()
→ average growth per second
→ uses the whole selected range

irate()
→ recent growth per second
→ reacts quickly to changes

increase()
→ total Counter growth in the selected range
→ result expressed in events
```

---

## Lab traffic

Initially the queries returned:

```text
0
```

because no new HTTP requests were being generated.

The Counter was not changing:

```text
10 → 10 → 10 → 10
```

Therefore:

```text
rate = 0
irate = 0
increase = 0
```

---

## Generate traffic

Traffic was generated using:

```bash
for i in {1..20}; do
  curl -s http://localhost:8000/ > /dev/null
  sleep 1
done
```

After the Counter started increasing, the PromQL functions returned values greater than zero.

---

## Queries

Average request rate:

```promql
rate(app_http_requests_total[1m])
```

Recent request rate:

```promql
irate(app_http_requests_total[1m])
```

Request increase during the last minute:

```promql
increase(app_http_requests_total[1m])
```

---

## Graph comparison

The results were also compared using the Prometheus Graph view.

Typical observation:

```text
rate()
→ smoother graph

irate()
→ more spiky graph
```

This is because `irate()` reacts more strongly to the most recent change.

---

## When to use rate()

Typical use cases:

```text
HTTP requests per second
errors per second
network bytes per second
CPU counter rates
```

Example:

```promql
rate(app_http_requests_total[5m])
```

---

## When to use irate()

Useful when investigating very recent or sudden changes.

Example:

```promql
irate(app_http_requests_total[1m])
```

It is generally more useful for troubleshooting short spikes than for stable dashboards or alerts.

---

## When to use increase()

Useful when the question is:

```text
How many events happened during this period?
```

Example:

```promql
increase(app_http_requests_total[1h])
```

This answers approximately:

```text
How many requests were processed during the last hour?
```

---

## Mental model

```text
Counter
100 → 112
```

Then:

```text
rate()
→ how fast did it grow?

irate()
→ how fast is it growing right now?

increase()
→ how much did it grow?
```

---

## Key takeaways

```text
rate()
= average per-second Counter growth

irate()
= recent per-second Counter growth

increase()
= total Counter increase during a time window
```

For dashboards and alerts, `rate()` is usually the safer default.

For very recent spikes, `irate()` can be useful.

For questions about the number of events during a period, use `increase()`.

---

## Interview summary

`rate()` calculates the average per-second increase of a Counter over a selected time range.

`irate()` calculates a more immediate rate based on the latest samples and therefore reacts faster to sudden changes.

`increase()` calculates the total Counter growth during a time interval.

For example, I used these functions to analyze HTTP request Counters in Prometheus and compared their behavior while generating application traffic.
