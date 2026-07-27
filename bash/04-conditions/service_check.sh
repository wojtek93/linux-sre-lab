#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename "$0") <service_name>"
    exit 2
fi

SERVICE_NAME="$1"

if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "OK: Service '$SERVICE_NAME' is active."
    exit 0
elif systemctl is-enabled --quiet "$SERVICE_NAME"; then
    echo "WARNING: Service '$SERVICE_NAME' is enabled but not active."
    exit 1
else
    echo "CRITICAL: Service '$SERVICE_NAME' is inactive or does not exist."
    exit 2
fi
