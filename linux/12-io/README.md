# Linux Lab 12 – Disk I/O Monitoring

## Objective

Learn how to monitor disk I/O activity and identify storage bottlenecks using Linux performance monitoring tools.

---

## Tools Used

- iostat
- dd
- which

---

## Commands

### Verify that iostat is installed

```bash
which iostat
```

### Display disk I/O statistics

```bash
iostat
```

### Extended statistics

```bash
iostat -x
```

### Refresh statistics every second

```bash
iostat -x 1
```

### Generate disk write activity

```bash
dd if=/dev/zero of=testfile bs=1M count=1024
```

### Remove the test file

```bash
rm testfile
```

---

## Key Metrics

- **r/s** – read operations per second
- **w/s** – write operations per second
- **rkB/s** – kilobytes read per second
- **wkB/s** – kilobytes written per second
- **%util** – percentage of time the disk is busy
- **await** – average I/O request latency
- **svctm** *(older systems only)* – average service time

---

## What I Learned

- Monitor disk performance with `iostat`.
- Generate artificial disk activity using `dd`.
- Observe how disk metrics change under load.
- Identify basic indicators of disk bottlenecks.
