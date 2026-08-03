# BAS-19 - Lock File

## Objective

Learn how to prevent multiple instances of the same Bash script from running simultaneously using a lock file.

## Skills Practiced

- File locking
- Mutual exclusion (Mutex)
- `trap`
- Signal-safe cleanup
- Conditional statements
- Creating directories
- Timestamps
- Defensive Bash scripting

## Project Structure

```text
19-locking/
├── backup.sh
├── README.md
└── output/
```

## Features

- Prevents concurrent execution using a lock file
- Automatically removes the lock file on exit
- Simulates a backup process
- Creates timestamped backup files
- Handles normal and abnormal script termination

## Locking Workflow

1. Check if `backup.lock` exists.
2. If it exists:
   - Print an error message.
   - Exit with status `1`.
3. Otherwise:
   - Create the lock file.
   - Register a cleanup function using `trap`.
   - Perform the backup.
   - Create a timestamped output file.
   - Exit successfully.
4. `trap` automatically removes the lock file.

## Example

First terminal:

```bash
./backup.sh
```

Output:

```text
Backup started...
Backup created: output/backup_2026-08-03_20-15-10.txt
Backup completed successfully.
```

Second terminal (while the first is still running):

```bash
./backup.sh
```

Output:

```text
Another instance is already running.
```

## Output

Example:

```text
output/
└── backup_2026-08-03_20-15-10.txt
```

## Key Concepts

### Check if lock exists

```bash
[[ -f "$lock_file" ]]
```

### Create lock

```bash
touch "$lock_file"
```

### Automatic cleanup

```bash
trap 'rm -f "$lock_file"' EXIT
```

### Timestamp

```bash
date "+%F_%H-%M-%S"
```

## What I Learned

- Why lock files are necessary in automation.
- How to prevent concurrent script execution.
- How `trap` guarantees cleanup.
- How to safely create temporary resources.
- How lock files are commonly used in cron jobs, backups, deployments, and DevOps automation.
