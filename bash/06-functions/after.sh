#!/usr/bin/env bash


check_arguments() {
	if [[ $# -ne 1 ]]; then
   		 echo "Usage: $0 <log_file>"
    		 exit 1
	fi	
}


check_file() {
	local file="$1"
	if [[ ! -f "$file" ]]; then
   		 echo "File '$file' does not exist."
   		 exit 1
	fi
}


count_entries() {
	local file="$1"
	
	local info
	local warning
	local error

	info=$(grep -c "INFO" "$file")
	warning=$(grep -c "WARNING" "$file")
	error=$(grep -c "ERROR" "$file")

	echo "$info $warning $error"
}


print_report() {
	local file="$1"
	local info="$2"
	local warning="$3"
	local error="$4"

	echo "=========================="
	echo "File: $(basename "$file")"
	echo "=========================="
	echo
	echo "INFO:    $info"
	echo "WARNING: $warning"
	echo "ERROR:   $error"
	echo
	echo "Total entries: $((info + warning + error))"
}



check_arguments "$@"

check_file "$1"

read info warning error <<< "$(count_entries "$1")"

print_report "$1" "$info" "$warning" "$error"

