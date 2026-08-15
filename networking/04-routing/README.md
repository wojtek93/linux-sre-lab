# NET-04 — Routing

## Goal

Understand how Linux decides where to send packets, how to read the routing table, how default gateways work, how the most specific route is selected, and how to troubleshoot routing and TCP connectivity.

---

## What is Routing?

Routing answers:

```text
Where should this packet go?
```

For each destination, the operating system checks its routing table.

If the destination is in the local subnet:

```text
send directly
```

If the destination is outside the local subnet:

```text
send through a router / gateway
```

---

## Show Routing Table

Use:

```bash
ip route
```

Example:

```text
default via 192.168.1.1 dev eth0
192.168.1.0/24 dev eth0
10.10.0.0/16 via 192.168.1.254 dev eth0
```

---

## Reading a Direct Route

Example:

```text
192.168.1.0/24 dev eth0
```

This means:

```text
destinations inside 192.168.1.0/24
→ are directly reachable
→ through eth0
```

Example destination:

```text
192.168.1.80
```

belongs to:

```text
192.168.1.0/24
```

so no gateway is required.

---

## Default Route

Example:

```text
default via 192.168.1.1 dev eth0
```

This means:

```text
if no more specific route matches
→ send the packet to 192.168.1.1
→ through eth0
```

The default gateway is normally the router that provides access to other networks.

Example:

```text
destination: 8.8.8.8
```

If there is no specific route for it:

```text
8.8.8.8
→ default gateway
→ 192.168.1.1
```

---

## Route Through Another Gateway

Example:

```text
10.10.0.0/16 via 192.168.1.254 dev eth0
```

This means:

```text
for destinations inside 10.10.0.0/16
→ send packets to router 192.168.1.254
→ using eth0
```

Example destination:

```text
10.10.5.20
```

belongs to:

```text
10.10.0.0/16
```

so this route is used.

---

## Understanding /8, /16 and /24

For simplified subnet recognition:

```text
/8
→ first octet identifies the network

/16
→ first two octets identify the network

/24
→ first three octets identify the network
```

Examples:

```text
10.0.0.0/8
→ 10.x.x.x
```

```text
10.20.0.0/16
→ 10.20.x.x
```

```text
10.20.50.0/24
→ 10.20.50.x
```

---

## Longest Prefix Match

Linux chooses the most specific matching route.

Example:

```text
default via 10.0.0.1 dev eth0
10.0.0.0/8 via 10.0.0.2 dev eth0
10.20.0.0/16 via 10.0.0.3 dev eth0
10.20.50.0/24 via 10.0.0.4 dev eth0
```

Destination:

```text
10.20.50.25
```

matches:

```text
10.0.0.0/8
10.20.0.0/16
10.20.50.0/24
```

The most specific route wins:

```text
10.20.50.0/24
```

So:

```text
/24 > /16 > /8 > default
```

This is called:

```text
longest prefix match
```

---

## Example Route Selection

Routing table:

```text
default via 192.168.1.1 dev eth0
192.168.1.0/24 dev eth0
10.10.0.0/16 via 192.168.1.254 dev eth0
```

Destination:

```text
192.168.1.80
```

Result:

```text
192.168.1.0/24 dev eth0
```

because the destination is local.

Destination:

```text
10.10.5.20
```

Result:

```text
10.10.0.0/16 via 192.168.1.254 dev eth0
```

Destination:

```text
8.8.8.8
```

Result:

```text
default via 192.168.1.1 dev eth0
```

---

## ip route get

Instead of manually reading the entire routing table, ask the kernel which route it will use.

Example:

```bash
ip route get 8.8.8.8
```

Possible output:

```text
8.8.8.8 via 192.168.1.1 dev eth0 src 192.168.1.50
```

Read it as:

```text
destination → 8.8.8.8

gateway
via 192.168.1.1

interface
dev eth0

source IP
src 192.168.1.50
```

Mental shortcut:

```text
A via B dev C src D
```

means:

```text
to A
through B
using C
from address D
```

---

## Direct Route with ip route get

Example:

```bash
ip route get 192.168.1.80
```

Possible result:

```text
192.168.1.80 dev eth0 src 192.168.1.50
```

There is no:

```text
via
```

so no gateway is required.

That means:

```text
destination is directly reachable
```

---

## traceroute

Use:

```bash
traceroute 8.8.8.8
```

or:

```bash
tracepath 8.8.8.8
```

Example:

```text
1  192.168.1.1
2  10.0.0.1
3  203.0.113.5
4  8.8.8.8
```

Each step is a:

```text
hop
```

So:

```text
host
↓
router 1
↓
router 2
↓
router 3
↓
destination
```

---

## traceroute and * * *

Example:

```text
1  192.168.1.1
2  10.0.0.1
3  * * *
4  * * *
```

Do not assume automatically that hop 3 is broken.

Possible reasons:

