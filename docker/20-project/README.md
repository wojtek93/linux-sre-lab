# Docker Lab 20 — Production-Style Final Project

## Objective

Build a production-style containerized application that combines the main Docker concepts covered in previous labs.

The project includes:

- FastAPI application
- PostgreSQL database
- multi-stage Docker build
- non-root user
- Docker healthcheck
- Docker Compose
- service dependency management
- environment variables
- persistent named volume
- resource limits
- internal Docker networking
- vulnerability scanning with Trivy

---

## Project Structure

```text
docker/20-project/
├── compose.yaml
├── .env
├── .dockerignore
└── app/
    ├── Dockerfile
    ├── requirements.txt
    └── main.py
```

---

## Architecture

```text
                  HOST
                   |
                   | localhost:8000
                   |
                   v
        +----------------------+
        |      FastAPI App     |
        |                      |
        |  non-root appuser    |
        |  healthcheck         |
        |  CPU / RAM limits    |
        +----------+-----------+
                   |
                   | Docker network
                   | hostname: db
                   | port: 5432
                   v
        +----------------------+
        |      PostgreSQL      |
        |                      |
        |  healthcheck         |
        |  CPU / RAM limits    |
        +----------+-----------+
                   |
                   v
        +----------------------+
        | postgres-data volume |
        +----------------------+
```

Docker Compose automatically creates the internal network used by the services.

The application connects to PostgreSQL using:

```text
db:5432
```

instead of a hardcoded container IP address.

---

## Application Dependencies

`app/requirements.txt`:

```text
fastapi
uvicorn
psycopg2-binary
```

---

## FastAPI Application

