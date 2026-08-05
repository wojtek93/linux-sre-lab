# TEX-20 - Text Processing Final Challenge

## Objective

Combine Linux text-processing tools to analyze log files, CSV data and JSON documents.

This lab focuses on:

- filtering application logs
- counting and grouping records
- analyzing HTTP status codes
- finding unique values
- processing CSV files
- aggregating JSON data
- building readable command pipelines
- using associative arrays in `awk`

---

## Project Structure

```text
20-final-challenge/
├── input/
│   ├── access.log
│   ├── servers.json
│   └── users.csv
├── README.md
└── notes.md
```

---

## Skills Practiced

- Filter records with `grep` and `awk`
- Extract selected fields with `cut` and `awk`
- Sort and remove duplicate records
- Count repeated and unique values
- Group data using AWK associative arrays
- Find maximum values
- Analyze HTTP access logs
- Process CSV files with custom separators
- Filter and aggregate JSON data with `jq`
- Combine multiple Linux commands into pipelines

---

## Input Data

### Access log format

```text
2026-08-01T08:12:11 web01 GET /index.html 200
```

Fields:

```text
timestamp server method endpoint status
```

---

### Users CSV format

```text
id,name,department
101,John,IT
```

---

### Servers JSON format

```json
{
  "hostname": "web01",
  "environment": "production",
  "status": "running",
  "cpu": 42
}
```

---

## Basic Patterns

### Filter HTTP errors

```bash
grep -E '[45][0-9][0-9]$' input/access.log
```

---

### Count repeated values

```bash
sort | uniq -c
```

---

### Remove duplicate values

```bash
sort -u
```

---

### Count values with AWK

```bash
awk '{count[$1]++} END {for (key in count) print key, count[key]}'
```

---

### Filter JSON objects

```bash
jq '.[] | select(.field == "value")' file.json
```

---

## Completed Tasks

### 1. Count total requests and errors for each server

```bash
awk '
$5 ~ /^[45][0-9][0-9]$/ {
    countError[$2]++
}

{
    countRequest[$2]++
}

END {
    for (server in countRequest) {
        print server, countRequest[server], countError[server] + 0
    }
}
' input/access.log
```

Result:

```text
web01 9 2
web02 7 3
web03 4 1
```

---

### 2. Count total requests and errors for each endpoint

```bash
awk '
$5 ~ /^[45][0-9][0-9]$/ {
    error[$4]++
}

{
    request[$4]++
}

END {
    for (endpoint in request) {
        print endpoint, request[endpoint], error[endpoint] + 0
    }
}
' input/access.log
```

---

### 3. Count users in each department

```bash
awk -F',' '
NR > 1 {
    count[$3]++
}

END {
    for (department in count) {
        print department, count[department]
    }
}
' input/users.csv
```

Result:

```text
IT 4
HR 2
Finance 1
Security 1
```

---

### 4. Find the department with the most users

```bash
awk -F',' '
NR > 1 {
    countDepartment[$3]++
}

END {
    max = 0

    for (department in countDepartment) {
        if (countDepartment[department] > max) {
            max = countDepartment[department]
            maxDepartment = department
        }
    }

    print maxDepartment, max
}
' input/users.csv
```

Result:

```text
IT 4
```

---

### 5. Display running servers with CPU usage greater than 40

```bash
jq -r '
.[] |
select(.status == "running" and .cpu > 40) |
"\(.hostname) \(.cpu)"
' input/servers.json
```

Result:

```text
web01 42
web02 68
```

---

### 6. Count running servers with CPU usage greater than or equal to 40

```bash
jq '
[
    .[] |
    select(.status == "running" and .cpu >= 40)
] |
length
' input/servers.json
```

Result:

```text
2
```

---

### 7. Find the endpoint with the highest number of errors

```bash
awk '
$5 ~ /^[45][0-9][0-9]$/ {
    endpointError[$4]++
}

END {
    for (endpoint in endpointError) {
        print endpoint, endpointError[endpoint]
    }
}
' input/access.log \
| sort -k2,2nr \
| head -n 1
```

---

### 8. Display the three most requested endpoints

```bash
awk '{print $4}' input/access.log \
| sort \
| uniq -c \
| sort -nr \
| head -n 3
```

---

### 9. Count unique endpoints for each server

```bash
awk '{print $2, $4}' input/access.log \
| sort -u \
| awk '{print $1}' \
| sort \
| uniq -c
```

Result:

```text
6 web01
5 web02
4 web03
```

---

### 10. Find the server with the most unique successful endpoints

```bash
awk '$5 == 200 {print $2, $4}' input/access.log \
| sort -u \
| cut -d' ' -f1 \
| sort \
| uniq -c \
| sort -nr \
| head -n 1
```

---

### 11. Count different servers that returned HTTP errors

```bash
grep -E '[45][0-9][0-9]$' input/access.log \
| awk '{print $2}' \
| sort -u \
| wc -l
```

Result:

```text
3
```

---

### 12. Count requests by HTTP method

```bash
cut -d' ' -f3 input/access.log \
| sort \
| uniq -c \
| awk '{print $2, $1}'
```

Result:

```text
GET 15
POST 5
```

---

## Common Patterns

### Count values by key

```bash
awk '{count[$1]++} END {for (key in count) print key, count[key]}'
```

---

### Count errors by server

```bash
awk '$5 ~ /^[45][0-9][0-9]$/ {count[$2]++}'
```

---

### Count unique pairs

```bash
awk '{print $1, $2}' file \
| sort -u
```

---

### Find the largest value

```bash
sort -k2,2nr \
| head -n 1
```

---

### Skip a CSV header

```bash
awk -F',' 'NR > 1'
```

---

### Count filtered JSON objects

```bash
jq '[.[] | select(.field == "value")] | length'
```

---

## Real-World Examples

### Count errors by application server

```bash
awk '$5 >= 400 && $5 < 600 {count[$2]++}
END {
    for (server in count) {
        print server, count[server]
    }
}' access.log
```

---

### Find the most requested API endpoint

```bash
awk '{print $4}' access.log \
| sort \
| uniq -c \
| sort -nr \
| head -n 1
```

---

### Count HTTP methods

```bash
awk '{count[$3]++}
END {
    for (method in count) {
        print method, count[method]
    }
}' access.log
```

---

### Find running infrastructure with high CPU usage

```bash
jq -r '
.[] |
select(.status == "running" and .cpu >= 80) |
"\(.hostname) \(.cpu)"
' servers.json
```

---

## Frequently Used Tools

| Tool | Description |
|------|-------------|
| `grep` | Filter matching lines |
| `cut` | Extract selected fields |
| `sort` | Sort records |
| `uniq` | Remove or count duplicate lines |
| `wc` | Count lines, words or bytes |
| `awk` | Filter, group and aggregate text |
| `jq` | Process structured JSON data |
| `head` | Display the first records |

---

## What I Learned

- Analyze HTTP access logs using Linux command-line tools.
- Count total requests and error responses.
- Group records using AWK associative arrays.
- Count unique values and unique field combinations.
- Find maximum values using AWK or sorted pipelines.
- Process CSV data using a custom field separator.
- Filter and count JSON objects with `jq`.
- Choose between a readable pipeline and a single AWK command.
- Build reports without creating additional scripts.
