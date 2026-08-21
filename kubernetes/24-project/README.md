# KUB-24 Final Kubernetes Project

## Goal

Build and validate a small production-style Kubernetes application stack using the main concepts covered in previous labs.

The project combines:

```text
ConfigMap
Secret
Deployment
ReplicaSet
Pods
Service
Ingress
readinessProbe
livenessProbe
resource requests
resource limits
PersistentVolumeClaim
```

The goal was not only to deploy an application, but also to understand how the Kubernetes objects cooperate with each other.

---

# Architecture

The application flow is:

```text
Client
↓
Ingress
↓
Service
↓
Deployment
↓
ReplicaSet
↓
Pods
↓
nginx container
```

Additional configuration:

```text
ConfigMap ───────→ application files

Secret ─────────→ environment variable

PVC ────────────→ persistent /data storage

Probes ─────────→ health checking

Resources ──────→ CPU and memory control
```

---

# Project files

The project contains:

```text
24-project/
├── README.md
├── configmap.yaml
├── secret.yaml
├── pvc.yaml
├── deployment.yaml
├── service.yaml
└── ingress.yaml
```

Each YAML file defines a separate Kubernetes object.

They are applied independently with:

```bash
kubectl apply -f <file>
```

---

# ConfigMap

The application page was stored in a ConfigMap.

Example:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: final-app-config

data:
  index.html: |
    <html>
      <body>
        <h1>Wojtek Kubernetes Final Project</h1>
        <p>Application is running.</p>
      </body>
    </html>
```

The ConfigMap contains:

```text
index.html
```

which is mounted into the nginx container.

---

# ConfigMap flow

```text
ConfigMap
↓
index.html
↓
volume
↓
/usr/share/nginx/html
↓
nginx serves the page
```

The Deployment does not create the ConfigMap.

The ConfigMap is a separate Kubernetes object.

The Deployment only references it.

---

# Secret

A Secret was created for application configuration.

Example:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: final-app-secret
type: Opaque

stringData:
  APP_TOKEN: wojtek-secret-token
```

Using:

```yaml
stringData:
```

allows plain text input without manually encoding the value with base64.

---

# Secret in Deployment

The Deployment references the Secret:

```yaml
env:
  - name: APP_TOKEN
    valueFrom:
      secretKeyRef:
        name: final-app-secret
        key: APP_TOKEN
```

Inside the Pod:

```bash
echo $APP_TOKEN
```

returns the Secret value.

Flow:

```text
Secret
↓
secretKeyRef
↓
environment variable
↓
container
```

---

# PersistentVolumeClaim

Persistent storage was requested using a PVC.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: final-app-pvc

spec:
  accessModes:
    - ReadWriteOnce

  resources:
    requests:
      storage: 1Gi
```

The PVC requested:

```text
1 GiB
```

of persistent storage.

---

# PVC status

The PVC was checked with:

```bash
kubectl get pvc final-app-pvc
```

The final status was:

```text
Bound
```

This means Kubernetes successfully connected the claim to storage.

---

# PVC in Deployment

The PVC is referenced by the Deployment:

```yaml
volumes:
  - name: app-data
    persistentVolumeClaim:
      claimName: final-app-pvc
```

The container mounts it:

```yaml
volumeMounts:
  - name: app-data
    mountPath: /data
```

Flow:

```text
PVC
↓
volume
↓
Pod
↓
/data
```

---

# Persistent storage test

A file was created inside the Pod:

```bash
echo "persistent-data" > /data/test.txt
```

Then verified:

```bash
cat /data/test.txt
```

Result:

```text
persistent-data
```

The Pod was then deleted:

```bash
kubectl delete pod <POD_NAME>
```

Because the Pod belonged to a Deployment, Kubernetes automatically created a replacement Pod.

The file was checked again in the new Pod:

```bash
cat /data/test.txt
```

Result:

```text
persistent-data
```

This proved that:

```text
Pod lifetime
!=
storage lifetime
```

Flow:

```text
old Pod
↓
writes /data/test.txt
↓
PVC stores data
↓
old Pod deleted
↓
Deployment creates new Pod
↓
same PVC mounted
↓
data still exists
```

---

# Deployment

The Deployment manages the application Pods.

Example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: final-app

spec:
  replicas: 2

  selector:
    matchLabels:
      app: final-app

  template:
    metadata:
      labels:
        app: final-app

    spec:
      containers:
        - name: nginx
          image: nginx:latest
```

