# TEX-12 - sed Range

## Objective

Learn how to apply `sed` commands only to selected line ranges.

This lab focuses on:

- printing line ranges
- deleting line ranges
- replacing text within selected ranges
- addressing individual lines
- combining line addressing with `sed` commands

---

## Project Structure

```text
12-sed-range/
├── input/
│   ├── config.conf
│   ├── system.log
│   ├── text.txt
│   └── users.txt
├── README.md
└── notes.md
```

---

## Skills Practiced

- Print selected line ranges
- Delete selected line ranges
- Modify only selected lines
- Address a single line
- Address a continuous range
- Combine addresses with substitution commands

---

## Addressing Syntax

### Single line

```bash
sed '5d' file.txt
```

The command applies only to line 5.

---

### Line range

```bash
sed '3,6d' file.txt
```

The command applies to lines 3 through 6.

---

### Print a selected range

```bash
sed -n '3,6p' file.txt
```

`-n` disables automatic output and `p` prints the selected lines.

---

### Substitute within a range

```bash
sed '2,5s/old/new/g' file.txt
```

The substitution is performed only on lines 2 through 5.

---

## Completed Tasks

### 1. Print lines 3 through 6

```bash
sed -n '3,6p' input/text.txt
```

Expected output:

```text
Line three
Line four
Line five
Line six
```

---

### 2. Delete lines 2 through 4

```bash
sed '2,4d' input/text.txt
```

---

### 3. Replace semicolons with commas only on lines 2 through 4

```bash
sed '2,4s/;/,/g' input/users.txt
```

Lines outside the selected range remain unchanged.

---

### 4. Replace `development` with `production` only on line 7

```bash
sed '7s/development/production/' input/config.conf
```

---

### 5. Print only lines 4 through 7 from the log

```bash
sed -n '4,7p' input/system.log
```

---

### 6. Replace `INFO` with `NOTICE` only on lines 1 through 5

```bash
sed '1,5s/INFO/NOTICE/g' input/system.log
```

---

### 7. Delete lines from 5 to the end of the file

```bash
sed '5,$d' input/text.txt
```

Here, `$` means the last line.

---

### 8. Print from line 4 to the end

```bash
sed -n '4,$p' input/text.txt
```

---

## Important Range Patterns

| Address | Meaning |
|---|---|
| `5` | Only line 5 |
| `2,6` | Lines 2 through 6 |
| `4,$` | Line 4 through the last line |
| `1,$` | Entire file |
| `$` | Last line |

---

## Common Commands

### Print range

```bash
sed -n 'START,ENDp' file.txt
```

### Delete range

```bash
sed 'START,ENDd' file.txt
```

### Substitute within range

```bash
sed 'START,ENDs/old/new/g' file.txt
```

### Modify one line

```bash
sed 'LINEs/old/new/' file.txt
```

---

## Important Difference

```bash
sed -n '3,6p' file.txt
```

prints only lines 3 through 6.

```bash
sed '3,6d' file.txt
```

prints every line except lines 3 through 6.

---

## What I Learned

- How to address individual lines.
- How to address continuous line ranges.
- How to print selected ranges.
- How to delete selected ranges.
- How to apply substitutions only to selected lines.
- How to use `$` as the address of the final line.
