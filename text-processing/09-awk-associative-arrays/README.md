# TP-09 - AWK Associative Arrays & Reports

## Objective

Learn how to use associative arrays in AWK for grouping, counting, aggregating and reporting data.

This lab focuses on:

- associative arrays
- grouping data
- counting occurrences
- calculating totals
- calculating averages
- generating reports

---

## Project Structure

```text
09-awk-associative-arrays/
├── input/
│   ├── access.log
│   ├── employees.csv
│   ├── packages.txt
│   └── services.txt
├── README.md
└── notes.md
```

---

## Skills Practiced

- Associative arrays
- Counting occurrences
- Grouping records
- Summing values
- Calculating averages
- Working with multiple arrays
- Building reports
- Formatting output

---

## New Syntax

### Associative Array

```awk
count[$2]++
```

---

### Sum by Group

```awk
salary[$2] += $3
```

---

### Iterate Through Array

```awk
for (i in count) {
    print i, count[i]
}
```

---

### Multiple Arrays

```awk
salary[$2] += $3
count[$2]++
```

---

## Completed Tasks

### 1. Count employees per department

```bash
awk -F',' '
NR > 1 {
    count[$2]++
}

END {
    for (department in count) {
        print department, count[department]
    }
}
' input/employees.csv
```

---

### 2. Count HTTP status codes

```bash
awk '
{
    count[$3]++
}

END {
    for (status in count) {
        print status, count[status]
    }
}
' input/access.log
```

---

### 3. Count requests per IP

```bash
awk '
{
    count[$1]++
}

END {
    for (ip in count) {
        print ip, count[ip]
    }
}
' input/access.log
```

---

### 4. Count services by status

```bash
awk '
{
    count[$2]++
}

END {
    for (status in count) {
        print status, count[status]
    }
}
' input/services.txt
```

---

### 5. Count packages by category

```bash
awk '
{
    count[$2]++
}

END {
    for (category in count) {
        print category, count[category]
    }
}
' input/packages.txt
```

---

### 6. Calculate total salary per department

```bash
awk -F',' '
NR > 1 {
    salary[$2] += $3
}

END {
    for (department in salary) {
        print department, salary[department]
    }
}
' input/employees.csv
```

---

### 7. Calculate average salary per department

```bash
awk -F',' '
NR > 1 {
    salary[$2] += $3
    count[$2]++
}

END {
    for (department in salary) {
        printf "%-10s %.2f\n", department, salary[department]/count[department]
    }
}
' input/employees.csv
```

---

### 8. Count HTTP errors by IP

```bash
awk '
$3=="404" || $3=="500" {
    count[$1]++
}

END {
    for (ip in count) {
        print ip, count[ip]
    }
}
' input/access.log
```

---

### 9. Department salary report

```bash
awk -F',' '
NR > 1 {
    count[$2]++
    salary[$2] += $3
}

END {
    for (department in count) {
        printf "%-10s Count: %d  Total: %d  Avg: %.2f\n", \
            department, \
            count[department], \
            salary[department], \
            salary[department]/count[department]
    }
}
' input/employees.csv
```

---

## Important Concepts

### Counting

```awk
count[key]++
```

---

### Summing

```awk
sum[key] += value
```

---

### Average

```awk
average[key] = sum[key] / count[key]
```

---

### Iterating

```awk
for (key in array) {
    print key, array[key]
}
```

---

## Variables Used

| Variable | Purpose |
|-----------|---------|
| count[] | Count occurrences |
| salary[] | Salary totals |
| key | Current associative array key |
| NR | Current record number |
| END | Final report generation |

---

## What I Learned

- Creating associative arrays.
- Counting grouped records.
- Summing values by group.
- Calculating grouped averages.
- Iterating through associative arrays.
- Building formatted reports.
- Combining filtering with aggregation.
- Writing reusable AWK reporting patterns.
