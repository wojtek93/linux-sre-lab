# KUB-06 Service — ClusterIP

## Goal

Understand why Kubernetes Services are needed, how a ClusterIP Service discovers Pods using labels, how EndpointSlice tracks current backend Pod IPs, and why clients should use a stable Service name instead of direct Pod IPs.

---

## The problem

Pods have their own IP addresses.

Example:

```text
10.244.0.4
10.244.0.7
```

However, Pod IP addresses are not stable.

If a Pod is deleted:

```text
old Pod
↓
deleted
↓
Deployment creates replacement Pod
↓
new Pod receives a new IP
```

Therefore clients should not normally depend directly on Pod IP addresses.

---

## Solution: Service

A Kubernetes Service provides a stable network endpoint in front of a set of Pods.

Simplified:

```text
Client
↓
Service
↓
Pod
```

If multiple Pods match the Service:

```text
Client
↓
Service
↓
Pod A / Pod B / Pod C
```

---

## Service manifest

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service

spec:
  selector:
    app: nginx-deploy

  ports:
    - port: 80
      targetPort: 80

  type: ClusterIP
```

---

## apiVersion

```yaml
apiVersion: v1
```

Service is a core Kubernetes resource and uses API version:

```text
v1
```

---

## kind

```yaml
kind: Service
```

This defines a Kubernetes Service object.

---

## metadata.name

```yaml
metadata:
  name: nginx-service
```

The Service is named:

```text
nginx-service
```

This name can also be used as a DNS name by workloads inside the cluster.

Example:

```bash
curl http://nginx-service
```

Important:

```text
Service name
= how clients reach the Service
```

---

## Selector

```yaml
selector:
  app: nginx-deploy
```

The Service does not select Pods by Pod name.

It selects Pods by labels.

Meaning:

```text
find Pods with:

app=nginx-deploy
```

Example:

```text
Pod A → app=nginx-deploy
Pod B → app=nginx-deploy
Pod C → app=nginx-deploy
```

All matching Pods can become backends for the Service.

---

## Service name vs selector

These are different concepts.

```text
metadata.name
= how client identifies Service

selector
= how Service identifies backend Pods
```

Example:

```text
Service name:
nginx-service

selector:
app=nginx-deploy
```

Flow:

```text
client
↓
nginx-service
↓
Service finds Pods using selector
↓
app=nginx-deploy
```

---

## port

```yaml
port: 80
```

This is the port exposed by the Service.

Clients connect to:

```text
nginx-service:80
```

---

## targetPort

```yaml
targetPort: 80
```

This is the destination port on backend Pods.

Flow:

```text
Service port 80
↓
Pod targetPort 80
```

---

## ClusterIP

```yaml
type: ClusterIP
```

ClusterIP is the default Kubernetes Service type.

It provides a stable virtual IP reachable from inside the cluster.

In the lab:

```text
ClusterIP: 10.96.29.186
```

The client could therefore use:

```bash
curl http://10.96.29.186
```

or preferably the Service DNS name:

```bash
curl http://nginx-service
```

---

## Create Service

```bash
kubectl apply -f service.yaml
```

---

## List Services

```bash
kubectl get service
```

Short form:

```bash
kubectl get svc
```

Specific Service:

```bash
kubectl get svc nginx-service
```

The output included:

```text
TYPE
CLUSTER-IP
PORT
```

---

## Describe Service

```bash
kubectl describe svc nginx-service
```

Important fields include:

```text
Name
Namespace
Selector
Type
IP
Port
TargetPort
Endpoints
```

---

## Lab Service details

The lab Service showed:

```text
Name: nginx-service
Type: ClusterIP
IP: 10.96.29.186
Port: 80
TargetPort: 80
Selector: app=nginx-deploy
```

---

## EndpointSlice

Kubernetes tracks backend Pod addresses using EndpointSlice resources.

Command:

```bash
kubectl get endpointslices \
  -l kubernetes.io/service-name=nginx-service
```

More detail:

```bash
kubectl get endpointslices \
  -l kubernetes.io/service-name=nginx-service \
  -o wide
```

The EndpointSlice contained backend Pod IP addresses.

Example:

```text
10.244.0.4
10.244.0.7
```

---

## Service discovery flow

```text
Client
↓
nginx-service
↓
Kubernetes DNS
↓
ClusterIP
↓
EndpointSlice
↓
backend Pod
```

---

## Service and Pod labels

The Deployment creates Pods with:

```yaml
labels:
  app: nginx-deploy
```

The Service contains:

```yaml
selector:
  app: nginx-deploy
```

Therefore:

```text
Service selector
app=nginx-deploy
        │
        │ matches
        ↓
Pod label
app=nginx-deploy
```

This is how the Service discovers its backend Pods.

---

## Test Service from another Pod

A temporary curl Pod was used as a client.

Example:

```bash
kubectl run curl-client \
  --image=curlimages/curl:latest \
  --restart=Never \
  -- sleep 3600
