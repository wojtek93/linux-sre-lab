# KUB-02 kubectl Basics and Troubleshooting

## Goal

Learn the most important `kubectl` commands used for everyday Kubernetes administration and troubleshooting.

The main commands covered in this lab are:

```text
get
describe
logs
exec
events
```

---

## kubectl get

`kubectl get` is used to quickly list Kubernetes resources.

Examples:

```bash
kubectl get nodes
kubectl get pods
kubectl get services
kubectl get deployments
```

---

## All namespaces

To list Pods from all namespaces:

```bash
kubectl get pods -A
```

`-A` means:

```text
--all-namespaces
```

Equivalent command:

```bash
kubectl get pods --all-namespaces
```

---

## Wide output

More detailed output:

```bash
kubectl get pods -A -o wide
```

This may show additional information such as:

```text
Pod IP
Node
Node IP
```

---

## Namespaces

List namespaces:

```bash
kubectl get namespaces
```

Example namespaces:

```text
default
kube-system
ingress-nginx
local-path-storage
```

---

## Selecting namespace

Use:

```bash
kubectl get pods -n kube-system
```

`-n` means:

```text
namespace
```

It selects one specific namespace for the command.

---

## Current namespace

The default namespace can be configured for the current kubectl context.

Example:

```bash
kubectl config set-context --current --namespace=kube-system
```

Then:

```bash
kubectl get pods
```

will automatically use:

```text
kube-system
```

Check current namespace:

```bash
kubectl config view --minify | grep namespace
```

Return to default:

```bash
kubectl config set-context --current --namespace=default
```

---

## kubectl describe

`kubectl describe` gives detailed information about a specific resource.

Example:

```bash
kubectl describe pod <pod-name>
```

For another namespace:

```bash
kubectl describe pod -n kube-system <pod-name>
```

Important sections include:

```text
Name
Namespace
Node
Status
IP
Containers
Image
Restart Count
Conditions
Events
```

---

## kubectl get vs describe

```text
kubectl get
= quick overview

kubectl describe
= detailed inspection
```

---

## kubectl logs

Show container logs:

```bash
kubectl logs <pod-name>
```

For another namespace:

```bash
kubectl logs -n kube-system <pod-name>
```

Show only the last 20 lines:

```bash
kubectl logs <pod-name> --tail=20
```

Logs are useful for finding application-level problems.

Examples:

```text
startup errors
connection errors
exceptions
configuration problems
application failures
```

---

## Pod and container relationship

A Pod contains one or more containers.

Simple case:

```text
Pod
↓
Container
```

Multi-container Pod:

```text
Pod
├── application container
└── sidecar container
```

---

## List containers inside a Pod

Command:

```bash
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[*].name}'
```

Example:

```text
nginx
```

This means:

```text
Pod
↓
nginx container
```

---

## List Pods and containers together

Useful command:

```bash
kubectl get pods -A -o custom-columns='NAMESPACE:.metadata.namespace,POD:.metadata.name,CONTAINERS:.spec.containers[*].name'
```

Example:

```text
NAMESPACE     POD                         CONTAINERS
default       curl-client                 curl-client
default       net-demo-xxxxx              nginx
kube-system   kube-apiserver-xxxxx        kube-apiserver
kube-system   kube-scheduler-xxxxx        kube-scheduler
```

This provides a clear mapping:

```text
Namespace
↓
Pod
↓
Container
```

---

## kubectl exec

`kubectl exec` runs a command inside a container.

Interactive shell:

```bash
kubectl exec -it <pod-name> -- sh
```

Meaning:

```text
exec
= execute command in container

-i
= interactive stdin

-t
= terminal

--
= command after this is executed inside container

sh
= shell
```

---

## Example exec session

```bash
kubectl exec -it curl-client -- sh
```

Inside the container:

```bash
hostname
ip addr
cat /etc/os-release
```

Exit:

```bash
exit
```

---

## Multiple containers

If a Pod contains multiple containers, specify which one:

```bash
kubectl exec -it <pod-name> -c <container-name> -- sh
```

Example:

```bash
kubectl exec -it app-pod -c sidecar -- sh
```

---

## Kubernetes Events

Events show important actions and failures happening in the cluster.

Command:

```bash
kubectl get events
```

Sorted chronologically:

```bash
kubectl get events --sort-by=.metadata.creationTimestamp
```

Typical events:

```text
Scheduled
Pulled
Created
Started
Failed
BackOff
Killing
```

---

## Troubleshooting workflow

A useful Kubernetes troubleshooting sequence:

```text
Pod problem
↓
kubectl get
↓
kubectl describe
↓
kubectl logs
↓
kubectl exec
↓
kubectl get events
```

---

## Step 1: get

Check basic Pod state:

```bash
kubectl get pods
```

Look at:

```text
READY
STATUS
RESTARTS
AGE
```

Possible problematic states:

```text
Pending
CrashLoopBackOff
ImagePullBackOff
Error
```

---

## Step 2: describe

Inspect details:

```bash
kubectl describe pod <pod-name>
```

Look especially at:

```text
Status
Conditions
Restart Count
Events
```

---

## Step 3: logs

Check application output:

```bash
kubectl logs <pod-name>
```

This helps identify:

```text
application errors
configuration failures
connection problems
startup failures
```

---

## Step 4: exec

Inspect the container internally:

```bash
kubectl exec -it <pod-name> -- sh
```

Possible checks:

```bash
hostname
ip addr
env
cat configuration files
curl another service
```

---

## Step 5: events

Check Kubernetes actions:

```bash
kubectl get events --sort-by=.metadata.creationTimestamp
```

Events can reveal:

```text
image pull failures
scheduling failures
restart loops
container creation problems
volume problems
```

---

## Useful commands

```bash
kubectl get nodes

kubectl get pods

kubectl get pods -A

kubectl get pods -A -o wide

kubectl get namespaces

kubectl get all -n kube-system

kubectl describe pod <pod-name>

kubectl logs <pod-name>

kubectl logs <pod-name> --tail=20

kubectl get pod <pod-name> -o jsonpath='{.spec.containers[*].name}'

kubectl get pods -A -o custom-columns='NAMESPACE:.metadata.namespace,POD:.metadata.name,CONTAINERS:.spec.containers[*].name'

kubectl exec -it <pod-name> -- sh

kubectl exec -it <pod-name> -c <container-name> -- sh

kubectl get events --sort-by=.metadata.creationTimestamp
```

---

## Key takeaways

```text
get
= list resources

describe
= inspect one resource deeply

logs
= inspect application output

exec
= inspect container from inside

events
= inspect Kubernetes lifecycle and failures
```

Relationship:

```text
Node
↓
Pod
↓
Container
```

Troubleshooting:

```text
get
↓
describe
↓
logs
↓
exec
↓
events
```

---

## Interview summary

A common Kubernetes troubleshooting workflow is:

```text
First I use kubectl get to check resource status.

Then I use kubectl describe to inspect conditions and events.

If the Pod is running but the application is failing, I check logs.

If I need to inspect networking, environment variables or files inside
the container, I use kubectl exec.

Finally, I review Kubernetes events to identify scheduling, image,
container or lifecycle problems.
```
