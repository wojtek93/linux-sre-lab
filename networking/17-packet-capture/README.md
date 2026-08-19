# NET-17 Packet Capture with tcpdump

## Goal

Understand how to capture and analyze TCP traffic with `tcpdump`, recognize TCP handshake flags, distinguish an open port from a closed or filtered port, and save packet captures to `.pcap` files for later analysis.

---

## What is tcpdump?

`tcpdump` is a command-line packet capture and network troubleshooting tool.

It allows us to inspect packets passing through a network interface.

Typical uses include:

```text
connection troubleshooting
TCP handshake analysis
DNS investigation
HTTP traffic analysis
firewall troubleshooting
packet loss investigation
port connectivity problems
```

---

## Basic tcpdump command

Command:

```bash
sudo tcpdump -i lo -nn tcp port 9999
```

Options:

```text
-i lo = capture traffic on loopback interface
-nn    = do not resolve IP addresses or port numbers to names
tcp    = capture only TCP traffic
port 9999 = capture only traffic related to port 9999
```

---

## Why use -nn?

Without `-nn`, tcpdump may try to convert:

```text
127.0.0.1
```

or port numbers into names.

With:

```bash
-nn
```

the output stays numeric.

This is usually easier during troubleshooting because the exact ports and IP addresses remain visible.

---

## TCP flags in tcpdump

Important TCP flags:

```text
[S]   = SYN
[S.]  = SYN + ACK
[.]   = ACK
[P.]  = PSH + ACK
[F.]  = FIN + ACK
[R.]  = RST + ACK
```

These flags help identify what is happening during a TCP connection.

---

## SYN

Example:

```text
Flags [S]
```

SYN starts a TCP connection.

Simplified meaning:

```text
client
↓
I want to create a TCP connection
↓
server
```

It is the first step of the TCP three-way handshake.

---

## SYN-ACK

Example:

```text
Flags [S.]
```

This means:

```text
SYN + ACK
```

The server received the SYN and agrees to establish the connection.

---

## ACK

Example:

```text
Flags [.]
```

This represents ACK.

ACK confirms that a TCP segment was received.

During the TCP handshake:

```text
SYN
↓
SYN-ACK
↓
ACK
```

After the final ACK, the TCP connection is established.

---

## TCP three-way handshake

A successful TCP connection starts with:

```text
client
↓
SYN
↓
server

server
↓
SYN-ACK
↓
client

client
↓
ACK
↓
server
```

In tcpdump:

```text
[S]
[S.]
[.]
```

This means:

```text
TCP handshake successful
port is reachable
service is listening
```

---

## PSH + ACK

Example:

```text
Flags [P.]
```

PSH usually indicates that application data is being transferred.

In this lab, after the TCP handshake, HTTP traffic was exchanged.

Simplified flow:

```text
TCP handshake
↓
connection established
↓
HTTP GET
↓
HTTP response
```

Packets carrying HTTP data may appear with:

```text
[P.]
```

---

## FIN

Example:

```text
Flags [F.]
```

FIN is used to close a TCP connection gracefully.

Simplified flow:

```text
application finishes communication
↓
FIN
↓
ACK
↓
connection closes
```

A normal TCP session can therefore contain:

```text
SYN
SYN-ACK
ACK
data
FIN
ACK
```

---

## RST

Example:

```text
Flags [R.]
```

RST = Reset.

It indicates that a TCP connection is being rejected or immediately reset.

This is commonly seen when a host is reachable but no service is listening on the requested port.

---

## Closed TCP port test

First, no service was running on port 9999.

Check:

```bash
sudo ss -tlnp sport = :9999
```

No output means:

```text
nothing is listening on TCP port 9999
```

tcpdump was started:

```bash
sudo tcpdump -i lo -nn tcp port 9999
```

Then:

```bash
curl http://127.0.0.1:9999
```

returned:

```text
Connection refused
```

---

## Closed port packet flow

tcpdump showed:

```text
Flags [S]
Flags [R.]
```

Flow:

```text
client
↓
SYN
↓
port 9999
↓
no service listening
↓
RST
↓
client
```

