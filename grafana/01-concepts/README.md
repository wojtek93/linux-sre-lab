# GRA-01 — Grafana Concepts

## Goal

Understand the basic Grafana concepts used in monitoring and observability:

- Data source
- Dashboard
- Panel
- Query
- Transformation
- Alert

---

## Data Source

A data source is the system Grafana connects to in order to retrieve data.

Examples:

- Prometheus
- MySQL
- PostgreSQL
- Loki
- Elasticsearch

In this lab, Prometheus is the main data source.

Typical flow:

```text
Application / Exporter -> Prometheus -> Grafana
```

Grafana does not usually collect application metrics directly. It queries the configured data source and visualizes the returned data.

Interview answer:

> A data source is the system Grafana connects to in order to retrieve data, for example Prometheus, MySQL or Loki.

---

## Dashboard

A dashboard is a collection of panels displayed together to provide an overview of a system, application or service.

Example dashboard:

Application Overview

- CPU usage
- Memory usage
- Request rate
- Error rate
- p95 latency
- Availability

Interview answer:

> A dashboard is a collection of panels that provides an overview of selected metrics or system behavior.

---

## Panel

A panel is a single visualization inside a Grafana dashboard.

A panel can display data as:

- Time series graph
- Stat
- Gauge
- Table
- Heatmap
- Other visualization types

Example:

A dashboard may contain separate panels for:

- CPU usage
- Memory usage
- Request rate
- Error rate
- p95 latency

Interview answer:

> A panel is an individual visualization on a Grafana dashboard.

---

## Query

A query defines what data should be retrieved from the configured data source.

When Prometheus is used as a data source, queries are usually written in PromQL.

Example:

```promql
up{job="application"}
```

This query returns the availability status of the application target.

Another example:

```promql
rate(app_requests_total[5m])
```

This shows the request rate calculated over the last five minutes.

Relationship:

```text
Data source -> Query -> Panel
```

Interview answer:

> A query defines what data a Grafana panel retrieves from the configured data source. For Prometheus, queries are usually written in PromQL.

---

## Transformation

A transformation modifies or reshapes the data returned by a query before it is displayed in a panel.

Typical transformations:

- Rename fields
- Hide unnecessary fields
- Sort data
- Filter data
- Join results
- Calculate additional values

Example:

A query returns:

- instance
- job
- value

A transformation may remove unnecessary columns and rename `instance` to `Server`.

Important distinction:

```text
Query = what data is retrieved

Transformation = how returned data is reshaped before visualization
```

Interview answer:

> A transformation modifies or reshapes the data returned by a query before it is displayed in a Grafana panel.

---

## Alert

An alert evaluates a condition based on metrics and can notify the team when that condition is met.

Example condition:

```promql
instance:node_cpu_usage:rate5m > 80
```

If CPU usage remains above the configured threshold, the alert can move through states such as:

- Pending
- Firing

Notifications can be sent to systems such as:

- Email
- Slack
- Microsoft Teams
- PagerDuty
- Webhooks

Important distinction:

```text
Panel = displays data

Alert = reacts when a defined condition is met
```

Interview answer:

> An alert evaluates a condition based on metrics and notifies the team when the condition is met.

---

## Grafana Concept Flow

```text
Data Source
    |
    v
Query
    |
    v
Transformation
    |
    v
Panel
    |
    v
Dashboard

Alert -> evaluates conditions based on metrics
```

---

## Practical Observability Context

Grafana is commonly used to observe application and infrastructure behavior.

Typical things to monitor:

- CPU usage
- Memory usage
- Disk usage
- Application availability
- Request rate
- Error rate
- Latency
- p95 latency
- Target status
- Pod restarts
- Resource saturation

A useful SRE approach is to monitor not only failures, but also trends that may indicate an upcoming problem.

Examples:

- CPU increasing over time
- Latency increasing while traffic grows
- Error rate slowly increasing
- Memory usage continuously rising
- Disk space decreasing

A common framework is the Four Golden Signals:

- Latency
- Traffic
- Errors
- Saturation

---

## Quick Review

### Data Source

Where Grafana gets data from.

### Dashboard

A collection of panels.

### Panel

A single visualization.

### Query

Defines what data to retrieve.

### Transformation

Changes returned data before display.

### Alert

Evaluates a condition and can trigger notification.

---

## Interview Summary

> Grafana connects to a data source such as Prometheus. Queries retrieve metrics, panels visualize them, dashboards group multiple panels together, transformations reshape the returned data, and alerts evaluate conditions and notify the team when thresholds are exceeded.
