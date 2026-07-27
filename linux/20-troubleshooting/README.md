# Lab 20 – Linux Troubleshooting

## Objective

Learn a structured troubleshooting methodology used by Linux Administrators, DevOps Engineers and Site Reliability Engineers.

The purpose of this lab is to combine knowledge from previous Linux labs into a practical incident response workflow.

---

# Troubleshooting Principles

Always investigate before making changes.

Typical workflow:

1. Identify the problem.
2. Verify the symptoms.
3. Collect information.
4. Find the root cause.
5. Apply the fix.
6. Verify the solution.

---

# Common Troubleshooting Commands

## System Information

```bash
hostname
hostname -I
uptime
```

---

## Services

```bash
systemctl status <service>

journalctl -u <service>
```

---

## Processes

```bash
ps aux

top

htop
```

---

## CPU

```bash
top

ps aux --sort=-%cpu
```

---

## Memory

```bash
free -h
```

---

## Disk

```bash
df -h

du -sh *
```

---

## Networking

```bash
ip addr

ip route

ping

ss -tulpn

nc -zv

curl

dig

traceroute
```

---

## Files

```bash
find

grep

tail

less
```

---

## Packages

```bash
apt

dpkg
```

---

## System Calls

```bash
strace
```

---

# Standard Troubleshooting Workflow

## Application unavailable

Check process

```bash
ps aux
```

↓

Check listening ports

```bash
ss -tulpn
```

↓

Test application

```bash
curl
```

↓

Review logs

```bash
journalctl
```

↓

Check CPU / RAM / Disk

```bash
top
free -h
df -h
```

↓

Verify network

```bash
ping
dig
ip route
```

---

# Summary

During this lab I reviewed how to troubleshoot Linux systems using a structured approach instead of guessing.

The focus was on combining knowledge from previous labs to investigate common production issues.

---

# Interview Notes ⭐

A good Linux/DevOps/SRE engineer should troubleshoot problems methodically.

Typical order:

1. Verify the process is running.
2. Check whether the service is listening.
3. Test connectivity.
4. Review logs.
5. Check CPU, memory and disk usage.
6. Verify DNS and networking.
7. Use `strace` when application behaviour is unclear.

The goal is not to memorize commands, but to develop a logical troubleshooting workflow.
