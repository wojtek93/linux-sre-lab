# BAS-17 - Logging Library

## Objective

Learn how to build a reusable logging library in Bash.

## Skills Practiced

- Bash functions
- Local variables
- Reading configuration with `source`
- Command substitution
- Timestamps
- Logging to console and file
- Using `tee`
- Creating directories
- Reusable code (DRY)

## Project Structure

```text
17-logging/
├── logging_library.sh
├── README.md
├── config/
│   └── app.conf
└── logs/
    └── application.log
```

## Configuration

Example:

```ini
APP_NAME=linux-sre-lab
LOG_LEVEL=INFO
LOG_FILE=logs/application.log
```

## Features

- Reads configuration from `config/app.conf`
- Creates the log directory if it does not exist
- Displays log messages on the terminal
- Saves log messages to a log file
- Adds timestamps to every log entry

## Functions

```bash
log()
log_info()
log_warn()
log_error()
```

## Example Output

```text
2026-08-03 18:10:21 [INFO] Application started
2026-08-03 18:10:25 [WARN] Disk usage above 80%
2026-08-03 18:10:40 [ERROR] Database connection failed
```

## Run

```bash
chmod +x logging_library.sh

./logging_library.sh
```

## Log File

```text
logs/application.log
```

## Concepts Learned

- `source`
- `local`
- `tee`
- `tee -a`
- `dirname`
- `mkdir -p`
- `$(command)`
- Reusable Bash functions
- Logging best practices
