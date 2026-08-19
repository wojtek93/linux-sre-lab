# NET-18 MTU and Path MTU

## Goal

Understand what MTU is, how packet fragmentation works, how to test the maximum packet size with `ping`, how to inspect Path MTU with `tracepath`, and how routing and MTU interact during network troubleshooting.

---

## What is MTU?

MTU = Maximum Transmission Unit.

MTU defines the maximum size of an IP packet that can be transmitted through a network interface without fragmentation.

Typical Ethernet MTU:

```text
1500 bytes
```

In this lab, the main interface showed:

```text
enp0s1
MTU 1500
```

---

## Check interface MTU

Command:

```bash
ip link show enp0s1
```

Example:

```text
enp0s1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
```

This means:

```text
interface = enp0s1
MTU       = 1500 bytes
```

---

## Check interfaces in short format

Command:

```bash
ip -br link
```

This provides a shorter overview of interfaces and their state.

Example:

```text
lo      UNKNOWN
enp0s1  UP
```

---

## What is fragmentation?

Fragmentation means splitting a packet that is too large into smaller pieces.

Example:

```text
packet size = 2000 bytes
MTU         = 1500 bytes
```

The packet cannot pass through the interface as one piece.

Simplified flow:

```text
2000-byte packet
↓
packet too large
↓
fragmentation
↓
fragment 1
fragment 2
↓
destination reassembles fragments
```

---

## Why fragmentation exists

Different network links can have different MTU values.

Example:

```text
host network MTU = 1500
↓
another network MTU = 1400
```

If a packet is larger than the next link allows, it may need to be fragmented.

---

## Test MTU with ping

Command:

```bash
ping -c 3 -M do -s 1472 8.8.8.8
```

Options:

```text
-c 3   = send 3 packets
-M do  = do not allow fragmentation
-s     = ICMP payload size
```

Destination:

```text
8.8.8.8
```

---

## What does -c mean?

Example:

```bash
-c 3
```

`-c` means:

```text
count
```

The command sends exactly three ICMP Echo Requests and then stops.

---

## What does -M do mean?

Example:

```bash
-M do
```

This tells the kernel not to fragment the packet.

Simplified meaning:

```text
packet fits
↓
send it
```

or:

```text
packet too large
↓
do not fragment
↓
return an error
```

This makes `ping -M do` useful for MTU troubleshooting.

---

## What does -s mean?

Example:

```bash
-s 1472
```

`-s` defines the ICMP payload size.

It does not represent the complete IP packet.

For IPv4, additional headers are added:

```text
20 bytes IPv4 header
8 bytes ICMP header
```

Total overhead:

```text
28 bytes
```

---

## Calculate packet size

For IPv4:

```text
ICMP payload
+
IPv4 header
+
ICMP header
=
total IP packet size
```

Example:

```text
1472
+ 20
+ 8
----
1500
```

This exactly matches an MTU of 1500.

---

## Successful MTU test

Command:

```bash
ping -c 3 -M do -s 1472 8.8.8.8
```

The lab result showed successful replies.

Meaning:

```text
1472 payload
+ 28 bytes headers
= 1500 bytes
```

The packet fits exactly within the interface MTU.

---

## Packet too large

Command:

```bash
ping -c 3 -M do -s 1473 8.8.8.8
```

The result showed:

```text
Message too long
```

Calculation:

```text
1473
+ 28
----
1501
```

The packet exceeds MTU 1500 by one byte.

Because fragmentation was disabled with:

```text
-M do
```

the kernel could not split the packet.

---

## Key MTU boundary

For IPv4 with MTU 1500:

```text
maximum ICMP payload = 1472
```

Because:

```text
1500 - 20 - 8 = 1472
```

So:

```text
-s 1472
→ works

-s 1473
→ too large
```

---

## MTU vs payload

Important distinction:

```text
MTU = whole IP packet size
```

while:

```text
ping -s = ICMP payload size
```

This is why the maximum `ping -s` value is smaller than the MTU.

---

## What is Path MTU?

PMTU = Path Maximum Transmission Unit.

PMTU is the largest packet that can travel across the entire network path without fragmentation.

The important rule is:

```text
PMTU = smallest MTU anywhere on the path
```

---

## Path MTU example

Example network path:

```text
host MTU   = 1500
router 1   = 1500
router 2   = 1400
router 3   = 1500
destination
```

Path MTU is:

```text
1400
```

because the smallest MTU along the path determines the maximum packet size.

---

## Check Path MTU

Command:

```bash
tracepath 8.8.8.8
```

In this lab, the output showed:

```text
pmtu 1500
```

and at the end:

```text
Resume: pmtu 1500
```

This means the Path MTU to `8.8.8.8` was 1500 bytes.

---

## MTU vs PMTU

MTU:

```text
maximum packet size on one interface
```

PMTU:

```text
maximum packet size across the full network path
```

Example:

```text
local interface MTU = 1500
PMTU                 = 1400
```

