# KUB-18 HPA — Horizontal Pod Autoscaler

## Goal

Understand how Kubernetes Horizontal Pod Autoscaler automatically changes the number of Pod replicas based on resource usage.

The lab demonstrated:

```text
Metrics Server
CPU metrics
HorizontalPodAutoscaler
scale up
scale down
minReplicas
maxReplicas
CPU utilization target
```

---

## What is HPA?

HPA means:

```text
Horizontal Pod Autoscaler
```

It automatically changes the number of Pod replicas.

Simplified:

```text
low load
↓
fewer Pods

high load
↓
more Pods
```

---

## Horizontal scaling

Horizontal scaling means changing the number of application instances.

Example:

```text
1 Pod
↓
high CPU
↓
5 Pods
```

This is different from vertical scaling, where one Pod receives more CPU or memory.

---

# Application Deployment

The lab used a Deployment called:

```text
hpa-demo
```

Manifest:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hpa-demo

spec:
  replicas: 1

  selector:
    matchLabels:
      app: hpa-demo

  template:
    metadata:
      labels:
        app: hpa-demo

    spec:
      containers:
        - name: php-apache
          image: registry.k8s.io/hpa-example

          ports:
            - containerPort: 80

          resources:
            requests:
              cpu: 100m

            limits:
              cpu: 500m
```

---

## Why CPU request is important

The container had:

```yaml
requests:
  cpu: 100m
```

The HPA CPU utilization percentage is calculated relative to the CPU request.

In this lab:

```text
CPU request = 100m
```

So conceptually:

```text
50m CPU usage
↓
approximately 50% utilization
```

and:

```text
100m CPU usage
↓
approximately 100% utilization
```

---

## CPU units

```text
1000m = 1 CPU

500m = 0.5 CPU

100m = 0.1 CPU
```

---

# Service

The application was exposed internally using a Service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: hpa-demo

spec:
  selector:
    app: hpa-demo

  ports:
    - port: 80
      targetPort: 80
```

This provided a stable endpoint:

```text
hpa-demo
```

for the load generator.

---

## Apply application

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

Check:

```bash
kubectl get pods -l app=hpa-demo
```

Initially there was one application Pod.

---

# Metrics Server

HPA needs resource metrics such as CPU usage.

Initially:

```bash
kubectl top pods
```

returned:

```text
Metrics API not available
```

This meant the cluster did not yet have working resource metrics.

---

## Install Metrics Server

Metrics Server was installed with:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Because the lab cluster runs using kind, the Metrics Server Deployment was patched with:

```bash
kubectl patch deployment metrics-server \
  -n kube-system \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
```

---

## Verify Metrics Server

```bash
kubectl get pods -n kube-system | grep metrics
```

Then:

```bash
kubectl top pods
```

started returning CPU and memory metrics.

Example:

```text
NAME                    CPU(cores)   MEMORY(bytes)
hpa-demo-xxxxxxxx       1m           15Mi
```

---

## Metrics flow

```text
Pods
↓
Kubelet
↓
Metrics Server
↓
Metrics API
↓
HPA
```

Simplified:

```text
Metrics Server
= provides CPU and memory metrics
```

---

# HPA manifest

The HPA configuration:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: hpa-demo

spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hpa-demo

  minReplicas: 1
  maxReplicas: 5

  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

---

## scaleTargetRef

```yaml
scaleTargetRef:
  apiVersion: apps/v1
  kind: Deployment
  name: hpa-demo
```

This tells HPA:

```text
scale the Deployment named hpa-demo
```

HPA itself does not directly create Pods.

Instead:

```text
HPA
↓
changes Deployment replica count
↓
Deployment creates or removes Pods
```

---

## minReplicas

```yaml
minReplicas: 1
```

Meaning:

```text
never scale below 1 Pod
```

---

## maxReplicas

```yaml
maxReplicas: 5
```

Meaning:

```text
never scale above 5 Pods
```

---

## CPU target

```yaml
averageUtilization: 50
```

Meaning:

```text
target average CPU utilization = 50%
```

HPA attempts to keep average CPU usage around this value.

---

## Apply HPA

```bash
kubectl apply -f hpa.yaml
```

Check:

```bash
kubectl get hpa
```

Initially the output showed one replica.

---

# Generate load

A load generator Pod was created:

```bash
kubectl run load-generator \
  --image=busybox:latest \
  --restart=Never \
  -- sh -c 'while true; do wget -q -O- http://hpa-demo; done'
```

The Pod continuously sent HTTP requests to:

```text
hpa-demo
```

---

## Load flow

```text
load-generator
↓
HTTP requests
↓
Service hpa-demo
↓
application Pods
↓
CPU usage increases
```

---

# Observe HPA

The HPA was observed with:

```bash
kubectl get hpa -w
```

Application Pods were observed in another terminal:

```bash
kubectl get pods -l app=hpa-demo -w
```

---

## Scale-up result

CPU utilization increased far above the configured target.

Observed values included approximately:

```text
462% / 50%
401% / 50%
404% / 50%
```

Meaning:

```text
actual CPU
>>
target CPU
```

HPA increased replicas:

```text
1
↓
4
↓
5
```

The configured maximum was:

```text
maxReplicas = 5
```

so scaling stopped at five Pods.

---

## Full scale-up flow

```text
load-generator creates requests
↓
application CPU rises
↓
Metrics Server reports CPU
↓
HPA sees CPU > 50%
↓
HPA increases desired replicas
↓
Deployment creates more Pods
↓
new Pods become Running
```

