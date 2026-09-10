# MOT-15 — Troubleshooting with `strace`

## Goal

Use `strace` to diagnose failing Linux commands and understand system call errors.

---

## What is `strace`?

`strace` shows the system calls a process makes to the Linux kernel.

It can help identify:

- missing files,
- permission problems,
- failed file operations,
- processes waiting on system calls,
- resources a process is trying to access.

---

## Basic example

```bash
strace cat /tmp/does-not-exist
```

A failed syscall may look like:

```text
openat(..., "/tmp/does-not-exist", ...) = -1 ENOENT
```

Meaning:

```text
openat → process tried to open a file
-1     → syscall failed
ENOENT → No such file or directory
```

---

## Filtering errors

`strace` writes its output to stderr.

To pass it through `grep`:

```bash
strace command 2>&1 | grep '= -1'
```

```text
2>&1 = redirect stderr to stdout
```

Examples:

```bash
strace command 2>&1 | grep ENOENT
strace command 2>&1 | grep EACCES
```

---

## ENOENT

```text
ENOENT = No such file or directory
```

Example:

```bash
strace cat /tmp/does-not-exist 2>&1 | grep ENOENT
```

---

## EACCES

```text
EACCES = Permission denied
```

Example lab:

```bash
mkdir -p ~/strace-lab
echo secret > ~/strace-lab/secret.txt
chmod 000 ~/strace-lab/secret.txt

strace cat ~/strace-lab/secret.txt 2>&1 | grep EACCES
```

Example result:

```text
openat(..., "/home/wojtek/strace-lab/secret.txt", O_RDONLY) = -1 EACCES
```

Fix with the minimum required permissions:

```bash
chmod 600 ~/strace-lab/secret.txt
```

Avoid blindly using:

```bash
chmod 777
```

---

## Parent directory permission issue

A file may have correct permissions while access still fails because a parent directory lacks execute permission.

Diagnose with:

```bash
namei -l /full/path/to/file
```

Workflow:

```text
strace
→ EACCES
→ identify failing path
→ namei -l
→ check file and parent directory permissions
→ fix with least privilege
→ verify
```

For directories:

```text
r → list directory entries
w → create/delete entries
x → traverse the directory
```

---

## Useful `strace` options

### Filter system calls

```bash
strace -e openat,access,statx command
```

or file-related calls:

```bash
strace -e trace=%file command
```

### Follow child processes

```bash
strace -f command
```

`-f` follows processes created by the traced process.

### Attach to a running process

```bash
sudo strace -p PID
```

Useful when a process is already running but behaving unexpectedly.

### Save trace to a file

```bash
strace -o /tmp/trace.log command
```

Then analyze it:

```bash
grep '= -1' /tmp/trace.log
```

---

## Troubleshooting workflow

```text
command/process fails
→ check normal error/logs
→ strace
→ identify relevant syscall/path
→ look for errno such as ENOENT or EACCES
→ investigate root cause
→ fix
→ verify
```

Do not assume every `ENOENT` or failed syscall in `strace` is the root cause.

A program can legitimately try multiple optional files or paths.

Always interpret:

```text
syscall + path/resource + errno + application symptom
```

---

## Interview answer

> I use strace when a command or process fails and normal logs are not enough. It lets me see the system calls made by the process and errors returned by the kernel, for example ENOENT for a missing file or EACCES for a permission problem. I can also attach it to a running process with `-p`.
