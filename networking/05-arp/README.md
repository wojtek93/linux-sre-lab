# NET-05 — ARP and Neighbor Discovery Basics

## Goal

Understand what ARP does, why Linux needs MAC addresses in a local network, how ARP interacts with routing, and how to inspect neighbor state with `ip neigh`.

---

## What is ARP?

ARP means:

```text
Address Resolution Protocol
```

Its basic job is:

```text
IP address
→
MAC address
```

A simple mental model:

```text
ARP = "I know the IP, but I need the MAC"
```

ARP is used inside the local network.

---

## Why is ARP Needed?

IP routing uses IP addresses.

Ethernet communication inside the local network uses MAC addresses.

Example:

```text
Host A
IP: 192.168.1.10

Host B
IP: 192.168.1.20
MAC: aa:bb:cc:dd:ee:ff
```

Host A wants to send traffic to:

```text
192.168.1.20
```

Because Host B is in the same subnet, Host A needs Host B's MAC address.

Host A sends an ARP request:

```text
Who has 192.168.1.20?
```

Host B replies:

```text
192.168.1.20 is at aa:bb:cc:dd:ee:ff
```

Host A can then send the Ethernet frame to that MAC address.

---

## Same Subnet

Example:

```text
Host A: 192.168.1.10/24
Host B: 192.168.1.50/24
```

Both hosts belong to:

```text
192.168.1.0/24
```

So communication is direct.

Flow:

```text
Host A
↓
destination is local
↓
ARP for Host B
↓
find Host B MAC
↓
send Ethernet frame directly to Host B
```

Mental rule:

```text
same subnet
→ ARP for destination
```

---

## Different Subnet

Example:

```text
Host A:      192.168.1.10/24
Gateway:     192.168.1.1
Destination: 8.8.8.8
```

`8.8.8.8` is not inside:

```text
192.168.1.0/24
```

So Host A must send traffic to the gateway.

Host A does NOT need the MAC address of:

```text
8.8.8.8
```

Instead it needs the MAC address of:

```text
192.168.1.1
```

Flow:

```text
destination = 8.8.8.8
↓
destination is outside local subnet
↓
route says use gateway 192.168.1.1
↓
ARP for 192.168.1.1
↓
find gateway MAC
↓
send Ethernet frame to gateway
↓
router forwards packet
```

Mental rule:

```text
different subnet
→ ARP for gateway
```

---

## IP vs MAC

Think about the two addresses separately.

```text
IP
→ logical network address
→ used for routing

MAC
→ local link address
→ used for Ethernet delivery
```

Example:

```text
IP:  192.168.1.20
MAC: aa:bb:cc:dd:ee:ff
```

ARP connects these two pieces of information.

---

## Check Neighbor Table

On Linux:

```bash
ip neigh
```

Example:

```text
192.168.1.1 dev eth0 lladdr 00:11:22:33:44:55 REACHABLE
192.168.1.20 dev eth0 lladdr aa:bb:cc:dd:ee:ff STALE
```

Read:

```text
192.168.1.20
→ neighbor IP

dev eth0
→ local interface used

lladdr aa:bb:cc:dd:ee:ff
→ neighbor MAC address

STALE
→ neighbor entry exists but has not been recently confirmed
```

---

## Important Neighbor States

### REACHABLE

```text
REACHABLE
```

means Linux recently confirmed that the neighbor is reachable.

Usually:

```text
OK
```

---

## STALE

```text
STALE
```

does not automatically mean a problem.

It means:

```text
Linux knows the MAC
but has not recently reconfirmed the neighbor
```

The entry can still be used.

---

## DELAY / PROBE

These states mean Linux is in the process of checking whether the neighbor is still reachable.

```text
DELAY
PROBE
```

For basic troubleshooting, you usually do not need to analyze them deeply.

---

## FAILED

Example:

```text
192.168.1.50 dev eth0 FAILED
```

This means Linux failed to resolve or confirm the neighbor.

Possible causes:

```text
host is down
wrong subnet
wrong VLAN
interface problem
local network problem
ARP request or reply does not reach the host
```

Important:

```text
FAILED
→ this is a Layer 2 / neighbor problem
```

Do not immediately investigate TCP ports.

ARP resolution happens before TCP communication can work to a local next hop.

---

## Failed Gateway

Example:

```text
192.168.1.1 dev eth0 FAILED
```

