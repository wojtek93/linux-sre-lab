# Lab 11 - Safe Temporary File Processing

## Objective

Learn how to safely create, use and automatically remove temporary files in Bash using `mktemp` and `trap`.

## Skills Practiced

- `mktemp`
- `trap`
- Temporary files
- Safe cleanup
- `awk`
- `sort`
- `wc`
- Bash best practices
- `set -euo pipefail`

## Files

```
safe_temp_processing.sh
input/users.csv
```

## Run

```bash
chmod +x safe_temp_processing.sh

./safe_temp_processing.sh
```

## Workflow

1. Create a secure temporary file with `mktemp`.
2. Register automatic cleanup using `trap`.
3. Extract active users from the CSV file.
4. Save intermediate data into the temporary file.
5. Sort the temporary data.
6. Display the processed results.
7. Print the total number of active users.
8. Automatically remove the temporary file when the script exits.

## What I Learned

- Why `mktemp` is safer than creating files manually in `/tmp`.
- How `trap` guarantees cleanup even if the script exits unexpectedly.
- How to safely process intermediate data without modifying the original input file.
- How multiple Linux tools (`awk`, `sort`, `wc`) can work together using a temporary file.
- Why automatic cleanup is considered a Bash scripting best practice.
