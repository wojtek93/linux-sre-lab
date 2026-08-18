# NET-16 Load Balancing with nginx

## Goal

Understand how load balancing works, how nginx distributes requests across multiple backend servers and how a load balancer can keep an application available when one backend becomes unavailable.

---

## What is load balancing?

Load balancing distributes incoming traffic across multiple backend servers.

Instead of sending every request to one application instance:

```text
client
↓
backend
```

a load balancer can distribute requests between several backends:

```text
client
↓
load balancer
├── backend1
└── backend2
```

This can improve:

```text
availability
scalability
traffic distribution
fault tolerance
```

---

## nginx as a load balancer

nginx can work as:

```text
web server
reverse proxy
load balancer
```

In this lab nginx acted as a load balancer.

Architecture:

```text
client
↓
nginx :80
↓
backend_pool
├── backend1 :9001
└── backend2 :9002
```

The client communicates only with nginx.

nginx decides which backend should receive each request.

---

## Prepare backend directories

Two directories were created:

```bash
mkdir backend1 backend2
```

Each backend received a different HTML response.

Backend 1:

```bash
echo "BACKEND 1" > backend1/index.html
```

Backend 2:

```bash
echo "BACKEND 2" > backend2/index.html
```

This makes it easy to identify which backend handled a request.

---

## Start backend 1

Command:

```bash
docker run -d \
  --name backend1 \
  -p 9001:80 \
  -v "$PWD/backend1:/usr/share/nginx/html:ro" \
  nginx
```

Port mapping:

```text
host:9001
↓
container:80
```

Backend 1 returned:

```text
BACKEND 1
```

---

## Start backend 2

Command:

```bash
docker run -d \
  --name backend2 \
  -p 9002:80 \
  -v "$PWD/backend2:/usr/share/nginx/html:ro" \
  nginx
```

Port mapping:

```text
host:9002
↓
container:80
```

Backend 2 returned:

```text
BACKEND 2
```

---

## Check containers

Command:

```bash
docker ps
```

The output showed:

```text
backend1 → 9001:80
backend2 → 9002:80
```

Both backend containers were running.

---

## Test backends directly

Backend 1:

```bash
curl http://127.0.0.1:9001
```

Result:

```text
BACKEND 1
```

Backend 2:

```bash
curl http://127.0.0.1:9002
```

Result:

```text
BACKEND 2
```

This confirmed that both applications were healthy before configuring the load balancer.

---

## Configure nginx upstream

The nginx configuration was edited:

```bash
sudo vi /etc/nginx/sites-available/default
```

An upstream group was created:

```nginx
upstream backend_pool {
    server 127.0.0.1:9001;
    server 127.0.0.1:9002;
}
```

The `upstream` block defines a group of backend servers.

---

## Important upstream placement

The `upstream` directive must be outside the `server` block.

Incorrect:

```nginx
server {
    upstream backend_pool {
        ...
    }
}
```

This produced:

```text
"upstream" directive is not allowed here
```

Correct structure:

```nginx
upstream backend_pool {
    server 127.0.0.1:9001;
    server 127.0.0.1:9002;
}

server {
    ...
}
```

---

## Configure proxy_pass

The nginx location was configured as:

```nginx
location / {
    proxy_pass http://backend_pool;
}
```

Instead of forwarding traffic to one backend:

```text
127.0.0.1:9000
```

nginx now forwards traffic to:

```text
backend_pool
```

---

## Complete nginx flow

```text
client
↓
nginx :80
↓
proxy_pass
↓
backend_pool
├── 127.0.0.1:9001
└── 127.0.0.1:9002
```

---

## Validate nginx configuration

Command:

```bash
sudo nginx -t
```

After correcting the upstream placement, the result was:

```text
syntax is ok
test is successful
```

Then nginx was reloaded:

```bash
sudo systemctl reload nginx
```

---

## Round-robin load balancing

nginx uses round-robin load balancing by default.

This means consecutive requests are distributed between available backend servers.

Example:

```text
request 1 → backend1
request 2 → backend2
request 3 → backend1
request 4 → backend2
```

---

## Test multiple requests

Command:

```bash
for i in {1..6}; do curl -s http://127.0.0.1; done
```

Result:

```text
BACKEND 1
BACKEND 2
BACKEND 1
BACKEND 2
BACKEND 1
BACKEND 2
```

This confirmed that nginx was distributing traffic between both backend servers.

---

