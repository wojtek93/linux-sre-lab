# PRO-04 Static Scrape Target

## Goal

Configure Prometheus with a static scrape target and verify that the target is reachable.

---

## Configuration

The following `prometheus.yml` configuration was used:

```yaml
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets:
          - "localhost:9090"

  - job_name: "demo-app"
    static_configs:
      - targets:
          - "host.docker.internal:8000"
```

---

## Configuration validation

The configuration was validated with `promtool`:

```bash
docker run --rm \
  -v "$(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml" \
  --entrypoint promtool \
  prom/prometheus \
  check config /etc/prometheus/prometheus.yml
```

Result:

```text
SUCCESS
```

---

## Prometheus container

Prometheus was started with the custom configuration:

```bash
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  --add-host=host.docker.internal:host-gateway \
  -v "$(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml" \
  prom/prometheus
```

---

## Why `host.docker.internal` is used

Prometheus runs inside a Docker container.

The demo Python application runs directly on the Linux VM.

Inside the container:

```text
localhost
```

refers to the Prometheus container itself.

Therefore:

```text
localhost:8000
```

would not reach the Python application.

The mapping:

```bash
--add-host=host.docker.internal:host-gateway
```

allows the container to reach the Docker host.

Flow:

```text
Prometheus container
↓
host.docker.internal:8000
↓
Linux VM
↓
Python application
```

---

## Target verification

In the Prometheus UI:

```text
Status → Targets
```

both targets were visible as:

```text
prometheus   UP
demo-app     UP
```

---

## PromQL verification

The following query was executed:

```promql
up
```

Both targets returned:

```text
1
```

Meaning:

```text
1
→ target is reachable and scraping succeeds

0
→ target is unreachable or scraping fails
```

---

## Mental model

```text
prometheus.yml
↓
scrape_configs
↓
job_name
↓
static target
↓
Prometheus performs HTTP scrape
↓
target returns /metrics
↓
target status = UP
```

---

## Key takeaways

```text
static_configs
→ manually defined targets

job_name
→ logical group of scrape targets

targets
→ addresses Prometheus scrapes

up
→ automatic metric indicating scrape health

promtool
→ validates Prometheus configuration
```

---

## Result

A static scrape target was successfully configured and verified.

The `demo-app` target was reachable and reported `UP` in Prometheus.
