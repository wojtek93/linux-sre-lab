#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
	echo "Usage $0 <name_of_service> <port>"
	exit 2
fi

SERVICE=$1
PORT=$2

# 1. Check if platform-api service is active

if systemctl is-active --quiet  "$SERVICE" ; then
	echo "$SERVICE is active "
else
	echo "$SERVICE is not active"
	exit 1
fi

# 2. Check if port <PORT> is listening

if ss -tlnp | grep -q ":$PORT"; then
	echo "Port $PORT is listening"
else
	echo "Port $PORT is not listening"
	exit 1
fi

# 3. Check application health endpoint

if curl -fsS "http://localhost:${PORT}/healt"h; then
    echo "Health check passed"
else
    echo "Health check failed"
    exit 1
fi


# 4. Return success if all checks pass

echo  "Success"
exit 0
