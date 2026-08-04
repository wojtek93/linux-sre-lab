# TP-05 - sort & uniq

## Objective

Practice sorting data, removing duplicates, counting occurrences, and identifying the most frequent values using `sort` and `uniq`.

---

## Project Structure

```text
05-sort-uniq/
├── input/
│   ├── fruits.txt
│   ├── logins.log
│   ├── processes.txt
│   ├── salaries.csv
│   └── users.txt
├── README.md
└── notes.md
```

---

## Skills Practiced

- Alphabetical sorting
- Reverse sorting
- Numeric sorting
- Sorting by a specific field
- Removing duplicate values
- Counting duplicate occurrences
- Combining `sort` and `uniq`
- Finding the most common values
- Working with CSV files

---

## Useful Commands

### Alphabetical sort

```bash
sort file.txt
```

---

### Reverse sort

```bash
sort -r file.txt
```

---

### Numeric sort

```bash
sort -n numbers.txt
```

---

### Reverse numeric sort

```bash
sort -nr numbers.txt
```

---

### Sort using a delimiter

```bash
sort -t',' -k2 -n salaries.csv
```

- `-t` → field delimiter
- `-k2` → second column
- `-n` → numeric comparison

---

### Remove duplicate lines

```bash
sort file.txt | uniq
```

---

### Count duplicate lines

```bash
sort file.txt | uniq -c
```

---

### Display the most common values

```bash
sort file.txt | uniq -c | sort -nr
```

---

## Completed Tasks

### 1. Sort fruits alphabetically

```bash
sort input/fruits.txt
```

---

### 2. Sort fruits in reverse order

```bash
sort -r input/fruits.txt
```

---

### 3. Display unique fruits

```bash
sort input/fruits.txt | uniq
```

---

### 4. Count each fruit

```bash
sort input/fruits.txt | uniq -c
```

---

### 5. Display fruits ordered by frequency

```bash
sort input/fruits.txt | uniq -c | sort -nr
```

---

### 6. Find the most frequently logged-in user

```bash
sort input/logins.log | uniq -c | sort -nr
```

Only the top user:

```bash
sort input/logins.log | uniq -c | sort -nr | head -1
```

---

### 7. Sort salaries in ascending order

```bash
sort -t',' -k2 -n input/salaries.csv
```

---

### 8. Sort salaries in descending order

```bash
sort -t',' -k2 -nr input/salaries.csv
```

---

### 9. Display unique process names

```bash
sort input/processes.txt | uniq
```

---

### 10. Display processes ordered by occurrence

```bash
sort input/processes.txt | uniq -c | sort -nr
```

---

## Key Options

### sort

Sort lines alphabetically.

```bash
sort file.txt
```

---

### -r

Reverse sorting order.

```bash
sort -r file.txt
```

---

### -n

Numeric sorting.

```bash
sort -n numbers.txt
```

Without `-n`:

```text
100
20
3
```

With `-n`:

```text
3
20
100
```

---

### -t

Specify a field delimiter.

```bash
sort -t',' ...
```

---

### -k

Choose the sort key (column).

```bash
sort -k2
```

Second field.

---

### uniq

Remove adjacent duplicate lines.

```bash
uniq
```

Since `uniq` only removes consecutive duplicates, it is usually used together with `sort`.

```bash
sort file.txt | uniq
```

---

### uniq -c

Count occurrences.

```bash
sort file.txt | uniq -c
```

---

## Common Pattern

The classic log-analysis pipeline:

```bash
sort file.txt | uniq -c | sort -nr
```

Meaning:

1. Sort the data.
2. Count duplicate lines.
3. Sort counts from highest to lowest.

---

## What I Learned

- How alphabetical and numeric sorting differ.
- How to sort using specific columns.
- Why `uniq` should usually follow `sort`.
- How to count duplicate values.
- How to identify the most frequent entries in logs.
- How to work with CSV files using custom delimiters.
- How to build efficient pipelines with `sort`, `uniq`, and `head`.
