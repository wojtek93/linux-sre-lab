#!/usr/bin/env bash

set -euo pipefail

current_date=$(date +%F)

echo "Current date: $current_date"

filename="backup.tar.gz"

echo "${filename%%.*}"

path="/home/wojtek/Documents/report.txt"


echo "${path##*/}"
echo "${path#/home/wojtek/}"


echo "${path/wojtek/maciek}"

