# KUB-05 Rollout

## Goal

Understand how Kubernetes Deployment rollouts work, how application updates create new revisions and ReplicaSets, how to monitor rollout progress, inspect rollout history and perform rollback.

---

## Starting point

The lab uses an existing Deployment:

```text
nginx-deployment
```

with Pods selected by:

```text
app=nginx-deploy
```

Check Deployment:

```bash
kubectl get deployment nginx-deployment
```

Check Pods:

```bash
kubectl get pods -l app=nginx-deploy
```

---

## Check current container image

The current image can be inspected with:

```bash
kubectl get deployment nginx-deployment \
  -o jsonpath='{.spec.template.spec.containers[*].image}'
```

Example:

```text
nginx:latest
```

---

## Change container image

A new image can be set directly from the CLI:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.26
```

Command structure:

```text
deployment/nginx-deployment
↓
target Deployment

nginx=
↓
container name

nginx:1.26
↓
new image
```

Changing the Pod template causes a new rollout.

---

## What happens during image update

Simplified flow:

```text
Deployment Pod template changes
↓
new revision created
↓
new ReplicaSet created
↓
new Pods start
↓
new Pods become Ready
↓
old Pods are gradually removed
```

This is a RollingUpdate.

---

## RollingUpdate

RollingUpdate means Kubernetes updates an application gradually.

Instead of:

```text
delete all old Pods
↓
start all new Pods
```

Kubernetes performs:

```text
start some new Pods
↓
wait until they are available
↓
remove old Pods
↓
continue until update is complete
```

This helps reduce downtime during application updates.

---

## Watch rollout status

Command:

```bash
kubectl rollout status deployment/nginx-deployment
```

This waits until the Deployment rollout completes.

Example:

```text
deployment "nginx-deployment" successfully rolled out
```

---

## Watch Pods during rollout

Pods can be watched live:

```bash
kubectl get pods -l app=nginx-deploy -w
```

`-w` means:

```text
watch
```

During a rollout, it is possible to observe:

```text
old Pods running
↓
new Pods created
↓
new Pods become Ready
↓
old Pods terminate
```

Stop watch with:

```text
Ctrl+C
```

---

## Rollout history

Check Deployment revisions:

```bash
kubectl rollout history deployment/nginx-deployment
```

Example:

```text
REVISION
1
4
5
```

Each revision represents a recorded Deployment Pod template version.

---

## Inspect specific revision

Command:

```bash
kubectl rollout history deployment/nginx-deployment --revision=5
```

Important syntax:

```text
--revision=5
```

Not:

```text
--revision= 5
```

There must be no space after `=`.

---

## Revision numbers

Revision numbers do not simply move backward during rollback.

Example:

```text
revision 1
↓
update
↓
revision 2
↓
update
↓
revision 3
↓
rollback
↓
another revision is created
```

Rollback restores an older configuration, but Kubernetes records the operation as another revision.

This is why rollout history may contain non-obvious revision numbers after multiple updates and rollbacks.

---

## Rollback

Rollback to the previous Deployment revision:

```bash
kubectl rollout undo deployment/nginx-deployment
```

Then monitor:

```bash
kubectl rollout status deployment/nginx-deployment
```

---

## Verify image after rollback

Check the active image:

```bash
kubectl get deployment nginx-deployment \
  -o jsonpath='{.spec.template.spec.containers[*].image}'
```

This confirms which image is currently configured in the Deployment Pod template.

---

## Rollback flow

```text
new application version
↓
new revision
↓
rollout starts
↓
problem detected
↓
kubectl rollout undo
↓
older configuration restored
↓
new rollout completes
```

---

## Deployment and ReplicaSets

Check ReplicaSets:

```bash
kubectl get rs
```

Or only ReplicaSets matching the Deployment Pods:

```bash
kubectl get rs -l app=nginx-deploy
```

A Deployment can have multiple ReplicaSets after several rollouts.

Simplified:

```text
Deployment
│
├── old ReplicaSet
│   └── 0 active Pods
│
├── older ReplicaSet
│   └── 0 active Pods
│
└── current ReplicaSet
    └── active Pods
