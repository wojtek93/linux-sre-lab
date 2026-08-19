# NET-20 End-to-End Network Troubleshooting

## Goal

Understand how to troubleshoot a network problem where an application works locally but cannot be reached through the host network address.

The objective is to diagnose the problem step by step instead of assuming that the application, firewall or routing is responsible.

Main troubleshooting flow:

```text
application
↓
process
↓
listening socket
↓
bind address
↓
firewall
↓
routing
↓
connectivity
```

---

## Scenario

A simple HTTP server runs on TCP port `9090`.

At first:

```text
curl localhost
→ works
```

but:

```text
curl host IP
→ fails
```

Possible causes include:

```text
application not running
wrong listening port
application bound only to localhost
firewall blocking traffic
incorrect routing
network interface problem
```

The lab investigates these possibilities one by one.

---

## Start HTTP server on localhost only

Command:

```bash
python3 -m http.server 9090 --bind 127.0.0.1
```

Important option:

```text
--bind 127.0.0.1
```

This tells the application to listen only on the loopback address.

---

## What is 127.0.0.1?

`127.0.0.1` is the IPv4 loopback address.

It is commonly called:

```text
localhost
```

Traffic to this address stays on the local host.

Simplified:

```text
application
↓
127.0.0.1
↓
same machine
```

Another machine cannot reach a service through the target machine's `127.0.0.1`.

---

## Test locally

Command:

```bash
curl -I http://127.0.0.1:9090
```

The response returned:

```text
HTTP/1.0 200 OK
```

This confirmed that:

```text
application is running
port 9090 works locally
HTTP server responds
```

However, this alone does not prove that the service is reachable through the network interface.

---

## Check listening socket

Command:

```bash
sudo ss -tlnp sport = :9090
```

Options:

```text
-t = TCP
-l = listening sockets
-n = numeric addresses and ports
-p = process information
```

The important field is:

```text
Local Address:Port
```

The output showed:

```text
127.0.0.1:9090
```

---

## What does 127.0.0.1:9090 mean?

It means the application is listening only on:

```text
localhost
```

Flow:

```text
curl 127.0.0.1:9090
↓
service listening there
↓
works
```

but:

```text
curl 192.168.64.2:9090
↓
service is not bound to this address
↓
fails
```

---

## Check host IP addresses

Command:

```bash
ip -br addr
```

The main network interface showed:

```text
enp0s1
192.168.64.2/24
```

This means the host has a network address:

```text
192.168.64.2
```

on interface:

```text
enp0s1
```

---

## Test using host IP

Command:

```bash
curl --connect-timeout 5 http://192.168.64.2:9090
```

The request failed.

This was expected because the application was listening only on:

```text
127.0.0.1:9090
```

and not on:

```text
192.168.64.2:9090
```

---

## Bind address problem

The first root cause was:

```text
wrong bind address
```

The application worked locally, but was not listening on the host network interface.

Important pattern:

```text
localhost works
+
host IP fails
+
ss shows 127.0.0.1
=
application bound only to loopback
```

---

## 127.0.0.1 vs 0.0.0.0

Important distinction:

```text
127.0.0.1
= only localhost
```

```text
0.0.0.0
= all local IPv4 interfaces
```

```text
192.168.64.2
= one specific local network address
```

---

## Fix bind address

The original server was stopped.

Then it was restarted with:

```bash
python3 -m http.server 9090 --bind 0.0.0.0
```

This tells the application to listen on all local IPv4 interfaces.

---

## Verify new listener

Command:

```bash
sudo ss -tlnp sport = :9090
```

The result showed:

```text
0.0.0.0:9090
```

Meaning:

```text
service listens on port 9090
through all local IPv4 interfaces
```

---

## Test localhost again

Command:

```bash
curl -I http://127.0.0.1:9090
```

Result:

```text
HTTP/1.0 200 OK
```

The application still worked locally.

---

## Test host IP after fixing bind

Command:

```bash
curl -I http://192.168.64.2:9090
```

Result:

```text
HTTP/1.0 200 OK
```

Now the application worked using the host network address.

---

## Bind troubleshooting pattern

Before:

```text
LISTEN 127.0.0.1:9090
```

Result:

```text
localhost works
host IP fails
```

After:

