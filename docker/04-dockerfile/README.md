# Docker Lab 04 – Dockerfile

## Objective

Build a custom Docker image for a small FastAPI application and understand the basic Dockerfile workflow.

---

## Lab Structure

    Dockerfile
    requirements.txt
    app/main.py

---

## Application

The FastAPI application exposes three endpoints:

    /
    /health
    /info

Example response from `/`:

    {
      "message": "Docker SRE Lab",
      "status": "running"
    }

Example response from `/health`:

    {
      "status": "healthy"
    }

Example response from `/info`:

    {
      "hostname": "...",
      "environment": "development"
    }

---

## Dockerfile

Final Dockerfile:

    FROM python:3.12-slim

    WORKDIR /app

    COPY requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY app/ .

    EXPOSE 8000

    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

---

## Dockerfile Instructions

### FROM

Defines the base image:

    FROM python:3.12-slim

The slim variant provides a smaller Python base image.

---

### WORKDIR

Defines the working directory inside the image:

    WORKDIR /app

Following instructions are executed relative to this directory.

---

### COPY

Copy dependency file:

    COPY requirements.txt .

Copy application code:

    COPY app/ .

---

### RUN

Install Python dependencies:

    RUN pip install --no-cache-dir -r requirements.txt

---

### EXPOSE

Document the port used by the application:

    EXPOSE 8000

EXPOSE does not publish the port on the host.

Port publishing is configured when running the container.

---

### CMD

Define the default process started by the container:

    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

---

## Build Image

Build version 1:

    docker build -t fastapi-lab:v1 .

Syntax:

    docker build -t IMAGE_NAME:TAG BUILD_CONTEXT

In this case:

    IMAGE_NAME = fastapi-lab
    TAG        = v1
    CONTEXT    = .

---

## List Images

Display local images:

    docker images

Alternative:

    docker image ls

Filter FastAPI images:

    docker images | grep fastapi-lab

---

## Run Container

Run the image:

    docker run -d --name fastapi-app -p 8087:8000 fastapi-lab:v1

Port mapping:

    -p HOST_PORT:CONTAINER_PORT

Example:

    8087:8000

means:

    Host port 8087
          |
          v
    Container port 8000

---

## Test Application

Test root endpoint:

    curl http://localhost:8087/

Test health endpoint:

    curl http://localhost:8087/health

Test info endpoint:

    curl http://localhost:8087/info

---

## Environment Variables

Run another container with:

    APP_ENV=production

Example:

    docker run -d \
      --name fastapi-app2 \
      -p 8088:8000 \
      -e APP_ENV=production \
      fastapi-lab:v1

Test:

    curl http://localhost:8088/info

The response should contain:

    "environment": "production"

Without the environment variable, the application uses:

    development

---

## Multiple Containers From One Image

The same Docker image can be used to create multiple containers.

Example:

    fastapi-lab:v1
          |
          +-- fastapi-app
          +-- fastapi-app2
          +-- fastapi-app3

Each container can have its own:

    name
    host port
    environment variables
    runtime state

---

## Filter Containers By Image

Display containers created from a specific image:

    docker ps -a --filter ancestor=fastapi-lab:v1

---

## Image Tags

Build another tag:

    docker build -t fastapi-lab:v2 .

Add a new tag without rebuilding:

    docker tag fastapi-lab:v2 fastapi-lab:latest

Remove only the tag:

    docker image rm fastapi-lab:latest

Multiple tags can point to the same image ID.

---

## Image History

Display image layer history:

    docker history fastapi-lab:v2

Alternative:

    docker image history fastapi-lab:v2

This shows the layers and commands used to create the image.

---

## Inspect Image

Display full image information:

    docker inspect fastapi-lab:v2

Alternative:

    docker image inspect fastapi-lab:v2

Display working directory:

    docker inspect fastapi-lab:v2 | jq -r '.[0].Config.WorkingDir'

Display CMD:

    docker inspect fastapi-lab:v2 | jq '.[0].Config.Cmd'

Display exposed ports:

    docker inspect fastapi-lab:v2 | jq '.[0].Config.ExposedPorts'

Display image tags:

    docker inspect fastapi-lab:v2 | jq '.[0].RepoTags'

---

## Build Cache

Docker can reuse unchanged image layers during subsequent builds.

Example Dockerfile order:

    COPY requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY app/ .

If only:

    app/main.py

changes, Docker can reuse the cached dependency installation layer.

During the build this can be identified by:

    Using cache

Example:

    WORKDIR /app
        -> cache

    COPY requirements.txt .
        -> cache

    RUN pip install ...
        -> cache

    COPY app/ .
        -> rebuilt after application change

This prevents reinstalling dependencies every time application code changes.

---

## Build New Application Version

After changing the application:

    docker build -t fastapi-lab:v3 .

Run the new version:

    docker run -d \
      --name fastapi-v3 \
      -p 8090:8000 \
      fastapi-lab:v3

Test:

    curl http://localhost:8090/

---

## Important Concepts

    FROM     = base image

    WORKDIR  = working directory inside image

    COPY     = copy files into image

    RUN      = execute command during image build

    EXPOSE   = document application port

    CMD      = default process started by container

    docker build = create image

    docker run   = create and start container

    docker tag   = add another tag to existing image

    docker history = display image layers

    docker inspect = display image configuration

---

## What I Learned

* Create a Dockerfile for a Python application.
* Select a lightweight base image.
* Configure the working directory.
* Copy dependency and application files into an image.
* Install application dependencies during image build.
* Define the application startup command.
* Build Docker images with tags.
* Run containers from custom images.
* Map host ports to container ports.
* Pass environment variables to containers.
* Run multiple containers from one image.
* Inspect Docker image configuration.
* Understand Docker image tags.
* Inspect image layer history.
* Understand Docker build cache.
* Structure Dockerfile instructions to improve cache reuse.
