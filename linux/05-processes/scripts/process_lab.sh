#!/usr/bin/env bash

set -euo pipefail

process="sleep"
duration=300
last_pid=""

cleanup() {
    if [[ -n "$last_pid" ]] && kill -0 "$last_pid" 2>/dev/null; then
        echo
        echo "Cleaning up process $last_pid..."
        kill -TERM "$last_pid" 2>/dev/null || true
        wait "$last_pid" 2>/dev/null || true
    fi
}

trap cleanup EXIT

echo "====================================="
echo " Linux Process Management Lab"
echo "====================================="
echo

echo "Starting test process: $process $duration"

"$process" "$duration" &
last_pid=$!

echo "Process started successfully."
echo "PID: $last_pid"

parent_pid=$(ps -p "$last_pid" -o ppid= | xargs)

echo "PPID: $parent_pid"
echo

echo "====================================="
echo " Child Process"
echo "====================================="

ps -fp "$last_pid"

echo
echo "====================================="
echo " Parent Process"
echo "====================================="

ps -fp "$parent_pid"

echo
echo "====================================="
echo " Process Status"
echo "====================================="

if kill -0 "$last_pid" 2>/dev/null; then
    echo "Process $last_pid is running."
else
    echo "Process $last_pid is not running."
    exit 1
fi

echo
echo "Sending SIGTERM to process $last_pid..."

kill -TERM "$last_pid"

sleep 2

if kill -0 "$last_pid" 2>/dev/null; then
    echo "Process did not terminate after SIGTERM."
    echo "Sending SIGKILL to process $last_pid..."

    kill -KILL "$last_pid"
else
    echo "Process terminated gracefully after SIGTERM."
fi

# Collect the terminated background process.
# A process terminated by a signal returns a non-zero exit code,
# so the failure is intentionally ignored.
wait "$last_pid" 2>/dev/null || true

# Prevent the EXIT trap from trying to clean up an already finished process.
last_pid=""

echo
echo "====================================="
echo " Process lab completed successfully"
echo "====================================="
