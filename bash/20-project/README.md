# System Health Report

A Bash-based system health reporting tool that collects key system metrics and generates a readable report. The project combines Linux administration commands, text processing with `awk`, JSON parsing with `jq`, logging, and report generation.

---

## Features

- Collect hostname information
- Display current timestamp
- Show system uptime
- Display CPU load averages
- Show used and free memory
- Display root filesystem usage
- Detect the primary IPv4 address
- Read running services from a JSON file using `jq`
- Generate a formatted system health report
- Log successful execution using a reusable logging library

---

## Technologies

- Bash
- AWK
- JQ
- Linux CLI
- Here Documents
- Command Substitution
- Tee
- Logging Functions

---

## Project Structure

```
20-project/
├── config/
│   └── app.conf
├── input/
│   └── services.json
├── logs/
│   └── application.log
├── output/
│   └── system_report.txt
├── logging_library.sh
├── system_health.sh
└── README.md
```

---

## Example Output

```
==============================
      SYSTEM HEALTH REPORT
==============================

Timestamp:        2026-08-04 16:21:21
Hostname:         arista-lab

Uptime:
16:21:21 up 1:23, 2 users, load average: 0.19, 0.14, 0.12

CPU Load:
0.19, 0.14, 0.12

Memory Used:
449Mi

Memory Free:
2.1Gi

Disk Usage:
44%

IP Address:
192.168.64.2/24

Running Services:
nginx
postgres
api

==============================
```

---

## Skills Practiced

- Strict mode (`set -euo pipefail`)
- Bash variables
- Command substitution (`$(...)`)
- Here Documents (`<<EOF`)
- Functions
- Reusable logging library
- Parsing command output with `awk`
- Reading JSON with `jq`
- Working with Linux system commands
- Directory organization
- Report generation
- Logging

---

## Commands Used

- `hostname`
- `uptime`
- `free -h`
- `df -h`
- `ip -4 addr`
- `awk`
- `jq`
- `tee`
- `date`

---

## Learning Goals

This project combines the knowledge acquired throughout the Bash learning track into a single practical tool.

It demonstrates how Bash can automate common system administration tasks by collecting system information, processing command output, generating reports, and writing execution logs.

---

## Run

```bash
chmod +x system_health.sh
./system_health.sh
```

---

## Author

**Wojciech Furman**

Linux • Bash • DevOps • Automation
