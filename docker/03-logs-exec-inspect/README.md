# Docker Lab 03 – Logs, Exec and Inspect

## Objective

Troubleshoot running Docker containers using logs, process inspection, resource monitoring and container configuration.

---

## Lab Structure

    input/requests.txt
    output/
    scripts/debug.sh

---

## Run Debug Container

Run nginx container:

    docker run -d --name debug-web -p 8084:80 nginx:alpine

Check running containers:

    docker ps

---

## Generate Test Requests

Requests can be generated with curl:

    curl http://localhost:8084/
    curl http://localhost:8084/health
    curl http://localhost:8084/admin

A file with endpoints can also be used:

    while read endpoint; do
        curl "http://localhost:8084$endpoint"
    done < input/requests.txt

---

## Container Logs

Display container logs:

    docker logs debug-web

Display last 5 log lines:

    docker logs -n 5 debug-web

Alternative:

    docker logs --tail 5 debug-web

Display timestamps:

    docker logs -t debug-web

Display logs from the last 2 minutes:

    docker logs --since 2m debug-web

Follow logs in real time:

    docker logs -f debug-web

Combine options:

    docker logs -t -f --since 5m debug-web

---

## Execute Commands Inside Container

Open shell:

    docker exec -it debug-web /bin/sh

Display nginx configuration:

    cat /etc/nginx/nginx.conf

Run command without opening interactive shell:

    docker exec debug-web cat /etc/nginx/nginx.conf

---

## Container Processes

Display processes running inside container:

    docker top debug-web

---

## Resource Usage

Display live resource usage:

    docker stats debug-web

Display one snapshot:

    docker stats --no-stream debug-web

Important metrics include:

    CPU %
    Memory Usage
    Memory %
    Network I/O
    Block I/O
    PIDs

---

## Inspect Container

Display full container configuration:

    docker inspect debug-web

Display only container state:

    docker inspect debug-web | jq '.[0].State'

Display only current status:

    docker inspect debug-web | jq -r '.[0].State.Status'

Display main process PID:

    docker inspect debug-web | jq -r '.[0].State.Pid'

Display exit code:

    docker inspect debug-web | jq -r '.[0].State.ExitCode'

---

## Troubleshooting Scenario 1 – Container Stopped

If an application does not respond, first check whether the container is running:

    docker ps -a | grep debug-web

If the container status is:

    Exited

the container is stopped.

Check recent logs:

    docker logs -n 10 debug-web

Basic troubleshooting flow:

    container status
        |
        v
    logs
        |
        v
    identify failure

---

## Troubleshooting Scenario 2 – Wrong Port Mapping

Run a container with incorrect port mapping:

    docker run -d --name bad-port -p 8085:8080 nginx:alpine

Test connection:

    curl http://localhost:8085/

Check container status:

    docker ps -a | grep bad-port

Check port mapping:

    docker port bad-port

Example incorrect mapping:

    8080/tcp -> 0.0.0.0:8085

nginx listens on port:

    80

Correct mapping:

    host 8085 -> container 80

Fix:

    docker rm -f bad-port

    docker run -d --name bad-port -p 8085:80 nginx:alpine

Test:

    curl http://localhost:8085/

---

## Port Mapping Rule

Docker port syntax:

    -p HOST_PORT:CONTAINER_PORT

Example:

    -p 8085:80

means:

    host port 8085
          |
          v
    container port 80

Output from docker port may look like:

    80/tcp -> 0.0.0.0:8085

---

## Troubleshooting Scenario 3 – HTTP 404

Run container:

    docker run -d --name app404 -p 8086:80 nginx:alpine

Request missing endpoint:

    curl http://localhost:8086/admin

Check logs:

    docker logs app404

Example log:

    GET /admin HTTP/1.1

with HTTP status:

    404

nginx may also report:

    open() "/usr/share/nginx/html/admin" failed
    No such file or directory

Diagnosis:

    container running
          |
          v
    request reaches nginx
          |
          v
    endpoint does not exist
          |
          v
    HTTP 404

This means the problem is not Docker networking or container startup.

The requested resource simply does not exist.

---

## Basic Troubleshooting Workflow

When a containerized application does not work, check:

    1. Is the container running?

       docker ps -a

    2. What do the logs show?

       docker logs <container>

    3. Are ports mapped correctly?

       docker port <container>

    4. What processes are running?

       docker top <container>

    5. Is the container using excessive resources?

       docker stats --no-stream <container>

    6. What does the container configuration show?

       docker inspect <container>

    7. If necessary, inspect the container internally:

       docker exec -it <container> /bin/sh

---

## Key Commands

    docker logs
    docker logs -f
    docker logs --tail
    docker logs --since
    docker exec
    docker top
    docker stats
    docker inspect
    docker port
    docker ps -a

---

## What I Learned

* Read and follow Docker container logs.
* Filter logs using timestamps and time ranges.
* Execute commands inside running containers.
* Inspect processes running inside containers.
* Monitor container CPU and memory usage.
* Inspect container state using Docker inspect and jq.
* Diagnose stopped containers.
* Diagnose incorrect Docker port mappings.
* Diagnose HTTP 404 errors using container logs.
* Distinguish Docker infrastructure problems from application-level problems.
* Use a simple troubleshooting workflow for Docker containers.
