# Bash Lab 04 – Service Check with Conditions

## Objective

Create a Bash script that checks the state of a systemd service using:

- `if`
- `elif`
- `else`
- meaningful exit codes

---

## Project Structure

```text
04-conditions/
├── service_check.sh
├── README.md
└── tests/
    ├── active_service.txt
    ├── missing_service.txt
    └── missing_argument.txt
```

---

## Usage

```bash
./service_check.sh <service_name>
```

Example:

```bash
./service_check.sh ssh
```

---

## Logic

The script checks the service in the following order:

1. Is the service active?
2. If not active, is it enabled?
3. Otherwise, report it as inactive or unavailable.

---

## Conditions

```bash
if systemctl is-active --quiet "$SERVICE_NAME"; then
```

Checks whether the service is currently running.

```bash
elif systemctl is-enabled --quiet "$SERVICE_NAME"; then
```

Checks whether the service is configured to start automatically.

```bash
else
```

Handles services that are inactive, disabled or unavailable.

---

## Exit Codes

| Exit code | Meaning |
|---:|---|
| `0` | Service is active |
| `1` | Service is enabled but inactive |
| `2` | Invalid usage, inactive service or missing service |

Exit codes allow other scripts, monitoring tools and CI/CD pipelines to determine whether the check succeeded.

Check the latest exit code:

```bash
echo "$?"
```

---

## Examples

### Active service

```bash
./service_check.sh ssh
```

```text
OK: Service 'ssh' is active.
```

### Missing service

```bash
./service_check.sh service-that-does-not-exist
```

```text
CRITICAL: Service 'service-that-does-not-exist' is inactive or does not exist.
```

### Missing argument

```bash
./service_check.sh
```

```text
Usage: service_check.sh <service_name>
```

---

## Skills Practiced

- `if/elif/else`
- argument validation
- `systemctl is-active`
- `systemctl is-enabled`
- meaningful exit codes
- safe variable quoting
