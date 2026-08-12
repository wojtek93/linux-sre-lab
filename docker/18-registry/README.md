# Docker Lab 18 — Container Registry

## Objective

Understand how to publish Docker images to a remote container registry and pull them back to another environment.

The main goal of this lab was to practice the full registry workflow:

- tag a local image
- authenticate to GitHub Container Registry
- push an image
- remove the local registry tag
- pull the image back from the remote registry

---

## Local Image

The image used in this lab was:

```text
vulnerable-app:v2
```

Verify that the image exists locally:

```bash
docker images
```

---

## GitHub Container Registry

GitHub Container Registry uses the hostname:

```text
ghcr.io
```

The image name follows this format:

```text
ghcr.io/NAMESPACE/IMAGE:TAG
```

Example used in this lab:

```text
ghcr.io/wojtek93/vulnerable-app:v2
```

Where:

```text
ghcr.io
```

is the registry,

```text
wojtek93
```

is the GitHub namespace,

```text
vulnerable-app
```

is the image name,

and:

```text
v2
```

is the image tag.

---

## Tag the Image

Tag the local image for GitHub Container Registry:

```bash
docker tag vulnerable-app:v2 ghcr.io/wojtek93/vulnerable-app:v2
```

Check images:

```bash
docker images
```

The same image now has an additional tag:

```text
ghcr.io/wojtek93/vulnerable-app:v2
```

Tagging does not build a new image.

It creates another reference to the same image.

---

## Registry Authentication

A GitHub Personal Access Token was used to authenticate to GHCR.

The token was stored temporarily in an environment variable:

```bash
export CR_PAT='TOKEN'
```

Login:

```bash
echo "$CR_PAT" | docker login ghcr.io -u wojtek93 --password-stdin
```

Successful authentication returns:

```text
Login Succeeded
```

Using `--password-stdin` avoids placing the token directly in the command argument list.

---

## Push the Image

Push the image to GitHub Container Registry:

```bash
docker push ghcr.io/wojtek93/vulnerable-app:v2
```

Docker uploads the image layers to the remote registry.

The flow is:

```text
local Docker host
       ↓
docker push
       ↓
ghcr.io
       ↓
remote image stored in registry
```

---

## Registry Purpose

A Docker registry stores and distributes container images.

The basic workflow is:

```text
Dockerfile
    ↓
docker build
    ↓
local image
    ↓
docker tag
    ↓
docker push
    ↓
container registry
```

Another server can later retrieve the image:

```text
container registry
       ↓
docker pull
       ↓
local image
       ↓
docker run
```

---

## Test the Remote Image

To verify that the image actually exists in the registry, the local GHCR tag was removed:

```bash
docker image rm ghcr.io/wojtek93/vulnerable-app:v2
```

This removes the local image reference.

It does not remove the image stored in GitHub Container Registry.

---

## Pull the Image

Pull the image again from GHCR:

```bash
docker pull ghcr.io/wojtek93/vulnerable-app:v2
```

Verify:

```bash
docker images | grep vulnerable-app
```

The image appeared locally again after being downloaded from the remote registry.

This confirmed that the push was successful.

---

## Full Registry Workflow

The complete workflow used in this lab was:

```text
local image
    ↓
docker tag
    ↓
registry-compatible image name
    ↓
docker login
    ↓
docker push
    ↓
remote registry
    ↓
remove local tag
    ↓
docker pull
    ↓
image available locally again
```

---

## Build vs Tag vs Push

### Build

```bash
docker build -t vulnerable-app:v2 .
```

Creates a Docker image locally.

### Tag

```bash
docker tag vulnerable-app:v2 ghcr.io/wojtek93/vulnerable-app:v2
```

Adds another name to an existing image.

### Push

```bash
docker push ghcr.io/wojtek93/vulnerable-app:v2
```

Uploads the image to the remote registry.

### Pull

```bash
docker pull ghcr.io/wojtek93/vulnerable-app:v2
```

Downloads the image from the registry.

---

## Why Registries Matter

Without a registry, an image exists only on the machine where it was built.

Example:

```text
Developer machine
      ↓
Docker image
```

Another server does not automatically have access to that image.

With a registry:

```text
Developer / CI
      ↓
docker push
      ↓
Registry
      ↓
docker pull
      ↓
Production server
```

The registry becomes the distribution point for container images.

---

## CI/CD Use Case

A common CI/CD workflow is:

```text
git push
   ↓
CI pipeline
   ↓
docker build
   ↓
security scan
   ↓
docker tag
   ↓
docker push
   ↓
container registry
   ↓
deployment environment
   ↓
docker pull
   ↓
run new version
```

This allows the exact same image to move between environments.

---

## Image Tags

Tags can represent versions:

```text
v1
v2
v3
```

Example:

```text
ghcr.io/wojtek93/vulnerable-app:v1
ghcr.io/wojtek93/vulnerable-app:v2
```

A tag can also be named:

```text
latest
```

For example:

```text
ghcr.io/wojtek93/vulnerable-app:latest
```

Versioned tags make it easier to identify which application version is being deployed.

---

## Useful Commands

List local images:

```bash
docker images
```

Tag an image:

```bash
docker tag SOURCE_IMAGE TARGET_IMAGE
```

Example:

```bash
docker tag vulnerable-app:v2 ghcr.io/wojtek93/vulnerable-app:v2
```

Login to a registry:

```bash
docker login ghcr.io
```

Login using stdin:

```bash
echo "$CR_PAT" | docker login ghcr.io -u wojtek93 --password-stdin
```

Push an image:

```bash
docker push ghcr.io/wojtek93/vulnerable-app:v2
```

Pull an image:

```bash
docker pull ghcr.io/wojtek93/vulnerable-app:v2
```

Remove a local image reference:

```bash
docker image rm ghcr.io/wojtek93/vulnerable-app:v2
```

---

## Key Concepts

A Docker registry is a remote service used to store container images.

Important concepts:

```text
image
tag
registry
namespace
push
pull
authentication
```

The registry address is part of the image name.

Example:

```text
ghcr.io/wojtek93/vulnerable-app:v2
```

Docker can identify:

```text
registry = ghcr.io
namespace = wojtek93
image = vulnerable-app
tag = v2
```

---

## Security Note

Registry credentials and access tokens should not be stored in:

```text
Dockerfile
source code
Git repository
compose.yaml
README
```

Tokens should be provided through secure credential storage, environment variables, or CI/CD secret management.

---

## What I Learned

- container registries store and distribute Docker images
- GitHub Container Registry uses `ghcr.io`
- registry image names include registry, namespace, image name, and tag
- `docker tag` adds another reference to an existing image
- tagging does not rebuild or duplicate the image
- `docker login` authenticates Docker to a registry
- `--password-stdin` can be used to provide credentials more safely
- `docker push` uploads an image to a remote registry
- `docker pull` downloads an image from a remote registry
- removing a local image does not remove the remote registry copy
- pulling the image after local removal verifies that the registry push succeeded
- image registries are an important part of CI/CD workflows
- registries allow the same image to be used across development, testing, and production environments
- versioned image tags help identify deployed application versions
- registry credentials should never be committed to Git
