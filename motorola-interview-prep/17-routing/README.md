# MOT-17 — Routing

## Goal

Review Linux routing fundamentals required for troubleshooting:

- inspect interface addressing
- inspect routing table
- understand default gateway
- understand longest-prefix match
- understand route metrics
- check which route Linux would use for a destination

---

## Check Interface Configuration

Use:

```bash
ip addr
```

This shows:

- network interfaces
- IPv4 / IPv6 addresses
- interface state
- prefix length
- link information

Example:

```text
inet 192.168.64.2/24
```

This means the host has:

```text
IP address: 192.168.64.2
Network:    192.168.64.0/24
```

---

## Check Routing Table

Use:

```bash
ip route
```

Example:

```text
default via 192.168.64.1 dev enp0s1 proto dhcp src 192.168.64.2 metric 100
192.168.64.0/24 dev enp0s1 proto kernel scope link src 192.168.64.2 metric 100
172.17.0.0/16 dev docker0
```

---

## Default Route

Example:

```text
default via 192.168.64.1 dev enp0s1
```

Meaning:

```text
default          → route used when no more specific route matches
192.168.64.1     → default gateway
enp0s1           → outgoing interface
```

A default route is equivalent conceptually to:

```text
0.0.0.0/0
```

---

## Longest-Prefix Match

Linux selects the most specific matching route.

Example routing table:

```text
default via 192.168.64.1
192.168.64.0/24 dev enp0s1
```

Destination:

```text
192.168.64.50
```

Linux chooses:

```text
192.168.64.0/24 dev enp0s1
```

because `/24` is more specific than `/0`.

Rule:

```text
longer matching prefix = more specific route
```

For:

```text
8.8.8.8
```

if there is no more specific route, Linux uses:

```text
default via 192.168.64.1
```

Interview answer:

> Linux uses longest-prefix match. It selects the most specific matching route, and if none matches, it uses the default route.

---

## Missing Default Route

If a host has a valid IP address but no default route, it may still communicate with hosts in the local subnet.

However, it may not know where to send packets destined for external networks.

Example symptom:

```text
local network works
internet / remote network does not
```

Check:

```bash
ip route
```

Expected example:

```text
default via 192.168.64.1 dev enp0s1
```

Possible causes:

- DHCP did not configure a gateway
- incorrect static network configuration
- default route was removed
- wrong interface configuration
- incorrect gateway

Interview answer:

> If the host has an IP address but no default route, it may reach the local subnet but not external networks. I would check the gateway and routing configuration.

---

## Check Route to a Specific Destination

Use:

```bash
ip route get 8.8.8.8
```

Example:

```text
8.8.8.8 via 192.168.64.1 dev enp0s1 src 192.168.64.2
```

Meaning:

```text
destination → 8.8.8.8
gateway     → 192.168.64.1
interface   → enp0s1
source IP   → 192.168.64.2
```

This command is useful when troubleshooting which path Linux intends to use.

---

## Route Metric

Example:

```text
default via 192.168.64.1 metric 100
default via 10.0.0.1 metric 200
```

If both routes have the same prefix length, Linux normally prefers the route with the lower metric.

```text
metric 100 → preferred
metric 200 → less preferred
```

Routing decision:

```text
1. longest matching prefix
2. if prefix length is equal → lower metric
```

Interview answer:

> Linux first chooses the most specific route using longest-prefix match. If multiple routes have the same prefix length, the route with the lower metric is preferred.

---

## Practical Troubleshooting Flow

```text
Connectivity problem
        ↓
ip addr
        ↓
Does the interface have the expected IP?
        ↓
ip route
        ↓
Is the expected network route present?
        ↓
Is there a default route?
        ↓
ip route get <destination>
        ↓
Is Linux choosing the expected gateway/interface?
```

Useful commands:

```bash
ip addr
ip route
ip route get 8.8.8.8
```

---

## Interview Quick Recall

```text
ip addr
→ interface addresses

ip route
→ routing table

default via ...
→ default gateway

longest-prefix match
→ most specific matching route wins

same prefix length
→ lower metric preferred

ip route get <IP>
→ show which route Linux would use
```

## Key Interview Sentence

> Linux selects routes using longest-prefix match. If no specific route matches, it uses the default route. If multiple routes have the same prefix length, the lower metric is normally preferred.
