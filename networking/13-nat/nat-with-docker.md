# NAT with Docker

## Goal

Understand how NAT works in Docker, how container traffic is translated and how Docker uses DNAT and MASQUERADE for port mapping and outbound connectivity.

---

## What is NAT?

NAT = Network Address Translation.

NAT changes network information inside packets as they pass through a host or router.

It can modify:

```text
source IP
destination IP
source port
destination port
```

NAT is commonly used when private networks communicate with other networks.

---

## Docker container networking

A Docker container normally gets its own private IP address.

Example from the lab:

```text
container IP: 172.17.0.2
```

The Linux host had a different IP address.

Example:

```text
host IP: 192.168.64.2
```

The container runs inside a Docker bridge network.

Simplified view:

```text
host
192.168.64.2
│
├── docker bridge
│
└── container
    172.17.0.2
```

---

## Run nginx without port mapping

Command:

```bash
docker run -d --name nat-nginx nginx
```

Check:

```bash
docker ps
```

The output showed:

```text
80/tcp
```

This means nginx is listening on port 80 inside the container.

However, there was no host port mapping.

There was no entry like:

```text
0.0.0.0:8080->80/tcp
```

---

## Check container IP

Command:

```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nat-nginx
```

Result from the lab:

```text
172.17.0.2
```

This is the container IP inside the Docker bridge network.

---

## Access the container directly

Command:

```bash
curl http://172.17.0.2
```

The nginx page was returned.

This means:

```text
host
↓
Docker bridge network
↓
172.17.0.2:80
↓
nginx
```

The host could directly reach the container IP.

---

## Port mapping

The first container was removed:

```bash
docker rm -f nat-nginx
```

Then nginx was started with port mapping:

```bash
docker run -d --name nat-nginx -p 8080:80 nginx
```

The important option is:

```text
-p 8080:80
```

This means:

```text
HOST_PORT:CONTAINER_PORT
```

In this case:

```text
host port:      8080
container port: 80
```

---

## Check port mapping

Command:

```bash
docker ps
```

The output showed:

```text
0.0.0.0:8080->80/tcp
```

and:

```text
[::]:8080->80/tcp
```

This means incoming traffic to host port 8080 is forwarded to port 80 inside the container.

Flow:

```text
client
↓
host:8080
↓
Docker port mapping
↓
container:80
↓
nginx
```

---

## Test mapped port

Command:

```bash
curl http://127.0.0.1:8080
```

The nginx page was returned.

This confirms that the port mapping works.

Traffic flow:

```text
127.0.0.1:8080
↓
Docker NAT
↓
172.17.0.2:80
↓
nginx
```

---

## What is DNAT?

DNAT = Destination Network Address Translation.

DNAT changes the destination address or destination port of a packet.

In this lab:

```text
destination before NAT:
host:8080
```

became:

```text
destination after NAT:
172.17.0.2:80
```

Flow:

```text
host:8080
↓
DNAT
↓
172.17.0.2:80
```

Easy way to remember:

```text
DNAT = change where the packet is going
```

---

## Inspect Docker NAT rules

Command:

```bash
sudo iptables -t nat -L -n -v
```

Options:

```text
-t nat = inspect NAT table
-L     = list rules
-n     = numeric addresses and ports
-v     = verbose output
```

The output showed Docker-related NAT rules.

---

## Docker DNAT rule

Command:

```bash
sudo iptables -t nat -L DOCKER -n -v
```

The lab showed a rule similar to:

```text
DNAT tcp ... tcp dpt:8080 to:172.17.0.2:80
```

This means:

```text
packet arrives at host port 8080
↓
Docker changes destination
↓
172.17.0.2:80
```

This is the rule responsible for the Docker port mapping.

---

## What is SNAT?

SNAT = Source Network Address Translation.

SNAT changes the source address of a packet.

This is commonly used when a device with a private IP sends traffic to another network.

Example:

```text
container source:
172.17.0.2
```

can be translated to:

```text
host source:
192.168.64.2
```

Easy way to remember:

```text
SNAT = change where the packet appears to come from
```

---

## MASQUERADE

Docker commonly uses:

```text
MASQUERADE
```

for outbound container traffic.

