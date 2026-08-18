# NET-11 HTTP

## Goal

Understand how HTTP works, how clients communicate with web servers, how to inspect HTTP responses and how to troubleshoot HTTP services using `curl`.

---

## What is HTTP?

HTTP = Hypertext Transfer Protocol.

HTTP is an application layer protocol used for communication between clients and web servers.

Typical flow:

```text
client
↓
HTTP request
↓
web server
↓
HTTP response
```

Example:

```text
curl
↓
GET /
↓
nginx
↓
HTTP/1.1 200 OK
```

HTTP commonly uses:

```text
TCP/80
```

HTTPS commonly uses:

```text
TCP/443
```

---

## Basic HTTP request

Command:

```bash
curl http://127.0.0.1
```

This sends an HTTP request to the local web server.

In this lab, nginx returned its default HTML page.

Example:

```html
<h1>Welcome to nginx!</h1>
```

This confirms that:

```text
nginx is running
port 80 is reachable
HTTP request was processed
response body was returned
```

---

## Check HTTP headers

Command:

```bash
curl -I http://127.0.0.1
```

Option:

```text
-I = fetch response headers
```

Example response:

```text
HTTP/1.1 200 OK
Server: nginx/1.28.3 (Ubuntu)
Content-Type: text/html
Content-Length: 615
Connection: keep-alive
```

---

## HTTP status line

Example:

```text
HTTP/1.1 200 OK
```

This contains:

```text
HTTP/1.1 = HTTP protocol version
200      = status code
OK       = status description
```

Status:

```text
200 OK
```

means that the request was processed successfully.

---

## Important HTTP headers

Example:

```text
Server: nginx/1.28.3 (Ubuntu)
Content-Type: text/html
Content-Length: 615
Connection: keep-alive
```

`Server`:

```text
Server: nginx/1.28.3
```

shows which web server generated the response.

`Content-Type`:

```text
Content-Type: text/html
```

shows the type of returned content.

`Content-Length`:

```text
Content-Length: 615
```

shows the response body size in bytes.

`Connection`:

```text
Connection: keep-alive
```

means that the TCP connection may remain open and be reused.

---

## HTTP 404 Not Found

Request a resource that does not exist:

```bash
curl -I http://127.0.0.1/nie-ma-takiej-strony
```

Result:

```text
HTTP/1.1 404 Not Found
```

This means:

```text
web server is reachable
HTTP is working
requested resource does not exist
```

This is different from a network connection failure.

Example:

```text
server unreachable
```

and:

```text
HTTP 404
```

are two different problems.

With `404`, the server successfully received and processed the HTTP request.

---

## HTTP status codes

HTTP status codes are grouped into categories.

```text
1xx = informational
2xx = success
3xx = redirects
4xx = client errors
5xx = server errors
```

Examples:

```text
200 = OK
301 = Moved Permanently
302 = temporary redirect
404 = Not Found
405 = Method Not Allowed
500 = Internal Server Error
```

---

## Verbose HTTP request

Command:

```bash
curl -v http://127.0.0.1
```

Option:

```text
-v = verbose
```

Verbose mode shows additional connection and HTTP information.

Example:

```text
* Trying 127.0.0.1:80...
* Established connection to 127.0.0.1
```

This confirms that the TCP connection to port 80 was successfully created.

---

## HTTP request details

In verbose mode, lines beginning with:

```text
>
```

represent data sent by the client.

Example:

```text
> GET / HTTP/1.1
> Host: 127.0.0.1
> User-Agent: curl/8.18.0
> Accept: */*
```

This is the HTTP request.

---

## HTTP response details

Lines beginning with:

```text
<
```

represent data received from the server.

Example:

```text
< HTTP/1.1 200 OK
< Server: nginx/1.28.3 (Ubuntu)
< Content-Type: text/html
< Content-Length: 615
```

This is the HTTP response.

---

## HTTP request flow

Example:

```text
curl
↓
TCP connection to 127.0.0.1:80
↓
GET / HTTP/1.1
↓
nginx
↓
HTTP/1.1 200 OK
↓
HTML response body
```

HTTP uses an existing TCP connection to exchange request and response data.

---

## GET request

Example request:

```text
GET / HTTP/1.1
```

This means:

```text
GET      = HTTP method
/        = requested path
HTTP/1.1 = protocol version
```

`GET` is normally used to retrieve data from a server.

Example:

```bash
curl -X GET http://127.0.0.1
```

---

## Check only HTTP status code

