# BAS-16 - JSON Processing with jq

## Objective

Learn how to read, validate, filter, and summarize JSON data in Bash using `jq`.

## Skills Practiced

- JSON validation
- `jq`
- Accessing object fields
- Iterating over arrays
- Filtering with `select()`
- Raw output with `-r`
- String interpolation
- Counting array elements
- Command substitution
- File output
- Error handling

## Files

```text
json_report.sh
input/services.json
output/running_services.txt
```

## Run

```bash
chmod +x json_report.sh

./json_report.sh
```

## Generated Report

The script creates:

```text
output/running_services.txt
```

Example content:

```text
nginx:80
postgres:5432
api:8080
```

## Key jq Expressions

### Display all service names

```bash
jq -r '.services[].name' input/services.json
```

### Filter running services

```bash
jq -r '.services[] | select(.status == "running") | .name' input/services.json
```

### Count all services

```bash
jq '.services | length' input/services.json
```

### Count running services

```bash
jq '[.services[] | select(.status == "running")] | length' input/services.json
```

## What I Learned

- How to validate JSON using `jq empty`.
- How to navigate JSON objects and arrays.
- How to filter records using `select()`.
- How to extract fields and format output.
- How to calculate totals using `length`.
- How to use `jq` inside Bash scripts.
