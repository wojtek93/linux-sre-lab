# NET-15 Reverse Proxy

## Goal

Understand what a reverse proxy is, how nginx can forward client requests to a backend application, and how to troubleshoot the connection between client, proxy and backend service.

---

## What is a reverse proxy?

A reverse proxy is a server that receives requests from clients and forwards them to backend services.

The client communicates with the reverse proxy instead of connecting directly to the backend application.

Example:

```text
client
↓
reverse proxy
↓
backend application
```

In this lab:

```text
client
↓
nginx :80
↓
Python HTTP server :9000
```

---

## Direct backend connection

A Python HTTP server was started on port 9000:

```bash
python3 -m http.server 9000
```

The backend was tested directly:

```bash
curl -I http://127.0.0.1:9000
```

The response showed:

```text
HTTP/1.0 200 OK
Server: SimpleHTTP/0.6 Python/3.14.4
```

This confirmed that the backend application was running correctly.

---

## Backend flow

Before configuring nginx, traffic looked like:

```text
curl
↓
127.0.0.1:9000
↓
Python HTTP server
```

The client had to know the backend port directly.

---

## Configure nginx reverse proxy

The nginx configuration was edited:

```bash
sudo nano /etc/nginx/sites-available/default
```

The main location block was configured as:

```nginx
location / {
    proxy_pass http://127.0.0.1:9000;
}
```

This tells nginx to forward requests to the backend running on port 9000.

---

## proxy_pass

The important directive is:

```nginx
proxy_pass http://127.0.0.1:9000;
```

Meaning:

```text
request arrives at nginx
↓
nginx forwards request
↓
127.0.0.1:9000
```

The client does not need to know that the backend uses port 9000.

---

## Nginx location block

Configuration:

```nginx
location / {
    proxy_pass http://127.0.0.1:9000;
}
```

`location /` matches requests to the root path and paths below it.

Example:

```text
/
```

or:

```text
/test
```

can be handled by this location block.

---

## More specific location blocks

The nginx configuration also contained:

```nginx
location /old {
    return 301 /new;
}
```

and:

```nginx
location /new {
    return 200 "new location\n";
}
```

These more specific locations can coexist with:

```nginx
location / {
    proxy_pass http://127.0.0.1:9000;
}
```

Nginx selects the matching location according to its location matching rules.

---

## Check nginx configuration

Before reloading nginx, the configuration was tested:

```bash
sudo nginx -t
```

The result showed:

```text
syntax is ok
test is successful
```

This confirms that nginx configuration syntax is valid.

---

## Reload nginx

After successful validation:

```bash
sudo systemctl reload nginx
```

Reload applies the new configuration without fully stopping the nginx service.

---

## Test reverse proxy

The client connected to nginx:

```bash
curl -I http://127.0.0.1
```

The request went to port 80.

Flow:

```text
curl
↓
127.0.0.1:80
↓
nginx
↓
proxy_pass
↓
127.0.0.1:9000
↓
Python HTTP server
```

The request was successfully handled through the reverse proxy.

---

## Response through nginx

The response showed:

```text
HTTP/1.1 200 OK
Server: nginx/1.28.3 (Ubuntu)
Content-Type: text/html; charset=utf-8
Content-Length: 299
```

Even though the backend was the Python HTTP server, the client communicated with nginx.

This is the key idea of a reverse proxy.

---

## Client does not know the backend

Without reverse proxy:

```text
client
↓
backend:9000
```

With reverse proxy:

```text
client
↓
nginx:80
↓
backend:9000
```

The backend port is hidden from the client.

The client only needs to know:

```text
nginx:80
```

---

## Why reverse proxies are useful

A reverse proxy can provide:

```text
single entry point
backend abstraction
TLS termination
load balancing
routing
authentication
caching
logging
security controls
```

The backend application does not have to be exposed directly to clients.

---

## Reverse proxy as a single entry point

Without a proxy:

```text
client
├── application A :9000
├── application B :9001
└── application C :9002
```

With nginx:

```text
client
↓
nginx :80 / :443
├── application A
├── application B
└── application C
```

