# HTTP Debugging Notes

## Basic request

```bash
curl http://127.0.0.1
```

Returns the response body.

---

## Headers only

```bash
curl -I http://127.0.0.1
```

Example:

```text
HTTP/1.1 200 OK
Server: nginx
Content-Type: text/html
Content-Length: 615
```

---

## 404 test

```bash
curl -I http://127.0.0.1/nie-ma-takiej-strony
```

Result:

```text
HTTP/1.1 404 Not Found
```

This means the server is reachable, but the requested resource does not exist.

---

## Verbose request

```bash
curl -v http://127.0.0.1
```

Important markers:

```text
> = request sent by the client
< = response returned by the server
```

Example request:

```text
> GET / HTTP/1.1
> Host: 127.0.0.1
> User-Agent: curl
```

Example response:

```text
< HTTP/1.1 200 OK
< Server: nginx
< Content-Type: text/html
```

---

## HTTP status only

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1
```

Meaning:

```text
-s = silent
-o /dev/null = discard response body
-w = write selected information
```

Example result:

```text
200
```

---

## Redirect test

```bash
curl -I http://127.0.0.1/old
```

Example:

```text
HTTP/1.1 301 Moved Permanently
Location: http://127.0.0.1/new
```

Follow the redirect:

```bash
curl -L http://127.0.0.1/old
```

---

## Test HTTP methods

GET:

```bash
curl -X GET http://127.0.0.1
```

POST:

```bash
curl -X POST http://127.0.0.1
```

Check only status codes:

```bash
curl -s -o /dev/null -w "%{http_code}\n" -X GET http://127.0.0.1
curl -s -o /dev/null -w "%{http_code}\n" -X POST http://127.0.0.1
```

Example:

```text
200
405
```

---

## Important status codes

```text
200 = OK
301 = Moved Permanently
302 = Temporary Redirect
404 = Not Found
405 = Method Not Allowed
```

---

## Basic troubleshooting flow

```text
curl request
↓
check HTTP status
↓
inspect headers
↓
use verbose mode if needed
↓
check redirect
↓
check HTTP method
```

Useful commands:

```bash
curl -I http://127.0.0.1
curl -v http://127.0.0.1
curl -L http://127.0.0.1/old
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1
```
