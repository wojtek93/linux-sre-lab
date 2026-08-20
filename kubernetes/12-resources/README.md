# KUB-12 Resources — Requests, Limits and OOMKilled

## Goal

Understand how Kubernetes CPU and memory requests and limits work, how the scheduler uses requests, and what happens when a container exceeds its memory limit.

The lab demonstrates:

```text
requests
limits
OOMKilled
Exit Code 137
CPU throttling concept
```

---

## Resource configuration

Example Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resources-demo

spec:
  containers:
    - name: demo
      image: polinux/stress
      command: ["stress"]
      args: ["--vm", "1", "--vm-bytes", "200M", "--vm-hang", "1"]

      resources:
        requests:
          memory: "64Mi"
          cpu: "100m"

        limits:
          memory: "128Mi"
          cpu: "500m"
```

---

## Requests

```yaml
requests:
  memory: "64Mi"
  cpu: "100m"
```

Requests describe how many resources the container expects to need.

The Kubernetes scheduler uses requests when deciding where a Pod can be placed.

Simplified:

```text
Pod requests resources
↓
Scheduler checks Nodes
↓
Node with enough available requested capacity is selected
```

---

## Memory request

```yaml
memory: "64Mi"
```

Meaning:

```text
requested memory = 64 MiB
```

This value is mainly used during scheduling.

It does not mean that the process can only use 64 MiB.

---

## CPU request

```yaml
cpu: "100m"
```

`m` means millicpu.

```text
1000m = 1 CPU
500m = 0.5 CPU
100m = 0.1 CPU
```

Therefore:

```text
100m
=
0.1 CPU
```

---

## Limits

```yaml
limits:
  memory: "128Mi"
  cpu: "500m"
```

Limits define the maximum resources the container is allowed to use.

---

## Memory limit

```yaml
memory: "128Mi"
```

This means the container cannot safely exceed approximately 128 MiB of memory.

If it exceeds the enforced memory limit:

```text
memory usage > limit
↓
kernel / cgroup detects violation
↓
process is killed
↓
Kubernetes reports OOMKilled
```

---

## CPU limit

```yaml
cpu: "500m"
```

Meaning:

```text
maximum CPU allocation = 0.5 CPU
```

CPU behaves differently from memory.

If a container tries to use more CPU than its limit:

```text
CPU usage > limit
↓
CPU is throttled
```

The container is normally not killed just because it tries to use more CPU.

---

## Stress workload

The lab used:

```yaml
image: polinux/stress
```

with:

```yaml
args:
  - "--vm"
  - "1"
  - "--vm-bytes"
  - "200M"
  - "--vm-hang"
  - "1"
```

The important part is:

```text
--vm-bytes 200M
```

The process tries to allocate approximately 200 MB of memory.

---

## First test

The memory limit was:

```text
128Mi
```

while the stress process tried to use:

```text
~200M
```

Result:

```text
200M
>
128Mi
↓
memory limit exceeded
↓
OOMKilled
```

---

## Create Pod

```bash
kubectl apply -f resources-lab.yaml
```

---

## Watch Pod

```bash
kubectl get pod resources-demo -w
```

The container repeatedly failed and restarted.

---

## Inspect Pod

```bash
kubectl describe pod resources-demo
```

The important output showed:

```text
Reason: OOMKilled
Exit Code: 137
Restart Count: 3
```

---

## What is OOMKilled?

OOM means:

```text
Out Of Memory
```

`OOMKilled` means the container process was killed because it exceeded its allowed memory.

Simplified:

```text
container
↓
uses too much memory
↓
memory limit exceeded
↓
OOM kill
↓
container restarted
```

---

## Exit Code 137

The failed container showed:

```text
Exit Code: 137
```

This commonly indicates that the process was terminated with `SIGKILL`.

In this lab it correlated with:

```text
Reason: OOMKilled
```

---

## Restart behavior

After the container was killed, Kubernetes restarted it.

The process again attempted to allocate too much memory.

This resulted in a loop:

```text
container starts
↓
stress allocates memory
↓
limit exceeded
↓
OOMKilled
↓
restart
↓
same thing happens again
```

---

## Fix

The memory limit was increased from:

```yaml
memory: "128Mi"
```

to:

```yaml
memory: "256Mi"
```

The Pod was recreated:

```bash
kubectl delete pod resources-demo
kubectl apply -f resources-lab.yaml
```

---

## Second test

After increasing the memory limit:

```text
stress wants ~200M
↓
limit = 256Mi
↓
process fits inside limit
↓
no OOMKilled
```

---

## Verified result

`kubectl describe pod resources-demo` showed:

```text
State: Running
Ready: True
Restart Count: 0
```

Resources showed:

```text
Limits:
  cpu: 500m
  memory: 256Mi