Clients communicate with one frontend service.

---

## Reverse proxy vs port mapping

Docker port mapping:

```text
host:8080
↓
DNAT
↓
container:80
```

Reverse proxy:

```text
client
↓
nginx
↓
new application-level HTTP request
↓
backend
```

NAT works at the network/transport level.

A reverse proxy works at the application layer and understands HTTP.

---

## Reverse proxy vs forward proxy

Reverse proxy:

```text
client
↓
reverse proxy
↓
server/backend
```

The proxy represents the backend services.

Forward proxy:

```text
client
↓
forward proxy
↓
internet/server
```

The proxy represents the client.

Easy way to remember:

```text
forward proxy hides clients
reverse proxy hides servers
```

---

## Verify backend request

Verbose curl can be used:

```bash
curl -v http://127.0.0.1
```

The client connects to:

```text
127.0.0.1:80
```

The Python backend terminal also shows an incoming HTTP request.

This confirms that nginx forwarded the request to the backend.

---

## End-to-end request flow

Complete flow:

```text
client
↓
TCP connection to nginx:80
↓
HTTP request
↓
nginx
↓
proxy_pass
↓
TCP connection to backend:9000
↓
HTTP request to backend
↓
Python application
↓
HTTP response
↓
nginx
↓
client
```

---

## Backend failure

If the backend stops:

```text
Python server stopped
```

nginx may still be listening on port 80.

The client can reach nginx, but nginx cannot reach the backend.

Typical flow:

```text
client
↓
nginx works
↓
backend unavailable
↓
proxy error
```

This is important during troubleshooting because:

```text
frontend reachable
```

does not always mean:

```text
backend healthy
```

---

## Troubleshooting workflow

If a reverse-proxied application is not working:

```text
client cannot access application
↓
check nginx
↓
check nginx listening port
↓
check nginx configuration
↓
check backend service
↓
check backend listening port
↓
test backend directly
↓
test through nginx
```

Useful checks:

```bash
sudo ss -tlnp sport = :80
```

Check whether nginx is listening.

```bash
sudo ss -tlnp sport = :9000
```

Check whether backend is listening.

```bash
curl -I http://127.0.0.1:9000
```

Test backend directly.

```bash
curl -I http://127.0.0.1
```

Test through reverse proxy.

---

## Configuration troubleshooting

Check nginx syntax:

```bash
sudo nginx -t
```

If syntax is valid:

```text
syntax is ok
test is successful
```

Then reload:

```bash
sudo systemctl reload nginx
```

If configuration is invalid, do not reload until the error is fixed.

---

## Important troubleshooting distinction

Case 1:

```text
backend:9000 works
nginx:80 fails
```

Possible problem:

```text
nginx configuration
proxy configuration
nginx service
```

Case 2:

```text
nginx:80 reachable
backend:9000 unavailable
```

Possible problem:

```text
backend application
backend process
backend port
```

Case 3:

```text
both backend and nginx work
```

Result:

```text
reverse proxy path is healthy
```

---

## Key commands

```bash
python3 -m http.server 9000

curl -I http://127.0.0.1:9000

sudo nano /etc/nginx/sites-available/default

sudo nginx -t

sudo systemctl reload nginx

curl -I http://127.0.0.1

curl -v http://127.0.0.1

sudo ss -tlnp sport = :80

sudo ss -tlnp sport = :9000
```

---

## Key takeaways

```text
reverse proxy sits between client and backend
nginx can act as a reverse proxy
proxy_pass forwards requests to a backend
client does not need to know the backend port
nginx can provide a single entry point
reverse proxy works at the application layer
nginx configuration should be validated with nginx -t
backend should always be tested directly during troubleshooting
nginx can work while backend is unavailable
reverse proxy can hide backend infrastructure from clients
```

Short interview answer:

```text
A reverse proxy receives client requests and forwards them to backend services.

In this lab I configured nginx on port 80 to proxy requests to a Python backend
running on port 9000 using proxy_pass.

For troubleshooting, I test the backend directly first, then nginx separately,
and finally the complete request path through the reverse proxy.
```
