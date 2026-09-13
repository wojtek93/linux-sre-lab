# MOT-28 — Manual Integration Testing and Test Automation

## Goal

Practice manual integration testing of a Linux platform service and automate repeatable validation checks.

The objective was to verify that a deployed service is not only running, but is also listening on the expected port and responding correctly at the application level.

## Manual Verification Flow

```text
service
↓
port
↓
application endpoint
↓
logs
```

Typical manual checks:

```bash
systemctl status <service>
systemctl is-active <service>
ss -tlnp
curl <endpoint>
journalctl -u <service>
```

## Service Check

For automation:

```bash
systemctl is-active --quiet "$SERVICE"
```

Exit code `0` means the service is active. A non-zero exit code indicates a failure.

## Port Check

To inspect listening TCP ports:

```bash
ss -tlnp
```

For an automated check:

```bash
ss -tlnp | grep -q ":$PORT"
```

`grep -q` produces no normal output and allows the script to use its exit code.

## Application Check

A running service and listening port do not guarantee that the application works correctly.

The application can be checked with:

```bash
curl -fsS "http://localhost:${PORT}/" > /dev/null
```

Options:

- `-f` — HTTP 4xx/5xx causes curl to fail
- `-s` — silent mode
- `-S` — show errors despite silent mode
- `${PORT}` — use the port provided to the script
- `> /dev/null` — discard response body

## HTTP Status vs Exit Code

HTTP status and process exit code are different things.

```text
HTTP 200
↓
curl succeeds
↓
exit code 0
```

Failure example:

```text
HTTP 500 / 502
↓
curl -f fails
↓
non-zero exit code
```

A CI/CD system such as Jenkins can use the process exit code to determine whether the validation succeeded.

## Integration Test Script

The script accepts two arguments:

```text
$1 = service name
$2 = port
```

Example:

```bash
./integration_test.sh nginx 80
```

Script:

```bash
#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <name_of_service> <port>"
    exit 2
fi

SERVICE=$1
PORT=$2

if systemctl is-active --quiet "$SERVICE"; then
    echo "$SERVICE is active"
else
    echo "$SERVICE is not active"
    exit 1
fi

if ss -tlnp | grep -q ":$PORT"; then
    echo "Port $PORT is listening"
else
    echo "Port $PORT is not listening"
    exit 1
fi

if curl -fsS "http://localhost:${PORT}/" > /dev/null; then
    echo "Health check passed"
else
    echo "Health check failed"
    exit 1
fi

echo "Success"
exit 0
```

## Real Test

We used the existing nginx service.

The service check passed:

```text
nginx is active
```

The port check passed:

```text
Port 80 is listening
```

The HTTP request returned:

```text
HTTP 502
```

The automated test therefore correctly reported a failure.

This demonstrates an important principle:

```text
service running != application healthy
```

A process can be running and listening on the expected port while the application-level request still fails.

## CI/CD Integration

The same validation script could be executed after deployment from a Jenkins pipeline.

```text
Deploy
↓
Integration Test
↓
exit 0 → continue
exit != 0 → fail
```

This makes the manual validation process repeatable and suitable for automation.

## Interview Answer

> I would first verify that the service is running, then check whether it is listening on the expected port, test the application endpoint and review the logs. After confirming the manual validation flow, I would automate the same checks in a script and run them after deployment in a CI/CD pipeline. The script would return exit code 0 if all checks pass and a non-zero exit code if any validation fails.

## Key Takeaways

- Service status alone is not enough.
- A listening port alone is not enough.
- Application-level validation is also required.
- HTTP status codes and process exit codes are different.
- `curl -f` converts HTTP error responses into command failures.
- Scripts should return meaningful exit codes.
- Manual integration checks can be converted into repeatable CI/CD tests.
