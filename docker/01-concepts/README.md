# Docker Lab 01 – Docker Concepts

## Objective

Understand the basic Docker concepts required to work with containers, images, registries, layers and container runtimes.

---

## Concepts

### Docker Image

A Docker image is a read-only template used to create containers.

It contains the application, dependencies, libraries and filesystem required to run the application.

### Docker Container

A Docker container is a running instance of a Docker image.

A container normally runs as long as its main process is running.

### Docker Registry

A Docker registry is a service used to store and distribute Docker images.

Example:

    Docker Hub

### Docker Repository

A repository is a collection of related Docker images, usually identified using different tags.

Example:

    nginx:1.25
    nginx:1.26
    nginx:latest

### Docker Layers

Docker images are built from multiple read-only layers.

Layers represent filesystem changes created during the image build.

Docker can reuse unchanged layers using build cache.

### Container Runtime

A container runtime is responsible for creating, starting and managing containers from container images.

Examples:

    containerd
    runc

---

## Container Isolation

Docker containers use Linux kernel mechanisms for isolation and resource control.

### Namespaces

Namespaces control what resources a container can see.

Examples:

    processes
    network
    filesystem mounts
    hostname

### cgroups

Control groups limit and control resource usage.

Examples:

    CPU
    RAM

---

## Docker Run Lifecycle

When running:

    docker run nginx

Docker performs the following steps:

1. Check whether the image exists locally.
2. Pull the image from a registry if necessary.
3. Create a container from the image.
4. Prepare container isolation.
5. Start the main process.
6. Keep the container running while the main process is running.

---

## Key Concepts

* Image – read-only template used to create containers
* Container – running instance of an image
* Registry – service used to store and distribute images
* Repository – collection of related images
* Layer – part of an image representing filesystem changes
* Runtime – starts and manages containers
* Namespaces – provide isolation
* cgroups – control resource usage

---

## What I Learned

* Understand the difference between Docker images and containers.
* Understand how Docker registries and repositories store images.
* Understand that Docker images consist of multiple layers.
* Understand the role of a container runtime.
* Understand basic container isolation using namespaces and cgroups.
* Understand what happens when running `docker run`.
