# Docker Lab 13 — Docker Compose

## Objective

Understand how Docker Compose manages multi-container applications using a single configuration file.

The main goal of this lab was to run multiple services together, understand how Compose creates networking automatically, and build a custom application directly from a Dockerfile.

---

## Project Structure

```text
docker/13-compose/
├── compose.yaml
└── app/
    ├── Dockerfile
    ├── main.py
    └── requirements.txt
```

---

## Basic Compose Configuration

Example Compose file with nginx and PostgreSQL:

```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: apppass
      POSTGRES_DB: appdb
```

Start all services:

```bash
docker compose up -d
```

Check running services:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs
```

View logs for a specific service:

```bash
docker compose logs db
```

---

## Compose Networking

Docker Compose automatically creates a private network for the project.

List Docker networks:

```bash
docker network ls
```

A network with a name similar to this should appear:

```text
13-compose_default
```

Services defined in the same Compose project can communicate using their service names.

Example:

```text
web <-------> db
```

The `web` service can resolve the hostname:

```text
db
```

without using the database container IP address.

---

## Stop vs Down

Stop Compose containers:

```bash
docker compose stop
```

This stops the containers but does not remove them.

Start them again:

```bash
docker compose start
```

Remove the Compose application:

```bash
docker compose down
```

This stops and removes containers and the Compose network.

Named volumes are not removed automatically.

To remove volumes as well:

```bash
docker compose down -v
```

---

## Custom Application

Instead of using only prebuilt images, Compose can build a custom application from a Dockerfile.

Application dependencies:

```text
fastapi
uvicorn
```

Application:

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Hello from Docker Compose"}
```

Dockerfile:

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## Build Application with Compose

The Compose configuration was changed to:

```yaml
services:
  app:
    build: ./app
    ports:
      - "8000:8000"

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: apppass
      POSTGRES_DB: appdb
```

The important part is:

```yaml
build: ./app
```

This tells Compose to build an image using the Dockerfile located in the `app` directory.

Build and start the application:

```bash
docker compose up -d --build
```

Check services:

```bash
docker compose ps
```

Test the application:

```bash
curl http://localhost:8000
```

Expected response:

```json
{"message":"Hello from Docker Compose"}
```

---

## `up` vs `up --build`

Start services:

```bash
docker compose up -d
```

Build images and then start services:

```bash
docker compose up -d --build
```

`--build` is useful when the application image needs to be rebuilt after changes to:

```text
Dockerfile
requirements.txt
application code
```

---

## Service Name DNS

Compose services communicate through the internal Docker network using service names.

The database service is called:

```yaml
db:
```

Therefore the hostname of the database inside the Compose network is:

```text
db
```

Check name resolution from the application container:

```bash
docker compose exec app python -c "import socket; print(socket.gethostbyname('db'))"
```

Docker DNS resolves `db` to the internal IP address of the database container.

---

## localhost vs Service Name

Inside the `app` container:

```text
localhost
```

means:

```text
the app container itself
```

It does not mean the database container.

To connect from `app` to PostgreSQL, use:

```text
db:5432
```

instead of:

```text
localhost:5432
```

Example database connection string:

```text
postgresql://appuser:apppass@db:5432/appdb
```

Communication flow:

```text
app
 |
 | hostname: db
 v
db
 |
 | PostgreSQL
 v
5432
```

---

## Useful Commands

Start services:

```bash
docker compose up -d
```

Build and start:

```bash
docker compose up -d --build
```

Check services:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs
```

View logs for one service:

```bash
docker compose logs SERVICE
```

Execute a command inside a service:

```bash
docker compose exec SERVICE COMMAND
```

Stop services:

```bash
docker compose stop
```

Start stopped services:

```bash
docker compose start
```

Remove the Compose application:

```bash
docker compose down
```

Remove the application and volumes:

```bash
docker compose down -v
```

---

## Key Concepts

Docker Compose allows multiple containers to be described in one YAML file.

Instead of manually running commands such as:

```text
docker run ...
docker network create ...
docker run ...
docker run ...
```

Compose manages the application as one project.

A Compose application can contain services such as:

```text
frontend
backend
database
redis
nginx
```

Compose can:

```text
build images
start containers
create networks
publish ports
configure environment variables
manage service relationships
stop the entire application
remove the entire application
```

---

## What I Learned

- Docker Compose manages multi-container applications
- services are defined in `compose.yaml`
- `docker compose up -d` starts the application
- `docker compose up -d --build` rebuilds images before starting
- Compose can use existing images or build custom images from Dockerfiles
- Compose automatically creates a shared network
- services can communicate using service names
- Docker DNS resolves service names to container IP addresses
- `localhost` inside a container refers to that same container
- another Compose service should be accessed by its service name
- `docker compose stop` stops containers without removing them
- `docker compose start` starts stopped containers again
- `docker compose down` stops and removes the Compose application
- `docker compose down -v` also removes volumes
