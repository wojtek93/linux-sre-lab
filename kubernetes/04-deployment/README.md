# KUB-04 Deployment

## Goal

Understand how Kubernetes Deployments manage Pods through ReplicaSets, maintain the desired number of replicas, recreate deleted Pods and allow scaling.

---

## Deployment hierarchy

```text
Deployment
↓
ReplicaSet
↓
Pods
↓
Containers
```

A Deployment manages ReplicaSets.

A ReplicaSet ensures that the expected number of Pods exists.

---

## Deployment manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment

spec:
  replicas: 3

  selector:
    matchLabels:
      app: nginx-deploy

  template:
    metadata:
      labels:
        app: nginx-deploy

    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
```

---

## apiVersion

```yaml
apiVersion: apps/v1
```

Deployment uses:

```text
apps/v1
```

---

## kind

```yaml
kind: Deployment
```

This tells Kubernetes that the resource is a Deployment.

---

## metadata

```yaml
metadata:
  name: nginx-deployment
```

This defines the Deployment name.

---

## spec

The `spec` section describes the desired state.

Example:

```yaml
spec:
  replicas: 3
```

Meaning:

```text
desired number of Pods = 3
```

---

## replicas

```yaml
replicas: 3
```

Kubernetes continuously tries to maintain three running Pods.

Example:

```text
desired = 3
actual = 2
↓
Kubernetes creates another Pod
↓
actual = 3
```

---

## selector

```yaml
selector:
  matchLabels:
    app: nginx-deploy
```

The selector defines which Pods belong to the Deployment.

Meaning:

```text
manage Pods with:

app=nginx-deploy
```

---

## template

```yaml
template:
```

The template defines how new Pods should be created.

Inside the template is a Pod specification.

---

## Pod labels

```yaml
template:
  metadata:
    labels:
      app: nginx-deploy
```

Every Pod created by the Deployment receives:

```text
app=nginx-deploy
```

---

## Selector and labels must match

Important relationship:

```text
Deployment selector
app=nginx-deploy
        │
        │ must match
        ↓
Pod template label
app=nginx-deploy
```

The Deployment uses the selector to identify the Pods it manages.

---

## Container specification

```yaml
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

Meaning:

```text
container name = nginx
image = nginx:latest
container port = 80
```

---

## Create Deployment

```bash
kubectl apply -f deployment.yaml
```

or when using the test manifest:

```bash
kubectl apply -f deployment.test.yaml
```

---

## Dry run

Before creating the resource, YAML can be validated with:

```bash
kubectl apply --dry-run=client -f deployment.test.yaml
```

This checks whether kubectl can parse and validate the manifest without creating the resource.

---

## Check Deployment

```bash
kubectl get deployments
```

Example information:

```text
READY
UP-TO-DATE
AVAILABLE
AGE
```

---

## Check ReplicaSet

```bash
kubectl get replicasets
```

or shorter:

```bash
kubectl get rs
```

This shows the ReplicaSet created by the Deployment.

---

## Check Pods using labels

```bash
kubectl get pods -l app=nginx-deploy
```

`-l` means:

```text
label selector
```

The command shows only Pods with:

```text
app=nginx-deploy
```

---

## Show labels

```bash
kubectl get pods --show-labels
```

Another option:

```bash
kubectl get pods -L app
```

This adds the `app` label as a column.

---

## Self-healing test

First list the Pods:

```bash
kubectl get pods -l app=nginx-deploy
```

Delete one Pod:

```bash
kubectl delete pod <pod-name>
```

Then watch the Pods:

```bash
kubectl get pods -l app=nginx-deploy -w
```

`-w` means:

```text
watch
```

It continuously watches changes.

---

## What happens after deleting a Pod

The Deployment expects:

```text
replicas = 3
```

After deleting one Pod:

```text
actual replicas = 2
```

The ReplicaSet detects the difference:

```text
desired = 3
actual = 2
↓
missing replica detected
↓
new Pod created
↓
actual = 3
```

This demonstrates Kubernetes reconciliation and self-healing.

---

## Standalone Pod vs Deployment Pod

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
ReplicaSet
↓
Pod
↓
delete Pod
↓
new Pod automatically created
```

---

## Scaling

Deployment replicas can be changed from the CLI.

Scale to five Pods:

```bash
kubectl scale deployment nginx-deployment --replicas=5
```

Check:

```bash
kubectl get deployment nginx-deployment
kubectl get pods -l app=nginx-deploy
```

Scale down:

```bash
kubectl scale deployment nginx-deployment --replicas=2
```

---

## Scaling behavior

Scale up:

```text
desired = 5
actual = 3
↓
create 2 Pods
↓
actual = 5
```

Scale down:

```text
desired = 2
actual = 5
↓
remove 3 Pods
↓
actual = 2
```

---

## Declarative scaling

Instead of using `kubectl scale`, change:

```yaml
replicas: 3
```

in the YAML file.

Then:

```bash
kubectl apply -f deployment.yaml
```

---

## Imperative vs declarative changes

```text
kubectl scale
= quick imperative change

edit YAML + kubectl apply
= declarative configuration change
```

For configuration stored in Git, the declarative approach is usually easier to track and reproduce.

---

## Describe Deployment

```bash
kubectl describe deployment nginx-deployment
```

Important sections:

```text
Replicas
Selector
StrategyType
Pod Template
Conditions
Events
```

---

## Replicas

`describe` shows information about:

```text
desired replicas
updated replicas
available replicas
unavailable replicas
```

---

## Selector

The Deployment selector identifies managed Pods.

Example:

```text
Selector: app=nginx-deploy
```

---

## Pod Template

The Pod Template shows the configuration used for new Pods.

It includes:

```text
labels
containers
images
ports
```

---

## Deployment strategy

The default Deployment strategy is typically:

```text
RollingUpdate
```

This allows Kubernetes to replace Pods gradually during an application update.

This will be explored in KUB-05 Rollout.

---

## Reconciliation

One of the core Kubernetes concepts is reconciliation.

Kubernetes continuously compares:

```text
desired state
vs
actual state
```

Example:

```text
desired replicas = 3
actual replicas = 2
↓
reconciliation
↓
new Pod created
↓
actual replicas = 3
```

---

## Useful commands

```bash
kubectl apply -f deployment.yaml

kubectl apply --dry-run=client -f deployment.yaml

kubectl get deployments

kubectl get deployment nginx-deployment

kubectl get replicasets

kubectl get rs

kubectl get pods

kubectl get pods -l app=nginx-deploy

kubectl get pods --show-labels

kubectl get pods -L app

kubectl describe deployment nginx-deployment

kubectl delete pod <pod-name>

kubectl get pods -l app=nginx-deploy -w

kubectl scale deployment nginx-deployment --replicas=5

kubectl scale deployment nginx-deployment --replicas=2
```

---

## Key takeaways

```text
Deployment manages ReplicaSets

ReplicaSet maintains the required number of Pods

replicas defines the desired number of Pods

selector identifies managed Pods

template defines how new Pods are created

selector must match Pod template labels

-l filters resources using labels

-w watches changes

deleted Deployment-managed Pods are recreated

Deployment can be scaled up and down

Kubernetes continuously reconciles desired and actual state
```

---

## Interview summary

A Kubernetes Deployment manages application Pods through ReplicaSets.

The Deployment defines the desired state, including the number of replicas and the Pod template.

The selector identifies which Pods belong to the Deployment and must match the labels in the Pod template.

If one of the Pods is deleted, the ReplicaSet detects that the actual number of replicas is lower than the desired number and creates a replacement Pod.

Deployments also support scaling and rolling updates.
