#!/usr/bin/env bash

RANDOM_NUMBER=$(( RANDOM % 2 ))

if [[ $RANDOM_NUMBER -eq 0 ]]; then
    echo "Success"
    exit 0
else
    echo "Failure"
    exit 1
fi
