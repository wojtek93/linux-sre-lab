# KUB-14 Storage — PVC and Persistent Data

## Goal

Understand how Kubernetes persistent storage works using:

```text
PersistentVolumeClaim
PersistentVolume
volumeMount
persistentVolumeClaim
```

The main objective of this lab was to prove that:

```text
Pod can be deleted
↓
new Pod can be created
↓
data can remain
```

---

## Why persistent storage is needed

Containers and Pods are temporary.

A Pod can be:

```text
deleted
recreated
rescheduled
replaced
```

If application data is stored only inside the container filesystem, it can disappear together with the Pod.

Persistent storage solves this problem.

---

## Basic storage model

```text
Pod
↓
PVC
↓
PV
↓
physical storage
```

Meaning:

```text
Pod
= uses storage

PVC
= requests storage

PV
= actual storage resource

physical storage
= where data is really stored
```

---

## PersistentVolumeClaim

The lab started with a PVC.

Example:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc

spec:
  accessModes:
    - ReadWriteOnce

  resources:
    requests:
      storage: 1Gi
```

---

## What is PVC?

PVC means:

```text
PersistentVolumeClaim
```

It can be understood as:

```text
"give my application persistent storage"
```

In this lab:

```text
requested storage = 1Gi
```

---

## accessModes

The PVC used:

```yaml
accessModes:
  - ReadWriteOnce
```

`ReadWriteOnce` means the volume can be mounted read-write by a single Node at a time.

Short form:

```text
RWO
```

---

## Storage request

```yaml
resources:
  requests:
    storage: 1Gi
```

Meaning:

```text
PVC requests 1 GiB of storage
```

---

## Create PVC

```bash
kubectl apply -f pvc.yaml
```

Check:

```bash
kubectl get pvc
```

Initially the PVC showed:

```text
STATUS: Pending
```

---

## Why PVC was Pending

The PVC did not immediately become `Bound`.

`kubectl describe pvc app-pvc` showed an event similar to:

```text
waiting for first consumer to be created before binding
```

The StorageClass used:

```text
WaitForFirstConsumer
```

behavior.

Meaning:

```text
PVC created
↓
Kubernetes waits
↓
Pod starts using PVC
↓
storage is provisioned / selected
↓
PVC becomes Bound
```

---

## Pod using PVC

The Pod manifest:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: storage-demo

spec:
  containers:
    - name: demo
      image: busybox:latest
      command: ["sh", "-c", "sleep 3600"]

      volumeMounts:
        - name: app-storage
          mountPath: /data

  volumes:
    - name: app-storage
      persistentVolumeClaim:
        claimName: app-pvc
```

---

## volumes

Important section:

```yaml
volumes:
  - name: app-storage
    persistentVolumeClaim:
      claimName: app-pvc
```

Meaning:

```text
create volume called app-storage
↓
source of volume = PVC app-pvc
```

---

## volumeMounts

```yaml
volumeMounts:
  - name: app-storage
    mountPath: /data
```

Meaning:

```text
take app-storage volume
↓
mount it inside container
↓
at /data
```

So application data written to:

```text
/data
```

is stored on the persistent volume.

---

## Create Pod

```bash
kubectl apply -f pod.yaml
```

Check:

```bash
kubectl get pod storage-demo
```

The Pod reached:

```text
Running
```

---

## PVC becomes Bound

After the Pod started using the PVC:

```bash
kubectl get pvc
```

showed:

```text
app-pvc   Bound
```

This means Kubernetes successfully attached the PVC to a PersistentVolume.

---

## Pending to Bound flow

```text
PVC created
↓
Pending
↓
Pod references PVC
↓
storage provisioned
↓
PV created / selected
↓
PVC linked to PV
↓
Bound
```

---

## Check PersistentVolume

PVC:

```bash
kubectl get pvc
```

PV:

```bash
kubectl get pv
```

The relationship is:

```text
PVC
↓
Bound to
↓
PV
```

---

## PVC vs PV

PVC:

```text
request for storage
```

PV:

```text
actual storage resource
```

Mental model:

```text
PVC
= "I need storage"

PV
= "here is the storage"
```

---

## Write data

The Pod mounted the volume at:

```text
/data
```

Inside the Pod:

```bash
kubectl exec -it storage-demo -- sh
```

Data was written:

```bash
echo "persistent-data-test" > /data/test.txt
```

Verified with:

```bash
cat /data/test.txt
```

Result:

