# KUB-22 Service 503 — Selector and Endpoint Troubleshooting

## Goal

Understand how a Kubernetes Service finds backend Pods and how to diagnose a Service that exists but cannot forward traffic because it has no valid endpoints.

The lab demonstrated:

```text
Service
Pod labels
Service selectors
Endpoints
EndpointSlices
failed backend discovery
curl troubleshooting
```

---

## Basic Service model

A Kubernetes Service does not automatically know which Pods belong to it.

It uses:

```text
selector
```

to find Pods with matching:

```text
labels
```

Mental model:

```text
Pod labels
↓
Service selector
↓
matching Pods
↓
Endpoints
↓
traffic
```

---

## Deployment

The lab used a Deployment with two nginx Pods.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: svc-demo

spec:
  replicas: 2

  selector:
    matchLabels:
      app: svc-demo

  template:
    metadata:
      labels:
        app: svc-demo

    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
```

---

## Important Pod label

The Pods created by the Deployment have:

```text
app=svc-demo
```

This label is what the Service must match.

---

## Create Deployment

```bash
kubectl apply -f deployment.yaml
```

Check Pods:

```bash
kubectl get pods -l app=svc-demo
```

The Deployment created two nginx Pods.

---

# Broken Service

The Service was intentionally configured incorrectly.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: svc-demo

spec:
  selector:
    app: wrong-label

  ports:
    - port: 80
      targetPort: 80
```

---

## Why this Service is broken

The Pods have:

```text
app=svc-demo
```

but the Service searches for:

```text
app=wrong-label
```

Therefore:

```text
Service selector
↓
searches for app=wrong-label
↓
no Pods match
↓
no endpoints
↓
traffic cannot reach application
```

---

# Service selector

The important part of the Service is:

```yaml
selector:
  app: svc-demo
```

The selector means:

```text
find Pods whose label is:
app=svc-demo
```

So:

```text
Pod:
app=svc-demo

Service:
selector app=svc-demo
```

results in a match.

---

## Selector connects Service to Pods

The relationship is:

```text
Pod
label: app=svc-demo
↓
Service
selector: app=svc-demo
↓
match
```

The Service can then use those Pods as backends.

---

# Endpoints

When a Service finds matching Pods, Kubernetes creates backend endpoint information.

Conceptually:

```text
Service svc-demo
↓
Pod A IP
Pod B IP
```

These Pod IP addresses are the Service backends.

---

## Check endpoints

```bash
kubectl get endpoints svc-demo
```

With the broken selector, the result showed:

```text
ENDPOINTS: <none>
```

This was the key troubleshooting clue.

---

# EndpointSlice

Modern Kubernetes stores Service backend information primarily using:

```text
EndpointSlice
```

Check:

```bash
kubectl get endpointslices \
  -l kubernetes.io/service-name=svc-demo
```

With the incorrect selector, no usable Pod endpoints were available.

---

## Endpoints vs EndpointSlice

Simplified:

```text
Endpoints
= older representation of Service backends

EndpointSlice
= newer scalable representation of Service backends
```

For troubleshooting, both help answer:

```text
Does this Service actually have backend Pods?
```

---

# Test client

A test Pod was created:

```bash
kubectl run svc-client \
  --image=curlimages/curl:latest \
  --restart=Never \
  -- sleep 3600
```

Enter it:

```bash
kubectl exec -it svc-client -- sh
```

Then:

```bash
curl --connect-timeout 5 http://svc-demo
```

The request failed.

---

# Why curl failed

The Service itself existed.

Its DNS name:

```text
svc-demo
```

could be used.

But there were no backend endpoints.

Flow:

```text
curl http://svc-demo
↓
Service exists
↓
selector does not match Pods
↓
ENDPOINTS = <none>
↓
Service has nowhere to send request
↓
connection fails
```

---

# Important distinction

A Service can exist while still being unusable.

```text
kubectl get svc
```

showing the Service does not prove that the application behind it is reachable.

You must also check:

```text
Endpoints
EndpointSlices
```

---

# Fix

The broken selector:

```yaml
selector:
  app: wrong-label
```

was changed to:

```yaml
selector:
  app: svc-demo
```

Now the Service selector matches the Pod labels.

---

## Apply fixed Service

```bash
kubectl apply -f service.yaml
```

---

## Check endpoints again

