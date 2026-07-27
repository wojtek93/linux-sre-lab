# Linux SRE Lab 17 – Networking

## Goal

Learn the most commonly used Linux networking tools for troubleshooting connectivity, DNS resolution, HTTP services, routing and open ports.

---

## Topics

- Network interfaces
- IP addresses
- Routing
- DNS
- TCP vs UDP
- HTTP requests
- Open ports
- Connectivity troubleshooting

---

## Commands used

### Network configuration

```bash
ip addr
ip -br addr
ip route
hostname
hostname -I
```

### Connectivity

```bash
ping google.com
ping 192.168.64.2
```

### Open ports and sockets

```bash
ss -tulpn
ss -tan
netstat -tulpn
```

### HTTP testing

```bash
curl -I https://google.com
curl -L https://google.com
curl https://httpbin.org/get
curl -o /dev/null -s -w "%{http_code}\n" https://google.com
```

### DNS

```bash
dig google.com
dig +short google.com
dig AAAA google.com
nslookup google.com
cat /etc/resolv.conf
```

### Port testing

```bash
nc -zv 192.168.64.2 22
nc -zv 192.168.64.2 9999
```

### Download test

```bash
wget --spider https://google.com
```

### Route tracing

```bash
traceroute google.com
```

---

## What I learned

- Configure and inspect network interfaces.
- Understand routing and the default gateway.
- Differentiate TCP and UDP.
- Verify network connectivity with ping.
- Inspect listening services using ss.
- Test HTTP endpoints with curl.
- Resolve DNS records using dig and nslookup.
- Check port availability with netcat.
- Trace packet paths using traceroute.
- Perform structured network troubleshooting.

---

## Key concepts

### TCP

Reliable protocol.

- guarantees delivery
- retransmits lost packets
- preserves packet order

Used by:

- SSH
- HTTPS
- Git
- APIs

---

### UDP

Connectionless protocol.

- faster
- no delivery guarantee
- no retransmission

Used by:

- DNS
- VoIP
- Streaming
- Online games

---

## Basic troubleshooting workflow

1. Verify connectivity.

```bash
ping <host>
```

2. Check IP configuration.

```bash
ip addr
```

3. Verify routing.

```bash
ip route
```

4. Verify listening services.

```bash
ss -tulpn
```

5. Test a TCP port.

```bash
nc -zv <host> <port>
```

6. Verify DNS resolution.

```bash
dig <domain>
```

7. Test HTTP response.

```bash
curl -I <url>
```

8. Trace packet path.

```bash
traceroute <host>
```

---

## Result

Successfully completed a practical networking lab covering Linux networking fundamentals, DNS, routing, TCP/UDP, HTTP testing, port verification and troubleshooting techniques commonly used by Linux administrators, DevOps Engineers and Site Reliability Engineers.