This produces:

```text
Connection refused
```

---

## Important closed port pattern

```text
SYN
↓
RST
```

Usually means:

```text
host is reachable
network path works
port is closed
nothing is listening
```

This is very different from a timeout.

---

## Firewall DROP test

A firewall rule was added:

```bash
sudo iptables -I INPUT 1 -p tcp --dport 9999 -j DROP
```

This silently drops incoming TCP packets to port 9999.

The rule was checked with:

```bash
sudo iptables -L INPUT -n -v --line-numbers
```

---

## Test connection through DROP

Command:

```bash
curl --connect-timeout 5 http://127.0.0.1:9999
```

The result was:

```text
Connection timed out
```

Unlike a closed port, no immediate rejection was returned.

---

## Packet flow with DROP

tcpdump showed repeated:

```text
Flags [S]
Flags [S]
Flags [S]
Flags [S]
```

No:

```text
[S.]
```

and no:

```text
[R.]
```

were returned.

Flow:

```text
client sends SYN
↓
firewall DROP
↓
packet discarded
↓
no response
↓
client retransmits SYN
↓
still no response
↓
timeout
```

---

## TCP retransmission

TCP retransmits packets when it expects a response but does not receive one.

In the DROP test:

```text
SYN
↓
no response
↓
SYN retransmission
↓
no response
↓
SYN retransmission
```

This continues until the connection attempt times out.

---

## Closed port vs firewall DROP

Closed port:

```text
SYN
↓
RST
↓
Connection refused
```

Firewall DROP:

```text
SYN
↓
no response
↓
SYN retransmission
↓
timeout
```

This difference is extremely useful during network troubleshooting.

---

## Remove test firewall rule

After the DROP test:

```bash
sudo iptables -D INPUT 1
```

The firewall was checked again:

```bash
sudo iptables -L INPUT -n -v --line-numbers
```

This removed the temporary test rule.

---

## Open port test

A simple HTTP server was started on port 9999:

```bash
python3 -m http.server 9999
```

This created a real TCP listener.

Check:

```bash
sudo ss -tlnp sport = :9999
```

The port should appear as:

```text
LISTEN
```

---

## Capture working TCP connection

tcpdump:

```bash
sudo tcpdump -i lo -nn tcp port 9999
```

Then:

```bash
curl http://127.0.0.1:9999
```

The request succeeded.

---

## Working TCP handshake

tcpdump showed:

```text
[S]
[S.]
[.]
```

Meaning:

```text
SYN
↓
SYN-ACK
↓
ACK
```

This confirms:

```text
host reachable
port open
service listening
TCP handshake successful
```

---

## Application data

After the handshake, packets with:

```text
[P.]
```

appeared.

This indicates application data being exchanged.

In this lab:

```text
HTTP GET
↓
Python HTTP server
↓
HTTP response
```

---

## Connection close

At the end of the session, tcpdump showed FIN-related packets.

Example:

```text
[F.]
```

This represents graceful TCP connection termination.

Flow:

```text
HTTP request
↓
HTTP response
↓
FIN
↓
ACK
↓
connection closed
```

---

## Three key packet patterns

### Open TCP port

```text
SYN
↓
SYN-ACK
↓
ACK
```

Meaning:

```text
TCP connection successful
```

---

### Closed TCP port

```text
SYN
↓
RST
```

Meaning:

```text
host reachable
port closed
```

---

### Filtered / dropped traffic

```text
SYN
↓
no response
↓
SYN retransmission
↓
timeout
```

Meaning:

```text
possible firewall DROP
packet loss
network filtering
routing problem
```

---

## Capture packets to a file

Instead of only watching packets live, tcpdump can save them to a file.

Command:

```bash
sudo tcpdump -i lo -nn tcp port 9999 -w packet-capture.pcap
```

Option:

```text
-w = write packets to a file
```

The file format is:

```text
.pcap
```

PCAP = Packet Capture.

---

## Generate traffic for the capture

While tcpdump was recording:

```bash
curl http://127.0.0.1:9999
```

