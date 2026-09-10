# MOT-08 — Linux Load Average

## Goal
Understand Linux load average and interpret it correctly in relation to CPU count and system load trends.

## Basic command

```bash
uptime
```

Example:

```text
load average: 0.80, 2.50, 6.00
```

The three values represent:

```text
1 minute / 5 minutes / 15 minutes
```

## CPU comparison

Check the number of CPUs:

```bash
nproc
```

Always compare load average with the CPU count.

Example for 4 CPUs:

```text
load average: 0.80, 2.50, 6.00
```

The load is decreasing:

- 15 min → 6.00
- 5 min → 2.50
- 1 min → 0.80

## Important

High load does not automatically mean high CPU usage.

Linux load average includes:

- runnable tasks — running or waiting for CPU
- tasks in uninterruptible sleep — often waiting for I/O

To investigate further:

```bash
top
vmstat 1 5
iostat -xz 1 3
```

Useful `vmstat` fields:

- `r` → runnable tasks / CPU pressure
- `b` → blocked tasks
- `wa` → I/O wait

## Interview answer

> Load average shows the average number of runnable and uninterruptible tasks over the last 1, 5 and 15 minutes. I compare it with the number of CPUs and check the trend. High load does not necessarily mean a CPU bottleneck because I/O waiting can also increase load average.

## Troubleshooting flow

```text
Load average
      ↓
Compare with CPU count
      ↓
Check trend: 1 / 5 / 15 min
      ↓
CPU pressure or I/O?
      ↓
top / vmstat / iostat
```
