# Bash Lab 05 – Log Batch Report

## Objective

Create a Bash script that processes every `.log` file in a directory and produces:

- a separate summary for each log file,
- the number of `INFO`, `WARNING`, and `ERROR` entries,
- a combined summary for all processed files.

---

## Project Structure

```text
05-loops/
├── log_batch_report.sh
├── README.md
└── logs/
    ├── app.log
    ├── auth.log
    └── nginx.log
```

---

## Usage

Make the script executable:

```bash
chmod +x log_batch_report.sh
```

Run the script and provide the log directory:

```bash
./log_batch_report.sh logs
```

---

## Example Output

```text
------------------------
File: app.log

Info: 3
Warning: 1
Error: 2
------------------------

------------------------
File: auth.log

Info: 2
Warning: 1
Error: 2
------------------------

========================
Total results:

Total Info: 5
Total Warning: 2
Total Error: 4
========================
```

---

## Argument Validation

The script expects exactly one command-line argument:

```text
<log_path>
```

Example:

```bash
./log_batch_report.sh logs
```

If the argument is missing, the script displays:

```text
Usage: log_batch_report.sh <log_path>
```

and exits with status code `1`.

---

## Directory Validation

The script verifies that the provided path exists and is a directory:

```bash
if [[ ! -d "$log_path" ]]; then
```

If the directory does not exist, the script displays an error and exits.

---

## Finding Log Files

The script uses:

```bash
find "$log_path" -type f -name "*.log"
```

Meaning:

- `"$log_path"` – directory to search,
- `-type f` – only regular files,
- `-name "*.log"` – only files ending with `.log`.

`find` searches recursively, including subdirectories.

---

## Processing Files with a Loop

The script processes each discovered file using a `for` loop:

```bash
for file in $files; do
    ...
done
```

For every file, it calculates the number of matching log levels.

---

## Counting Log Levels

The script uses `grep -c`:

```bash
info=$(grep -c "INFO" "$file")
warning=$(grep -c "WARNING" "$file")
error=$(grep -c "ERROR" "$file")
```

The `-c` option returns the number of matching lines.

---

## Arithmetic in Bash

Combined totals are calculated using arithmetic expressions:

```bash
((total_info += info))
((total_warning += warning))
((total_error += error))
```

This means:

```text
total_info = total_info + info
```

Bash uses `(( ... ))` for arithmetic operations.

---

## Safe Variable Quoting

Paths are passed in double quotes:

```bash
"$log_path"
"$file"
```

This prevents unexpected word splitting when a path contains spaces.

---

## Exit Codes

The script uses:

```text
0 = success
1 = invalid argument or missing directory
```

Check the latest exit code with:

```bash
echo "$?"
```

---

## Skills Practiced

- command-line arguments,
- directory validation,
- `find`,
- `for` loops,
- `grep -c`,
- Bash arithmetic,
- counters,
- command substitution,
- safe variable quoting,
- generating per-file and total summaries.
