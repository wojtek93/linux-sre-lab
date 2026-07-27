## ⭐ Most Important Commands

### Create compressed archive

```bash
tar -czvf backup.tar.gz backup-demo
```

Creates a compressed backup archive using gzip.

---

### Extract archive

```bash
tar -xzvf backup.tar.gz
```

Extracts a compressed archive.

---

### Generate SHA256 checksum

```bash
sha256sum backup.tar.gz
```

Creates a SHA256 hash used to verify file integrity.

Typical use cases:

- backup verification
- ISO image verification
- artifact validation
- software downloads

---

### Verify checksum

```bash
sha256sum -c backup.sha256
```

Confirms that the file has not been modified or corrupted.

Expected output:

```text
backup.tar.gz: OK
```

---

### Synchronize directories

```bash
rsync -av source/ destination/
```

Synchronizes only changed files while preserving:

- permissions
- ownership
- timestamps
- directory structure

Common use cases:

- incremental backups
- server migrations
- deployment synchronization
- remote backups

---

### Why rsync instead of cp?

`cp`

- copies everything every time

`rsync`

- copies only changed files
- saves bandwidth
- much faster for large datasets
- standard tool used by Linux administrators and SREs
