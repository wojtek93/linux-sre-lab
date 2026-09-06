# GRA-02 — Connect Grafana to Prometheus

## Goal

Connect Grafana to Prometheus as a data source and verify that Grafana can successfully query Prometheus metrics.

---

## Environment

Services used:

- Grafana
- Prometheus
- node_exporter
- Flask application exposing metrics

Grafana was started in Docker and exposed on port:

```text
3000
```

Prometheus was available on:

```text
9090
```

Application metrics were exposed on:

```text
8000
```

---

## Grafana Container

Grafana was started with:

```bash
docker run -d \
  --name grafana \
  --add-host=host.docker.internal:host-gateway \
  -p 3000:3000 \
  grafana/grafana
```

The additional host mapping allows Grafana running inside Docker to reach services running on the Docker host.

---

## Access Grafana

Grafana was opened from the browser using the VM IP:

```text
http://192.168.64.2:3000
```

Default credentials:

```text
username: admin
password: admin
```

---

## Add Prometheus Data Source

In Grafana:

```text
Connections
-> Data sources
-> Add data source
-> Prometheus
```

Prometheus server URL:

```text
http://host.docker.internal:9090
```

After clicking:

```text
Save & test
```

Grafana successfully connected to the Prometheus API.

---

## Test Query

The first test query was:

```promql
up
```

It returned three targets:

- Prometheus
- node_exporter
- application

At that moment:

```text
prometheus     = 1
node_exporter  = 1
application    = 0
```

This showed that Grafana was correctly reading Prometheus metrics, but the monitored application was down.

---

## Filter Application Target

The query was narrowed to:

```promql
up{job="application"}
```

The result was:

```text
0
```

Meaning:

```text
application target = DOWN
```

---

## Start the Application

The application was located in:

```text
~/Projects/linux-sre-lab/prometheus/20-monitoring-project/app
```

A Python virtual environment was created:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Dependencies were installed:

```bash
pip install -r requirements.txt
```

The application was started with:

```bash
python app.py
```

The Flask application started on:

```text
http://127.0.0.1:8000
http://192.168.64.2:8000
```

---

## Verify Recovery in Grafana

The same Grafana query was executed again:

```promql
up{job="application"}
```

The metric changed from:

```text
0
```

to:

```text
1
```

This confirmed that Prometheus detected the application recovery and Grafana displayed the updated metric.

---

## Observed Flow

```text
Application
    |
    v
Prometheus
    |
    v
Grafana
```

The complete test demonstrated:

```text
application down
-> Prometheus reports up=0
-> Grafana displays up=0
-> application starts
-> Prometheus reports up=1
-> Grafana displays up=1
```

---

## SRE Interpretation

This is a basic availability monitoring scenario.

The `up` metric tells us whether Prometheus can successfully scrape a target.

```text
up = 1
```

means the target is reachable and Prometheus can scrape it.

```text
up = 0
```

means the scrape failed.

This does not always mean that the whole application is completely unavailable to users, but it is a strong indication that the monitoring target is unhealthy or unreachable and requires investigation.

---

## Troubleshooting Lesson

When the application target showed:

```text
up = 0
```

other monitored targets were still healthy.

This helped isolate the problem:

```text
Prometheus     UP
node_exporter  UP
application    DOWN
```

The issue was therefore related to the application rather than the monitoring infrastructure itself.

---

## Interview Answer

> Grafana was connected to Prometheus as a data source. I verified the connection using the `up` metric. When the monitored application was stopped, Grafana showed `up=0`. After starting the application, Prometheus successfully scraped it again and Grafana showed the transition from `0` to `1`.

---

## Key Concepts

### Data Source

Prometheus was configured as the Grafana data source.

### Query

PromQL was used to retrieve metrics:

```promql
up
```

and:

```promql
up{job="application"}
```

### Availability

The `up` metric was used to verify scrape availability.

### Troubleshooting

Different target states helped identify which component was unhealthy.

---

## Result

GRA-02 completed successfully.

Verified:

- Grafana running
- Prometheus configured as data source
- Grafana querying Prometheus
- `up` metric visible in Grafana
- application DOWN detected
- application recovery detected
- full Application -> Prometheus -> Grafana monitoring flow confirmed
