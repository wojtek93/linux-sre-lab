#!/usr/bin/env bash

set -euo pipefail

echo "---------------------------------"
echo "Signal Lab Started"
echo "---------------------------------"

echo "PID: $$"
echo

trap 'echo "SIGUSR1 received."' SIGUSR1

trap 'echo "USR2 received."' SIGUSR2

trap '
echo
echo "SIGINT received (Ctrl+C)"
' SIGINT

trap '
echo
echo "SIGTERM received."
echo "Cleaning resources..."
echo "Exiting..."
exit 0
' SIGTERM

trap 'echo "SIGKILL received."' SIGKILL

trap 'echo "SIGSTOP received."' SIGSTOP

while :; do
	echo "Application is running..."
	sleep 2
done


