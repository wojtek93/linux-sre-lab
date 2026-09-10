# MOT-09 — High CPU Incident

## Goal

Diagnose a high CPU issue, identify the responsible process, mitigate it and verify recovery.

## Generate CPU load

```bash
yes > /dev/null &
```

## Identify high CPU processes

```bash
top
```

or:

```bash
ps aux --sort=-%cpu | head
```

Important: always check the `COMMAND` column before taking action.

A process showing around `100% CPU` usually means it is consuming approximately one logical CPU.

## Check system-wide pressure

```bash
uptime
nproc
vmstat 1 5
```

Compare load average with the number of CPUs.

Useful `vmstat` fields:

```text
r   runnable tasks / CPU pressure
b   blocked tasks
us  user-space CPU
sy  kernel CPU
id  idle CPU
wa  I/O wait
```

High CPU usage by one process does not necessarily mean the whole server is overloaded.

## Mitigation

Find the PID:

```bash
pgrep yes
```

Terminate the problematic process:

```bash
kill <PID>
```

## Verification

Check again:

```bash
uptime
top
```

Verify that CPU usage and load are decreasing.

## Troubleshooting flow

```text
Symptom
   ↓
top / ps
   ↓
Identify process
   ↓
uptime / vmstat
   ↓
Mitigation
   ↓
Verification
```

## Interview answer

> I would first identify the CPU-intensive process using top or ps. Then I would check the overall system load and CPU pressure using uptime and vmstat. After confirming the problematic process, I would mitigate the issue and verify that CPU usage and load return to normal.
