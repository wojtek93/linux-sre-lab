# Linux Lab 15 – SSH Key Authentication

## Goal

Configure SSH key authentication between a macOS client and an Ubuntu virtual machine.

The objective of this lab was to understand how public/private key authentication works, configure passwordless SSH login, and review the most important SSH configuration files.

---

## Environment

Client:
- macOS

Server:
- Ubuntu 24.04 LTS
- IP: `192.168.64.2`

---

## Tasks completed

- Generated an ED25519 SSH key pair.
- Copied the public key to the Ubuntu VM.
- Configured passwordless SSH authentication.
- Created an SSH client alias.
- Verified authentication using verbose mode.
- Reviewed SSH client and server configuration files.

---

## Generate SSH key pair

```bash
ssh-keygen -t ed25519 -C "wojciechfurman93@gmail.com"
```

Files created:

```
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub
```

- `id_ed25519` → private key
- `id_ed25519.pub` → public key

---

## Copy public key to the server

```bash
ssh-copy-id wojtek@192.168.64.2
```

The public key is appended to:

```
~/.ssh/authorized_keys
```

on the remote server.

---

## Passwordless login

After copying the key:

```bash
ssh wojtek@192.168.64.2
```

Authentication is performed using the SSH key instead of a password.

---

## SSH Client Configuration

Created `~/.ssh/config`:

```text
Host lab
    HostName 192.168.64.2
    User wojtek
    IdentityFile ~/.ssh/id_ed25519
```

Now the connection can be established using:

```bash
ssh lab
```

---

## Verify authentication

Verbose mode:

```bash
ssh -v lab
```

Important output:

```text
Offering public key
Server accepts key
Authenticated using publickey
```

---

## Important files

### Client

```
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub
~/.ssh/config
~/.ssh/known_hosts
```

### Server

```
~/.ssh/authorized_keys
/etc/ssh/sshd_config
```

---

## SSH Concepts

### Private Key

- Stored only on the client.
- Used to prove identity.
- Must never be shared.

---

### Public Key

- Safe to share.
- Copied to remote servers.
- Stored inside:

```
~/.ssh/authorized_keys
```

---

### authorized_keys

Contains trusted public keys allowed to authenticate.

---

### known_hosts

Stores fingerprints of previously connected servers to protect against Man-in-the-Middle (MITM) attacks.

---

### ssh-copy-id

Copies the public key to the remote host and automatically updates `authorized_keys`.

---

### ssh -v

Enables verbose mode for troubleshooting SSH authentication.

---

## Security Best Practices

Recommended production configuration:

```text
PubkeyAuthentication yes
PasswordAuthentication no
PermitRootLogin prohibit-password
```

Disabling password authentication reduces the attack surface by allowing only key-based authentication.

---

## Skills Practiced

- SSH key generation
- Public/private key authentication
- Passwordless SSH login
- SSH client configuration
- SSH troubleshooting
- Understanding `authorized_keys`
- Understanding `known_hosts`
- Basic SSH server hardening

---

## Result

Successfully configured secure passwordless SSH authentication from macOS to an Ubuntu virtual machine using ED25519 keys.
