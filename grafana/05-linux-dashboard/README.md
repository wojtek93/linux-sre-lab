# GRA-05 — Linux Infrastructure Dashboard

## Goal

Build a Grafana infrastructure dashboard using metrics from `node_exporter`.

The dashboard focuses on four core Linux infrastructure areas:

- CPU
- Memory
- Disk
- Network

The purpose of this lab is to connect Linux host metrics with Grafana and practice reading infrastructure trends from a production-style dashboard.

---

# Dashboard

Dashboard name:

```text
Production App Infrastructure
```

The dashboard contains four main panels:

```text
CPU Usage
Memory Usage
Disk Usage
Network Traffic
```

Metrics are collected by Prometheus from `node_exporter`.

---

# 1. CPU Usage

Panel:

```text
CPU Usage
```

Query:

```promql
instance:node_cpu_usage:rate5m
```

Unit:

```text
Percent (0-100)
```

This recording rule shows CPU utilization for the Linux host.

The metric can be used to identify:

- increasing CPU pressure
- prolonged high CPU usage
- temporary CPU spikes
- possible CPU saturation

A high CPU value does not automatically identify the root cause.

If CPU usage increases, the next step on the Linux host can be:

```bash
top
```

or:

```bash
ps -eo pid,comm,%cpu --sort=-%cpu | head
```

This allows the dashboard signal to be correlated with real processes.

---

# 2. Memory Usage

Panel:

```text
Memory Usage
```

Query:

```promql
instance:node_memory_usage_percent
```

Unit:

```text
Percent (0-100)
```

This recording rule shows Linux memory usage as a percentage.

Memory monitoring helps detect:

- gradual memory growth
- memory pressure
- potential memory leaks
- sustained high RAM utilization

Useful Linux commands for deeper investigation:

```bash
free -h
```

```bash
vmstat
```

```bash
ps -eo pid,comm,%mem --sort=-%mem | head
```

A rising memory trend is usually more important than a single temporary spike.

---

# 3. Disk Usage

Panel:

```text
Disk Usage
```

Query:

```promql
100 * (
  1 -
  (
    node_filesystem_avail_bytes{fstype!~"tmpfs|overlay"}
    /
    node_filesystem_size_bytes{fstype!~"tmpfs|overlay"}
  )
)
```

Unit:

```text
Percent (0-100)
```

The query calculates used disk space as:

```text
100 × (1 - available / total)
```

Temporary filesystems and overlay filesystems are excluded:

```text
tmpfs
overlay
```

Multiple lines may appear because the Linux host can have multiple mounted filesystems.

Useful Linux verification commands:

```bash
df -h
```

```bash
du -sh /*
```

Disk usage is especially important because reaching 100% can cause:

- application failures
- inability to write logs
- database failures
- service crashes
- deployment failures

---

# 4. Network Traffic

Panel:

```text
Network Traffic
```

The panel contains two queries.

## Receive

```promql
rate(node_network_receive_bytes_total{device!="lo"}[5m])
```

Legend:

```text
Receive
```

## Transmit

```promql
rate(node_network_transmit_bytes_total{device!="lo"}[5m])
```

Legend:

```text
Transmit
```

Unit:

```text
bytes/sec
```

The loopback interface is excluded:

```text
device!="lo"
```

The panel shows incoming and outgoing network traffic.

This can help identify:

- traffic spikes
- unexpected network activity
- loss of traffic
- large outbound transfers
- correlation between application load and network utilization

Useful Linux commands:

```bash
ip addr
```

```bash
ip route
```

```bash
ss -tulpn
```

---

# Infrastructure Troubleshooting Flow

This dashboard extends the same troubleshooting model used in the Golden Signals lab.

Example CPU flow:

```text
Grafana
→ CPU usage increases
→ inspect Linux processes
→ identify responsible process
→ mitigate
→ verify CPU recovery
```

Example memory flow:

```text
Grafana
→ memory usage increases
→ free / vmstat / ps
→ identify process or system pressure
→ investigate
```

Example disk flow:

```text
Grafana
→ filesystem usage increases
→ df
→ du / find / lsof
→ identify what consumes space
→ cleanup or expand storage
→ verify
```

Example network flow:

```text
Grafana
→ unusual traffic
→ inspect interfaces and routing
→ check listening connections
→ correlate with application behavior
```

---

# Dashboard vs Linux Tools

Grafana provides:

```text
trend
history
correlation
visibility
```

Linux tools provide:

```text
process-level details
filesystem details
network state
current system state
```

The important operational skill is combining both.

Example:

```text
Grafana says CPU is high
```

does not explain:

```text
which process is responsible
```

That requires Linux-level investigation.

---

# Infrastructure Metrics and Golden Signals

The infrastructure dashboard complements the Golden Signals dashboard.

Golden Signals:

```text
Latency
Traffic
Errors
Saturation
```

Infrastructure dashboard:

```text
CPU
Memory
Disk
Network
```

Together they allow correlation such as:

```text
traffic increases
→ CPU increases
→ latency increases
```

or:

```text
disk usage reaches critical level
→ application errors appear
```

or:

```text
network traffic drops
→ application becomes unreachable
```

This correlation is more useful than looking at a single metric in isolation.

---

# Interview Context

A useful explanation:

> I use Grafana to monitor both application-level and infrastructure-level metrics. For Linux infrastructure I monitor CPU, memory, disk and network metrics from node_exporter. If I see an anomaly, I correlate it with other metrics and then move to Linux tools such as ps, top, free, df, ss or journalctl to identify the actual cause.

Another useful statement:

> A dashboard tells me where the problem may be, but I still need to investigate the underlying Linux system to identify the root cause.

---

# Dashboard Export

The Grafana dashboard was exported as:

```text
production-app-infrastructure.json
```

Training artifact:

```text
grafana/05-linux-dashboard/production-app-infrastructure.json
```

Production Application SRE Lab copy:

```text
production-app/monitoring/grafana/production-app-infrastructure.json
```

---

# Result

GRA-05 completed successfully.

Practiced:

- CPU monitoring with node_exporter
- memory monitoring
- filesystem usage monitoring
- network receive/transmit monitoring
- PromQL calculations
- Grafana units
- infrastructure trend analysis
- Linux metric correlation
- Grafana → Linux troubleshooting workflow
- combining infrastructure metrics with Golden Signals
