#!/usr/bin/env bash

set -euo pipefail

# Lab 12 - Pipelines

input_file="input/app.log"

if [[ ! -e "$input_file" ]]; then
    echo "Error: The file '$input_file' does not exist."
    exit 2
fi

echo "ERROR summary:"
grep " ERROR " "$input_file" |
    cut -d' ' -f4- |
    sort |
    uniq -c |
    sort -nr

echo
echo "Log level summary:"
awk '{print $3}' "$input_file" |
    sort |
    uniq -c |
    sort -nr

echo
echo "Total log entries:"
wc -l < "$input_file"

echo
echo "Total errors:"
grep -c " ERROR " "$input_file"

echo
echo "Unique ERROR messages:"
grep " ERROR " "$input_file" |
    cut -d' ' -f4- |
    sort |
    uniq
