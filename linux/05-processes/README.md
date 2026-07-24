# Linux Process Management Lab

## Overview

This lab demonstrates fundamental Linux process management concepts using Bash.

The script starts a background process, retrieves its Process ID (PID) and Parent Process ID (PPID), displays information about both processes, verifies whether the process is running, and terminates it gracefully using Unix signals.

The implementation also demonstrates safe cleanup using Bash traps.

---

## Learning Objectives

- Start a process in the background
- Retrieve the process PID using `$!`
- Retrieve the parent PID (PPID)
- Display process information using `ps`
- Verify whether a process exists using `kill -0`
- Gracefully terminate a process with `SIGTERM`
- Force termination with `SIGKILL` if necessary
- Handle script cleanup using `trap`
- Apply Bash best practices with `set -euo pipefail`

---

## Project Structure

```
05-processes/
├── README.md
├── experiment-report.md
├── examples/
└── scripts/
    └── process_lab.sh
```

---

## How to Run

Make the script executable:

```bash
chmod +x scripts/process_lab.sh
```

Run the script:

```bash
./scripts/process_lab.sh
```

---

## Example Output

```text
=====================================
 Linux Process Management Lab
=====================================

Starting test process: sleep 300

Process started successfully.
PID: 22050
PPID: 22038

=====================================
 Child Process
=====================================

UID        PID    PPID CMD
wojtek   22050   22038 sleep 300

=====================================
 Parent Process
=====================================

UID        PID    PPID CMD
wojtek   22038   21981 bash

=====================================
 Process Status
=====================================

Process 22050 is running.

Sending SIGTERM to process 22050...

Process terminated gracefully after SIGTERM.

=====================================
 Process lab completed successfully
=====================================
```

---

## Key Concepts

### PID

A Process ID (PID) uniquely identifies a running process in Linux.

### PPID

A Parent Process ID (PPID) identifies the process that created another process.

### SIGTERM

Requests a process to terminate gracefully, allowing it to release resources and perform cleanup.

### SIGKILL

Immediately terminates a process. It cannot be caught or ignored.

### kill -0

Checks whether a process exists without sending a signal.

### trap

Executes cleanup code automatically when the script exits, preventing orphaned background processes.

---

## Skills Practiced

- Linux process management
- Bash scripting
- Process monitoring
- Signal handling
- Background jobs
- Process hierarchy
- Defensive scripting
- Resource cleanup
