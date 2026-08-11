# Docker Lab 12 — Networks

## Objective

Understand how Docker networking works and how containers communicate with each other using custom Docker networks.

The main goal of this lab was to verify how Docker DNS allows containers in the same network to communicate using container names instead of IP addresses.

---

## Create a Custom Network

Create a new Docker network:

```bash
docker network create app-network
```

List available networks:

```bash
docker network ls
```

The custom network should appear in the list:

```text
app-network
```

---

## Run Containers in the Same Network

Run an nginx container:

```bash
docker run -d \
  --name web1 \
  --network app-network \
  nginx:alpine
```

Run a second container using Alpine Linux:

```bash
docker run -d \
  --name client1 \
  --network app-network \
  alpine sleep 3600
```

The network now looks like this:

```text
app-network

client1 <-------> web1
                  nginx
```

Both containers are connected to the same Docker network.

---

## Container-to-Container Communication

From `client1`, connect to the nginx container using its container name:

```bash
docker exec client1 wget -qO- http://web1
```

Docker resolves the name:

```text
web1
```

to the internal IP address of the container.

The request reaches nginx without manually specifying an IP address.

This demonstrates Docker's internal DNS functionality on custom networks.

---

## Test a Container Outside the Network

Run another Alpine container without specifying `app-network`:

```bash
docker run -d \
  --name client2 \
  alpine sleep 3600
```

This container is connected to the default Docker bridge network.

Try to connect to `web1`:

```bash
docker exec client2 wget -qO- http://web1
```

The request fails:

```text
wget: bad address 'web1'
```

The reason is that `client2` and `web1` are not connected to the same custom network.

---

## Connect a Running Container to a Network

Connect `client2` to `app-network`:

```bash
docker network connect app-network client2
```

Try the request again:

```bash
docker exec client2 wget -qO- http://web1
```

This time the request works because both containers are now connected to `app-network`.

A running container can be connected to more than one Docker network.

---

## Inspect Container Networks

Inspect the container:

```bash
docker inspect client2
```

The network configuration can be found under:

```text
NetworkSettings
```

and:

```text
Networks
```

A container connected to multiple networks will have multiple network entries.

---

## Disconnect a Container from a Network

Disconnect `client2` from `app-network`:

```bash
docker network disconnect app-network client2
```

Try the request again:

```bash
docker exec client2 wget -qO- http://web1
```

The request fails again:

```text
wget: bad address 'web1'
```

This confirms that name-based communication depends on the containers sharing the same Docker network.

---

## Network Communication Flow

Containers in the same custom network:

```text
        app-network

client1 ----------> web1
                     nginx
```

Docker DNS resolves:

```text
web1 -> internal container IP
```

No manual IP address is required.

Containers in different networks:

```text
app-network          default bridge

web1                 client2
  X <-------------------
```

The container name cannot be resolved across unrelated networks.

---

## Useful Commands

Create a network:

```bash
docker network create app-network
```

List networks:

```bash
docker network ls
```

Run a container in a specific network:

```bash
docker run --network app-network IMAGE
```

Connect a running container:

```bash
docker network connect app-network CONTAINER
```

Disconnect a container:

```bash
docker network disconnect app-network CONTAINER
```

Inspect a container:

```bash
docker inspect CONTAINER
```

Inspect a network:

```bash
docker network inspect app-network
```

---

## Key Concepts

A Docker custom network provides communication between containers connected to that network.

Containers can communicate using names such as:

```text
web1
backend
database
```

instead of manually using IP addresses.

Example application architecture:

```text
frontend
   |
   v
backend
   |
   v
database
```

Containers can communicate using addresses such as:

```text
http://backend
database:5432
```

Docker resolves the container or service name to the correct internal IP address.

Container IP addresses may change, so names are more practical and reliable than hardcoded IP addresses.

---

## What I Learned

- Docker containers can communicate through Docker networks
- custom networks provide DNS-based name resolution
- containers in the same custom network can communicate using container names
- containers in different networks cannot automatically resolve each other's names
- a running container can be connected to an additional network
- a container can belong to more than one network
- `docker network connect` connects an existing container to a network
- `docker network disconnect` removes a container from a network
- Docker DNS removes the need to hardcode container IP addresses
- custom networks are commonly used for communication between application components such as frontend, backend and databases
