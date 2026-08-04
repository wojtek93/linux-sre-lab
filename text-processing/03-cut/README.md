# TP-03 - Cut

## Objective

Practice extracting specific fields and character ranges from structured text files using the `cut` command.

---

## Project Structure

```text
03-cut/
├── input/
│   ├── employees.csv
│   └── servers.txt
├── README.md
└── notes.md
```

---

## Skills Practiced

- Field extraction
- Multiple field selection
- Field ranges
- Character extraction
- Character ranges
- Working with different delimiters
- Combining `cut` with pipelines

---

## Useful Options

### Select delimiter

```bash
-d ','
```

Specify the field delimiter.

---

### Select a single field

```bash
cut -d',' -f2 employees.csv
```

---

### Select multiple fields

```bash
cut -d',' -f2,4 employees.csv
```

---

### Select a range of fields

```bash
cut -d',' -f3- employees.csv
```

From field 3 to the end.

```bash
cut -d',' -f1-3 employees.csv
```

From field 1 to field 3.

---

### Extract characters

```bash
cut -c1-5 file.txt
```

Characters 1 through 5.

```bash
cut -c7-18 file.txt
```

Characters 7 through 18.

---

## Completed Tasks

### Display employee names

```bash
cut -d',' -f2 input/employees.csv
```

---

### Display names and departments

```bash
cut -d',' -f2,3 input/employees.csv
```

---

### Display departments through the last column

```bash
cut -d',' -f3- input/employees.csv
```

---

### Display email addresses

```bash
cut -d',' -f4 input/employees.csv
```

---

### Display salaries without the header

```bash
tail -n +2 input/employees.csv | cut -d',' -f5
```

---

### Display server hostnames

```bash
cut -d':' -f1 input/servers.txt
```

---

### Display IP address and environment

```bash
cut -d':' -f2,3 input/servers.txt
```

---

### Display fields from the third field onward

```bash
cut -d':' -f3- input/servers.txt
```

---

### Display the first five characters

```bash
cut -c-5 input/servers.txt
```

---

### Display characters 7 through 18

```bash
cut -c7-18 input/servers.txt
```

---

## Key Concepts

### Field delimiter

```bash
-d ','
```

Defines how `cut` splits each line.

Examples:

CSV

```text
John,IT,8000
```

Delimiter:

```text
,
```

Server list

```text
web01:192.168.1.10:production
```

Delimiter:

```text
:
```

---

### Field selection

Single field

```bash
-f2
```

Multiple fields

```bash
-f2,4
```

Field range

```bash
-f2-4
```

From a field to the end

```bash
-f3-
```

---

### Character selection

Beginning of line

```bash
-c1-5
```

Up to character five

```bash
-c-5
```

Character seven onward

```bash
-c7-
```

Specific range

```bash
-c7-18
```

---

## What I Learned

- How to extract specific columns from delimited files.
- How to work with different delimiters.
- How to extract multiple fields at once.
- How to select field ranges.
- How to extract fixed character positions.
- How to combine `cut` with other commands in a pipeline.
- When `cut` is sufficient and when more advanced tools such as `awk` are needed.
