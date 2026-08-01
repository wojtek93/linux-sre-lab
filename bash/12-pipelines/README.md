# BAS-12 – Pipeline Challenge

## Objective

Create a Bash script that analyzes an application log using Unix pipelines.

## Features

- Verifies that the input log file exists.
- Displays the most frequent ERROR messages.
- Counts log entries by log level (INFO, WARN, ERROR).
- Counts the total number of log entries.
- Counts the total number of ERROR entries.
- Displays unique ERROR messages.

## Technologies

- Bash
- grep
- cut
- awk
- sort
- uniq
- wc

## Usage

```bash
./pipeline_challenge.sh
```

## Example Output

```
ERROR summary:
      3 Database connection failed
      2 Authentication failed
      2 File not found

Log level summary:
      6 ERROR
      2 WARN
      2 INFO

Total log entries:
10

Total errors:
6

Unique ERROR messages:
Authentication failed
Database connection failed
File not found
```

## Learning Goals

- Bash pipelines
- Text processing
- Command chaining
- Log analysis
- Exit codes
