# PRO-19 Prometheus Storage and Retention

## Goal

Understand Prometheus local storage, retention and persistent storage considerations.

---

## What is retention?

Retention defines how long Prometheus keeps historical time-series data.

Mental model:

```text
Prometheus scrapes metrics
↓
stores samples in TSDB
↓
keeps them for configured retention period
↓
older data is removed
```

---

## Local TSDB storage

Prometheus stores data locally in its TSDB.

Default storage path inside the container:

```text
/prometheus
```

Disk usage can be checked with:

```bash
docker exec prometheus du -sh /prometheus
```

---

## What affects storage usage?

Main factors:

```text
number of time series
×
scrape frequency
×
retention period
```

Examples:

```text
more metrics
→ more disk usage

scrape every 5 seconds instead of every 30 seconds
→ more samples

retention 90d instead of 15d
→ more historical data
```

High cardinality also increases storage requirements.

---

## Configuring retention

Prometheus retention can be configured with:

```text
--storage.tsdb.retention.time
```

Example:

```text
--storage.tsdb.retention.time=7d
```

This configures Prometheus to retain data for approximately seven days.

---

## Example Docker configuration

```bash
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  --add-host=host.docker.internal:host-gateway \
  -v "$(pwd)/../17-target-down/prometheus.yml:/etc/prometheus/prometheus.yml" \
  -v prometheus-data:/prometheus \
  prom/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus \
  --storage.tsdb.retention.time=7d
```

---

## Persistent storage

Container storage is not a good place for important Prometheus data.

If data exists only inside the container:

```text
container deleted
↓
data can be lost
```

Using a Docker volume:

```text
container
↓
/prometheus
↓
prometheus-data volume
```

allows data to survive container recreation.

Create volume:

```bash
docker volume create prometheus-data
```

List volumes:

```bash
docker volume ls
```

---

## Persistence test

The Prometheus container was removed while the Docker volume was kept.

After recreating Prometheus using the same volume, the TSDB data was still present.

Mental model:

```text
container deleted
↓
volume survives
↓
new container mounts same volume
↓
Prometheus data survives
```

---

## Important storage considerations

In production, consider:

```text
disk capacity
retention period
scrape interval
number of targets
number of series
high-cardinality labels
persistent storage
backup / remote storage strategy
```

---

## Retention trade-off

Longer retention:

```text
more historical data
+
better long-term analysis
-
more disk usage
```

Shorter retention:

```text
less disk usage
+
lower storage requirements
-
less historical data
```

---

## Key takeaway

Prometheus primarily stores recent metrics locally in its TSDB.

Storage requirements depend mainly on:

```text
series count
sample frequency
retention time
```

Persistent storage should be used so that deleting or recreating the Prometheus container does not delete monitoring history.

---

## Interview summary

Prometheus stores time-series data locally in its TSDB.

Retention can be controlled using `--storage.tsdb.retention.time`.

Storage usage depends on the number of time series, scrape interval and retention period.

In containerized environments I would use persistent storage, such as a Docker volume or persistent volume, so that Prometheus data survives container restarts or recreation.
