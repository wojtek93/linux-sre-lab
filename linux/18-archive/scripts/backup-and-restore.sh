#!/bin/bash

set -e

SOURCE_DIR="../backup-demo"
BACKUP_DIR="../backups"
RESTORE_DIR="../restore-test"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE="$BACKUP_DIR/backup-$TIMESTAMP.tar.gz"
CHECKSUM="$ARCHIVE.sha256"

mkdir -p "$BACKUP_DIR"
mkdir -p "$RESTORE_DIR"

echo "Creating backup..."
tar -czf "$ARCHIVE" "$SOURCE_DIR"

echo "Creating SHA256 checksum..."
sha256sum "$ARCHIVE" > "$CHECKSUM"

echo "Verifying backup integrity..."
sha256sum -c "$CHECKSUM"

echo "Restoring backup for verification..."
tar -xzf "$ARCHIVE" -C "$RESTORE_DIR"

echo
echo "Backup completed successfully."
echo "Archive: $ARCHIVE"
echo "Checksum: $CHECKSUM"
echo "Restore directory: $RESTORE_DIR"
