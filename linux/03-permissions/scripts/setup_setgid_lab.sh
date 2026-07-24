#!/usr/bin/env bash

set -euo pipefail

GROUP_NAME="developers"
TEST_USER="alice"
SHARED_DIR="/shared"

echo "Creating group: $GROUP_NAME"
if ! getent group "$GROUP_NAME" >/dev/null; then
    sudo groupadd "$GROUP_NAME"
else
    echo "Group already exists."
fi

echo "Creating user: $TEST_USER"
if ! id "$TEST_USER" >/dev/null 2>&1; then
    sudo useradd -m "$TEST_USER"
else
    echo "User already exists."
fi

echo "Adding $TEST_USER to $GROUP_NAME"
sudo usermod -aG "$GROUP_NAME" "$TEST_USER"

echo "Creating shared directory: $SHARED_DIR"
sudo mkdir -p "$SHARED_DIR"

echo "Setting group ownership"
sudo chgrp "$GROUP_NAME" "$SHARED_DIR"

echo "Setting permissions and setgid bit"
sudo chmod 2775 "$SHARED_DIR"

echo
echo "Lab configured successfully."
echo
echo "Directory details:"
ls -ld "$SHARED_DIR"

echo
echo "User details:"
id "$TEST_USER"