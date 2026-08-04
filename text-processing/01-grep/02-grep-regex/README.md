# TP-02 - GREP and Regular Expressions

## Objective

Practice using `grep` with regular expressions to match line beginnings, line endings, whole words, alternatives, character classes, and escaped special characters.

## Project Structure

```text
02-grep-regex/
├── input/
│   ├── access.log
│   ├── config.conf
│   ├── emails.txt
│   └── users.txt
├── README.md
└── notes.md
```

## Skills Practiced

- Extended regular expressions with `grep -E`
- Beginning-of-line anchor `^`
- End-of-line anchor `$`
- Whole-word matching with `-w`
- Inverted matching with `-v`
- Character classes such as `[0-9]`
- Regex alternation with `|`
- Escaping literal dots with `\.`
- Writing precise patterns
- Filtering configuration files and logs

## Useful Patterns

### Lines beginning with a value

```bash
grep -E '^john' input/users.txt
```

### Lines ending with a value

```bash
grep -E '\.com$' input/emails.txt
```

### Literal dots

A dot in regex means any character.

To match a real dot:

```bash
\.
```

Example:

```bash
grep -E '^192\.168' input/access.log
```

### Whole-word matching

```bash
grep -w 'admin' input/users.txt
```

### Exclude matching lines

```bash
grep -v '^#' input/config.conf
```

To exclude comments and empty lines:

```bash
grep -Ev '^#|^$' input/config.conf
```

### Regex OR

```bash
grep -E '401|403|500' input/access.log
```

A more precise version:

```bash
grep -E ' (401|403|500)$' input/access.log
```

### Character classes

Find lines ending in a digit:

```bash
grep -E '[0-9]$' input/users.txt
```

### Match an exact configuration key

```bash
grep '^host=' input/config.conf
```

This avoids matching:

```text
api_host=api-server
```

## Completed Tasks

### 1. Find usernames beginning with `john`

```bash
grep -E '^john' input/users.txt
```

### 2. Find email addresses ending with `.com`

```bash
grep -E '\.com$' input/emails.txt
```

### 3. Find IP addresses beginning with `192.168`

```bash
grep -E '^192\.168' input/access.log
```

### 4. Match the whole word `admin`

```bash
grep -w 'admin' input/users.txt
```

### 5. Display configuration lines without comments

```bash
grep -v '^#' input/config.conf
```

More precise:

```bash
grep -Ev '^#|^$' input/config.conf
```

### 6. Find HTTP status codes 401, 403, or 500

```bash
grep -E '401|403|500' input/access.log
```

### 7. Find email addresses from `example.com`

```bash
grep -iE '@example\.com$' input/emails.txt
```

### 8. Find usernames ending in a digit

```bash
grep -E '[0-9]$' input/users.txt
```

### 9. Find usernames containing an underscore

```bash
grep '_' input/users.txt
```

### 10. Find only the `host` configuration key

```bash
grep '^host=' input/config.conf
```

## Key Concepts

### `^`

Matches the beginning of a line.

```regex
^john
```

### `$`

Matches the end of a line.

```regex
\.com$
```

### `|`

Means logical OR when extended regex is enabled with `-E`.

```regex
401|403|500
```

### `[0-9]`

Matches one digit.

```regex
[0-9]$
```

### `\.`

Matches a literal dot.

```regex
192\.168
```

## What I Learned

- How anchors make searches more precise.
- Why dots must be escaped in regular expressions.
- How to use extended regex alternation.
- How whole-word matching differs from substring matching.
- How to filter comments and blank lines from configuration files.
- Why matching a full configuration key is safer than searching for a partial word.