```

Check status:

```bash
kubectl get pod curl-client
```

The Pod must be:

```text
Running
```

Then enter it:

```bash
kubectl exec -it curl-client -- sh
```

---

## Test using Service DNS

Inside curl-client:

```bash
curl http://nginx-service
```

This sends traffic through the Service.

---

## Test using ClusterIP

Inside curl-client:

```bash
curl http://10.96.29.186
```

This also reaches the same Service.

---

## Why curl-client sometimes failed

A previous curl-client Pod had already completed or failed.

Attempting:

```bash
kubectl exec -it curl-client -- sh
```

returned an error similar to:

```text
cannot exec into a container in a completed pod
```

or:

```text
current phase is Failed
```

`kubectl exec` requires a running container.

---

## Recreate curl-client

Delete the old Pod:

```bash
kubectl delete pod curl-client
```

Create a new long-running Pod:

```bash
kubectl run curl-client \
  --image=curlimages/curl:latest \
  --restart=Never \
  -- sleep 3600
```

Then:

```bash
kubectl exec -it curl-client -- sh
```

---

## Backend replacement test

The backend Pods were listed with:

```bash
kubectl get pods -l app=nginx-deploy -o wide
```

Example Pod IPs:

```text
10.244.0.4
10.244.0.7
```

One Pod was deleted:

```bash
kubectl delete pod <pod-name>
```

Because the Pods were managed by a Deployment, Kubernetes created a replacement.

---

## EndpointSlice update

Before deletion:

```text
10.244.0.4
10.244.0.7
```

After replacement:

```text
10.244.0.4
10.244.0.10
```

The old Pod IP disappeared and the new Pod IP was automatically added.

---

## What remained stable

The Pod IP changed:

```text
10.244.0.7
↓
deleted
↓
10.244.0.10
```

But the Service remained:

```text
nginx-service
```

and its ClusterIP remained:

```text
10.96.29.186
```

This is the main purpose of a Service.

---

## Stable frontend, changing backends

```text
Client
↓
nginx-service
↓
10.96.29.186
↓
EndpointSlice
↓
10.244.0.4
10.244.0.10
```

The client does not need to know that backend Pod IP addresses changed.

---

## Pod IP vs Service IP

Pod IP:

```text
temporary
can change after Pod recreation
belongs to a specific Pod
```

Service ClusterIP:

```text
stable while Service exists
represents a logical group of Pods
used as a stable internal endpoint
```

---

## Service DNS

Instead of hardcoding:

```text
10.96.29.186
```

applications inside the cluster can use:

```text
nginx-service
```

Example:

```bash
curl http://nginx-service
```

This is generally easier because clients do not need to know the ClusterIP.

---

## Multiple backend Pods

If the selector matches multiple Pods:

```text
Service
↓
EndpointSlice
├── Pod A
├── Pod B
└── Pod C
```

Traffic can be distributed across available Service backends.

If only one Pod matches:

```text
Service
↓
Pod A
```

the Service still works.

---

## Mental model

```text
Service name
= how client finds Service

ClusterIP
= stable virtual Service address

selector
= how Service finds Pods

EndpointSlice
= current backend Pod addresses

Pod IP
= individual, replaceable backend address
```

---

## Full flow

```text
Client Pod
↓
curl http://nginx-service
↓
Service DNS
↓
ClusterIP
↓
Service selector
↓
EndpointSlice
↓
one matching Pod
↓
nginx container
```

---

## Useful commands

Create Service:

```bash
kubectl apply -f service.yaml
```

List Services:

```bash
kubectl get svc
```

Describe Service:

```bash
kubectl describe svc nginx-service
```

Check matching Pods:

```bash
kubectl get pods -l app=nginx-deploy -o wide
```

Check EndpointSlice:

```bash
kubectl get endpointslices \
  -l kubernetes.io/service-name=nginx-service \
  -o wide
```

Create curl client:

```bash
kubectl run curl-client \
  --image=curlimages/curl:latest \
  --restart=Never \
  -- sleep 3600
```

Enter curl client:

```bash
kubectl exec -it curl-client -- sh
```

Test DNS:

```bash
curl http://nginx-service
```

Test ClusterIP:

```bash
curl http://10.96.29.186
```

---

## Key takeaways

```text
Pods have replaceable IP addresses

Service provides a stable endpoint

ClusterIP is an internal virtual Service IP

Service selects Pods using labels, not Pod names

metadata.name becomes the Service name

Service DNS can be used by clients inside the cluster

port is the Service port

targetPort is the backend Pod port

EndpointSlice contains current backend Pod addresses

EndpointSlice automatically changes when backend Pods change

clients do not need to know individual Pod IPs
```

---

## Interview summary

A Kubernetes Service provides a stable network endpoint for a dynamic set of Pods.

The Service uses a label selector to identify backend Pods. Kubernetes tracks their current IP addresses using EndpointSlices.

With a ClusterIP Service, clients inside the cluster can connect using the stable Service DNS name or ClusterIP instead of individual Pod IPs.

If a Pod is deleted and recreated with a different IP, the EndpointSlice is automatically updated while the Service name and ClusterIP remain stable.
