# NET-08 — TCP Fundamentals and Troubleshooting

## Goal

Understand how TCP establishes and closes connections, how to inspect TCP sockets and states, how to distinguish connection refused from timeout, and how packet loss affects TCP latency.

---

## What is TCP?

TCP means:

```text
Transmission Control Protocol
```

TCP operates at:

```text
OSI Layer 4 — Transport
```

TCP provides:

```text
connection-oriented communication
reliable delivery
ordered delivery
acknowledgments
retransmissions
```

---

## TCP 3-Way Handshake

Before sending application data, TCP establishes a connection.

The basic flow is:

```text
Client → SYN
Server → SYN-ACK
Client → ACK
```

Meaning:

```text
SYN = Synchronize
ACK = Acknowledgment
```

Mental model:

```text
SYN
→ "I want to connect"

SYN-ACK
→ "I received your request and I am ready"

ACK
→ "Confirmed"
```

After this, the TCP connection is established.

---

## Inspect Listening TCP Sockets

Use:

```bash
ss -lnt
```

Options:

```text
-l → listening
-n → numeric addresses and ports
-t → TCP
```

Example:

```text
LISTEN 0 128 0.0.0.0:80
```

Meaning:

```text
LISTEN
→ waiting for connections

0.0.0.0
→ all IPv4 interfaces

80
→ local TCP port
```

---

## Common Bind Addresses

```text
127.0.0.1:8080
→ local-only

0.0.0.0:8080
→ all IPv4 interfaces

[::]:8080
→ all IPv6 interfaces
```

---

## Testing a TCP Port

Use:

```bash
nc -vz 127.0.0.1 80
```

Options:

```text
nc = netcat
-v = verbose
-z = connection test without sending application data
```

Successful result:

```text
Connection to 127.0.0.1 80 port [tcp/http] succeeded!
```

This confirms that a TCP connection can be established.

---

## Capture TCP Handshake

Use:

```bash
sudo tcpdump -i lo tcp port 80
```

Then from another terminal:

```bash
nc -vz 127.0.0.1 80
```

Typical flags:

```text
[S]
[S.]
[.]
```

Meaning:

```text
[S]  → SYN
[S.] → SYN + ACK
[.]  → ACK
```

This is the TCP 3-way handshake.

---

## Client and Server Ports

A server may listen on:

```text
80
```

while the client uses a temporary high-numbered port such as:

```text
34726
```

Example:

```text
client:34726
→
server:80
```

The client port is often called an:

```text
ephemeral port
```

It is temporary and selected for the connection.

---

## TCP Connection States

### LISTEN

```text
LISTEN
```

Meaning:

```text
server is waiting for new connections
```

---

### ESTABLISHED

`ss` often shows:

```text
ESTAB
```

Meaning:

```text
TCP connection is active
```

Example:

```text
127.0.0.1:9090
127.0.0.1:37524
```

One side is the server port and the other is the client's ephemeral port.

---

## Create an ESTABLISHED Connection

Terminal 1:

```bash
nc -l 9090
```

Terminal 2:

```bash
nc 127.0.0.1 9090
```

Terminal 3:

```bash
ss -tn | grep 9090
```

Expected state:

```text
ESTAB
```

---

## Closing a TCP Connection

TCP normally closes using FIN packets.

```text
FIN = Finish
```

A simplified closing process:

```text
Side A → FIN
Side B → ACK
Side B → FIN
Side A → ACK
```

---

## FIN-WAIT

Example state:

```text
FIN-WAIT-2
```

Meaning:

```text
local side has started closing
and is waiting for the remote side to finish closing
```

---

## CLOSE-WAIT

Example:

```text
CLOSE-WAIT
```

Meaning:

```text
remote side closed the connection
but the local application has not closed its socket yet
```

A large persistent number of:

```text
CLOSE-WAIT
```

may indicate that an application is not closing sockets properly.

---

## TIME-WAIT

After a connection is closed, TCP may keep information about it temporarily.

Example:

```text
TIME-WAIT
```

Meaning:

```text
connection is already closed
but kernel temporarily remembers it
```

This is normally expected behavior.

It helps prevent delayed packets from an old connection being confused with a new connection.

---

## Generate TIME-WAIT Connections

Run:

```bash
for i in {1..5}; do nc -z 127.0.0.1 80; done
```

Then:

```bash
ss -tan | grep TIME-WAIT
```

You may see several entries with different client ports.

---

## TCP State Quick Reference

```text
LISTEN
→ waiting for new connections

ESTABLISHED / ESTAB
→ active connection

FIN-WAIT
→ connection is being closed

CLOSE-WAIT
→ remote side closed, local application has not finished closing

TIME-WAIT
→ closed connection temporarily retained by kernel
```

---

## Connection Refused

Test a port where nothing is listening:

```bash
nc -vz 127.0.0.1 9999
```

Typical result:

```text
Connection refused
```

Capture it:

```bash
sudo tcpdump -i lo tcp port 9999
```

Then run the connection again.

Typical packets:

```text
[S]
[R.]
```

Meaning:

```text
SYN
→ client asks to connect

RST + ACK
→ host actively rejects connection
```

`RST` means:

```text
Reset
```

Mental model:

```text
SYN
→ RST
→ Connection refused
```

---

## Connection Timeout

A timeout means the client does not receive the expected response.

Example:

```bash
nc -vz -w 3 192.168.64.250 9999
```

Option:

```text
-w 3
→ wait up to 3 seconds
```

Possible result:

```text
timed out
```

Possible causes include:

```text
firewall dropping traffic
routing issue
ACL / security group
host unavailable
Layer 2 issue
```

---

## Timeout Caused Before TCP

In the lab, the destination was inside the same local subnet.