`app/main.py`:

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
    return {
        "message": "Docker Final Project",
        "status": "running"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


@app.get("/db")
def database_check():
    conn = psycopg2.connect(
        host=DB_HOST,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )

    cursor = conn.cursor()
    cursor.execute("SELECT version();")
    version = cursor.fetchone()[0]

    cursor.close()
    conn.close()

    return {
        "database": "connected",
        "version": version
    }
```

The application provides three endpoints:

```text
/
```

Application status.

```text
/health
```

Healthcheck endpoint.

```text
/db
```

Tests the connection to PostgreSQL.

---

## Multi-Stage Dockerfile

`app/Dockerfile`:

```dockerfile
FROM python:3.12-slim AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install \
    --no-cache-dir \
    --prefix=/install \
    -r requirements.txt


FROM python:3.12-slim

WORKDIR /app

RUN useradd -m appuser

COPY --from=builder /install /usr/local
COPY main.py .

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## Multi-Stage Build

The Dockerfile uses two stages.

Builder stage:

```text
python:3.12-slim
      ↓
install Python dependencies
      ↓
/install
```

Runtime stage:

```text
python:3.12-slim
      ↓
copy installed dependencies
      ↓
copy application
      ↓
run application
```

The builder environment is not used as the final runtime container.

This separates dependency installation from the runtime image.

---

## Non-Root User

The Dockerfile creates:

```dockerfile
RUN useradd -m appuser
```

and switches to:

```dockerfile
USER appuser
```

The application therefore does not run as root.

This was verified with:

```bash
docker exec final-app-test id
```

The process ran as:

```text
appuser
```

instead of:

```text
root
```

---

## Application Healthcheck

The application healthcheck calls:

```text
http://localhost:8000/health
```

Dockerfile configuration:

```dockerfile
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1
```

The application eventually reaches:

```text
healthy
```

status.

---

## Environment Variables

`.env`:

```text
DB_HOST=db
DB_NAME=appdb
DB_USER=appuser
DB_PASSWORD=apppass

POSTGRES_DB=appdb
POSTGRES_USER=appuser
POSTGRES_PASSWORD=apppass
```

The application reads database configuration from environment variables.

The database hostname is:

```text
db
```

because Docker Compose provides service-name DNS.

---

## Docker Compose

`compose.yaml`:

```yaml
services:
  app:
    build: ./app
    ports:
      - "8000:8000"
    env_file:
      - .env
    depends_on:
      db:
        condition: service_healthy
    mem_limit: 256m
    cpus: 0.50

  db:
    image: postgres:16-alpine
    env_file:
      - .env
    volumes:
      - postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser -d appdb"]
      interval: 5s
      timeout: 3s
      retries: 5
    mem_limit: 512m
    cpus: 1.00

volumes:
  postgres-data:
```

---

## Validate Compose Configuration

Before starting the project:

```bash
docker compose config
```

This validates the YAML structure and resolved Compose configuration.

---

## Start the Project

Build and start all services:

```bash
docker compose up -d --build
```

Check status:

```bash
docker compose ps
```

Expected state:

```text
app   healthy
db    healthy
```

The application port is published as:

```text
0.0.0.0:8000->8000/tcp
```

---

## Service Dependency

The application depends on the database:

```yaml
depends_on:
  db:
    condition: service_healthy
```

Startup flow:

```text
PostgreSQL container starts
        ↓
PostgreSQL initializes
        ↓
database healthcheck runs
        ↓
db becomes healthy
        ↓
application starts
```

This prevents the application from starting before PostgreSQL is ready.

---

## PostgreSQL Healthcheck

The database uses:

```bash
pg_isready -U appuser -d appdb
```

Configuration:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U appuser -d appdb"]
  interval: 5s
  timeout: 3s
  retries: 5
```

A running database container is therefore distinguished from a database that is actually ready for connections.

---

## Docker Networking

Compose automatically creates a network for the project.

The application communicates with PostgreSQL using:

```text
db
```

as the hostname.

Communication flow:

```text
app
 |
 | db:5432
 v
db
```

No manual container IP address is required.

---

## Test the Application

Application endpoint:

```bash
curl http://localhost:8000/
```

Health endpoint:

```bash
curl http://localhost:8000/health
```

Database endpoint:

```bash
curl http://localhost:8000/db
```

The database endpoint successfully returned:

```text
database: connected
```

confirming communication between the application and PostgreSQL.

---

## Persistent Database Storage

PostgreSQL uses a named volume:

```yaml
volumes:
  - postgres-data:/var/lib/postgresql/data
```

The volume is declared as:

```yaml
volumes:
  postgres-data:
```

This keeps database files outside the writable layer of the container.

---

## Persistence Test

A test table was created:

```sql
CREATE TABLE test_data (
    id SERIAL PRIMARY KEY,
    message TEXT
);
```

A record was inserted:

```sql
INSERT INTO test_data (message)
VALUES ('Docker volume persistence works');
```

The data was verified:

```sql
SELECT * FROM test_data;
```

The Compose project was then removed:

```bash
docker compose down
```

The named volume remained.

After starting the project again:

```bash
docker compose up -d
```

the same record was still present.

This confirmed:

```text
database container removed
        ↓
named volume remains
        ↓
new database container starts
        ↓
existing data is reused
```

---

## Important Volume Behavior

Normal shutdown:

```bash
docker compose down
```

removes containers and the Compose network but preserves named volumes.

Using:

```bash
docker compose down -v
```

would also remove the project's named volumes and therefore delete the persisted database data.

---

## Resource Limits

The application is configured with:

```yaml
mem_limit: 256m
cpus: 0.50
```

The database is configured with:

```yaml
mem_limit: 512m
cpus: 1.00
```

This prevents services from consuming unlimited host resources.

Resource usage can be checked with:

```bash
docker stats --no-stream
```

The configured memory limits are visible in the output.

---

## Security Scan

The final application image was scanned using Trivy:

```bash
trivy image \
  --severity HIGH,CRITICAL \
  20-project-app:latest
```

The initial scan reported:

```text
Total: 23
HIGH: 19
CRITICAL: 4
```

The findings were associated with packages in the Debian-based runtime image.

The Python application packages displayed no HIGH or CRITICAL findings in the scan summary.

---

## Fixable Vulnerabilities

A second scan was performed using:

```bash
trivy image \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  20-project-app:latest
```

The result was:

```text
Vulnerabilities: 0
```

This means that none of the detected HIGH or CRITICAL findings currently had a fix available according to the Trivy vulnerability database at the time of the scan.

The security result can therefore be summarized as:

```text
23 HIGH / CRITICAL findings detected
        ↓
filter vulnerabilities without available fixes
        ↓
0 currently fixable HIGH / CRITICAL findings
```

These findings should continue to be monitored and the base image should be rebuilt regularly when fixes become available.

---

## Final Verification

The final project was verified with:

```bash
docker compose ps
```

and:

```bash
curl http://localhost:8000/
curl http://localhost:8000/health
curl http://localhost:8000/db
```

All tests passed.

The final state confirmed:

```text
application running
application healthy
database healthy
database connection working
persistent volume working
resource limits configured
non-root runtime configured
multi-stage build working
security scan completed
```

---

## Troubleshooting Performed

During the project, a port conflict occurred because another container was already using host port `8000`.

The error was similar to:

```text
Bind for 0.0.0.0:8000 failed: port is already allocated
```

The conflicting container was identified with:

```bash
docker ps
```

and removed:

```bash
docker rm -f final-app-test
```

The Compose project was then restarted.

Another important step was recreating the Compose environment after configuration changes:

```bash
docker compose down
docker compose up -d --build
```

This ensured that containers were recreated using the current Compose configuration.

---

## Useful Commands

Validate Compose configuration:

```bash
docker compose config
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

Application logs:

```bash
docker compose logs app
```

Database logs:

```bash
docker compose logs db
```

Stop and remove containers:

```bash
docker compose down
```

Remove containers and volumes:

```bash
docker compose down -v
```

Check volumes:

```bash
docker volume ls
```

Check resource usage:

```bash
docker stats --no-stream
```

Scan final image:

```bash
trivy image --severity HIGH,CRITICAL 20-project-app:latest
```

Show only currently fixable HIGH and CRITICAL findings:

```bash
trivy image \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  20-project-app:latest
```

---

## Complete Application Flow

```text
Dockerfile
    ↓
multi-stage build
    ↓
application image
    ↓
non-root appuser
    ↓
Docker Compose
    ↓
+-------------------------------+
|                               |
v                               v
FastAPI                       PostgreSQL
:8000                         :5432
|                               |
| healthcheck                   | healthcheck
|                               |
+---------- Docker network -----+
                                |
                                v
                        postgres-data volume
```

---

## Production-Style Concepts Used

This project combines:

```text
multi-stage builds
non-root containers
healthchecks
Docker Compose
service dependencies
environment variables
Docker DNS
named volumes
persistent storage
CPU limits
memory limits
security scanning
runtime troubleshooting
```

---

## What I Learned

- how to build a multi-stage Docker image
- how to separate builder and runtime stages
- how to run an application as a non-root user
- how Docker healthchecks verify application readiness
- how Docker Compose manages multiple services
- how `depends_on` with `service_healthy` controls startup order
- how containers communicate using service names
- how environment variables configure containerized applications
- how PostgreSQL data can be persisted using a named volume
- how data survives container recreation
- how `docker compose down` differs from `docker compose down -v`
- how to configure CPU and memory limits
- how to monitor resources with `docker stats`
- how to detect Docker port conflicts
- how to troubleshoot Compose services using `ps` and `logs`
- how Trivy scans a final Docker image
- how to distinguish all findings from currently fixable findings
- why base images should be regularly rebuilt and rescanned
- how multiple Docker concepts combine into one production-style application stack
