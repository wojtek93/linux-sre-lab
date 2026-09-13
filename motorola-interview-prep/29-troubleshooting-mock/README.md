# MOT-29 — Full Troubleshooting Mock

## Goal

Practice a structured troubleshooting approach for common Linux platform incidents.

The main troubleshooting flow used in this lab:

**Symptom → Hypotheses → Evidence → Narrow Down → Safe Fix / Mitigation → Verification → RCA / Prevention**

---

## Scenario 1 — Slow Linux Server

### Symptom

A Linux production server is very slow.

Observed:
- CPU usage around 20%
- memory usage normal
- load average around 24
- system has 8 CPU cores

### Initial investigation

Check the overall system state:

```bash
top
vmstat 1
```

Because the load is high while CPU utilization is relatively low, investigate I/O:

```bash
iostat -xz 1
sudo iotop
```

### Important observation

Processes in `D` state can contribute to high load average.

`D` means:

**Uninterruptible sleep**

This often means the process is waiting for I/O, for example:

- disk access
- storage
- network filesystem

### Interview answer

> First, I would check `vmstat` and `iostat`, because high load with relatively low CPU utilization could indicate that processes are waiting for I/O. I would then inspect disk latency and utilization and identify processes generating I/O using `iotop`.

### Key lesson

High load average does not always mean high CPU usage.

---

## Scenario 2 — Virtual Machine Does Not Start

### Symptom

A virtual machine fails to start.

### Investigation

Check whether the virtualization service is running.

Then verify:

- VM configuration
- virtual disk path
- file permissions
- service user permissions
- host CPU resources
- host memory
- available disk space
- virtualization logs

Example checks:

```bash
systemctl status libvirtd
ls -l /path/to/vm.qcow2
ls -ld /path/to/
ps aux | grep qemu
df -h
```

Try to start the VM manually and capture the exact error.

### Possible causes

- incorrect disk path
- permission problem
- corrupted virtual disk image
- insufficient host resources
- virtualization configuration error

### Interview answer

> I would first confirm the exact symptom and determine what happens when the VM tries to start. Then I would check the virtualization logs and try to start the VM manually so I can capture the exact error message. Based on that evidence, I would narrow down the root cause.

### Key lesson

Do not guess the failure. Use the startup error and logs to narrow down the cause.

---

## Scenario 3 — Server Not Reachable Over Network

### Symptom

Users cannot connect to a Linux server.

### Investigation

First determine whether:

- the whole server is unreachable
- only one specific service is unreachable

Check the server network configuration:

```bash
ip addr
ip route
```

Test connectivity:

```bash
ping <server_ip>
nc -vz <server_ip> <port>
```

If the issue affects a specific service, check whether it is listening:

```bash
sudo ss -tlnp
```

Check firewall rules:

```bash
sudo iptables -L -n
```

### Example

```text
LISTEN  0  128  127.0.0.1:22  0.0.0.0:*
```

This means SSH is listening only on the loopback interface.

Remote clients cannot connect.

Possible correct binding:

```text
0.0.0.0:22
```

or a specific server interface IP.

### Interview answer

> Since ping works, basic IP connectivity is available. Because the TCP connection to port 22 fails, I would check whether SSH is actually listening on that port using `ss -tlnp`. If the service is bound only to `127.0.0.1`, it is reachable only locally.

### Key lesson

Separate basic network connectivity from application-level connectivity.

---

## Scenario 4 — Disk Full

### Symptom

The server reports:

```text
No space left on device
```

### Step 1 — Identify the full filesystem

```bash
df -h
```

Example:

```text
/var → 100% used
```

### Step 2 — Find large directories

```bash
sudo du -sh /var/* 2>/dev/null | sort -hr
```

Do not immediately delete files.

First understand what is using the space.

### Special case — `df` and `du` disagree

If `df` reports the filesystem as full but `du` cannot find the space usage, check for deleted files still held open by processes:

```bash
sudo lsof +L1
```

A deleted file can still consume disk space while a running process holds its file descriptor open.

### Recovery

Identify the process holding the file.

If it is safe, perform a controlled restart of the process or service.

Then verify:

```bash
df -h
```

### Interview answer

> I would suspect a deleted file that is still open by a running process. The file is no longer visible in the filesystem, so `du` does not count it, but the process still holds the file descriptor and the space is not released. I would check this with `sudo lsof +L1`.

### Prevention

Investigate why the file became so large.

Possible improvements:

- log rotation
- monitoring
- disk usage alerts
- application log limits

---

## Scenario 5 — Failed Linux Service

### Symptom

Users report that an application is unavailable.

If the service name is unknown, identify failed units:

```bash
systemctl --failed
```

Check recent system errors:

```bash
journalctl -p err -b
```

After identifying the affected service:

```bash
systemctl status <service>
journalctl -u <service>
```

Example:

```text
ERROR: Cannot connect to database 10.0.2.15:5432
```

### Database connectivity investigation

Test the TCP connection:

```bash
nc -vz 10.0.2.15 5432
```

If it times out, investigate:

```bash
ip route
sudo iptables -L -n
ping 10.0.2.15
```

If access to the database server is available, verify whether the database is listening:

```bash
sudo ss -tlnp | grep ':5432'
```

### Important distinction

`5432` is the remote database port.

Running `ss -tlnp` on the application server does not prove whether the remote database is listening.

### Senior-level next step

Finding the root cause is not the end of troubleshooting.

After identifying the cause:

1. assess the impact
2. determine the safest recovery action
3. avoid blind production changes
4. use runbooks or involve the owning team when necessary
5. apply a controlled fix, rollback, workaround or escalation
6. verify the service end-to-end
7. perform root cause analysis
8. improve prevention

Possible prevention improvements:

- monitoring
- alerts
- health checks
- runbooks
- automation
- configuration validation

### Senior troubleshooting flow

**Find cause → Assess impact → Choose safest recovery → Verify → RCA → Prevention**

### Interview answer

> Once I identify the root cause, I would assess the impact and choose the safest recovery action. I would avoid making changes blindly, especially in production. If necessary, I would follow the runbook or involve the team responsible for the affected component. After recovery, I would verify the service end to end and then perform root cause analysis to prevent the issue from happening again.

---

## Final Troubleshooting Checklist

For production incidents, use this structure:

1. Confirm the symptom.
2. Determine the scope.
3. Form hypotheses.
4. Gather evidence.
5. Narrow down the root cause.
6. Assess impact and risk.
7. Choose the safest recovery action.
8. Apply the fix, workaround, rollback or escalation.
9. Verify the system end-to-end.
10. Perform RCA and improve prevention.

## Result

MOT-29 completed through five troubleshooting scenarios:

- slow Linux server
- VM startup failure
- network connectivity failure
- disk full
- failed service / database dependency failure

The focus was not only on commands, but on structured evidence-based troubleshooting and safe production recovery.
