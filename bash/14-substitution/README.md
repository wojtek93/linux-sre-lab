# BAS-14 - Command Substitution and Parameter Expansion

## Objective

Learn how to use command substitution and Bash parameter expansion to manipulate strings efficiently without unnecessary external commands.

## Skills Practiced

- Command substitution (`$(...)`)
- Parameter expansion
- String length
- Prefix and suffix removal
- Uppercase and lowercase conversion
- Default values
- Variable assignment
- String replacement
- Bash optimization

## Files

```
examples.sh
parameter_expansion.md
```

## Run

```bash
chmod +x examples.sh

./examples.sh
```

## Topics Covered

### Command Substitution

```bash
current_date=$(date +%F)
```

Capture the output of a command and store it in a variable.

---

### Remove Suffix

```bash
${filename%.gz}
${filename%.*}
${filename%%.*}
```

---

### Remove Prefix

```bash
${path#/home/user/}
${path##*/}
```

---

### String Length

```bash
${#text}
```

---

### Case Conversion

```bash
${text^^}
${text,,}
```

---

### Default Values

```bash
${variable:-default}
${variable:=default}
```

---

### String Replacement

```bash
${text/old/new}
${text//old/new}
```

## What I Learned

- How to capture command output using `$(...)`.
- How to manipulate strings using Bash parameter expansion.
- How to remove prefixes and suffixes without external tools.
- How to convert text to uppercase and lowercase.
- How to use default values for variables.
- How to replace text inside variables.
- How to avoid unnecessary subprocesses by using built-in Bash features instead of tools like `cut`, `sed`, `awk`, or `tr` for simple string operations.
