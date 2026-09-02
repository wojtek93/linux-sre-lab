# PRO-15 Kubernetes Service Discovery and Relabeling

## Goal

Understand how Prometheus discovers Kubernetes targets dynamically and how relabeling is used to filter and transform discovered targets.

---

## Why service discovery is needed

In a static environment Prometheus can use:

```yaml
static_configs:
  - targets:
      - "host.docker.internal:8000"
```

In Kubernetes this is not practical because Pods:

```text
are created
are deleted
change IP addresses
scale up and down
```

Therefore Prometheus can use Kubernetes Service Discovery.

---

## Kubernetes Service Discovery

Example:

```yaml
kubernetes_sd_configs:
  - role: pod
```

This means:

```text
Prometheus
↓
queries Kubernetes API
↓
discovers Pods
```

Prometheus receives temporary metadata labels such as:

```text
__meta_kubernetes_pod_name
__meta_kubernetes_namespace
__meta_kubernetes_pod_annotation_...
```

These labels are used during target discovery and relabeling.

---

## Relabeling

Relabeling is used to decide which discovered targets should be scraped and how their target metadata should be modified.

Mental model:

```text
Service Discovery
→ find candidates

Relabeling
→ filter and transform candidates
```

---

## Example configuration

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "kubernetes-pods"

    kubernetes_sd_configs:
      - role: pod

    relabel_configs:
      - source_labels:
          - __meta_kubernetes_pod_annotation_prometheus_io_scrape
        action: keep
        regex: "true"

      - source_labels:
          - __meta_kubernetes_pod_annotation_prometheus_io_path
        action: replace
        target_label: __metrics_path__
        regex: "(.+)"

      - source_labels:
          - __address__
          - __meta_kubernetes_pod_annotation_prometheus_io_port
        action: replace
        regex: "([^:]+)(?::\\d+)?;(\\d+)"
        replacement: "$1:$2"
        target_label: __address__

      - source_labels:
          - __meta_kubernetes_namespace
        target_label: namespace

      - source_labels:
          - __meta_kubernetes_pod_name
        target_label: pod
```

---

## Filtering by annotation

Example Pod:

```yaml
metadata:
  annotations:
    prometheus.io/scrape: "true"
```

Relabel rule:

```yaml
- source_labels:
    - __meta_kubernetes_pod_annotation_prometheus_io_scrape
  action: keep
  regex: "true"
```

Meaning:

```text
scrape=true
→ keep target

scrape=false or missing
→ discard target
```

---

## Metrics path

Pod annotation:

```yaml
prometheus.io/path: "/metrics"
```

Relabeling sets:

```text
__metrics_path__ = /metrics
```

This tells Prometheus where the metrics endpoint is located.

---

## Port relabeling

Example discovered address:

```text
10.244.1.23:8080
```

Pod annotation:

```yaml
prometheus.io/port: "8000"
```

After relabeling:

```text
10.244.1.23:8000
```

Meaning:

```text
Pod IP
+
metrics port
↓
final scrape address
```

---

## Namespace label

Temporary discovery metadata:

```text
__meta_kubernetes_namespace = production
```

Relabeling converts it into:

```text
namespace="production"
```

This can later be used in PromQL:

```promql
up{namespace="production"}
```

---

## Pod label

Temporary metadata:

```text
__meta_kubernetes_pod_name = api-7f8d9c6b5c-x2k4m
```

Relabeling converts it into:

```text
pod="api-7f8d9c6b5c-x2k4m"
```

---

## Full example

Pod:

```yaml
metadata:
  name: api-7f8d9c6b5c-x2k4m
  namespace: production
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
    prometheus.io/port: "8000"
```

Pod IP:

```text
10.244.1.23
```

Prometheus discovery metadata:

```text
__address__ = 10.244.1.23:8080
__meta_kubernetes_pod_name = api-7f8d9c6b5c-x2k4m
__meta_kubernetes_namespace = production
__meta_kubernetes_pod_annotation_prometheus_io_scrape = true
__meta_kubernetes_pod_annotation_prometheus_io_path = /metrics
__meta_kubernetes_pod_annotation_prometheus_io_port = 8000
```

After relabeling:

```text
target kept
__metrics_path__ = /metrics
__address__ = 10.244.1.23:8000
namespace="production"
pod="api-7f8d9c6b5c-x2k4m"
```

Final scrape endpoint:

```text
http://10.244.1.23:8000/metrics
```

---

## Example of rejected target

Pod:

```yaml
metadata:
  name: worker-123
  annotations:
    prometheus.io/scrape: "false"
```

Relabeling checks:

```text
scrape=false
```

But the rule requires:

```text
true
```

Therefore:

```text
target discarded
```

---

## Key takeaways

```text
Kubernetes Service Discovery
→ dynamically finds Pods and other Kubernetes resources

__meta_kubernetes_*
→ temporary discovery metadata

relabel_configs
→ filters and transforms discovered targets

action: keep
→ keep only matching targets

__address__
→ final target address

__metrics_path__
→ metrics endpoint path
```

---

## Interview summary

I understand how Prometheus can use Kubernetes Service Discovery instead of static target configuration.

Prometheus queries the Kubernetes API and discovers Pods dynamically.

The discovered targets contain temporary metadata labels such as namespace, Pod name and annotations.

I used relabeling rules to keep only Pods marked for scraping, set the metrics path and port, and convert Kubernetes metadata into useful Prometheus labels such as namespace and pod.

This allows Prometheus to monitor dynamic Kubernetes workloads without manually maintaining Pod IP addresses.
