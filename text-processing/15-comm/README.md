# TEX-15 - comm

## Objective

Learn how to compare two sorted text files using the Linux `comm` command.

This lab focuses on:

- identifying records unique to the first file
- identifying records unique to the second file
- finding records common to both files
- comparing system inventories and configuration snapshots
- understanding the three-column output format

---

## Project Structure

```text
15-comm/
├── input/
│   ├── packages_after.txt
│   ├── packages_before.txt
│   ├── servers_a.txt
│   ├── servers_b.txt
│   ├── services_new.txt
│   ├── services_old.txt
│   ├── users_dev.txt
│   └── users_prod.txt
├── README.md
└── notes.md
```

---

## Important Rule

`comm` requires both input files to be sorted.

Example:

```bash
sort file1.txt > file1.sorted.txt
sort file2.txt > file2.sorted.txt
```

Then:

```bash
comm file1.sorted.txt file2.sorted.txt
```

---

## Three Output Columns

A plain `comm` command produces three columns:

| Column | Meaning |
|---|---|
| 1 | Lines only in the first file |
| 2 | Lines only in the second file |
| 3 | Lines common to both files |

Example:

```bash
comm input/servers_a.txt input/servers_b.txt
```

---

## Important Options

The options suppress output columns.

| Option | Effect |
|---|---|
| `-1` | Hide column 1 |
| `-2` | Hide column 2 |
| `-3` | Hide column 3 |

---

## Completed Tasks

### 1. Compare two server lists

```bash
comm input/servers_a.txt input/servers_b.txt
```

This displays:

- servers only in `servers_a.txt`
- servers only in `servers_b.txt`
- servers present in both files

---

### 2. Show entries only in the first file

```bash
comm -2 -3 input/servers_a.txt input/servers_b.txt
```

Expected output:

```text
app01
db02
```

---

### 3. Show entries only in the second file

```bash
comm -1 -3 input/servers_a.txt input/servers_b.txt
```

Expected output:

```text
db03
web02
```

---

### 4. Show common entries

```bash
comm -1 -2 input/servers_a.txt input/servers_b.txt
```

Expected output:

```text
app02
db01
proxy01
web01
```

---

### 5. Show packages added after an update

```bash
comm -1 -3 input/packages_before.txt input/packages_after.txt
```

Expected output:

```text
htop
tmux
```

---

### 6. Show services added in the new version

```bash
comm -1 -3 input/services_old.txt input/services_new.txt
```

Expected output:

```text
loki
tempo
```

---

## Common Patterns

### Only in the first file

```bash
comm -2 -3 file1 file2
```

### Only in the second file

```bash
comm -1 -3 file1 file2
```

### Common to both files

```bash
comm -1 -2 file1 file2
```

---

## Practical Examples

### Find users existing only in production

```bash
comm -1 -3 input/users_dev.txt input/users_prod.txt
```

### Find users existing only in development

```bash
comm -2 -3 input/users_dev.txt input/users_prod.txt
```

### Find users existing in both environments

```bash
comm -1 -2 input/users_dev.txt input/users_prod.txt
```

---

## `comm` vs `diff`

`comm` is best when:

- both files contain sorted line-based lists
- you want unique and common values
- each line represents one item

`diff` is better when:

- you want line-by-line file changes
- line order matters
- you need patch-style output

---

## What I Learned

- How the three `comm` output columns work.
- How to suppress selected columns.
- How to find values unique to either file.
- How to find values shared by both files.
- Why input files must be sorted.
- How to compare package, server, service and user inventories.
