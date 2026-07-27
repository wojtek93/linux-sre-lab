# Lab 18 – Archive & Backup

## Objective

Learn how to create archives, compress backups, verify file integrity using SHA256 checksums, synchronize directories with rsync, and automate the backup process using a Bash script.

---

# Environment

- Ubuntu Linux
- tar
- gzip
- sha256sum
- rsync
- Bash

---

# Project Structure

```
18-archive/
├── README.md
├── backup-demo/
│   ├── notes.txt
│   ├── skills.txt
│   └── k8s.txt
├── backups/
├── restore-test/
└── scripts/
    └── backup-and-restore.sh
```

---

# Exercises

## 1. Create sample files

```bash
mkdir backup-demo
cd backup-demo

echo "Linux" > notes.txt
echo "Kubernetes" > k8s.txt
echo "Bash" > skills.txt
```

---

## 2. Create a TAR archive

```bash
tar -cvf backup.tar backup-demo
```

List archive contents:

```bash
tar -tvf backup.tar
```

---

## 3. Extract archive

Remove original directory:

```bash
rm -rf backup-demo
```

Restore it:

```bash
tar -xvf backup.tar
```

---

## 4. Compress archive

Compress using gzip:

```bash
gzip backup.tar
```

Result:

```
backup.tar.gz
```

Restore:

```bash
gunzip backup.tar.gz
```

---

## 5. Create compressed archive directly

```bash
tar -czvf backup.tar.gz backup-demo
```

Extract:

```bash
tar -xzvf backup.tar.gz
```

---

# ⭐ Verify Backup Integrity (SHA256)

Generate checksum:

```bash
sha256sum backup.tar.gz
```

Save checksum:

```bash
sha256sum backup.tar.gz > backup.sha256
```

View checksum:

```bash
cat backup.sha256
```

Verify backup integrity:

```bash
sha256sum -c backup.sha256
```

Expected result:

```
backup.tar.gz: OK
```

### Why is SHA256 important?

Before restoring a backup, SREs often verify that the archive has not been corrupted or modified.

This guarantees backup integrity.

---

# ⭐ Synchronize Directories (rsync)

Create destination:

```bash
mkdir backup-copy
```

Synchronize:

```bash
rsync -av backup-demo/ backup-copy/
```

Modify source:

```bash
echo "Docker" > backup-demo/docker.txt
```

Run synchronization again:

```bash
rsync -av backup-demo/ backup-copy/
```

Only the new file is copied.

### Why use rsync?

Unlike `cp`, `rsync` copies only changed files.

This makes incremental backups much faster and more efficient.

---

# Backup Automation Script

Location:

```
scripts/backup-and-restore.sh
```

Run:

```bash
cd scripts
./backup-and-restore.sh
```

The script performs the following steps:

1. Creates the backup directory.
2. Creates a compressed archive.
3. Generates a SHA256 checksum.
4. Verifies archive integrity.
5. Restores the archive to a test directory.
6. Prints a completion summary.

---

# Important Commands

Create archive

```bash
tar -cvf backup.tar backup-demo
```

List archive

```bash
tar -tvf backup.tar
```

Extract archive

```bash
tar -xvf backup.tar
```

Compressed archive

```bash
tar -czvf backup.tar.gz backup-demo
```

Extract compressed archive

```bash
tar -xzvf backup.tar.gz
```

Generate checksum

```bash
sha256sum backup.tar.gz
```

Save checksum

```bash
sha256sum backup.tar.gz > backup.sha256
```

Verify checksum

```bash
sha256sum -c backup.sha256
```

Synchronize directories

```bash
rsync -av source/ destination/
```

---

# Summary

During this lab I learned how to:

- create TAR archives
- compress backups using gzip
- extract archives
- create compressed archives directly
- generate SHA256 checksums
- verify backup integrity before restore
- synchronize directories with rsync
- understand incremental synchronization
- automate backups using a Bash script

---

# Interview Notes ⭐

## tar

Creates and extracts archives.

Common options:

- `-c` create
- `-x` extract
- `-t` list
- `-v` verbose
- `-f` filename
- `-z` gzip compression

---

## sha256sum ⭐

Used to verify backup integrity.

Typical workflow:

```bash
sha256sum backup.tar.gz > backup.sha256
sha256sum -c backup.sha256
```

If the archive was modified or corrupted, verification fails immediately.

---

## rsync ⭐

One of the most common Linux backup tools.

Example:

```bash
rsync -av source/ destination/
```

Advantages:

- copies only changed files
- preserves permissions and timestamps
- ideal for incremental backups
- significantly faster than copying everything again

---

## Why SREs use these tools

A typical production backup workflow:

```
Application Data
        │
        ▼
tar
        │
        ▼
gzip
        │
        ▼
sha256sum
        │
        ▼
Store Backup
        │
        ▼
Restore Test
        │
        ▼
Verify Integrity
```

Using `sha256sum` ensures backups are valid, while `rsync` enables efficient incremental synchronization.