The connection generated:

```text
TCP handshake
HTTP request
HTTP response
TCP connection close
```

These packets were written to:

```text
packet-capture.pcap
```

---

## Stop capture

tcpdump was stopped with:

```text
Ctrl+C
```

The capture file was then checked:

```bash
ls -lh packet-capture.pcap
```

---

## Read a pcap file

Command:

```bash
tcpdump -nn -r packet-capture.pcap
```

Option:

```text
-r = read packets from a capture file
```

This allows analysis after the original network event has already happened.

---

## Live capture vs pcap

Live capture:

```bash
sudo tcpdump -i lo -nn tcp port 9999
```

Meaning:

```text
observe packets in real time
```

Capture to file:

```bash
sudo tcpdump -i lo -nn tcp port 9999 -w packet-capture.pcap
```

Meaning:

```text
save packets for later analysis
```

Read saved capture:

```bash
tcpdump -nn -r packet-capture.pcap
```

Meaning:

```text
analyze previously captured traffic
```

---

## Why pcap files are useful

Packet captures can be:

```text
saved
shared
analyzed later
opened with Wireshark
used during incident investigation
used for troubleshooting intermittent problems
```

A problem does not need to be reproduced while the engineer is watching the terminal.

---

## Packet capture troubleshooting workflow

When a TCP connection fails:

```text
application cannot connect
↓
check listening socket
↓
ss
↓
capture packets
↓
tcpdump
↓
inspect TCP flags
```

Then identify the pattern.

---

## Pattern 1

```text
SYN → SYN-ACK → ACK
```

Result:

```text
network path works
TCP connection established
```

Continue troubleshooting at the application layer.

---

## Pattern 2

```text
SYN → RST
```

Result:

```text
host reachable
port closed
service probably not listening
```

Check:

```bash
ss -tlnp
```

and the application/service status.

---

## Pattern 3

```text
SYN → no response
```

Result:

```text
possible firewall
possible packet loss
possible routing problem
possible remote host problem
```

Check:

```text
firewall
routing
network path
remote host
```

---

## tcpdump filtering

Filtering traffic is important because a busy server may process thousands of packets.

Example:

```bash
sudo tcpdump -i lo -nn tcp port 9999
```

filters by:

```text
interface = lo
protocol = TCP
port = 9999
```

This makes packet analysis much easier.

---

## Key troubleshooting commands

```bash
sudo ss -tlnp sport = :9999

sudo tcpdump -i lo -nn tcp port 9999

curl http://127.0.0.1:9999

sudo iptables -I INPUT 1 -p tcp --dport 9999 -j DROP

sudo iptables -L INPUT -n -v --line-numbers

curl --connect-timeout 5 http://127.0.0.1:9999

sudo iptables -D INPUT 1

python3 -m http.server 9999

sudo tcpdump -i lo -nn tcp port 9999 -w packet-capture.pcap

ls -lh packet-capture.pcap

tcpdump -nn -r packet-capture.pcap
```

---

## Key takeaways

```text
tcpdump captures network packets
-i selects the network interface
-nn keeps IP addresses and ports numeric
tcp filters TCP traffic
port filters traffic by port

[S] = SYN
[S.] = SYN-ACK
[.] = ACK
[P.] = PSH + ACK
[F.] = FIN + ACK
[R.] = RST + ACK

SYN → SYN-ACK → ACK = successful TCP handshake
SYN → RST = host reachable but port closed
SYN → no response = possible firewall DROP or network problem

TCP retransmits SYN when no response is received
-w saves packets to a pcap file
-r reads packets from a pcap file
pcap files can be analyzed later or opened in Wireshark
```

Short interview answer:

```text
I use tcpdump to inspect network traffic at packet level.

For TCP troubleshooting, I look at the handshake and TCP flags.

SYN followed by SYN-ACK and ACK means the connection works.
SYN followed by RST usually means the host is reachable but the port is closed.
Repeated SYN packets without a response may indicate firewall filtering,
packet loss or another network path problem.

I can also save captures to pcap files for later analysis.
```
