# Docker Lab 08 – Run as Non-root User

## Objective

Understand why containers should not run application processes as root and learn how to configure a Docker image to use a dedicated non-root user.

---

## Lab Structure

    Dockerfile
    requirements.txt
    app/main.py

---

## Application

The FastAPI application exposes:

    /

The endpoint returns information about the user running the application process.

Example:

    {
      "message": "Non-root Docker lab",
      "uid": 1000,
      "gid": 1000
    }

---

## Initial Dockerfile

The first version of the Dockerfile did not define a user:

    FROM python:3.12-slim

    WORKDIR /app

    COPY requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY app/ .

    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

Build:

    docker build -t nonroot-lab:v1 .

Run:

    docker run -d --name nonroot-v1 -p 8091:8000 nonroot-lab:v1

---

## Check Container User

Check the user inside the container:

    docker exec nonroot-v1 id

Initial result:

    uid=0(root) gid=0(root) groups=0(root)

This means the application process runs as root.

---

## UID and GID

Linux internally identifies users and groups using numeric IDs.

    UID = User ID

    GID = Group ID

Examples:

    root
        UID 0

    appuser
        UID 1000

The user name is a human-readable representation of the numeric UID.

---

## Create Non-root User

Create a dedicated application user:

    RUN useradd -m appuser

Switch the container to this user:

    USER appuser

Dockerfile:

    FROM python:3.12-slim

    WORKDIR /app

    COPY requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY app/ .

    RUN useradd -m appuser

    USER appuser

    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

---

## Build Non-root Image

Build version 2:

    docker build -t nonroot-lab:v2 .

Run container:

    docker run -d --name nonroot-v2 -p 8092:8000 nonroot-lab:v2

Check user:

    docker exec nonroot-v2 id

Result:

    uid=1000(appuser) gid=1000(appuser) groups=1000(appuser)

The container is now running as a non-root user.

---

## Test Application

Test endpoint:

    curl http://localhost:8092/

Example response:

    {
      "message": "Non-root Docker lab",
      "uid": 1000,
      "gid": 1000
    }

---

## Permission Test – /root

Try writing inside the root user's home directory:

    docker exec nonroot-v2 sh -c 'echo test > /root/test.txt'

Result:

    Permission denied

This confirms that `appuser` does not have root permissions.

---

## Permission Test – User Home

Write inside the application user's home directory:

    docker exec nonroot-v2 sh -c 'echo test > /home/appuser/test.txt'

Read the file:

    docker exec nonroot-v2 cat /home/appuser/test.txt

Result:

    test

The non-root user can write to directories where it has permissions.

---

## Permission Test – /app

Try writing to the application directory:

    docker exec nonroot-v2 sh -c 'echo hello > /app/test.txt'

Result:

    Permission denied

Inspect directory ownership:

    docker exec nonroot-v2 ls -ld /app

Example:

    drwxr-xr-x 1 root root ... /app

The `/app` directory belongs to:

    owner = root
    group = root

The `appuser` process can read files but cannot write to the directory.

---

## Fix Application Directory Ownership

Change ownership before switching users:

    RUN chown -R appuser:appuser /app

Updated Dockerfile:

    FROM python:3.12-slim

    WORKDIR /app

    COPY requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY app/ .

    RUN useradd -m appuser

    RUN chown -R appuser:appuser /app

    USER appuser

    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

---

## Build Version 3

Build:

    docker build -t nonroot-lab:v3 .

Run:

    docker run -d --name nonroot-v3 -p 8093:8000 nonroot-lab:v3

Test write access:

    docker exec nonroot-v3 sh -c 'echo hello > /app/test.txt'

The command should now succeed.

---

## USER Instruction

The Dockerfile instruction:

    USER appuser

defines which user should run following instructions and the default container process.

Most importantly, the final application process will run as:

    appuser

instead of:

    root

---

## File Ownership

Switching users with:

    USER appuser

does not automatically change ownership of files created earlier during the image build.

For example:

    COPY app/ .

normally copies files as root.

This is why ownership may need to be changed explicitly.

---

## Alternative COPY Syntax

Docker can also assign ownership while copying files:

    COPY --chown=appuser:appuser app/ .

This can avoid a separate:

    RUN chown ...

step in some Dockerfiles.

---

## Security Benefit

Running as non-root follows the principle of least privilege.

If the application is compromised, the process has fewer permissions inside the container.

Instead of:

    application
        |
        v
    root privileges

we prefer:

    application
        |
        v
    dedicated appuser
        |
        v
    limited permissions

---

## Important Concepts

    root
        = UID 0 and highest privileges

    UID
        = numeric user identifier

    GID
        = numeric group identifier

    USER
        = Dockerfile instruction defining runtime user

    chown
        = change file or directory ownership

    least privilege
        = give a process only the permissions it needs

---

## Useful Commands

Check container user:

    docker exec <container> id

Check directory ownership:

    docker exec <container> ls -ld /app

Test write permissions:

    docker exec <container> sh -c 'echo test > /path/file'

Build image:

    docker build -t nonroot-lab:v3 .

Run container:

    docker run -d --name nonroot-v3 -p 8093:8000 nonroot-lab:v3

---

## What I Learned

* Understand that Docker containers may run as root by default.
* Understand Linux UID and GID values.
* Check the effective user inside a running container.
* Create a dedicated application user in a Docker image.
* Use the Dockerfile `USER` instruction.
* Run application processes as non-root.
* Understand Linux file ownership inside containers.
* Diagnose permission denied errors.
* Use `chown` to grant application directory ownership.
* Understand that switching users does not automatically change existing file ownership.
* Use `COPY --chown` as an alternative ownership method.
* Understand why non-root containers improve security.
* Apply the principle of least privilege to containerized applications.
