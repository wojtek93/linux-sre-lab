# Docker Lab 02 – Container Lifecycle

## Objective

Learn how to run, manage, inspect and remove Docker containers using the Docker CLI.

---

## Commands

### Run a container

    docker run -d --name web -p 8080:80 nginx

Options:

    -d            run container in detached mode
    --name web    assign container name
    -p 8080:80    map host port 8080 to container port 80

---

## List Containers

Running containers:

    docker ps

All containers:

    docker ps -a

---

## Stop and Start Containers

Stop container:

    docker stop web

Start existing stopped container:

    docker start web

Restart container:

    docker restart web

---

## Container Logs

Display logs:

    docker logs web

Follow logs in real time:

    docker logs -f web

---

## Execute Commands Inside Container

Open shell inside running container:

    docker exec -it web /bin/sh

For images containing bash:

    docker exec -it web /bin/bash

Exit container shell:

    exit

---

## Inspect Container

Display detailed container information:

    docker inspect web

Display only container state:

    docker inspect web | jq '.[0].State'

Display image used by the container:

    docker inspect web | jq -r '.[0].Config.Image'

---

## Container Processes

Display processes running inside a container:

    docker top web

---

## Container Resource Usage

Display live CPU and memory usage:

    docker stats web

Display one snapshot:

    docker stats --no-stream web

---

## Remove Containers

Remove stopped container:

    docker rm web

Force remove running container:

    docker rm -f web

---

## Docker Images

List local images:

    docker images

Alternative:

    docker image ls

Pull image without running a container:

    docker pull nginx:alpine

Remove image:

    docker image rm nginx:alpine

---

## Port Mapping

Example:

    docker run -d --name web2 -p 8081:80 nginx:alpine

Traffic flow:

    Host port 8081
          |
          v
    Container port 80
          |
          v
        nginx

Check port mapping:

    docker port web2

---

## Container Lifecycle

    docker run
        |
        v
    Created + Running
        |
        v
    docker stop
        |
        v
    Exited
        |
        v
    docker start
        |
        v
    Running
        |
        v
    docker rm
        |
        v
    Removed

---

## Important Difference

    docker run    = create + start a new container

    docker start  = start an existing stopped container

---

## What I Learned

* Run containers in detached mode.
* Assign names to containers.
* Map host ports to container ports.
* List running and stopped containers.
* Stop, start and restart containers.
* Read and follow container logs.
* Execute commands inside running containers.
* Inspect container configuration and state.
* Display processes and resource usage.
* Remove containers.
* Pull and list Docker images.
* Understand the basic Docker container lifecycle.
