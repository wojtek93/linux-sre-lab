# Linux Lab 11 - CPU Monitoring and High CPU Investigation

## Objective

Learn how to inspect CPU information, monitor CPU utilization, identify CPU-intensive processes, and analyze process details using standard Linux tools.

---

## Commands Used

### Display CPU information

```bash
lscpu
```

Displays CPU architecture, number of CPUs, cores, threads, cache sizes and processor model.

---

### Monitor system in real time

```bash
top
```

Shows:

- CPU utilization
- Memory usage
- Running processes
- Load average

---

### Sort processes by CPU usage

```bash
ps aux --sort=-%cpu | head
```

Displays the processes consuming the most CPU.

---

### Simulate high CPU usage

```bash
yes > /dev/null
```

Continuously prints "y" to `/dev/null`, consuming nearly 100% of one CPU core.

Stop the process:

```bash
Ctrl + C
```

---

### View process information

```bash
cat /proc/<PID>/status
```

Displays detailed process information including:

- PID
- State
- UID/GID
- Memory usage
- Threads
- Capabilities

---

## Example Investigation

Generate CPU load:

```bash
yes > /dev/null
```

Open another terminal:

```bash
top
```

Observe:

- `yes` consuming ~100% CPU
- Increased load average
- Higher user CPU usage

Find the process:

```bash
ps aux --sort=-%cpu | head
```

Inspect it:

```bash
cat /proc/<PID>/status
```

Stop the load:

```bash
Ctrl + C
```

---

## Key Concepts

### CPU

The Central Processing Unit executes instructions and performs calculations for all running programs.

---

### Load Average

Average number of processes waiting for CPU or currently running.

Example:

```
load average: 1.10 0.67 0.29
```

On a 4-core system:

- Load ≈ 1 → low utilization
- Load ≈ 4 → all CPU cores busy
- Load > 4 → processes waiting for CPU

---

### CPU States

`top` displays CPU time distribution:

| Field | Meaning |
|------|---------|
| us | User processes |
| sy | Kernel (system) processes |
| ni | Nice processes |
| id | Idle CPU |
| wa | Waiting for I/O |
| hi | Hardware interrupts |
| si | Software interrupts |
| st | CPU stolen by hypervisor |

---

## Files Created

```
linux/11-cpu/
├── README.md
```

---

## Skills Practiced

- Reading CPU information
- Monitoring CPU usage
- Understanding load average
- Identifying CPU-intensive processes
- Simulating CPU load
- Inspecting process metadata
- Using `/proc`
