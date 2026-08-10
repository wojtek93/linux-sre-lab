# Docker Lab 09 – Healthcheck

## Objective

Understand how Docker health checks work and how to distinguish between a running container and a healthy application.

---

## Lab Structure

    Dockerfile
    requirements.txt
    app/main.py

---

## Application

The FastAPI application exposes:

    /
    /health

Example response from `/`:

    {
      "message": "Docker healthcheck lab",
      "status": "running"
    }

Example response from `/health`:

    {
      "status": "healthy"
    }

---

## Initial Dockerfile

The initial image did not contain a healthcheck:

    FROM python:3.12-slim

    WORKDIR /app

    COPY requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY app/ .

    EXPOSE 8000

    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

---

## Build Initial Image

Build:

    docker build -t healthcheck-lab:v1 .

Run:

    docker run -d --name healthcheck-v1 -p 8094:8000 healthcheck-lab:v1

Test application:

    curl http://localhost:8094/health

---

## HEALTHCHECK Instruction

A Docker image can define a healthcheck using:

    HEALTHCHECK

Example:

    HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
      CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

---

## Healthcheck Options

    --interval=10s

Run the healthcheck every 10 seconds.

    --timeout=3s

Consider the healthcheck failed if it takes longer than 3 seconds.

    --start-period=5s

Allow the application time to start before failures are counted.

    --retries=3

Mark the container unhealthy after 3 consecutive failed checks.

---

## Dockerfile With Healthcheck

    FROM python:3.12-slim

    WORKDIR /app

    COPY requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY app/ .

    EXPOSE 8000

    HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
      CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

---

## Build Healthy Version

Build:

    docker build -t healthcheck-lab:v2 .

Run:

    docker run -d --name healthcheck-v2 -p 8095:8000 healthcheck-lab:v2

Check status:

    docker ps

The status may initially show:

    health: starting

and later:

    healthy

---

## Healthy State

A healthy container means:

    container process is running

and:

    configured healthcheck succeeds

Example:

    Up 30 seconds (healthy)

---

## Broken Healthcheck

To simulate a failing healthcheck, change the endpoint from:

    /health

to:

    /badhealth

Example:

    HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
      CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/badhealth')" || exit 1

Build:

    docker build -t healthcheck-lab:v3 .

Run:

    docker run -d --name healthcheck-v3 -p 8096:8000 healthcheck-lab:v3

---

## Unhealthy State

Check:

    docker ps

The container may first show:

    health: starting

and later:

    unhealthy

Important:

    the container can still be running

while:

    the application healthcheck is failing

This means:

    running != healthy

---

## Inspect Healthcheck Details

Display healthcheck information:

    docker inspect healthcheck-v3 | jq '.[0].State.Health'

This can show:

    Status
    FailingStreak
    Log

These fields help identify why a container is considered unhealthy.

---

## Healthcheck Flow

    container starts
          |
          v
    health: starting
          |
          v
    healthcheck runs
          |
      +---+---+
      |       |
    success  failure
      |       |
      v       v
    healthy  retry
              |
              v
         repeated failure
              |
              v
          unhealthy

---

## Container State vs Application Health

Container running:

    process is alive

Container healthy:

    process is alive
    +
    healthcheck succeeds

Therefore:

    Up

does not always mean:

    application works correctly

---

## Why Healthchecks Matter

Healthchecks help detect situations where:

    the container process is running
    but the application is not responding correctly

Examples:

    application hangs
    dependency is unavailable
    wrong endpoint
    internal service failure
    application startup problem

---

## Useful Commands

Build image:

    docker build -t healthcheck-lab:v2 .

Run container:

    docker run -d --name healthcheck-v2 -p 8095:8000 healthcheck-lab:v2

Check container status:

    docker ps

Inspect health details:

    docker inspect healthcheck-v3 | jq '.[0].State.Health'

Test endpoint manually:

    curl http://localhost:8095/health

---

## Key Concepts

    HEALTHCHECK
        = defines how Docker checks application health

    healthy
        = healthcheck succeeds

    unhealthy
        = healthcheck repeatedly fails

    health: starting
        = container is still inside the startup period

    running
        = container process is alive

    healthy
        = application also passes its healthcheck

---

## Important Rule

    container running
        does not guarantee
    application healthy

Simplified:

    running != healthy

---

## What I Learned

* Add a Docker HEALTHCHECK instruction.
* Configure healthcheck interval, timeout, startup period and retries.
* Observe the `health: starting` state.
* Observe the `healthy` state.
* Simulate and diagnose an `unhealthy` container.
* Understand the difference between container runtime state and application health.
* Inspect Docker healthcheck details.
* Understand why healthchecks are useful for container monitoring and orchestration.