```

---

## Why old ReplicaSets remain

Kubernetes keeps previous ReplicaSets so previous Pod templates can be referenced during rollback.

The current ReplicaSet normally has active replicas.

Older ReplicaSets usually remain with:

```text
0 replicas
```

unless currently used during a rollout or rollback.

---

## Rollout and ReplicaSet relationship

Changing the Deployment Pod template:

```text
Deployment
↓
template changed
↓
new ReplicaSet
↓
new Pods
```

Rollback:

```text
Deployment
↓
older Pod template selected
↓
ReplicaSets adjusted
↓
Pods updated
```

---

## Deployment describe

Detailed rollout information can be inspected with:

```bash
kubectl describe deployment nginx-deployment
```

Important sections include:

```text
Replicas
StrategyType
RollingUpdateStrategy
OldReplicaSets
NewReplicaSet
Conditions
Events
```

---

## kubectl apply warning

During the lab, a warning appeared after using commands such as:

```bash
kubectl rollout undo deployment/nginx-deployment
```

The warning indicated that the Deployment had previously been managed using:

```bash
kubectl apply
```

This happened because the lab mixed declarative management:

```bash
kubectl apply -f deployment.yaml
```

with imperative commands:

```bash
kubectl set image
kubectl rollout undo
```

The warning did not mean that the rollback failed.

For production workflows, the source-of-truth configuration should normally remain consistent with the actual cluster state.

---

## Declarative vs imperative update

Declarative:

```bash
vi deployment.yaml
kubectl apply -f deployment.yaml
```

Imperative:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.26
```

The imperative command is useful for learning, testing and quick operational changes.

The declarative approach is easier to track in Git.

---

## Troubleshooting a rollout

Useful sequence:

```text
update started
↓
kubectl rollout status
↓
kubectl get pods
↓
kubectl describe deployment
↓
kubectl describe pod
↓
kubectl logs
↓
rollback if necessary
```

Commands:

```bash
kubectl rollout status deployment/nginx-deployment

kubectl get pods -l app=nginx-deploy

kubectl describe deployment nginx-deployment

kubectl get rs -l app=nginx-deploy

kubectl rollout history deployment/nginx-deployment
```

---

## Useful commands

Check Deployment:

```bash
kubectl get deployment nginx-deployment
```

Check Pods:

```bash
kubectl get pods -l app=nginx-deploy
```

Check current image:

```bash
kubectl get deployment nginx-deployment \
  -o jsonpath='{.spec.template.spec.containers[*].image}'
```

Update image:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.26
```

Check rollout:

```bash
kubectl rollout status deployment/nginx-deployment
```

Watch Pods:

```bash
kubectl get pods -l app=nginx-deploy -w
```

Check history:

```bash
kubectl rollout history deployment/nginx-deployment
```

Check revision:

```bash
kubectl rollout history deployment/nginx-deployment --revision=5
```

Rollback:

```bash
kubectl rollout undo deployment/nginx-deployment
```

Check ReplicaSets:

```bash
kubectl get rs -l app=nginx-deploy
```

Inspect Deployment:

```bash
kubectl describe deployment nginx-deployment
```

---

## Key takeaways

```text
Deployment supports rolling application updates

changing the Pod template creates a new rollout

new rollout creates a new revision

new Pod template normally creates a new ReplicaSet

RollingUpdate gradually replaces old Pods with new Pods

kubectl rollout status monitors rollout progress

kubectl rollout history shows revisions

kubectl rollout undo performs rollback

rollback restores an older configuration but is recorded as another revision

old ReplicaSets are retained to support rollout history and rollback

kubectl get rs helps understand Deployment rollout behavior
```

---

## Mental model

```text
Deployment
↓
revision
↓
ReplicaSet
↓
Pods
```

Update:

```text
old revision
↓
set new image
↓
new revision
↓
new ReplicaSet
↓
RollingUpdate
↓
new Pods replace old Pods
```

Rollback:

```text
problem
↓
rollout undo
↓
older configuration restored
↓
new rollout
↓
application returns to previous version
```

---

## Interview summary

A Kubernetes Deployment performs application updates using rolling updates.

When the Pod template changes, for example after changing the container image, Kubernetes creates a new Deployment revision and normally a new ReplicaSet.

The rollout can be monitored using `kubectl rollout status`, and previous versions can be inspected with `kubectl rollout history`.

If a deployment causes a problem, `kubectl rollout undo` can restore the previous configuration.

Older ReplicaSets are retained with zero replicas so Kubernetes can maintain rollout history and support rollback.
