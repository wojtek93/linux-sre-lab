# TP-01 - GREP Fundamentals

## Objective

Practice searching, filtering, counting, and locating text using `grep` across application logs, authentication logs, web logs, and CSV files.

## Project Structure

```text
01-grep/
├── input/
│   ├── application.log
│   ├── auth.log
│   ├── users.csv
│   └── web.log
├── README.md
└── notes.md
```

## Skills Practiced

- Case-insensitive search
- Line numbering
- Counting matches
- Inverted matching
- Recursive search
- Whole-word matching
- Extended regular expressions
- Anchors
- Escaping special regex characters
- Searching across multiple file types

## Useful Options

### Ignore case

```bash
grep -i "error" input/application.log
```

### Show line numbers

```bash
grep -n "ERROR" input/application.log
```

### Count matches

```bash
grep -c "WARNING" input/application.log
```

### Invert the match

```bash
grep -v "INFO" input/application.log
```

### Search recursively

```bash
grep -rn "admin" input/
```

### Match a whole word

```bash
grep -w "admin" input/auth.log
```

### Use extended regular expressions

```bash
grep -E "401|403|500" input/web.log
```

## Example Tasks

### Find errors case-insensitively with line numbers

```bash
grep -in "ERROR" input/application.log
```

### Count warning entries

```bash
grep -c "WARNING" input/application.log
```

### Display entries without INFO

```bash
grep -iv "INFO" input/application.log
```

### Search recursively for admin-related entries

```bash
grep -rwn "admin" input/
```

### Find failed password attempts

```bash
grep -rn "Failed password" input/
```

### Find HTTP 500 entries

```bash
grep -rn "500" input/
```

### Find HTTP error codes

```bash
grep -E "401|403|500" input/web.log
```

### Find lines starting with 192.168

```bash
grep -r "^192\.168" input/
```

### Find IT department records

```bash
grep -rw "IT" input/
```

### Count password entries

```bash
grep -irc "password" input/
```

## Key Concepts

### `-w`

Matches a complete word rather than part of a larger word.

```bash
grep -w "admin" file.txt
```

Matches:

```text
admin
user admin logged in
```

Does not match:

```text
administrator
myadmin
admin123
```

### `-r`

Searches recursively through a directory.

```bash
grep -rn "ERROR" input/
```

This is appropriate when the exact file containing the data is unknown.

### `-E`

Enables extended regular expressions.

```bash
grep -E "401|403|500" input/web.log
```

The `|` operator means logical OR.

### Regex anchors

```text
^pattern
```

Matches the beginning of a line.

```text
pattern$
```

Matches the end of a line.

### Escaping dots

A dot in regex means any character.

To match a literal dot, escape it:

```bash
grep "^192\.168" input/web.log
```

## What I Learned

- How to search logs efficiently using `grep`.
- How to ignore case and display line numbers.
- How to count matching entries.
- How to exclude matching lines.
- How recursive search differs from searching a specific file.
- How whole-word matching works.
- How to use extended regular expressions.
- Why special regex characters such as `.` must sometimes be escaped.
- How to choose `grep` options based on whether the target file is known.
