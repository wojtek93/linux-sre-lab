#!/usr/bin/env bash

set -euo pipefail

readonly path_value=$PATH


IFS=':' read -a path_array <<< "$path_value"


existing_count=0
missing_count=0
total_count=0

for dir in "${path_array[@]}";
do
	if [[ -d "$dir" ]];then
		echo "EXISTS: $dir"
		((existing_count += 1))
	else
		echo "MISSING: $dir"
		((missing_count += 1))
	fi

	((total_count += 1))
done

echo
echo "========================"
echo "Summary"
echo "========================"
echo "Total entries: $total_count"
echo "Existing: $existing_count"
echo "Missing: $missing_count"




