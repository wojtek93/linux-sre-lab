# KUB-08 Ingress

## Goal

Understand how Kubernetes Ingress routes HTTP traffic to Services based on host and path rules, and understand the difference between an Ingress resource and an Ingress Controller.

---

## What is Ingress?

Ingress defines HTTP/HTTPS routing rules.

Example:

```text
nginx.local
↓
Ingress rule
↓
nginx-service:80
```

Ingress itself contains configuration.

It does not process traffic by itself.

---

## What is an Ingress Controller?

The Ingress Controller is the component that actually receives HTTP traffic and applies Ingress rules.

In this lab the controller was:

```text
ingress-nginx-controller
```

Simplified:

```text
Ingress
= routing rules

Ingress Controller
= component executing those rules
```

---

## Ingress manifest

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress

spec:
  ingressClassName: nginx

  rules:
    - host: nginx.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-service
                port:
                  number: 80
```

---

## apiVersion

```yaml
apiVersion: networking.k8s.io/v1
```

Ingress belongs to the Kubernetes networking API group.

---

## kind

```yaml
kind: Ingress
```

This creates an Ingress resource.

---

## metadata.name

```yaml
metadata:
  name: nginx-ingress
```

The Ingress object is named:

```text
nginx-ingress
```

---

## ingressClassName

```yaml
ingressClassName: nginx
```

This tells Kubernetes that the Ingress should be handled by an nginx-compatible Ingress Controller.

---

## Host rule

```yaml
host: nginx.local
```

This means:

```text
requests with HTTP Host:
nginx.local
```

should match this Ingress rule.

---

## Path

```yaml
path: /
pathType: Prefix
```

This means the rule matches paths beginning with:

```text
/
```

Examples:

```text
/
 /test
 /api
 /anything
```

---

## Backend

```yaml
backend:
  service:
    name: nginx-service
    port:
      number: 80
```

This tells the Ingress Controller where matching traffic should be sent.

Flow:

```text
nginx.local
↓
Ingress
↓
nginx-service:80
```

The Service then selects one of its backend Pods.

---

## Full request flow

```text
Client
↓
Ingress Controller
↓
Ingress rule
↓
Service
↓
EndpointSlice
↓
Pod
```

For this lab:

```text
Client
↓
nginx.local
↓
ingress-nginx-controller
↓
nginx-ingress
↓
nginx-service:80
↓
nginx Pod
```

---

## Ingress Controller installation

The ingress-nginx controller had already been installed in the cluster.

It could be checked with:

```bash
kubectl get pods -n ingress-nginx
```

The controller Pod was running in namespace:

```text
ingress-nginx
```

---

## Apply Ingress

```bash
kubectl apply -f ingress.yaml
```

---

## Check Ingress

```bash
kubectl get ingress
```

---

## Describe Ingress

```bash
kubectl describe ingress nginx-ingress
```

Important fields include:

```text
Host
Path
Backend
Ingress Class
Events
```

In the lab:

```text
Host: nginx.local
Path: /
Backend: nginx-service:80
```

---

## Port-forward Ingress Controller

Because the cluster was running in kind, the controller was exposed locally with:

```bash
kubectl port-forward \
  -n ingress-nginx \
  svc/ingress-nginx-controller \
  8080:80
```

Meaning:

```text
local port 8080
↓
Ingress Controller Service port 80
```

---

## Test request

The request was sent with:

```bash
curl -H "Host: nginx.local" http://127.0.0.1:8080
```

The response returned the nginx page.

---

## What does -H mean?

In curl:

```text
-H
= add HTTP header
```

Example:

```bash
curl -H "Host: nginx.local" http://127.0.0.1:8080
```

adds:

```text
Host: nginx.local
```

to the HTTP request.

---

## Why Host header is needed

The actual TCP connection was made to:

```text
127.0.0.1:8080
```

but the Ingress routing rule expects:

```text
Host: nginx.local
```

The controller reads the Host header and decides which routing rule to use.

Simplified:

```text
127.0.0.1:8080
= where the request physically goes

Host: nginx.local
= which application the request is for
```

---

## Host-based routing

Ingress can route different hosts to different Services.

Example:

```text
app1.local
↓
service-a

app2.local
↓
service-b
```

Both can be handled by the same Ingress Controller.

---

## One address, multiple applications

A major benefit of Ingress is that multiple applications can share one ingress entry point.

Example:

```text
Ingress Controller
├── app1.local → service-a
├── app2.local → service-b
└── nginx.local → nginx-service
```

The Host header determines which backend should receive the request.

---

## Ingress vs Service

Service:

```text
stable endpoint for Pods
```

Ingress:

```text
HTTP/HTTPS routing to Services
```

Flow:

```text
Ingress
↓
Service
↓
Pod
```

Ingress does not normally route directly to individual Pods.

---

## Ingress vs NodePort

NodePort:

```text
NodeIP:30080
↓
Service
↓
Pod
```

Ingress:

```text
hostname
↓
Ingress Controller
↓
Service
↓
Pod
```

Ingress provides more flexible HTTP routing than directly exposing individual NodePorts.

---

## Ingress resource vs Ingress Controller

Important distinction:

```text
Ingress resource
= configuration

Ingress Controller
= running software
```

Without the controller:

```text
Ingress YAML exists
↓
but no component processes the traffic
```

With the controller:

```text
Ingress YAML
↓
controller reads rules
↓
traffic is routed
```

---

## Verified lab flow

The successful request confirmed:

```text
curl
↓
127.0.0.1:8080
↓
port-forward
↓
ingress-nginx-controller
↓
Host: nginx.local
↓
nginx-ingress
↓
nginx-service:80
↓
nginx Pod
```

---

## Useful commands

Create Ingress:

```bash
kubectl apply -f ingress.yaml
```

List Ingress resources:

```bash
kubectl get ingress
```

Describe Ingress:

```bash
kubectl describe ingress nginx-ingress
```

Check Ingress Controller:

```bash
kubectl get pods -n ingress-nginx
```

Port-forward controller:

```bash
kubectl port-forward \
  -n ingress-nginx \
  svc/ingress-nginx-controller \
  8080:80
```

Test routing:

```bash
curl -H "Host: nginx.local" http://127.0.0.1:8080
```

---

## Key takeaways

```text
Ingress defines HTTP/HTTPS routing rules

Ingress Controller executes those rules

Ingress routes traffic to Services

Services route traffic to Pods

Host-based routing uses the HTTP Host header

-H in curl adds an HTTP header

multiple hostnames can use the same Ingress Controller

Ingress is more flexible than exposing every application with NodePort
```

---

## Mental model

```text
Client
↓
Ingress Controller
↓
Ingress rule
↓
Service
↓
Pod
```

For this lab:

```text
nginx.local
↓
nginx-ingress
↓
nginx-service
↓
nginx Pod
```

---

## Interview summary

A Kubernetes Ingress defines HTTP and HTTPS routing rules to Services.

The Ingress resource only stores routing configuration. An Ingress Controller, such as ingress-nginx, is required to actually receive traffic and apply those rules.

Routing can be based on hostname and path.

In this lab, requests containing:

```text
Host: nginx.local
```

were routed through the Ingress Controller to:

```text
nginx-service:80
```

which then forwarded the traffic to one of the nginx Pods.
