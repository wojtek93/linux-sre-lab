#!/usr/bin/env bash

set -euo pipefail

# BAS-16 - JSON processing with jq

input_file="input/services.json"
output_dir="output"
output_file="$output_dir/running_services.txt"

if [[ ! -f "$input_file" ]]; then
    echo "Error: input file does not exist: $input_file"
    exit 1
fi

mkdir -p "$output_dir"

if ! jq empty "$input_file" > /dev/null 2>&1; then
    echo "Error: invalid JSON format: $input_file"
    exit 1
fi

echo "All services:"
jq -r '.services[].name' "$input_file"

echo
echo "Running services:"
jq -r '.services[] | select(.status == "running") | .name' "$input_file"

jq -r '
    .services[]
    | select(.status == "running")
    | "\(.name):\(.port)"
' "$input_file" > "$output_file"

total_services=$(jq '.services | length' "$input_file")

running_services=$(jq '
    [.services[] | select(.status == "running")]
    | length
' "$input_file")

echo
echo "Total services: $total_services"
echo "Running services: $running_services"

echo
echo "Report saved to: $output_file"
