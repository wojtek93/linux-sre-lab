# MOT-14 — Permissions and Ownership

## Goal

Understand Linux permissions, ownership, groups, setgid and least privilege, and troubleshoot `Permission denied` problems.

## Basic permissions

```text
r = read    = 4
w = write   = 2
x = execute = 1
```

Example:

```text
-rwxr-x---
```

means:

```text
owner  → rwx → 7
group  → r-x → 5
others → --- → 0
```

Equivalent:

```bash
chmod 750 file
```

## Ownership

Change owner:

```bash
sudo chown wojtek file
```

Change owner and group:

```bash
sudo chown wojtek:developers file
```

Change only group:

```bash
sudo chgrp developers file
```

## Directory permissions

For directories:

```text
r → list names inside directory
w → create/delete entries
x → traverse/access directory
```

A missing `x` on any parent directory can cause:

```text
Permission denied
```

Useful troubleshooting command:

```bash
namei -l /path/to/file
```

## Setgid on directories

Enable setgid:

```bash
chmod g+s shared/
```

or:

```bash
chmod 2770 shared/
```

Disable:

```bash
chmod g-s shared/
```

With setgid enabled, new files and subdirectories inherit the directory's group.

```text
2xxx → setgid
```

## Users and groups

List groups:

```bash
getent group
```

Check user's groups:

```bash
groups wojtek
id wojtek
```

Create group:

```bash
sudo groupadd developers
```

Delete group:

```bash
sudo groupdel developers
```

Add user to supplementary group:

```bash
sudo usermod -aG developers wojtek
```

Remove user from group:

```bash
sudo gpasswd -d wojtek developers
```

Remember:

```text
groupadd → create group
groupdel → delete group
usermod -aG → add user to additional group
gpasswd -d → remove user from group
getent group → query groups
```

## Least privilege

Avoid unnecessary permissions such as:

```text
777
```

Example executable:

```bash
sudo chown root:developers deploy.sh
chmod 750 deploy.sh
```

Result:

```text
root       → rwx
developers → r-x
others     → ---
```

Sensitive file example:

```bash
chmod 600 secret.conf
```

Result:

```text
owner  → rw-
group  → ---
others → ---
```

## Permission denied troubleshooting

```text
Permission denied
        ↓
ls -l file
ls -ld directory
        ↓
id
        ↓
check owner/group
        ↓
check r/w/x permissions
        ↓
check parent directories
        ↓
namei -l /full/path
        ↓
apply least-privilege fix
        ↓
verify
```

## Interview summary

When troubleshooting a permission issue, I first check the ownership and permissions with `ls -l` or `ls -ld`. Then I use `id` to verify the user's group membership. For directory access I also check execute permission because `x` is required to traverse a directory. If the path contains multiple directories, I can use `namei -l` to identify which component blocks access. I then apply the minimum required permission or ownership change instead of using overly permissive settings such as `777`.