---

## What actually creates Pods?

Important distinction:

```text
Metrics Server
= measures

HPA
= decides desired replica count

Deployment
= creates/removes Pods
```

So:

```text
Metrics Server
↓
HPA
↓
Deployment
↓
Pods
```

---

# Stop load

The load generator was removed:

```bash
kubectl delete pod load-generator
```

After the traffic stopped, CPU usage dropped significantly.

Observed HPA utilization dropped to approximately:

```text
8% / 50%
```

Meaning:

```text
actual CPU = 8%
target = 50%
```

---

## Scale-down behavior

Even though CPU usage dropped below the target, the HPA did not immediately reduce replicas.

This is expected.

HPA uses stabilization behavior to avoid rapid scaling changes.

Without this behavior, replicas could constantly change:

```text
1
↓
5
↓
1
↓
5
↓
1
```

This unstable behavior is sometimes described as flapping or oscillation.

---

## Scale-down model

```text
CPU drops
↓
HPA sees utilization below target
↓
waits during stabilization period
↓
reduces desired replicas
↓
Deployment removes excess Pods
```

We did not wait for the full scale-down period because the important autoscaling behavior had already been verified.

---

# HPA decision model

Simplified:

```text
CPU > target
↓
scale up

CPU < target
↓
eventually scale down
```

For this lab:

```text
target = 50%
```

---

## Example

```text
CPU = 400%
target = 50%
↓
need substantially more capacity
↓
increase replicas
```

After load removal:

```text
CPU = 8%
target = 50%
↓
excess capacity
↓
eventual scale down
```

---

# Useful commands

Apply Deployment:

```bash
kubectl apply -f deployment.yaml
```

Apply Service:

```bash
kubectl apply -f service.yaml
```

Apply HPA:

```bash
kubectl apply -f hpa.yaml
```

Check HPA:

```bash
kubectl get hpa
```

Watch HPA:

```bash
kubectl get hpa -w
```

Describe HPA:

```bash
kubectl describe hpa hpa-demo
```

Check resource usage:

```bash
kubectl top pods
```

Watch application Pods:

```bash
kubectl get pods -l app=hpa-demo -w
```

Generate load:

```bash
kubectl run load-generator \
  --image=busybox:latest \
  --restart=Never \
  -- sh -c 'while true; do wget -q -O- http://hpa-demo; done'
```

Stop load:

```bash
kubectl delete pod load-generator
```

---

# Troubleshooting HPA

If HPA shows:

```text
<unknown>
```

for metrics, check:

```bash
kubectl top pods
```

If it returns:

```text
Metrics API not available
```

check Metrics Server:

```bash
kubectl get pods -n kube-system | grep metrics
```

Then:

```bash
kubectl describe deployment metrics-server -n kube-system
```

---

## Check HPA events

```bash
kubectl describe hpa hpa-demo
```

Important information includes:

```text
Metrics
Min replicas
Max replicas
Current replicas
Desired replicas
Conditions
Events
```

---

# Why requests matter for HPA

CPU percentage based HPA requires meaningful CPU requests.

For example:

```yaml
requests:
  cpu: 100m
```

Without a CPU request, utilization-based HPA may not be able to calculate the percentage correctly for that container.

---

# HPA vs resource limits

Do not confuse:

```text
CPU request
CPU limit
HPA target
```

In this lab:

```text
CPU request = 100m
CPU limit = 500m
HPA target = 50%
```

The request is used as the reference for utilization.

The limit caps available CPU.

The HPA target determines when scaling should occur.

---

# HPA vs Deployment

Deployment:

```text
maintains desired number of replicas
```

HPA:

```text
automatically changes that desired number
```

So:

```text
HPA
↓
sets replicas
↓
Deployment
↓
maintains those replicas
```

---

# HPA vs vertical scaling

Horizontal scaling:

```text
more Pods
```

Example:

```text
1 Pod → 5 Pods
```

Vertical scaling:

```text
more CPU/RAM for the same Pod
```

This lab focused on horizontal scaling.

---

# Key takeaways

```text
HPA automatically adjusts replica count

Metrics Server provides CPU and memory metrics

kubectl top uses the Metrics API

HPA can target a Deployment

minReplicas defines minimum replica count

maxReplicas defines maximum replica count

CPU utilization target can trigger scaling

high CPU causes scale up

low CPU eventually causes scale down

HPA changes replica count

Deployment actually creates and removes Pods

CPU requests are important for utilization-based HPA

scale down is intentionally slower to prevent oscillation
```

---

# Mental model

```text
traffic
↓
CPU usage
↓
Metrics Server
↓
HPA
↓
desired replicas
↓
Deployment
↓
Pods
```

High load:

```text
1 Pod
↓
CPU 400%
↓
HPA
↓
5 Pods
```

Low load:

```text
traffic stops
↓
CPU 8%
↓
stabilization period
↓
eventual scale down
```

---

# Interview summary

A Kubernetes HorizontalPodAutoscaler automatically adjusts the number of replicas of a scalable workload such as a Deployment.

HPA reads resource metrics through the Kubernetes Metrics API, commonly provided by Metrics Server.

In this lab, the HPA targeted 50% average CPU utilization with a minimum of one replica and a maximum of five replicas.

A load generator increased CPU utilization above 400%, causing the HPA to scale the Deployment from one Pod to five Pods.

After the load generator was removed, CPU utilization dropped significantly. HPA scale-down is intentionally delayed by stabilization behavior to avoid rapid replica oscillation.
