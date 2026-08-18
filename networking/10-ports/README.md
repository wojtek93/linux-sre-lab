# NET-10 Ports and Sockets

## Goal

Understand how Linux ports and sockets work, how to identify listening services, established TCP connections and the processes using specific ports.

---

## What is a port?

A port identifies a specific network service or application on a host.

Examples:

```text
22  = SSH
53  = DNS
80  = HTTP
443 = HTTPS
```

An IP address identifies the host.

A port identifies the service running on that host.

Example:

```text
192.168.64.2:80
```

This means:

```text
IP address: 192.168.64.2
port:       80
```

---

## What is a socket?

A socket is a network communication endpoint.

A socket is usually identified by:

```text
protocol
IP address
port
```

Example:

```text
TCP 192.168.64.2:22
```

This represents a TCP socket using port 22 on the local host.

---

## Check listening TCP and UDP sockets

Command:

```bash
sudo ss -tulnp
```

Options:

```text
-t = TCP
-u = UDP
-l = listening sockets
-n = numeric addresses and ports
-p = process
```

This command shows listening TCP and UDP sockets together with the processes using them.

During the lab, services were visible on ports such as:

```text
22 = SSH
53 = DNS
80 = HTTP / nginx
```

---

## LISTEN state

A TCP socket waiting for incoming connections appears in the:

```text
LISTEN
```

state.

Example:

```text
tcp LISTEN 0 511 0.0.0.0:80
```

This means that a TCP service is waiting for incoming connections on port 80.

Traffic flow:

```text
client
↓
connection request
↓
service listening on port 80
```

---

## Listening addresses

Example:

```text
0.0.0.0:80
```

This means the service is listening on port 80 on all IPv4 interfaces.

Example:

```text
[::]:80
```

This means the service is listening on IPv6 interfaces.

Example:

```text
127.0.0.1:53
```

This means the service is listening only on the local loopback interface.

---

## Check only listening TCP sockets

Command:

```bash
ss -tln
```

Options:

```text
-t = TCP
-l = listening sockets
-n = numeric addresses and ports
```

Example:

```text
LISTEN 0 511 0.0.0.0:80
LISTEN 0 128 0.0.0.0:22
```

This means that TCP services are waiting for connections on ports 80 and 22.

---

## Check established TCP connections

Command:

```bash
ss -tn state established
```

Options:

```text
-t = TCP
-n = numeric addresses and ports
```

`ESTABLISHED` means that a TCP connection has already been successfully created.

Example:

```text
192.168.64.2:22    192.168.64.1:53000
```

This means:

```text
local IP:     192.168.64.2
local port:   22
remote IP:    192.168.64.1
remote port:  53000
```

The SSH connection is already active.

---

## LISTEN vs ESTABLISHED

LISTEN:

```text
waiting for a new connection
```

ESTABLISHED:

```text
connection already exists
communication is active
```

Typical TCP flow:

```text
LISTEN
↓
client connects
↓
TCP handshake
↓
ESTABLISHED
```

---

## Filter by source port

Command:

```bash
ss -tn sport = :22
```

`sport` means:

```text
source port
```

In this lab, this command showed active SSH connections using local port 22.

Example:

```text
192.168.64.2:22 → 192.168.64.1:53000
```

The server uses local port 22.

---

## Filter by destination port

Command:

```bash
ss -tn dport = :22
```

`dport` means:

```text
destination port
```

This checks whether the local machine currently has TCP connections to port 22 on another host.

In this lab, the command returned no connections.

This means the machine was receiving SSH connections but was not currently connecting to another SSH server.

---

## Check whether port 80 is listening

Command:

```bash
ss -tln sport = :80
```

This checks whether a TCP service is listening locally on port 80.

Example:

```text
LISTEN 0 511 0.0.0.0:80
```

This confirms that a service is waiting for connections on TCP port 80.

---

## Identify the process using port 80

Command:

```bash
sudo ss -tlnp sport = :80
```

Option:

```text
-p = process
```

This shows which process owns the socket.

In this lab, the process listening on port 80 was:

```text
nginx
```

