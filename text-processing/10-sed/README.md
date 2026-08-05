# TP-10 - Stream Editor (sed)

## Objective

Learn how to use the Linux Stream Editor (`sed`) for editing and transforming text streams.

This lab focuses on:

- text substitution
- deleting lines
- printing selected lines
- line addressing
- editing files
- regular expressions

---

## Project Structure

```text
10-sed/
├── input/
│   ├── config.conf
│   ├── log.txt
│   ├── text.txt
│   └── users.txt
├── README.md
└── notes.md
```

---

## Skills Practiced

- Substitute text
- Delete lines
- Print matching lines
- Line ranges
- Regex matching
- In-place editing
- Stream processing

---

## New Syntax

### Substitute

```bash
sed 's/old/new/'
```

Replace the first occurrence.

---

### Global Substitute

```bash
sed 's/old/new/g'
```

Replace every occurrence.

---

### Delete Matching Lines

```bash
sed '/pattern/d'
```

---

### Delete Line by Number

```bash
sed '5d'
```

---

### Delete Range

```bash
sed '2,6d'
```

---

### Print Matching Lines

```bash
sed -n '/pattern/p'
```

---

### Substitute and Print

```bash
sed -n 's/old/new/p'
```

---

### Edit File In Place

```bash
sed -i 's/old/new/g' file.txt
```

---

## Completed Tasks

### Replace delimiters

```bash
sed 's/;/,/g' input/users.txt
```

---

### Replace "host" with "server"

```bash
sed 's/^host/server/' input/config.conf
```

---

### Replace port number

```bash
sed 's/8080/9090/' input/config.conf
```

---

### Disable debug

```bash
sed 's/debug=true/debug=false/' input/config.conf
```

---

### Remove INFO lines

```bash
sed '/INFO/d' input/log.txt
```

---

### Delete second line

```bash
sed '2d' input/log.txt
```

---

### Delete line range

```bash
sed '2,4d' input/log.txt
```

---

### Print ERROR lines only

```bash
sed -n '/ERROR/p' input/log.txt
```

---

### Replace all lowercase 'a'

```bash
sed 's/a/A/g' input/text.txt
```

---

### Replace ERROR with FAIL and print matching lines

```bash
sed -n 's/ERROR/FAIL/p' input/log.txt
```

---

## Frequently Used Commands

### Replace first occurrence

```bash
sed 's/foo/bar/'
```

---

### Replace all occurrences

```bash
sed 's/foo/bar/g'
```

---

### Delete matching lines

```bash
sed '/foo/d'
```

---

### Delete specific line

```bash
sed '3d'
```

---

### Delete line range

```bash
sed '3,8d'
```

---

### Print matching lines

```bash
sed -n '/foo/p'
```

---

### Edit file directly

```bash
sed -i 's/foo/bar/g' file.txt
```

---

## Important Regex

| Pattern | Meaning |
|----------|---------|
| ^ | Beginning of line |
| $ | End of line |
| . | Any character |
| * | Zero or more |
| [0-9] | Digit |
| [a-z] | Lowercase letters |
| [A-Z] | Uppercase letters |
| ^$ | Empty line |

---

## sed Cheat Sheet

| Command | Description |
|----------|-------------|
| s | Substitute |
| d | Delete |
| p | Print |
| -n | Disable automatic output |
| -i | Modify file directly |
| g | Replace all occurrences |

---

## What I Learned

- Replace text using `s///`.
- Replace all occurrences using the `g` flag.
- Delete matching lines.
- Delete specific lines and ranges.
- Print only matching lines.
- Use regular expressions with `sed`.
- Edit files in place.
- Combine substitution with selective printing.
