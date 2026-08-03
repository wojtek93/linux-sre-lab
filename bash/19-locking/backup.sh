#!/usr/bin/env bash

set -euo pipefail

# BAS-19 - Locking

lock_file="backup.lock"
output_dir="output"

if [[ -f "$lock_file" ]]; then
    echo "Another instance is already running."
    exit 1
fi

touch "$lock_file"

trap 'rm -f "$lock_file"' EXIT

mkdir -p "$output_dir"

echo "Backup started..."

sleep 10

timestamp=$(date "+%F_%H-%M-%S")
backup_file="$output_dir/backup_$timestamp.txt"

echo "Backup completed at $(date "+%F %T")" > "$backup_file"

echo "Backup created: $backup_file"
echo "Backup completed successfully."

exit 0
