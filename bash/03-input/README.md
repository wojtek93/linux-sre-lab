# Bash Lab 03 – Command-Line Argument Validation

## Objective

Create a Bash script that validates required command-line arguments.

The script expects two arguments:

1. Source file
2. Destination path

If the required arguments are missing, the script displays a usage message and exits with a non-zero status code.

---

## Project Structure

```text
03-input/
├── validate_args.sh
└── README.md
```

---

## Make the Script Executable

```bash
chmod +x validate_args.sh
```

---

## Usage

```bash
./validate_args.sh <source_file> <destination>
```

Example:

```bash
./validate_args.sh source.txt backup/
```

Expected output:

```text
Arguments validated successfully.
Source file: source.txt
Destination: backup/
```

---

## Missing Arguments

Running t[<72;98;47M[<72;98;47Mhe script without the required arguments:

```bash
./validate_args.sh
```

produces:

```text
Usage: validate_args.sh <source_file> <destination>
```

The script exits with status code `1`.

Check the exit status:

```bash
echo "$?"
```

Expected result:

```text
1
```

---

## Important Concepts

### Positional Parameters

Bash stores command-line arguments in positional parameters:

```bash
$1
$2
$3
```

In this script:

```text
$1 = source file
$2 = destination
```

---

### Argument Count

The special variable:

```bash
$#
```

contains the number of arguments passed to the script.

Example:

```bash
./validate_args.sh source.txt backup/
```

Here:

```text
$# = 2
```

---

### Validation Condition

```bash
if [[ $# -ne 2 ]]; then
```

Meaning:

- `[[ ... ]]` – Bash conditional expression
- `$#` – number of arguments
- `-ne` – not equal
- `2` – expected number of arguments

---

### Usage Message

```bash
echo "Usage: $(basename "$0") <source_file> <destination>"
```

`$0` contains the script path.

`basename "$0"` extracts only the script filename.

---

### Exit Status

```bash
exit 1
```

A non-zero exit status indicates that the script failed.

Conventionally:

```text
0 = success
non-zero = error
```

---

## Skills Practiced

- Command-line arguments
- Positional parameters
- Argument-count validation
- Conditional statements
- Usage messages
- Exit codes
- Safe variable quoting
