# KUB-01 Kubernetes Architecture

## Goal

Understand the main Kubernetes architecture components and how they cooperate when a Pod is created and run.

Main components covered:

- kube-apiserver
- etcd
- kube-scheduler
- kube-controller-manager
- kubelet
- container runtime

---

## High-level architecture

```text
                Kubernetes Cluster

          ┌──────────────────────────┐
          │      CONTROL PLANE       │
          │                          │
kubectl → │ kube-apiserver           │
          │      ↓                   │
          │     etcd                 │
          │                          │
          │ kube-scheduler           │
          │ kube-controller-manager  │
          └────────────┬─────────────┘
                       │
                       │
          ┌────────────▼─────────────┐
          │          NODE            │
          │                          │
          │ kubelet                  │
          │    ↓                     │
          │ container runtime        │
          │    ↓                     │
          │ Pods / containers        │
          └──────────────────────────┘
```

---

## kube-apiserver

The API Server is the main entry point to the Kubernetes cluster.

Commands such as:

```bash
kubectl get pods
kubectl apply -f deployment.yaml
kubectl delete pod example
```

communicate with the Kubernetes API Server.

Simplified flow:

```text
kubectl
↓
kube-apiserver
↓
Kubernetes cluster
```

The API Server:

- receives API requests
- validates requests
- authenticates and authorizes users
- communicates with other Kubernetes components
- reads and writes cluster state through etcd

In the lab:

```bash
kubectl describe pod -n kube-system kube-apiserver-networking-lab-control-plane
```

showed:

```text
State: Running
Ready: True
Port: 6443/TCP
```

The API Server was using:

```text
--secure-port=6443
```

---

## API Server and etcd

The kube-apiserver configuration showed:

```text
--etcd-servers=https://127.0.0.1:2379
```

This confirms communication between:

```text
kube-apiserver
↓
etcd
```

etcd uses port:

```text
2379
```

for client communication.

---

## etcd

etcd is the distributed key-value database used by Kubernetes.

It stores the cluster state.

Examples of data stored in etcd:

```text
Deployments
Services
ConfigMaps
Secrets
Pod definitions
cluster configuration
desired state
```

Simplified:

```text
etcd = persistent state of Kubernetes
```

In the lab:

```bash
kubectl describe pod -n kube-system etcd-networking-lab-control-plane
```

showed that etcd was:

```text
State: Running
Ready: True
```

---

## kube-scheduler

The Scheduler decides which Node should run a new Pod.

Flow:

```text
new Pod created
↓
Pod has no Node assigned
↓
kube-scheduler evaluates Nodes
↓
Scheduler selects Node
↓
Pod is assigned to that Node
```

The Scheduler can consider:

```text
CPU
memory
node selectors
taints and tolerations
affinity rules
resource requests
```

In the lab:

```bash
kubectl describe pod -n kube-system kube-scheduler-networking-lab-control-plane
```

showed:

```text
State: Running
Ready: True
```

---

## kube-controller-manager

The Controller Manager runs control loops that continuously compare:

```text
desired state
vs
actual state
```

Example:

```text
Deployment wants 3 Pods
↓
only 2 Pods are running
↓
controller detects mismatch
↓
another Pod is created
```

This is the reconciliation mechanism.

Simplified:

```text
desired state
↓
controller loop
↓
actual state corrected
```

In the lab:

```bash
kubectl describe pod -n kube-system kube-controller-manager-networking-lab-control-plane
```

showed:

```text
State: Running
Ready: True
```

---

## kubelet

kubelet is an agent running on every Kubernetes Node.

Its job is to ensure that Pods assigned to that Node are running correctly.

Simplified:

```text
Pod assigned to Node
↓
kubelet sees desired Pod state
↓
kubelet requests container runtime
↓
containers are started
```

In the kind Node:

```bash
docker exec -it networking-lab-control-plane bash
```

the process was verified with:

```bash
ps aux | grep kubelet
```

