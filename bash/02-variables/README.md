# BAS-02 – Variables and Quoting

## Objective

Learn how variables work in Bash and understand the differences between:

- unquoted variables
- double quotes (`" "`)
- single quotes (`' '`)
- command-line arguments
- interactive user input

---

## Project Structure

```text
02-variables/
├── quote_demo.sh
└── README.md
```

---

## Make the Script Executable

```bash
chmod +x quote_demo.sh
```

---

## Run the Script

Run with command-line arguments:

```bash
./quote_demo.sh Wojtek Docker
```

Example output:

```text
First argument: Wojtek
Second argument: Docker
```

The script will also ask for user input:

```text
Enter your name:
Enter your favourite technology:
```

---

## Variables

Example:

```bash
NAME="Wojtek Furman"
```

Display variable:

```bash
echo "$NAME"
```

---

## Quoting

### No Quotes

```bash
echo $NAME
```

- Variable is expanded.
- Word splitting may occur.
- Wildcards (`*`) may be expanded.

---

### Double Quotes

```bash
echo "$NAME"
```

- Variable is expanded.
- Spaces are preserved.
- Wildcards are not expanded.

✅ Recommended for almost every Bash variable.

---

### Single Quotes

```bash
echo '$NAME'
```

- Variable is NOT expanded.
- Everything is treated literally.

Output:

```text
$NAME
```

---

## Wildcard Expansion

Example:

```bash
FILES="*"
```

Without quotes:

```bash
echo $FILES
```

The shell expands `*` to all files in the current directory.

Example:

```text
README.md
script.sh
notes.txt
```

With double quotes:

```bash
echo "$FILES"
```

Output:

```text
*
```

With single quotes:

```bash
echo '$FILES'
```

Output:

```text
$FILES
```

---

## Command-line Arguments

Bash stores command-line arguments in special variables.

```bash
$1
$2
$3
...
```

Example:

```bash
./quote_demo.sh Wojtek Docker
```

Results:

```text
$1 = Wojtek
$2 = Docker
```

---

## Interactive Input

The script also uses:

```bash
read -r -p "Enter your name: " USER_NAME
```

### Options

`-p`

Displays a prompt.

`-r`

Prevents backslashes from being interpreted as escape characters.

---

## Best Practice

Prefer:

```bash
"$VARIABLE"
```

instead of

```bash
$VARIABLE
```

Double quotes preserve spaces and prevent unexpected word splitting.

---

## Skills Practiced

- Variables
- Single quotes
- Double quotes
- Word splitting
- Wildcard expansion
- Command-line arguments
- Interactive input (`read -p`)