```text
persistent-data-test
```

---

## Persistence test

The Pod was deleted:

```bash
kubectl delete pod storage-demo
```

Then recreated:

```bash
kubectl apply -f pod.yaml
```

The new Pod mounted the same PVC again.

Inside the recreated Pod:

```bash
cat /data/test.txt
```

The file still existed.

This proved:

```text
Pod deleted
↓
Pod filesystem disappears
↓
PVC/PV remain
↓
new Pod mounts same volume
↓
data remains
```

---

## Why data survives Pod deletion

The data is not stored only inside the Pod.

Instead:

```text
Pod
↓
mounts /data
↓
PVC
↓
PV
↓
persistent storage
```

Deleting the Pod removes:

```text
Pod
container
temporary container filesystem
```

but does not automatically remove:

```text
PVC
PV
persistent data
```

---

## Where are the data physically stored?

In this lab the cluster runs using kind.

The StorageClass uses local storage provided for the kind cluster.

Simplified:

```text
Pod
↓
/data
↓
PVC
↓
PV
↓
storage associated with Kubernetes Node
```

The Kubernetes Node in this lab is:

```text
networking-lab-control-plane
```

which itself runs as a Docker container because the cluster was created using kind.

---

## Lab-specific storage model

```text
storage-demo Pod
↓
/data
↓
app-pvc
↓
PersistentVolume
↓
local storage used by kind Node
```

---

## Production storage

In production the physical storage may be completely different.

Examples include:

```text
AWS EBS
Azure Disk
Google Persistent Disk
NFS
SAN
Ceph
other CSI storage systems
```

The application still uses the same basic Kubernetes model:

```text
Pod
↓
PVC
↓
PV
↓
storage backend
```

---

## StorageClass

The PVC used the default StorageClass:

```text
standard
```

StorageClass defines how storage should be dynamically provisioned.

Check:

```bash
kubectl get storageclass
```

or:

```bash
kubectl get sc
```

---

## Dynamic provisioning

In this lab, Kubernetes did not require us to manually create a PV first.

Instead:

```text
PVC created
↓
StorageClass sees request
↓
Pod becomes first consumer
↓
storage dynamically provisioned
↓
PV created
↓
PVC Bound
```

This is called:

```text
dynamic provisioning
```

---

## Useful commands

Create PVC:

```bash
kubectl apply -f pvc.yaml
```

Check PVC:

```bash
kubectl get pvc
```

Describe PVC:

```bash
kubectl describe pvc app-pvc
```

Create Pod:

```bash
kubectl apply -f pod.yaml
```

Check Pod:

```bash
kubectl get pod storage-demo
```

Check PV:

```bash
kubectl get pv
```

Check StorageClass:

```bash
kubectl get storageclass
```

Enter Pod:

```bash
kubectl exec -it storage-demo -- sh
```

Write data:

```bash
echo "persistent-data-test" > /data/test.txt
```

Read data:

```bash
cat /data/test.txt
```

Delete Pod:

```bash
kubectl delete pod storage-demo
```

Recreate Pod:

```bash
kubectl apply -f pod.yaml
```

---

## Troubleshooting PVC

If PVC stays:

```text
Pending
```

check:

```bash
kubectl describe pvc <pvc-name>
```

Look at:

```text
Status
StorageClass
Events
Used By
Volume
```

Possible reasons include:

```text
waiting for first consumer
no matching PV
StorageClass problem
provisioner problem
capacity problem
```

---

## Key takeaways

```text
Pods are temporary

persistent data should not depend on Pod lifecycle

PVC requests persistent storage

PV represents actual persistent storage

Pod mounts PVC through volumes

volumeMount defines where storage appears inside container

PVC can remain after Pod deletion

data can survive Pod recreation

Pending means PVC is not yet attached to usable storage

Bound means PVC is connected to a PV

StorageClass can dynamically provision storage
```

---

## Mental model

```text
Pod
↓
volumeMount
↓
volume
↓
PVC
↓
PV
↓
physical storage
```

For this lab:

```text
storage-demo
↓
/data
↓
app-pvc
↓
PV
↓
kind local storage
```

---

## Interview summary

A PersistentVolumeClaim is a request for persistent storage.

A Pod references the PVC through a volume and mounts it inside the container using a volumeMount.

The PVC is bound to a PersistentVolume, which represents the actual storage.

Because the data lives on the persistent volume rather than only in the Pod filesystem, deleting and recreating the Pod does not remove the stored data.
