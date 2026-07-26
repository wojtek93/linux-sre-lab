#!/usr/bin/env bash

set -euo pipefail

threshold=80
scan_path="/var"
report_file="$(pwd)/disk-report.txt"

{
    echo "====================================="
    echo " Disk Usage Report"
    echo "====================================="
    echo
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "Scan path: $scan_path"
    echo "Warning threshold: ${threshold}%"
    echo
} > "$report_file"

{
    echo "====================================="
    echo " Filesystem Usage"
    echo "====================================="
    echo

    df -h

    echo
} >> "$report_file"

{
    echo "====================================="
    echo " Filesystems Above Threshold"
    echo "====================================="
    echo

	df -P | awk -v threshold="$threshold" '
   	 NR > 1 {
        	usage = $5
        	gsub("%", "", usage)

       	 if (usage >= threshold) {
        	    print $0
        	    found = 1
       		 }
    	}

    END {
        if (!found) {
            print "No filesystems exceeded the configured threshold."
        }
    }
'
    echo
} >> "$report_file"

{
    echo "====================================="
    echo " Largest Directories"
    echo "====================================="
    echo

    du -sh "$scan_path"/* 2>/dev/null | sort -hr | head -n 10 || true

    echo
} >> "$report_file"

echo "Disk report generated successfully."
echo "Report file: $report_file"


