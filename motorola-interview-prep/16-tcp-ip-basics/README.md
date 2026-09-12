# MOT-16 — TCP/IP Basics

## Goal

Review the TCP/IP fundamentals required for Linux Platform / SRE troubleshooting:

- TCP vs UDP
- TCP three-way handshake
- common ports
- TCP connection states
- checking active and listening TCP sockets with `ss`

---

## TCP vs UDP

### TCP

TCP is connection-oriented and reliable.

Main characteristics:

- connection-oriented
- reliable delivery
- ordered delivery
- retransmission of lost segments
- higher overhead than UDP

Examples:

```text
SSH    TCP 22
HTTP   TCP 80
HTTPS  TCP 443
```

Interview answer:

> TCP is connection-oriented and reliable. It guarantees ordered delivery and retransmits lost segments.

---

### UDP

UDP is connectionless.

Main characteristics:

- no connection establishment
- no guarantee of delivery
- no guarantee of ordering
- no retransmission at the UDP layer
- lower overhead than TCP

Common example:

```text
DNS UDP 53
```

DNS commonly uses UDP because requests and responses are usually small and UDP has lower overhead.

If a DNS request is lost, the client can retry it.

---

## TCP Three-Way Handshake

TCP establishes a connection using:

```text
Client                         Server

SYN        ----------------->
           <----------------- SYN-ACK
ACK        ----------------->

             ESTABLISHED
```

Meaning:

```text
SYN      → client requests a connection
SYN-ACK  → server acknowledges and accepts
ACK      → client confirms
```

Interview answer:

> TCP uses a three-way handshake: SYN, SYN-ACK and ACK to establish a connection between the client and server.

---

## Lost TCP Segment

If a TCP segment is lost, TCP can retransmit it.

Interview answer:

> TCP detects that a segment was lost and retransmits it to ensure reliable delivery.

---

## Ports

An IP address identifies a host.

A port identifies a specific service or application on that host.

Example:

```text
10.0.0.5:22
```

```text
10.0.0.5 → host
22       → SSH service
```

TCP and UDP have separate port spaces.

Therefore:

```text
10.0.0.5:53/TCP
```

and:

```text
10.0.0.5:53/UDP
```

are different endpoints.

---

## Missing SYN-ACK

If a client sends a TCP SYN but receives no SYN-ACK, possible causes include:

- firewall blocking traffic
- service not listening on the destination port
- routing problem
- destination host unavailable
- return traffic blocked somewhere on the path

Troubleshooting idea:

```text
client
  ↓
routing
  ↓
firewall
  ↓
server
  ↓
listening service
```

Interview answer:

> I would check whether the service is listening, whether a firewall is blocking the traffic, and whether the routing is correct.

---

## TCP Connection States

Important TCP states:

```text
LISTEN        server is waiting for connections
SYN_SENT      client sent SYN
SYN_RECEIVED  server received SYN and replied
ESTABLISHED   connection is established
TIME_WAIT     connection was closed but TCP temporarily keeps its state
```

---

## Checking TCP Connections

Show TCP connections:

```bash
ss -t
```

Show listening TCP sockets:

```bash
ss -lnt
```

Options:

```text
-l  listening
-n  numeric addresses and ports
-t  TCP
```

Example:

```text
LISTEN 0 128 0.0.0.0:22
```

This means a service is listening on TCP port 22.

Example established SSH connection:

```text
ESTAB 0 0 10.0.0.5:22 10.0.0.20:51342
```

`ESTAB` means the TCP connection is established.

---

## Interview Quick Recall

```text
TCP
→ reliable
→ connection-oriented
→ ordered
→ retransmission

UDP
→ connectionless
→ no delivery guarantee
→ lower overhead

TCP handshake
→ SYN
→ SYN-ACK
→ ACK

SSH    → TCP 22
HTTP   → TCP 80
HTTPS  → TCP 443
DNS    → commonly UDP 53

ss -t
→ TCP connections

ss -lnt
→ listening TCP sockets
```

## Key Interview Sentence

> TCP is connection-oriented and reliable. It guarantees ordered delivery and retransmits lost segments. UDP is connectionless and has lower overhead but does not guarantee delivery or ordering.