If `192.168.1.1` is the default gateway, this is especially important.

Suppose:

```text
Host:        192.168.1.10/24
Gateway:     192.168.1.1
Destination: 8.8.8.8
```

The host needs the gateway to reach external networks.

If ARP for the gateway fails:

```text
Host cannot determine gateway MAC
↓
cannot send Ethernet frame to gateway
↓
cannot reach remote networks
```

So:

```text
FAILED for local host
→ cannot reach that local neighbor

FAILED for gateway
→ may not be able to reach other networks
```

---

## Useful Commands

Show neighbors:

```bash
ip neigh
```

Older tool:

```bash
arp -n
```

Show interfaces:

```bash
ip addr
```

Show interface link state:

```bash
ip link
```

Show routing table:

```bash
ip route
```

Test neighbor reachability:

```bash
ping 192.168.1.50
```

---

## Capture ARP Traffic

To see ARP requests and replies:

```bash
sudo tcpdump -i eth0 arp
```

You may see something conceptually similar to:

```text
Who has 192.168.1.50?
Tell 192.168.1.10
```

followed by:

```text
192.168.1.50 is-at aa:bb:cc:dd:ee:ff
```

This is useful when troubleshooting local connectivity.

---

## ARP and Routing Together

Routing decides:

```text
Who is my next hop?
```

ARP decides:

```text
What MAC address does that next hop have?
```

Example 1:

```text
destination: 192.168.1.50
same subnet
```

Routing decision:

```text
direct
```

ARP decision:

```text
find MAC of 192.168.1.50
```

Example 2:

```text
destination: 8.8.8.8
different subnet
gateway: 192.168.1.1
```

Routing decision:

```text
send through 192.168.1.1
```

ARP decision:

```text
find MAC of 192.168.1.1
```

This gives an important combined mental model:

```text
Routing
→ determines next hop

ARP
→ determines MAC of that next hop
```

---

## Troubleshooting Flow

If a local neighbor cannot be reached:

```text
1. Check interface

ip link

2. Check IP configuration

ip addr

3. Check route

ip route
ip route get <destination>

4. Check neighbor state

ip neigh

5. Test reachability

ping <destination>

6. If needed, capture ARP

sudo tcpdump -i eth0 arp
```

---

## Layer Model

ARP belongs to local network communication.

For the simplified OSI troubleshooting model:

```text
L3 → IP / routing
L2 → ARP / MAC / Ethernet
```

So:

```text
routing
→ where should I send?

ARP
→ which local MAC should receive it?
```

---

## Practical Example

Host:

```text
192.168.1.10/24
```

Destination:

```text
192.168.1.50
```

Steps:

```text
1. Is destination in my subnet?
   YES

2. Next hop?
   Destination itself

3. Do I know its MAC?
   Check neighbor cache

4. If not:
   Send ARP request

5. Receive ARP reply

6. Send Ethernet frame to destination MAC
```

---

## Remote Destination Example

Host:

```text
192.168.1.10/24
```

Destination:

```text
10.20.5.10
```

Gateway:

```text
192.168.1.1
```

Steps:

```text
1. Is destination in my subnet?
   NO

2. Next hop?
   Gateway 192.168.1.1

3. Do I know gateway MAC?
   Check neighbor cache

4. If not:
   ARP for 192.168.1.1

5. Send Ethernet frame to gateway MAC

6. Router forwards IP packet toward 10.20.5.10
```

---

## Quick Reference

```text
ARP
→ IP to MAC

ip neigh
→ show neighbor cache

same subnet
→ ARP for destination

different subnet
→ ARP for gateway

REACHABLE
→ recently confirmed

STALE
→ cached, not recently confirmed

FAILED
→ neighbor resolution failed
```

Most important relationship:

```text
Routing chooses next hop
ARP finds next hop MAC
```

---

## Interview Notes

If asked:

```text
Why does a host need ARP?
```

Answer:

```text
Because IP routing identifies the next-hop IP address,
but Ethernet delivery on the local network requires
the next-hop MAC address.
ARP resolves that IP address to a MAC address.
```

If destination is local:

```text
ARP destination
```

If destination is remote:

```text
ARP gateway
```

If:

```bash
ip neigh
```

shows:

```text
FAILED
```

investigate local Layer 2 connectivity before jumping directly to application ports.
