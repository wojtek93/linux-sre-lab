# PRO-16 Prometheus node_exporter

## Goal

Deploy node_exporter and query Linux host metrics with Prometheus.

---

## What is node_exporter?

`node_exporter` exposes Linux host metrics in Prometheus format.

It can provide metrics related to:

```text
CPU
memory
filesystem
disk
network
load average
```

Mental model:

```text
Linux host
↓
node_exporter
↓
/metrics
↓
Prometheus
```

---

## Running node_exporter

The exporter was started using Docker:

```bash
docker run -d \
  --name node-exporter \
  -p 9100:9100 \
  prom/node-exporter
```

The metrics endpoint is available at:

```text
http://localhost:9100/metrics
```

---

## Testing the metrics endpoint

Example:

```bash
curl http://localhost:9100/metrics | head
```

node_exporter exposes both its own runtime metrics and Linux host metrics.

Typical Linux metrics start with:

```text
node_
```

---

## CPU metrics

Example:

```promql
rate(node_cpu_seconds_total{mode!="idle"}[5m])
```

This shows CPU activity over the last five minutes.

A simplified CPU usage percentage can be calculated with:

```promql
100 *
(
  1 -
  avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))
)
```

Mental model:

```text
idle CPU
→ time CPU was not doing work

1 - idle
→ active CPU

× 100
→ CPU usage %
```

---

## Memory metrics

Example:

```promql
node_memory_MemAvailable_bytes
```

This shows available memory.

node_exporter exposes many memory metrics under:

```text
node_memory_*
```

---

## Load average

Example:

```promql
node_load1
```

This represents the Linux one-minute load average.

Related metrics include:

```text
node_load1
node_load5
node_load15
```

---

## Filesystem metrics

Example metric:

```text
node_filesystem_avail_bytes
```

This can be used to monitor available filesystem space.

---

## Network metrics

Example metric:

```text
node_network_receive_bytes_total
```

This is a Counter containing the total number of received bytes.

To calculate receive throughput:

```promql
rate(node_network_receive_bytes_total[5m])
```

---

## Prometheus configuration

node_exporter was added as a Prometheus target:

```yaml
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets:
          - "localhost:9090"

  - job_name: "node-exporter"
    static_configs:
      - targets:
          - "host.docker.internal:9100"
```

---

## Checking target health

Query:

```promql
up{job="node-exporter"}
```

Result:

```text
1
```

means:

```text
Prometheus successfully scrapes node_exporter
```

Result:

```text
0
```

would indicate a scrape problem.

---

## Useful metric families

```text
node_cpu_*
→ CPU

node_memory_*
→ memory

node_filesystem_*
→ filesystem

node_disk_*
→ disk I/O

node_network_*
→ network

node_load*
→ load average
```

---

## Practical SRE use

node_exporter allows Prometheus to monitor the health of Linux hosts.

Typical SRE use cases include:

```text
high CPU usage
low available memory
disk space exhaustion
high disk I/O
network traffic
high system load
```

These metrics can later be used in:

```text
dashboards
alerts
capacity analysis
incident troubleshooting
```

---

## Key takeaways

```text
node_exporter
→ exposes Linux metrics

port 9100
→ default node_exporter HTTP endpoint

node_*
→ host metric families

up{job="node-exporter"}
→ confirms Prometheus can scrape exporter
```

---

## Interview summary

I deployed node_exporter and configured Prometheus to scrape it on port 9100.

I queried Linux host metrics such as CPU, available memory, load average, filesystem and network metrics.

For example, I calculated CPU usage from the idle CPU rate and used the `up` metric to verify that Prometheus was successfully scraping the exporter.

This allows Prometheus to monitor both application metrics and underlying Linux infrastructure.
