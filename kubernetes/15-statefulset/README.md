# KUB-15 StatefulSet

## Goal

Understand how Kubernetes StatefulSets differ from Deployments and how StatefulSets provide:

```text
stable Pod identity
ordered Pod creation
stable persistent storage per Pod
```

The lab demonstrated that a StatefulSet Pod can be deleted and recreated with the same name and the same persistent storage.

---

## Deployment vs StatefulSet

Deployment:

```text
Pods are interchangeable
Pod names are generated
individual Pod identity is not important
```

Example:

```text
nginx-deployment-7f9479bffd-xxxxx
nginx-deployment-7f9479bffd-yyyyy
```

StatefulSet:

```text
Pods have stable identities
Pod names are predictable
each Pod can have its own persistent storage
```

Example:

```text
web-0
web-1
web-2
```

---

## Basic StatefulSet manifest

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web

spec:
  serviceName: "web"
  replicas: 3

  selector:
    matchLabels:
      app: web

  template:
    metadata:
      labels:
        app: web

    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
```

---

## Create StatefulSet

```bash
kubectl apply -f statefulset.yaml
```

Check:

```bash
kubectl get statefulsets
```

Short form:

```bash
kubectl get sts
```

Check Pods:

```bash
kubectl get pods -l app=web
```

---

## Stable Pod names

The StatefulSet created:

```text
web-0
web-1
web-2
```

Unlike Deployment Pods, these names are deterministic.

Mental model:

```text
StatefulSet web
↓
web-0
web-1
web-2
```

---

## Stable identity test

One Pod was deleted:

```bash
kubectl delete pod web-1
```

The StatefulSet recreated the Pod.

The replacement Pod was again named:

```text
web-1
```

It did not receive a random new name.

Flow:

```text
web-1
↓
deleted
↓
StatefulSet detects missing replica
↓
creates replacement
↓
web-1
```

This demonstrates stable Pod identity.

---

## Ordered Pod creation

The StatefulSet was deleted and recreated:

```bash
kubectl delete statefulset web
kubectl apply -f statefulset.yaml
```

Pods were observed with:

```bash
kubectl get pods -l app=web -w
```

The StatefulSet created Pods in order:

```text
web-0
↓
web-1
↓
web-2
```

By default, StatefulSet uses ordered Pod management.

This is useful for applications where instance order matters.

---

## Why StatefulSets are useful

Some applications need stable instance identity.

Examples include:

```text
databases
distributed systems
cluster members
stateful applications
```

In those systems:

```text
instance 0
instance 1
instance 2
```

may have different roles or data.

---

# Persistent storage per Pod

A major StatefulSet feature is the ability to create a separate PVC for every Pod.

This is configured using:

```text
volumeClaimTemplates
```

---

## StatefulSet with persistent storage

Final manifest:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web

spec:
  serviceName: "web"
  replicas: 3

  selector:
    matchLabels:
      app: web

  template:
    metadata:
      labels:
        app: web

    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80

          volumeMounts:
            - name: web-data
              mountPath: /usr/share/nginx/html

  volumeClaimTemplates:
    - metadata:
        name: web-data
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 1Gi
```

---

## volumeMounts

```yaml
volumeMounts:
  - name: web-data
    mountPath: /usr/share/nginx/html
```

Meaning:

```text
mount storage called web-data
↓
inside nginx container
↓
at /usr/share/nginx/html
```

---

## volumeClaimTemplates

```yaml
volumeClaimTemplates:
  - metadata:
      name: web-data
```

This tells StatefulSet:

```text
create a separate PVC
for every Pod
```

---

## Automatic PVC creation

With three replicas:

```text
web-0
web-1
web-2
```

Kubernetes created:

```text
web-data-web-0
web-data-web-1
web-data-web-2
```

So the relationship is:

```text
web-0
↓
web-data-web-0

web-1
↓
web-data-web-1

web-2
↓
web-data-web-2
```

---

## Verify PVCs

```bash
kubectl get pvc
```

The lab showed:

```text
web-data-web-0   Bound
web-data-web-1   Bound
web-data-web-2   Bound
```

Each Pod therefore had its own persistent storage.

---

## Persistent storage model

```text
StatefulSet
↓
Pod identity
↓
PVC identity
↓
PersistentVolume
```

Example:

```text
web-1
↓
web-data-web-1
↓
PV
↓
persistent data
```

---

# Persistence test

The lab tested whether data belonging to `web-1` survives Pod deletion.

Enter `web-1`:

```bash
kubectl exec -it web-1 -- sh
```

Write data:

```bash
echo "data-from-web-1" > /usr/share/nginx/html/test.txt
```

Verify:

```bash
cat /usr/share/nginx/html/test.txt
```

Result:

```text
data-from-web-1
```

---

## Delete web-1