Before TCP could send a SYN, Linux first needed the destination MAC address.

ARP requests were visible with:

```bash
sudo tcpdump -i enp0s1 arp
```

Example:

```text
ARP, Request who-has 192.168.64.250
```

No ARP reply arrived.

Flow:

```text
destination is local
↓
Linux needs MAC
↓
ARP request
↓
no ARP reply
↓
cannot send TCP SYN
↓
connection times out
```

This is an important example showing that a TCP timeout can be caused by a lower-layer networking problem.

---

## Connection Refused vs Timeout

```text
Connection refused
→ host is reachable
→ SYN is sent
→ RST is returned
→ port is not accepting connections
```

```text
Timeout
→ expected response never arrives
→ possible firewall / routing / ARP / network path issue
```

---

## TCP Sequence Numbers

TCP uses sequence numbers to track data.

```text
SEQ = Sequence Number
```

Example:

```text
seq = 300
length = 100 bytes
```

This represents bytes:

```text
300–399
```

The receiver responds with:

```text
ACK = 400
```

Meaning:

```text
I received everything up to 399
and expect byte 400 next
```

---

## SYN and Sequence Numbers

SYN consumes one sequence number.

Example:

```text
SYN
seq = 200
```

The server responds with:

```text
ACK = 201
```

---

## Data and ACK Calculation

For regular data:

```text
ACK = SEQ + number of received bytes
```

Example:

```text
seq = 500
length = 50
```

Result:

```text
ACK = 550
```

---

## Retransmission

TCP provides reliable delivery.

If data is sent but the expected acknowledgment does not arrive, TCP may retransmit the data.

Flow:

```text
send data
↓
wait for ACK
↓
ACK does not arrive
↓
retransmit
```

This is called:

```text
TCP retransmission
```

Many retransmissions may indicate:

```text
packet loss
network congestion
unstable link
network path problems
```

---

## Packet Loss

Packet loss means some packets do not reach the destination.

Example:

```text
20 packets transmitted
18 received
10% packet loss
```

Packet loss can increase application latency because TCP must retransmit missing data.

---

## Ping

Test reachability and latency:

```bash
ping -c 20 8.8.8.8
```

Important output:

```text
packet loss
RTT
```

`RTT` means:

```text
Round-Trip Time
```

It measures the time for a packet to travel to the destination and for the reply to return.

Example:

```text
20 transmitted
20 received
0% packet loss
```

indicates no loss during that test.

---

## Ping Statistics

Typical summary:

```text
min/avg/max/mdev
```

Meaning:

```text
min
→ lowest RTT

avg
→ average RTT

max
→ highest RTT

mdev
→ latency variation
```

---

## MTR

`mtr` combines ideas from:

```text
ping
+
traceroute
```

It shows latency and packet loss across multiple hops.

Run:

```bash
mtr 8.8.8.8
```

Important columns:

```text
Loss%
→ packet loss

Snt
→ packets sent

Last
→ latest RTT

Avg
→ average RTT

Best
→ lowest RTT

Wrst
→ highest RTT

StDev
→ latency variation
```

---

## Interpreting MTR

Do not automatically assume that packet loss on one intermediate hop means that router is broken.

Example:

```text
hop 4       50% loss
hop 5        0% loss
hop 6        0% loss
destination  0% loss
```

The intermediate router may simply limit diagnostic responses.

More concerning:

```text
hop 4       10% loss
hop 5       10% loss
hop 6       10% loss
destination 10% loss
```

This may indicate loss beginning around that section of the path.

---

## Ping vs Traceroute vs MTR

```text
ping
→ is destination reachable?
→ packet loss?
→ RTT?
```

```text
traceroute
→ which hops are used?
```

```text
mtr
→ hops + latency + packet loss
```

---

## Practical TCP Troubleshooting Flow

When an application port cannot be reached:

```text
1. Is the service listening?

ss -lnt

2. Can TCP connect?

nc -vz HOST PORT

3. Connection refused?

Check listener / bind address / application

4. Timeout?

Check:
ARP
routing
firewall
ACL
security group
network path

5. Need packet-level evidence?

tcpdump
```

---

## Useful Commands

Listening TCP sockets:

```bash
ss -lnt
```

Active TCP connections:

```bash
ss -tn
```

All TCP states:

```bash
ss -tan
```

Test port:

```bash
nc -vz HOST PORT
```

Test with timeout:

```bash
nc -vz -w 3 HOST PORT
```

Capture TCP:

```bash
sudo tcpdump -i <interface> tcp port <port>
```

Capture ARP:

```bash
sudo tcpdump -i <interface> arp
```

Packet loss / latency:

```bash
ping -c 20 HOST
```

Path + loss:

```bash
mtr HOST
```

---

## Quick Reference

```text
TCP
→ Transmission Control Protocol
→ Layer 4
```

Handshake:

```text
SYN
SYN-ACK
ACK
```

States:

```text
LISTEN
ESTABLISHED
TIME-WAIT
CLOSE-WAIT
FIN-WAIT
```

Errors:

```text
Connection refused
→ SYN → RST

Timeout
→ no expected response
```

Reliability:

```text
SEQ
ACK
retransmission
```

Network quality:

```text
packet loss
RTT
```

---

## Interview Mental Model

For:

```text
Cannot connect to application port
```

think:

```text
Is the service listening?
↓
Is TCP reachable?
↓
Refused or timeout?
↓
What does tcpdump show?
↓
Is ARP/routing/firewall involved?
```

Important distinctions:

```text
refused
→ active rejection

timeout
→ missing response

high packet loss
→ retransmissions
→ higher latency
```

The goal is to diagnose TCP behavior using evidence instead of guessing.
