# KUB-07 NodePort

## Goal

Understand how a Kubernetes NodePort Service exposes an application through a port opened on a Kubernetes Node.

The main objective is to understand the relationship between:

```text
nodePort
port
targetPort
```

and how traffic flows from a client to a Pod.

---

## Starting point

An existing Deployment runs nginx Pods with the label:

```text
app=nginx-deploy
```

The Pods listen on:

```text
TCP port 80
```

---

## Why NodePort

A ClusterIP Service is primarily used for communication inside the Kubernetes cluster.

Example:

```text
Pod
↓
ClusterIP Service
↓
Pod
```

A NodePort Service additionally exposes the Service through a port on the Kubernetes Node.

Simplified:

```text
Client
↓
Node IP
↓
NodePort
↓
Service
↓
Pod
```

---

## NodePort manifest

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport

spec:
  selector:
    app: nginx-deploy

  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080

  type: NodePort
```

---

## apiVersion

```yaml
apiVersion: v1
```

Service is a core Kubernetes resource and uses:

```text
v1
```

---

## kind

```yaml
kind: Service
```

This defines a Kubernetes Service.

---

## metadata.name

```yaml
metadata:
  name: nginx-nodeport
```

The Service name is:

```text
nginx-nodeport
```

---

## Selector

```yaml
selector:
  app: nginx-deploy
```

The Service selects Pods using labels.

It finds Pods with:

```text
app=nginx-deploy
```

The Service does not select Pods by Pod name.

---

## Service type

```yaml
type: NodePort
```

This makes Kubernetes expose the Service through a port on the Node.

---

## port

```yaml
port: 80
```

This is the port exposed by the Service inside the cluster.

Example:

```text
Service :80
```

---

## targetPort

```yaml
targetPort: 80
```

This is the destination port on the backend Pod.

Example:

```text
Pod nginx :80
```

---

## nodePort

```yaml
nodePort: 30080
```

This is the port exposed on the Kubernetes Node.

A client can reach the application using:

```text
NODE_IP:30080
```

---

## port vs targetPort vs nodePort

The most important relationship:

```text
nodePort
= port exposed on Node

port
= port exposed by Service

targetPort
= destination port on Pod
```

For this lab:

```text
nodePort:   30080
port:          80
targetPort:    80
```

---

## Full traffic flow

```text
Client
↓
Node IP :30080
↓
NodePort
↓
Service port :80
↓
targetPort :80
↓
nginx Pod :80
```

---

## Create NodePort Service

```bash
kubectl apply -f nodeport.yaml
```

---

## Check Service

```bash
kubectl get svc nginx-nodeport
```

The output showed a port mapping similar to:

```text
80:30080/TCP
```

Meaning:

```text
Service port 80
↓
NodePort 30080
```

---

## Describe Service

```bash
kubectl describe svc nginx-nodeport
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
NodePort
Endpoints
```

---

## Check Node

```bash
kubectl get nodes -o wide
```

In the lab, the Node was:

```text
networking-lab-control-plane
```

with internal IP:

```text
172.22.0.2
```

---

## kind environment

The Kubernetes cluster used in this lab was created using kind.

In kind:

```text
Kubernetes Node
=
Docker container
```

The control-plane Node was:

```text
networking-lab-control-plane
```

The Node itself could be entered with:

```bash
docker exec -it networking-lab-control-plane bash
```

---

## Test NodePort from Node

Inside the kind Node:

```bash
curl http://127.0.0.1:30080
```

The request returned the nginx page.

This confirmed that NodePort was listening on the Node.

---

## Test using Node IP

The Node IP was:

```text
172.22.0.2
```

The application was also tested with:

```bash
curl http://172.22.0.2:30080
```

This also returned the nginx page.

---

## Verified traffic path

The successful test confirmed:

```text
172.22.0.2:30080
↓
NodePort
↓
nginx-nodeport Service
↓
Service port 80
↓
targetPort 80
↓
nginx Pod
```

---

## localhost NodePort test

The following also worked from inside the Node:

```bash
curl http://127.0.0.1:30080
```

This means the NodePort was reachable through the Node's local networking stack.

---

## ClusterIP vs NodePort

### ClusterIP

```text
Client inside cluster
↓
Service ClusterIP
↓
Pod
```

Example:

```bash
curl http://nginx-service
```

ClusterIP is mainly for internal cluster communication.

---

### NodePort

```text
Client
↓
Node IP :NodePort
↓
Service
↓
Pod
```

Example:

```bash
curl http://172.22.0.2:30080
```

NodePort exposes an additional entry point through the Node.

---

## Service still uses selectors

Even with NodePort, backend discovery still works the same way as with ClusterIP.

```text
NodePort Service
↓
selector
↓
EndpointSlice
↓
matching Pods
```

The selector remains:

```text
app=nginx-deploy
```

---

## Backend Pods

The Service can have one or multiple backend Pods.

Example:

```text
NodePort
↓
Service
↓
Pod A
Pod B
Pod C
```

If one Pod disappears and the Deployment creates a new one, the Service can automatically use the new backend through EndpointSlice updates.

---

## NodePort does not replace ClusterIP

A NodePort Service still receives a ClusterIP.

NodePort adds another way to reach the same Service.

Conceptually:

```text
Service
├── ClusterIP
└── NodePort
```

Clients inside the cluster can still use the Service name or ClusterIP.

Clients able to reach the Node can use:

```text
NodeIP:NodePort
```

---

## Common mental model

```text
nodePort
↓
outside-facing port on Node

port
↓
Service port

targetPort
↓
application port inside Pod
```

For this lab:

```text
30080
↓
80
↓
80
```

---

## Useful commands

Create Service:

```bash
kubectl apply -f nodeport.yaml
```

Check Service:

```bash
kubectl get svc nginx-nodeport
```

Describe Service:

```bash
kubectl describe svc nginx-nodeport
```

Check Nodes:

```bash
kubectl get nodes -o wide
```

Enter kind Node:

```bash
docker exec -it networking-lab-control-plane bash
```

Test NodePort locally on Node:

```bash
curl http://127.0.0.1:30080
```

Test using Node IP:

```bash
curl http://172.22.0.2:30080
```

---

## Key takeaways

```text
NodePort exposes a Service through a port on the Node

nodePort is the port opened on the Node

port is the Service port

targetPort is the backend Pod port

Service still discovers Pods using labels

NodePort still uses the normal Kubernetes Service backend mechanism

NodePort adds an external-style entry point to a Service

ClusterIP remains available even when Service type is NodePort
```

---

## Interview summary

A NodePort Service exposes a Kubernetes Service on a static port on each Node.

Traffic sent to:

```text
NodeIP:NodePort
```

is forwarded through the Service to one of the matching backend Pods.

The `nodePort` is the port exposed on the Node, `port` is the Service port, and `targetPort` is the destination port on the Pod.

A NodePort Service still uses selectors and EndpointSlices to identify its backend Pods.