The Deployment requests:

```text
2 replicas
```

---

# What Deployment actually manages

A Deployment does not create every object in the project.

It mainly manages Pods through a ReplicaSet.

Flow:

```text
Deployment
↓
ReplicaSet
↓
Pods
↓
containers
```

Other objects are separate:

```text
ConfigMap
Secret
PVC
Service
Ingress
```

The Deployment can reference some of them, but they are still independent Kubernetes resources.

---

# Multiple containers

A Pod can contain one or more containers.

Example:

```yaml
containers:
  - name: nginx
  - name: sidecar
```

With:

```yaml
replicas: 2
```

the result would conceptually be:

```text
Pod 1
├── nginx
└── sidecar

Pod 2
├── nginx
└── sidecar
```

In this project each Pod contains one nginx container.

---

# Pod creation order

A Deployment does not guarantee strict sequential Pod startup.

With:

```yaml
replicas: 2
```

Kubernetes may create both Pods in parallel.

Conceptually:

```text
Deployment wants 2 Pods
↓
ReplicaSet creates Pods
↓
Scheduler places them on Nodes
↓
containers start
```

This differs from StatefulSet behavior, where ordered identity and startup can be important.

---

# Resource requests

The container uses resource requests:

```yaml
resources:
  requests:
    cpu: "50m"
    memory: "64Mi"
```

Requests are used by the Kubernetes scheduler when deciding where the Pod can run.

```text
50m CPU
=
0.05 CPU

64Mi
=
64 MiB memory
```

---

# Resource limits

The container also has limits:

```yaml
limits:
  cpu: "200m"
  memory: "128Mi"
```

These define the maximum resources the container should consume.

Simplified:

```text
requests
=
what the Pod asks the scheduler to reserve

limits
=
maximum resource usage allowed
```

---

# Readiness Probe

The readiness probe checks whether the application is ready to receive traffic.

```yaml
readinessProbe:
  httpGet:
    path: /
    port: 80
  periodSeconds: 5
```

Flow:

```text
Pod Running
↓
readiness probe
↓
healthy?
↓
yes
↓
Pod becomes Ready
↓
Service may send traffic
```

If readiness fails:

```text
Pod may still be Running
but
Service should not send traffic to it
```

---

# Liveness Probe

The liveness probe checks whether the application is still healthy.

```yaml
livenessProbe:
  httpGet:
    path: /
    port: 80
  periodSeconds: 10
```

Flow:

```text
container running
↓
liveness probe
↓
fails repeatedly
↓
Kubernetes restarts container
```

---

# Deployment volume configuration

The final Deployment uses two volumes.

ConfigMap volume:

```yaml
- name: html
  configMap:
    name: final-app-config
```

PVC volume:

```yaml
- name: app-data
  persistentVolumeClaim:
    claimName: final-app-pvc
```

The container mounts them as:

```text
/usr/share/nginx/html
/data
```

---

# Service

The Service provides stable network access to the application Pods.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: final-app-service

spec:
  selector:
    app: final-app

  ports:
    - port: 80
      targetPort: 80

  type: ClusterIP
```

---

# How Service finds Pods

The Pods have the label:

```text
app=final-app
```

The Service has the selector:

```yaml
selector:
  app: final-app
```

Therefore:

```text
Pod labels
↓
Service selector
↓
match
↓
Pod becomes Service backend
```

---

# Service endpoints

The Service endpoints were checked with:

```bash
kubectl get endpoints final-app-service
```

The Service had two endpoints because the Deployment had two Ready Pods.

Conceptually:

```text
final-app-service
↓
Pod IP A:80
Pod IP B:80
```

---

# Internal Service test

A test client Pod was created:

```bash
kubectl run final-client \
  --image=curlimages/curl:latest \
  --restart=Never \
  -- sleep 3600
```

The application was tested from inside the cluster:

```bash
kubectl exec -it final-client -- sh
```

Then:

```bash
curl http://final-app-service
```

The request returned:

```html
<h1>Wojtek Kubernetes Final Project</h1>
<p>Application is running.</p>
```

This confirmed:

```text
client
↓
Service DNS
↓
Service
↓
Pod
↓
nginx
```

---

# Ingress

Ingress provides HTTP routing to the Service.

Example:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: final-app-ingress

spec:
  ingressClassName: nginx

  rules:
    - host: final-app.local

      http:
        paths:
          - path: /
            pathType: Prefix

            backend:
              service:
                name: final-app-service
                port:
                  number: 80
```

