# MOT-19 — Application Unreachable Troubleshooting

## Goal

Build a structured troubleshooting flow for an application that cannot be reached over the network.

Main areas:

- DNS / name resolution
- routing
- host reachability
- listening ports
- bind address
- firewall
- application response
- service logs

---

## Troubleshooting Flow

```text
DNS
↓
Routing
↓
Reachability
↓
Listener
↓
Firewall
↓
Application response
↓
Logs
```

The exact order may depend on the symptoms, but the important point is to troubleshoot layer by layer.

---

## 1. Check Name Resolution

```bash
getent hosts app.example.com
```

This verifies whether the hostname resolves to an IP address.

Example:

```text
192.168.1.20 app.example.com
```

If name resolution fails, investigate:

- DNS
- `/etc/hosts`
- resolver configuration

Interview answer:

> I would first verify whether the hostname resolves to the expected IP address.

---

## 2. Check Routing

```bash
ip route
```

or for a specific destination:

```bash
ip route get 192.168.1.20
```

This shows:

- selected gateway
- outgoing interface
- source IP
- route used by Linux

Example:

```text
192.168.1.20 via 192.168.64.1 dev enp0s1 src 192.168.64.2
```

---

## 3. Check Reachability

Example:

```bash
ping -c 3 192.168.1.20
```

Ping can help verify basic IP reachability.

However, failed ping does not always mean the host is down because ICMP may be blocked.

---

## 4. Check Listening Ports

```bash
ss -lntp
```

or:

```bash
ss -lntp | grep 8080
```

Example:

```text
0.0.0.0:8080
```

means the service listens on all IPv4 interfaces.

Example:

```text
127.0.0.1:8080
```

means the service listens only on localhost.

---

## Bind Address Problem

A common situation:

```text
curl localhost works
curl server-IP fails
```

Check:

```bash
ss -lntp
```

If the service listens only on:

```text
127.0.0.1:8080
```

it will not accept connections through the server's network interface.

If appropriate, the application may need to listen on:

```text
0.0.0.0:8080
```

or on the expected interface IP.

Interview answer:

> If localhost works but the server IP does not, I would check the listening address. The application may be bound only to 127.0.0.1.

---

## Connection Refused

Example:

```bash
curl http://server:8080
```

returns:

```text
Connection refused
```

This commonly means:

- host is reachable
- no service is listening on the destination port

or the connection is being actively rejected.

Check:

```bash
ss -lntp | grep 8080
```

Interview answer:

> Connection refused usually means the host is reachable but no service is listening on the requested port, or the connection is actively rejected.

---

## Timeout

A timeout can indicate a different class of problem:

```text
routing problem
firewall dropping traffic
host unreachable
network path problem
```

Mental model:

```text
connection refused
→ host responds, but port/service problem

timeout
→ traffic may be dropped or cannot reach destination
```

---

## 5. Test the Application

Use:

```bash
curl -v http://server:8080
```

`-v` gives additional information about:

- connection attempt
- resolved IP
- TCP connection
- HTTP request
- HTTP response

---

## 6. Check Firewall

Examples:

```bash
sudo iptables -L -n
```

or on systems using nftables:

```bash
sudo nft list ruleset
```

Look for rules that may:

- DROP
- REJECT
- allow only selected sources
- block the application port

---

## 7. Check Service Logs

For a systemd service:

```bash
journalctl -u SERVICE
```

Examples of application-level causes:

- failed startup
- bad configuration
- dependency failure
- permission problem
- port already in use

---

## Practical Example

A Python HTTP server:

```bash
python3 -m http.server 8080
```

Check:

```bash
ss -lnt | grep 8080
```

Test locally:

```bash
curl http://localhost:8080
```

Test via server IP:

```bash
curl http://192.168.64.2:8080
```

Bind only to localhost:

```bash
python3 -m http.server 8080 --bind 127.0.0.1
```

Then:

```text
localhost → works
server IP → fails
```

This demonstrates a bind-address problem.

---

## Interview Troubleshooting Flow

If an application is unreachable:

```text
1. Resolve hostname
2. Check route
3. Check reachability
4. Check listener and bind address
5. Check firewall
6. Test with curl
7. Check service logs
```

Useful commands:

```bash
getent hosts HOST
ip route
ip route get DESTINATION
ping -c 3 HOST
ss -lntp
curl -v http://HOST:PORT
sudo iptables -L -n
sudo nft list ruleset
journalctl -u SERVICE
```

## Key Interview Sentence

> I troubleshoot connectivity layer by layer. I verify name resolution and routing, check whether the host is reachable, confirm that the service is listening on the expected address and port, then check firewall rules, test the application directly, and finally inspect the service logs.
