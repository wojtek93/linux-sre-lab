# Bash Lab 01 – Basics

## Objective

The goal of this lab is to create a simple Bash script that prints selected environment information.

This exercise introduces:

- shebang
- executable scripts
- environment variables
- command substitution

---

## Project Structure

```
01-basics/
├── hello_env.sh
└── README.md
```

---

## Script Features

The script prints:

- current user
- home directory
- current working directory
- hostname
- default shell

Example output:

```text
Hello wojtek!

User: wojtek
Home: /home/wojtek
Current directory: /home/wojtek/Projects/linux-sre-lab/bash/01-basics
Hostname: arista-lab
Shell: /bin/bash
```

---

## Concepts Learned

### Shebang

```bash
#!/usr/bin/env bash
```

Tells the operating system to execute the script using Bash.

---

### Environment Variables

| Variable | Description |
|----------|-------------|
| `$USER` | Current user |
| `$HOME` | User home directory |
| `$PWD` | Current working directory |
| `$SHELL` | Default shell |

---

### Command Substitution

```bash
$(hostname)
```

Executes a command and inserts its output into another command.

---

## Make Script Executable

```bash
chmod +x hello_env.sh
```

Run the script:

```bash
./hello_env.sh
```

---

## Skills Practiced

- Creating executable Bash scripts
- Using environment variables
- Command substitution
- Basic terminal output formatting
