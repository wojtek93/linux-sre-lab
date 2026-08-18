#!/bin/bash

echo "=== LISTENING TCP/UDP SOCKETS ==="
sudo ss -tulnp

echo
echo "=== ESTABLISHED TCP CONNECTIONS ==="
ss -tn state established

echo
echo "=== SUMMARY ==="

listening_count=$(ss -tuln | tail -n +2 | wc -l)
established_count=$(ss -tn state established | tail -n +2 | wc -l)

echo "Listening sockets: $listening_count"
echo "Established connections: $established_count"
