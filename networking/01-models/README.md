# NET-01 — OSI and TCP/IP Models

## Goal

Understand how common network protocols map to the OSI and TCP/IP models and how the model can be used during troubleshooting.

---

## OSI Model

The OSI model divides network communication into seven layers:

| Layer | Name | Examples |
|---|---|---|
| 7 | Application | HTTP, HTTPS, DNS |
| 6 | Presentation | Encryption, encoding |
| 5 | Session | Session management |
| 4 | Transport | TCP, UDP |
| 3 | Network | IP, ICMP |
| 2 | Data Link | Ethernet, Wi-Fi, ARP, MAC |
| 1 | Physical | Cable, fiber, radio signal |

For Linux/SRE troubleshooting, the most important layers are:

```text
L7 → Application
L4 → Transport
L3 → Network
L2 → Data Link
L1 → Physical
```

---

## TCP/IP Model

The TCP/IP model is simpler:

| TCP/IP Layer | OSI Equivalent | Examples |
|---|---|---|
| Application | OSI 5–7 | HTTP, HTTPS, DNS |
| Transport | OSI 4 | TCP, UDP |
| Internet | OSI 3 | IP, ICMP |
| Network Access | OSI 1–2 | Ethernet, Wi-Fi, ARP |

---

## Protocol Mapping

```text
HTTP   → OSI Layer 7 → TCP/IP Application
HTTPS  → OSI Layer 7 → TCP/IP Application
DNS    → OSI Layer 7 → TCP/IP Application

TCP    → OSI Layer 4 → TCP/IP Transport
UDP    → OSI Layer 4 → TCP/IP Transport

IP     → OSI Layer 3 → TCP/IP Internet
ICMP   → OSI Layer 3 → TCP/IP Internet

ARP      → OSI Layer 2 → TCP/IP Network Access
Ethernet → OSI Layer 2 → TCP/IP Network Access
Wi-Fi    → OSI Layer 2 → TCP/IP Network Access

Cable / fiber / radio signal
         → OSI Layer 1
```

---

## Important Concepts

### Layer 7 — Application

Protocols used directly by applications.

Examples:

```text
HTTP
HTTPS
DNS
```

Example:

```bash
curl https://example.com
```

If DNS resolution fails but connecting directly to an IP works, the problem may be at the application/DNS layer.

Useful commands:

```bash
dig example.com
getent hosts example.com
cat /etc/resolv.conf
```

---

## Layer 4 — Transport

Responsible for communication between processes using ports.

Main protocols:

```text
TCP
UDP
```

Example:

```text
TCP port 80  → HTTP
TCP port 443 → HTTPS
```

Useful commands:

```bash
ss -tulpn
nc -vz server 8080
```

Example troubleshooting:

```text
ping works
curl :8080 → connection refused
```

The host is reachable at Layer 3, so investigate Layer 4:

```bash
ss -tulpn | grep :8080
```

Then check the application:

```bash
systemctl status <service>
journalctl -u <service>
```

---

## Layer 3 — Network

Responsible for IP addressing and routing between networks.

Main protocols:

```text
IP
ICMP
```

ICMP is used by tools such as:

```bash
ping
```

Example:

```bash
ping 8.8.8.8
```

A successful ping confirms that IP communication works at least partially.

---

## Layer 2 — Data Link

Responsible for communication inside the local network.

Examples:

```text
Ethernet
Wi-Fi
MAC addresses
ARP
```

ARP maps an IP address to a MAC address.

Example:

```text
192.168.1.1
        ↓ ARP
aa:bb:cc:dd:ee:ff
```

Useful command:

```bash
ip neigh
```

Older command:

```bash
arp -n
```

---

## Layer 1 — Physical

The physical transmission of bits.

Examples:

```text
Ethernet cable
Fiber optic cable
Radio signal
Physical network interface
```

---

## Request Flow

A simplified HTTP request:

```text
HTTP request
    ↓
TCP
    ↓
IP
    ↓
Ethernet / Wi-Fi
    ↓
Physical medium
```

On the receiving host, the process happens in reverse.

---

## Troubleshooting Mental Model

Use OSI layers to narrow down the problem:

```text
L1 → Is the physical connection working?

L2 → Can devices communicate on the local network?
     ARP / MAC / Ethernet

L3 → Is IP connectivity and routing working?
     IP / ICMP / ping

L4 → Is the correct TCP/UDP port reachable?
     TCP / UDP / ports

L7 → Is the application protocol working?
     HTTP / HTTPS / DNS
```

Example:

```text
ping server
→ works

curl http://server:8080
→ connection refused
```

Reasoning:

```text
L3 works
↓
investigate L4
↓
is port 8080 listening?
```

Check:

```bash
ss -tulpn | grep :8080
```

---

## Quick Reference

```text
L7 → HTTP, HTTPS, DNS
L4 → TCP, UDP
L3 → IP, ICMP
L2 → Ethernet, Wi-Fi, ARP, MAC
L1 → Cable, fiber, radio signal
```

---

## Interview Notes

A useful troubleshooting approach is to move through the stack instead of checking random commands.

Example:

```text
Can I resolve the hostname?
↓
Can I reach the IP?
↓
Can I reach the TCP port?
↓
Does the application respond correctly?
```

Typical tools:

```bash
dig
ping
ip route
ip neigh
nc
ss
curl
```

The OSI model is useful mainly as a troubleshooting framework:

```text
Physical
→ Local network
→ IP/routing
→ TCP/ports
→ Application
```