MASQUERADE is a form of source NAT.

Simplified flow:

```text
container
172.17.0.2
↓
outbound traffic
↓
MASQUERADE
↓
host IP
↓
external network
```

The external network does not need to know about the private Docker address.

---

## Inspect POSTROUTING rules

Command:

```bash
sudo iptables -t nat -L POSTROUTING -n -v
```

The output showed:

```text
MASQUERADE
```

rules for Docker networks.

This means Docker can translate private container source addresses when traffic leaves the Docker network.

---

## DNAT vs SNAT

DNAT:

```text
changes destination
```

Example:

```text
host:8080
↓
DNAT
↓
container:80
```

SNAT:

```text
changes source
```

Example:

```text
container 172.17.0.2
↓
SNAT / MASQUERADE
↓
host IP
```

The easiest way to remember:

```text
DNAT = where is the packet going?
SNAT = where does the packet appear to come from?
```

---

## Incoming traffic

For incoming traffic to a published Docker port:

```text
client
↓
host:8080
↓
DNAT
↓
container 172.17.0.2:80
↓
nginx
```

The destination is changed.

---

## Outgoing traffic

For traffic leaving the container:

```text
container 172.17.0.2
↓
Docker bridge
↓
MASQUERADE / SNAT
↓
host IP
↓
external network
```

The source is changed.

---

## Why NAT is useful

Private addresses such as:

```text
172.17.0.2
```

are internal to the Docker network.

NAT allows containers to:

```text
receive traffic through host ports
access networks outside Docker
share the host network connection
remain isolated behind private addresses
```

---

## Port mapping without exposing the container IP

Without port mapping:

```text
container 172.17.0.2:80
```

must be reached directly from a network that can route to the container.

With:

```bash
-p 8080:80
```

clients can use:

```text
host:8080
```

without knowing the container IP.

This is one of the main practical uses of NAT in Docker.

---

## NAT troubleshooting workflow

If a Docker application is not reachable:

```text
application problem
↓
check container
↓
docker ps
↓
check container IP
↓
docker inspect
↓
check port mapping
↓
docker ps
↓
check DNAT rule
↓
iptables nat DOCKER
↓
test host port
↓
curl
```

Useful commands:

```bash
docker ps

docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nat-nginx

curl http://172.17.0.2

curl http://127.0.0.1:8080

sudo iptables -t nat -L -n -v

sudo iptables -t nat -L DOCKER -n -v

sudo iptables -t nat -L POSTROUTING -n -v
```

---

## Key troubleshooting questions

When a containerized service is not reachable, check:

```text
Is the container running?
Is the application listening inside the container?
What is the container IP?
Is the correct host port published?
Is the host port mapped to the correct container port?
Does the Docker DNAT rule exist?
Can the host reach the container directly?
Can the client reach the published host port?
```

---

## Lab files

```text
13-nat/
├── README.md
└── nat-with-docker.md
```

`nat-with-docker.md` contains the practical Docker NAT investigation.

---

## Key commands

```bash
docker run -d --name nat-nginx nginx

docker ps

docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nat-nginx

curl http://172.17.0.2

docker rm -f nat-nginx

docker run -d --name nat-nginx -p 8080:80 nginx

curl http://127.0.0.1:8080

sudo iptables -t nat -L -n -v

sudo iptables -t nat -L DOCKER -n -v

sudo iptables -t nat -L POSTROUTING -n -v
```

---

## Key takeaways

```text
NAT = Network Address Translation
NAT can change IP addresses and ports
Docker containers normally use private IP addresses
-p 8080:80 means host port 8080 maps to container port 80
DNAT changes the destination
SNAT changes the source
MASQUERADE is a form of source NAT
Docker uses DNAT for published ports
Docker uses MASQUERADE for outbound container traffic
iptables -t nat can show Docker NAT rules
DOCKER chain contains port mapping rules
POSTROUTING contains MASQUERADE rules
```

Short interview answer:

```text
NAT changes network address or port information in packets.

In Docker, publishing a port such as -p 8080:80 uses destination NAT
to forward traffic from host port 8080 to port 80 in the container.

For outbound container traffic, Docker uses source NAT or MASQUERADE
so private container addresses can communicate through the host.
```
