# NET-06 — DNS Basics and Troubleshooting

## Goal

Understand how DNS resolves names to IP addresses, how Linux uses resolvers, how to inspect DNS records, how TTL and cache work, and how to diagnose common DNS failures.

---

## What is DNS?

DNS means:

```text
Domain Name System
```

Its basic job is:

```text
hostname
→
IP address
```

Example:

```text
google.pl
→
142.250.x.x
```

Without DNS, applications would have to use IP addresses directly.

---

## DNS Resolver

A resolver is a service that performs DNS lookups for applications.

Example flow:

```text
application
↓
local resolver
↓
upstream DNS server
↓
authoritative DNS
↓
answer
```

On many Linux systems you may see:

```text
127.0.0.53
```

as the local resolver.

Example:

```bash
nslookup google.pl
```

may show:

```text
Server:  127.0.0.53
Address: 127.0.0.53#53
```

This means:

```text
DNS resolver: 127.0.0.53
DNS port:     53
```

---

## Common DNS Records

### A

Maps a hostname to an IPv4 address.

```text
app.example.com
→ A
→ 10.0.0.20
```

Query:

```bash
dig A example.com
```

---

## AAAA

Maps a hostname to an IPv6 address.

```text
example.com
→ AAAA
→ 2001:db8::10
```

Query:

```bash
dig AAAA example.com
```

---

## CNAME

CNAME is an alias to another hostname.

Example:

```text
www.example.com
→ CNAME
→ app.example.com
```

Then:

```text
app.example.com
→ A
→ 10.0.0.20
```

Mental model:

```text
CNAME = alias
```

---

## MX

MX means:

```text
Mail Exchange
```

It identifies the mail server responsible for a domain.

Example:

```text
example.com
→ MX
→ mail.example.com
```

Query:

```bash
dig MX example.com
```

---

## NS

NS means:

```text
Name Server
```

It identifies DNS servers responsible for a domain.

Example:

```text
example.com
→ NS
→ ns1.provider.com
```

Query:

```bash
dig NS example.com
```

---

## TXT

TXT records contain text data.

They are often used for:

```text
domain verification
SPF
DKIM-related configuration
service verification
```

Query:

```bash
dig TXT example.com
```

---

## A vs AAAA

Quick reference:

```text
A     → IPv4
AAAA  → IPv6
```

---

## dig

Basic query:

```bash
dig example.com
```

Important sections:

```text
QUESTION SECTION
→ what was queried

ANSWER SECTION
→ DNS response

SERVER
→ resolver that answered

Query time
→ lookup duration
```

Example:

```text
example.com. 300 IN A 93.184.216.34
```

Read:

```text
example.com
→ hostname

300
→ TTL

IN
→ Internet class

A
→ IPv4 record

93.184.216.34
→ returned IP
```

---

## nslookup

Example:

```bash
nslookup google.pl
```

Possible output:

```text
Server:  127.0.0.53
Address: 127.0.0.53#53

Non-authoritative answer:
Name:    google.pl
Address: 142.250.120.94
```

Read:

```text
Server
→ DNS resolver

Address #53
→ resolver address and DNS port

Name
→ queried hostname

Address
→ resolved IP
```

If both IPv4 and IPv6 exist, multiple addresses may appear.

---

## Non-authoritative Answer

A non-authoritative answer means the response did not come directly from the DNS server that owns the zone.

It may come from:

```text
recursive resolver
cache
upstream resolver
```

This is normal.

---

## TTL

TTL means:

```text
Time To Live
```

It tells DNS resolvers how long they may cache a DNS answer.

Example:

```text
example.com. 377 IN A 10.0.0.20
```

TTL:

```text
377 seconds
```

The resolver may cache:

```text
example.com → 10.0.0.20
```

until the TTL expires.

---

## DNS Cache

Flow:

```text
first request
→ resolver queries DNS
→ receives result
→ stores result in cache

next request
→ resolver may return cached result
```

This reduces:

```text
DNS traffic
lookup latency
load on DNS servers
```

---

## DNS Changes and TTL

Suppose:

```text
app.example.com
10.0.0.10
```

changes to:

```text
app.example.com
10.0.0.20
```

Some clients may temporarily still receive:

```text
10.0.0.10
```

because the old record is cached.

This is why DNS changes may appear gradually across different resolvers.

---

## High vs Low TTL

