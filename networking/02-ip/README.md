# NET-02 — IP Addressing Basics

## Goal

Understand basic IPv4 addressing, private vs public addresses, loopback, bind addresses, network address, host range, broadcast address, and when traffic stays local versus going through a router.

---

## IPv4 Address

An IPv4 address identifies a host or network interface.

Example:

```text
192.168.1.50
```

On Linux, check addresses with:

```bash
ip addr
```

or:

```bash
ip a
```

Example output:

```text
2: eth0: ...
    inet 192.168.1.50/24
```

Here:

```text
192.168.1.50 → host IP address
/24          → network prefix
```

---

## Loopback

The most common IPv4 loopback address is:

```text
127.0.0.1
```

It means:

```text
this same host
```

Example:

```bash
curl http://127.0.0.1:8080
```

This connects to port `8080` on the local machine.

Loopback is useful for:

- local application testing,
- services that should not be remotely reachable,
- local inter-process communication.

---

## 127.0.0.1 vs 0.0.0.0

These are very different.

### 127.0.0.1

If an application listens on:

```text
127.0.0.1:8080
```

it is available only locally.

Example:

```bash
curl http://127.0.0.1:8080
```

may work on the server, while:

```bash
curl http://192.168.1.50:8080
```

from another host does not.

### 0.0.0.0

When a server application binds to:

```text
0.0.0.0:8080
```

it means:

```text
listen on all IPv4 interfaces
```

For example, if the machine has:

```text
127.0.0.1
192.168.1.50
10.0.0.15
```

a process listening on:

```text
0.0.0.0:8080
```

can accept connections addressed to the host's available IPv4 interfaces, assuming routing and firewall rules allow them.

Check listening sockets with:

```bash
ss -tulpn
```

Example:

```bash
ss -tulpn | grep :8080
```

---

## Private IPv4 Ranges

Private addresses are used inside local, corporate, cloud, and internal networks.

The main private IPv4 ranges are:

```text
10.0.0.0/8
172.16.0.0/12
192.168.0.0/16
```

Practical shortcut:

```text
10.x.x.x
172.16.x.x - 172.31.x.x
192.168.x.x
```

Examples:

```text
10.25.4.9       → private
172.20.5.10     → private
172.31.255.254  → private
192.168.100.50  → private
```

Important:

```text
not every 172.x.x.x address is private
```

Examples:

```text
172.15.10.10 → public
172.16.10.10 → private
172.31.10.10 → private
172.32.10.10 → public
172.40.1.1   → public
```

Also:

```text
192.168.x.x → private
192.169.x.x → not part of the private 192.168/16 range
```

---

## Public vs Private IP

Private IP addresses are typically used for internal communication.

Example:

```text
app01 → 10.0.1.10
app02 → 10.0.1.11
db01  → 10.0.2.10
```

These systems may communicate inside a private network.

Public addresses are globally routable on the Internet.

A common architecture is:

```text
Internet
   ↓
Public Load Balancer
   ↓
Private network
   ↓
app01 10.0.1.10
app02 10.0.1.11
   ↓
db01 10.0.2.10
```

A database usually does not need to be directly exposed to the Internet.

Private hosts may access external networks through mechanisms such as:

```text
router
gateway
NAT
VPN
```

---

## /24 Network

For a simple `/24` network:

```text
192.168.1.10/24
```

you can think of it as:

```text
192.168.1 . 10
|---------|  |
  network   host
```

The network is:

```text
192.168.1.0/24
```

The usual host range is:

```text
192.168.1.1
to
192.168.1.254
```

The broadcast address is:

```text
192.168.1.255
```

So:

```text
network:   192.168.1.0
hosts:     192.168.1.1 - 192.168.1.254
broadcast: 192.168.1.255
```

---

## Broadcast

A broadcast address represents communication addressed to all hosts in a subnet.

For:

```text
192.168.1.0/24
```

the broadcast address is:

```text
192.168.1.255
```

For this simple `/24` example:

```text
.0   → network address
.1-.254 → host addresses
.255 → broadcast address
```

This shortcut applies specifically to `/24`.

Other prefix lengths have different network and broadcast boundaries.

---

## Same Subnet

Two hosts in the same subnet can communicate directly at the local network level.

Example:

```text
10.0.5.10/24
10.0.5.200/24
```

Both belong to:

```text
10.0.5.0/24
```

So:

```text
same subnet
→ direct communication
```

---

## Different Subnet

Example:

```text
10.0.5.10/24
10.0.6.20/24
```

The first belongs to:

```text
10.0.5.0/24
```

The second belongs to:

```text
10.0.6.0/24
```

They are in different networks.

Therefore:

```text
different subnet
→ traffic must be routed
```

Typically through:

```text
router
default gateway
```

Example:

```text
192.168.1.50
      ↓
default gateway
      ↓
192.168.2.10
```

---

## Practical Linux Commands

Show IP addresses:

```bash
ip addr
```

Short version:

```bash
ip a
```

Show only IPv4 addresses:

```bash
ip -4 addr
```

Show routing table:

```bash
ip route
```

Show listening sockets:

```bash
ss -tulpn
```

Check a specific port:

```bash
ss -tulpn | grep :8080
```

Test local application:

```bash
curl http://127.0.0.1:8080
```

Test application using host IP:

```bash
curl http://192.168.1.50:8080
```

---

## Troubleshooting Example

Application works locally:

```bash
curl http://127.0.0.1:8080
```

but fails remotely:

```bash
curl http://192.168.1.50:8080
```

Check the listening address:

```bash
ss -tulpn | grep :8080
```

If you see:

```text
127.0.0.1:8080
```

the application is bound only to loopback.

If it should accept remote traffic, it may need to listen on:

```text
0.0.0.0:8080
```

or on a specific network interface.

After fixing the bind address, also verify:

```text
firewall
routing
security groups / ACLs
load balancer
```

depending on the environment.

---

## Quick Reference

```text
127.0.0.1
→ loopback / localhost

0.0.0.0
→ all IPv4 interfaces when used as a server bind address

10.0.0.0/8
→ private

172.16.0.0/12
→ private

192.168.0.0/16
→ private
```

For `/24`:

```text
192.168.1.0   → network
192.168.1.1-254 → hosts
192.168.1.255 → broadcast
```

Networking rule:

```text
same subnet
→ direct communication

different subnet
→ router / default gateway
```

---

## Interview Notes

Typical questions:

```text
Why does localhost work but remote access fail?
```

Check:

```text
bind address
listening port
firewall
routing
```

Typical command:

```bash
ss -tulpn
```

Another common question:

```text
Can a host with private IP 10.0.1.20 be reached directly from the Internet?
```

Normally no, unless there is additional connectivity such as:

```text
VPN
bastion
NAT
load balancer
routing into the private network
```

The key mental model is:

```text
IP identifies where the host/interface is
+
subnet tells whether the destination is local
+
routing tells where traffic goes if it is not local
```
