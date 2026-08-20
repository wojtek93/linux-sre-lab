# KUB-16 RBAC

## Goal

Understand how Kubernetes RBAC controls permissions using:

```text
ServiceAccount
Role
RoleBinding
```

The lab demonstrates the principle:

```text
who?
↓
can do what?
↓
on which Kubernetes resources?
```

---

## What is RBAC?

RBAC means:

```text
Role-Based Access Control
```

It is used to control permissions inside Kubernetes.

Example:

```text
one identity
↓
can list Pods
↓
but cannot delete Pods
```

---

## Basic mental model

```text
ServiceAccount
= WHO

Role
= WHAT is allowed

RoleBinding
= CONNECT WHO with permissions
```

For this lab:

```text
pod-reader
↓
pod-reader-role
↓
get/list Pods
```

---

## RBAC manifest

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-reader

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader-role
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
subjects:
  - kind: ServiceAccount
    name: pod-reader

roleRef:
  kind: Role
  name: pod-reader-role
  apiGroup: rbac.authorization.k8s.io
```

---

# ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-reader
```

The ServiceAccount represents an identity inside Kubernetes.

In this lab:

```text
ServiceAccount = pod-reader
```

Simplified:

```text
pod-reader
= Kubernetes identity
```

---

## Why ServiceAccount?

Pods and applications often need to communicate with the Kubernetes API.

Instead of giving every application unrestricted permissions, Kubernetes can assign a ServiceAccount with limited permissions.

Example:

```text
application
↓
ServiceAccount
↓
RBAC permissions
↓
Kubernetes API
```

---

# Role

```yaml
kind: Role
metadata:
  name: pod-reader-role
```

A Role defines permissions.

The lab Role contained:

```yaml
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]
```

Meaning:

```text
resource:
Pods

allowed operations:
get
list
```

---

## resources

```yaml
resources:
  - pods
```

This means the permissions apply to:

```text
Pods
```

---

## verbs

```yaml
verbs:
  - get
  - list
```

These are Kubernetes API operations.

Examples:

```text
get
list
create
update
patch
delete
watch
```

Our ServiceAccount only received:

```text
get
list
```

It did not receive:

```text
delete
create
```

---

## get vs list

`get` means:

```text
read one specific resource
```

Example conceptually:

```bash
kubectl get pod nginx-pod
```

`list` means:

```text
read a collection of resources
```

Example:

```bash
kubectl get pods
```

---

# RoleBinding

```yaml
kind: RoleBinding
metadata:
  name: pod-reader-binding
```

RoleBinding connects a subject to a Role.

Mental model:

```text
ServiceAccount
+
Role
↓
RoleBinding
```

---

## subjects

```yaml
subjects:
  - kind: ServiceAccount
    name: pod-reader
```

This specifies:

```text
WHO receives permissions?
```

Answer:

```text
ServiceAccount pod-reader
```

---

## roleRef

```yaml
roleRef:
  kind: Role
  name: pod-reader-role
  apiGroup: rbac.authorization.k8s.io
```

This specifies:

```text
WHICH Role should be assigned?
```

Answer:

```text
pod-reader-role
```

---

## Full RBAC relationship

```text
ServiceAccount:
pod-reader

↓ RoleBinding

Role:
pod-reader-role

↓ permissions

pods:
get
list
```

---

# Apply RBAC

```bash
kubectl apply -f rbac.yaml
```

The command created:

```text
ServiceAccount
Role
RoleBinding
```

---

## Check ServiceAccount

```bash
kubectl get serviceaccount pod-reader
```

---

## Check Role

```bash
kubectl get role pod-reader-role
```

---

## Check RoleBinding

```bash
kubectl get rolebinding pod-reader-binding
```

---

# Testing permissions

Kubernetes provides:

```bash
kubectl auth can-i
```

This checks whether a particular identity is allowed to perform an action.

---

## Test list Pods

```bash
kubectl auth can-i list pods \
  --as=system:serviceaccount:default:pod-reader
```

Result:

```text
yes
```

Meaning:

```text
pod-reader
↓
is allowed to
↓
list Pods
```

---

## Test delete Pods

```bash
kubectl auth can-i delete pods \
  --as=system:serviceaccount:default:pod-reader
```

Result:

```text
no
```

Meaning:

```text
pod-reader
↓
is NOT allowed to
↓
delete Pods
```

---

## Identity format

The identity used in the test was:

