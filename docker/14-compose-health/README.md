# Docker Lab 14 — Compose Healthcheck

## Objective

Understand how Docker Compose healthchecks work and how one service can wait until another service is actually ready before starting.

The main goal of this lab was to compare:

- container running state
- service readiness
- healthcheck status
- dependency startup with `depends_on`

---

## Project Structure

```text
docker/14-compose-health/
├── compose.yaml
└── app/
    ├── Dockerfile
    ├── main.py
    └── requirements.txt
```

---

## Application

The application uses FastAPI and connects to PostgreSQL.

`requirements.txt`:

```text
fastapi
uvicorn
psycopg2-binary
```

`main.py`:

```python
from fastapi import FastAPI
import os
import psycopg2

app = FastAPI()

DB_HOST = os.getenv("DB_HOST", "db")
DB_NAME = os.getenv("DB_NAME", "appdb")
DB_USER = os.getenv("DB_USER", "appuser")
DB_PASSWORD = os.getenv("DB_PASSWORD", "apppass")


@app.get("/")
def root():
    return {"message": "Compose healthcheck lab"}


@app.get("/db")
def check_db():
    conn = psycopg2.connect(
        host=DB_HOST,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
    )

    conn.close()

    return {"database": "connected"}
```

---

## Dockerfile

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## Compose Configuration

```yaml
services:
  app:
    build: ./app
    ports:
      - "8000:8000"
    environment:
      DB_HOST: db
      DB_NAME: appdb
      DB_USER: appuser
      DB_PASSWORD: apppass
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: apppass
      POSTGRES_DB: appdb

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser -d appdb"]
      interval: 5s
      timeout: 3s
      retries: 5
```

---

## Healthcheck

The database healthcheck uses:

```bash
pg_isready -U appuser -d appdb
```

This checks whether PostgreSQL is ready to accept connections.

The healthcheck configuration:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U appuser -d appdb"]
  interval: 5s
  timeout: 3s
  retries: 5
```

means:

```text
interval: 5s
```

Run the healthcheck every 5 seconds.

```text
timeout: 3s
```

If the test takes longer than 3 seconds, consider the attempt failed.

```text
retries: 5
```

After repeated failed checks, the container can become unhealthy.

---

## Running vs Healthy

A running container does not necessarily mean the service is ready.

```text
running != ready
```

The database process may already exist while PostgreSQL is still initializing.

The healthcheck provides an additional readiness state:

```text
starting
   ↓
healthy
```

or:

```text
starting
   ↓
unhealthy
```

---

## depends_on with service_healthy

The application contains:

```yaml
depends_on:
  db:
    condition: service_healthy
```

This means the application waits until the database healthcheck succeeds.

Startup flow:

```text
db container starts
        ↓
PostgreSQL initializes
        ↓
healthcheck runs
        ↓
db becomes healthy
        ↓
app starts
```

This is different from only starting the database container first.

The application waits for the database to become ready.

---

## Start the Application

Build and start the project:

```bash
docker compose up -d --build
```

Check status:

```bash
docker compose ps
```

The database should eventually show:

```text
healthy
```

---

## Test the Application

Test the application:

```bash
curl http://localhost:8000/
```

Expected response:

```json
{"message":"Compose healthcheck lab"}
```

Test the database connection:

```bash
curl http://localhost:8000/db
```

Expected response:

```json
{"database":"connected"}
```

This confirms that:

```text
app
 |
 | connection to db:5432
 v
db
```

works correctly.

---

## Broken Healthcheck Test

To verify the behavior, the healthcheck was intentionally changed to:

```yaml
healthcheck:
  test: ["CMD-SHELL", "exit 1"]
  interval: 5s
  timeout: 3s
  retries: 3
```

`exit 1` always returns a failure status.

After starting the project:

```bash
docker compose down
docker compose up -d --build
```

the database eventually becomes:

```text
unhealthy
```

Because the application depends on:

```yaml
condition: service_healthy
```

the application cannot start normally while the database healthcheck is failing.

---

## Validate Compose Configuration

Compose configuration can be validated before starting containers:

```bash
docker compose config
```

This is useful for detecting YAML syntax and indentation errors.

---

## YAML Indentation

YAML depends on correct indentation.

In Vim, automatic indentation can be applied with:

```text
gg=G
```

Useful Vim settings:

```vim
:set shiftwidth=2
:set tabstop=2
:set expandtab
```

Then:

```text
gg=G
```

can be used to re-indent the file.

---

## Useful Commands

Build and start services:

```bash
docker compose up -d --build
```

Check service status:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs
```

View database logs:

```bash
docker compose logs db
```

Validate configuration:

```bash
docker compose config
```

Stop and remove the project:

```bash
docker compose down
```

---

## Key Concepts

Without a healthcheck:

```text
container started
      ↓
application assumes dependency is ready
```

With a healthcheck:

```text
container started
      ↓
healthcheck
      ↓
dependency ready
      ↓
healthy
      ↓
dependent service starts
```

Healthchecks allow Docker Compose to distinguish between:

```text
process running
```

and:

```text
service ready
```

---

## What I Learned

- a running container does not always mean the service is ready
- Docker healthchecks verify service readiness
- healthcheck status can be `starting`, `healthy`, or `unhealthy`
- `pg_isready` can be used to check PostgreSQL readiness
- `depends_on` can wait for a dependency to become healthy
- `condition: service_healthy` delays dependent service startup
- failing healthchecks can prevent dependent services from starting
- `docker compose ps` shows service health status
- `docker compose config` validates Compose configuration
- YAML indentation must be correct
- Vim `gg=G` can automatically re-indent a file
