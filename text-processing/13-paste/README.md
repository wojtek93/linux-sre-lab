# TEX-13 - paste

## Objective

Learn how to combine multiple text files side-by-side using the Linux `paste` command.

This lab focuses on:

- combining files column-by-column
- changing delimiters
- working with multiple files
- generating simple reports

---

## Project Structure

```text
13-paste/
├── input/
│   ├── departments.txt
│   ├── environments.txt
│   ├── ips.txt
│   ├── names.txt
│   ├── salaries.txt
│   └── servers.txt
├── README.md
└── notes.md
```

---

## Skills Practiced

- Merge files side-by-side
- Change field delimiter
- Combine multiple files
- Create simple tabular reports

---

## New Syntax

### Combine two files

```bash
paste file1 file2
```

---

### Combine three files

```bash
paste file1 file2 file3
```

---

### Change delimiter

```bash
paste -d',' file1 file2
```

---

### Use semicolon delimiter

```bash
paste -d';' file1 file2 file3
```

---

### Pretty-print output

```bash
paste file1 file2 file3 | column -t
```

---

## Completed Tasks

### Merge names and departments

```bash
paste input/names.txt input/departments.txt
```

---

### Merge using comma

```bash
paste -d',' input/names.txt input/departments.txt
```

---

### Merge names, departments and salaries

```bash
paste input/names.txt input/departments.txt input/salaries.txt
```

---

### Merge three files using semicolon

```bash
paste -d';' input/names.txt input/departments.txt input/salaries.txt
```

---

### Create server inventory

```bash
paste input/servers.txt input/ips.txt input/environments.txt
```

---

## Frequently Used Commands

### Default delimiter (TAB)

```bash
paste file1 file2
```

---

### Custom delimiter

```bash
paste -d',' file1 file2
```

---

### Multiple files

```bash
paste file1 file2 file3 file4
```

---

### Format as table

```bash
paste file1 file2 file3 | column -t
```

---

## Command Options

| Option | Description |
|--------|-------------|
| `-d` | Specify delimiter |
| `-` | Read input from stdin |

---

## What I Learned

- Combine files side-by-side.
- Merge multiple files.
- Change output delimiters.
- Build simple reports from multiple data sources.
- Format merged output using `column -t`.
