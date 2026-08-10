# Docker Lab 07 – Multi-stage Build

## Objective

Understand how Docker multi-stage builds work and how they can reduce the size of the final production image.

---

## Lab Structure

    Dockerfile.single
    Dockerfile.multi
    requirements.txt
    app/main.py

---

## Application

The FastAPI application exposes:

    /

Example response:

    {
      "message": "Multi-stage Docker lab",
      "status": "running"
    }

---

## Single-stage Build

The first Dockerfile uses a traditional single-stage build.

Dockerfile:

    FROM python:3.12-slim

    WORKDIR /app

    COPY requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY app/ .

    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

Build image:

    docker build -t multistage-single:v1 -f Dockerfile.single .

---

## Single-stage Concept

In a single-stage build, all build operations happen inside one image.

Conceptually:

    Base image
        |
        v
    Install dependencies
        |
        v
    Copy application
        |
        v
    Final image

Everything created during the build remains part of the image layers.

---

## Multi-stage Build

The multi-stage Dockerfile contains two separate stages.

### Builder Stage

    FROM python:3.12-slim AS builder

    WORKDIR /build

    COPY requirements.txt .

    RUN pip install --no-cache-dir --target=/install -r requirements.txt

The builder stage prepares the Python dependencies.

The stage is named:

    builder

using:

    AS builder

---

## Runtime Stage

The second stage starts from a clean base image:

    FROM python:3.12-slim

    WORKDIR /app

Only the required dependencies are copied from the builder stage:

    COPY --from=builder /install /usr/local/lib/python3.12/site-packages

Then the application code is copied:

    COPY app/ .

The final process is defined:

    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

---

## Final Multi-stage Dockerfile

    FROM python:3.12-slim AS builder

    WORKDIR /build

    COPY requirements.txt .

    RUN pip install --no-cache-dir --target=/install -r requirements.txt


    FROM python:3.12-slim

    WORKDIR /app

    COPY --from=builder /install /usr/local/lib/python3.12/site-packages

    COPY app/ .

    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

---

## Build Multi-stage Image

Build:

    docker build -t multistage-multi:v1 -f Dockerfile.multi .

---

## COPY --from

The important instruction is:

    COPY --from=builder /install /usr/local/lib/python3.12/site-packages

This means:

    take files from the stage called "builder"
                       |
                       v
    copy /install
                       |
                       v
    into the final runtime image

The final image does not need to contain the complete builder environment.

---

## Multi-stage Flow

    Stage 1 – Builder
    -----------------

    python:3.12-slim
          |
          v
    requirements.txt
          |
          v
    pip install
          |
          v
    /install
          |
          |
          | COPY --from=builder
          v

    Stage 2 – Runtime
    -----------------

    python:3.12-slim
          |
          v
    copied dependencies
          |
          v
    application code
          |
          v
    final runtime image

---

## Compare Image Sizes

Display the images:

    docker images | grep multistage

Observed during the lab:

    multistage-single:v1    ~212 MB

    multistage-multi:v1     ~49.3 MB

The multi-stage image was significantly smaller than the single-stage image in this lab.

---

## Why Multi-stage Builds Matter

Multi-stage builds allow us to separate:

    build environment

from:

    runtime environment

The build stage can contain tools required only during the build process.

The final stage contains only the files required to run the application.

---

## Benefits

Multi-stage builds can provide:

    smaller final images

    fewer unnecessary files

    fewer build tools in production

    faster image push and pull

    reduced attack surface

    cleaner production images

---

## Single-stage vs Multi-stage

Single-stage:

    build tools
        +
    dependencies
        +
    application
        |
        v
    final image

Multi-stage:

    builder stage
        |
        v
    build dependencies
        |
        v
    prepared artifacts
        |
        | copy only required files
        v
    clean runtime stage
        |
        v
    final image

---

## Important Commands

Build single-stage image:

    docker build -t multistage-single:v1 -f Dockerfile.single .

Build multi-stage image:

    docker build -t multistage-multi:v1 -f Dockerfile.multi .

Compare images:

    docker images | grep multistage

Inspect image:

    docker inspect multistage-multi:v1

Inspect layers:

    docker history multistage-multi:v1

---

## Key Concepts

    stage
        = one build phase inside a Dockerfile

    AS builder
        = assigns a name to a build stage

    COPY --from
        = copy files from another build stage

    builder stage
        = environment used to prepare application artifacts

    runtime stage
        = final environment used to run the application

---

## Important Rule

The builder stage can contain everything needed to build the application.

The final stage should contain only what is required to run it.

Simplified:

    build everything
          |
          v
    copy only what is needed
          |
          v
    run minimal final image

---

## What I Learned

* Understand the purpose of Docker multi-stage builds.
* Create multiple stages inside one Dockerfile.
* Name a Docker build stage using `AS`.
* Copy files between stages using `COPY --from`.
* Separate build-time dependencies from runtime dependencies.
* Build single-stage and multi-stage Docker images.
* Compare final Docker image sizes.
* Understand why production images should contain only required runtime files.
* Reduce image size using multi-stage builds.
* Understand how multi-stage builds can improve security and deployment efficiency.
