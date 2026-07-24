# LIN-03 - Linux Permissions

## Objective

Learn how Linux permissions work and understand:

- chmod
- chown
- chgrp
- umask
- setuid
- setgid
- sticky bit

The goal is not only to memorize commands, but to understand when and why they are used.

---

# Permission Model

Every Linux file has three permission classes:

- User (Owner)
- Group
- Others

Example:

```text
-rwxr-xr--
```

Breakdown:

```text
- | rwx | r-x | r--
```

| Section | Description |
|----------|-------------|
| User | File owner permissions |
| Group | Users belonging to the file group |
| Others | Everyone else |

---

# Permission Values

| Permission | Value |
|------------|------:|
| Read | 4 |
| Write | 2 |
| Execute | 1 |

Examples

```text
7 = rwx
6 = rw-
5 = r-x
4 = r--
0 = ---
```

---

# chmod

Change permissions.

Examples

```bash
chmod 755 script.sh
chmod 644 file.txt

chmod u+x script.sh
chmod g+w file.txt
chmod o-r file.txt
```

---

# chown

Change file owner.

```bash
sudo chown alice file.txt
sudo chown alice:developers file.txt
```

---

# chgrp

Change group ownership.

```bash
sudo chgrp developers project
```

---

# umask

`umask` removes permissions from newly created files and directories.

Default permissions:

Files

```text
666
```

Directories

```text
777
```

Example

```bash
umask 022
```

New permissions

```text
File      -> 644
Directory -> 755
```

Example

```bash
umask 077
```

New permissions

```text
File      -> 600
Directory -> 700
```

Important

- affects only newly created files
- does not modify existing files
- removes permissions instead of adding them

---

# setuid

Runs an executable with the permissions of the file owner.

Example

```bash
chmod u+s program
```

Numeric form

```bash
chmod 4755 program
```

Example

```text
-rwsr-xr-x
```

Typical example

```text
/usr/bin/passwd
```

A regular user cannot modify

```text
/etc/shadow
```

because it belongs to root.

The `passwd` executable has the setuid bit, so it temporarily runs with root privileges and can safely update password information.

Important

The user does **not** become root.

Only the executable runs with the file owner's effective permissions.

---

# setgid

When set on a directory, every newly created file inherits the directory's group.

Enable

```bash
chmod g+s project
```

or

```bash
chmod 2775 project
```

Directory

```text
drwxrwsr-x
```

---

## Practical Example

Create a shared group

```bash
sudo groupadd developers
```

Create users

```bash
sudo useradd -m alice
sudo passwd alice

sudo usermod -aG developers alice
```

Create shared directory

```bash
sudo mkdir /shared
sudo chgrp developers /shared
sudo chmod 2775 /shared
```

Verify

```bash
ls -ld /shared
```

Output

```text
drwxrwsr-x
```

Login as Alice

```bash
su - alice
```

Create a file

```bash
touch /shared/alice.txt
```

Check ownership

```bash
ls -l /shared
```

Output

```text
-rw-r--r-- alice developers alice.txt
```

Although Alice's primary group is:

```text
alice
```

the new file inherits

```text
developers
```

because the directory has the **setgid** bit enabled.

Without setgid

```text
alice.txt

owner: alice
group: alice
```

With setgid

```text
alice.txt

owner: alice
group: developers
```

This is commonly used for shared project directories.

---

# Sticky Bit

Sticky bit protects files inside shared writable directories.

Enable

```bash
chmod +t shared
```

or

```bash
chmod 1777 shared
```

Example

```text
drwxrwxrwt
```

Common example

```text
/tmp
```

Everyone can create files.

Only the following can remove a file:

- file owner
- directory owner
- root

---

# Numeric Special Bits

| Bit | Numeric |
|------|--------:|
| setuid | 4xxx |
| setgid | 2xxx |
| sticky bit | 1xxx |

Examples

```text
4755
2775
1777
```

---

# Useful Commands

Permissions

```bash
ls -l
ls -ld directory
stat file
```

Ownership

```bash
id
groups
whoami
```

Umask

```bash
umask
```

Find setuid files

```bash
find / -perm -4000 -type f 2>/dev/null
```

Find setgid files

```bash
find / -perm -2000 -type f 2>/dev/null
```

Find sticky directories

```bash
find / -perm -1000 -type d 2>/dev/null
```

---

# Interview Questions

### What is chmod?

Changes file or directory permissions.

---

### What is chown?

Changes file ownership.

---

### What is chgrp?

Changes group ownership.

---

### What is umask?

Removes permissions from newly created files and directories.

---

### What does setuid do?

Runs an executable with the effective permissions of the file owner.

---

### What does setgid do?

When enabled on a directory, all new files inherit the directory's group.

---

### What is Sticky Bit?

Allows everyone to create files but only the owner (or root) can delete them.

---

# Key Takeaways

- Linux permissions are divided into owner, group and others.
- chmod changes permissions.
- chown changes owner.
- chgrp changes group ownership.
- umask removes default permissions for newly created files.
- setuid allows a program to run with the owner's privileges.
- setgid ensures new files inherit the directory group.
- sticky bit protects files in shared writable directories.
- Always follow the principle of least privilege.

## Automated Lab Setup

The lab can be created automatically with:

```bash
./scripts/setup_setgid_lab.sh
```

Verification commands:

```bash
ls -ld /shared
id alice
getent group developers
```

The `/shared` directory should have the setgid bit enabled:

```text
drwxrwsr-x
```

Files created inside the directory should inherit the `developers` group.