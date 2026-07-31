#!/usr/bin/env bash

set -e

echo "Before"

if ls /this_directory_does_not_exist; then
    echo "Directory exists."
fi

echo "After"
