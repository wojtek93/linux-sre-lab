# Docker Lab 15 — Resource Limits

## Objective

Understand how Docker resource limits control CPU and memory usage.

The main goal of this lab was to apply CPU and memory limits to containers and observe what happens when a container reaches those limits.

---

## CPU and Memory Limits

Run nginx with both memory and CPU limits:

```bash
docker run -d \
  --name limited-nginx \
  --memory=128m \
  --cpus=0.5 \
  nginx:alpine
```

The memory limit:

```text
--memory=128m
```

means the container can use up to 128 MiB of RAM.

The CPU limit:

```text
--cpus=0.5
```

means the container can use up to approximately half of one CPU core.

---

## Monitor Resource Usage

Check current resource usage:

```bash
docker stats --no-stream limited-nginx
```

Example output:

```text
MEM USAGE / LIMIT
4.625MiB / 128MiB
```

The nginx container was using only a small amount of memory, while the configured maximum was 128 MiB.

---

## CPU Limit Test

Run a container that continuously consumes CPU:

```bash
docker run -d \
  --name cpu-test \
  --cpus=0.5 \
  alpine \
  sh -c 'while true; do :; done'
```

Check resource usage:

```bash
docker stats --no-stream cpu-test
```

The CPU usage reached approximately:

```text
50%
```

This confirms that Docker was actively limiting the container to approximately half of one CPU core.

Without the CPU limit, the busy loop could attempt to consume approximately 100% of one CPU core.

---

## Memory Limit Test

Run a Python container with a 50 MiB memory limit:

```bash
docker run -d \
  --name memory-test \
  --memory=50m \
  python:3.12-alpine \
  python -c 'a=[]; [a.append("x"*1024*1024) for _ in range(200)]'
```

The Python process attempts to allocate much more memory than the configured limit.

Check the container status:

```bash
docker ps -a --filter name=memory-test
```

The container exited with:

```text
Exited (137)
```

---

## OOM Kill

Inspect the container:

```bash
docker inspect memory-test
```

The container state showed:

```text
"OOMKilled": true
"ExitCode": 137
```

This means the process exceeded the configured memory limit and was killed because of an Out Of Memory condition.

The flow was:

```text
container memory limit = 50 MiB
          ↓
Python allocates more memory
          ↓
memory limit is reached
          ↓
process is killed
          ↓
OOMKilled = true
          ↓
ExitCode = 137
```

---

## Exit Code 137

Exit code:

```text
137
```

is commonly associated with a process terminated by `SIGKILL`.

```text
128 + 9 = 137
```

where signal 9 is:

```text
SIGKILL
```

In this lab, the process was killed after exceeding the container memory limit.

---

## Inspect Configured Limits

Inspect the resource configuration:

```bash
docker inspect limited-nginx | grep -E '"Memory"|"NanoCpus"'
```

The output showed:

```text
"Memory": 134217728
"NanoCpus": 500000000
```

Memory:

```text
134217728 bytes = 128 MiB
```

CPU:

```text
500000000 NanoCPUs = 0.5 CPU
```

This confirms that the limits were stored in the container configuration.

---

## Useful Commands

Run a container with a memory limit:

```bash
docker run --memory=128m IMAGE
```

Run a container with a CPU limit:

```bash
docker run --cpus=0.5 IMAGE
```

Use both limits:

```bash
docker run \
  --memory=128m \
  --cpus=0.5 \
  IMAGE
```

Monitor container resources:

```bash
docker stats
```

Single snapshot:

```bash
docker stats --no-stream
```

Inspect container configuration:

```bash
docker inspect CONTAINER
```

Check stopped containers:

```bash
docker ps -a
```

---

## Key Concepts

Docker uses Linux resource-control mechanisms to restrict how much CPU and memory a container can consume.

Without limits:

```text
container
   ↓
can compete for available host resources
```

With limits:

```text
container
   ↓
CPU limit
memory limit
   ↓
controlled resource usage
```

CPU limits throttle how much processing time a container can consume.

Memory limits define how much RAM a container may use.

If a process exceeds its memory limit, it may be terminated by the OOM mechanism.

---

## Why Resource Limits Matter

Resource limits help prevent one container from consuming excessive host resources.

Example:

```text
Host
├── application container
├── database container
├── monitoring container
└── other services
```

Without limits, one badly behaving container could consume large amounts of CPU or RAM and affect the other workloads.

Resource limits provide better isolation and predictable resource usage.

---

## What I Learned

- Docker containers can have CPU and memory limits
- `--memory` limits the amount of RAM available to a container
- `--cpus` limits the amount of CPU available to a container
- `docker stats` shows real-time CPU and memory usage
- CPU-intensive processes are throttled when they reach the configured CPU limit
- exceeding a memory limit can result in an OOM kill
- `OOMKilled: true` indicates that a process was killed because of memory pressure
- exit code `137` commonly indicates termination by `SIGKILL`
- `docker inspect` can be used to verify configured resource limits
- `Memory` is stored in bytes
- `NanoCpus` represents the configured CPU limit
- resource limits help protect the host and other containers from excessive resource consumption
