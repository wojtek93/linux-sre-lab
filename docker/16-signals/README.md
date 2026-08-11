# Docker Lab 16 — Signals and Graceful Shutdown

## Objective

Understand how Docker sends signals to containers, how PID 1 behaves, and why graceful shutdown is important.

The main goal of this lab was to compare:

- proper SIGTERM handling
- graceful shutdown
- ignored SIGTERM
- forced SIGKILL
- exit code 137
- PID 1 behavior inside a container

---

## Project Structure

```text
docker/16-signals/
└── app/
    ├── Dockerfile
    └── main.py
```

---

## Graceful Shutdown Application

The first version of the application handles both `SIGTERM` and `SIGINT`.

`main.py`:

```python
import signal
import time
import sys

def shutdown(signum, frame):
    print(f"Received signal: {signum}")
    print("Graceful shutdown...")
    sys.exit(0)

signal.signal(signal.SIGTERM, shutdown)
signal.signal(signal.SIGINT, shutdown)

print("Application started")

while True:
    time.sleep(1)
```

---

## Dockerfile

```dockerfile
FROM python:3.12-alpine

WORKDIR /app

COPY main.py .

CMD ["python", "main.py"]
```

The exec-form `CMD` starts Python directly as the main process in the container.

---

## Build the Image

Build the first version:

```bash
docker build -t signals-lab:v1 ./app
```

Run the container:

```bash
docker run -d \
  --name signals-test \
  signals-lab:v1
```

---

## PID 1

Check the processes running inside the container:

```bash
docker top signals-test
```

The main process is:

```text
python main.py
```

Inside the container, this application is the main process and receives signals sent by Docker.

---

## Docker Stop

Stop the container:

```bash
docker stop signals-test
```

Check logs:

```bash
docker logs signals-test
```

Observed output:

```text
Application started
Received signal: 15
Graceful shutdown...
```

Signal number:

```text
15
```

is:

```text
SIGTERM
```

The flow is:

```text
docker stop
   ↓
Docker sends SIGTERM
   ↓
main process receives signal
   ↓
shutdown() handler runs
   ↓
application performs graceful shutdown
   ↓
sys.exit(0)
```

---

## Graceful Shutdown

Graceful shutdown means that an application receives a termination request and has time to cleanly stop before exiting.

Typical cleanup operations may include:

```text
finish current requests
close database connections
flush buffered data
close files
release resources
stop worker processes
```

In this lab, the application handled `SIGTERM` and exited cleanly.

---

## Ignoring SIGTERM

The second version intentionally ignores the termination request.

`main.py`:

```python
import signal
import time

def ignore_signal(signum, frame):
    print(f"Ignoring signal: {signum}")

signal.signal(signal.SIGTERM, ignore_signal)

print("Application started")

while True:
    time.sleep(1)
```

Build the second image:

```bash
docker build -t signals-lab:v2 ./app
```

Run it:

```bash
docker run -d \
  --name signals-test2 \
  signals-lab:v2
```

---

## Forced Shutdown

Stop the container with a short timeout:

```bash
docker stop -t 3 signals-test2
```

Docker first sends:

```text
SIGTERM
```

The application ignores it.

Docker waits 3 seconds.

After the timeout, Docker sends:

```text
SIGKILL
```

The flow is:

```text
docker stop -t 3
      ↓
SIGTERM
      ↓
application ignores signal
      ↓
Docker waits 3 seconds
      ↓
SIGKILL
      ↓
process is forcibly terminated
```

---

## Inspect Exit Status

Inspect the container:

```bash
docker inspect signals-test2 | grep -E '"ExitCode"|"OOMKilled"'
```

Observed result:

```text
"OOMKilled": false
"ExitCode": 137
```

The process exited with:

```text
137
```

because it was killed with `SIGKILL`.

---

## Exit Code 137

Exit code 137 can be calculated as:

```text
128 + 9 = 137
```

Signal number 9 is:

```text
SIGKILL
```

However, exit code 137 does not automatically mean an Out Of Memory event.

The `OOMKilled` field must also be checked.

In this lab:

```text
ExitCode = 137
OOMKilled = false
```

means:

```text
process was killed with SIGKILL
but not because of OOM
```

---

## Comparison with Resource Limits Lab

In the previous memory-limit test:

```text
ExitCode = 137
OOMKilled = true
```

This indicated an Out Of Memory kill.

In this signals lab:

```text
ExitCode = 137
OOMKilled = false
```

This indicated a forced `SIGKILL` after the process ignored `SIGTERM`.

---

## Graceful vs Forced Shutdown

Graceful shutdown:

```text
docker stop
   ↓
SIGTERM
   ↓
application handles signal
   ↓
cleanup
   ↓
exit 0
```

Forced shutdown:

```text
docker stop
   ↓
SIGTERM
   ↓
application ignores signal
   ↓
timeout
   ↓
SIGKILL
   ↓
exit 137
```

---

## SIGTERM vs SIGKILL

`SIGTERM`:

```text
signal 15
```

asks a process to terminate.

The application can catch the signal and perform cleanup.

`SIGKILL`:

```text
signal 9
```

immediately terminates the process.

The application cannot catch or ignore `SIGKILL`.

---

## Useful Commands

Build an image:

```bash
docker build -t signals-lab:v1 ./app
```

Run a container:

```bash
docker run -d --name signals-test signals-lab:v1
```

Check processes:

```bash
docker top signals-test
```

Check logs:

```bash
docker logs signals-test
```

Stop a container:

```bash
docker stop signals-test
```

Stop with a custom timeout:

```bash
docker stop -t 3 signals-test2
```

Inspect container state:

```bash
docker inspect signals-test2
```

Check exit code and OOM status:

```bash
docker inspect signals-test2 | grep -E '"ExitCode"|"OOMKilled"'
```

---

## Key Concepts

Docker sends termination signals to the main process inside a container.

A properly designed containerized application should handle `SIGTERM`.

The normal shutdown sequence is:

```text
SIGTERM
   ↓
application cleanup
   ↓
clean exit
```

If the application refuses to exit:

```text
SIGTERM
   ↓
timeout
   ↓
SIGKILL
```

A forced `SIGKILL` prevents the application from performing cleanup.

---

## Why Graceful Shutdown Matters

Graceful shutdown is important for production services.

Without proper shutdown handling, applications may:

```text
drop active requests
leave transactions incomplete
lose buffered data
leave temporary state behind
terminate workers unexpectedly
```

Container orchestrators such as Docker and Kubernetes rely heavily on applications responding correctly to termination signals.

---

## What I Learned

- Docker sends signals to the main process of a container
- the main container process has PID 1 inside the container
- `docker stop` sends `SIGTERM` first
- `SIGTERM` is signal 15
- applications can catch `SIGTERM` and perform cleanup
- graceful shutdown allows applications to exit cleanly
- `docker stop -t` controls how long Docker waits before forcing termination
- if the process does not exit, Docker sends `SIGKILL`
- `SIGKILL` is signal 9
- `SIGKILL` cannot be caught or ignored
- exit code 137 usually indicates termination by `SIGKILL`
- exit code 137 does not automatically mean an OOM event
- `OOMKilled: true` indicates an Out Of Memory kill
- `OOMKilled: false` with exit code 137 indicates another SIGKILL scenario
- signal handling is important for reliable containerized applications