```bash
kubectl delete pod web-1
```

The StatefulSet recreated:

```text
web-1
```

Wait for it:

```bash
kubectl get pods -l app=web -w
```

---

## Verify data after Pod recreation

Enter the recreated Pod:

```bash
kubectl exec -it web-1 -- sh
```

Check:

```bash
cat /usr/share/nginx/html/test.txt
```

The result was still:

```text
data-from-web-1
```

---

## Why the data survived

The data was not stored only in the temporary container filesystem.

Instead:

```text
web-1
↓
/usr/share/nginx/html
↓
web-data-web-1
↓
PersistentVolume
```

When `web-1` was deleted:

```text
Pod disappeared
↓
PVC remained
↓
PersistentVolume remained
↓
data remained
```

When StatefulSet recreated `web-1`:

```text
new web-1
↓
same PVC web-data-web-1
↓
same persistent data
```

---

## Stable identity + stable storage

This is the key StatefulSet concept:

```text
stable Pod identity
+
stable storage identity
```

For example:

```text
web-0
always uses
web-data-web-0
```

```text
web-1
always uses
web-data-web-1
```

```text
web-2
always uses
web-data-web-2
```

---

## StatefulSet vs Deployment storage

Deployment conceptually treats replicas as interchangeable:

```text
Pod A
Pod B
Pod C
```

StatefulSet treats replicas as individual members:

```text
web-0
web-1
web-2
```

Each member can have its own storage:

```text
web-0 → storage-0
web-1 → storage-1
web-2 → storage-2
```

---

## Pod deletion behavior

Deployment:

```text
delete Pod
↓
replacement Pod created
↓
new generated Pod name
```

StatefulSet:

```text
delete web-1
↓
replacement created
↓
name remains web-1
```

---

## Persistent data behavior

Without persistent storage:

```text
Pod deleted
↓
container filesystem disappears
↓
data may disappear
```

With StatefulSet PVC:

```text
Pod deleted
↓
PVC remains
↓
new Pod attaches same PVC
↓
data remains
```

---

## serviceName

The StatefulSet contained:

```yaml
serviceName: "web"
```

StatefulSets commonly work together with a headless Service to provide stable network identities to Pods.

Conceptually:

```text
web-0
web-1
web-2
```

can have stable DNS identities when used with the corresponding Service.

This lab focused primarily on stable Pod identity and storage.

---

## Useful commands

Create StatefulSet:

```bash
kubectl apply -f statefulset.yaml
```

List StatefulSets:

```bash
kubectl get statefulsets
```

Short form:

```bash
kubectl get sts
```

List StatefulSet Pods:

```bash
kubectl get pods -l app=web
```

Watch Pods:

```bash
kubectl get pods -l app=web -w
```

Delete Pod:

```bash
kubectl delete pod web-1
```

Delete StatefulSet:

```bash
kubectl delete statefulset web
```

Check PVCs:

```bash
kubectl get pvc
```

Enter Pod:

```bash
kubectl exec -it web-1 -- sh
```

Write persistent data:

```bash
echo "data-from-web-1" > /usr/share/nginx/html/test.txt
```

Read persistent data:

```bash
cat /usr/share/nginx/html/test.txt
```

---

## Troubleshooting StatefulSet

Useful flow:

```text
StatefulSet problem
↓
kubectl get sts
↓
kubectl get pods
↓
kubectl describe sts
↓
kubectl describe pod
↓
kubectl get pvc
↓
kubectl describe pvc
```

Useful commands:

```bash
kubectl describe statefulset web
kubectl get pods -l app=web
kubectl get pvc
```

---

## Key takeaways

```text
StatefulSet manages stateful workloads

StatefulSet Pods have predictable names

Pod identity remains stable after recreation

Pods are normally created in ordered sequence

volumeClaimTemplates can create one PVC per Pod

each Pod can have its own persistent storage

PVC survives Pod deletion

recreated Pod reconnects to its own PVC

StatefulSet is useful when application instances are not interchangeable
```

---

## Mental model

```text
StatefulSet
↓
stable Pod
↓
stable PVC
↓
stable data
```

Example:

```text
web-1
↓
web-data-web-1
↓
persistent data
```

Delete Pod:

```text
web-1 deleted
↓
PVC remains
↓
web-1 recreated
↓
same PVC attached
↓
same data available
```

---

## Interview summary

A Kubernetes StatefulSet is used for workloads that require stable identity and persistent storage.

Unlike Deployment Pods, StatefulSet Pods have predictable names such as `web-0`, `web-1` and `web-2`.

Using `volumeClaimTemplates`, StatefulSet can automatically create a dedicated PVC for every Pod.

When a StatefulSet Pod is deleted, Kubernetes recreates it with the same identity and reconnects it to the same PVC, allowing its persistent data to survive Pod recreation.
