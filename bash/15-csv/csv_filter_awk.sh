#!/usr/bin/env bash

set -euo pipefail

# BAS-15 - CSV processing with awk

input_file="input/users.csv"
output_dir="output"
output_file="$output_dir/it_users_awk.csv"

if [[ ! -f "$input_file" ]]; then
    echo "Error: input file does not exist: $input_file"
    exit 1
fi

mkdir -p "$output_dir"

awk -F',' -v OFS=',' '
BEGIN {
    print "name", "city", "id"
}

NR > 1 && $3 == "IT" {
    print $2, $4, $1
}' "$input_file" > "$output_file"

echo "Created: $output_file"
