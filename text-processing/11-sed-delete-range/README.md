# TEX-11 - sed Delete

## Objective

Learn how to remove lines from text files using `sed`.

This lab focuses on:

- deleting matching lines
- deleting empty lines
- deleting comments
- deleting multiple patterns
- deleting specific lines

---

## Project Structure

```text
11-sed-delete/
├── input/
│   ├── config.conf
│   ├── script.sh
│   └── system.log
├── README.md
└── notes.md
```

---

## Skills Practiced

- Delete matching lines
- Delete empty lines
- Delete comments
- Delete multiple patterns
- Delete specific lines

---

## New Syntax

### Delete Matching Lines

```bash
sed '/pattern/d'
```

---

### Delete Empty Lines

```bash
sed '/^$/d'
```

---

### Delete Comment Lines

```bash
sed '/^#/d'
```

---

### Delete Specific Line

```bash
sed '5d'
```

---

### Multiple Delete Commands

```bash
sed '/INFO/d;/WARNING/d'
```

or

```bash
sed -e '/INFO/d' -e '/WARNING/d'
```

---

## Completed Tasks

### Remove empty lines and comments

```bash
sed -e '/^$/d' -e '/^#/d' input/config.conf
```

---

### Remove comments but keep shebang

```bash
sed '/^# /d' input/script.sh
```

---

### Remove INFO and WARNING messages

```bash
sed '/INFO/d;/WARNING/d' input/system.log
```

---

## Frequently Used Commands

### Delete by pattern

```bash
sed '/ERROR/d'
```

---

### Delete empty lines

```bash
sed '/^$/d'
```

---

### Delete comments

```bash
sed '/^#/d'
```

---

### Delete specific line

```bash
sed '5d'
```

---

### Execute multiple delete operations

```bash
sed '/foo/d;/bar/d'
```

---

## Important Regex

| Pattern | Meaning |
|----------|---------|
| `^` | Beginning of line |
| `$` | End of line |
| `^#` | Line starts with `#` |
| `^$` | Empty line |

---

## sed Delete Cheat Sheet

| Command | Description |
|----------|-------------|
| `d` | Delete line |
| `/pattern/d` | Delete matching lines |
| `5d` | Delete line 5 |
| `^#` | Comment line |
| `^$` | Empty line |

---

## What I Learned

- Delete matching lines.
- Remove comments.
- Remove empty lines.
- Delete specific lines.
- Execute multiple delete commands in a single `sed` invocation.