```text
LISTEN 0.0.0.0:9090
```

Result:

```text
localhost works
host IP works
```

---

## Second failure scenario: firewall

After fixing the bind address, another controlled failure was created.

The application remained correctly listening on:

```text
0.0.0.0:9090
```

but firewall traffic to the port was blocked.

---

## Add firewall DROP rule

Command:

```bash
sudo iptables -I INPUT 1 -p tcp --dport 9090 -j DROP
```

Meaning:

```text
-I INPUT 1
= insert rule at position 1 in INPUT chain
```

```text
-p tcp
= match TCP traffic
```

```text
--dport 9090
= match destination port 9090
```

```text
-j DROP
= silently discard matching packets
```

---

## Firewall flow

The rule created this behavior:

```text
incoming TCP packet
↓
destination port 9090
↓
iptables INPUT
↓
DROP
↓
packet discarded
```

The application itself remained healthy.

---

## Check firewall rules

Command:

```bash
sudo iptables -L -n -v --line-numbers
```

Options:

```text
-L = list rules
-n = numeric output
-v = verbose output
--line-numbers = show rule numbers
```

The rule showed traffic matching:

```text
tcp dpt:9090
```

with target:

```text
DROP
```

---

## Test through firewall DROP

Command:

```bash
curl --connect-timeout 5 http://192.168.64.2:9090
```

The result was a timeout.

This was different from the bind problem.

---

## Verify application is still listening

Command:

```bash
sudo ss -tlnp sport = :9090
```

The output still showed:

```text
0.0.0.0:9090
```

This is a critical troubleshooting clue.

```text
service is LISTEN
+
bind address is correct
+
curl times out
=
look beyond the application
```

One possible cause is firewall filtering.

---

## Bind failure vs firewall failure

### Bind problem

```text
ss:
127.0.0.1:9090
```

Result:

```text
localhost works
host IP fails
```

Cause:

```text
application listens only on loopback
```

---

### Firewall problem

```text
ss:
0.0.0.0:9090
```

but:

```text
iptables:
DROP tcp dpt:9090
```

Result:

```text
application listens correctly
connection times out
```

Cause:

```text
firewall blocks traffic
```

---

## Remove firewall rule

The temporary test rule was removed:

```bash
sudo iptables -D INPUT 1
```

Then the rules were checked again:

```bash
sudo iptables -L -n -v --line-numbers
```

---

## Test after removing DROP

Command:

```bash
curl -I http://192.168.64.2:9090
```

The response again returned:

```text
HTTP/1.0 200 OK
```

This confirmed that the firewall rule caused the failure.

---

## Routing check

After checking the application and firewall, routing was inspected.

Command:

```bash
ip route get 192.168.64.2
```

The output showed:

```text
local 192.168.64.2 dev lo src 192.168.64.2
```

---

## Why does route use lo?

`192.168.64.2` is an IP address assigned to the same host.

Therefore Linux recognizes:

```text
destination = local address
```

and handles the traffic locally.

Simplified:

```text
source host
↓
destination is my own address
↓
local routing
↓
lo / local network stack
```

The packet does not need to travel to another machine.

---

## Local address vs remote destination

For the host's own address:

```bash
ip route get 192.168.64.2
```

Linux reports:

```text
local
```

For an internet destination such as:

```bash
ip route get 8.8.8.8
```

Linux normally chooses:

```text
interface
gateway
source address
```

Example:

```text
8.8.8.8
↓
enp0s1
↓
gateway
↓
internet
```

---

## Full routing table

Command:

```bash
ip route
```

The routing table showed entries including:

```text
default via 192.168.64.1 dev enp0s1
```

and:

```text
192.168.64.0/24 dev enp0s1
```

---

## Default route

Example:

```text
default via 192.168.64.1 dev enp0s1
```

Meaning:

```text
if no more specific route exists
↓
send traffic through gateway 192.168.64.1
↓
using interface enp0s1
```

---

## Local network route

Example:

```text
192.168.64.0/24 dev enp0s1
```

Meaning:

```text
destinations in 192.168.64.0/24
↓
are directly reachable
↓
through enp0s1
```

---

## Three separate troubleshooting layers

This lab demonstrated three different failure areas.

### 1. Application / bind

```text
process running
port listening
but only on 127.0.0.1
```

