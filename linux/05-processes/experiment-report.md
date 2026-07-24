# Experiment Report

## Objective

The objective of this lab was to understand Linux process management by creating a Bash script that starts a background process, inspects its properties, verifies its state, and terminates it safely using Unix signals.

---

## Environment

- Operating System: Ubuntu Server
- Shell: Bash
- Test Process: `sleep 300`

---

## Procedure

### 1. Started a Background Process

The script launches a `sleep` process in the background and stores its Process ID (PID) using the special Bash variable `$!`.

This PID is used throughout the script to monitor and manage the process.

---

### 2. Retrieved Process Information

The script retrieves:

- Process ID (PID)
- Parent Process ID (PPID)

The PPID is obtained using the `ps` command.

Both the child process and its parent process are displayed for inspection.

---

### 3. Verified Process Status

The script checks whether the process is still running using:

```bash
kill -0 <PID>
```

Unlike normal `kill`, signal `0` does not terminate the process. It only verifies whether the process exists and whether the current user has permission to signal it.

---

### 4. Graceful Process Termination

The script sends the `SIGTERM` signal:

```bash
kill -TERM <PID>
```

This allows the process to terminate gracefully and release any resources before exiting.

The script waits briefly before checking whether the process has terminated.

---

### 5. Forced Process Termination

If the process is still running after receiving `SIGTERM`, the script sends:

```bash
kill -KILL <PID>
```

`SIGKILL` immediately terminates the process and cannot be intercepted or ignored.

---

### 6. Automatic Cleanup

A Bash `trap` is used to ensure that the background process is terminated if the script exits unexpectedly.

This prevents orphaned processes from remaining in the system.

---

## Results

The script successfully:

- started a background process
- retrieved the PID and PPID
- displayed process hierarchy
- verified process existence
- terminated the process using `SIGTERM`
- fell back to `SIGKILL` when necessary
- cleaned up remaining resources using `trap`

---

## Challenges

During implementation I encountered two issues:

- The output of `ps -o ppid=` contained leading spaces, which caused `ps -fp` to fail. This was resolved by trimming the output with `xargs`.
- The cleanup function initially executed after the process had already terminated. This was fixed by clearing the stored PID after `wait`, preventing unnecessary cleanup attempts.

---

## Lessons Learned

This lab improved my understanding of:

- Linux process hierarchy (PID and PPID)
- Background jobs in Bash
- Process inspection using `ps`
- Signal handling (`SIGTERM` vs `SIGKILL`)
- Process existence checks using `kill -0`
- Safe Bash scripting with `set -euo pipefail`
- Automatic resource cleanup using `trap`
- Writing more robust and production-style Bash scripts

---

## Conclusion

This lab provided practical experience with Linux process management and signal handling. The resulting Bash script demonstrates common administrative techniques such as monitoring background processes, performing graceful shutdowns, implementing fallback termination, and ensuring automatic cleanup. These concepts are fundamental for Linux administration, automation, and Site Reliability Engineering (SRE).