This is useful when troubleshooting questions such as:

```text
Which process is using port 80?
```

---

## Identify the process PID

The `ss` output also shows the PID of the process.

In this lab:

```text
PID 1310
```

Inspect the process with:

```bash
ps -fp 1310
```

Options:

```text
-f = full-format listing
-p = select process by PID
```

The output showed:

```text
nginx: master process
```

---

## nginx processes

Command:

```bash
ps aux | grep nginx
```

The output showed:

```text
nginx: master process
nginx: worker process
nginx: worker process
```

Simplified nginx architecture:

```text
nginx master process
        ↓
worker process
worker process
worker process
```

The master process manages nginx configuration and worker processes.

Worker processes handle client requests.

---

## Avoid matching grep itself

Command:

```bash
ps aux | grep nginx
```

also shows the `grep nginx` process.

One way to avoid this is:

```bash
ps aux | grep '[n]ginx'
```

Another option is:

```bash
pgrep -a nginx
```

This directly shows nginx processes.

---

## Socket report script

File:

```text
socket-report.sh
```

Script:

```bash
#!/bin/bash

echo "=== LISTENING TCP/UDP SOCKETS ==="
sudo ss -tulnp

echo
echo "=== ESTABLISHED TCP CONNECTIONS ==="
ss -tn state established

echo
echo "=== SUMMARY ==="

listening_count=$(ss -tuln | tail -n +2 | wc -l)
established_count=$(ss -tn state established | tail -n +2 | wc -l)

echo "Listening sockets: $listening_count"
echo "Established connections: $established_count"
```

Make the script executable:

```bash
chmod +x socket-report.sh
```

Run:

```bash
./socket-report.sh
```

---

## Count listening sockets

Command used in the script:

```bash
ss -tuln | tail -n +2 | wc -l
```

Flow:

```text
ss -tuln
↓
show listening TCP and UDP sockets
↓
tail -n +2
↓
skip the header
↓
wc -l
↓
count the remaining lines
```

The value is stored in:

```bash
listening_count=$(ss -tuln | tail -n +2 | wc -l)
```

---

## Count established connections

Command:

```bash
ss -tn state established | tail -n +2 | wc -l
```

Flow:

```text
ss -tn state established
↓
show established TCP connections
↓
tail -n +2
↓
skip the header
↓
wc -l
↓
count the connections
```

The value is stored in:

```bash
established_count=$(ss -tn state established | tail -n +2 | wc -l)
```

---

## Save the report

Save script output to a file:

```bash
sudo -v
./socket-report.sh > sample-output.txt
```

Check the result:

```bash
cat sample-output.txt
```

---

## Basic troubleshooting workflow

If a web service on port 80 is not working:

```text
application not responding
↓
check whether port 80 is listening
↓
sudo ss -tlnp sport = :80
↓
identify process and PID
↓
nginx / PID
↓
inspect process
↓
ps -fp PID
```

Example:

```bash
sudo ss -tlnp sport = :80
ps -fp 1310
```

This allows us to connect network information with the Linux process using the socket.

---

## Key troubleshooting commands

```bash
sudo ss -tulnp
ss -tln
ss -tn state established
ss -tn sport = :22
ss -tn dport = :22
ss -tln sport = :80
sudo ss -tlnp sport = :80
ps -fp 1310
ps aux | grep '[n]ginx'
pgrep -a nginx
```

---

## Key takeaways

```text
port = identifies a network service
socket = network communication endpoint
LISTEN = waiting for incoming connection
ESTABLISHED = TCP connection already exists
sport = source port
dport = destination port
0.0.0.0 = all IPv4 interfaces
127.0.0.1 = local loopback interface
ss -tulnp = show listening TCP/UDP sockets and processes
ss -tn state established = show active TCP connections
ss can identify which process and PID use a port
ps can inspect the process after finding its PID
```

Short interview answer:

```text
I use ss to inspect listening ports and established network connections.
For example, sudo ss -tlnp sport = :80 shows which process is listening
on TCP port 80, while ss -tn state established shows active TCP connections.
```
