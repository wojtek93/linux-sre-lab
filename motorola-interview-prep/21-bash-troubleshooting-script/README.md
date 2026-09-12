# MOT-21 — Bash Troubleshooting Script

## Goal

Practice writing a simple Bash troubleshooting script that:

- accepts an argument,
- reads disk usage,
- processes command output,
- compares values,
- prints a status,
- returns meaningful exit codes.

## Script

```bash
#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <threshold value>"
    exit 2
fi

TRESHOLD=$1

USAGE=$(df -h / | awk 'NR==2 {gsub("%",""); print $5}')

echo "Disk usage: $USAGE%"
echo "Threshold: $TRESHOLD%"

if [[ $USAGE -lt $TRESHOLD ]]; then
    echo "OK"
    exit 0
else
    echo "WARNING"
    exit 1
fi
```

## Important Bash Concepts

### Script arguments

```bash
$1
```

means the first argument passed to the script.

Example:

```bash
./disk_check.sh 80
```

Then:

```bash
$1 = 80
```

### Number of arguments

```bash
$#
```

returns the number of arguments passed to the script.

Example:

```bash
if [[ $# -ne 1 ]]; then
```

means:

```text
if number of arguments is not equal to 1
```

### Command substitution

```bash
$(command)
```

runs a command and stores its output.

Example:

```bash
USAGE=$(df -h / | awk 'NR==2 {gsub("%",""); print $5}')
```

### Extracting disk usage

```bash
df -h /
```

shows filesystem usage for `/`.

The script uses:

```bash
awk 'NR==2 {gsub("%",""); print $5}'
```

to:

- select the second line,
- remove `%`,
- print the usage value.

Example:

```text
42%
```

becomes:

```text
42
```

### Numeric comparison

```bash
-lt
```

means:

```text
less than
```

Example:

```bash
[[ $USAGE -lt $TRESHOLD ]]
```

### Exit codes

```text
0 → success / OK
1 → warning condition
2 → incorrect script usage
```

Check the exit code with:

```bash
echo $?
```

## Tests

```bash
./disk_check.sh 80
echo $?
```

Expected:

```text
OK
0
```

Test warning condition:

```bash
./disk_check.sh 1
echo $?
```

Expected:

```text
WARNING
1
```

Test missing argument:

```bash
./disk_check.sh
echo $?
```

Expected:

```text
Usage: ./disk_check.sh <threshold value>
2
```

## Interview Takeaway

A Bash troubleshooting script can combine:

```text
arguments
command substitution
text processing
conditions
exit codes
```

Example interview answer:

> I can use Bash for simple operational checks, for example checking disk usage, parsing command output with awk, comparing the result against a threshold and returning an appropriate exit code for monitoring or automation.
