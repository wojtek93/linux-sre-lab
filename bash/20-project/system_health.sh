#!/usr/bin/env bash

set -euo pipefail

source logging_library.sh

output_dir="output"
report_file="$output_dir/system_report.txt"

mkdir -p "$output_dir"

timestamp=$(date "+%F %T")
host_name=$(hostname)

uptime_info=$(uptime)
cpu_load=$(uptime | awk -F'load average: ' '{print $2}')

memory_used=$(free -h | awk '/^Mem:/ {print $3}')
memory_free=$(free -h | awk '/^Mem:/ {print $4}')

disk_usage=$(df -h | awk '$6 == "/" {print $5}')

ip_address=$(
    ip -4 addr show scope global \
    | awk '/inet / {print $2; exit}'
)

running_services=$(
    jq -r '.services[]
        | select(.status == "running")
        | .name' input/services.json
)

cat << EOF | tee "$report_file"

==============================
      SYSTEM HEALTH REPORT
==============================

Timestamp:        $timestamp
Hostname:         $host_name

Uptime:
$uptime_info

CPU Load:
$cpu_load

Memory Used:
$memory_used

Memory Free:
$memory_free

Disk Usage:
$disk_usage

IP Address:
$ip_address

Running Services:
$running_services

==============================

EOF

log_info "System health report generated successfully." "logs/app.log"

exit 0
