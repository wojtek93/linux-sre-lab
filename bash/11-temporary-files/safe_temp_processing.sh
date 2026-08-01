#!/usr/bin/env bash

set -euo pipefail

input_file="input/users.csv"

temp_file=$(mktemp)

trap 'rm -f "$temp_file"' EXIT

awk -F',' '$2 == "active"' "$input_file" > "$temp_file"

sort "$temp_file" -o "$temp_file"

echo "Active users:"
cat "$temp_file"

echo
echo "Total active users: $(wc -l < "$temp_file")"

