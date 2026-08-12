# Docker Lab 19 — Broken Image Troubleshooting

## Objective

Practice troubleshooting broken Docker images and containers by identifying common runtime problems and fixing them systematically.

The main goal of this lab was to diagnose several typical failures:

- incorrect `CMD`
- missing application file
- missing Python dependency
- incorrect port mapping

---

## Project Structure

```text
docker/19-broken-image/
└── app/
    ├── Dockerfile
    ├── main.py
    └── requirements.txt
```

---

## Case 1 — Incorrect CMD

The first image contained:

```dockerfile
FROM python:3.12-alpine

WORKDIR /app

COPY main.py .

CMD ["python", "missing.py"]
```

The image built successfully:

```bash
docker build -t broken-image:v1 ./app
```

But the container failed at runtime:

```bash
docker run --name broken-test broken-image:v1
```

The error was:

```text
python: can't open file '/app/missing.py': [Errno 2] No such file or directory
```

---

## Troubleshooting with Logs

Check the stopped container:

```bash
docker ps -a --filter name=broken-test
```

Check logs:

```bash
docker logs broken-test
```

The logs showed that Python was trying to execute:

```text
/app/missing.py
```

but that file did not exist.

---

## Inspect Image Contents

Start a temporary shell inside the image:

```bash
docker run --rm -it broken-image:v1 sh
```

Check the application directory:

```bash
ls -la /app
```

The image contained:

```text
main.py
```

but not:

```text
missing.py
```

Exit the temporary container:

```bash
exit
```

The `--rm` option removes the temporary container automatically after it exits.

It does not remove the image.

---

## Fix the CMD

The Dockerfile was corrected:

```dockerfile
FROM python:3.12-alpine

WORKDIR /app

COPY main.py .

CMD ["python", "main.py"]
```

Build the corrected version:

```bash
docker build -t broken-image:v2 ./app
```

Run it:

```bash
docker run --name fixed-test broken-image:v2
```

The application started successfully:

```text
Application started
```

---

## Exit Code 0

The application only printed a message and then finished.

Therefore the container stopped with:

```text
Exited (0)
```

This is a successful process exit.

The important distinction is:

```text
Exited (0)
= process completed successfully
```

while:

```text
Exited (non-zero)
= process returned an error
```

---

## Case 2 — Missing Dependency

The application was changed to use the Python `requests` library:

```python
import requests

print("Application started")
print(requests.get("https://example.com").status_code)
```

The Dockerfile did not install `requests`:

```dockerfile
FROM python:3.12-alpine

WORKDIR /app

COPY main.py .

CMD ["python", "main.py"]
```

Build:

```bash
docker build -t broken-image:v3 ./app
```

Run:

```bash
docker run --name broken-dependency broken-image:v3
```

The application failed with an error similar to:

```text
ModuleNotFoundError: No module named 'requests'
```

---

## Why Installing Dependencies in docker run Is Not the Fix

A dependency could technically be installed at runtime:

```bash
docker run broken-image:v3 \
  sh -c "pip install requests && python main.py"
```

However, this is not a good image design.

Every new container would have to install the dependency again.

The image itself should already contain everything required to run the application.

---

## Correct Dependency Fix

Create:

```text
requirements.txt
```

with:

```text
requests
```

Update the Dockerfile:

```dockerfile
FROM python:3.12-alpine

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

CMD ["python", "main.py"]
```

Build the corrected image:

```bash
docker build -t broken-image:v4 ./app
```

Run it:

```bash
docker run --rm broken-image:v4
```

The dependency is now part of the image.

---

## Case 3 — Incorrect Port Mapping

The application was changed to start an HTTP server on port `8000`:

```python
from http.server import HTTPServer, SimpleHTTPRequestHandler

server = HTTPServer(("0.0.0.0", 8000), SimpleHTTPRequestHandler)

print("Server started on port 8000")
server.serve_forever()
```

Build:

```bash
docker build -t broken-image:v5 ./app
```

