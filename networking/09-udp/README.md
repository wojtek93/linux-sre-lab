# NET-09 UDP

## Goal

Understand how UDP works, how it differs from TCP, and how to troubleshoot UDP traffic in Linux.

---

## What is UDP?

UDP = User Datagram Protocol.

UDP works at Layer 4 of the OSI model.

UDP is connectionless.

It does not create a connection before sending data.

There is no TCP-style handshake:

```text
SYN
SYN-ACK
ACK
```

With UDP, the sender can immediately send a datagram.

---

## TCP vs UDP

TCP:

```text
connection-oriented
handshake
reliable delivery
ACKs
retransmissions
ordered data
```

UDP:

```text
connectionless
no handshake
no delivery guarantee
no built-in retransmission
no guaranteed ordering
lower protocol overhead
```

---

## Check UDP sockets

Command:

```bash
ss -lun
```

Options:

```text
-l = listening sockets
-u = UDP
-n = numeric addresses and ports
```

UDP sockets often appear as:

```text
UNCONN
```

This means unconnected.

This is normal for UDP because there is no persistent connection like TCP ESTABLISHED.

To also show the process:

```bash
sudo ss -lunp
```

```text
-p = process
```

---

## Create a UDP listener

Terminal 1:

```bash
nc -u -l 9090
```

Terminal 2:

```bash
echo "hello udp" | nc -u 127.0.0.1 9090
```

The listener receives:

```text
hello udp
```

No handshake is created before the data is sent.

---

## Capture UDP traffic

Start tcpdump:

```bash
sudo tcpdump -i lo udp port 9090
```

Send a datagram:

```bash
echo "hello udp" | nc -u 127.0.0.1 9090
```

Example packet:

```text
IP localhost.50420 > localhost.9090: UDP, length 10
```

This means:

```text
source port:      50420
destination port: 9090
protocol:         UDP
payload:          10 bytes
```

Unlike TCP, there are no SYN, SYN-ACK or ACK packets before the data.

---

## UDP to a closed port

Capture UDP and ICMP:

```bash
sudo tcpdump -i lo 'udp port 9999 or icmp'
```

Send UDP traffic:

```bash
echo "test" | nc -u -w 1 127.0.0.1 9999
```

If nothing is listening on port 9999, Linux may respond with:

```text
ICMP localhost udp port 9999 unreachable
```

ICMP = Internet Control Message Protocol.

Traffic flow:

```text
UDP datagram
    ↓
closed UDP port
    ↓
ICMP Port Unreachable
```

---

## TCP closed port vs UDP closed port

TCP:

```text
SYN
↓
RST
↓
Connection refused
```

UDP:

```text
UDP datagram
↓
possibly ICMP Port Unreachable
```

Important:

```text
no UDP response != port definitely closed
```

No response may mean:

```text
application does not respond
firewall dropped the UDP packet
firewall dropped ICMP response
packet was lost
remote host is unreachable
```

This makes UDP troubleshooting less obvious than TCP troubleshooting.

---

## DNS over UDP

DNS = Domain Name System.

A normal DNS query usually uses:

```text
UDP/53
```

Example:

```bash
dig @8.8.8.8 google.com
```

The output can show:

```text
SERVER: 8.8.8.8#53(8.8.8.8) (UDP)
```

Typical flow:

```text
DNS query
↓
UDP/53
↓
DNS server
↓
DNS response
```

UDP works well for many DNS queries because the exchange is usually short:

```text
one question
↓
one response
```

---

## DNS over TCP

DNS can also use TCP port 53.

Force TCP with:

```bash
dig +tcp @8.8.8.8 google.com
```

The output can show:

```text
SERVER: 8.8.8.8#53(8.8.8.8) (TCP)
```

TCP creates the connection first:

```text
SYN
SYN-ACK
ACK
DNS query
DNS response
```

This is different from UDP, where the DNS query can be sent immediately.

---

## Troubleshooting DNS TCP vs UDP

If this works:

```bash
dig @8.8.8.8 google.com
```

but this fails:

```bash
dig +tcp @8.8.8.8 google.com
```

possible causes include filtering of TCP port 53.

You can test TCP/53 with:

```bash
nc -vz 8.8.8.8 53
```

---

## Packet loss

UDP itself does not retransmit a lost datagram.

Example:

```text
datagram sent
↓
packet lost
↓
UDP does not retransmit it
```

TCP behaves differently:

```text
data sent
↓
ACK missing
↓
retransmission
```

If an application using UDP needs reliability, it must implement the required mechanisms at a higher layer.

---

## Common UDP use cases

UDP is useful when low latency and low overhead are important.

Examples:

```text
DNS
VoIP
real-time audio/video
online games
some telemetry systems
```

For real-time communication, receiving current data quickly may be more useful than retransmitting old data.

Example:

```text
audio 1
audio 2
audio 3 LOST
audio 4
audio 5
```

A short missing fragment may be preferable to delaying the entire stream while waiting for retransmission.

---

## Key troubleshooting commands

```bash
ss -lun
sudo ss -lunp
nc -u -l 9090
nc -u 127.0.0.1 9090
tcpdump -i lo udp port 9090
tcpdump -i lo 'udp port 9999 or icmp'
dig @8.8.8.8 google.com
dig +tcp @8.8.8.8 google.com
nc -vz 8.8.8.8 53
```

---

## Key takeaways

```text
UDP = connectionless
UDP = no handshake
UDP = no built-in ACK/retransmission
UDP = no guaranteed delivery
UDP = low overhead
UDP closed port may return ICMP Port Unreachable
no UDP response does not prove the port is closed
DNS commonly uses UDP/53
DNS can also use TCP/53
```

Short interview answer:

```text
UDP is used when low latency is more important than guaranteed delivery,
for example DNS, VoIP, real-time audio/video and online games.
```