```bash
kubectl get endpoints svc-demo
```

Instead of:

```text
<none>
```

the Service should now show Pod IP addresses.

Conceptually:

```text
10.244.x.x:80
10.244.x.y:80
```

---

## Check EndpointSlice

```bash
kubectl get endpointslices \
  -l kubernetes.io/service-name=svc-demo
```

Now the EndpointSlice should contain addresses for the matching Pods.

---

# Successful request flow

After fixing the selector:

```bash
kubectl exec -it svc-client -- sh
```

then:

```bash
curl http://svc-demo
```

The nginx page should be returned.

Flow:

```text
client
↓
DNS name svc-demo
↓
Service
↓
selector matches app=svc-demo
↓
Endpoints contain nginx Pods
↓
Service chooses backend
↓
nginx Pod
↓
HTTP response
```

---

# Service load balancing

Because two Pods match the selector:

```text
Pod A
Pod B
```

the Service has multiple backends.

Conceptually:

```text
client
↓
Service
↓
Pod A or Pod B
```

The client does not need to know individual Pod IP addresses.

It only uses:

```text
svc-demo
```

---

# Why Service is useful

Pod IP addresses can change when Pods are recreated.

Instead of clients using:

```text
10.244.x.x
```

directly, they use:

```text
svc-demo
```

The Service provides a stable access point.

---

# Full relationship

```text
Deployment
↓
creates Pods
↓
Pods get labels
↓
Service selector searches labels
↓
matching Pods become endpoints
↓
Service forwards traffic to endpoints
```

For this lab:

```text
Deployment svc-demo
↓
Pods:
app=svc-demo
↓
Service selector:
app=svc-demo
↓
Endpoints
↓
nginx
```

---

# Troubleshooting workflow

When a Service does not work:

```text
kubectl get svc
↓
Service exists?
↓
kubectl get pods
↓
Pods Running?
↓
check Pod labels
↓
kubectl get endpoints
↓
are endpoints empty?
↓
check Service selector
↓
compare selector with Pod labels
```

---

## Useful commands

Check Service:

```bash
kubectl get service svc-demo
```

Describe Service:

```bash
kubectl describe service svc-demo
```

Check Pods:

```bash
kubectl get pods -l app=svc-demo
```

Check labels:

```bash
kubectl get pods --show-labels
```

Check endpoints:

```bash
kubectl get endpoints svc-demo
```

Check EndpointSlices:

```bash
kubectl get endpointslices \
  -l kubernetes.io/service-name=svc-demo
```

Test from client:

```bash
kubectl exec -it svc-client -- sh
```

Then:

```bash
curl http://svc-demo
```

---

# Common causes of empty Service endpoints

If:

```text
ENDPOINTS = <none>
```

check:

```text
wrong Service selector
wrong Pod labels
Pods not Ready
wrong namespace
Pods do not exist
Deployment failed
```

---

# Selector troubleshooting

Compare:

```bash
kubectl get service svc-demo -o yaml
```

with:

```bash
kubectl get pods --show-labels
```

You are checking whether:

```text
Service selector
==
Pod labels
```

---

# Key takeaways

```text
Service finds Pods using selectors

Pods expose labels

selector must match Pod labels

matching Pods become Service endpoints

EndpointSlice stores backend information

Service may exist even when it has no backends

ENDPOINTS <none> is an important troubleshooting clue

wrong selector can completely break Service traffic

clients use stable Service names instead of Pod IPs
```

---

# Mental model

```text
Pod labels
↓
Service selector
↓
Endpoints
↓
traffic
```

Broken:

```text
Pods:
app=svc-demo

Service:
app=wrong-label

↓
no match
↓
no endpoints
↓
request fails
```

Fixed:

```text
Pods:
app=svc-demo

Service:
app=svc-demo

↓
match
↓
endpoints created
↓
request works
```

---

# Interview summary

A Kubernetes Service discovers backend Pods using its selector.

The selector is matched against Pod labels. Matching Pods are represented as Service endpoints, primarily through EndpointSlices.

In this lab, the Service used an incorrect selector, so it had no endpoints even though the Service object itself existed.

The troubleshooting process was to inspect the Service, check its endpoints, compare the Service selector with Pod labels, correct the selector, and verify that endpoint addresses appeared.

Once the selector matched the Pod labels, traffic through the Service successfully reached the nginx Pods.
