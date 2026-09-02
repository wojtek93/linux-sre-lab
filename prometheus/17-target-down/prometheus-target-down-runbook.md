# PRO-17 Prometheus Target DOWN Runbook

## Goal

Diagnose and fix a Prometheus target that is DOWN because of a configuration or connectivity problem.

---

## Symptom

Prometheus query:

```promql
up{job="node-exporter-broken"}
```

returned:

```text
0
```

Meaning:

```text
Prometheus knows the target
but cannot scrape it successfully
```

---

## Step 1 — Check whether the exporter is running

Command:

```bash
docker ps
```

Expected:

```text
node-exporter is running
```

If the exporter is stopped, start it first.

---

## Step 2 — Check the metrics endpoint locally

Command:

```bash
curl http://localhost:9100/metrics | head
```

If metrics are returned, node_exporter itself is working.

Mental model:

```text
exporter running
+
/metrics works locally
↓
problem is probably elsewhere
```

---

## Step 3 — Check Prometheus target configuration

Command:

```bash
cat prometheus.yml
```

Broken configuration:

```yaml
scrape_configs:
  - job_name: "node-exporter-broken"
    static_configs:
      - targets:
          - "host.docker.internal:9999"
```

The configured port was:

```text
9999
```

but node_exporter was actually listening on:

```text
9100
```

---

## Root cause

```text
wrong target port in Prometheus configuration
```

Prometheus was trying to scrape:

```text
host.docker.internal:9999
```

instead of:

```text
host.docker.internal:9100
```

---

## Fix

Correct configuration:

```yaml
scrape_configs:
  - job_name: "node-exporter-broken"
    static_configs:
      - targets:
          - "host.docker.internal:9100"
```

Restart Prometheus:

```bash
docker restart prometheus
```

---

## Verification

Query:

```promql
up{job="node-exporter-broken"}
```

Before fix:

```text
0
```

After fix:

```text
1
```

Meaning:

```text
Prometheus can successfully scrape the target
```

---

## Troubleshooting flow

```text
target DOWN
↓
check up metric
↓
check exporter process
↓
check /metrics locally
↓
check address and port
↓
check Prometheus config
↓
fix configuration/network problem
↓
restart or reload Prometheus
↓
verify up = 1
```

---

## Other possible causes of target DOWN

```text
wrong hostname
wrong port
exporter stopped
firewall blocking connection
DNS problem
network routing problem
wrong metrics path
authentication problem
container networking problem
```

---

## Key takeaway

The `up` metric is one of the first things to check when diagnosing Prometheus scrape problems.

```text
up = 1
→ scrape successful

up = 0
→ scrape failed
```

---

## Interview summary

When a Prometheus target was DOWN, I first checked the `up` metric and confirmed that the target existed but could not be scraped.

I then verified that node_exporter was running and that its `/metrics` endpoint worked locally.

After that I checked the Prometheus scrape configuration and found that the target was configured with the wrong port.

I corrected the port, restarted Prometheus, and verified that the `up` metric changed from 0 to 1.