---

# Ingress flow

```text
HTTP request
↓
Ingress Controller
↓
Ingress rule
↓
final-app-service
↓
Pod
```

The rule:

```yaml
host: final-app.local
```

means requests with:

```text
Host: final-app.local
```

should be routed to:

```text
final-app-service
```

---

# Ingress Controller

Ingress rules are implemented by the nginx Ingress Controller.

Inside the cluster the controller Service can be addressed using Kubernetes DNS.

Pattern:

```text
SERVICE.NAMESPACE.svc.cluster.local
```

Example:

```text
ingress-nginx-controller.ingress-nginx.svc.cluster.local
```

Breakdown:

```text
ingress-nginx-controller
=
Service name

ingress-nginx
=
namespace

svc
=
Kubernetes Service domain

cluster.local
=
cluster DNS domain
```

---

# Testing Ingress

The Ingress was tested from the client Pod using:

```bash
curl \
  -H "Host: final-app.local" \
  http://ingress-nginx-controller.ingress-nginx.svc.cluster.local
```

The request succeeded.

Why the Host header is required:

```text
request reaches Ingress Controller
↓
Ingress Controller reads Host header
↓
Host = final-app.local
↓
matching Ingress rule found
↓
request forwarded to final-app-service
```

---

# Local hostname test

For easier local testing:

```text
final-app.local
```

was mapped in:

```text
/etc/hosts
```

using:

```text
127.0.0.1 final-app.local
```

This makes the Linux machine resolve:

```text
final-app.local
```

to:

```text
127.0.0.1
```

---

# Port-forward testing

The Ingress Controller can be forwarded locally:

```bash
kubectl port-forward \
  -n ingress-nginx \
  service/ingress-nginx-controller \
  8080:80
```

Then:

```bash
curl http://final-app.local:8080
```

Flow:

```text
final-app.local
↓
/etc/hosts
↓
127.0.0.1:8080
↓
kubectl port-forward
↓
Ingress Controller:80
↓
Ingress rule
↓
Service
↓
Pod
```

---

# Kubernetes DNS

Kubernetes Services can be accessed internally using DNS names.

Short form inside the same namespace:

```text
final-app-service
```

Full form:

```text
final-app-service.default.svc.cluster.local
```

General pattern:

```text
SERVICE.NAMESPACE.svc.cluster.local
```

This allows applications to use stable names instead of Pod IP addresses.

---

# Updating Kubernetes objects

Each object can be updated separately.

Example:

```bash
vi secret.yaml
kubectl apply -f secret.yaml
```

or:

```bash
vi service.yaml
kubectl apply -f service.yaml
```

or:

```bash
vi deployment.yaml
kubectl apply -f deployment.yaml
```

---

# Updating Deployment

Changes such as:

```text
replica count
image
resources
probes
environment references
volume configuration
```

are applied with:

```bash
kubectl apply -f deployment.yaml
```

For example:

```yaml
replicas: 2
```

can be changed to:

```yaml
replicas: 4
```

and reapplied.

---

# Deployment rollout

When the Pod template changes, the Deployment performs a rollout.

Example:

```text
image changed
↓
Deployment updated
↓
new ReplicaSet
↓
new Pods created
↓
old Pods removed
```

Useful command:

```bash
kubectl rollout status deployment final-app
```

---

# ConfigMap and Secret updates

ConfigMaps and Secrets are separate objects.

They are updated independently:

```bash
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
```

If a Secret is used as an environment variable, existing containers do not automatically reload that environment variable.

A Deployment restart can be triggered:

```bash
kubectl rollout restart deployment final-app
```

New Pods then read the current Secret values.

---

# YAML validation

Because Kubernetes YAML is indentation-sensitive, manifests can be validated before applying them.

With yamllint:

```bash
yamllint deployment.yaml
```

For Kubernetes-specific validation:

```bash
kubectl apply \
  --dry-run=client \
  -f deployment.yaml
```

This checks the manifest without applying it to the cluster.

Useful workflow:

```text
edit YAML
↓
yamllint
↓
kubectl --dry-run
↓
kubectl apply
```

---

# Final resource verification

The complete stack can be checked with:

```bash
kubectl get deployment final-app
```

```bash
kubectl get pods -l app=final-app
```

