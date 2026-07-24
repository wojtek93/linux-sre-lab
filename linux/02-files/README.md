# LIN-02 - Find Large Files

## Objective

Learn how to use the `find` command to locate files based on different criteria such as file type, size, and modification time.

---

## Task

Find all regular files larger than **100 MB** that were modified within the last **7 days**.

---

## Solution

```bash
find / -type f -size +100M -mtime -7 2>/dev/null
```

---

## Command Breakdown

| Option | Description |
|---------|-------------|
| `find /` | Start searching from the root directory. |
| `-type f` | Search only for regular files. |
| `-size +100M` | Find files larger than 100 MB. |
| `-mtime -7` | Find files modified within the last 7 days. |
| `2>/dev/null` | Suppress permission denied and other error messages. |

---

## Example Output

```text
/var/log/big-app.log
/home/user/Downloads/ubuntu.iso
/opt/backups/database_backup.sql
```

---

## Practical Use Cases

- Identify large log files consuming disk space.
- Locate recent backup files.
- Investigate disk usage issues.
- Find unexpectedly large files after software installation.
- Troubleshoot systems running out of storage.

---

## Related Commands

```bash
# Find files larger than 1 GB
find / -type f -size +1G

# Find files modified today
find / -type f -mtime 0

# Find files older than 30 days
find / -type f -mtime +30

# Find files by name
find / -type f -name "*.log"

# Find empty files
find / -type f -empty
```

---

## Interview Notes

### What is the difference between `-mtime -7` and `-mtime +7`?

- `-mtime -7` → modified within the last 7 days.
- `-mtime +7` → modified more than 7 days ago.

---

### Why redirect `2>/dev/null`?

Searching from `/` often produces permission errors. Redirecting standard error to `/dev/null` hides these messages and displays only the matching files.

---

### Why use `-type f`?

Without `-type f`, `find` may also return directories, symbolic links, sockets, and other filesystem objects.

---

## Key Takeaways

- `find` is one of the most important Linux administration tools.
- Multiple search conditions can be combined.
- `find` is commonly used in Linux, DevOps and SRE troubleshooting.
- Knowing `find` well is essential for technical interviews.