```text
high TTL
→ fewer DNS queries
→ longer cache duration
→ slower reaction to DNS changes
```

```text
low TTL
→ more DNS queries
→ shorter cache duration
→ faster reaction to DNS changes
```

Before planned DNS migrations or failovers, TTL may be lowered in advance.

---

## Query a Specific DNS Server

Example:

```bash
dig @8.8.8.8 example.com
```

This asks:

```text
8.8.8.8
```

directly.

Another example:

```bash
dig @1.1.1.1 example.com
```

This is useful when comparing resolver behavior.

---

## Default Resolver vs Specific Resolver

Suppose:

```bash
dig example.com
```

times out.

But:

```bash
dig @8.8.8.8 example.com
```

works.

This strongly suggests:

```text
external DNS connectivity works
but the default/local resolver configuration may be broken
```

Check:

```bash
cat /etc/resolv.conf
resolvectl status
systemctl status systemd-resolved
```

---

## /etc/resolv.conf

Check:

```bash
cat /etc/resolv.conf
```

Example:

```text
nameserver 127.0.0.53
```

or:

```text
nameserver 8.8.8.8
```

This file helps determine which DNS resolver the system uses.

---

## systemd-resolved

On systems using `systemd-resolved`:

```bash
resolvectl status
```

Check service state:

```bash
systemctl status systemd-resolved
```

---

## /etc/hosts

Linux does not always need DNS to resolve a hostname.

Example:

```bash
cat /etc/hosts
```

may contain:

```text
127.0.0.1 localhost
10.0.0.50 app.internal
```

Then:

```bash
getent hosts app.internal
```

may return:

```text
10.0.0.50 app.internal
```

even if DNS does not know the name.

---

## getent hosts

Use:

```bash
getent hosts example.com
```

This uses the system's configured name resolution mechanism.

This may include:

```text
/etc/hosts
DNS
other NSS sources
```

So:

```text
dig
→ DNS query

getent hosts
→ system name resolution
```

This distinction is very useful during troubleshooting.

---

## nsswitch.conf

Check:

```bash
grep '^hosts:' /etc/nsswitch.conf
```

Example:

```text
hosts: files dns
```

This means:

```text
files
→ local files such as /etc/hosts

dns
→ DNS lookup
```

The order matters.

---

## NXDOMAIN

Example:

```bash
dig app.internal
```

returns:

```text
status: NXDOMAIN
```

This means:

```text
the DNS name does not exist
```

Important:

```text
DNS itself responded
```

So this is not the same as a network timeout.

Mental model:

```text
NXDOMAIN
→ name does not exist
```

---

## SERVFAIL

Example:

```text
status: SERVFAIL
```

This means:

```text
DNS received the query
but could not successfully resolve it
```

Possible causes:

```text
resolver problem
authoritative DNS problem
DNSSEC issue
broken DNS zone
upstream DNS problem
```

Mental model:

```text
SERVFAIL
→ DNS had a problem resolving the query
```

---

## DNS Timeout

Example:

```text
connection timed out
no servers could be reached
```

This means:

```text
no DNS response was received
```

Possible causes:

```text
resolver unavailable
routing problem
firewall
blocked port 53
wrong nameserver
local resolver issue
```

Mental model:

```text
TIMEOUT
→ DNS did not answer
```

---

## Quick Failure Reference

```text
NXDOMAIN
→ hostname does not exist

SERVFAIL
→ DNS could not complete the lookup

TIMEOUT
→ no DNS response
```

---

## DNS and Network Troubleshooting

Suppose:

```bash
ping 8.8.8.8
```

works.

But:

```bash
ping example.com
```

does not.

This strongly suggests:

```text
basic IP connectivity works
name resolution may be broken
```

Check:

```bash
dig example.com
getent hosts example.com
cat /etc/resolv.conf
resolvectl status
```

---

## When dig Works but Application Fails

If:

```bash
dig example.com
```

works, DNS resolution itself may be fine.

But the application may still fail because of:

```text
routing
TCP connectivity
firewall
TLS
HTTP
application errors
```

Troubleshooting flow:

```text
DNS
↓
IP
↓
routing
↓
TCP port
↓
TLS / HTTP
↓
application
```

Useful commands:

```bash
getent hosts example.com
ip route get <IP>
nc -vz <IP> 443
curl -v https://example.com
```

---

