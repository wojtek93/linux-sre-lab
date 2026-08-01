#!/usr/bin/env bash

set -euo pipefail

# BAS-15 - CSV processing with while read

input_file="input/users.csv"
output_dir="output"
output_file="$output_dir/it_users.csv"

if [[ ! -f "$input_file" ]]; then
    echo "Error: input file does not exist: $input_file"
    exit 1
fi

mkdir -p "$output_dir"

echo "name,city,id" > "$output_file"

while IFS=',' read -r id name department city; do
    if [[ "$id" == "id" ]]; then
        continue
    fi

    if [[ "$department" == "IT" ]]; then
        echo "$name,$city,$id" >> "$output_file"
    fi
done < "$input_file"

echo "Created: $output_file"
