#!/usr/bin/env bash

set -euo pipefail

# BAS-13 - Here Documents

output_file="output/app.conf"

app_name="LinuxSRE"
version="1.0"
environment="development"
port="8080"
log_level="INFO"

cat > "$output_file" <<EOF
APP_NAME=$app_name
VERSION=$version
ENVIRONMENT=$environment
PORT=$port
LOG_LEVEL=$log_level
EOF

echo "Configuration generated: $output_file"
