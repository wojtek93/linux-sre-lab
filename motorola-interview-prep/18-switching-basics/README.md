# MOT-18 — Switching Basics

## Goal

Review basic Layer 2 switching concepts required for Linux Platform troubleshooting:

- switch vs router
- MAC addresses
- MAC address table
- unknown destination MAC
- VLANs
- inter-VLAN communication

---

## Switch vs Router

A switch operates mainly at Layer 2.

It uses:

```text
MAC addresses
MAC address table
```

to forward Ethernet frames to the appropriate ports.

A router operates at Layer 3.

It uses:

```text
IP addresses
routing table
```

to route packets between networks.

Mental model:

```text
Switch → L2 → MAC → frames
Router → L3 → IP → packets
```

Interview answer:

> A switch operates mainly at Layer 2. It uses MAC addresses and a MAC address table to forward frames to the appropriate ports. A router operates at Layer 3 and uses IP addresses and a routing table to route packets between networks.

---

## MAC Address Table

A switch maintains a MAC address table.

Example:

```text
MAC address          Port
AA:AA:AA:AA:AA:01    port1
BB:BB:BB:BB:BB:02    port4
```

The table maps:

```text
MAC address → switch port
```

This allows the switch to forward a frame only to the appropriate port.

---

## MAC Learning

Switches learn MAC addresses automatically.

When a frame arrives, the switch examines the source MAC address and records:

```text
source MAC → incoming port
```

Example:

```text
Frame arrives on port1
Source MAC = AA:AA:AA:AA:AA:01
```

The switch learns:

```text
AA:AA:AA:AA:AA:01 → port1
```

---

## Unknown Destination MAC

If the destination MAC is not present in the MAC address table, the switch does not yet know the correct destination port.

It floods the frame to the other relevant ports within the same VLAN.

At the same time, it learns the source MAC address.

Interview answer:

> If the destination MAC is unknown, the switch floods the frame within the VLAN, while learning the source MAC address on the incoming port.

---

## VLAN

A VLAN logically separates Layer 2 networks while allowing them to use the same physical switching infrastructure.

Example:

```text
VLAN 10 → users
VLAN 20 → servers
VLAN 30 → management
```

VLAN is NOT IP-to-MAC mapping.

IP-to-MAC resolution is associated with ARP in IPv4.

VLAN means:

```text
logical Layer 2 network separation
```

Interview answer:

> VLANs are used to logically separate Layer 2 networks on the same physical switching infrastructure.

---

## Communication Between VLANs

Hosts in the same VLAN can communicate through Layer 2 switching.

Example:

```text
Host A ── VLAN 10 ── Host B
```

Hosts in different VLANs cannot communicate directly at Layer 2.

Example:

```text
Host A → VLAN 10

Host B → VLAN 20
```

Communication between them requires Layer 3 routing.

This can be provided by:

```text
router
or
Layer 3 switch
```

This is called:

```text
inter-VLAN routing
```

Interview answer:

> Hosts in different VLANs cannot communicate directly at Layer 2. They need a router or Layer 3 switch to route traffic between the VLANs.

---

## Quick Recall

```text
Switch
→ Layer 2
→ MAC addresses
→ Ethernet frames

Router
→ Layer 3
→ IP addresses
→ packets

MAC table
→ MAC address → switch port

Unknown destination MAC
→ flood within VLAN

VLAN
→ logical separation of Layer 2 networks

Same VLAN
→ Layer 2 communication possible

Different VLANs
→ Layer 3 routing required
```

## Key Interview Sentence

> A switch uses MAC addresses to forward frames at Layer 2, while a router uses IP addresses to route packets at Layer 3. VLANs logically separate Layer 2 networks, and communication between different VLANs requires routing.
