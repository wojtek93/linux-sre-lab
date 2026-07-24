# Linux Signals Lab

## Objective

The purpose of this lab was to understand how Linux signals work, how they are delivered to processes, and how Bash scripts can respond to them using the `trap` command.

The lab demonstrates graceful process termination, signal handling, and the behavior of different Linux signals.

---

## Topics Covered

- Linux signals
- Process communication
- `kill`
- `trap`
- SIGINT
- SIGTERM
- SIGUSR1
- SIGUSR2
- SIGKILL
- SIGSTOP
- SIGCONT
- Graceful shutdown

---

## Project Structure

```
06-signals/
├── README.md
├── experiment-report.md
├── scripts/
│   └── signal_lab.sh
└── examples/
```

---

## Script Features

The Bash script:

- prints its own PID
- runs continuously in an infinite loop
- handles multiple Linux signals
- demonstrates graceful shutdown
- exits correctly after receiving SIGTERM

Implemented signal handlers:

| Signal | Action |
|---------|--------|
| SIGUSR1 | Print custom message |
| SIGUSR2 | Print custom message |
| SIGINT | Print notification |
| SIGTERM | Cleanup resources and terminate |

---

## Commands Used

```bash
kill -USR1 <PID>

kill -USR2 <PID>

kill -INT <PID>

kill -TERM <PID>

kill -STOP <PID>

kill -CONT <PID>

kill -l
```

---

## Key Concepts

### Linux Signals

Signals are software interrupts used by the operating system to notify processes about specific events.

---

### SIGTERM

Requests graceful process termination.

The process can:

- finish current work
- release resources
- close files
- save data
- exit cleanly

---

### SIGKILL

Immediately terminates a process.

It cannot be:

- caught
- ignored
- handled with `trap`

---

### SIGSTOP

Temporarily stops a running process.

The process remains in memory and can later be resumed using `SIGCONT`.

---

### trap

The Bash `trap` command executes custom code when specific signals are received.

Example:

```bash
trap 'echo "SIGTERM received."' SIGTERM
```

---

## Learning Outcome

After completing this lab I understand:

- how Linux signals work
- how the `kill` command sends signals
- how Bash handles signals using `trap`
- how to implement graceful shutdown
- the difference between SIGTERM and SIGKILL
- why SIGKILL and SIGSTOP cannot be trapped
- how to stop and resume processes using SIGSTOP and SIGCONT
