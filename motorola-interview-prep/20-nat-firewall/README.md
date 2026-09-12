# MOT-20 — NAT and Firewall

## Goal

Review basic NAT and firewall concepts required for Linux / Platform troubleshooting:

- SNAT
- DNAT
- MASQUERADE
- firewall ACCEPT / DROP / REJECT
- iptables
- nftables
- troubleshooting blocked traffic

---

## NAT

NAT means:

```text
Network Address Translation
```

It changes addressing information in network traffic.

The most important types:

```text
SNAT → changes source address
DNAT → changes destination address
MASQUERADE → dynamic form of SNAT
```

---

## SNAT

SNAT means:

```text
Source Network Address Translation
```

It changes the source address of outgoing traffic.

Example:

```text
192.168.1.50
        ↓
      SNAT
        ↓
83.x.x.x
```

A private host sends traffic to the Internet.

The router replaces:

```text
source IP = 192.168.1.50
```

with its public IP address.

Typical use:

```text
private network → Internet
```

Interview answer:

> SNAT changes the source address of a packet, for example when private hosts access the Internet through a router.

---

## MASQUERADE

MASQUERADE is a special form of SNAT.

It is commonly used when the external interface IP can change dynamically.

Example:

```text
LAN
↓
router
↓
dynamic public IP
↓
Internet
```

The system automatically uses the current IP of the outgoing interface.

Mental model:

```text
MASQUERADE ≈ dynamic SNAT
```

---

## DNAT

DNAT means:

```text
Destination Network Address Translation
```

It changes the destination address or destination port.

Example:

```text
public_IP:8080
       ↓
      DNAT
       ↓
192.168.1.50:80
```

Traffic arriving at the public IP on port 8080 is redirected to an internal host on port 80.

Typical use:

```text
external traffic → internal service
```

Interview answer:

> DNAT changes the destination address or port, for example when forwarding traffic from a public IP to an internal server.

---

## SNAT vs DNAT

```text
SNAT
→ changes source

DNAT
→ changes destination
```

Example:

```text
192.168.1.50 → Internet
```

If the private source IP becomes a public IP:

```text
SNAT
```

Example:

```text
public_IP:8080
↓
192.168.1.50:80
```

This is:

```text
DNAT
```

---

## Firewall

A firewall decides whether network traffic should be allowed or blocked.

Typical actions:

```text
ACCEPT
DROP
REJECT
```

---

## ACCEPT

```text
ACCEPT
→ allow traffic
```

---

## DROP

```text
DROP
→ silently discard packet
```

The sender normally receives no immediate response.

Typical symptom:

```text
timeout
```

Interview answer:

> DROP silently discards the packet, so the client normally waits until the connection times out.

---

## REJECT

```text
REJECT
→ actively refuse traffic
```

The sender receives an error response.

Typical symptom may be an immediate rejection rather than waiting for a timeout.

Interview answer:

> REJECT actively refuses the traffic and sends an error response back to the sender.

---

## DROP vs REJECT

```text
DROP
→ silent
→ usually timeout

REJECT
→ active rejection
→ immediate error response
```

---

## Check iptables Rules

List firewall rules:

```bash
sudo iptables -L -n
```

Options:

```text
-L → list rules
-n → numeric output
```

More details:

```bash
sudo iptables -L -n -v
```

`-v` shows additional information such as packet and byte counters.

Look for actions such as:

```text
ACCEPT
DROP
REJECT
```

---

## nftables

Modern Linux systems may use nftables instead of traditional iptables.

Show current rules:

```bash
sudo nft list ruleset
```

---

## Troubleshooting Example

Situation:

```text
application is running
ss shows port 8080 is listening
remote client gets timeout
```

We already know:

```text
service exists
listener exists
```

One of the next checks should be the firewall.

Commands:

```bash
sudo iptables -L -n -v
```

or:

```bash
sudo nft list ruleset
```

Look for rules blocking:

```text
destination port
source IP
interface
protocol
```

---

## Troubleshooting Logic

```text
service unreachable
        ↓
is service listening?
        ↓
yes
        ↓
is routing correct?
        ↓
yes
        ↓
check firewall
        ↓
DROP / REJECT?
```

Possible interpretation:

```text
timeout
→ possible DROP
→ routing problem
→ host unreachable
→ network path problem
```

```text
immediate rejection
→ possible REJECT
→ service actively refusing connection
```

---

## NAT vs Firewall

They perform different functions.

```text
NAT
→ changes addresses or ports

Firewall
→ decides whether traffic is allowed
```

A system can use both at the same time.

Example:

```text
Internet
↓
DNAT
↓
firewall check
↓
internal application
```

---

## Quick Recall

```text
SNAT
→ Source NAT
→ changes source IP

DNAT
→ Destination NAT
→ changes destination IP / port

MASQUERADE
→ dynamic SNAT

ACCEPT
→ allow

DROP
→ silently discard
→ usually timeout

REJECT
→ actively reject
→ error returned

iptables -L -n
→ list firewall rules numerically

iptables -L -n -v
→ detailed rules + counters

nft list ruleset
→ inspect nftables rules
```

## Key Interview Sentence

> SNAT changes the source address, DNAT changes the destination address or port, and MASQUERADE is a dynamic form of SNAT. For firewall troubleshooting, I check whether traffic is being accepted, dropped or rejected using iptables or nftables.