```bash
kubectl get svc final-app-service
```

```bash
kubectl get ingress final-app-ingress
```

```bash
kubectl get pvc final-app-pvc
```

```bash
kubectl get configmap final-app-config
```

```bash
kubectl get secret final-app-secret
```

---

# Useful troubleshooting commands

Check Pods:

```bash
kubectl get pods -o wide
```

Describe Pod:

```bash
kubectl describe pod <POD_NAME>
```

Logs:

```bash
kubectl logs <POD_NAME>
```

Check Deployment:

```bash
kubectl describe deployment final-app
```

Check Service:

```bash
kubectl describe service final-app-service
```

Check endpoints:

```bash
kubectl get endpoints final-app-service
```

Check EndpointSlices:

```bash
kubectl get endpointslices \
  -l kubernetes.io/service-name=final-app-service
```

Check Ingress:

```bash
kubectl describe ingress final-app-ingress
```

Check PVC:

```bash
kubectl describe pvc final-app-pvc
```

Check resource usage:

```bash
kubectl top pods
kubectl top nodes
```

---

# Full object relationship

```text
ConfigMap
   │
   └── index.html
          │
          ↓
Secret ─→ Deployment ←─ PVC
          │
          ↓
      ReplicaSet
          │
          ↓
       2 Pods
          │
          ↓
        nginx
          │
          ↓
       Service
          │
          ↓
       Ingress
          │
          ↓
        Client
```

---

# Full request flow

```text
User
↓
final-app.local
↓
Ingress Controller
↓
Ingress rule
↓
final-app-service
↓
Service endpoints
↓
Ready Pod
↓
nginx
↓
index.html from ConfigMap
↓
HTTP response
```

---

# Storage flow

```text
PVC
↓
PersistentVolume
↓
mounted as /data
↓
Pod writes data
↓
Pod deleted
↓
new Pod created
↓
same PVC mounted
↓
data survives
```

---

# Health flow

```text
Pod starts
↓
nginx starts
↓
readinessProbe
↓
Ready
↓
Service can send traffic
```

During runtime:

```text
livenessProbe
↓
application healthy?
↓
yes → continue

no → restart container
```

---

# Scheduling flow

The Deployment creates Pods with resource requests:

```text
CPU: 50m
Memory: 64Mi
```

The scheduler checks Node capacity:

```text
Pod requests
↓
Scheduler
↓
Node capacity
↓
Pod scheduled
```

---

# Key takeaways

```text
A Deployment manages Pods through ReplicaSets

A Deployment does not automatically create Service, Secret, ConfigMap, PVC or Ingress

These are separate Kubernetes objects

Pods can contain one or more containers

Deployment Pods may start in parallel

Services discover Pods using selectors and labels

Ready Pods become Service backends

Ingress provides HTTP routing to Services

ConfigMaps provide non-secret configuration

Secrets provide sensitive configuration

PVCs provide storage independent of Pod lifetime

Readiness controls whether a Pod receives traffic

Liveness checks whether a container should be restarted

Resource requests influence scheduling

Resource limits control maximum resource usage

kubectl apply updates declarative Kubernetes objects

kubectl --dry-run can validate manifests before deployment
```

---

# Final mental model

```text
Desired configuration in YAML
↓
kubectl apply
↓
Kubernetes API
↓
controllers reconcile desired state
↓
Pods and other resources created
↓
application becomes available
```

Kubernetes continuously tries to make:

```text
actual state
```

match:

```text
desired state
```

defined in the manifests.

---

# Interview summary

This project deploys a small nginx-based application using several core Kubernetes resources.

A ConfigMap provides the HTML page, while a Secret provides an application environment variable.

A Deployment manages two nginx Pods through a ReplicaSet. The Pods have CPU and memory requests and limits, as well as readiness and liveness probes.

The Deployment mounts the ConfigMap into the nginx document root and mounts a PersistentVolumeClaim under `/data`.

A ClusterIP Service discovers the Pods through labels and selectors and provides a stable network endpoint.

An Ingress routes HTTP traffic for `final-app.local` to the Service through the nginx Ingress Controller.

Persistent storage was verified by creating a file in `/data`, deleting the Pod, allowing the Deployment to create a replacement Pod, and confirming that the file remained available through the same PVC.

The project demonstrates how independent Kubernetes objects cooperate to provide deployment, networking, configuration, health checking, resource management, and persistent storage for an application.