The container was intentionally started with the wrong port mapping:

```bash
docker run -d \
  --name wrong-port \
  -p 8080:9000 \
  broken-image:v5
```

Test:

```bash
curl http://localhost:8080
```

The request failed.

---

## Why the Port Mapping Was Wrong

The application listens inside the container on:

```text
8000
```

but Docker was configured with:

```text
8080:9000
```

The mapping was:

```text
HOST 8080
   ↓
CONTAINER 9000
```

but no application was listening on container port `9000`.

The application was listening on:

```text
CONTAINER 8000
```

---

## Fix the Port Mapping

Remove the broken container:

```bash
docker rm -f wrong-port
```

Run the image with the correct mapping:

```bash
docker run -d \
  --name correct-port \
  -p 8080:8000 \
  broken-image:v5
```

Test:

```bash
curl http://localhost:8080
```

The request now reaches the application.

---

## Port Mapping Rule

Docker port mapping uses:

```text
-p HOST_PORT:CONTAINER_PORT
```

Example:

```text
-p 8080:8000
```

means:

```text
host port 8080
      ↓
container port 8000
```

The container port must match the port where the application is actually listening.

---

## Troubleshooting Workflow

A useful troubleshooting workflow is:

```text
container does not work
        ↓
docker ps -a
        ↓
docker logs
        ↓
check exit status
        ↓
inspect configuration
        ↓
inspect image / filesystem if needed
        ↓
identify root cause
        ↓
fix Dockerfile or runtime configuration
        ↓
docker build
        ↓
docker run
        ↓
test again
```

---

## Useful Commands

List running containers:

```bash
docker ps
```

List all containers:

```bash
docker ps -a
```

Filter by container name:

```bash
docker ps -a --filter name=CONTAINER
```

Check logs:

```bash
docker logs CONTAINER
```

Inspect a container:

```bash
docker inspect CONTAINER
```

Start a temporary debugging shell:

```bash
docker run --rm -it IMAGE sh
```

Build an image:

```bash
docker build -t IMAGE:TAG .
```

Remove a container:

```bash
docker rm CONTAINER
```

Force-remove a running container:

```bash
docker rm -f CONTAINER
```

---

## Key Concepts

An image can build successfully and still fail when the container starts.

Build-time success does not guarantee runtime correctness.

Typical runtime failures include:

```text
wrong startup command
missing files
missing dependencies
wrong environment variables
wrong port mappings
permission problems
network problems
```

Logs are usually one of the first places to look when a container exits unexpectedly.

---

## Build-Time vs Runtime Problems

Build-time problem:

```text
docker build
   ↓
fails
```

Example:

```text
COPY source file does not exist
```

Runtime problem:

```text
docker build succeeds
   ↓
docker run
   ↓
container fails
```

Examples from this lab:

```text
wrong CMD
missing dependency
wrong port mapping
```

---

## Root Cause vs Workaround

A good fix should correct the image or configuration.

Example:

```text
missing Python package
```

Workaround:

```text
install package every time the container starts
```

Proper fix:

```text
install dependency during docker build
```

The goal is to create a reproducible image that contains everything required at runtime.

---

## What I Learned

- Docker images can build successfully but still fail at runtime
- `docker ps -a` helps identify containers that exited
- `docker logs` is one of the first troubleshooting tools to use
- incorrect `CMD` can cause immediate container failure
- image contents can be inspected using a temporary shell
- `--rm` automatically removes temporary containers
- `--rm` does not remove Docker images
- exit code `0` means the process completed successfully
- non-zero exit codes indicate process failure
- application dependencies should be installed during image build
- runtime dependency installation is not a good replacement for a correct Dockerfile
- `requirements.txt` makes Python dependencies reproducible
- port mapping uses `HOST:CONTAINER`
- the container port must match the port used by the application
- troubleshooting should focus on identifying the root cause instead of applying temporary workarounds
- a systematic workflow makes Docker troubleshooting faster and more reliable
