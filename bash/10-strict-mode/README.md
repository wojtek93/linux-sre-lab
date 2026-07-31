# Lab 10 - Strict Mode

## Objective

Learn how Bash strict mode (`set -euo pipefail`) improves script reliability by preventing silent failures, detecting undefined variables, and handling pipeline errors correctly.

## Skills Practiced

- `set -e`
- `set -u`
- `set -o pipefail`
- Error handling
- Exit codes
- Pipeline behavior
- Undefined variables
- Conditional execution
- Bash safety best practices

## Files

```
strict_mode_lab.sh
```

## Run

```bash
chmod +x strict_mode_lab.sh

./strict_mode_lab.sh
```

## Experiments

### Experiment 1 - `set -e`

Verify that the script stops immediately after a command returns a non-zero exit code.

### Experiment 2 - `set -u`

Verify that accessing an undefined variable terminates the script.

### Experiment 3 - `pipefail`

Compare pipeline behavior with and without `pipefail`.

### Experiment 4 - `if` exception

Observe that commands used as conditions inside an `if` statement do not terminate the script even when `set -e` is enabled.

### Experiment 5 - `&&` and `||`

Understand why logical operators are exceptions to `set -e`.

## What I Learned

- Why production Bash scripts commonly start with:

```bash
set -euo pipefail
```

- How `set -e` stops execution after unexpected failures
- How `set -u` detects undefined variables
- How `pipefail` propagates failures inside pipelines
- Why `set -e` has exceptions (`if`, `while`, `&&`, `||`)
- When additional error handling is still required
