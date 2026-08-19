# NET-19 Kubernetes Networking

## Goal

Understand how network traffic flows through Kubernetes from a client to an Ingress, Service and finally to a Pod.

The main traffic path in this lab was:

```text
client
↓
Ingress Controller
↓
Ingress
↓
Service
↓
EndpointSlice
↓
Pod
```

---

## Kubernetes networking components used

During this lab we worked with:

```text
kubectl
kind
Deployment
Pods
Service
ClusterIP
Endpoints / EndpointSlice
Ingress
Ingress Controller
port-forward
```

Each component has a different role in the network path.

---

## Install kubectl

Initially, `kubectl` was not installed.

The Kubernetes CLI was installed and verified with:

```bash
kubectl version --client
```

`kubectl` is the command-line client used to communicate with the Kubernetes API server.

Important:

```text
kubectl = client
Kubernetes cluster = actual Kubernetes environment
```

Installing `kubectl` does not create a cluster.

---

## kubectl without a cluster

After installing `kubectl`:

```bash
kubectl cluster-info
```

returned a connection error.

This happened because there was no active Kubernetes cluster.

Simplified:

```text
kubectl
↓
tries to contact Kubernetes API
↓
no cluster available
↓
connection refused
```

---

## Create Kubernetes cluster with kind

A local Kubernetes cluster was created using `kind`.

`kind` = Kubernetes IN Docker.

Command:

```bash
kind create cluster --name networking-lab
```

This created a Kubernetes control-plane node inside Docker.

---

## Verify Kubernetes cluster

Commands:

```bash
kubectl cluster-info
kubectl get nodes
```

The node appeared as:

```text
Ready
```

This confirmed that:

```text
kubectl
↓
kubeconfig
↓
Kubernetes API server
↓
kind cluster
```

was working correctly.

---

## Create Deployment

A Deployment was created with two nginx replicas.

File:

```text
deployment.yaml
```

Configuration:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: net-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: net-demo
  template:
    metadata:
      labels:
        app: net-demo
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
```

Apply:

```bash
kubectl apply -f deployment.yaml
```

---

## Deployment and Pods

The Deployment was configured with:

```text
replicas: 2
```

This means Kubernetes should maintain two running Pods.

Flow:

```text
Deployment
↓
desired replicas = 2
↓
Pod 1
Pod 2
```

---

## Check Pod IP addresses

Command:

```bash
kubectl get pods -o wide
```

Each Pod received its own IP address.

Example from the lab:

```text
10.244.0.5
10.244.0.6
```

This demonstrates:

```text
each Pod has its own IP
```

---

## Pod IP

A Pod IP identifies a specific Pod.

Example:

```text
10.244.0.5:80
```

means:

```text
Pod IP = 10.244.0.5
application port = 80
```

Important:

```text
Pod IP is not considered stable
```

A Pod may be deleted and recreated with another IP address.

---

## Create Service

A Kubernetes Service was created.

File:

```text
service.yaml
```

Configuration:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: net-demo-service
spec:
  selector:
    app: net-demo
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
```

Apply:

```bash
kubectl apply -f service.yaml
```

---

## What is a Service?

A Service provides a stable network endpoint in front of Pods.

Instead of connecting directly to:

```text
10.244.0.5
10.244.0.6
```

applications can connect to:

```text
net-demo-service
```

The Service then forwards traffic to one of the matching Pods.

---

## ClusterIP

Command:

```bash
kubectl get svc
```

The Service received a ClusterIP.

Example:

```text
10.96.10.100
```

Architecture:

```text
Service
10.96.10.100:80
↓
Pod 1
or
Pod 2
```

A ClusterIP is normally reachable only from inside the Kubernetes cluster.

---

## Service selector

The Service uses:

```yaml
selector:
  app: net-demo
```

The Pods created by the Deployment use the same label:

```yaml
labels:
  app: net-demo
```

Therefore:

```text
Service selector
app=net-demo
↓
find Pods
↓
Pod 1
Pod 2
```

This is how the Service discovers its backend Pods.

---

## Service does not point directly to Deployment

Important:

```text
Service
```

does not directly send traffic to a Deployment.

Instead:

```text
Service
↓
selector
↓
Pods
```

The Deployment manages the Pods, while the Service discovers them using labels.

---

## Check Service endpoints

Command:

```bash
kubectl get endpoints net-demo-service
```

The result showed backend addresses such as:

```text
10.244.0.5:80
10.244.0.6:80
```

This confirmed that the Service correctly discovered both Pods.

---

## EndpointSlice

Modern Kubernetes uses EndpointSlices to track Service backends.

Check:

```bash
kubectl get endpointslices
```

Simplified:

```text
Service
↓
EndpointSlice
↓
Pod IP addresses
```

EndpointSlice contains the current network endpoints associated with a Service.

---

## Create test client Pod

A temporary client Pod was created:

```bash
kubectl run curl-client \
  --image=curlimages/curl:latest \
  --restart=Never \
  -- sleep 3600
```

This allowed us to test networking from inside the Kubernetes cluster.

---

## Enter client Pod

Command:

```bash
kubectl exec -it curl-client -- sh
```

Now network requests were generated from inside a Pod.

In this lab, `curl` acted as the client.

---

## What is a client?

A client is simply something that sends a request.

Examples:

```text
curl
web browser
mobile application
another backend
another Pod
```

In this lab:

```text
curl
↓
sends HTTP request
↓
Kubernetes network
```

---

## Access Service by DNS name

Inside the `curl-client` Pod:

```bash
curl http://net-demo-service
```

The request succeeded.

Flow:

```text
curl-client
↓
net-demo-service
↓
Kubernetes DNS
↓
Service ClusterIP
↓
Pod
```

---

## Kubernetes Service DNS

Kubernetes provides DNS names for Services.

Instead of remembering:

```text
10.96.10.100
```

applications can use:

```text
net-demo-service
```

This is much more useful because Service names are stable.

---

## Access Service by ClusterIP

Inside the client Pod:

```bash
curl http://10.96.10.100
```

The request also succeeded after using the correct ClusterIP.

This confirmed:

```text
DNS Service name
↓
resolves to ClusterIP
↓
Service routes traffic
↓
Pod
```

---

## Service DNS vs ClusterIP

Both can reach the same Service:

```text
net-demo-service
```

and:

```text
10.96.10.100
```

The difference is:

```text
DNS name = easier and more stable to use in applications
ClusterIP = actual virtual IP of the Service
```

---

## Direct Pod connectivity

The client Pod also connected directly to the Pod IP addresses.

Example:

```bash
curl http://10.244.0.5
curl http://10.244.0.6
```

This bypassed the Service.

Flow:

```text
curl-client
↓
Pod IP
↓
nginx
```

---

## Direct Pod vs Service

Direct Pod access:

```text
client
↓
10.244.0.5
↓
specific Pod
```

Through Service:

```text
client
↓
net-demo-service
↓
Service
↓
one of the available Pods
```

Important:

```text
Pod IP = tied to specific Pod
Service = stable entry point
```

---

## Delete a Pod

One of the application Pods was manually deleted.

Command:

```bash
kubectl delete pod <POD_NAME>
```

The Deployment detected that the number of replicas was below the desired state.

Flow:

```text
2 replicas required
↓
one Pod deleted
↓
only 1 Pod remains
↓
Deployment creates replacement
↓
2 Pods again
```

---

## Watch Pod recreation

Command:

```bash
kubectl get pods -w
```

The old Pod terminated and a new Pod was created.

The new Pod received a new IP address.

This confirms that:

```text
Pod IP may change
```

---

## Service survives Pod replacement

After replacing the Pod:

```bash
kubectl get endpoints net-demo-service
```

showed the updated backend addresses.

The Service remained the same.

This is one of the most important reasons for using Services.

```text
old Pod IP disappears
↓
new Pod IP appears
↓
EndpointSlice updates
↓
Service still works
```

---

## Stable Service vs temporary Pods

Important concept:

```text
Pods are temporary
Services are stable
```

Applications should normally connect to a Service instead of hardcoding Pod IP addresses.

---

## Create Ingress

An Ingress resource was created.

File:

```text
ingress.yaml
```

Configuration:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: net-demo-ingress
spec:
  rules:
    - host: net-demo.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: net-demo-service
                port:
                  number: 80
```

Apply:

```bash
kubectl apply -f ingress.yaml
```

---

## What is Ingress?

Ingress defines HTTP/HTTPS routing rules.

In this lab:

```text
Host: net-demo.local
↓
net-demo-service:80
```

The Ingress configuration says:

```text
if request host is net-demo.local
↓
send request to net-demo-service
```

---

## Ingress alone is not enough

After creating the Ingress:

```bash
kubectl get ingress
```

the resource existed, but there was initially no Ingress Controller.

Important distinction:

```text
Ingress
= routing configuration
```

while:

```text
Ingress Controller
= component that actually processes the traffic
```

Without a controller, the Ingress rules are not actively handled.

---

## Install ingress-nginx controller

An nginx Ingress Controller was installed in the cluster.

After installation:

```bash
kubectl get pods -n ingress-nginx
```

showed the controller:

```text
1/1 Running
```

This confirmed that the Ingress Controller was operational.

---

## Ingress Controller

The controller watches Kubernetes Ingress resources and configures itself according to their rules.

Flow:

```text
Ingress resource
↓
Ingress Controller reads rule
↓
configures HTTP routing
```

---

## Complete Ingress architecture

```text
client
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

This is the complete network path investigated during the lab.

---

## Port-forward Ingress Controller

Because this was a local `kind` cluster, access to the Ingress Controller was provided using port-forwarding.

Command:

```bash
kubectl port-forward \
  -n ingress-nginx \
  svc/ingress-nginx-controller \
  8080:80
```

This created:

```text
localhost:8080
↓
Ingress Controller port 80
```

---

## Test Ingress

Command:

```bash
curl -H "Host: net-demo.local" http://127.0.0.1:8080
```

The response returned the nginx welcome page.

This confirmed the complete Kubernetes network path.

---

## Why Host header was required

The Ingress rule was configured for:

