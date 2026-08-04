#!/usr/bin/env bash

set -euo pipefail

source config/app.conf

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    local level="$1"
    local message="$2"

    echo "$(date "+%F %T") [$level] $message" | tee -a "$LOG_FILE"
}

log_info() {
    log INFO "$1"
}

log_warn() {
    log WARN "$1"
}

log_error() {
    log ERROR "$1"
}



