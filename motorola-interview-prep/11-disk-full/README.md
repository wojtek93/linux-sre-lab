# MOT-11 — Disk Full / Filesystem Issue

## Goal

Diagnose a full filesystem, identify what consumes disk space and safely determine the cause.

## Check filesystem usage

```bash
df -h
```

Important fields:

```text
Size   total filesystem size
Used   used space
Avail  available space
Use%   percentage used
Mounted on  mount point
```

Example:

```text
30G  25G  4.1G  86%  /
```

## Find large directories

```bash
sudo du -xhd1 / 2>/dev/null | sort -h
```

Options:

```text
-x   stay on the same filesystem
-h   human-readable sizes
-d1  show one directory level
```

Then investigate the largest directory:

```bash
sudo du -xhd1 /var 2>/dev/null | sort -h
```

## Find large files

```bash
sudo find /var -xdev -type f -size +100M -exec ls -lh {} \;
```

Important options:

```text
-xdev        stay on the same filesystem
-type f      regular files only
-size +100M  files larger than 100 MB
-exec        execute a command for every result
{}           found file
\;           end of -exec command
```

Do not delete a file only because it is large. First determine what application or service owns it.

## Deleted but still open files

Sometimes:

```text
df → filesystem is full
du → cannot find all the used space
```

Check:

```bash
sudo lsof +L1
```

`lsof` means:

```text
List Open Files
```

A process can keep a deleted file open. The file is no longer visible normally, but its disk space is not released until the process closes it.

Look for entries marked:

```text
(deleted)
```

## Troubleshooting flow

```text
Disk full
   ↓
df -h
   ↓
Identify filesystem
   ↓
du
   ↓
Identify large directory
   ↓
find
   ↓
Identify large files
   ↓
Determine what owns the data
   ↓
Safe cleanup / mitigation
   ↓
df -h
   ↓
Verify recovery
```

Special case:

```text
df full but du does not explain usage
                ↓
            lsof +L1
                ↓
      look for large (deleted) files
```

## Interview answer

> I would first use df -h to identify the affected filesystem. Then I would use du to locate the directories consuming the most space and find to identify large files. Before deleting anything, I would determine what application or service owns the data. If df showed significantly more usage than du, I would also check lsof +L1 for deleted files that are still held open by a process. After mitigation, I would verify the filesystem usage again with df -h.
