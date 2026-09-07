# GRA-06 — Grafana Variables

## Goal

Add reusable dashboard variables to the Production App Infrastructure dashboard.

The variables used in this lab are:

- `instance`
- `endpoint`
- `environment`

The goal is to make dashboards reusable instead of hardcoding values directly inside PromQL queries.

---

# 1. Instance Variable

Variable:

```text
instance
```

Type:

```text
Query
```

Query type:

```text
Label values
```

Metric:

```text
node_uname_info
```

Label:

```text
instance
```

The variable returns available node_exporter instances.

In the current lab environment only one node_exporter instance exists:

```text
host.docker.internal:9100
```

The variable is still useful as a reusable dashboard pattern for environments containing multiple Linux hosts.

Example:

```text
server-a:9100
server-b:9100
server-c:9100
```

The same dashboard can then be switched between hosts using a dropdown.

---

# CPU Panel

Original query:

```promql
instance:node_cpu_usage:rate5m
```

Variable-enabled query:

```promql
instance:node_cpu_usage:rate5m{instance="$instance"}
```

---

# Memory Panel

Variable-enabled query:

```promql
instance:node_memory_usage_percent{instance="$instance"}
```

---

# Disk Panel

Variable-enabled query:

```promql
100 * (
  1 -
  (
    node_filesystem_avail_bytes{
      fstype!~"tmpfs|overlay",
      instance="$instance"
    }
    /
    node_filesystem_size_bytes{
      fstype!~"tmpfs|overlay",
      instance="$instance"
    }
  )
)
```

---

# Network Panel

Receive:

```promql
rate(
  node_network_receive_bytes_total{
    device!="lo",
    instance="$instance"
  }[5m]
)
```

Transmit:

```promql
rate(
  node_network_transmit_bytes_total{
    device!="lo",
    instance="$instance"
  }[5m]
)
```

---

# 2. Endpoint Variable

Variable:

```text
endpoint
```

Type:

```text
Query
```

Query type:

```text
Label values
```

Metric:

```text
app_requests_total
```

Label:

```text
endpoint
```

The variable returned:

```text
/
/error
/slow
```

These values appeared after the application generated metrics for those endpoints.

This demonstrated an important Prometheus behavior:

```text
Prometheus can only expose label values for metric series that already exist.
```

If an endpoint has never produced a metric series, it may not appear in Grafana variable values.

---

# Request Rate by Endpoint

A new panel was added:

```text
Request Rate by Endpoint
```

Query:

```promql
sum(
  rate(
    app_requests_total{
      endpoint="$endpoint"
    }[5m]
  )
)
```

Selecting:

```text
/
```

shows request rate for the root endpoint.

Selecting:

```text
/error
```

shows request rate for the controlled error endpoint.

Selecting:

```text
/slow
```

shows request rate for the slow endpoint.

This makes the dashboard interactive without editing the PromQL query.

---

# 3. Environment Variable

Variable:

```text
environment
```

Type:

```text
Custom
```

Values:

```text
dev
stage
prod
```

The current application metrics do not contain an `environment` label.

Therefore this variable currently acts as a dashboard preparation mechanism rather than an active metric filter.

In a larger environment the same dashboard could use metrics containing labels such as:

```text
environment="dev"
environment="stage"
environment="prod"
```

and the selected environment could then filter all panels.

---

# Why Variables Matter

Without variables, a query may contain a hardcoded value:

```promql
some_metric{instance="server-a:9100"}
```

Changing the server requires editing the query.

With a variable:

```promql
some_metric{instance="$instance"}
```

the same dashboard can be reused for multiple servers.

The same principle applies to:

```text
instance
endpoint
environment
namespace
pod
service
region
cluster
```

---

# Practical Dashboard Pattern

Variables allow one dashboard to support many targets:

```text
one dashboard
+
multiple hosts
+
multiple endpoints
+
multiple environments
=
reusable operational dashboard
```

This is especially useful in production environments where many systems use the same dashboard structure.

---

# Troubleshooting Lesson — Time Drift

During this lab the endpoint panel initially showed no data.

The root cause was not the Grafana variable.

Prometheus reported:

```text
Server time is out of sync
```

The VM clock had drifted again after restart.

The issue was verified using:

```bash
timedatectl
```

and time synchronization was restored.

After synchronization:

- Prometheus data returned
- Grafana panels displayed correctly
- endpoint variable filtering worked

This reinforced the troubleshooting pattern:

```text
Grafana No data
→ application check
→ Prometheus target check
→ Prometheus query
→ VM time synchronization
→ Grafana
```

Time synchronization should be checked early when monitoring appears broken after a VM restart.

---

# Interview Context

A useful explanation:

> Grafana variables allow me to build reusable dashboards instead of hardcoding values inside queries. For example, I can use an instance variable to switch between servers or an endpoint variable to filter application metrics without changing the PromQL query.

Another useful explanation:

> In larger environments I would commonly use variables for instances, services, environments, namespaces or endpoints so that one dashboard can be reused across multiple systems.

---

# Dashboard Export

The dashboard was exported as:

```text
production-app-infrastructure-variables.json
```

Training artifact:

```text
grafana/06-variables/production-app-infrastructure-variables.json
```

Production Application SRE Lab copy:

```text
production-app/monitoring/grafana/production-app-infrastructure-variables.json
```

---

# Result

GRA-06 completed successfully.

Practiced:

- Grafana query variables
- custom variables
- label value discovery
- `$instance`
- `$endpoint`
- environment preparation
- reusable PromQL queries
- interactive dashboards
- filtering infrastructure metrics
- filtering application metrics
- Prometheus label behavior
- troubleshooting Grafana No data caused by VM clock drift
