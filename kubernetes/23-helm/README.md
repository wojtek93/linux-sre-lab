# KUB-23 Helm

## Goal

Understand how Helm simplifies Kubernetes application deployment by packaging Kubernetes manifests into reusable and configurable charts.

This lab demonstrated:

```text
Helm installation
Helm Chart structure
Chart.yaml
values.yaml
templates
helm template
helm install
helm upgrade
helm history
helm rollback
helm uninstall
```

---

# What is Helm?

Helm is a package manager and templating system for Kubernetes.

Without Helm, an application can require many separate manifest files:

```text
deployment.yaml
service.yaml
configmap.yaml
ingress.yaml
secret.yaml
```

With Helm, these resources can be grouped into one reusable package:

```text
Helm Chart
```

Mental model:

```text
Chart
↓
templates
+
values.yaml
↓
Helm renders YAML
↓
Kubernetes resources
```

---

# Helm installation

First, Helm was not installed:

```bash
helm version
```

The shell returned that the `helm` command was not available.

Helm was installed using the official installation script:

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

Then verified with:

```bash
helm version
```

---

# Create a Helm Chart

The lab directory was:

```bash
cd ~/Projects/linux-sre-lab/kubernetes/23-helm
```

A new chart was created with:

```bash
helm create nginx-chart
```

This generated a ready-to-use Helm chart structure.

---

# Chart structure

The chart contents were inspected with:

```bash
find nginx-chart -maxdepth 2 -type f | sort
```

Important files included:

```text
nginx-chart/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── serviceaccount.yaml
    ├── _helpers.tpl
    └── ...
```

---

# Chart.yaml

`Chart.yaml` contains metadata describing the Helm chart.

Example information:

```text
chart name
chart version
application version
description
```

Simplified:

```text
Chart.yaml
=
information about the package
```

---

# values.yaml

`values.yaml` stores configurable values used by templates.

Example:

```yaml
replicaCount: 1
```

Instead of hardcoding a value directly into every Kubernetes manifest, templates can read the value from `values.yaml`.

Simplified:

```text
values.yaml
=
configuration
```

---

# templates directory

The:

```text
templates/
```

directory contains Kubernetes manifest templates.

For example:

```text
deployment.yaml
service.yaml
ingress.yaml
```

Unlike normal Kubernetes manifests, Helm templates can contain expressions such as:

```yaml
replicas: {{ .Values.replicaCount }}
```

This means:

```text
read replicaCount from values.yaml
```

---

# Rendering templates

Before installing anything into Kubernetes, the chart was rendered with:

```bash
helm template my-nginx ./nginx-chart
```

This command did not deploy the application.

It only generated the final Kubernetes manifests.

Flow:

```text
values.yaml
+
templates
↓
helm template
↓
rendered Kubernetes YAML
```

This is useful for:

```text
debugging
reviewing manifests
checking configuration
CI/CD validation
```

---

# Chart vs Release

Two important Helm concepts are:

```text
Chart
Release
```

A Chart is the package:

```text
nginx-chart
```

A Release is a particular installed instance of that chart.

In this lab:

```text
Chart:
nginx-chart

Release:
my-nginx
```

Mental model:

```text
Chart
=
application package

Release
=
installed instance of that package
```

---

# Install the Chart

The chart was installed with:

```bash
helm install my-nginx ./nginx-chart
```

This created a Helm release named:

```text
my-nginx
```

Helm rendered the templates and sent the resulting Kubernetes manifests to the cluster.

Flow:

```text
nginx-chart
↓
helm install
↓
render templates
↓
send manifests to Kubernetes API
↓
Deployment / Service / other resources created
```

---

# Check releases

Installed releases were checked with:

```bash
helm list
```

The release showed:

```text
STATUS: deployed
```

---

# Check Kubernetes resources

The resources created by Helm were verified with:

```bash
kubectl get pods
kubectl get svc
```

A Pod belonging to the Helm release was running.

The Pod name included the release and chart information.

---

# Changing configuration with values.yaml

The chart initially used:

```yaml
replicaCount: 1
```

The file was edited:

```bash
vi nginx-chart/values.yaml
```

and changed to:

```yaml
replicaCount: 3
```

---

# Verify rendered configuration

Before applying the change, the generated Deployment configuration was checked with:

```bash
helm template my-nginx ./nginx-chart | grep -A3 replicas
```

The rendered manifest showed:

```yaml
replicas: 3
```

This confirmed that Helm correctly used the new value.

---

# Helm upgrade

The running release was updated with:

```bash
helm upgrade my-nginx ./nginx-chart
```

The release remained:

```text
deployed
```

but Helm created a new revision.

After the upgrade:

```bash
kubectl get pods -l app.kubernetes.io/instance=my-nginx
```

showed three Pods.

---

# Upgrade flow

The complete flow was:

```text
values.yaml

replicaCount: 3
↓
Helm template reads value
↓
Deployment rendered with:

replicas: 3
↓
helm upgrade
↓
Kubernetes Deployment updated
↓
3 Pods running
```

This demonstrates one of the main advantages of Helm.

Instead of manually modifying many Kubernetes YAML files, configurable values can be centralized in:

```text
values.yaml
```

---

# Helm revisions

Helm stores a history of changes made to a release.

The history was checked with:

```bash
helm history my-nginx
```

The release contained multiple revisions.

Conceptually:

```text
Revision 1
=
initial installation

Revision 2
=
upgrade to 3 replicas
```

---

# Helm rollback

The release was rolled back to the original configuration:

```bash
helm rollback my-nginx 1
```

