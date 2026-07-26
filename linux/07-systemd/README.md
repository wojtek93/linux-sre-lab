# LIN-07 — systemd

## Goal

Learn how systemd manages Linux services and how to create your own systemd service.

## Topics Covered

- PID 1
- systemd architecture
- Unit files
- Service lifecycle
- systemctl
- journalctl
- daemon-reload
- enable / disable
- automatic restart

## Files

```
07-systemd/
├── README.md
├── experiment-report.md
├── scripts/
│   └── app.sh
├── systemd/
│   └── sre-demo.service
└── examples/
```

## Commands Practiced

```bash
systemctl start
systemctl stop
systemctl restart
systemctl status
systemctl enable
systemctl disable
systemctl daemon-reload

journalctl -u <service>
journalctl -u <service> -f

systemd-analyze verify
```

## What I Learned

- systemd is PID 1
- Services are defined using .service files
- systemctl manages services
- journalctl reads service logs
- daemon-reload reloads unit files
- enable starts services during boot
- Restart policy controls automatic recovery
