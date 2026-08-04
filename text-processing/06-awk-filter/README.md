# TP-06 - awk (Filtering)

## Objective

Practice filtering, selecting fields, formatting output, and using built-in AWK variables for processing structured text files.

---

## Project Structure

```text
06-awk-filter/
├── input/
│   ├── employees.csv
│   ├── access.log
│   ├── disks.txt
│   └── processes.txt
├── README.md
└── notes.md
```

---

## Skills Practiced

- Selecting fields
- Filtering rows
- Numeric comparisons
- String comparisons
- Working with CSV files
- Using custom delimiters
- Using built-in variables
- Formatted output with printf
- END block

---

## Useful Syntax

### Specify a delimiter

```bash
awk -F',' '{print $1}'
```

---

### Print a field

```bash
awk '{print $1}'
```

---

### Print multiple fields

```bash
awk '{print $1,$3}'
```

---

### Filter rows

```bash
awk '$2=="IT" {print $1}'
```

---

### Numeric comparison

```bash
awk '$3>8500 {print $1}'
```

---

### Multiple conditions

```bash
awk 'NR>1 && $3>8500 {print $1,$3}'
```

---

### Print the whole record

```bash
awk '{print $0}'
```

---

### Print the last column

```bash
awk '{print $NF}'
```

---

### Print the line number

```bash
awk '{print NR,$0}'
```

---

### Formatted output

```bash
awk '{printf "%s %d\n",$1,$2}'
```

---

### END block

```bash
awk '
END{
    print "Finished"
}
'
```

---

## Completed Tasks

### 1. Print employee names

```bash
awk -F',' 'NR>1 {print $1}' input/employees.csv
```

---

### 2. Print employees from the IT department

```bash
awk -F',' '$2=="IT" {print $1}' input/employees.csv
```

---

### 3. Print employees earning more than 8500

```bash
awk -F',' 'NR>1 && $3>8500 {print $1,$3}' input/employees.csv
```

---

### 4. Print IP addresses with HTTP 401

```bash
awk '$4==401 {print $1}' input/access.log
```

---

### 5. Print filesystems with usage greater than 80%

```bash
awk 'NR>1 {
    gsub("%","",$5)
    if($5>80)
        print $1
}' input/disks.txt
```

Alternative solution:

```bash
awk -F'%| ' 'NR>1 && $5>80 {print $1}' input/disks.txt
```

---

### 6. Print processes with more than 10 instances

```bash
awk '$2>10 {print $1,$2}' input/processes.txt
```

---

### 7. Print all records with AWK line numbers

```bash
awk -F',' 'NR>1 {print NR,$0}' input/employees.csv
```

---

### 8. Format custom output

```bash
awk -F',' 'NR>1 {
    print $1 " works in " $2 " and earns " $3
}' input/employees.csv
```

---

### 9. Number employees

```bash
awk -F',' '
NR>1{
    printf "Employee #%d: %s\n",NR-1,$1
}
' input/employees.csv
```

---

### 10. Print total number of employees

```bash
awk -F',' '
NR>1{
    printf "Employee #%d: %s\n",NR-1,$1
}
END{
    printf "Total employees: %d\n",NR-1
}
' input/employees.csv
```

---

## Important Built-in Variables

| Variable | Description |
|----------|-------------|
| `$0` | Entire record |
| `$1` | First field |
| `$2` | Second field |
| `$NF` | Last field |
| `NR` | Current record number |
| `NF` | Number of fields |

---

## Useful Functions

### gsub()

Replace every occurrence.

```bash
gsub("%","",$5)
```

---

## Comparison Operators

```text
==
!=
>
<
>=
<=
```

---

## Logical Operators

```text
&&
||
!
```

---

## What I Learned

- How AWK splits input into fields.
- How to filter rows using conditions.
- How to compare numbers and strings.
- How to access fields using `$1`, `$2`, `$NF`.
- How `NR` and `NF` work.
- How to format output using `printf`.
- How to build custom reports.
- How to use the `END` block for summaries.
- How to modify field content with `gsub()`.