Command:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1
```

Options:

```text
-s = silent
-o = output
-w = write-out
```

`-s`:

```text
do not show unnecessary curl output
```

`-o /dev/null`:

```text
discard the response body
```

`-w "%{http_code}\n"`:

```text
print only the HTTP status code
```

Example:

```text
200
```

Simple way to remember:

```text
silent
↓
discard body
↓
write status code
```

---

## HTTP redirect

A redirect tells the client to request another location.

In this lab, nginx was configured with:

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

Before reloading nginx, the configuration was checked with:

```bash
sudo nginx -t
```

Then nginx was reloaded:

```bash
sudo systemctl reload nginx
```

---

## HTTP 301 redirect

Command:

```bash
curl -I http://127.0.0.1/old
```

Result:

```text
HTTP/1.1 301 Moved Permanently
Location: http://127.0.0.1/new
```

This means:

```text
client requests /old
↓
server returns 301
↓
Location header points to /new
```

`301` means:

```text
permanent redirect
```

`302` usually means:

```text
temporary redirect
```

---

## Follow HTTP redirects

By default, curl does not automatically follow redirects in a normal request.

Use:

```bash
curl -L http://127.0.0.1/old
```

Option:

```text
-L = follow redirects
```

Flow:

```text
GET /old
↓
301 Moved Permanently
↓
Location: /new
↓
GET /new
↓
200 OK
```

Result:

```text
new location
```

---

## HTTP methods

Common HTTP methods include:

```text
GET
POST
PUT
PATCH
DELETE
HEAD
```

Typical usage:

```text
GET    = retrieve data
POST   = send or create data
PUT    = replace or update a resource
PATCH  = partially update a resource
DELETE = remove a resource
HEAD   = retrieve headers without response body
```

---

## Test GET method

Command:

```bash
curl -X GET http://127.0.0.1
```

In this lab, the request returned:

```text
200 OK
```

This means the server accepted the GET request.

---

## Test POST method

Command:

```bash
curl -X POST http://127.0.0.1
```

In this lab, nginx returned:

```text
HTTP/1.1 405 Not Allowed
```

This means:

```text
server is reachable
resource exists
requested HTTP method is not allowed
```

---

## 404 vs 405

`404`:

```text
resource was not found
```

`405`:

```text
resource exists
HTTP method is not allowed
```

Example:

```text
GET /nonexistent
↓
404 Not Found
```

Example:

```text
POST /
↓
405 Not Allowed
```

---

## Check status for different HTTP methods

GET:

```bash
curl -s -o /dev/null -w "%{http_code}\n" -X GET http://127.0.0.1
```

Result:

```text
200
```

POST:

```bash
curl -s -o /dev/null -w "%{http_code}\n" -X POST http://127.0.0.1
```

Result:

```text
405
```

This is useful in scripts and automated health checks.

---

## HEAD request

The `HEAD` method works similarly to GET but returns only headers.

Example:

```bash
curl -I http://127.0.0.1
```

Typical response:

```text
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 615
```

No HTML body is returned.

This is useful when only metadata or HTTP status is needed.

---

## HTTP troubleshooting workflow

If a web application is not working, start with:

```bash
curl -I http://127.0.0.1
```

Possible result:

```text
200 OK
```

means the server is responding successfully.

If you get:

```text
404 Not Found
```

the server works but the requested resource does not exist.

If you get:

```text
405 Not Allowed
```

the endpoint exists but the HTTP method is not accepted.

For more details:

```bash
curl -v http://127.0.0.1
```

This shows:

```text
connection attempt
TCP connection
HTTP request
HTTP response
headers
status
```

---

## Redirect troubleshooting

Check redirect without following it:

```bash
curl -I http://127.0.0.1/old
```

Look for:

```text
301
302
Location:
```

Follow redirects:

```bash
curl -L http://127.0.0.1/old
```

This helps identify redirect chains and final destinations.

---

## Basic troubleshooting flow

```text
application problem
↓
curl request
↓
check HTTP status
↓
inspect headers
↓
use curl -v
↓
check redirect
↓
check HTTP method
↓
identify application-level problem
```

HTTP troubleshooting should distinguish between:

```text
network problem
TCP connection problem
HTTP status problem
redirect problem
HTTP method problem
application problem
```

---

## Lab files

```text
11-http/
├── README.md
└── http-debugging.md
```

`README.md` contains the lab explanation and key concepts.

`http-debugging.md` contains practical HTTP troubleshooting commands and examples.

---

## Key troubleshooting commands

```bash
curl http://127.0.0.1
curl -I http://127.0.0.1
curl -I http://127.0.0.1/nie-ma-takiej-strony
curl -v http://127.0.0.1
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1
curl -I http://127.0.0.1/old
curl -L http://127.0.0.1/old
curl -X GET http://127.0.0.1
curl -X POST http://127.0.0.1
curl -s -o /dev/null -w "%{http_code}\n" -X GET http://127.0.0.1
curl -s -o /dev/null -w "%{http_code}\n" -X POST http://127.0.0.1
sudo nginx -t
sudo systemctl reload nginx
```

---

## Key takeaways

```text
HTTP is an application layer protocol
HTTP commonly uses TCP port 80
curl can test HTTP endpoints
curl -I shows response headers
curl -v shows detailed request and response information
> represents the HTTP request
< represents the HTTP response
200 = request successful
301 = permanent redirect
404 = resource not found
405 = HTTP method not allowed
-L follows redirects
-X selects an HTTP method
-s -o /dev/null -w can return only the HTTP status code
HTTP errors do not always mean a network problem
```

Short interview answer:

```text
I use curl to troubleshoot HTTP services.

I normally start with curl -I to inspect the status code and response headers,
then use curl -v when I need to see the connection, request and response details.

I also check redirects with curl -L and test specific HTTP methods when needed.
```
