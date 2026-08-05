# TEX-14 - join

## Objective

Learn how to combine records from two sorted text files using a shared key.

This lab focuses on:

- joining files by a common field
- selecting join fields from both files
- controlling output columns
- understanding the difference between `paste` and `join`
- working with sorted input files

---

## Project Structure

```text
14-join/
├── input/
│   ├── certificates.txt
│   ├── departments.txt
│   ├── employees.txt
│   ├── employees_by_name.txt
│   ├── ips.txt
│   ├── salaries.txt
│   ├── servers.txt
│   └── users.txt
├── README.md
└── notes.md
```

---

## Skills Practiced

- Join files by a common key
- Join using non-default columns
- Select output fields
- Work with sorted input
- Combine inventory and employee data

---

## Important Rule

`join` requires both input files to be sorted by the join field.

Example:

```bash
sort -k1,1 file1.txt > file1.sorted.txt
sort -k1,1 file2.txt > file2.sorted.txt
```

Then:

```bash
join file1.sorted.txt file2.sorted.txt
```

---

## Basic Syntax

### Join by the first field

```bash
join file1 file2
```

By default, `join` uses the first field from both files.

---

### Select the join field

```bash
join -1 FIELD_FROM_FILE1 -2 FIELD_FROM_FILE2 file1 file2
```

Example:

```bash
join -1 2 -2 1 file1 file2
```

This joins:

- field 2 from the first file,
- field 1 from the second file.

---

### Select output fields

On the local implementation used in this lab:

```bash
join -o 1.2,2.2 file1 file2
```

A portable alternative may require the field list as one quoted argument:

```bash
join -o '1.2 2.2' file1 file2
```

Field notation:

```text
1.2
```

means field 2 from file 1.

```text
2.2
```

means field 2 from file 2.

---

## Completed Tasks

### 1. Join employees and departments

```bash
join input/employees.txt input/departments.txt
```

Expected result:

```text
101 John IT
102 Anna HR
103 Mark IT
104 Kate Finance
105 Tom IT
106 Alice Security
```

---

### 2. Join employees and salaries

```bash
join input/employees.txt input/salaries.txt
```

Expected result:

```text
101 John 8000
102 Anna 6200
103 Mark 9500
104 Kate 7000
105 Tom 8700
106 Alice 9200
```

---

### 3. Join servers and IP addresses

```bash
join input/servers.txt input/ips.txt
```

Expected result:

```text
app01 production 10.0.0.10
app02 production 10.0.0.11
db01 staging 10.0.0.20
db02 staging 10.0.0.21
proxy01 development 10.0.0.30
```

---

### 4. Select the first field explicitly

```bash
join -1 1 -2 1 input/servers.txt input/ips.txt
```

This produces the same result as the default `join`.

---

### 5. Join using different field positions

First file:

```text
101 8000
102 6200
```

Second file:

```text
John 101
Anna 102
```

Command:

```bash
join -1 1 -2 2 input/salaries.txt input/employees_by_name.txt
```

Expected output order:

```text
101 8000 John
102 6200 Anna
```

The join key is printed first, followed by remaining fields from file 1 and then file 2.

---

### 6. Print selected columns only

```bash
join -o 1.2,2.2 input/employees.txt input/departments.txt
```

Expected result:

```text
John IT
Anna HR
Mark IT
Kate Finance
Tom IT
Alice Security
```

---

## `paste` vs `join`

### `paste`

Combines records by line position:

```bash
paste file1 file2
```

Line 1 is combined with line 1, line 2 with line 2, and so on.

### `join`

Combines records by a matching key:

```bash
join file1 file2
```

Records are matched by field value, not by line number.

---

## Option Reference

| Option | Description |
|---|---|
| `-1 N` | Join using field N from the first file |
| `-2 N` | Join using field N from the second file |
| `-o LIST` | Select output fields |
| `-t CHAR` | Use a custom field separator |

---

## Important Concepts

### Default join

```bash
join file1 file2
```

Uses field 1 from both files.

### Non-default join

```bash
join -1 2 -2 1 file1 file2
```

Uses different join fields.

### Output field selection

```bash
join -o 1.2,2.2 file1 file2
```

Prints only selected fields.

---

## What I Learned

- How to join two files by a shared key.
- How `join` differs from `paste`.
- How to select join fields using `-1` and `-2`.
- How to select output columns using `-o`.
- Why input files must be sorted by the join key.
- How output field order depends on file order.