The system showed:

```text
/usr/bin/kubelet
```

This confirmed that kubelet was running directly on the Node.

---

## Container runtime

The container runtime actually creates and runs containers.

Examples:

```text
containerd
CRI-O
```

In this lab, the runtime was:

```text
containerd
```

It was verified with:

```bash
ps aux | grep containerd
```

The output showed:

```text
/usr/local/bin/containerd
```

and multiple:

```text
containerd-shim-runc-v2
```

processes.

Simplified:

```text
kubelet
↓
containerd
↓
container
```

---

## kubelet vs container runtime

Important distinction:

```text
kubelet
= manages and monitors Pods on the Node

containerd
= actually runs the containers
```

Flow:

```text
Scheduler selects Node
↓
kubelet manages Pod lifecycle
↓
containerd starts containers
```

---

## Control Plane vs Node components

### Control Plane

```text
kube-apiserver
etcd
kube-scheduler
kube-controller-manager
```

### Node

```text
kubelet
container runtime
Pods
```

---

## kind-specific architecture

The lab used Kubernetes in Docker (`kind`).

The Kubernetes Node itself was running as a Docker container:

```bash
docker ps
```

showed:

```text
networking-lab-control-plane
```

Inside this container were Kubernetes Node processes such as:

```text
kubelet
containerd
```

This means kind creates Kubernetes Nodes as Docker containers.

Logical Kubernetes architecture remains the same.

---

## Pod creation flow

When running:

```bash
kubectl apply -f pod.yaml
```

the simplified process is:

```text
kubectl
↓
kube-apiserver
↓
desired state stored in etcd
↓
kube-scheduler selects Node
↓
kubelet on selected Node sees the Pod
↓
kubelet communicates with container runtime
↓
containerd starts container
↓
Pod becomes Running
```

---

## Kubernetes self-healing concept

Kubernetes constantly tries to maintain the desired state.

Example:

```text
desired replicas = 3

actual replicas = 2
```

Controller detects:

```text
actual != desired
```

and performs reconciliation.

Result:

```text
new Pod created
↓
actual replicas = 3
```

---

## Useful commands

List Nodes:

```bash
kubectl get nodes
```

List system Pods:

```bash
kubectl get pods -n kube-system
```

Inspect API Server:

```bash
kubectl describe pod -n kube-system kube-apiserver-networking-lab-control-plane
```

Inspect etcd:

```bash
kubectl describe pod -n kube-system etcd-networking-lab-control-plane
```

Inspect Scheduler:

```bash
kubectl describe pod -n kube-system kube-scheduler-networking-lab-control-plane
```

Inspect Controller Manager:

```bash
kubectl describe pod -n kube-system kube-controller-manager-networking-lab-control-plane
```

List Docker containers used by kind:

```bash
docker ps
```

Enter kind Node:

```bash
docker exec -it networking-lab-control-plane bash
```

Check kubelet:

```bash
ps aux | grep kubelet
```

Check container runtime:

```bash
ps aux | grep containerd
```

---

## Key takeaways

```text
kube-apiserver
= entry point to Kubernetes API

etcd
= stores cluster state

kube-scheduler
= chooses Node for new Pods

kube-controller-manager
= reconciles desired state with actual state

kubelet
= manages Pods on a Node

containerd
= actually runs containers
```

Complete flow:

```text
kubectl
↓
API Server
↓
etcd
↓
Scheduler
↓
Node
↓
kubelet
↓
container runtime
↓
container
```

---

## Interview summary

If asked to explain Kubernetes architecture:

```text
Kubernetes consists of a control plane and worker nodes.

The API Server is the main entry point to the cluster.
Cluster state is stored in etcd.

The Scheduler chooses which Node should run a new Pod.

The Controller Manager continuously reconciles desired state with actual state.

On every Node, kubelet ensures assigned Pods are running.

The kubelet communicates with a container runtime such as containerd,
which actually creates and runs containers.
```
