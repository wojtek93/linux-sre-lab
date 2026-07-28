# Bash Lab 06 – Functions

## Objective

Refactor a Bash script into reusable functions.

The script should:

- validate input arguments,
- verify that the provided log file exists,
- count INFO, WARNING and ERROR entries,
- print a formatted report.

---

## Project Structure

```
06-functions/
├── before.sh
├── after.sh
├── README.md
└── logs/
    ├── app.log
    └── nginx.log
```

---

## Usage

```bash
./after.sh logs/app.log
```

or

```bash
bash after.sh logs/nginx.log
```

---

## Example Output

```
------------------------
File: app.log
------------------------

INFO:    15
WARNING: 3
ERROR:   2

Total entries: 20
```

---

## Concepts Practiced

- Bash functions
- Function arguments
- Local variables
- Returning values with `echo`
- Reading command output using `read`
- Variable scope
- Reusable code
