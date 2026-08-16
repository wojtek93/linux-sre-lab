# NET-07 — DNS Failure Drills

## Goal

Practice diagnosing DNS and application connectivity failures using a structured troubleshooting flow.

The focus of this lab is not memorizing commands.

The goal is to answer:

```text
What works?
What fails?
At which layer does the problem begin?
What should I test next?
```

---

## Core Troubleshooting Flow

Use this order:

```text
DNS
↓
IP
↓
Routing
↓
TCP port
↓
TLS / HTTP
↓
Application
```

Do not jump randomly between commands.

---

## Scenario 1 — IP Works but DNS Times Out

Example:

```bash
ping 8.8.8.8
```

works.

But:

```bash
dig app.internal
```

returns a timeout.

This means:

```text
basic IP connectivity works
but DNS is not returning an answer
```

Possible causes:

```text
local resolver problem
wrong nameserver
DNS server unavailable
firewall blocking DNS
routing problem to DNS server
UDP/53 filtering
```

Check:

```bash
cat /etc/resolv.conf
resolvectl status
```

Then test a specific resolver:

```bash
dig @8.8.8.8 example.com
```

---

## Scenario 2 — Default Resolver Fails but Specific Resolver Works

Example:

```bash
dig example.com
```

times out.

But:

```bash
dig @8.8.8.8 example.com
```

works.

This strongly suggests:

```text
local/default resolver problem
```

Possible areas:

```text
/etc/resolv.conf
systemd-resolved
local resolver configuration
```

Check:

```bash
cat /etc/resolv.conf
resolvectl status
systemctl status systemd-resolved
```

---

## Scenario 3 — Specific Resolver Also Times Out

Example:

```bash
dig example.com
```

times out.

And:

```bash
dig @8.8.8.8 example.com
```

also times out.

This is less likely to be only a local resolver problem.

Possible causes:

```text
firewall
routing
blocked UDP/53
network path issue
DNS server unreachable
```

---

## Scenario 4 — NXDOMAIN

Example:

```bash
dig app.internal
```

returns:

```text
NXDOMAIN
```

Meaning:

```text
DNS answered
but the requested name does not exist
```

Mental model:

```text
NXDOMAIN
→ no such DNS name
```

---

## Scenario 5 — SERVFAIL

Example:

```bash
dig app.internal
```

returns:

```text
SERVFAIL
```

Meaning:

```text
DNS received the query
but could not successfully resolve it
```

Possible causes:

```text
resolver problem
upstream DNS problem
authoritative DNS problem
DNSSEC issue
broken DNS zone
```

Mental model:

```text
SERVFAIL
→ DNS could not complete the lookup
```

---

## Scenario 6 — TIMEOUT

Example:

```bash
dig app.internal
```

returns a timeout.

Meaning:

```text
no DNS response was received
```

Possible causes:

```text
resolver unavailable
firewall
routing
port 53 filtering
network path issue
```

Mental model:

```text
TIMEOUT
→ DNS did not answer
```

---

## Failure Status Quick Reference

```text
NXDOMAIN
→ name does not exist

SERVFAIL
→ DNS could not resolve the query

TIMEOUT
→ no DNS response
```

---

## Scenario 7 — dig Fails but getent Works

Example:

```bash
dig app.internal
```

returns:

```text
NXDOMAIN
```

But:

```bash
getent hosts app.internal
```

returns:

```text
10.0.0.50 app.internal
```

This suggests that system name resolution is using another source.

Check:

```bash
cat /etc/hosts
```

Possible entry:

```text
10.0.0.50 app.internal
```

Also check:

```bash
grep '^hosts:' /etc/nsswitch.conf
```

Example:

```text
hosts: files dns
```

Meaning:

```text
check local files first
then DNS
```

---

## dig vs getent

```text
dig
→ asks DNS directly

getent hosts
→ uses system name resolution
```

System resolution may use:

```text
/etc/hosts
DNS
other NSS sources
```

---

## Scenario 8 — DNS Returns Old Address

Suppose a DNS record changes:

```text
10.0.0.10
→
10.0.0.20
```

but some clients still receive:

```text
10.0.0.10
```

Likely cause:

```text
DNS cache / TTL
```

Different resolvers may temporarily return different results.

Compare:

```bash
dig @8.8.8.8 app.example.com
dig @1.1.1.1 app.example.com
```

Mental model:

```text
record changed
but old TTL has not expired
→ cached answer may still be used
```

---

## Scenario 9 — DNS Works but Application Fails

Example:

```bash
dig app.example.com
```

returns the correct IP.

But:

```bash
curl https://app.example.com
```

fails.

Do not automatically blame DNS.

Continue through the stack:

```text
DNS
→ works

then check:
routing
TCP
TLS
HTTP
application
```

Useful commands:

```bash
ip route get <IP>
nc -vz <IP> 443
curl -v https://app.example.com
```

---

## Scenario 10 — TCP Port Timeout

Example:

```bash
dig app.example.com
```

works.

But:

```bash
nc -vz <IP> 443
```

times out.

This suggests:

```text
DNS is OK
TCP connection is not receiving a response
```

Possible causes:

```text
firewall
routing
ACL
security group
network path
```

---

## Scenario 11 — TLS Certificate Error

Example:

```bash
dig app.example.com
```

works.

```bash
nc -vz <IP> 443
```

works.

But:

```bash
curl -v https://app.example.com
```

returns:

```text
certificate verify failed
```

This points to:

```text
TLS / certificate problem
```

Possible causes:

```text
expired certificate
hostname mismatch
self-signed certificate
missing certificate chain
wrong certificate on proxy/load balancer
```

Useful command:

```bash
openssl s_client -connect app.example.com:443 -servername app.example.com
```

---

