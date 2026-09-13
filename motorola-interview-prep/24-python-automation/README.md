# MOT-24 — Python Automation Basics

## Goal

Create a small Python automation script that:

- accepts a log file as a command-line argument,
- reads the file line by line,
- detects ERROR and WARNING entries,
- counts detected messages,
- handles missing arguments and missing files,
- returns meaningful exit codes.

## Example Log

```text
2026-09-13 10:01:12 INFO Application started
2026-09-13 10:02:15 INFO User logged in
2026-09-13 10:03:41 ERROR Database connection failed
2026-09-13 10:04:02 WARNING High memory usage
2026-09-13 10:05:17 ERROR API request failed
```

## Python Script

```python
import sys

if len(sys.argv) < 2:
    print("Usage: python3 log_parser.py <filename>")
    sys.exit(1)

filename = sys.argv[1]

error_count = 0
warning_count = 0

try:
    with open(filename, "r") as file:
        for line in file:
            if "ERROR" in line:
                error_count += 1
            elif "WARNING" in line:
                warning_count += 1

except FileNotFoundError:
    print(f"ERROR: File '{filename}' not found")
    sys.exit(1)

print(f"ERROR's number {error_count}")
print(f"WARNING's number {warning_count}")

sys.exit(0)
```

## Tests

### Normal Log File

```bash
python3 log_parser.py app.log
echo $?
```

Expected:

```text
ERROR's number 2
WARNING's number 1
0
```

### Clean Log File

```bash
python3 log_parser.py clean.log
echo $?
```

Expected:

```text
ERROR's number 0
WARNING's number 0
0
```

### Missing File

```bash
python3 log_parser.py missing.log
echo $?
```

Expected:

```text
ERROR: File 'missing.log' not found
1
```

### Missing Argument

```bash
python3 log_parser.py
echo $?
```

Expected:

```text
Usage: python3 log_parser.py <filename>
1
```

## Key Concepts

### Command-line arguments

`sys.argv` contains arguments passed to the Python script.

For:

```bash
python3 log_parser.py app.log
```

we have:

```text
sys.argv[0] = log_parser.py
sys.argv[1] = app.log
```

### File Handling

```python
with open(filename, "r") as file:
```

The file is opened in read mode. Using `with` ensures that Python closes the file automatically after leaving the block.

### Log Parsing

The script reads the file line by line and checks whether each line contains `ERROR` or `WARNING`.

```python
if "ERROR" in line:
    error_count += 1
elif "WARNING" in line:
    warning_count += 1
```

### Exception Handling

```python
try:
    ...
except FileNotFoundError:
    ...
```

Instead of terminating with an uncontrolled traceback when the file does not exist, the script handles the expected exception and returns a useful message.

### Exit Codes

- `0` — successful execution
- `1` — execution failed

Exit codes are important in automation because tools such as Jenkins or GitHub Actions can use them to determine whether a step succeeded or failed.

## Bash vs Python

Python is useful when automation involves:

- file parsing,
- exception handling,
- structured data,
- more complex program logic,
- scripts that may grow and need to remain maintainable.

Bash is often a better choice for short system administration tasks, command execution and simple command chaining.

## Interview Takeaway

The script demonstrates a practical automation use case: reading a log file, parsing its contents, handling expected failures and returning meaningful exit codes.

A concise interview explanation:

> The script takes a file path as an argument and reads the file line by line. It checks for ERROR and WARNING messages and counts them. It also handles missing files using exception handling. On success it returns exit code 0, while failures return a non-zero exit code, which makes the script suitable for use in automation pipelines.

## What I Practiced

- Python command-line arguments
- `sys.argv`
- file handling
- loops and conditions
- log parsing
- counters
- `try` / `except`
- `FileNotFoundError`
- exit codes
- success and failure testing
- practical Python automation
- explaining automation during a technical interview
