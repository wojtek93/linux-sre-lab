#!/usr/bin/env bash

if [[ $# -ne 1 ]];then
	echo "Usage $0 <log_pah>>"
	exit 1
fi

log_path=$1

if [[ ! -d "$log_path" ]]; then
    echo "Directory '$log_path' does not exist."
    exit 1
fi

files=$(find $log_path -type f -name '*.log')

total_info=0
total_warning=0
total_error=0


for file in $files;do

	info=$(grep -c "INFO" "$file")
	warning=$(grep -c "WARNING" "$file")
	error=$(grep -c "ERROR" "$file")
	
	((total_info += info ))
	((total_warning += warning))
	((total_error += error))

	echo "======================="
	echo "File: $(basename "$file")"
	echo 
	echo "Info: $info"
	echo "Warning:  $warning"
	echo "Error: $error"
	echo "======================="
	echo
done

	echo "======================="
	echo "Total results: "
	echo
	echo "Total Info: $total_info"
	echo "Total Warning:  $total_warning"
	echo "Total Error: $total_error"
	echo "======================="

