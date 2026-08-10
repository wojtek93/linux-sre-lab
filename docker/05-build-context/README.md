# Docker Lab 05 – Build Context and .dockerignore

## Objective

Understand how Docker build context works and how `.dockerignore` prevents unnecessary files from being copied into Docker images.

---

## Lab Structure

    Dockerfile
    .dockerignore
    requirements.txt
    notes.txt
    temp.log
    app/main.py

---

## Application

The FastAPI application exposes:

    /

Example response:

    {
      "message": "Build context lab"
    }

---

## Dockerfile

    FROM python:3.12-slim

    WORKDIR /app

    COPY requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY . .

    CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

---

## Build Context

Build image:

    docker build -t build-context:v1 .

The final dot:

    .

defines the Docker build context.

The build context is the directory whose files are available to Docker during the build.

---

## Initial Build

Build version 1:

    docker build -t build-context:v1 .

Run container:

    docker run -d --name build-context-v1 build-context:v1

Inspect files copied into the image:

    docker exec build-context-v1 ls -l /app

Before using `.dockerignore`, the image contained unnecessary files such as:

    notes.txt
    temp.log

This happened because the Dockerfile contains:

    COPY . .

which copies files from the build context into the image.

---

## .dockerignore

The `.dockerignore` file defines files and directories that should be excluded from the Docker build context.

Example:

    notes.txt
    temp.log

After adding these entries, Docker does not send these files as part of the build context.

---

## Build Image With .dockerignore

Build version 2:

    docker build -t build-context:v2 .

Run container:

    docker run -d --name build-context-v2 build-context:v2

Inspect image contents:

    docker exec build-context-v2 ls -l /app

The following files should no longer exist inside the image:

    notes.txt
    temp.log

---

## Compare Images

List images:

    docker images | grep build-context

Example:

    build-context   v1
    build-context   v2

For very small files, the image size difference may not be visible.

The important difference is that unnecessary files are no longer included in the image.

---

## Why .dockerignore Matters

Without `.dockerignore`, Docker may send unnecessary files during build.

Examples include:

    logs
    temporary files
    local notes
    .git directory
    cache files
    environment files
    test artifacts

This can result in:

    larger build context
    slower builds
    unnecessary files inside images
    reduced build cache efficiency
    possible exposure of sensitive files

---

## Example .dockerignore

A more realistic `.dockerignore` could contain:

    .git
    .gitignore
    *.log
    __pycache__/
    .pytest_cache/
    .venv/
    venv/
    .env
    notes.txt

Sensitive files such as `.env` should normally not be included in Docker images.

---

## COPY and Build Context

Dockerfile:

    COPY . .

does not mean:

    copy the entire host filesystem

It means:

    copy files from the current Docker build context

If the build command is:

    docker build -t build-context:v2 .

then:

    .

is the build context.

---

## Build Context Flow

    Host directory
          |
          v
    Build context
          |
          | .dockerignore filters files
          v
    Docker build
          |
          v
    COPY . .
          |
          v
    Docker image

---

## Important Difference

Without `.dockerignore`:

    build context
        |
        +-- app/
        +-- requirements.txt
        +-- notes.txt
        +-- temp.log

With `.dockerignore`:

    build context
        |
        +-- app/
        +-- requirements.txt

        notes.txt  -> ignored
        temp.log   -> ignored

---

## Useful Commands

Build image:

    docker build -t build-context:v1 .

Run container:

    docker run -d --name build-context-v1 build-context:v1

Inspect copied files:

    docker exec build-context-v1 ls -l /app

List images:

    docker images

List containers:

    docker ps -a

Remove test container:

    docker rm -f build-context-v1

---

## Key Concepts

    build context
        = files Docker can access during image build

    .
        = current directory used as build context

    COPY . .
        = copy files from build context into image

    .dockerignore
        = exclude unnecessary files from build context

---

## What I Learned

* Understand what Docker build context is.
* Understand the meaning of the final `.` in `docker build`.
* Understand how `COPY . .` uses the build context.
* Identify unnecessary files copied into Docker images.
* Create and use a `.dockerignore` file.
* Prevent logs and temporary files from entering Docker images.
* Reduce unnecessary build context data.
* Understand why `.dockerignore` improves Docker builds.
* Understand why sensitive files should not be included in build context.
