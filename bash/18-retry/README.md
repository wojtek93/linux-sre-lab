# BAS-18 - Retry Mechanism

## Objective

Learn how to implement a retry mechanism in Bash for commands that may fail temporarily.

## Skills Practiced

- Bash loops
- Exit codes
- Conditional command execution
- Retry limits
- Delays with `sleep`
- Command arguments
- Command substitution and evaluation
- Defensive scripting
- SRE retry patterns

## Project Structure

```text
18-retry/
├── retry.sh
├── README.md
├── logs/
└── scripts/
    └── unreliable_command.sh
```

## Features

- Retries a command after failure
- Limits the number of attempts
- Stops immediately after success
- Waits between attempts
- Returns exit code `1` after exhausting retries
- Can execute a simulated unreliable command
- Can be adapted to run other commands

## Example

```bash
./retry.sh "./scripts/unreliable_command.sh"
```

Example output:

```text
Attempt 1/5
Failure
Command failed.
Retrying in 2 seconds...

Attempt 2/5
Success
Command succeeded.
```

## Failure Test

```bash
./retry.sh false
```

Expected result:

```text
Attempt 1/5
Command failed.
Retrying in 2 seconds...

...

Attempt 5/5
Command failed.
Retry limit exceeded.
```

## Success Test

```bash
./retry.sh "echo hello"
```

Expected result:

```text
Attempt 1/5
hello
Command succeeded.
```

## Key Concepts

### Retry loop

```bash
for (( i=1; i<=MAX_RETRIES; i++ )); do
    ...
done
```

### Delay between attempts

```bash
sleep "$RETRY_DELAY"
```

### Stop after success

```bash
exit 0
```

### Fail after retry exhaustion

```bash
exit 1
```

## What I Learned

- How to retry transiently failing commands.
- How to limit the maximum number of attempts.
- How to use exit codes to detect success and failure.
- How to avoid sleeping after the final failed attempt.
- How retry mechanisms are used in DevOps and SRE automation.
