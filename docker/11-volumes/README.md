# Docker Lab 11 — Volumes and Bind Mounts

## Objective

Understand how Docker stores persistent data and compare named volumes with bind mounts.

The main goal of this lab was to verify what happens to data when a container is removed and how host files can be mounted directly into a container.

---

## Named Volume

Create a Docker volume:

```bash
docker volume create app-data
```

List volumes:

```bash
docker volume ls
```

Run an nginx container with the volume mounted:

```bash
docker run -d \
  --name volume-web \
  -v app-data:/usr/share/nginx/html \
  nginx:alpine
```

Create a file inside the mounted directory:

```bash
docker exec volume-web sh -c \
  'echo "Hello from Docker volume" > /usr/share/nginx/html/index.html'
```

Verify the file:

```bash
docker exec volume-web cat /usr/share/nginx/html/index.html
```

Remove the container:

```bash
docker rm -f volume-web
```

The container is removed, but the volume still exists.

Start a new container using the same volume:

```bash
docker run -d \
  --name volume-web2 \
  -v app-data:/usr/share/nginx/html \
  nginx:alpine
```

Verify that the file still exists:

```bash
docker exec volume-web2 cat /usr/share/nginx/html/index.html
```

The data survived because it was stored in the Docker volume, not only in the container filesystem.

---

## Bind Mount

Create a directory on the host:

```bash
mkdir -p host-data
```

Create a file:

```bash
echo "Hello from host bind mount" > host-data/index.html
```

Run nginx with the host directory mounted into the container:

```bash
docker run -d \
  --name bind-web \
  -v "$(pwd)/host-data:/usr/share/nginx/html" \
  nginx:alpine
```

Verify the file inside the container:

```bash
docker exec bind-web cat /usr/share/nginx/html/index.html
```

---

## Live Changes

Change the file on the host:

```bash
echo "changed on host" > host-data/index.html
```

Check the file inside the container:

```bash
docker exec bind-web cat /usr/share/nginx/html/index.html
```

The change is immediately visible inside the container.

Now change the file from inside the container:

```bash
docker exec bind-web sh -c \
  'echo "changed inside container" > /usr/share/nginx/html/index.html'
```

Check it on the host:

```bash
cat host-data/index.html
```

The change is also visible on the host.

A bind mount does not create a copy of the directory. The host directory is mounted directly into the container.

---

## Named Volume vs Bind Mount

### Named Volume

```bash
-v app-data:/data
```

Docker manages the storage location.

Typical use cases:

- persistent application data
- database data
- runtime data

### Bind Mount

```bash
-v "$(pwd)/host-data:/data"
```

A specific host directory is mounted into the container.

Typical use cases:

- development
- configuration files
- source code
- files edited directly on the host

---

## Inspect Mounts

Inspect the container using the named volume:

```bash
docker inspect volume-web2
```

In the `Mounts` section the mount type is:

```text
Type: volume
```

Inspect the bind mount container:

```bash
docker inspect bind-web
```

In the `Mounts` section the mount type is:

```text
Type: bind
```

---

## Key Concepts

Docker volume syntax:

```text
-v SOURCE:DESTINATION
```

The left side represents either:

- a Docker volume name
- a host filesystem path

The right side represents the path inside the container.

Named volume example:

```text
app-data:/usr/share/nginx/html
```

Bind mount example:

```text
/home/user/project/host-data:/usr/share/nginx/html
```

Named volume flow:

```text
container
   ↓
Docker volume
   ↓
container removed
   ↓
volume still exists
   ↓
new container
   ↓
same data
```

Bind mount flow:

```text
host directory
      ↕
container directory
```

---

## What I Learned

- container filesystem data is not suitable for persistent storage
- named volumes survive container removal
- Docker manages the physical location of named volumes
- bind mounts use a specific path from the host filesystem
- bind mount changes are visible immediately between host and container
- `-v` uses the format `SOURCE:DESTINATION`
- the left side is the volume name or host path
- the right side is the path inside the container
- named volumes are useful for persistent application data
- bind mounts are useful when files should be edited directly on the host
