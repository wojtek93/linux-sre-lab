# KUB-03 Pod

## Goal

Understand the basic Kubernetes Pod lifecycle and learn how to create, inspect, enter and delete a standalone Pod.

---

## Pod manifest

Example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

---

## Create Pod

```bash
kubectl apply -f pod.yaml
```

---

## Check Pod status

```bash
kubectl get pod nginx-pod
```

More details:

```bash
kubectl get pod nginx-pod -o wide
```

Important fields:

```text
READY
STATUS
RESTARTS
AGE
IP
NODE
```

---

## Pod details

```bash
kubectl describe pod nginx-pod
```

Important information observed:

```text
Status: Running
Ready: True
Restart Count: 0
Image: nginx:latest
Port: 80/TCP
```

The Pod received its own IP address and was scheduled on a Node.

---

## Pod lifecycle events

The Events section showed:

```text
Scheduled
Pulling
Pulled
Created
Started
```

Simplified lifecycle:

```text
Pod definition created
↓
Scheduler selects Node
↓
kubelet handles Pod
↓
image pulled
↓
container created
↓
container started
↓
Pod Running
```

---

## Enter container

```bash
kubectl exec -it nginx-pod -- sh
```

Inside:

```bash
hostname
ip addr
```

Exit:

```bash
exit
```

---

## Delete Pod

```bash
kubectl delete pod nginx-pod
```

Then:

```bash
kubectl get pods
```

The Pod disappears.

---

## Standalone Pod behavior

Important:

```text
standalone Pod
↓
deleted
↓
not recreated
```

This happens because there is no higher-level controller managing the Pod.

---

## Pod vs Deployment

Standalone Pod:

```text
Pod
↓
delete
↓
gone
```

Deployment-managed Pod:

```text
Deployment
↓
Pod
↓
delete Pod
↓
Deployment notices missing replica
↓
new Pod created
```

---

## Key commands

```bash
kubectl apply -f pod.yaml

kubectl get pod nginx-pod

kubectl get pod nginx-pod -o wide

kubectl get pod nginx-pod -o yaml

kubectl describe pod nginx-pod

kubectl exec -it nginx-pod -- sh

kubectl delete pod nginx-pod
```

---

## Key takeaways

```text
Pod is the smallest deployable unit in Kubernetes

Pod contains one or more containers

Pod gets its own IP

Scheduler selects a Node

kubelet starts and monitors the Pod

standalone Pod is not automatically recreated after deletion
```

---

## Interview summary

A Pod is the smallest deployable unit in Kubernetes.

It contains one or more containers that share networking and storage context.

A standalone Pod can be created directly with a Pod manifest, but if it is deleted, Kubernetes will not recreate it unless it is managed by a controller such as a Deployment.
