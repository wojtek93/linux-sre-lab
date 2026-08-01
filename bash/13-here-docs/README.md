# BAS-13 - Here Documents

## Objective

Learn how to use Bash here-documents to generate configuration files in a simple and readable way.

## Skills Practiced

- Here documents (`<<EOF`)
- Variable expansion
- Literal here documents (`<<'EOF'`)
- File generation
- Output redirection
- Bash best practices
- `set -euo pipefail`

## Files

```
generate_config.sh
output/app.conf
```

## Run

```bash
chmod +x generate_config.sh

./generate_config.sh
```

## Generated Configuration

```ini
APP_NAME=LinuxSRE
VERSION=1.0
ENVIRONMENT=development
PORT=8080
LOG_LEVEL=INFO
```

## Key Concepts

### Variable Expansion

```bash
cat <<EOF
APP_NAME=$app_name
EOF
```

Variables are expanded before being written to the file.

### Literal Here Document

```bash
cat <<'EOF'
APP_NAME=$app_name
EOF
```

Variables are written literally without expansion.

## What I Learned

- How to generate configuration files using here-documents.
- The difference between `<<EOF` and `<<'EOF'`.
- How variable expansion works inside a here-document.
- How to redirect multi-line output into a file.
- Why here-documents are commonly used to generate configuration files such as `.env`, `.conf`, `.yaml`, and `.ini`.
