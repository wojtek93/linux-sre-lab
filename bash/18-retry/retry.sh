#!/usr/bin/env bash

set -euo pipefail

MAX_RETRIES=5
RETRY_DELAY=2

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <command>"
    exit 1
fi

COMMAND="$*"

for (( i=1; i<=MAX_RETRIES; i++ )); do
    echo "Attempt $i/$MAX_RETRIES"

    if eval "$COMMAND"; then
        echo "Command succeeded."
        exit 0
    fi

    echo "Command failed."

    if [[ $i -lt $MAX_RETRIES ]]; then
        echo "Retrying in ${RETRY_DELAY} seconds..."
        sleep "$RETRY_DELAY"
    fi
done

echo "Retry limit exceeded."
exit 1
