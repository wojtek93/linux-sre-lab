# KUB-20 ImagePullBackOff

## Goal

Understand how to diagnose and fix a Pod stuck in:

```text
ErrImagePull
ImagePullBackOff
```

The lab demonstrated:

```text
wrong container image tag
image pull failure
kubectl describe
Pod Events
ErrImagePull
ImagePullBackOff
fixing image configuration
```

---

## What is ImagePullBackOff?

`ImagePullBackOff` means Kubernetes cannot successfully pull the container image required by the Pod.

Typical flow:

```text
Pod created
↓
kubelet tries to pull image
↓
image pull fails
↓
ErrImagePull
↓
Kubernetes waits before retrying
↓
ImagePullBackOff
```

The `BackOff` part means Kubernetes increases the delay between repeated pull attempts.

---

## Broken Pod

The lab intentionally used an invalid nginx image tag:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: image-demo

spec:
  containers:
    - name: demo
      image: nginx:this-tag-does-not-exist
```

The image name contained:

```text
nginx:this-tag-does-not-exist
```

This tag did not exist in the container registry.

---

## Create broken Pod

```bash
kubectl apply -f broken-image.yaml
```

Then:

```bash
kubectl get pod image-demo
```

The Pod could not start normally.

---

## Watch Pod state

```bash
kubectl get pod image-demo -w
```

The status changed through states similar to:

```text
ContainerCreating
↓
ErrImagePull
↓
ImagePullBackOff
```

---

# ErrImagePull

`ErrImagePull` means Kubernetes attempted to download the image and the attempt failed.

In this lab:

```text
nginx:this-tag-does-not-exist
```

could not be found in the registry.

---

# ImagePullBackOff

After repeated failures, Kubernetes entered:

```text
ImagePullBackOff
```

Meaning:

```text
image pull failed
↓
Kubernetes will retry
↓
but waits before the next attempt
```

This avoids continuously hammering the container registry with immediate retries.

---

# Troubleshooting

The main diagnostic command was:

```bash
kubectl describe pod image-demo
```

The most important section was:

```text
Events
```

---

## Events

The Pod Events showed messages related to:

```text
Pulling
Failed
ErrImagePull
BackOff
```

The output indicated that Kubernetes failed to pull:

```text
nginx:this-tag-does-not-exist
```

and reported that the image reference could not be resolved.

---

## Troubleshooting flow

When seeing:

```text
ImagePullBackOff
```

use:

```text
kubectl get pods
↓
kubectl describe pod
↓
check Events
↓
inspect image name
↓
inspect image tag
↓
check registry/authentication if needed
```

---

# Common causes

Typical causes of ImagePullBackOff include:

```text
wrong image name
wrong image tag
image does not exist
private registry authentication failure
missing imagePullSecret
registry unavailable
network problem
registry rate limit
```

In this lab the root cause was:

```text
invalid image tag
```

---

# Fix

The broken image:

```yaml
image: nginx:this-tag-does-not-exist
```

was replaced with:

```yaml
image: nginx:latest
```

---

## Recreate Pod

The standalone Pod was deleted:

```bash
kubectl delete pod image-demo
```

Then recreated:

```bash
kubectl apply -f broken-image.yaml
```

Check:

```bash
kubectl get pod image-demo
```

Final result:

```text
image-demo   1/1   Running
```

---

# Full failure flow

```text
Pod created
↓
image = nginx:this-tag-does-not-exist
↓
kubelet tries registry
↓
image/tag not found
↓
ErrImagePull
↓
retry
↓
ImagePullBackOff
```

---

# Full fix flow

```text
wrong image tag
↓
correct image tag
↓
delete broken Pod
↓
create Pod again
↓
image successfully pulled
↓
container starts
↓
Running
```

---

# ImagePullBackOff vs CrashLoopBackOff

This is an important distinction.

## ImagePullBackOff

```text
Kubernetes cannot pull image
↓
container never successfully starts
```

Typical causes:

```text
wrong image
wrong tag
registry authentication
registry/network problems
```

---

## CrashLoopBackOff

```text
image was successfully pulled
↓
container starts
↓
application/process crashes
↓
Kubernetes restarts container
```

Typical causes:

```text
bad command
application error
bad configuration
missing environment variable
failed dependency
```

---

## Short comparison

```text
ImagePullBackOff
= cannot obtain the container image

CrashLoopBackOff
= container starts but keeps crashing
```

---

# Useful commands

Create Pod:

```bash
kubectl apply -f broken-image.yaml
```

Check Pod:

```bash
kubectl get pod image-demo
```

Watch Pod:

```bash
kubectl get pod image-demo -w
```

Describe Pod:

```bash
kubectl describe pod image-demo
```

Delete Pod:

```bash
kubectl delete pod image-demo
```

Recreate Pod:

```bash
kubectl apply -f broken-image.yaml
```

---

# Incident checklist

When seeing:

```text
ImagePullBackOff
```

check:

```text
1. kubectl describe pod

2. Events

3. exact image name

4. exact image tag

5. registry address

6. registry authentication

7. imagePullSecrets

8. network access to registry
```

---

# Key takeaways

```text
ErrImagePull means an image pull attempt failed

ImagePullBackOff means Kubernetes is backing off before retrying

the container may never start if its image cannot be pulled

kubectl describe pod is the main troubleshooting command

Pod Events usually show the exact image pull error

wrong image tags are a common cause

fixing the image reference allows the Pod to start normally

ImagePullBackOff is different from CrashLoopBackOff
```

---

# Mental model

```text
Pod
↓
needs image
↓
kubelet
↓
container registry
```

Failure:

```text
registry cannot provide image
↓
ErrImagePull
↓
ImagePullBackOff
```

Success:

```text
registry provides image
↓
container created
↓
Running
```

---

# Interview summary

`ImagePullBackOff` indicates that Kubernetes cannot successfully pull the container image required by a Pod.

The correct troubleshooting approach is to inspect the Pod with `kubectl describe pod` and review the Events section for image pull errors.

Common causes include an incorrect image name or tag, authentication problems with a private registry, missing image pull credentials, or registry connectivity issues.

In this lab, the Pod referenced a nonexistent nginx tag. After changing the image to `nginx:latest` and recreating the Pod, the image was pulled successfully and the Pod entered the Running state.