```text
system:serviceaccount:default:pod-reader
```

Breakdown:

```text
system:serviceaccount
↓
ServiceAccount identity

default
↓
namespace

pod-reader
↓
ServiceAccount name
```

So:

```text
system:serviceaccount:default:pod-reader
```

means:

```text
ServiceAccount pod-reader
in namespace default
```

---

# Verified behavior

The lab confirmed:

```text
list pods
→ yes

delete pods
→ no
```

This proves that Kubernetes RBAC enforces only the permissions explicitly granted by the Role.

---

# Principle of least privilege

A major security principle is:

```text
give only the permissions that are actually required
```

Example:

If an application only needs to read Pods:

```text
get
list
```

there is no reason to give:

```text
delete
create
update
```

This reduces security risk.

---

## Bad example

Giving unnecessary permissions:

```text
pods:
*
```

or broad administrative rights when the application only needs read access.

---

## Better approach

```text
application needs:
read Pods

give:
get
list

do not give:
delete
create
update
```

This is the principle of least privilege.

---

# Role vs ClusterRole

This lab used:

```text
Role
```

A Role is namespace-scoped.

Conceptually:

```text
Role
↓
permissions inside one namespace
```

Kubernetes also has:

```text
ClusterRole
```

which can define permissions across the cluster or for cluster-scoped resources.

Simplified:

```text
Role
= namespace-level permissions

ClusterRole
= cluster-wide or reusable permissions
```

---

# RoleBinding vs ClusterRoleBinding

Similarly:

```text
RoleBinding
= binds permissions within a namespace

ClusterRoleBinding
= grants permissions across the cluster
```

This lab intentionally used the smaller namespace-scoped model:

```text
ServiceAccount
↓
RoleBinding
↓
Role
```

---

# Troubleshooting RBAC

If an application receives:

```text
Forbidden
```

or:

```text
permission denied
```

check:

```bash
kubectl auth can-i <verb> <resource> \
  --as=<identity>
```

Example:

```bash
kubectl auth can-i list pods \
  --as=system:serviceaccount:default:pod-reader
```

Then inspect:

```bash
kubectl get serviceaccount
kubectl get role
kubectl get rolebinding
```

And describe them if needed:

```bash
kubectl describe serviceaccount pod-reader
kubectl describe role pod-reader-role
kubectl describe rolebinding pod-reader-binding
```

---

# Useful commands

Apply RBAC:

```bash
kubectl apply -f rbac.yaml
```

List ServiceAccounts:

```bash
kubectl get serviceaccounts
```

Check ServiceAccount:

```bash
kubectl get serviceaccount pod-reader
```

List Roles:

```bash
kubectl get roles
```

Check Role:

```bash
kubectl get role pod-reader-role
```

List RoleBindings:

```bash
kubectl get rolebindings
```

Check RoleBinding:

```bash
kubectl get rolebinding pod-reader-binding
```

Test read permissions:

```bash
kubectl auth can-i list pods \
  --as=system:serviceaccount:default:pod-reader
```

Test delete permissions:

```bash
kubectl auth can-i delete pods \
  --as=system:serviceaccount:default:pod-reader
```

---

# Key takeaways

```text
RBAC controls Kubernetes permissions

ServiceAccount represents an identity

Role defines allowed actions

RoleBinding connects identity with Role

resources define what Kubernetes objects permissions apply to

verbs define what operations are allowed

get/list provide read access

delete was not allowed in this lab

kubectl auth can-i is useful for testing permissions

Role is namespace-scoped

RBAC should follow the principle of least privilege
```

---

# Mental model

```text
WHO?
↓
ServiceAccount

WHAT CAN THEY DO?
↓
Role

CONNECT THEM
↓
RoleBinding
```

For this lab:

```text
pod-reader
↓
RoleBinding
↓
pod-reader-role
↓
pods
↓
get + list
```

Result:

```text
read Pods → YES
delete Pods → NO
```

---

# Interview summary

Kubernetes RBAC controls access to Kubernetes API resources.

A ServiceAccount represents an identity, a Role defines permissions, and a RoleBinding assigns those permissions to the identity.

In this lab, the `pod-reader` ServiceAccount was granted `get` and `list` permissions for Pods.

Using `kubectl auth can-i`, we verified that the ServiceAccount could list Pods but could not delete them.

This demonstrates the principle of least privilege: grant only the permissions required by the workload.
