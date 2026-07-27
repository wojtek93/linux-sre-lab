# Lab 19 – strace

## Objective

Learn how to troubleshoot Linux applications using **strace** by observing system calls made between a userspace process and the Linux kernel.

This lab focuses on understanding how programs open files, read data, and interact with the operating system.

---

## Environment

- Ubuntu Linux
- OpenSSH
- strace

---

# Project Structure

```
19-strace/
├── README.md
└── scripts/
```

---

# Exercises

## 1. Install strace

Update package index and install the tool.

```bash
sudo apt update
sudo apt install strace
```

Verify installation.

```bash
which strace
```

---

## 2. Trace a command

Trace every system call executed by `ls`.

```bash
strace ls
```

Observe how many kernel calls are required to execute a simple command.

---

## 3. Trace file access

Run:

```bash
strace cat /etc/hosts
```

The output is very verbose because every syscall is displayed.

---

## 4. Filter the output

Redirect stderr to stdout and search only for operations involving `/etc/hosts`.

```bash
strace cat /etc/hosts 2>&1 | grep "/etc/hosts"
```

Example output:

```text
execve("/usr/bin/cat", ["cat", "/etc/hosts"], ...)
statx(AT_FDCWD, "/etc/hosts", ...)
openat(AT_FDCWD, "/etc/hosts", O_RDONLY|O_CLOEXEC) = 3
```

---

## 5. Trace only file opening

Reduce noise by tracing only `openat()`.

```bash
strace -e openat cat /etc/hosts
```

---

## 6. Trace failed commands

Observe how Linux reports missing files.

```bash
strace cat missing.txt
```

Notice:

```text
ENOENT
```

which means:

```
No such file or directory
```

---

## 7. Trace command execution

Observe how Linux starts a program.

```bash
strace echo Hello
```

Notice the first syscall:

```text
execve(...)
```

---

# Important Concepts

## execve()

Starts a new process.

Example:

```text
execve("/usr/bin/cat", ...)
```

The kernel loads the executable into memory.

---

## stat()

Checks file metadata before opening it.

Example:

```text
stat("/etc/hosts")
```

Linux verifies that the file exists and checks its permissions.

---

## openat()

Opens a file.

Example:

```text
openat(..., "/etc/hosts", O_RDONLY) = 3
```

Meaning:

- file opened successfully
- read-only mode
- file descriptor = 3

---

## read()

Reads bytes from the opened file.

Example:

```text
read(3, ...)
```

---

## close()

Closes the file descriptor.

```text
close(3)
```

---

## exit()

Terminates the process.

---

# Typical Program Flow

Almost every Linux application performs something similar to:

```
execve()
↓
stat()
↓
open()
↓
read()
↓
write()
↓
close()
↓
exit()
```

---

# Why strace is Useful

`strace` shows exactly what an application is asking the Linux kernel to do.

Examples:

Missing file:

```text
open("/etc/config.yml") = -1 ENOENT
```

Permission problem:

```text
open("/var/log/app.log") = -1 EACCES
```

Missing directory:

```text
chdir("/opt/app") = -1 ENOENT
```

Without reading application logs, `strace` often immediately reveals the real cause of the issue.

---

# Key Commands

```bash
strace ls

strace cat /etc/hosts

strace cat /etc/hosts 2>&1 | grep "/etc/hosts"

strace -e openat cat /etc/hosts

strace cat missing.txt
```

---

# Summary

During this lab I learned how to:

- install `strace`
- trace Linux system calls
- observe how applications interact with the kernel
- understand `execve()`, `stat()`, `openat()`, `read()`, `close()`
- filter `strace` output using `grep`
- diagnose missing files (`ENOENT`)
- diagnose permission issues (`EACCES`)
- use `strace` as a troubleshooting tool for SRE and DevOps work

---

# Interview Notes ⭐

### What is strace?

`strace` traces system calls made by a process.

It shows every interaction between an application and the Linux kernel.

---

### Common troubleshooting workflow

Application fails

↓

Run:

```bash
strace ./application
```

↓

Look for:

- `ENOENT` → missing file
- `EACCES` → permission denied
- `open()` failures
- `connect()` failures
- unexpected missing libraries

---

### Why is strace valuable for SRE?

Instead of guessing why an application fails, `strace` shows exactly what the process attempted to do and which system call failed, making root cause analysis significantly faster.
