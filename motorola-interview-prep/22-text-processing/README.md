# MOT-22 — Text Processing Under Interview Pressure

## Goal

Practice fast command-line text processing using common Linux tools used in DevOps/SRE troubleshooting.

Tools covered:

- `grep`
- `awk`
- `sed`
- `cut`
- `sort`
- `uniq`
- `tr`
- `wget`
- pipelines

## grep

Filter lines:

```bash
grep "ERROR" app.log
```

Exclude matching lines:

```bash
grep -v "INFO" app.log
```

Count matching lines:

```bash
grep -c "ERROR" app.log
```

## awk

General structure:

```bash
awk 'condition { action }' file
```

Filter ERROR records and print selected fields:

```bash
awk '$3=="ERROR" {print $4,$6}' app.log
```

Remove prefixes and apply a numeric condition:

```bash
awk '$3=="ERROR" {
    gsub("duration=","",$6)
    if ($6 > 800)
        print $4,$6
}' app.log
```

Skip the header:

```bash
awk 'NR>1 && $4>=85 {print $1,$3,$4}' users.txt
```

Associative arrays can be used for counting:

```bash
awk '{count[$3]++} END {for (i in count) print i,count[i]}' app.log
```

## sort

Numeric descending sort:

```bash
sort -nr
```

Sort numerically by the second field in descending order:

```bash
sort -k2,2nr
```

Example:

```bash
awk '$3=="ERROR" {
    gsub("user=","",$4)
    gsub("duration=","",$6)
    print $4,$6
}' app.log | sort -k2,2nr
```

## uniq

Count repeated values:

```bash
awk '{print $3}' app.log | sort | uniq -c
```

`uniq` works on adjacent duplicate lines, therefore input is normally sorted first.

## cut

Extract fields:

```bash
cut -d' ' -f3,4 app.log
```

Useful options:

```text
-f    fields
-c    characters
-b    bytes
-d    delimiter
```

## sed

Replace text in output:

```bash
sed 's/ERROR/CRITICAL/' app.log
```

Combine with grep:

```bash
grep ERROR app.log | sed 's/action=//'
```

Without `-i`, the source file is not modified.

## tr

Convert lowercase characters to uppercase:

```bash
tr '[:lower:]' '[:upper:]' < app.log
```

`tr` reads from standard input rather than taking the filename directly as a normal argument.

## wget

Check whether a resource is available without downloading it:

```bash
wget --spider http://localhost:8000/users.txt
```

Download and specify the output filename:

```bash
wget -O downloaded_users.txt http://localhost:8000/users.txt
```

Quiet mode:

```bash
wget -q -O downloaded_users.txt http://localhost:8000/users.txt
```

Other useful options:

```text
-O          output filename/path
-P          target directory
-q          quiet mode
-S          show server response headers
-c          continue interrupted download
--spider    check resource without downloading
```

## Pipeline example

Download a file and process it only when the download succeeds:

```bash
wget -q -O downloaded_users.txt http://localhost:8000/users.txt \
&& awk 'NR>1 && $4>=85 {print $1,$3,$4}' downloaded_users.txt \
| sort -k3,3nr
```

## Key interview takeaway

Use each tool for what it does best:

```text
grep   -> filter lines
awk    -> fields, conditions, calculations
sed    -> substitutions
cut    -> simple field extraction
sort   -> ordering
uniq   -> duplicate counting
tr     -> character transformations
wget   -> retrieve/check HTTP resources
```

Linux pipelines allow these tools to be combined quickly during troubleshooting.
