#!/usr/bin/env python3

import sys

if len(sys.argv) < 2:
    print("Usage: python3 "+ sys.argv[0] + " <filename> ")
    sys.exit(1)

filename = sys.argv[1]
error_count = 0
warning_count = 0

try:
    with open(filename, "r" ) as file:
        for line in file:
            if "ERROR" in line:
                error_count += 1
            elif "WARNING" in line:
                warning_count += 1

except FileNotFoundError:
    print(f"ERROR: File '{filename}' not found")
    sys.exit(1)


print(f"ERROR's number {error_count}" )
print(f"WARNING's number {warning_count}")
