#!/usr/bin/env bash

# Lab 09 - Exit codes

echo "Starting workflow..."

./scripts/check_service.sh

exit_code=$?

if [[ $exit_code -eq 0 ]]; then
    echo "Service check passed."
else
    echo "Service check failed."
    exit 1
fi

./scripts/check_disk.sh

exit_code=$?

if [[ $exit_code -eq 0 ]]; then
    echo "Disk check passed."
else
    echo "Disk check failed."
    exit 1
fi

./scripts/deploy_app.sh

exit_code=$?

if [[ $exit_code -eq 0 ]]; then
    echo "Deployment completed successfully."
else
    echo "Deployment failed."
    exit 1
fi

echo "Workflow completed successfully."

exit 0