Requests:
  cpu: 100m
  memory: 64Mi
```

---

## Requests vs limits

The most important distinction:

```text
requests
= resources used by scheduler when placing Pod

limits
= maximum resources container may consume
```

---

## Memory behavior

```text
request memory = 64Mi
limit memory = 256Mi
```

The container may use more than its request.

Example:

```text
uses 150Mi
↓
request was only 64Mi
↓
still allowed
```

as long as it stays below:

```text
limit = 256Mi
```

---

## CPU behavior

CPU limit behavior differs from memory.

Memory:

```text
memory > limit
↓
OOMKilled
```

CPU:

```text
CPU demand > limit
↓
throttling
```

This means the process gets less CPU time instead of being killed.

---

## Scheduler perspective

Suppose a Node has limited capacity.

A Pod requests:

```text
cpu: 100m
memory: 64Mi
```

The scheduler evaluates whether the Node can satisfy those requests.

Conceptually:

```text
Pod request
↓
Scheduler
↓
check Node capacity
↓
choose suitable Node
```

---

## Why requests matter

Without sensible requests, Kubernetes has less accurate information about how much capacity workloads need.

Requests help with:

```text
scheduling
capacity planning
resource sharing
autoscaling decisions
```

---

## Why limits matter

Limits help prevent one container from consuming unlimited resources.

Example:

```text
broken application
↓
memory leak
↓
memory usage grows
↓
limit reached
↓
container constrained / killed
```

---

## QoS observation

The Pod showed:

```text
QoS Class: Burstable
```

This happens when resource requests and limits are defined but are not configured in a way that gives the Pod the `Guaranteed` QoS class.

---

## Useful commands

Create Pod:

```bash
kubectl apply -f resources-lab.yaml
```

Watch Pod:

```bash
kubectl get pod resources-demo -w
```

Inspect Pod:

```bash
kubectl describe pod resources-demo
```

Delete Pod:

```bash
kubectl delete pod resources-demo
```

Recreate Pod:

```bash
kubectl apply -f resources-lab.yaml
```

---

## Troubleshooting OOMKilled

Typical flow:

```text
Pod restarting
↓
kubectl get pods
↓
kubectl describe pod
↓
check Last State
↓
Reason: OOMKilled
↓
check memory requests and limits
↓
check application memory consumption
```

Useful:

```bash
kubectl describe pod <pod-name>
```

Look for:

```text
Last State
Reason
Exit Code
Restart Count
Limits
Requests
```

---

## Key takeaways

```text
requests influence scheduling

limits restrict maximum resource usage

memory request is not the maximum memory usage

memory limit is enforced

memory above limit can cause OOMKilled

OOMKilled commonly appears with Exit Code 137

CPU above limit is normally throttled

increasing memory limit can stop OOMKilled if the workload genuinely needs more memory
```

---

## Mental model

```text
requests
↓
Scheduler asks:
"Where can I place this Pod?"

limits
↓
Runtime asks:
"How much can this container consume?"
```

Memory:

```text
usage > memory limit
↓
OOMKilled
```

CPU:

```text
usage demand > CPU limit
↓
throttling
```

---

## Interview summary

Kubernetes resource requests and limits control workload resource allocation.

Requests are used by the scheduler when deciding where a Pod can run.

Limits define the maximum amount of CPU or memory a container can consume.

If a container exceeds its memory limit, it can be terminated with `OOMKilled`, commonly showing exit code 137.

CPU behaves differently: when CPU usage exceeds the configured limit, the container is usually throttled rather than killed.