## DNS Port 53

DNS uses:

```text
UDP 53
```

for most ordinary queries.

DNS can also use:

```text
TCP 53
```

for certain responses and operations.

Quick reference:

```text
DNS
→ usually UDP/53
→ sometimes TCP/53
```

---

## nc and DNS

Example:

```bash
nc -vz 8.8.8.8 53
```

tests:

```text
TCP port 53
```

It does NOT prove that normal UDP DNS queries work.

So:

```text
TCP/53 reachable
≠
DNS definitely works
```

A better DNS test is:

```bash
dig @8.8.8.8 example.com
```

because it performs an actual DNS lookup.

---

## DNS Troubleshooting Flow

### Step 1 — Check basic IP connectivity

```bash
ping 8.8.8.8
```

If IP connectivity does not work, DNS may not be the real problem.

---

### Step 2 — Check configured resolver

```bash
cat /etc/resolv.conf
```

or:

```bash
resolvectl status
```

---

### Step 3 — Test DNS

```bash
dig example.com
```

---

### Step 4 — Test a specific resolver

```bash
dig @8.8.8.8 example.com
```

If this works while normal `dig` fails:

```text
suspect local/default resolver configuration
```

---

### Step 5 — Compare system resolution

```bash
getent hosts example.com
```

If:

```text
dig fails
but getent works
```

check:

```bash
cat /etc/hosts
grep '^hosts:' /etc/nsswitch.conf
```

---

### Step 6 — Continue beyond DNS

If the hostname resolves but the application fails:

```bash
ip route get <resolved-IP>
nc -vz <resolved-IP> <port>
curl -v <URL>
```

---

## Practical Scenario 1

```text
ping 8.8.8.8
→ works

ping app.example.com
→ fails
```

Likely area:

```text
DNS / name resolution
```

Check:

```bash
dig app.example.com
getent hosts app.example.com
```

---

## Practical Scenario 2

```text
dig app.example.com
→ timeout

dig @8.8.8.8 app.example.com
→ works
```

Likely area:

```text
local resolver
/etc/resolv.conf
systemd-resolved
local DNS configuration
```

---

## Practical Scenario 3

```text
dig app.internal
→ NXDOMAIN

getent hosts app.internal
→ 10.0.0.50
```

Likely explanation:

```text
hostname exists in /etc/hosts
but not in DNS
```

Check:

```bash
cat /etc/hosts
```

---

## Practical Scenario 4

DNS record changes:

```text
10.0.0.10
→
10.0.0.20
```

but some clients still see:

```text
10.0.0.10
```

Likely cause:

```text
DNS cache / TTL
```

---

## Useful Commands

DNS lookup:

```bash
dig example.com
```

Specific DNS server:

```bash
dig @8.8.8.8 example.com
```

Specific record:

```bash
dig A example.com
dig AAAA example.com
dig MX example.com
dig NS example.com
```

Quick lookup:

```bash
nslookup example.com
```

System name resolution:

```bash
getent hosts example.com
```

Resolver configuration:

```bash
cat /etc/resolv.conf
```

Resolver status:

```bash
resolvectl status
```

Local hostname mappings:

```bash
cat /etc/hosts
```

NSS order:

```bash
grep '^hosts:' /etc/nsswitch.conf
```

---

## Quick Reference

```text
A      → IPv4
AAAA   → IPv6
CNAME  → alias
MX     → mail server
NS     → authoritative DNS server
TXT    → text / verification data
```

Failure states:

```text
NXDOMAIN → name does not exist
SERVFAIL → DNS could not resolve
TIMEOUT  → DNS did not answer
```

Tools:

```text
dig
→ direct DNS troubleshooting

nslookup
→ quick DNS lookup

getent hosts
→ system name resolution

/etc/resolv.conf
→ configured resolver

/etc/hosts
→ local hostname mapping
```

---

## Interview Mental Model

When a hostname does not work:

```text
Can I reach an IP?
↓
Which resolver am I using?
↓
Does dig work?
↓
Does a specific DNS server work?
↓
Does getent return something different?
↓
Is /etc/hosts overriding DNS?
↓
Is the answer cached?
↓
What does NXDOMAIN / SERVFAIL / timeout tell me?
```

A useful high-level flow is:

```text
hostname
→ resolver
→ DNS record
→ IP
→ routing
→ TCP
→ application
```