## Scenario 12 — 502 Bad Gateway

Example:

```text
DNS works
TCP/443 works
HTTP returns 502
```

Meaning:

```text
client reached reverse proxy / load balancer
but proxy could not get a valid response from backend
```

Possible causes:

```text
backend application down
wrong backend IP
wrong backend port
upstream connection refused
bad proxy configuration
backend healthcheck failure
```

Useful checks:

```bash
systemctl status nginx
nginx -t
ss -tulpn | grep :8080
curl http://127.0.0.1:8080
```

Mental model:

```text
502
→ proxy ↔ backend problem
```

---

## Scenario 13 — 504 Gateway Timeout

Example:

```text
DNS works
TCP/443 works
HTTP returns 504
```

Meaning:

```text
proxy waited for backend
but backend did not respond in time
```

Possible causes:

```text
slow backend
slow database
slow external API
resource saturation
connection pool problem
upstream timeout
```

Useful checks:

```bash
curl http://127.0.0.1:8080
top
iostat -xz 1
```

Also inspect:

```text
application logs
database metrics
dependency latency
```

Mental model:

```text
504
→ backend too slow / timeout
```

---

## Scenario 14 — 503 Service Unavailable

Example:

```text
HTTP returns 503
```

Meaning:

```text
service is temporarily unavailable
```

Possible causes:

```text
backend down
all instances unhealthy
maintenance
application overload
no healthy load balancer targets
readiness checks failing
```

Useful checks:

```bash
systemctl status <service>
ss -tulpn | grep :<port>
curl http://127.0.0.1:<port>
```

In Kubernetes:

```bash
kubectl get pods
kubectl get endpoints
kubectl describe pod <pod>
```

Mental model:

```text
503
→ service unavailable
```

---

## Scenario 15 — 404 Not Found

Example:

```text
HTTP returns 404
```

Meaning:

```text
server responded
but requested resource / endpoint does not exist
```

Possible causes:

```text
wrong URL
wrong API path
endpoint does not exist
reverse proxy routes request incorrectly
wrong application version
```

Mental model:

```text
404
→ server works, resource not found
```

---

## Scenario 16 — 500 Internal Server Error

Example:

```text
HTTP returns 500
```

Meaning:

```text
request reached application
but application failed internally
```

Possible causes:

```text
application exception
database problem
missing environment variable
bad configuration
dependency failure
bug after deployment
```

Check logs:

```bash
journalctl -u <service>
```

or application/container logs.

Mental model:

```text
500
→ application failed while processing request
```

---

## Authentication Codes

### 401 Unauthorized

Usually means:

```text
authentication is missing or invalid
```

Examples:

```text
missing token
expired token
invalid credentials
```

Mental model:

```text
401
→ who are you?
```

---

## 403 Forbidden

Usually means:

```text
identity is known
but permission is denied
```

Example:

```text
normal user tries to access /admin
```

Mental model:

```text
403
→ I know who you are, but you are not allowed
```

---

## HTTP Status Quick Reference

```text
404 → resource not found
500 → application error
502 → proxy/backend communication problem
503 → service unavailable
504 → backend timeout
401 → authentication problem
403 → authorization problem
```

Do not try to memorize everything at once.

Use the status code as a clue about where to investigate next.

---

## Full Troubleshooting Example

Suppose:

```bash
curl https://app.example.com
```

fails.

Use this flow:

```text
1. Can DNS resolve the name?

dig app.example.com

2. Does system name resolution agree?

getent hosts app.example.com

3. Which route will Linux use?

ip route get <IP>

4. Is TCP/443 reachable?

nc -vz <IP> 443

5. Does TLS/HTTP work?

curl -v https://app.example.com

6. What status code is returned?

404 / 500 / 502 / 503 / 504

7. Check the correct component

DNS
network
proxy
backend
database
dependency
```

---

## Practical Mental Model

Do not think:

```text
application does not work
→ start checking random things
```

Think:

```text
Can I resolve the hostname?
↓
Can I reach the IP?
↓
Can I reach the port?
↓
Does TLS work?
↓
Does HTTP respond?
↓
What does the status code tell me?
↓
Which backend/dependency should I inspect?
```

---

## Useful Commands

DNS:

```bash
dig example.com
dig @8.8.8.8 example.com
getent hosts example.com
```

Resolver:

```bash
cat /etc/resolv.conf
resolvectl status
```

Local name mapping:

```bash
cat /etc/hosts
grep '^hosts:' /etc/nsswitch.conf
```

Routing:

```bash
ip route get <IP>
```

TCP:

```bash
nc -vz <IP> <PORT>
```

HTTP/TLS:

```bash
curl -v https://example.com
```

Certificate:

```bash
openssl s_client -connect example.com:443 -servername example.com
```

Backend:

```bash
ss -tulpn
systemctl status <service>
journalctl -u <service>
```

---

## Quick Reference

```text
NXDOMAIN
→ name does not exist

SERVFAIL
→ DNS could not resolve

TIMEOUT
→ DNS did not answer
```

Application path:

```text
DNS
→ IP
→ routing
→ TCP
→ TLS
→ HTTP
→ application
```

HTTP clues:

```text
404 → resource missing
500 → application error
502 → bad gateway / backend communication
503 → service unavailable
504 → backend timeout
401 → authentication
403 → authorization
```

---

## Interview Mental Model

A strong answer is structured.

Instead of:

```text
I would check logs and firewall.
```

Use:

```text
First I would confirm whether the hostname resolves correctly.

Then I would check IP routing and TCP connectivity.

If TCP connectivity works, I would move to TLS and HTTP.

The HTTP status code would tell me whether the issue is in the application,
reverse proxy, backend availability, or response time.
```

The key principle:

```text
verify each layer
before moving to the next
```
