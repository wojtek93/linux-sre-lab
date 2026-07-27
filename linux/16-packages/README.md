# Linux Lab 16 – Package Management

## Goal

Learn how package management works on Ubuntu using APT and DPKG.

The objective of this lab was to understand how to search, install, update, remove, and inspect software packages.

---

## Package Managers

Ubuntu uses:

- **APT** – high-level package manager
- **DPKG** – low-level package manager for `.deb` packages

---

## Update Package Index

Refresh package information:

```bash
sudo apt update
```

Downloads the latest package index from configured repositories.

---

## Upgrade Packages

Install available updates:

```bash
sudo apt upgrade
```

Updates installed packages to newer versions.

---

## Install a Package

```bash
sudo apt install tree
```

Verify installation:

```bash
which tree
tree
```

---

## Search Packages

```bash
apt search nginx
```

---

## Show Package Information

```bash
apt show nginx
```

Displays:

- version
- description
- dependencies
- maintainer
- installed size

---

## Remove Packages

Remove package:

```bash
sudo apt remove tree
```

Remove package and configuration:

```bash
sudo apt purge tree
```

---

## Remove Unused Dependencies

```bash
sudo apt autoremove
```

---

## Package Information

Find which package installed a file:

```bash
dpkg -S /usr/bin/ssh
```

Example output:

```text
openssh-client: /usr/bin/ssh
```

---

List files installed by a package:

```bash
dpkg -L openssh-client
```

---

## Package Version

```bash
apt policy tree
```

Shows:

- installed version
- candidate version
- repository

---

## Useful Commands

```bash
apt update
apt upgrade
apt install
apt remove
apt purge
apt autoremove
apt search
apt show

dpkg -S
dpkg -L
```

---

## Interview Notes

Frequently asked questions:

- Difference between `apt update` and `apt upgrade`
- Difference between `apt remove` and `apt purge`
- How to find which package installed a file
- How to list files belonging to a package

---

## Skills Practiced

- Package installation
- Package removal
- Package updates
- Package search
- Package inspection
- Understanding dependencies
- Basic Linux package management
