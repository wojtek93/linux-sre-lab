# Docker Lab 17 — Security Scanning with Trivy

## Objective

Understand how to scan Docker images for known vulnerabilities and how to remediate security findings.

The main goal of this lab was to:

- scan container images with Trivy
- identify HIGH and CRITICAL vulnerabilities
- understand CVE findings
- compare vulnerable and updated images
- rebuild and rescan after remediation

---

## Trivy Installation

Trivy was installed on the system and verified with:

```bash
trivy --version
```

Trivy is a security scanner that can analyze container images for known vulnerabilities.

---

## Scan a Docker Image

Scan an nginx Alpine image:

```bash
trivy image nginx:alpine
```

The scan returned:

```text
Vulnerabilities: 0
```

This means no known vulnerabilities were detected in the scanned packages for this image.

---

## Filter by Severity

Instead of displaying all findings, Trivy can show only selected severity levels.

Scan nginx for HIGH and CRITICAL vulnerabilities:

```bash
trivy image --severity HIGH,CRITICAL nginx:alpine
```

Scan Python:

```bash
trivy image --severity HIGH,CRITICAL python:3.12-alpine
```

Both images returned no HIGH or CRITICAL findings during the lab.

---

## Trivy Output

Important columns in a Trivy vulnerability report include:

```text
Library
Vulnerability
Severity
Status
Installed Version
Fixed Version
Title
```

### Library

The package that contains the vulnerability.

### Vulnerability

The CVE identifier describing the known security issue.

Example:

```text
CVE-XXXX-XXXX
```

### Severity

The severity assigned to the vulnerability.

Common values include:

```text
LOW
MEDIUM
HIGH
CRITICAL
```

### Installed Version

The currently installed vulnerable version.

### Fixed Version

The version containing the security fix.

### Status

Indicates the current remediation state of the vulnerability.

---

## Vulnerable Image

A deliberately older image was created to generate useful security findings.

`Dockerfile.vulnerable`:

```dockerfile
FROM python:3.9-slim-bullseye

RUN pip install Flask==2.0.0

CMD ["python", "--version"]
```

Build the image:

```bash
docker build \
  -t vulnerable-app:v1 \
  -f Dockerfile.vulnerable .
```

Scan it:

```bash
trivy image --severity HIGH,CRITICAL vulnerable-app:v1
```

This time Trivy detected multiple HIGH and CRITICAL vulnerabilities.

---

## Why the Image Was Vulnerable

The image contained older components:

```text
old base image
+
old system packages
+
old application dependencies
```

These versions contained known vulnerabilities listed in vulnerability databases.

The basic flow was:

```text
old image
   ↓
known vulnerable packages
   ↓
Trivy scan
   ↓
HIGH / CRITICAL findings
```

---

## Remediation

A newer image was created.

`Dockerfile.fixed`:

```dockerfile
FROM python:3.12-slim

RUN pip install --no-cache-dir Flask

CMD ["python", "--version"]
```

Build the updated image:

```bash
docker build \
  -t vulnerable-app:v2 \
  -f Dockerfile.fixed .
```

Scan it again:

```bash
trivy image --severity HIGH,CRITICAL vulnerable-app:v2
```

The number of HIGH and CRITICAL vulnerabilities decreased.

This confirmed that updating the base image and dependencies reduced the security exposure.

---

## Security Remediation Workflow

The workflow used in this lab was:

```text
build image
    ↓
scan image
    ↓
identify findings
    ↓
check severity
    ↓
update base image / packages
    ↓
rebuild image
    ↓
rescan
```

This is a common container security workflow.

---

## Vulnerable vs Fixed Image

Version 1:

```text
python:3.9-slim-bullseye
Flask 2.0.0
        ↓
more HIGH / CRITICAL findings
```

Version 2:

```text
python:3.12-slim
current Flask version
        ↓
fewer HIGH / CRITICAL findings
```

The newer image had a smaller vulnerability footprint.

---

## Important Security Concept

A vulnerability scan does not automatically mean an image is unsafe to run.

A finding should be evaluated based on factors such as:

```text
severity
fixed version availability
whether the vulnerable component is actually used
exposure of the vulnerable functionality
exploitability
runtime environment
business risk
```

However, HIGH and CRITICAL findings should normally receive priority.

---

## Fixed Version

If Trivy reports:

```text
Installed Version: old-version
Fixed Version: newer-version
```

the normal remediation is to update the affected package or base image.

Example workflow:

```text
find vulnerable package
        ↓
identify fixed version
        ↓
update dependency
        ↓
rebuild image
        ↓
scan again
```

---

## No Fixed Version

Sometimes Trivy may report a vulnerability where no fixed version is currently available.

In that situation, possible actions include:

```text
assess actual exploitability
change the affected package
change the base image
reduce exposure
apply compensating controls
document the accepted risk
monitor for a future fix
```

Not every vulnerability can be immediately removed.

---

## Useful Commands

Check Trivy version:

```bash
trivy --version
```

Scan an image:

```bash
trivy image IMAGE
```

Show only HIGH and CRITICAL findings:

```bash
trivy image --severity HIGH,CRITICAL IMAGE
```

Scan nginx:

```bash
trivy image nginx:alpine
```

Scan Python:

```bash
trivy image python:3.12-alpine
```

Scan the vulnerable lab image:

```bash
trivy image --severity HIGH,CRITICAL vulnerable-app:v1
```

Scan the remediated image:

```bash
trivy image --severity HIGH,CRITICAL vulnerable-app:v2
```

---

## Key Concepts

Container images contain multiple layers of software:

```text
base OS
system packages
language runtime
application libraries
application code
```

Any of these components can contain known vulnerabilities.

A security scanner compares installed package versions against vulnerability databases.

The scanner then reports known CVEs.

The goal is not only to detect vulnerabilities, but also to reduce them through remediation.

---

## Why Image Scanning Matters

A Docker image may work correctly and still contain vulnerable software.

For example:

```text
application works
      ↓
container starts
      ↓
healthcheck passes
      ↓
but image contains vulnerable package
```

Functional correctness and security are separate concerns.

Security scanning should therefore be part of the container lifecycle.

---

## CI/CD Use Case

Image scanning can also be integrated into a CI/CD pipeline.

Example:

```text
git push
   ↓
build Docker image
   ↓
Trivy scan
   ↓
HIGH / CRITICAL findings?
   ↓
yes → fail pipeline
no  → continue deployment
```

This can prevent images with unacceptable vulnerabilities from reaching production.

---

## What I Learned

- Trivy can scan Docker images for known vulnerabilities
- container images can contain vulnerable OS and application packages
- `trivy image IMAGE` scans a container image
- `--severity HIGH,CRITICAL` filters important findings
- CVE identifiers represent known vulnerabilities
- `Installed Version` shows the currently affected version
- `Fixed Version` shows the version containing the fix
- older base images can contain more known vulnerabilities
- outdated application dependencies can increase security risk
- updating the base image can reduce vulnerabilities
- updating dependencies can reduce vulnerabilities
- images should be rescanned after remediation
- a successful application does not automatically mean a secure application
- some vulnerabilities may not yet have a fixed version
- findings should be evaluated based on severity and actual risk
- image scanning can be integrated into CI/CD pipelines
