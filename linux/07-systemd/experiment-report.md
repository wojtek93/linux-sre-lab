# LIN-07 Experiment Report

## Objective

Create and manage a custom systemd service.

---

## Environment

- Ubuntu
- Bash
- systemd

---

## Experiments

### Experiment 1

Created a long-running Bash application.

Result:

Application prints a message every five seconds.

---

### Experiment 2

Created a custom systemd service.

Result:

Service started successfully.

---

### Experiment 3

Checked service status.

Command:

```bash
systemctl status sre-demo
```

Result:

Service is active and running.

---

### Experiment 4

Viewed service logs.

Command:

```bash
journalctl -u sre-demo -f
```

Result:

Logs are streamed in real time.

---

### Experiment 5

Enabled automatic startup.

Command:

```bash
systemctl enable sre-demo
```

Result:

Service is configured to start during boot.

---

### Experiment 6

Reloaded systemd configuration.

Command:

```bash
systemctl daemon-reload
```

Result:

Modified unit file was successfully reloaded.

---

## Conclusion

This lab demonstrated how to create, configure and manage services using systemd.

Key concepts learned:

- PID 1
- Unit files
- Service management
- Logging
- Automatic restart
- Boot-time activation
