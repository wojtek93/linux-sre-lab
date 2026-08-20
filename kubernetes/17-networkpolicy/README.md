# KUB-17 NetworkPolicy

## Goal

Understand how Kubernetes NetworkPolicy controls network traffic between Pods.

The lab demonstrates:

```text
Pod-to-Pod communication
Ingress traffic
default deny behavior
allow rules
podSelector
port restrictions
```

---

## Starting point

Two Pods were created:

```text
client
web
```

The `web` Pod runs nginx.

The `client` Pod contains curl and is used to generate HTTP traffic.

---

## Pods manifest

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
  labels:
    app: web
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80

---
apiVersion: v1
kind: Pod
metadata:
  name: client
  labels:
    app: client
spec:
  containers:
    - name: curl
      image: curlimages/curl:latest
      command: ["sh", "-c", "sleep 3600"]
```

---

## Pod labels

The important labels were:

```text
web
↓
app=web
```

and:

```text
client
↓
app=client
```

NetworkPolicy uses labels to select Pods.

---

## Create Pods

```bash
kubectl apply -f pods.yaml
```

Check:

```bash
kubectl get pods -o wide
```

---

## Test communication before NetworkPolicy

The IP address of the `web` Pod was checked:

```bash
kubectl get pod web -o wide
```

Then the client Pod was entered:

```bash
kubectl exec -it client -- sh
```

The nginx Pod was accessed with:

```bash
curl http://<WEB_POD_IP>
```

The nginx page was returned.

This confirmed:

```text
client
↓
HTTP
↓
web:80
↓
nginx
```

---

# NetworkPolicy

NetworkPolicy controls allowed network communication for selected Pods.

Important concepts:

```text
podSelector
= which Pods are protected by the policy

Ingress
= incoming traffic

Egress
= outgoing traffic
```

---

## Ingress does not mean block

This was an important distinction in the lab.

```yaml
policyTypes:
  - Ingress
```

does NOT mean:

```text
block traffic
```

It means:

```text
this NetworkPolicy controls incoming traffic
```

---

# Deny all incoming traffic

The first NetworkPolicy selected the web Pod:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-web

spec:
  podSelector:
    matchLabels:
      app: web

  policyTypes:
    - Ingress
```

---

## Why this blocks traffic

The policy contains:

```text
policyTypes:
Ingress
```

but does not contain any allowed:

```yaml
ingress:
```

rules.

Therefore:

```text
web is selected by NetworkPolicy
↓
incoming traffic is restricted
↓
no source is allowed
↓
incoming traffic is blocked
```

---

## Apply deny policy

```bash
kubectl apply -f deny-web.yaml
```

Check:

```bash
kubectl get networkpolicy
```

---

## Test blocked traffic

From the client:

```bash
kubectl exec -it client -- sh
```

then:

```bash
curl --connect-timeout 5 http://<WEB_POD_IP>
```

The request timed out.

This confirmed:

```text
client
↓
NetworkPolicy
↓
DROP
↓
web not reachable
```

---

# Allow only client Pod

The policy was then changed so that only Pods with:

```text
app=client
```

could connect to:

```text
app=web
```

on:

```text
TCP/80
```

---

## Allow policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-client-to-web

spec:
  podSelector:
    matchLabels:
      app: web

  policyTypes:
    - Ingress

  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: client

      ports:
        - protocol: TCP
          port: 80
```

---

## How to read this policy

```text
podSelector:
app=web
```

means:

```text
this policy applies to web Pods
```

---

```text
policyTypes:
Ingress
```

means:

```text
control incoming traffic to web
```

---

```text
from:
podSelector:
app=client
```

means:

```text
allow traffic from Pods labeled app=client
```

---

```text
port: 80
protocol: TCP
```

means:

```text
allow only TCP traffic to port 80
```

---

## Full policy logic

```text
destination:
app=web

source:
app=client

protocol:
TCP

