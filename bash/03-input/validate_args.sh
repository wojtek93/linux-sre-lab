#!/usr/bin/env bash

if [[ $# -ne 2 ]]; then
    echo "Usage: $(basename "$0") <source_file> <destination>"
    exit 1
fi

SOURCE_FILE="$1"
DESTINATION="$2"

echo "Arguments validated successfully."
echo "Source file: $SOURCE_FILE"
echo "Destination: $DESTINATION"
