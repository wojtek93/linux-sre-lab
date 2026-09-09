# MOT-07 — Linux Server Troubleshooting

## Goal

Practice a systematic troubleshooting flow for a slow or unhealthy Linux server.

The investigation covered:

- CPU usage
- Load average
- Memory
- Swap
- Disk space
- Disk I/O
- Processes
- systemd services
- system logs
- Mitigation and verification

---

## 1. CPU and Processes

Check overall CPU usage and running processes:

```bash
top
```

Find the processes consuming the most CPU:

```bash
ps aux --sort=-%cpu | head
```

In the lab, a CPU-intensive process was generated using:

```bash
yes > /dev/null &
```

The `yes` process consumed approximately 100% of one logical CPU.

After identifying the PID, the process was stopped:

```bash
kill <PID>
```

CPU usage was checked again to verify that the mitigation worked.

---

## 2. Load Average

Check system load:

```bash
uptime
```

Example:

```text
load average: 3.83, 1.93, 0.99
```

The three values represent the average system load over:

- 1 minute
- 5 minutes
- 15 minutes

Check the number of available logical CPUs:

```bash
nproc
```

Load average should always be interpreted relative to the number of CPUs.

Linux load includes tasks that are:

- runnable and waiting for CPU
- in uninterruptible sleep, commonly because of I/O

Therefore, high load does not automatically mean high CPU utilization.

---

## 3. Memory

Check memory:

```bash
free -h
```

Important fields:

- `used` — memory currently used
- `available` — memory that can realistically be allocated without heavy swapping
- `buff/cache` — filesystem cache that Linux can reclaim
- `swap` — disk-backed virtual memory

Low `free` memory alone does not mean that the server has a memory problem.

`available` is generally more useful when assessing memory pressure.

---

## 4. vmstat

Run:

```bash
vmstat 1 5
```

Important fields:

```text
r   processes waiting/runnable for CPU
b   blocked processes

si  swap in
so  swap out

us  CPU used by user-space processes
sy  CPU used by the kernel
id  idle CPU
wa  CPU waiting for I/O
```

Example interpretation:

```text
r=0
b=0
si=0
so=0
us=2
sy=15
id=82
wa=0
```

This indicates:

- no significant CPU queue
- no blocked processes
- no active swapping
- plenty of idle CPU
- no significant I/O wait

---

## 5. Disk Space

Check filesystem usage:

```bash
df -h
```

During the lab, the root filesystem was approximately 86% full.

This was not yet a disk-full incident, but it should be monitored.

---

## 6. Disk I/O

Check disk performance:

```bash
iostat -xz 1 3
```

Important indicators include:

- `%util`
- `await`
- `%iowait`

Low values during the lab indicated that disk I/O was not the source of the performance problem.

---

## 7. Service Troubleshooting

A controlled nginx configuration failure was introduced.

After restarting nginx:

```bash
sudo systemctl restart nginx
```

the service failed.

The first diagnostic step was:

```bash
systemctl status nginx
```

Then logs were investigated:

```bash
journalctl -u nginx --since "10 minutes ago"
```

or:

```bash
journalctl -xeu nginx
```

The logs reported:

```text
getpwnam("THIS_IS_BROKEN") failed in /etc/nginx/nginx.conf:1
```

This indicated an invalid user configured in nginx.

The original configuration was restored.

Before restarting the service, the configuration was validated:

```bash
sudo nginx -t
```

Expected result:

```text
syntax is ok
test is successful
```

Then nginx was restarted and verified:

```bash
sudo systemctl restart nginx
systemctl status nginx
```

---

## Troubleshooting Flow

```text
SYMPTOM
   |
   v
Check CPU / processes
top
ps
   |
   v
Check system load
uptime
nproc
   |
   v
Check memory / swap
free
vmstat
   |
   v
Check disk capacity
df
   |
   v
Check disk I/O
iostat
   |
   v
Check service
systemctl status
   |
   v
Check logs
journalctl
   |
   v
Identify root cause
   |
   v
Mitigate
   |
   v
Verify service and system health
   |
   v
Root Cause Analysis / Prevention
```

## Interview Summary

When troubleshooting a slow Linux server, I first determine whether the bottleneck is related to CPU, memory, disk I/O, disk capacity or a specific service.

I use tools such as `top`, `ps`, `uptime`, `free`, `vmstat`, `iostat` and `df` to narrow down the problem.

If a service is affected, I check its state with `systemctl` and investigate logs using `journalctl`.

After identifying the likely cause, I mitigate the impact, verify that the system has recovered, and then investigate the root cause and how to prevent recurrence.

## Key Principle

```text
Identify
→ Confirm
→ Mitigate
→ Verify
→ Root Cause
→ Prevent recurrence
```
