#!/bin/bash

set -e

cd "$(dirname "$0")/.."

if mount | grep -q "$(pwd)/mnt"; then
    sudo umount mnt
fi

rm -f disk.img

echo "Cleanup completed."
