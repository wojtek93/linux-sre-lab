# MOT-12 — Service Fails to Start

## Goal

Diagnose and recover a Linux service that fails to start.

## Troubleshooting flow

```text
service failed
   ↓
systemctl status
   ↓
journalctl -u
   ↓
identify root cause
   ↓
fix configuration / permissions / dependency
   ↓
validate configuration
   ↓
restart service
   ↓
verify
```

## Check service status

```bash
systemctl status nginx
```

Look for:

- `active`
- `inactive`
- `failed`
- exit code
- recent error messages

## Check service logs

```bash
journalctl -u nginx
```

Recent logs:

```bash
journalctl -u nginx -n 50
```

## Validate configuration

For nginx:

```bash
sudo nginx -t
```

Always validate configuration before restarting the service when possible.

## Restart and verify

```bash
sudo systemctl restart nginx
systemctl status nginx
```

## Common causes

- invalid configuration
- missing file
- wrong permissions or ownership
- missing dependency
- port already in use
- invalid user/group
- filesystem full

## Interview answer

If a service failed to start, I would first check `systemctl status` to see the current state and initial error. Then I would inspect the service logs with `journalctl -u`. After identifying the cause, I would fix the configuration, permissions or dependency, validate the configuration if the application supports it, restart the service and verify that it is running correctly.