port:
80
```

Meaning:

```text
client
app=client
↓
allowed
↓
web
app=web
↓
TCP/80
```

---

## Verify labels

The Pod labels were checked with:

```bash
kubectl get pod client --show-labels
```

Result included:

```text
app=client
```

For web:

```bash
kubectl get pod web --show-labels
```

Result included:

```text
app=web
```

This was important because NetworkPolicy matches Pods using labels.

---

## Multiple NetworkPolicies

During the lab both policies temporarily existed:

```text
deny-web
allow-client-to-web
```

Kubernetes NetworkPolicies are additive.

A deny-style policy does not automatically override a valid allow rule.

For clarity in the lab, the old policy was removed:

```bash
kubectl delete networkpolicy deny-web
```

---

## Final connectivity test

After keeping the allow rule:

```bash
kubectl exec -it client -- sh
```

then:

```bash
curl --connect-timeout 5 http://<WEB_POD_IP>
```

The nginx page was returned again.

This confirmed that:

```text
client with app=client
↓
matches allowed source
↓
TCP/80 allowed
↓
web reachable
```

---

# NetworkPolicy mental model

Think of NetworkPolicy as a firewall for Pods.

```text
Pod
↓
NetworkPolicy
↓
who can communicate?
↓
on which ports?
↓
in which direction?
```

---

## Ingress vs Egress

Ingress:

```text
traffic coming INTO Pod
```

Example:

```text
client
↓
web
```

For the `web` Pod this is:

```text
Ingress
```

---

Egress:

```text
traffic going OUT of Pod
```

Example:

```text
web
↓
external server
```

For the `web` Pod this is:

```text
Egress
```

---

## Default behavior

Without a NetworkPolicy selecting a Pod:

```text
traffic generally allowed
```

Once an ingress NetworkPolicy selects the Pod:

```text
only explicitly allowed ingress traffic is permitted
```

---

# Important selectors

Destination selector:

```yaml
podSelector:
  matchLabels:
    app: web
```

Means:

```text
apply policy to web
```

Source selector:

```yaml
from:
  - podSelector:
      matchLabels:
        app: client
```

Means:

```text
allow client Pods
```

---

## Full flow from the lab

Before NetworkPolicy:

```text
client
↓
web
↓
works
```

With deny policy:

```text
client
↓
NetworkPolicy
↓
blocked
↓
timeout
```

With allow policy:

```text
client
app=client
↓
allowed by NetworkPolicy
↓
web
app=web
↓
TCP/80
↓
works
```

---

# Troubleshooting NetworkPolicy

Useful workflow:

```text
connection timeout
↓
check source Pod labels
↓
check destination Pod labels
↓
check NetworkPolicies
↓
check podSelector
↓
check from selector
↓
check protocol and port
```

Useful commands:

```bash
kubectl get networkpolicy
```

```bash
kubectl describe networkpolicy allow-client-to-web
```

```bash
kubectl get pod client --show-labels
```

```bash
kubectl get pod web --show-labels
```

```bash
kubectl get pod web -o wide
```

---

## Useful commands

Create Pods:

```bash
kubectl apply -f pods.yaml
```

List Pods:

```bash
kubectl get pods -o wide
```

Show labels:

```bash
kubectl get pod client --show-labels
kubectl get pod web --show-labels
```

Apply NetworkPolicy:

```bash
kubectl apply -f deny-web.yaml
```

List policies:

```bash
kubectl get networkpolicy
```

Describe policy:

```bash
kubectl describe networkpolicy allow-client-to-web
```

Delete policy:

```bash
kubectl delete networkpolicy deny-web
```

Test connectivity:

```bash
kubectl exec -it client -- sh
```

then:

```bash
curl --connect-timeout 5 http://<WEB_POD_IP>
```

---

# Key takeaways

```text
NetworkPolicy controls Pod network traffic

podSelector selects Pods protected by the policy

Ingress means incoming traffic

Egress means outgoing traffic

Ingress does not automatically mean block

an ingress policy with no allow rules effectively blocks incoming traffic

from.podSelector selects allowed source Pods

ports restrict allowed destination ports

labels are critical for NetworkPolicy matching

NetworkPolicies are additive

NetworkPolicy behaves conceptually like a firewall for Pods
```

---

# Interview summary

Kubernetes NetworkPolicy controls network communication between Pods.

A `podSelector` identifies which Pods the policy applies to.

`Ingress` controls traffic entering those Pods, while `Egress` controls traffic leaving them.

In this lab, we first applied an ingress policy with no allow rules, which blocked traffic to the nginx Pod.

We then created a policy allowing only Pods labeled `app=client` to connect to Pods labeled `app=web` on TCP port 80.

This demonstrated label-based network isolation and controlled Pod-to-Pod communication.
