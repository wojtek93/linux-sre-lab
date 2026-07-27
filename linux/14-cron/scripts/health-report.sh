#!/bin/bash

echo "===== Health Report ====="
date

echo
echo "Hostname:"
hostname

echo
echo "Uptime:"
uptime

echo
echo "Disk Usage:"
df -h /

echo
echo "Memory Usage:"
free -h

echo
echo "Load Average:"
cat /proc/loadavg

echo
echo "========================="
