# TEX-17 - jq Filter

## Objective

Learn how to extract and filter data from JSON files using the `jq` command.

This lab focuses on:

- reading JSON documents
- selecting object fields
- iterating over JSON arrays
- filtering objects
- producing raw output
- processing structured API responses

---

## Project Structure

```text
17-jq-filter/
├── input/
│   ├── azure.json
│   ├── docker.json
│   ├── employees.json
│   ├── pods.json
│   └── servers.json
├── README.md
└── notes.md
```

---

## Skills Practiced

- Read JSON documents
- Iterate through JSON arrays
- Extract object properties
- Filter JSON objects
- Produce raw output
- Process structured API responses

---

## Basic Syntax

### Print the entire JSON document

```bash
jq '.' file.json
```

---

### Iterate through an array

```bash
jq '.[]' file.json
```

---

### Extract a field

```bash
jq '.[].name' file.json
```

---

### Filter objects

```bash
jq '.[] | select(.status=="Running")'
```

---

### Print raw strings

```bash
jq -r '.[].name'
```

---

## Completed Tasks

### 1. Print the entire JSON document

```bash
jq '.' input/employees.json
```

---

### 2. Print employee names

```bash
jq '.[].name' input/employees.json
```

---

### 3. Print employee salaries

```bash
jq '.[].salary' input/employees.json
```

---

### 4. Show employees from the IT department

```bash
jq '.[] | select(.department=="IT")' input/employees.json
```

---

### 5. Show only names of IT employees

```bash
jq -r '.[] | select(.department=="IT") | .name' input/employees.json
```

Expected output:

```text
John
Mark
Tom
```

---

### 6. Show running servers

```bash
jq -r '.[] | select(.status=="running") | .hostname' input/servers.json
```

Expected output:

```text
web01
web02
cache01
```

---

### 7. Show running Kubernetes pods

```bash
jq -r '.[] | select(.status=="Running") | .name' input/pods.json
```

Expected output:

```text
frontend
backend
monitoring
```

---

## Common Patterns

### Entire document

```bash
jq '.'
```

---

### Iterate through an array

```bash
jq '.[]'
```

---

### Select a field

```bash
jq '.[].field'
```

---

### Filter objects

```bash
jq '.[] | select(.field=="value")'
```

---

### Filter and extract

```bash
jq -r '.[] | select(.field=="value") | .name'
```

---

## Frequently Used Options

| Option | Description |
|---------|-------------|
| `-r` | Raw output (remove quotes) |
| `.` | Current JSON object |
| `[]` | Iterate through array |
| `select()` | Filter objects |

---

## Real-World Examples

### Kubernetes

```bash
kubectl get pods -o json | jq -r '.items[].metadata.name'
```

---

### Azure CLI

```bash
az vm list | jq -r '.[].name'
```

---

### Docker

```bash
docker inspect container | jq -r '.[0].Config.Image'
```

---

### REST API

```bash
curl https://api.example.com/users | jq '.[].email'
```

---

## What I Learned

- Read and format JSON documents.
- Iterate through JSON arrays.
- Extract object properties.
- Filter objects using `select()`.
- Produce raw output with `-r`.
- Build pipelines for processing JSON data returned by APIs.
