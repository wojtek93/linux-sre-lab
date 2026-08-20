# KUB-09 ConfigMap

## Goal

Understand how Kubernetes ConfigMaps store application configuration outside container images and how that configuration can be injected into Pods.

The lab covered two common methods:

```text
ConfigMap
├── environment variables
└── mounted files
```

---

## Why ConfigMap

Application configuration should not always be hardcoded inside a container image.

Example configuration:

```text
APP_ENV=production
APP_COLOR=blue
```

Instead, Kubernetes can store it separately in a ConfigMap.

---

## ConfigMap as environment variables

Example:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config

data:
  APP_ENV: production
  APP_COLOR: blue
```

Apply:

```bash
kubectl apply -f configmap.yaml
```

Check:

```bash
kubectl get configmap
kubectl describe configmap app-config
```

---

## Inject ConfigMap into Pod

Example Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo

spec:
  containers:
    - name: demo
      image: busybox:latest
      command: ["sh", "-c", "sleep 3600"]

      envFrom:
        - configMapRef:
            name: app-config
```

Important section:

```yaml
envFrom:
  - configMapRef:
      name: app-config
```

Meaning:

```text
take values from ConfigMap app-config
↓
inject them as environment variables
↓
inside the container
```

---

## Verify environment variables

Enter Pod:

```bash
kubectl exec -it configmap-demo -- sh
```

Check:

```bash
echo $APP_ENV
echo $APP_COLOR
```

Result:

```text
production
blue
```

---

## ConfigMap as files

ConfigMap can also contain file-like configuration.

Example:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config

data:
  app.conf: |
    mode=production
    color=blue
```

The `|` means:

```text
everything below is one multiline text value
```

So:

```text
key:
app.conf

value:
mode=production
color=blue
```

---

## What happens after ConfigMap apply

After:

```bash
kubectl apply -f configmap-file.yaml
```

Kubernetes stores the ConfigMap as an object in the cluster.

At this moment:

```text
ConfigMap exists
↓
but no file exists inside a Pod yet
```

The ConfigMap simply stores configuration data.

---

## Mount ConfigMap as volume

Pod example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-file-demo

spec:
  containers:
    - name: demo
      image: busybox:latest
      command: ["sh", "-c", "sleep 3600"]

      volumeMounts:
        - name: config-volume
          mountPath: /config

  volumes:
    - name: config-volume
      configMap:
        name: nginx-config
```

---

## volumes

```yaml
volumes:
  - name: config-volume
    configMap:
      name: nginx-config
```

Meaning:

```text
create a volume
↓
source = ConfigMap nginx-config
```

---

## volumeMounts

```yaml
volumeMounts:
  - name: config-volume
    mountPath: /config
```

Meaning:

```text
mount config-volume
↓
inside container
↓
at /config
```

---

## How file is created

The ConfigMap contains:

```text
app.conf
```

as a key.

When the ConfigMap is mounted as a volume:

```text
ConfigMap key
↓
becomes filename
```

and:

```text
ConfigMap value
↓
becomes file content
```

Therefore:

```text
ConfigMap:
app.conf
↓
mountPath:
/config
↓
file:
/config/app.conf
```

---

## Full flow

```text
kubectl apply ConfigMap
↓
ConfigMap stored in Kubernetes
↓
kubectl apply Pod
↓
Pod references ConfigMap as volume
↓
volume mounted at /config
↓
ConfigMap key app.conf becomes file
↓
/config/app.conf
```

---

## Verify mounted file

Enter Pod:

```bash
kubectl exec -it configmap-file-demo -- sh
```

Check directory:

```bash
ls -l /config
```

Check file:

```bash
cat /config/app.conf
```

Result:

```text
mode=production
color=blue
```

---

## Environment variables vs files

Environment variables:

```text
ConfigMap
↓
envFrom
↓
APP_ENV
APP_COLOR
```

Files:

```text
ConfigMap
↓
volume
↓
volumeMount
↓
/config/app.conf
```

---

## Mental model

```text
ConfigMap
= configuration stored in Kubernetes
```

Then Pod decides how to consume it:

```text
ConfigMap
├── env variables
└── mounted files
```

---

## Key commands

```bash
kubectl apply -f configmap.yaml

kubectl get configmap

kubectl describe configmap app-config

kubectl apply -f pod.yaml

kubectl exec -it configmap-demo -- sh

echo $APP_ENV
echo $APP_COLOR

kubectl apply -f configmap-file.yaml

kubectl apply -f pod-file.yaml

kubectl exec -it configmap-file-demo -- sh

ls -l /config

cat /config/app.conf
```

---

## Key takeaways

```text
ConfigMap stores non-sensitive configuration

ConfigMap exists independently from Pods

Pods can consume ConfigMaps as environment variables

Pods can consume ConfigMaps as mounted files

ConfigMap key becomes filename when mounted as volume

ConfigMap value becomes file content

mountPath defines where the file appears in the container
```

---

## Interview summary

A ConfigMap stores non-sensitive application configuration separately from the container image.

Pods can consume ConfigMap data as environment variables or as files mounted through volumes.

When a ConfigMap is mounted as a volume, each ConfigMap key becomes a file and the corresponding value becomes the file content.
