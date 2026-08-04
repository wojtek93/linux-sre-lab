# TP-04 - tr

## Objective

Practice transforming, deleting, filtering, and compressing characters using the `tr` command.

## Project Structure

```text
04-tr/
├── input/
│   ├── numbers.txt
│   ├── spaces.txt
│   ├── text.txt
│   └── users.txt
├── README.md
└── notes.md
```

## Skills Practiced

- Converting lowercase letters to uppercase
- Converting uppercase letters to lowercase
- Replacing delimiters
- Deleting characters
- Keeping only selected characters
- Replacing spaces with new lines
- Compressing repeated characters
- Working with character classes
- Reading input from standard input

## Useful Syntax

### Convert lowercase to uppercase

```bash
tr '[:lower:]' '[:upper:]' < input/text.txt
```

### Convert uppercase to lowercase

```bash
tr '[:upper:]' '[:lower:]' < input/text.txt
```

### Replace characters

```bash
tr ';' ',' < input/users.txt
```

### Delete characters

```bash
tr -d '0-9' < input/numbers.txt
```

### Keep only selected characters

```bash
tr -cd '0-9\n' < input/numbers.txt
```

### Compress repeated characters

```bash
tr -s ' ' < input/spaces.txt
```

## Completed Tasks

### 1. Convert all lowercase letters to uppercase

```bash
tr '[:lower:]' '[:upper:]' < input/text.txt
```

### 2. Convert all uppercase letters to lowercase

```bash
tr '[:upper:]' '[:lower:]' < input/text.txt
```

### 3. Replace semicolons with commas

```bash
tr ';' ',' < input/users.txt
```

### 4. Remove all digits

```bash
tr -d '0-9' < input/numbers.txt
```

### 5. Remove lowercase vowels

```bash
tr -d 'aeiou' < input/text.txt
```

To remove vowels regardless of case:

```bash
tr -d 'aeiouAEIOU' < input/text.txt
```

### 6. Replace spaces with new lines

```bash
tr ' ' '\n' < input/text.txt
```

### 7. Display only digits

```bash
tr -cd '0-9\n' < input/numbers.txt
```

The newline character is included so that lines remain separate.

### 8. Compress multiple spaces into one

```bash
tr -s ' ' < input/spaces.txt
```

### 9. Replace lowercase letters with `*`

```bash
tr '[:lower:]' '*' < input/text.txt
```

### 10. Convert semicolon-separated users into separate lines

```bash
tr ';' '\n' < input/users.txt
```

## Key Options

### `-d`

Delete the specified characters.

```bash
tr -d '0-9'
```

### `-c`

Use the complement of the specified character set.

```bash
tr -cd '0-9\n'
```

This means:

> delete everything except digits and newline characters.

### `-s`

Squeeze repeated occurrences of a character into one.

```bash
tr -s ' '
```

### Character classes

```bash
[:lower:]
[:upper:]
[:digit:]
[:space:]
```

Example:

```bash
tr '[:lower:]' '[:upper:]'
```

## Important Difference

`grep` uses regular-expression character classes:

```regex
[0-9]
```

`tr` uses character ranges:

```text
0-9
```

For example:

```bash
grep -E '[0-9]' file.txt
```

but:

```bash
tr -d '0-9' < file.txt
```

## What I Learned

- How `tr` processes character sets rather than full regular expressions.
- How to replace one group of characters with another.
- How to delete selected characters.
- How complement mode keeps only selected characters.
- Why newlines must sometimes be explicitly preserved.
- How to normalize repeated spaces.
- How to transform delimited data into line-based output.
- How standard input redirection works with `tr`.
