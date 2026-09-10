# MOT-10 — High Memory Incident

## Goal

Diagnose high memory usage, identify memory-consuming processes and determine whether the system is under real memory pressure.

## Check overall memory usage

```bash
free -h
```

Important fields:

```text
total       total RAM
used        memory currently used
free        completely unused RAM
buff/cache  memory used by Linux for cache
available   memory realistically available for applications
```

The most important value is:

```text
available
```

Low `free` memory does not automatically mean there is a memory problem. Linux uses unused RAM for cache and can reclaim it when applications need memory.

## Identify processes using RAM

```bash
ps aux --sort=-%mem | head
```

Important columns:

```text
%MEM     percentage of RAM used by the process
PID      process ID
COMMAND  process name / command
```

Always identify the process before taking any action.

## Check swap activity

```bash
vmstat 1 5
```

For memory troubleshooting focus on:

```text
si  swap in  - data moved from swap to RAM
so  swap out - data moved from RAM to swap
```

If `si` and `so` remain around zero, the system is not actively moving memory between RAM and swap.

High sustained swap activity can indicate memory pressure.

## Detailed memory information

```bash
cat /proc/meminfo | head
```

Useful fields:

```text
MemTotal
MemFree
MemAvailable
Cached
```

`/proc/meminfo` provides detailed memory information from the Linux kernel.

## Troubleshooting flow

```text
High memory symptom
        ↓
free -h
        ↓
Check available memory
        ↓
ps aux --sort=-%mem
        ↓
Identify memory-consuming process
        ↓
vmstat
        ↓
Check swap activity
        ↓
Mitigate if necessary
        ↓
Verify
```

## Key lesson

```text
Low free RAM != memory problem

Look primarily at available memory
and check whether the system is actively using swap.
```

## Interview answer

> I would first use free -h to check whether the system is actually under memory pressure, focusing mainly on available memory. Then I would use ps to identify the processes consuming the most RAM. I would also check vmstat for swap activity. If necessary, I would investigate the problematic process, mitigate the issue and verify that memory usage returns to normal.
