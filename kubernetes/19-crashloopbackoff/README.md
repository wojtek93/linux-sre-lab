# KUB-19 CrashLoopBackOff

## Goal

Understand how to diagnose and fix a Pod stuck in CrashLoopBackOff.

The lab demonstrated:

```text
CrashLoopBackOff
container restarts
exit codes
Last State
kubectl describe
kubectl logs
kubectl logs --previous
basic incident troubleshooting
```

---

## What is CrashLoopBackOff?

CrashLoopBackOff means:

```text
container starts
↓
container crashes
↓
Kubernetes restarts it
↓
container crashes again
↓
restart delay increases
```

It is not the original cause of the failure.

It is a symptom that the container repeatedly fails after startup.

---

## Broken Pod

The lab used:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: crash-demo

spec:
  containers:
    - name: demo
      image: busybox:latest
      command:
        - sh
        - -c
        - "echo Starting app; sleep 2; exit 1"
```

---

## Why the container crashes

The command contains:

```bash
exit 1
```

A non-zero exit code means the process failed.

So:

```text
container starts
↓
echo Starting app
↓
sleep 2
↓
exit 1
↓
process terminates with error
```

---

## Create broken Pod

```bash
kubectl apply -f broken-pod.yaml
```

Watch:

```bash
kubectl get pod crash-demo -w
```

The Pod eventually entered:

```text
CrashLoopBackOff
```

---

## Typical state flow

```text
Running
↓
Error
↓
restart
↓
Running
↓
Error
↓
CrashLoopBackOff
```

---

## First troubleshooting step

```bash
kubectl describe pod crash-demo
```

Important fields observed:

```text
State: Waiting
Reason: CrashLoopBackOff

Last State: Terminated
Reason: Error
Exit Code: 1

Restart Count: 3
```

---

## State vs Last State

Current State:

```text
Waiting
CrashLoopBackOff
```

means Kubernetes is currently waiting before the next restart.

Last State:

```text
Terminated
Error
Exit Code: 1
```

shows what happened during the previous execution.

---

## Exit Code 1

```text
Exit Code: 1
```

means the application process exited with an error.

Unlike:

```text
Exit Code: 0
```

which normally means success.

---

## Restart Count

The Pod showed:

```text
Restart Count: 3
```

This proves that Kubernetes had already restarted the container multiple times.

---

## Events

`kubectl describe` also showed restart-related events.

Conceptually:

```text
Created container
↓
Started container
↓
container crashes
↓
BackOff restarting failed container
```

---

# Logs

Current container logs:

```bash
kubectl logs crash-demo
```

Result:

```text
Starting app
```

---

## Previous container logs

Very important during CrashLoopBackOff:

```bash
kubectl logs crash-demo --previous
```

This shows logs from the previous terminated container instance.

Result:

```text
Starting app
```

---

## Why --previous matters

In a restart loop:

```text
container A crashes
↓
container B starts
```

Normal:

```bash
kubectl logs crash-demo
```

targets the current container instance.

But:

```bash
kubectl logs crash-demo --previous
```

lets us inspect the previous failed instance.

This is often essential during incident troubleshooting.

---

# Troubleshooting flow

A useful CrashLoopBackOff workflow:

```text
kubectl get pods
↓
identify CrashLoopBackOff
↓
kubectl describe pod
↓
check:
State
Last State
Reason
Exit Code
Restart Count
Events
↓
kubectl logs
↓
kubectl logs --previous
↓
identify root cause
```

---

## Common causes of CrashLoopBackOff

Examples include:

```text
bad application configuration
missing environment variables
missing Secret
bad command or arguments
application exception
failed dependency
permission problem
wrong file path
failed health checks
resource problems
```

CrashLoopBackOff itself does not tell us which one occurred.

We need logs and Pod state information to identify the actual cause.

---

# Fix

The broken command was:

```yaml
command:
  - sh
  - -c
  - "echo Starting app; sleep 2; exit 1"
```

It was changed to:

```yaml
command:
  - sh
  - -c
  - "echo Starting app; sleep 3600"
```

Now the process remains running instead of exiting with an error.

---

## Recreate Pod

Because this is a standalone Pod, it was recreated:

```bash
kubectl delete pod crash-demo
kubectl apply -f broken-pod.yaml
```

Then:

```bash
kubectl get pod crash-demo
```

Expected:

```text
READY   STATUS
1/1     Running
```

---

# Broken vs fixed flow

Broken:

```text
Pod
↓
container starts
↓
exit 1
↓
Error
↓
restart
↓
CrashLoopBackOff
```

Fixed:

```text
Pod
↓
container starts
↓
sleep 3600
↓
process remains alive
↓
Running
```

---

# Backoff behavior

Kubernetes does not restart a continuously failing container as fast as possible forever.

Instead:

```text
failure
↓
restart
↓
failure
↓
wait longer
↓
restart
↓
failure
↓
wait longer
```

This is the "BackOff" part of:

```text
CrashLoopBackOff
```

It prevents extremely aggressive restart loops.

---

# Useful commands

Check Pod:

```bash
kubectl get pod crash-demo
```

Watch Pod:

```bash
kubectl get pod crash-demo -w
```

Describe Pod:

```bash
kubectl describe pod crash-demo
```

Current logs:

```bash
kubectl logs crash-demo
```

Previous container logs:

```bash
kubectl logs crash-demo --previous
```

Delete Pod:

```bash
kubectl delete pod crash-demo
```

Recreate:

```bash
kubectl apply -f broken-pod.yaml
```

---

# Incident checklist

When seeing:

```text
CrashLoopBackOff
```

do not immediately restart everything.

Check:

```text
1. kubectl describe pod

2. Last State

3. Exit Code

4. Restart Count

5. Events

6. kubectl logs

7. kubectl logs --previous
```

Then fix the actual root cause.

---

# Key takeaways

```text
CrashLoopBackOff means repeated container crashes

CrashLoopBackOff is a symptom, not the root cause

non-zero exit code usually indicates failure

Restart Count shows how often the container restarted

Last State shows information about the previous container execution

kubectl describe is one of the first troubleshooting commands

kubectl logs shows container output

kubectl logs --previous is extremely useful after restarts

Kubernetes increases restart delay after repeated failures
```

---

# Mental model

```text
application starts
↓
application crashes
↓
Kubernetes restarts it
↓
application crashes again
↓
backoff delay increases
↓
CrashLoopBackOff
```

Troubleshooting:

```text
CrashLoopBackOff
↓
describe
↓
logs
↓
previous logs
↓
root cause
↓
fix
```

---

# Interview summary

CrashLoopBackOff indicates that a container repeatedly starts, terminates with an error and is restarted by Kubernetes.

The correct troubleshooting approach is to inspect the Pod using `kubectl describe`, check the container's current and previous state, exit code, restart count and events, and then inspect logs using both `kubectl logs` and `kubectl logs --previous`.

In this lab, the container intentionally exited with code 1, causing repeated restarts and CrashLoopBackOff. After replacing the failing command with a long-running process and recreating the Pod, it remained Running successfully.
