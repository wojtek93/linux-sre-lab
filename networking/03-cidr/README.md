# NET-03 — CIDR and Subnet Basics

## Goal

Understand CIDR notation, subnet size, usable hosts, network address, broadcast address, and how to determine whether two hosts belong to the same subnet.

---

## What is CIDR?

CIDR means:

```text
Classless Inter-Domain Routing
```

You commonly see addresses written like:

```text
192.168.1.10/24
```

The `/24` is the CIDR prefix.

IPv4 contains:

```text
32 bits
```

The prefix tells us how many of those bits describe the network.

Example:

```text
/24
```

means:

```text
24 bits → network
8 bits  → hosts
```

---

## Network Size

The number of addresses is calculated using:

```text
2^(32 - prefix)
```

Example:

```text
/24

32 - 24 = 8

2^8 = 256 addresses
```

Typical usable hosts:

```text
256 - 2 = 254
```

because traditionally:

```text
1 address → network
1 address → broadcast
```

---

## Common CIDR Sizes

| CIDR | Total addresses | Usable hosts |
|---|---:|---:|
| /24 | 256 | 254 |
| /25 | 128 | 126 |
| /26 | 64 | 62 |
| /27 | 32 | 30 |
| /28 | 16 | 14 |
| /29 | 8 | 6 |
| /30 | 4 | 2 |

Important rule:

```text
larger prefix
→ fewer host bits
→ fewer addresses
→ smaller subnet
```

Therefore:

```text
/24 is larger than /26
/26 is larger than /28
```

---

## /24 Example

For:

```text
192.168.1.0/24
```

the range is:

```text
network:      192.168.1.0
first host:   192.168.1.1
last host:    192.168.1.254
broadcast:    192.168.1.255
```

So:

```text
192.168.1.0      → network
192.168.1.1-254  → hosts
192.168.1.255    → broadcast
```

---

## Network Address

The network address represents the whole subnet.

Example:

```text
192.168.1.0/24
```

The network address is:

```text
192.168.1.0
```

Think of it as:

```text
the address/name of the entire network
```

It is not normally assigned to a regular host.

---

## Host Address

A host address identifies a specific device or network interface.

Examples:

```text
192.168.1.10
192.168.1.20
192.168.1.50
```

These could represent:

```text
server
laptop
VM
router interface
```

---

## Broadcast Address

The broadcast address represents all hosts in the subnet.

For:

```text
192.168.1.0/24
```

the broadcast address is:

```text
192.168.1.255
```

Mental model:

```text
network   = whole subnet
host      = one device
broadcast = all devices in the subnet
```

---

## /26 Example

A `/26` contains:

```text
64 addresses
```

A `/24` can therefore be divided into four `/26` networks:

```text
192.168.1.0/26
192.168.1.64/26
192.168.1.128/26
192.168.1.192/26
```

The boundaries increase by:

```text
64
```

So:

```text
.0
.64
.128
.192
```

---

## First /26 Subnet

```text
192.168.1.0/26
```

Range:

```text
network:      192.168.1.0
first host:   192.168.1.1
last host:    192.168.1.62
broadcast:    192.168.1.63
```

---

## Second /26 Subnet

```text
192.168.1.64/26
```

Range:

```text
network:      192.168.1.64
first host:   192.168.1.65
last host:    192.168.1.126
broadcast:    192.168.1.127
```

---

## Third /26 Subnet

```text
192.168.1.128/26
```

Range:

```text
network:      192.168.1.128
first host:   192.168.1.129
last host:    192.168.1.190
broadcast:    192.168.1.191
```

---

## Fourth /26 Subnet

```text
192.168.1.192/26
```

Range:

```text
network:      192.168.1.192
first host:   192.168.1.193
last host:    192.168.1.254
broadcast:    192.168.1.255
```

---

## Full /26 View

```text
192.168.1.0   - 192.168.1.63
192.168.1.64  - 192.168.1.127
192.168.1.128 - 192.168.1.191
192.168.1.192 - 192.168.1.255
```

For every subnet:

```text
first address
→ network

addresses in the middle
→ usable hosts

last address
→ broadcast
```

---

## Same Subnet

Example:

```text
10.0.5.10/24
10.0.5.200/24
```

Both belong to:

```text
10.0.5.0/24
```

Therefore:

```text
same subnet
→ direct communication
```

---

## Different Subnets

Example:

```text
10.0.5.10/24
10.0.6.20/24
```

Networks:

```text
10.0.5.0/24
10.0.6.0/24
```

They are different.

Therefore:

```text
different subnet
→ router / gateway required
```

---

## Practical Rule

To determine where traffic should go, the operating system asks:

```text
Is the destination inside my local subnet?
```

If yes:

```text
send directly
```

If no:

```text
send to router / default gateway
```

This is one of the foundations of IP routing.

---

## Useful Linux Commands

Show interface addresses and prefixes:

```bash
ip addr
```

IPv4 only:

```bash
ip -4 addr
```

Show routes:

```bash
ip route
```

Example:

```text
192.168.1.0/24 dev eth0
```

means that the network:

```text
192.168.1.0/24
```

is directly reachable through:

```text
eth0
```

---

## Quick Calculation

For IPv4:

```text
host bits = 32 - CIDR prefix
```

Then:

```text
addresses = 2^(host bits)
```

Examples:

```text
/24

32 - 24 = 8
2^8 = 256
```

```text
/26

32 - 26 = 6
2^6 = 64
```

```text
/28

32 - 28 = 4
2^4 = 16
```

---

## Quick Reference

```text
/24 → 256 addresses
/25 → 128
/26 → 64
/27 → 32
/28 → 16
/29 → 8
/30 → 4
```

Mental rule:

```text
each +1 in prefix
→ subnet becomes half the size
```

Example:

```text
/24 → 256
/25 → 128
/26 → 64
/27 → 32
```

---

## Interview Notes

You should be able to explain:

```text
192.168.1.10/24
```

as:

```text
IP address: 192.168.1.10
network:    192.168.1.0/24
```

You should also recognize that:

```text
10.0.5.10/24
10.0.5.20/24
```

are in the same subnet, while:

```text
10.0.5.10/24
10.0.6.20/24
```

are not.

The key mental model:

```text
CIDR
→ determines subnet size

network address
→ identifies the subnet

host address
→ identifies a device

broadcast
→ addresses all hosts in the subnet
```

And:

```text
same subnet
→ direct communication

different subnet
→ routing required
```
