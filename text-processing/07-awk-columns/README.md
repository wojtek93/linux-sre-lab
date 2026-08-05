# TP-07 - AWK Columns & Formatting

## Objective

Practice selecting, reordering and formatting columns using AWK.

This lab focuses on building readable output from structured text files.

---

## Project Structure

```text
07-awk-columns/
├── input/
│   ├── employees.csv
│   ├── network.txt
│   ├── packages.txt
│   └── services.txt
├── README.md
└── notes.md
```

---

## Skills Practiced

- Selecting fields
- Reordering columns
- Formatting output
- Filtering records
- Using printf
- Building simple reports

---

## Useful Syntax

### Print selected columns

```bash
awk '{print $1,$3}'
```

---

### Change column order

```bash
awk '{print $3,$1,$2}'
```

---

### Custom text

```bash
awk '{print "User:",$1,"Status:",$2}'
```

---

### printf

```bash
awk '{printf "%-12s %10s\n",$1,$2}'
```

---

### Filter records

```bash
awk '$2=="UP" {print $1}'
```

---

### Skip header

```bash
awk 'NR>1 {print}'
```

---

## Completed Tasks

### 1. Print employee name and country

```bash
awk -F',' '
NR>1 {
    print $1,$4
}
' input/employees.csv
```

---

### 2. Print country, employee and salary

```bash
awk -F',' '
NR>1 {
    print $4,$1,$3
}
' input/employees.csv
```

---

### 3. Print services in custom format

```bash
awk '
{
    print "Service:",$1,"Status:",$2
}
' input/services.txt
```

---

### 4. Print active network interfaces

```bash
awk '
$2=="UP" {
    print $1,"->",$3
}
' input/network.txt
```

---

### 5. Print package name and version

```bash
awk '
{
    print $1,$2
}
' input/packages.txt
```

---

### 6. Print package, version and status

```bash
awk '
{
    print $1,$2,"OK"
}
' input/packages.txt
```

---

### 7. Replace commas with pipes

```bash
awk -F',' '
BEGIN {
    OFS=" | "
}

{
    print $1,$2,$3,$4
}
' input/employees.csv
```

---

### 8. Print first three columns separated by tabs

```bash
awk -F',' '
BEGIN {
    OFS="\t"
}

NR>1 {
    print $1,$2,$3
}
' input/employees.csv
```

---

### 9. Print records with line numbers

```bash
awk '
{
    print "[" NR "]",$0
}
' input/services.txt
```

---

### 10. Build a simple report

```bash
awk -F',' '
BEGIN {
    print "===== Employees ====="
}

NR>1 {
    print $1,"(" $2 ")"
}

END {
    print "===== End ====="
}
' input/employees.csv
```

---

## Important Variables

| Variable | Description |
|----------|-------------|
| `$0` | Entire record |
| `$1...$NF` | Fields |
| `NR` | Record number |
| `NF` | Number of fields |
| `OFS` | Output Field Separator |

---

## What I Learned

- Selecting columns.
- Reordering fields.
- Formatting reports.
- Using `printf`.
- Using `OFS`.
- Creating readable output.
- Filtering records.
- Combining multiple fields into custom text.
