# Docker Lab 06 – Layers and Build Cache

## Objective

Understand how Docker image layers and build cache work, and how Dockerfile instruction order affects rebuild performance.

---

## Lab Structure

    Dockerfile.bad
    Dockerfile.good
    requirements.txt
    app/main.py

---

## Application

The FastAPI application exposes:

    /

Example response:

    {
      "message": "Docker layers lab",
      "version": "1.0"
    }

---

## Bad Dockerfile

Initial Dockerfile:

    FROM python:3.12-slim

    WORKDIR /app

    COPY . .

    RUN pip install --no-cache-dir -r requirements.txt

    CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

---

## Build Bad Image

Build image using a custom Dockerfile:

    docker build -t layers-bad:v1 -f Dockerfile.bad .

Options:

    -t layers-bad:v1
        image name and tag

    -f Dockerfile.bad
        specify Dockerfile name

    .
        current directory used as build context

---

## Build Context

The final dot in:

    docker build -t layers-bad:v1 -f Dockerfile.bad .

means:

    current directory = build context

Docker can access files inside this directory during the build.

Example:

    .
    ├── Dockerfile.bad
    ├── Dockerfile.good
    ├── requirements.txt
    └── app/
        └── main.py

---

## Docker Build Cache

Running the same build again without changing any files:

    docker build -t layers-bad:v1 -f Dockerfile.bad .

allows Docker to reuse previous layers.

Example output:

    Step 2/5 : WORKDIR /app
     ---> Using cache

    Step 3/5 : COPY . .
     ---> Using cache

    Step 4/5 : RUN pip install --no-cache-dir -r requirements.txt
     ---> Using cache

`Using cache` means Docker did not execute that step again.

---

## Cache Invalidation

The bad Dockerfile contains:

    COPY . .

    RUN pip install --no-cache-dir -r requirements.txt

When only:

    app/main.py

is modified, the result of:

    COPY . .

changes.

This invalidates the cache for that layer and all following layers.

As a result:

    RUN pip install ...

is executed again.

---

## Bad Dockerfile Flow

    source code changed
           |
           v
       COPY . .
           |
           v
    cache invalidated
           |
           v
      pip install
      runs again
           |
           v
       slow build

Even though:

    requirements.txt

did not change.

---

## Good Dockerfile

Optimized Dockerfile:

    FROM python:3.12-slim

    WORKDIR /app

    COPY requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY . .

    CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

---

## Why This Order Is Better

Dependencies are copied and installed before application source code.

The files that change less frequently are placed earlier in the Dockerfile:

    requirements.txt

Application code, which changes more frequently, is copied later:

    app/main.py

---

## Build Good Image

Build:

    docker build -t layers-good:v1 -f Dockerfile.good .

After modifying only application code:

    docker build -t layers-good:v2 -f Dockerfile.good .

Docker can reuse the dependency layers.

Example:

    COPY requirements.txt .
        -> Using cache

    RUN pip install ...
        -> Using cache

    COPY . .
        -> rebuilt

---

## Good Dockerfile Flow

    app/main.py changed
           |
           v
    requirements.txt
       unchanged
           |
           v
      COPY requirements
         cache
           |
           v
       pip install
         cache
           |
           v
       COPY . .
       rebuilt
           |
           v
       faster build

---

## Bad vs Good

Bad:

    COPY . .
    RUN pip install ...

A source code change invalidates the dependency installation layer.

Good:

    COPY requirements.txt .
    RUN pip install ...
    COPY . .

A source code change does not invalidate dependency installation.

---

## Docker Layers

Each relevant Dockerfile instruction contributes to the image build history.

Examples:

    FROM
    WORKDIR
    COPY
    RUN
    CMD

Docker can reuse unchanged build results instead of executing the same steps again.

---

## Cache Rule

A useful rule:

    If a Docker layer changes,
    following layers may also need to be rebuilt.

Therefore:

    stable instructions first
    frequently changing instructions later

---

## Useful Commands

Build using default Dockerfile:

    docker build -t image:v1 .

Build using another Dockerfile:

    docker build -t image:v1 -f Dockerfile.good .

Inspect image history:

    docker history layers-good:v2

List images:

    docker images

---

## Key Concepts

    layer
        = result of an image build step

    cache
        = reuse of unchanged build results

    cache invalidation
        = previous cached result can no longer be reused

    build context
        = files available to Docker during build

    .
        = current directory as build context

---

## Dockerfile Optimization Rule

Prefer:

    COPY requirements.txt .

    RUN pip install -r requirements.txt

    COPY . .

Instead of:

    COPY . .

    RUN pip install -r requirements.txt

when dependencies change less frequently than application code.

---

## What I Learned

* Understand Docker image layers.
* Understand Docker build cache.
* Identify `Using cache` in Docker build output.
* Understand how cache invalidation works.
* Understand why Dockerfile instruction order matters.
* Understand why copying all files too early can cause unnecessary rebuilds.
* Separate dependency installation from application source code.
* Optimize Dockerfiles for faster rebuilds.
* Use `-f` to build from a custom Dockerfile.
* Understand the meaning of the final `.` in `docker build`.
* Compare inefficient and optimized Dockerfile structures.
