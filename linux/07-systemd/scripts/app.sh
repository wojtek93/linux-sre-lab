#!/usr/bin/env bash

PID=$$

echo "Starting SRE demo service..."
echo "PID: $PID"
echo

while :; do
   	date
   	echo "SRE demo service is running..."
   	sleep 5
done
