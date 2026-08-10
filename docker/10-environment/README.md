# Docker Lab 10 – Environment Variables

## Objective

Understand how to configure Docker containers using environment variables without rebuilding the Docker image.

---

## Lab Structure

    Dockerfile
    .dockerignore
    .env
    requirements.txt
    app/main.py

---

## Application

The FastAPI application reads configuration from environment variables.

The application uses:

    APP_ENV
    APP_VERSION
    API_URL

Example endpoint response:

    {
      "app_env": "production",
      "app_version": "2.0",
      "api_url": "https://api.example.local"
    }

---

## Application Code

The application reads environment variables using:

    os.getenv()

Example:

    os.getenv("APP_ENV", "development")

This means:

    use APP_ENV if it exists

otherwise:

    use "development"

---

## Dockerfile

    FROM python:3.12-slim

    WORKDIR /app

    COPY requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY app/ .

    EXPOSE 8000

    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

---

## Build Image

Build:

    docker build -t environment-lab:v1 .

The image itself does not contain environment-specific configuration.

The same image can be used in different environments.

---

## Run Without Environment Variables

Run:

    docker run -d \
      --name environment-v1 \
      -p 8097:8000 \
      environment-lab:v1

Test:

    curl http://localhost:8097/

Example response:

    {
      "app_env": "development",
      "app_version": "unknown",
      "api_url": "not-set"
    }

These values come from the defaults defined in the application.

---

## Environment File

Example `.env` file:

    APP_ENV=production
    APP_VERSION=1.0
    API_URL=https://api.example.local

The `.env` file stores runtime configuration.

---

## Run With --env-file

Run:

    docker run -d \
      --name environment-v2 \
      -p 8098:8000 \
      --env-file .env \
      environment-lab:v1

Test:

    curl http://localhost:8098/

Example response:

    {
      "app_env": "production",
      "app_version": "1.0",
      "api_url": "https://api.example.local"
    }

---

## Same Image, Different Configuration

Both containers use:

    environment-lab:v1

but receive different runtime configuration.

Example:

    environment-lab:v1
            |
            +-- environment-v1
            |       APP_ENV=development
            |
            +-- environment-v2
                    APP_ENV=production

This means the image does not need to be rebuilt when configuration changes.

---

## Pass Individual Environment Variable

A single environment variable can be passed using:

    -e

Example:

    docker run -d \
      --name environment-v3 \
      -p 8099:8000 \
      --env-file .env \
      -e APP_VERSION=2.0 \
      environment-lab:v1

---

## Environment Variable Override

The `.env` file contains:

    APP_VERSION=1.0

The command contains:

    -e APP_VERSION=2.0

The resulting value inside the container is:

    APP_VERSION=2.0

Command-line `-e` can therefore override a value loaded from `--env-file`.

---

## Environment Variable Priority

In this lab:

    .env
        |
        v
    APP_VERSION=1.0
        |
        | overridden by
        v
    -e APP_VERSION=2.0
        |
        v
    container receives APP_VERSION=2.0

---

## Check Environment Variables Inside Container

Display all variables:

    docker exec environment-v2 env

Filter application variables:

    docker exec environment-v2 env | grep APP_

Example:

    APP_ENV=production
    APP_VERSION=1.0

---

## Build-time vs Runtime Configuration

Docker image:

    application code
    dependencies
    runtime

Container:

    image
    +
    runtime environment variables

Simplified:

    IMAGE
      |
      v
    docker run
      |
      +-- environment variables
      +-- ports
      +-- container name
      |
      v
    CONTAINER

---

## .dockerignore

The `.env` file should not be included in the Docker build context.

Example `.dockerignore`:

    .env
    .git
    *.log
    __pycache__/

This prevents `.env` from being accidentally copied into the image.

---

## Why .env Should Not Be In The Image

Environment files may contain:

    passwords
    API keys
    database credentials
    tokens
    environment-specific configuration

These values should generally be supplied at runtime instead of being permanently stored in an image layer.

---

## COPY and Environment Files

A Dockerfile instruction such as:

    COPY . .

copies files from the build context into the image.

Without `.dockerignore`, a `.env` file inside the build context could therefore be copied into the image.

Using:

    .dockerignore

prevents this.

---

## COPY Syntax Reminder

    COPY SOURCE DESTINATION

Example:

    COPY . .

First dot:

    source = current build context

Second dot:

    destination = current WORKDIR inside the image

If:

    WORKDIR /app

then:

    COPY . .

means approximately:

    copy build context into /app

---

## Runtime Configuration Flow

    .env file
        |
        v
    docker run --env-file .env
        |
        v
    environment variables
        |
        v
    running container
        |
        v
    application reads variables with os.getenv()

---

## Important Commands

Build:

    docker build -t environment-lab:v1 .

Run without environment file:

    docker run -d \
      --name environment-v1 \
      -p 8097:8000 \
      environment-lab:v1

Run with environment file:

    docker run -d \
      --name environment-v2 \
      -p 8098:8000 \
      --env-file .env \
      environment-lab:v1

Override one value:

    docker run -d \
      --name environment-v3 \
      -p 8099:8000 \
      --env-file .env \
      -e APP_VERSION=2.0 \
      environment-lab:v1

Check variables:

    docker exec environment-v2 env

---

## Key Concepts

    environment variable
        = runtime configuration value

    -e
        = pass one environment variable

    --env-file
        = load multiple environment variables from a file

    .env
        = file containing environment configuration

    .dockerignore
        = prevent files from entering build context

---

## Important Rule

Prefer:

    build image once
    configure at runtime

instead of:

    rebuild image for every environment

Example:

    one image
       |
       +-- development container
       +-- staging container
       +-- production container

---

## What I Learned

* Pass environment variables to Docker containers.
* Use `-e` to define individual environment variables.
* Use `--env-file` to load configuration from a file.
* Override environment file values at runtime.
* Use the same Docker image with different configurations.
* Understand the difference between image configuration and container runtime configuration.
* Read environment variables inside a Python application.
* Understand default values with `os.getenv`.
* Prevent `.env` files from entering Docker build context.
* Use `.dockerignore` to protect sensitive configuration.
* Understand why secrets should not be baked into Docker images.
