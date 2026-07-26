# LIN-09 — Disk Usage Report

## Objective

The goal of this lab was to build a Bash script that generates a disk usage report and helps identify potential filesystem capacity problems.

The script collects filesystem usage, detects filesystems above a configured threshold, and lists the largest directories in a selected path.

---

## Project Structure

```text
09-disk/
├── README.md
├── experiment-report.md
├── examples/
│   ├── cron-example.txt
│   └── sample-report.txt
└── scripts/
    ├── disk_report.sh
    └── disk-report.txt
```

---

## Script Features

The script:

- prints the execution date
- prints the hostname
- shows usage of all mounted filesystems
- checks whether any filesystem exceeds the configured threshold
- lists the 10 largest directories in the selected path
- writes the results to a report file
- prints the location of the generated report

---

## Configuration

The script uses variables that can be adjusted:

```bash
threshold=80
scan_path="/var"
report_file="disk-report.txt"
```

### Variables

- `threshold` — warning threshold in percent
- `scan_path` — directory analyzed for disk usage
- `report_file` — output report file

---

## Commands Used

```bash
df -h
df -P
du -sh
sort -hr
head -n 10
hostname
date
realpath
```

---

## Filesystem Threshold Check

The script uses `awk` to inspect the filesystem utilization column:

```bash
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
```

### Important concepts

- `NR > 1` skips the header.
- `$5` contains the filesystem usage percentage.
- `gsub()` removes the `%` character.
- `-v` passes the Bash variable into `awk`.
- `found` tracks whether any matching filesystem was detected.
- `END` runs after all lines are processed.

---

## Largest Directories

The script uses the following pipeline:

```bash
du -sh "$scan_path"/* 2>/dev/null |
sort -hr |
head -n 10 ||
true
```

This pipeline:

1. calculates directory sizes
2. suppresses permission errors
3. sorts values from largest to smallest
4. displays the top 10 entries

The `|| true` prevents `set -euo pipefail` from terminating the script if an earlier process in the pipeline receives `SIGPIPE`.

---

## Running the Script

```bash
chmod +x scripts/disk_report.sh
./scripts/disk_report.sh
```

View the report:

```bash
cat scripts/disk-report.txt
```

---

## Cron Example

Example scheduled execution:

```cron
0 8 * * * /absolute/path/to/09-disk/scripts/disk_report.sh
```

This runs the report every day at 08:00.

---

## Learning Outcome

After completing this lab I understand:

- the difference between `df` and `du`
- how to detect filesystems above a threshold
- how to process numeric values in `awk`
- how to pass Bash variables into `awk`
- how `NR`, `$0`, `$5`, `gsub()` and `END` work
- how to build readable command pipelines
- how `set -euo pipefail` affects pipeline behavior
- how to generate a reusable disk usage report
