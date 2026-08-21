# KUB-21 Pending Pod Troubleshooting

## Goal

Understand why a Kubernetes Pod can remain in:

```text
Pending
```

and how to diagnose scheduling problems caused by insufficient resources.

The lab demonstrated:

```text
Pending
FailedScheduling
resource requests
CPU units
memory units
kubectl describe
scheduler decisions
```

---

## What does Pending mean?

A Pod in:

```text
Pending
```

has been accepted by Kubernetes, but it has not yet been successfully scheduled and started.

Simplified:

```text
Pod created
↓
Scheduler tries to find a Node
↓
no suitable Node found
↓
Pod remains Pending
```

---

## Broken Pod

The lab intentionally requested an unrealistic amount of resources.

Example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pending-demo

spec:
  containers:
    - name: demo
      image: nginx:latest

      resources:
        requests:
          cpu: "100"
          memory: "100Gi"
```

---

## Why this Pod cannot start

The Pod requested:

```text
100 CPU
100 GiB RAM
```

The lab cluster Node does not have that amount of capacity.

Therefore:

```text
Pod requests too many resources
↓
Scheduler checks Node
↓
Node does not have enough CPU/RAM
↓
Pod cannot be scheduled
↓
Pending
```

---

## Create broken Pod

```bash
kubectl apply -f pending-pod.yaml
```

Check:

```bash
kubectl get pod pending-demo
```

Result:

```text
STATUS: Pending
```

---

## Troubleshooting command

The main diagnostic command was:

```bash
kubectl describe pod pending-demo
```

The most important section was:

```text
Events
```

---

## FailedScheduling

The Events section showed:

```text
FailedScheduling
```

with a message similar to:

```text
0/1 nodes are available:
1 Insufficient cpu,
1 Insufficient memory
```

This tells us exactly why the Pod could not be scheduled.

---

## What scheduler is doing

The scheduler evaluates:

```text
Pod resource requests
↓
available Nodes
↓
Node capacity / allocatable resources
↓
can this Pod fit?
```

If not:

```text
Pod remains Pending
```

---

## Requests are important

The scheduler uses:

```yaml
resources:
  requests:
```

when deciding where the Pod can run.

Example:

```yaml
requests:
  cpu: "50m"
  memory: "64Mi"
```

means:

```text
CPU request = 0.05 CPU
Memory request = 64 MiB
```

---

# CPU units

This lab exposed an important Kubernetes CPU syntax issue.

Initially the CPU request was accidentally changed to:

```yaml
cpu: "50"
```

This does NOT mean:

```text
50 millicpu
```

It means:

```text
50 full CPUs
```

That was still far too much for the Node.

---

## Correct CPU syntax

```yaml
cpu: "50m"
```

means:

```text
50 millicpu
```

and:

```text
1000m = 1 CPU
500m  = 0.5 CPU
100m  = 0.1 CPU
50m   = 0.05 CPU
```

So:

```text
50
```

and:

```text
50m
```

are completely different values.

---

## Incorrect request

```yaml
requests:
  cpu: "50"
  memory: "64Mi"
```

Result:

```text
Pending
```

because:

```text
50 CPU
```

was still impossible to schedule.

`kubectl describe pod pending-demo` showed:

```text
Insufficient cpu
```

---

## Correct request

The manifest was fixed to:

```yaml
resources:
  requests:
    cpu: "50m"
    memory: "64Mi"
```

This means:

```text
0.05 CPU
64 MiB RAM
```

which the Node can provide.

---

## Recreate Pod

Because this was a standalone Pod:

```bash
kubectl delete pod pending-demo
kubectl apply -f pending-pod.yaml
```

Then:

```bash
kubectl get pod pending-demo -w
```

Expected state transition:

```text
Pending
↓
ContainerCreating
↓
Running
```

---

# Pending vs other common statuses

## Pending

```text
Pod has not successfully started
```

Typical causes:

```text
insufficient CPU
insufficient memory
PVC not available
nodeSelector mismatch
taints/tolerations
affinity rules
```

---

## ImagePullBackOff

```text
Pod was scheduled
↓
Kubernetes cannot pull image
```

Typical causes:

```text
wrong image
wrong tag
registry problem
authentication problem
```

---

## CrashLoopBackOff

```text
container starts
↓
application crashes
↓
container restarts repeatedly
```

---

## Short comparison

```text
Pending
= scheduler cannot get Pod running

ImagePullBackOff
= image cannot be pulled

CrashLoopBackOff
= container starts but crashes
```

---

# Troubleshooting flow

When a Pod is Pending:

```text
kubectl get pods
↓
identify Pending Pod
↓
kubectl describe pod
↓
check Events
↓
look for FailedScheduling
↓
read exact scheduler message
```

---

## Common FailedScheduling messages

Examples:

```text
Insufficient cpu

Insufficient memory

node(s) didn't match Pod's node affinity

node(s) had untolerated taint

persistentvolumeclaim not found

no available persistent volumes
```

---

# Useful commands

Create Pod:

```bash
kubectl apply -f pending-pod.yaml
```

Check Pod:

```bash
kubectl get pod pending-demo
```

Watch Pod:

```bash
kubectl get pod pending-demo -w
```

Describe Pod:

```bash
kubectl describe pod pending-demo
```

Delete Pod:

```bash
kubectl delete pod pending-demo
```

Check Nodes:

```bash
kubectl get nodes
```

Inspect Node:

```bash
kubectl describe node
```

Check current resource usage:

```bash
kubectl top nodes
kubectl top pods
```

---

# Incident checklist

For:

```text
Pod Pending
```

check:

```text
1. kubectl describe pod

2. Events

3. FailedScheduling reason

4. CPU requests

5. memory requests

6. PVC requirements

7. nodeSelector

8. affinity rules

9. taints and tolerations
```

---

# Key takeaways

```text
Pending often means the Pod cannot be scheduled

kubectl describe pod is the first important troubleshooting command

Events show scheduler decisions

FailedScheduling gives the actual reason

resource requests influence scheduling

too-large requests can prevent Pod placement

CPU units must be read carefully

50 means 50 CPUs

50m means 0.05 CPU

fixing requests allows the scheduler to place the Pod
```

---

# Mental model

```text
Pod
↓
resource requests
↓
Scheduler
↓
Node capacity
```

If requests fit:

```text
Scheduled
↓
ContainerCreating
↓
Running
```

If requests do not fit:

```text
FailedScheduling
↓
Pending
```

---

# Interview summary

A Pod in Pending state has been accepted by Kubernetes but has not yet been successfully scheduled and started.

The first troubleshooting step is to run `kubectl describe pod` and inspect the Events section.

In this lab, the Pod requested more CPU and memory than the Node could provide, resulting in `FailedScheduling` with `Insufficient cpu` and `Insufficient memory`.

An additional issue demonstrated that `cpu: "50"` means 50 full CPUs, while `cpu: "50m"` means 50 millicpu, or 0.05 CPU.

After correcting the resource requests to realistic values, the Pod could be scheduled and started.
