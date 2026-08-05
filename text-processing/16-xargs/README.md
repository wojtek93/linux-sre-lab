# TEX-16 - xargs

## Objective

Learn how to use `xargs` to convert standard input into command-line arguments.

This lab focuses on:

- passing stdin as command arguments
- executing commands for multiple inputs
- using placeholders with `-I`
- automating repetitive shell operations
- integrating `xargs` with pipelines

---

## Project Structure

```text
16-xargs/
├── input/
│   ├── directories.txt
│   ├── files.txt
│   ├── processes.txt
│   ├── urls.txt
│   └── users.txt
├── README.md
└── notes.md
```

---

## Skills Practiced

- Read input from stdin
- Pass arguments to commands
- Use placeholders
- Execute repetitive commands
- Combine commands with pipelines

---

## Basic Syntax

### Pass input as command arguments

```bash
cat file.txt | xargs command
```

---

### Use a placeholder

```bash
cat file.txt | xargs -I {} command {}
```

---

### Example

Input:

```text
john
anna
mark
```

Command:

```bash
cat users.txt | xargs echo
```

Result:

```text
john anna mark
```

---

## Completed Tasks

### 1. Pass users to echo

```bash
cat input/users.txt | xargs echo
```

---

### 2. Pass file names to echo

```bash
cat input/files.txt | xargs echo
```

---

### 3. Create directories

```bash
cat input/directories.txt | xargs mkdir -p
```

---

### 4. Use placeholders

```bash
cat input/users.txt | xargs -I {} echo "User: {}"
```

Result:

```text
User: john
User: anna
User: mark
User: kate
User: tom
```

---

### 5. Simulate restarting services

```bash
cat input/processes.txt | xargs -I {} echo "systemctl restart {}"
```

Expected output:

```text
systemctl restart nginx
systemctl restart postgres
systemctl restart redis
systemctl restart grafana
systemctl restart prometheus
```

---

## Common Patterns

### Remove files

```bash
find . -name "*.log" | xargs rm
```

---

### Change permissions

```bash
find . -type f | xargs chmod 644
```

---

### Create directories

```bash
cat dirs.txt | xargs mkdir -p
```

---

### Restart services

```bash
cat services.txt | xargs -I {} systemctl restart {}
```

---

### Kubernetes example

```bash
kubectl get pods -o name | xargs kubectl delete
```

---

### Docker example

```bash
docker ps -q | xargs docker stop
```

---

## Important Options

| Option | Description |
|---|---|
| `-I {}` | Placeholder for each input item |
| `-n N` | Use N arguments per command |
| `-0` | Read null-separated input |

---

## What I Learned

- Convert stdin into command arguments.
- Execute commands for multiple values.
- Use placeholders with `-I`.
- Build automation pipelines.
- Combine `find`, `cat`, and other commands with `xargs`.
