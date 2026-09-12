#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <treshold value> "
	exit 2
fi

TRESHOLD=$1

USAGE=$(df -h ./ | awk 'NR==2 {gsub("%","");print $5}')

echo "Disk usage: $USAGE"
echo "Threshold: $TRESHOLD%"

if [[ $USAGE -le $TRESHOLD ]]; then
	echo "OK"
	exit 0	
else
	echo "WARNING"
	exit 1
fi
