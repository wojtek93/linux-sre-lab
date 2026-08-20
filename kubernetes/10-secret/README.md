# KUB-10 Secret

## Goal

Understand how Kubernetes Secrets store sensitive configuration separately from container images and how Pods can consume Secret values as environment variables.

---

## Secret vs ConfigMap

ConfigMap is intended for normal configuration:

```text
environment
feature flags
application settings
URLs
```

Secret is intended for sensitive data:

```text
passwords
API tokens
credentials
keys
```

---

## Secret manifest

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret

type: Opaque

data:
  DB_USER: YWRtaW4=
  DB_PASSWORD: c2VjcmV0MTIz
```

---

## apiVersion

```yaml
apiVersion: v1
```

Secret is a core Kubernetes resource.

---

## kind

```yaml
kind: Secret
```

This creates a Secret object.

---

## metadata.name

```yaml
metadata:
  name: app-secret
```

The Secret is named:

```text
app-secret
```

Pods can reference this name.

---

## type: Opaque

```yaml
type: Opaque
```

`Opaque` is the generic Secret type used for arbitrary key-value data.

---

## Base64 encoding

Values under:

```yaml
data:
```

must be Base64 encoded.

Example:

```bash
echo -n "admin" | base64
```

Result:

```text
YWRtaW4=
```

Example:

```bash
echo -n "secret123" | base64
```

Result:

```text
c2VjcmV0MTIz
```

---

## Base64 is not encryption

Important:

```text
Base64
≠
encryption
```

Base64 is only an encoding format.

Anyone with access to the encoded value can decode it.

Example:

```bash
echo "YWRtaW4=" | base64 -d
```

Result:

```text
admin
```

---

## Create Secret

```bash
kubectl apply -f secret.yaml
```

---

## Check Secret

```bash
kubectl get secret app-secret
```

---

## Describe Secret

```bash
kubectl describe secret app-secret
```

The output does not display the secret values directly.

Instead, it shows information such as:

```text
DB_PASSWORD: 9 bytes
DB_USER: 5 bytes
```

This avoids accidentally printing Secret values during normal inspection.

---

## Pod using Secret

Example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-demo

spec:
  containers:
    - name: demo
      image: busybox:latest
      command: ["sh", "-c", "sleep 3600"]

      envFrom:
        - secretRef:
            name: app-secret
```

---

## secretRef

The important part is:

```yaml
envFrom:
  - secretRef:
      name: app-secret
```

Meaning:

```text
take values from Secret app-secret
↓
inject them into the container
↓
as environment variables
```

---

## Create Pod

```bash
kubectl apply -f pod.yaml
```

Check:

```bash
kubectl get pod secret-demo
```

The Pod should reach:

```text
Running
```

---

## Verify Secret inside container

Enter the Pod:

```bash
kubectl exec -it secret-demo -- sh
```

Check:

```bash
echo $DB_USER
echo $DB_PASSWORD
```

Result:

```text
admin
secret123
```

---

## Full flow

```text
plain value
↓
Base64 encoding
↓
Secret stored in Kubernetes
↓
Pod references Secret
↓
secretRef
↓
environment variables
↓
application reads value
```

For this lab:

```text
admin
↓
YWRtaW4=
↓
app-secret
↓
secret-demo
↓
DB_USER
↓
admin
```

---

## ConfigMap vs Secret

ConfigMap:

```text
normal configuration
```

Secret:

```text
sensitive configuration
```

Both can be consumed by Pods in similar ways.

Example:

```text
ConfigMap
↓
configMapRef

Secret
↓
secretRef
```

---

## Environment variables

Secret values can be injected as environment variables.

Example:

```text
Secret
↓
DB_USER
DB_PASSWORD
↓
container environment
```

The application can then read:

```bash
echo $DB_USER
echo $DB_PASSWORD
```

---

## Important security point

A Kubernetes Secret should not be treated as automatically encrypted just because its values appear in Base64.

```text
Base64
= encoding

encryption
= cryptographic protection
```

Access to Secrets should be controlled using Kubernetes mechanisms such as RBAC and appropriate cluster security configuration.

---

## Useful commands

Encode value:

```bash
echo -n "admin" | base64
```

Decode value:

```bash
echo "YWRtaW4=" | base64 -d
```

Create Secret:

```bash
kubectl apply -f secret.yaml
```

List Secrets:

```bash
kubectl get secrets
```

Inspect Secret metadata:

```bash
kubectl describe secret app-secret
```

Create Pod:

```bash
kubectl apply -f pod.yaml
```

Check Pod:

```bash
kubectl get pod secret-demo
```

Enter Pod:

```bash
kubectl exec -it secret-demo -- sh
```

Check injected values:

```bash
echo $DB_USER
echo $DB_PASSWORD
```

---

## Key takeaways

```text
Secret stores sensitive configuration

Secret exists independently from Pods

Pods can reference Secrets using secretRef

Secret values can become environment variables

data values are Base64 encoded

Base64 is not encryption

kubectl describe secret does not print values directly

access to Secrets should be tightly controlled
```

---

## Mental model

```text
Secret
↓
secretRef
↓
Pod
↓
container
↓
environment variable
↓
application
```

---

## Interview summary

A Kubernetes Secret is used to store sensitive configuration such as passwords, tokens and credentials separately from container images.

Secret values stored under `data` are Base64 encoded, which is not the same as encryption.

Pods can consume Secret values as environment variables using `secretRef`.

Access to Secrets should be protected using Kubernetes authorization mechanisms such as RBAC.