This means the local interface supports 1500-byte packets, but somewhere along the path there is a smaller MTU.

---

## tracepath output

Example:

```text
1?: [LOCALHOST] pmtu 1500
1:  gateway
2:  ...
3:  no reply
```

`tracepath` shows:

```text
network hops
latency
Path MTU information
```

---

## no reply in tracepath

A line such as:

```text
no reply
```

does not always mean network failure.

Some routers do not respond to diagnostic packets while still forwarding traffic normally.

So:

```text
no reply
```

may simply mean:

```text
router does not send diagnostic response
```

---

## Check routing path

Command:

```bash
ip route get 8.8.8.8
```

The lab returned:

```text
8.8.8.8 via 192.168.64.1 dev enp0s1 src 192.168.64.2
```

This shows how Linux will route traffic to the destination.

---

## Read ip route get output

Destination:

```text
8.8.8.8
```

Gateway:

```text
via 192.168.64.1
```

Meaning:

```text
send the packet through this next-hop router
```

Interface:

```text
dev enp0s1
```

Meaning:

```text
the packet leaves through enp0s1
```

Source address:

```text
src 192.168.64.2
```

Meaning:

```text
Linux selects this IP as the source address
```

---

## Complete routing flow

The result can be read as:

```text
source:
192.168.64.2
↓
interface:
enp0s1
↓
gateway:
192.168.64.1
↓
internet
↓
destination:
8.8.8.8
```

---

## MTU and routing together

In this lab:

```text
enp0s1 MTU = 1500
```

Routing showed:

```text
traffic to 8.8.8.8
↓
uses enp0s1
```

And `tracepath` showed:

```text
PMTU = 1500
```

So:

```text
local MTU = 1500
Path MTU  = 1500
```

There was no smaller MTU discovered along the route.

---

## Why MTU problems can be difficult

MTU problems can be deceptive because small packets may work while larger packets fail.

Example:

```text
ping works
SSH connection starts
small HTTP request works
```

but:

```text
large HTTP response hangs
file transfer stalls
TLS connection behaves strangely
```

This can happen when packets exceed the Path MTU.

---

## MTU problem example

Imagine:

```text
host MTU = 1500
↓
router = 1500
↓
VPN tunnel = 1400
↓
destination
```

Then:

```text
PMTU = 1400
```

Packets smaller than 1400 may work.

Larger packets may require fragmentation or fail if fragmentation-related mechanisms do not work correctly.

---

## MTU in tunnels and cloud networks

MTU is especially important with:

```text
VPN
VXLAN
Docker networking
Kubernetes networking
cloud networking
overlay networks
```

These technologies may add additional headers around packets.

Extra headers reduce the space available for the original packet.

---

## Encapsulation example

Simplified:

```text
original packet
↓
VPN / tunnel headers added
↓
larger packet
```

If the resulting packet exceeds the underlying MTU:

```text
fragmentation may be required
```

or the packet may fail.

---

## MTU troubleshooting workflow

If an application behaves strangely across the network:

```text
application works locally
↓
small packets work
↓
larger transfers fail
↓
suspect MTU / PMTU
```

Then check:

```bash
ip link
```

for interface MTU.

Test:

```bash
ping -M do -s SIZE destination
```

Then:

```bash
tracepath destination
```

to inspect Path MTU.

Finally:

```bash
ip route get destination
```

to determine the actual route and interface.

---

## Practical troubleshooting flow

```text
network problem
↓
identify route
↓
ip route get
↓
identify outgoing interface
↓
ip link
↓
check interface MTU
↓
ping -M do
↓
test packet size
↓
tracepath
↓
check Path MTU
```

---

## Key commands

```bash
ip link

ip -br link

ip link show enp0s1

ping -c 3 -M do -s 1472 8.8.8.8

ping -c 3 -M do -s 1473 8.8.8.8

tracepath 8.8.8.8

ip route get 8.8.8.8

ip route
```

---

## Key takeaways

```text
MTU = Maximum Transmission Unit
MTU defines the maximum IP packet size on an interface
Ethernet commonly uses MTU 1500

fragmentation splits oversized IP packets into smaller fragments
-M do disables fragmentation during ping tests
-s defines ICMP payload size

IPv4 header = 20 bytes
ICMP header = 8 bytes

for MTU 1500:
1472 + 28 = 1500
1473 + 28 = 1501

PMTU = Path Maximum Transmission Unit
PMTU is the smallest MTU across the entire network path

ip link shows interface MTU
ping -M do tests packet-size limits
tracepath can discover Path MTU
ip route get shows the selected route, gateway, interface and source IP

small packets working does not prove that MTU is correct
MTU problems may appear during large transfers, TLS, VPN or overlay networking
```

Short interview answer:

```text
MTU is the maximum IP packet size that can be sent through a network interface
without fragmentation.

Path MTU is the smallest MTU across the entire path to the destination.

I can check interface MTU with ip link, test packet-size limits with
ping -M do -s, inspect Path MTU with tracepath, and determine the actual
network path with ip route get.
```
