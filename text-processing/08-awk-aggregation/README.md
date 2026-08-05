# TP-08 - AWK Aggregation

## Objective

Practice data aggregation using AWK.

This lab focuses on:

- counters
- sums
- averages
- minimum values
- maximum values
- custom variables
- BEGIN / END blocks
- summary reports

---

## Project Structure

```text
08-awk-aggregation/
├── input/
│   ├── employees.csv
│   ├── cpu.txt
│   ├── disk.txt
│   ├── memory.txt
│   └── orders.csv
├── README.md
└── notes.md
```

---

## Skills Practiced

- Numeric aggregation
- Counters
- Running totals
- Average calculation
- Maximum values
- Minimum values
- Summary reports
- Working with variables
- END block

---

## Useful Patterns

### Sum

```awk
sum += $3
```

---

### Counter

```awk
count++
```

---

### Average

```awk
sum / count
```

---

### Maximum

```awk
NR == 2 {
    max = $3
}

NR > 2 && $3 > max {
    max = $3
}
```

---

### Minimum

```awk
NR == 2 {
    min = $3
}

NR > 2 && $3 < min {
    min = $3
}
```

---

### END block

```awk
END {
    print sum
}
```

---

## Completed Tasks

### 1. Calculate total salary

```bash
awk -F',' '
NR > 1 {
    sum += $3
}

END {
    printf "Total salary: %d\n", sum
}
' input/employees.csv
```

---

### 2. Calculate average salary

```bash
awk -F',' '
NR > 1 {
    sum += $3
}

END {
    printf "Average salary: %.1f\n", sum/(NR-1)
}
' input/employees.csv
```

---

### 3. Find highest salary

```bash
awk -F',' '
NR == 2 {
    max = $3
}

NR > 2 && $3 > max {
    max = $3
}

END {
    printf "Highest salary: %d\n", max
}
' input/employees.csv
```

---

### 4. Find lowest salary

```bash
awk -F',' '
NR == 2 {
    min = $3
}

NR > 2 && $3 < min {
    min = $3
}

END {
    printf "Lowest salary: %d\n", min
}
' input/employees.csv
```

---

### 5. Count employees

```bash
awk -F',' '
NR > 1 {
    count++
}

END {
    printf "Employees: %d\n", count
}
' input/employees.csv
```

---

### 6. Calculate total CPU usage

```bash
awk '
{
    sum += $2
}

END {
    printf "Total CPU: %d\n", sum
}
' input/cpu.txt
```

---

### 7. Print servers above average CPU

```bash
avg=$(awk '
{
    sum += $2
    count++
}

END {
    print sum/count
}
' input/cpu.txt)

awk -v avg="$avg" '
$2 > avg {
    print $1, $2
}
' input/cpu.txt
```

---

### 8. Calculate total order value

```bash
awk -F',' '
NR > 1 {
    sum += $3
}

END {
    printf "Total order value: %d\n", sum
}
' input/orders.csv
```

---

### 9. Find highest order

```bash
awk -F',' '
NR == 2 {
    max = $3
}

NR > 2 && $3 > max {
    max = $3
}

END {
    printf "Highest order: %d\n", max
}
' input/orders.csv
```

---

### 10. Generate summary report

```bash
awk -F',' '
NR > 1 {
    count++
    sum += $3
}

NR == 2 {
    max = $3
    min = $3
}

NR > 2 && $3 > max {
    max = $3
}

NR > 2 && $3 < min {
    min = $3
}

END {
    printf "========== SUMMARY ==========\n"
    printf "Employees: %d\n", count
    printf "Total salary: %d\n", sum
    printf "Average salary: %.1f\n", sum/count
    printf "Highest salary: %d\n", max
    printf "Lowest salary: %d\n", min
    printf "=============================\n"
}
' input/employees.csv
```

---

## Variables Used

| Variable | Purpose |
|-----------|---------|
| sum | Running total |
| count | Record counter |
| max | Maximum value |
| min | Minimum value |
| NR | Current record number |

---

## What I Learned

- Using variables in AWK.
- Aggregating numeric values.
- Counting matching records.
- Calculating averages.
- Finding minimum and maximum values.
- Building summary reports.
- Using `END` for final calculations.
- Writing readable multi-line AWK programs.
