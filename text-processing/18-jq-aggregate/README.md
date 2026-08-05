# TEX-18 - jq Aggregate

## Objective

Learn how to aggregate, transform and analyze JSON data using `jq`.

This lab focuses on:

- counting JSON objects
- transforming arrays
- calculating sums
- finding minimum and maximum values
- preparing JSON data for further processing

---

## Project Structure

```text
18-jq-aggregate/
├── input/
│   ├── employees.json
│   ├── pods.json
│   ├── projects.json
│   └── servers.json
├── README.md
└── notes.md
```

---

## Skills Practiced

- Count JSON objects
- Transform JSON arrays
- Aggregate numeric values
- Find minimum and maximum objects
- Analyze structured API responses

---

## Basic Syntax

### Count elements

```bash
jq 'length' file.json
```

---

### Transform an array

```bash
jq 'map(.field)' file.json
```

---

### Sum numeric values

```bash
jq 'map(.field) | add' file.json
```

---

### Find the largest object

```bash
jq 'max_by(.field)' file.json
```

---

### Find the smallest object

```bash
jq 'min_by(.field)' file.json
```

---

## Completed Tasks

### 1. Count employees

```bash
jq 'length' input/employees.json
```

Result:

```text
5
```

---

### 2. Count Kubernetes pods

```bash
jq 'length' input/pods.json
```

Result:

```text
5
```

---

### 3. Create an array of employee names

```bash
jq 'map(.name)' input/employees.json
```

Result:

```json
[
  "John",
  "Anna",
  "Mark",
  "Kate",
  "Tom"
]
```

---

### 4. Calculate total salaries

```bash
jq 'map(.salary) | add' input/employees.json
```

Result:

```text
39400
```

---

### 5. Find the employee with the highest salary

```bash
jq 'max_by(.salary)' input/employees.json
```

Result:

```json
{
  "id": 103,
  "name": "Mark",
  "department": "IT",
  "salary": 9500
}
```

---

### 6. Find the server with the lowest CPU usage

```bash
jq 'min_by(.cpu)' input/servers.json
```

Result:

```json
{
  "hostname": "cache01",
  "environment": "development",
  "cpu": 21
}
```

---

## Common Patterns

### Count elements

```bash
jq 'length'
```

---

### Transform arrays

```bash
jq 'map(.field)'
```

---

### Sum values

```bash
jq 'map(.value) | add'
```

---

### Largest object

```bash
jq 'max_by(.field)'
```

---

### Smallest object

```bash
jq 'min_by(.field)'
```

---

## Real-World Examples

### Count Kubernetes Pods

```bash
kubectl get pods -o json | jq '.items | length'
```

---

### Total CPU Requests

```bash
kubectl get pods -o json \
| jq '[.items[].spec.containers[].resources.requests.cpu] | add'
```

---

### Largest Virtual Machine

```bash
az vm list | jq 'max_by(.hardwareProfile.vmSize)'
```

---

### Largest Docker Image

```bash
docker images --format json | jq 'max_by(.Size)'
```

---

## Frequently Used Aggregate Functions

| Function | Description |
|----------|-------------|
| `length` | Count array elements |
| `map()` | Transform every element |
| `add` | Sum numeric values |
| `max_by()` | Largest object by field |
| `min_by()` | Smallest object by field |

---

## What I Learned

- Count JSON array elements.
- Transform arrays using `map()`.
- Aggregate numeric values using `add`.
- Find maximum and minimum objects.
- Build analytical queries against JSON returned by APIs.