Problem:

```text
wrong bind address
```

---

### 2. Firewall

```text
process running
port listening on 0.0.0.0
but connection times out
```

Problem:

```text
iptables DROP
```

---

### 3. Routing

Routing determines:

```text
where the packet should go
which interface should be used
which gateway should be used
```

Commands:

```bash
ip route get DESTINATION
ip route
```

---

## End-to-end troubleshooting workflow

When an application is unreachable:

```text
application unreachable
↓
is process running?
↓
is port listening?
↓
what address is it bound to?
↓
is firewall blocking?
↓
what route will Linux use?
↓
is remote connectivity possible?
```

---

## Step 1: Check process and socket

Command:

```bash
sudo ss -tlnp sport = :9090
```

Possible results:

```text
no output
→ nothing is listening
```

```text
127.0.0.1:9090
→ service available only locally
```

```text
0.0.0.0:9090
→ service listens on all IPv4 interfaces
```

---

## Step 2: Test locally

Command:

```bash
curl -I http://127.0.0.1:9090
```

If this fails:

```text
look at application/process first
```

---

## Step 3: Test host network IP

Command:

```bash
curl -I http://192.168.64.2:9090
```

If localhost works but host IP fails:

```text
inspect bind address
firewall
routing
```

---

## Step 4: Check firewall

Command:

```bash
sudo iptables -L -n -v --line-numbers
```

Look for:

```text
DROP
REJECT
destination port
source restrictions
```

---

## Step 5: Check route

Command:

```bash
ip route get DESTINATION
```

This shows how Linux intends to reach a destination.

Then inspect the full routing table:

```bash
ip route
```

---

## Troubleshooting logic

### Case 1

```text
curl localhost fails
```

Investigate:

```text
application
process
port
```

---

### Case 2

```text
localhost works
host IP fails
ss shows 127.0.0.1
```

Investigate:

```text
bind address
```

---

### Case 3

```text
localhost works
host IP fails
ss shows 0.0.0.0
```

Investigate:

```text
firewall
routing
network path
```

---

### Case 4

```text
LISTEN exists
firewall looks correct
route looks correct
remote host still cannot connect
```

Continue with:

```text
packet capture
remote routing
upstream firewall
security groups
NAT
load balancer
network policies
```

depending on the environment.

---

## Useful tools by layer

Application:

```bash
ps
systemctl
curl
```

Sockets:

```bash
ss
```

IP addresses:

```bash
ip -br addr
```

Firewall:

```bash
iptables
```

Routing:

```bash
ip route
ip route get
```

Packet level:

```bash
tcpdump
```

---

## Key commands

```bash
python3 -m http.server 9090 --bind 127.0.0.1

curl -I http://127.0.0.1:9090

sudo ss -tlnp sport = :9090

ip -br addr

curl --connect-timeout 5 http://192.168.64.2:9090

python3 -m http.server 9090 --bind 0.0.0.0

curl -I http://192.168.64.2:9090

sudo iptables -I INPUT 1 -p tcp --dport 9090 -j DROP

sudo iptables -L -n -v --line-numbers

sudo iptables -D INPUT 1

ip route get 192.168.64.2

ip route
```

---

## Key takeaways

```text
127.0.0.1 means localhost only

0.0.0.0 means all local IPv4 interfaces

localhost working does not prove remote connectivity works

ss shows whether a service is listening and on which address

LISTEN on 127.0.0.1 can explain why remote access fails

LISTEN on 0.0.0.0 means the application accepts connections through all IPv4 interfaces

iptables DROP can block traffic even when the application is healthy

DROP silently discards matching packets and usually causes a timeout

ip route get shows how Linux will route traffic to a specific destination

ip route shows the routing table

application, firewall and routing are separate troubleshooting layers

troubleshoot layer by layer instead of guessing
```

Short interview answer:

```text
If an application works on localhost but is unreachable remotely, I first
verify that the process is running and inspect the listening socket with ss.

I check whether the application is bound only to 127.0.0.1 or to an externally
reachable address such as 0.0.0.0.

If the bind address is correct, I inspect firewall rules and then routing with
iptables, ip route get and ip route.

This lets me separate application, firewall and network-path problems instead
of assuming the network is the cause.
```