```text
net-demo.local
```

Therefore the request had to contain:

```text
Host: net-demo.local
```

The Ingress Controller used this header to choose the correct routing rule.

---

## Host-based routing

Flow:

```text
HTTP request
↓
Host: net-demo.local
↓
Ingress Controller
↓
matching Ingress rule
↓
net-demo-service
```

Ingress can therefore route different hostnames to different Services.

Example:

```text
app.example.com
↓
app-service

api.example.com
↓
api-service
```

---

## Complete traffic flow from the lab

The final request travelled through:

```text
curl
↓
127.0.0.1:8080
↓
kubectl port-forward
↓
Ingress Controller
↓
Host: net-demo.local
↓
Ingress rule
↓
net-demo-service
↓
Service ClusterIP
↓
EndpointSlice
↓
Pod IP
↓
nginx container
↓
HTTP response
```

---

## Main Kubernetes networking roles

### Pod

```text
runs the application
has its own IP
IP may change when recreated
```

### Deployment

```text
manages desired number of Pods
recreates Pods when necessary
```

### Service

```text
stable access point in front of Pods
uses selectors to discover Pods
```

### ClusterIP

```text
virtual internal IP of a Service
```

### EndpointSlice

```text
contains current backend Pod addresses
```

### Ingress

```text
defines HTTP/HTTPS routing rules
```

### Ingress Controller

```text
implements Ingress routing
receives and forwards HTTP requests
```

### Client

```text
sends the request
```

---

## Kubernetes networking troubleshooting workflow

If an application cannot be reached:

```text
client cannot connect
↓
check Ingress
↓
check Ingress Controller
↓
check Service
↓
check EndpointSlice
↓
check Pod
↓
check application
```

---

## Check Pods

```bash
kubectl get pods -o wide
```

Check:

```text
Pod status
Pod IP
node
```

---

## Check Service

```bash
kubectl get svc
```

Check:

```text
Service name
ClusterIP
port
```

---

## Check endpoints

```bash
kubectl get endpoints net-demo-service
```

or:

```bash
kubectl get endpointslices
```

If the Service has no endpoints:

```text
Service exists
↓
but no Pods match selector
```

Possible cause:

```text
wrong labels
wrong selector
Pods not Ready
```

---

## Check Ingress

```bash
kubectl get ingress
```

and:

```bash
kubectl describe ingress net-demo-ingress
```

Check:

```text
host
path
backend Service
backend port
```

---

## Check Ingress Controller

```bash
kubectl get pods -n ingress-nginx
```

Controller should be:

```text
Running
Ready 1/1
```

---

## Test Service internally

From another Pod:

```bash
curl http://net-demo-service
```

If this works:

```text
Pods
Service
internal cluster networking
```

are likely working.

Then investigate the Ingress layer separately.

---

## Important troubleshooting distinction

If direct Pod access works:

```text
curl Pod-IP
```

but Service does not:

```text
curl Service
```

check:

```text
Service selector
EndpointSlice
Service port
targetPort
```

If Service works but Ingress does not:

```text
check Ingress rule
check Host header
check Ingress Controller
```

This allows troubleshooting layer by layer.

---

## Key commands

```bash
kubectl cluster-info

kubectl get nodes

kubectl get pods -A

kubectl apply -f deployment.yaml

kubectl get pods -o wide

kubectl apply -f service.yaml

kubectl get svc

kubectl get endpoints net-demo-service

kubectl get endpointslices

kubectl run curl-client \
  --image=curlimages/curl:latest \
  --restart=Never \
  -- sleep 3600

kubectl exec -it curl-client -- sh

curl http://net-demo-service

kubectl delete pod <POD_NAME>

kubectl get pods -w

kubectl apply -f ingress.yaml

kubectl get ingress

kubectl describe ingress net-demo-ingress

kubectl get pods -n ingress-nginx

kubectl port-forward \
  -n ingress-nginx \
  svc/ingress-nginx-controller \
  8080:80

curl -H "Host: net-demo.local" http://127.0.0.1:8080
```

---

## Key takeaways

```text
every Pod receives its own IP address
Pod IP addresses may change

Deployment maintains the desired number of Pods

Service provides stable access to Pods
Service discovers Pods through labels and selectors

ClusterIP is the internal virtual IP of a Service

EndpointSlice stores current backend Pod addresses

Kubernetes DNS allows applications to use Service names instead of IP addresses

Ingress defines HTTP/HTTPS routing rules

Ingress Controller actually processes Ingress traffic

Ingress without an Ingress Controller is only configuration

Host header can be used for Ingress host-based routing

client sends the request

complete traffic flow:
client
↓
Ingress
↓
Service
↓
Pod
```

Short interview answer:

```text
In Kubernetes, Pods have their own IP addresses, but Pod IPs are not stable.

A Service provides a stable network endpoint and uses selectors to discover
the current Pods. EndpointSlices contain the actual backend Pod addresses.

For external HTTP routing, an Ingress defines routing rules and an Ingress
Controller implements those rules.

The typical traffic path is client to Ingress Controller, then Service,
and finally one of the backend Pods.
```