```text
router does not answer traceroute
ICMP is filtered
firewall blocks replies
routing problem
network path issue
```

The result only proves that traffic reaches at least the previous responding hop.

---

## ip route get vs traceroute

```text
ip route get <IP>
→ how the local Linux kernel plans to send the packet

traceroute <IP>
→ which hops appear along the path
```

These answer different questions.

---

## Testing a TCP Port with nc

Use:

```bash
nc -vz HOST PORT
```

Example:

```bash
nc -vz 10.20.5.10 443
```

Options:

```text
-v → verbose
-z → scan/test mode without sending application data
```

Possible result:

```text
succeeded
```

means:

```text
TCP connection to the port works
```

---

## Connection Refused

Example:

```bash
nc -vz 10.0.0.50 8080
```

returns:

```text
Connection refused
```

This usually means:

```text
the host is reachable
but the TCP connection was actively rejected
```

Possible causes:

```text
application is not running
nothing is listening on the port
application listens only on 127.0.0.1
firewall actively rejects the connection
```

---

## Timeout

Example:

```bash
nc -vz 10.0.0.50 8080
```

returns:

```text
timed out
```

Possible causes:

```text
firewall drops traffic
ACL
security group
routing problem
network path problem
```

A timeout does not automatically mean the application itself is broken.

---

## Check Listening Ports

On the server:

```bash
ss -tulpn
```

Check one port:

```bash
ss -tulpn | grep :8080
```

Example:

```text
LISTEN 0 128 127.0.0.1:8080
```

This means:

```text
application listens only on loopback
```

Remote hosts cannot access it through the server's network IP.

---

## Listening on All Interfaces

Example:

```text
LISTEN 0 128 0.0.0.0:8080
```

This means:

```text
the application listens on all IPv4 interfaces
```

Remote access can still depend on:

```text
firewall
routing
ACL
security group
load balancer
```

---

## LISTEN 0 128

Example:

```text
LISTEN 0 128 0.0.0.0:8080
```

Important parts:

```text
LISTEN
→ socket accepts new connections

0
→ current queue usage

128
→ configured queue limit/backlog information
```

For basic troubleshooting, focus mainly on:

```text
LISTEN
IP:PORT
```

---

## Local vs Remote Troubleshooting

Scenario:

```bash
curl http://127.0.0.1:8080
```

works locally.

Remote:

```bash
nc -vz 10.0.0.50 8080
```

returns:

```text
Connection refused
```

Check:

```bash
ss -tulpn | grep :8080
```

If:

```text
127.0.0.1:8080
```

then:

```text
application is local-only
```

If:

```text
0.0.0.0:8080
```

then check:

```text
firewall
routing
ACL/security groups
```

---

## Firewall Checks

Depending on the Linux distribution:

```bash
sudo nft list ruleset
```

or:

```bash
sudo iptables -L -n -v
```

or:

```bash
sudo ufw status
```

In cloud environments also check:

```text
security groups
NSG
network ACLs
cloud firewall
```

---

## Practical Troubleshooting Flow

When remote access fails:

```text
1. Is the destination IP reachable?

ping <IP>

2. Which route will Linux use?

ip route get <IP>

3. What is the path?

traceroute <IP>

4. Is the TCP port reachable?

nc -vz <IP> <PORT>

5. Is the service listening locally?

ss -tulpn | grep :<PORT>

6. Is the service bound correctly?

127.0.0.1
vs
0.0.0.0

7. Is traffic filtered?

firewall
ACL
security group
```

---

## Useful Commands

Show routing table:

```bash
ip route
```

Show route for one destination:

```bash
ip route get 10.20.5.10
```

Trace path:

```bash
traceroute 8.8.8.8
```

or:

```bash
tracepath 8.8.8.8
```

Test TCP port:

```bash
nc -vz 10.20.5.10 443
```

Check listening sockets:

```bash
ss -tulpn
```

Check one port:

```bash
ss -tulpn | grep :443
```

---

## Quick Reference

```text
ip route
→ show all routes

ip route get <IP>
→ show selected route

traceroute <IP>
→ show hops along path

nc -vz <IP> <PORT>
→ test TCP connectivity

ss -tulpn
→ show local listening sockets
```

Routing decision:

```text
same subnet
→ direct

different subnet
→ gateway
```

Route selection:

```text
most specific matching route wins
```

TCP troubleshooting:

```text
connection refused
→ host reachable, TCP actively rejected

timeout
→ possible firewall / routing / network filtering
```

---

## Interview Mental Model

When asked why a remote application cannot be reached:

```text
IP
↓
route
↓
path
↓
TCP port
↓
local listener
↓
bind address
↓
firewall
↓
application
```

Useful sequence:

```bash
ip route get <destination>
traceroute <destination>
nc -vz <destination> <port>
ss -tulpn | grep :<port>
```

This avoids random troubleshooting and narrows the problem layer by layer.