This restored the configuration from revision 1.

After rollback:

```bash
kubectl get pods -l app.kubernetes.io/instance=my-nginx
```

returned to the previous replica configuration.

---

# Rollback model

```text
helm install
↓
revision 1

helm upgrade
↓
revision 2

helm rollback my-nginx 1
↓
restore configuration from revision 1
```

This makes application recovery much easier when a deployment introduces a problem.

---

# Helm history after rollback

The release history can be inspected again with:

```bash
helm history my-nginx
```

Helm tracks changes to the release and keeps revision information.

This is useful during deployment troubleshooting and incident recovery.

---

# Helm uninstall

Finally, the release was removed with:

```bash
helm uninstall my-nginx
```

The release was then checked with:

```bash
helm list
```

and its Pods with:

```bash
kubectl get pods -l app.kubernetes.io/instance=my-nginx
```

The Helm-managed application resources were removed.

---

# Full Helm lifecycle

This lab covered the basic Helm lifecycle:

```text
helm create
↓
create chart

helm template
↓
render manifests

helm install
↓
deploy release

helm upgrade
↓
update release

helm history
↓
show revisions

helm rollback
↓
restore previous revision

helm uninstall
↓
remove release
```

---

# Important Helm commands

Create a chart:

```bash
helm create nginx-chart
```

Render templates:

```bash
helm template my-nginx ./nginx-chart
```

Install:

```bash
helm install my-nginx ./nginx-chart
```

List releases:

```bash
helm list
```

Upgrade:

```bash
helm upgrade my-nginx ./nginx-chart
```

Show history:

```bash
helm history my-nginx
```

Rollback:

```bash
helm rollback my-nginx 1
```

Uninstall:

```bash
helm uninstall my-nginx
```

---

# How Helm works

Simplified internal flow:

```text
Chart
↓
Chart.yaml
values.yaml
templates/
↓
Helm rendering engine
↓
standard Kubernetes YAML
↓
Kubernetes API Server
↓
resources created
```

Helm does not replace Kubernetes.

It generates and manages Kubernetes resources.

Ultimately Kubernetes still receives normal resources such as:

```text
Deployment
Service
ConfigMap
Ingress
Secret
```

---

# Why values.yaml is useful

Imagine different environments:

```text
development
staging
production
```

They may use the same templates but different values.

For example:

```text
development:
replicas = 1

production:
replicas = 5
```

The Kubernetes structure can stay the same while configuration changes.

This makes Helm useful for reusable deployments.

---

# Helm templates

A normal Kubernetes manifest might contain:

```yaml
replicas: 3
```

A Helm template can contain:

```yaml
replicas: {{ .Values.replicaCount }}
```

and `values.yaml` contains:

```yaml
replicaCount: 3
```

During rendering:

```text
{{ .Values.replicaCount }}
↓
3
```

The final YAML sent to Kubernetes becomes:

```yaml
replicas: 3
```

---

# Helm release naming

The release name is important.

Example:

```bash
helm install my-nginx ./nginx-chart
```

means:

```text
my-nginx
=
release name

./nginx-chart
=
chart location
```

The same chart can theoretically be installed multiple times with different release names.

Example:

```text
frontend-dev
frontend-prod
```

using the same chart but different configuration.

---

# Practical troubleshooting

Useful commands during Helm troubleshooting:

```bash
helm list
```

Check installed releases.

```bash
helm history my-nginx
```

Check revision history.

```bash
helm template my-nginx ./nginx-chart
```

Inspect rendered manifests.

```bash
kubectl get pods
```

Check resources created in Kubernetes.

```bash
kubectl describe pod <pod>
```

Troubleshoot a resulting Kubernetes Pod.

---

# Helm and Kubernetes troubleshooting

Helm manages the deployment configuration, but runtime problems are still diagnosed with Kubernetes tools.

Example:

```text
helm install succeeds
↓
Pod CrashLoopBackOff
```

At this point use:

```bash
kubectl get pods
kubectl describe pod
kubectl logs
```

So:

```text
Helm
=
package and release management

kubectl
=
Kubernetes resource and runtime troubleshooting
```

---

# Key takeaways

```text
Helm is a package manager for Kubernetes

Helm Charts package Kubernetes manifests

Chart.yaml stores chart metadata

values.yaml stores configurable values

templates contain parameterized Kubernetes YAML

helm template renders manifests without deploying them

helm install creates a release

a Release is an installed instance of a Chart

helm upgrade changes an existing release

each change creates a revision

helm history shows release revisions

helm rollback restores an older revision

helm uninstall removes the release

Helm ultimately produces normal Kubernetes resources
```

---

# Mental model

```text
values.yaml
      +
templates/
      ↓
     Helm
      ↓
rendered Kubernetes YAML
      ↓
Kubernetes API
      ↓
Deployment
Service
Pods
etc.
```

---

# Interview summary

Helm is a Kubernetes package manager that uses Charts to package and configure Kubernetes resources.

A Helm Chart contains metadata in `Chart.yaml`, configurable values in `values.yaml`, and Kubernetes manifest templates in the `templates` directory.

`helm template` renders the templates locally without deploying them.

`helm install` creates a release from a chart.

When configuration changes, `helm upgrade` updates the release and creates a new revision.

`helm history` shows previous revisions, while `helm rollback` allows restoring a previous version.

Finally, `helm uninstall` removes the release and its managed Kubernetes resources.

In this lab, the nginx chart was installed with one replica, upgraded through `values.yaml` to three replicas, rolled back to the original revision, and finally uninstalled.
