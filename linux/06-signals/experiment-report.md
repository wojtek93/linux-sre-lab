# Experiment Report

## Experiment Objective

The goal of this experiment was to understand how Linux signals work and how Bash scripts can respond to them using the `trap` command.

The experiment focused on graceful process termination and custom signal handling.

---

## Environment

- Operating System: Ubuntu Linux
- Shell: Bash
- Editor: Vim

---

## Experiment Steps

### 1. Created a Bash script

A script was created that:

- prints its PID
- runs in an infinite loop
- prints a status message every two seconds

---

### 2. Added signal handlers

Signal handlers were implemented using the `trap` command for:

- SIGUSR1
- SIGUSR2
- SIGINT
- SIGTERM

Each signal performed a different action.

---

### 3. Tested SIGUSR1

Command:

```bash
kill -USR1 <PID>
```

Result:

- custom message displayed
- process continued running

---

### 4. Tested SIGUSR2

Command:

```bash
kill -USR2 <PID>
```

Result:

- custom message displayed
- process continued running

---

### 5. Tested SIGINT

Command:

```bash
kill -INT <PID>
```

and

```bash
Ctrl + C
```

Result:

- SIGINT handler executed
- custom message displayed

---

### 6. Tested SIGTERM

Command:

```bash
kill -TERM <PID>
```

Result:

- cleanup message displayed
- process exited gracefully

---

### 7. Tested SIGSTOP

Command:

```bash
kill -STOP <PID>
```

Result:

- process execution stopped
- process remained in memory

---

### 8. Tested SIGCONT

Command:

```bash
kill -CONT <PID>
```

Result:

- process resumed execution
- infinite loop continued

---

### 9. Tested SIGKILL

Command:

```bash
kill -KILL <PID>
```

Result:

- process terminated immediately
- cleanup code was not executed

Attempting to register a `trap` for `SIGKILL` resulted in an error because this signal cannot be caught or ignored.

---

## Observations

- `kill` sends signals rather than always terminating a process.
- Different signals trigger different actions.
- `trap` allows Bash scripts to execute custom code when signals are received.
- `SIGTERM` enables graceful shutdown.
- `SIGUSR1` and `SIGUSR2` are intended for application-defined behavior.
- `SIGSTOP` pauses a process, while `SIGCONT` resumes it.
- `SIGKILL` immediately terminates a process and bypasses all cleanup logic.

---

## Conclusion

This experiment demonstrated how Linux signals are used for process communication and lifecycle management.

Understanding signals is essential for Linux administration, Bash scripting, DevOps, and Site Reliability Engineering because production applications rely on graceful shutdown and proper signal handling.
