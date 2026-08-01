# BAS-15 - CSV Processing

## Objective

Learn how to process CSV files using both Bash (`while read`) and `awk`.

## Skills Practiced

- Reading CSV files
- Using IFS with `read`
- Filtering rows
- Reordering columns
- Creating output files
- Using `awk`
- BEGIN block
- NR (record number)
- Field separator (FS)
- Output field separator (OFS)

## Files

```
csv_filter.sh
csv_filter_awk.sh
input/users.csv
output/
```

## Run

```bash
chmod +x csv_filter.sh
chmod +x csv_filter_awk.sh

./csv_filter.sh
./csv_filter_awk.sh
```

## Output

```
output/it_users.csv
output/it_users_awk.csv
```

Both scripts generate the same CSV output.

## What I Learned

- Process CSV files using `while read`.
- Parse CSV using `awk`.
- Difference between FS and OFS.
- Use BEGIN blocks.
- Filter rows using conditions.
- Reorder output columns.
- Generate CSV reports.
