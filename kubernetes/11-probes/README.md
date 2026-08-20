# KUB-11 Probes

## Goal

Understand the purpose of Kubernetes startup, readiness and liveness probes and observe how they affect Pod behavior.

---

## Probe types

```text
startupProbe
= has the application finished starting?

readinessProbe
= is the application ready to receive traffic?

livenessProbe
= is the application still healthy?
```

---

## Pod manifest

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probe-demo

spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80

      startupProbe:
        httpGet:
          path: /
          port: 80
        periodSeconds: 2
        failureThreshold: 15

      readinessProbe:
        httpGet:
          path: /
          port: 80
        periodSeconds: 5

      livenessProbe:
        httpGet:
          path: /
          port: 80
        periodSeconds: 10
```

---

## HTTP probes

Each probe can perform an HTTP request.

Example:

```yaml
httpGet:
  path: /
  port: 80
```

Meaning:

```text
send HTTP GET request
↓
to path /
↓
on port 80
```

A successful HTTP response means the probe passes.

---

## startupProbe

The startup probe checks whether the application has successfully started.

Example:

```yaml
startupProbe:
  httpGet:
    path: /
    port: 80
  periodSeconds: 2
  failureThreshold: 15
```

This gives the application approximately:

```text
2 seconds × 15 failures
=
30 seconds
```

to start successfully.

Simplified:

```text
container starts
↓
startupProbe runs
↓
application becomes available
↓
startupProbe succeeds
↓
normal readiness and liveness checks continue
```

---

## Why startupProbe exists

Some applications start slowly.

Without a startup probe, liveness checks could restart an application before it has enough time to initialize.

Mental model:

```text
startupProbe
= give application time to start
```

---

## readinessProbe

The readiness probe determines whether the Pod should receive traffic.

Example:

```yaml
readinessProbe:
  httpGet:
    path: /
    port: 80
  periodSeconds: 5
```

If the probe succeeds:

```text
Ready = True
```

and the Pod can receive Service traffic.

---

## Readiness failure test

The readiness path was intentionally changed from:

```yaml
path: /
```

to:

```yaml
path: /does-not-exist
```

nginx returned:

```text
HTTP 404
```

The Pod remained:

```text
Running
```

but changed to:

```text
Ready = False
```

or:

```text
READY 0/1
```

---

## Readiness behavior

Important:

```text
readinessProbe failure
↓
container stays running
↓
Pod becomes NotReady
↓
Service should stop sending traffic to that Pod
```

The container was not restarted because of the readiness failure.

---

## Readiness event

`kubectl describe pod probe-demo` showed an event similar to:

```text
Readiness probe failed
HTTP probe failed with statuscode: 404
```

This confirmed that the readiness failure was caused by the invalid path.

---

## livenessProbe

The liveness probe determines whether the application is still healthy.

Example:

```yaml
livenessProbe:
  httpGet:
    path: /
    port: 80
  periodSeconds: 10
```

If the liveness probe keeps failing, Kubernetes restarts the container.

---

## Liveness failure test

The liveness path was intentionally changed to:

```yaml
path: /does-not-exist
```

The probe received HTTP 404 responses.

After repeated failures, Kubernetes restarted the nginx container.

---

## Liveness behavior

```text
livenessProbe fails
↓
Kubernetes considers container unhealthy
↓
container is killed
↓
container is started again
```

The restart was visible in:

```text
Restart Count: 1
```

---

## Liveness events

`kubectl describe pod probe-demo` showed events similar to:

```text
Liveness probe failed
Container nginx failed liveness probe, will be restarted
Killing
Started
```

This confirmed that the liveness failure caused a container restart.

---

## readiness vs liveness

Readiness failure:

```text
application is running
but should not receive traffic
```

Result:

```text
Running
READY 0/1
Restart Count unchanged
```

Liveness failure:

```text
application is considered unhealthy
```

Result:

```text
container restarted
Restart Count increases
```

---

## startup vs readiness vs liveness

```text
startupProbe
= did you finish starting?

readinessProbe
= can I send traffic to you?

livenessProbe
= are you still healthy?
```

---

## Standalone Pod update limitation

During the lab, an existing standalone Pod could not be modified in-place after changing its probe configuration.

`kubectl apply` returned an error because many Pod spec fields are immutable.

The solution was:

```bash
kubectl delete pod probe-demo
kubectl apply -f probe-lab.yaml
```

This recreated the Pod with the new probe configuration.

---

## Useful commands

Create Pod:

```bash
kubectl apply -f probe-lab.yaml
```

Check Pod:

```bash
kubectl get pod probe-demo
```

Watch Pod:

```bash
kubectl get pod probe-demo -w
```

Inspect probes and events:

```bash
kubectl describe pod probe-demo
```

Recreate standalone Pod after spec change:

```bash
kubectl delete pod probe-demo
kubectl apply -f probe-lab.yaml
```

---

## Key takeaways

```text
startupProbe protects slow-starting applications

readinessProbe controls whether Pod receives traffic

readiness failure does not restart container

livenessProbe detects unhealthy applications

liveness failure can restart container

Restart Count increases after liveness restart

HTTP 404 can intentionally fail an HTTP probe

standalone Pod probe configuration may require Pod recreation
```

---

## Mental model

```text
container starts
↓
startupProbe
↓
application started
↓
readinessProbe
↓
ready for traffic
↓
livenessProbe
↓
continuously checks health
```

---

## Interview summary

Kubernetes probes are used to monitor application lifecycle and health.

A startup probe determines whether an application has completed startup.

A readiness probe determines whether a Pod should receive traffic. If readiness fails, the Pod can remain Running but becomes NotReady.

A liveness probe determines whether the application is still healthy. Repeated liveness failures cause Kubernetes to restart the container.