## What is round-robin?

Round-robin distributes requests sequentially between available servers.

Example:

```text
request 1
↓
backend1

request 2
↓
backend2

request 3
↓
backend1

request 4
↓
backend2
```

This is nginx's default load balancing method.

---

## Backend failure test

Backend 1 was stopped:

```bash
docker stop backend1
```

Then the running containers were checked:

```bash
docker ps
```

Only backend 2 remained available.

---

## Test traffic after backend failure

Command:

```bash
for i in {1..6}; do curl -s http://127.0.0.1; done
```

Result:

```text
BACKEND 2
BACKEND 2
BACKEND 2
BACKEND 2
BACKEND 2
BACKEND 2
```

nginx continued serving requests using the remaining healthy backend.

---

## Why this matters

Without load balancing:

```text
client
↓
single backend
↓
backend failure
↓
application unavailable
```

With multiple backends:

```text
client
↓
nginx load balancer
├── backend1 DOWN
└── backend2 UP
        ↓
application still available
```

This improves service availability.

---

## Restore backend

Backend 1 was started again:

```bash
docker start backend1
```

Then:

```bash
docker ps
```

confirmed that both backends were running.

Traffic could again be distributed between both servers.

---

## Reverse proxy vs load balancer

Reverse proxy with one backend:

```text
client
↓
nginx
↓
backend
```

Load balancer with multiple backends:

```text
client
↓
nginx
├── backend1
└── backend2
```

A load balancer is therefore an extension of the reverse proxy concept.

---

## Why use multiple backends?

Multiple application instances can provide:

```text
higher availability
better scalability
traffic distribution
reduced load per server
fault tolerance
```

If traffic increases, more backend instances can be added.

Example:

```text
nginx
├── backend1
├── backend2
├── backend3
└── backend4
```

---

## Load balancing troubleshooting workflow

If requests are not distributed correctly:

```text
client problem
↓
check nginx
↓
check nginx configuration
↓
check upstream definition
↓
check backend ports
↓
test each backend directly
↓
check container status
↓
test through load balancer
```

---

## Test nginx

Check nginx:

```bash
sudo nginx -t
```

Check whether nginx is listening:

```bash
sudo ss -tlnp sport = :80
```

---

## Test backend 1

```bash
curl http://127.0.0.1:9001
```

Expected:

```text
BACKEND 1
```

---

## Test backend 2

```bash
curl http://127.0.0.1:9002
```

Expected:

```text
BACKEND 2
```

---

## Test complete load balancer

```bash
for i in {1..6}; do curl -s http://127.0.0.1; done
```

If both backends are healthy, responses should be distributed between them.

---

## Backend health troubleshooting

If only one response appears:

```text
BACKEND 2
BACKEND 2
BACKEND 2
```

check:

```bash
docker ps
```

Then test the missing backend directly:

```bash
curl http://127.0.0.1:9001
```

If it fails, the problem is likely with that backend rather than nginx itself.

---

## Key commands

```bash
mkdir backend1 backend2

echo "BACKEND 1" > backend1/index.html
echo "BACKEND 2" > backend2/index.html

docker run -d \
  --name backend1 \
  -p 9001:80 \
  -v "$PWD/backend1:/usr/share/nginx/html:ro" \
  nginx

docker run -d \
  --name backend2 \
  -p 9002:80 \
  -v "$PWD/backend2:/usr/share/nginx/html:ro" \
  nginx

docker ps

curl http://127.0.0.1:9001
curl http://127.0.0.1:9002

sudo vi /etc/nginx/sites-available/default

sudo nginx -t

sudo systemctl reload nginx

for i in {1..6}; do curl -s http://127.0.0.1; done

docker stop backend1

docker start backend1
```

---

## Key takeaways

```text
load balancing distributes traffic between multiple backend servers
nginx can work as a load balancer
upstream defines a group of backend servers
proxy_pass forwards requests to the upstream group
upstream must be outside the server block
nginx uses round-robin by default
round-robin distributes requests sequentially
multiple backends improve availability
if one backend fails, another backend can continue serving traffic
each backend should be tested directly during troubleshooting
```

Short interview answer:

```text
A load balancer distributes incoming requests between multiple backend servers.

In this lab I configured nginx with an upstream containing two backend
containers.

nginx used round-robin to distribute requests between them, and when one
backend was stopped, traffic continued through the remaining backend.

This improves availability and allows applications to scale horizontally.
```
