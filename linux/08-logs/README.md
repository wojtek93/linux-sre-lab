# LIN-08 — Linux Logs

## Objective

Learn how to inspect, filter, and analyze Linux logs using common command-line tools. This lab focuses on real-world troubleshooting techniques used by Linux administrators, DevOps Engineers, and Site Reliability Engineers (SREs).

---

## What I learned

- Understand the difference between system logs and application logs.
- Use `journalctl` to inspect logs collected by `systemd`.
- Monitor logs in real time.
- Filter log entries using `grep`.
- Count matching log entries.
- Search log context before and after errors.
- Extract selected fields using `awk`.
- Combine multiple Linux commands with pipes.
- Analyze logs during simulated production incidents.

---

## Commands practiced

### Systemd journal

```bash
journalctl
journalctl --no-pager
journalctl -u sre-demo
journalctl -u sre-demo -f
journalctl --since "10 minutes ago"
journalctl --since "14:20" --until "14:40"
```

---

### Tail

```bash
tail app.log
tail -20 app.log
tail -f app.log
```

---

### Grep

```bash
grep "ERROR" app.log
grep -i "error" app.log
grep -c "ERROR" app.log
grep -E "ERROR|FATAL" app.log

grep -A 5 "ERROR" app.log
grep -B 5 "ERROR" app.log
grep -C 5 "ERROR" app.log
```

---

### Awk

```bash
awk '{print $7}' app.log

awk '$3=="ERROR"' app.log

awk '$3=="ERROR" {print $4,$5}' app.log

awk '/ERROR/ {found=1} found' app.log
```

---

### Pipelines

Find the largest response time:

```bash
grep "WARNING" app.log \
| awk '{print $7}' \
| sort -nr \
| head -n 1
```

---

## Incident scenarios

### Incident 1

Application stopped responding.

Steps:

1. Check service status.

```bash
systemctl status sre-demo
```

2. Inspect service logs.

```bash
journalctl -u sre-demo
```

3. Monitor logs while restarting the service.

```bash
journalctl -u sre-demo -f
```

---

### Incident 2

Application crashes because of database timeout.

Useful commands:

```bash
grep "ERROR" app.log

grep -E "ERROR|FATAL" app.log

grep -c "ERROR" app.log
```

---

### Incident 3

Find everything after the first error.

```bash
awk '/ERROR/ {found=1} found' app.log
```

---

### Incident 4

Find the highest response time.

```bash
grep "WARNING" app.log \
| awk '{print $7}' \
| sort -nr \
| head -n 1
```

---

## Key takeaways

- `journalctl` is the primary tool for viewing logs from systemd services.
- `tail -f` is useful for monitoring application logs in real time.
- `grep` is the fastest way to filter log entries.
- `awk` can extract and process structured log data.
- Combining simple tools with pipes creates powerful log-analysis workflows.
- Always investigate logs before restarting a service.
- During incident response, focus on what happened before and after the failure.

---

## Skills gained

- Linux log analysis
- systemd journal inspection
- Log filtering
- Basic incident investigation
- Command pipelines
- Text processing with awk
- Production troubleshooting fundamentals
