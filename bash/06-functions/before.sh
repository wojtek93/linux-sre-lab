#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi

log_file="$1"

if [[ ! -f "$log_file" ]]; then
    echo "File '$log_file' does not exist."
    exit 1
fi

info=$(grep -c "INFO" "$log_file")
warning=$(grep -c "WARNING" "$log_file")
error=$(grep -c "ERROR" "$log_file")

echo "=========================="
echo "File: $(basename "$log_file")"
echo "=========================="
echo
echo "INFO:    $info"
echo "WARNING: $warning"
echo "ERROR:   $error"
echo
echo "Total entries: $((info + warning + error))"
