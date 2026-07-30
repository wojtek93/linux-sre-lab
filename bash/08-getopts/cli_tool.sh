#!/usr/bin/env bash

set -euo pipefail

# Lab 08 - getopts

input_file=""
output_file=""
verbose=false

while getopts "hf:o:v" option; do
    case "$option" in
        h)
            echo "Usage:"
            echo "./cli_tool.sh -f <file> [-o output] [-v] [-h]"
            exit 0
            ;;

        f)
            input_file="$OPTARG"
            ;;

        o)
            output_file="$OPTARG"
            ;;

        v)
            verbose=true
            ;;

        \?)
            echo "Error: Invalid option."
            echo "Use -h for help."
            exit 1
            ;;
    esac
done

# Validate input file
if [[ -z "$input_file" ]]; then
    echo "Error: Input file is required."
    echo
    echo "Usage:"
    echo "./cli_tool.sh -f <file> [-o output] [-v] [-h]"
    exit 1
fi

if [[ ! -f "$input_file" ]]; then
    echo "Error: File '$input_file' does not exist."
    exit 1
fi

# Default output file
if [[ -z "$output_file" ]]; then
    output_file="output/result.txt"
fi

# Create output directory if needed
mkdir -p "$(dirname "$output_file")"

if [[ $verbose == true ]]; then
    echo "Verbose mode enabled"
    echo "Input file : $input_file"
    echo "Output file: $output_file"
fi

cp "$input_file" "$output_file"

echo
echo "File copied successfully."
echo "Saved to: $output_file"
