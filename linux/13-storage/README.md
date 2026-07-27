# Linux SRE Lab 13 – Loopback Filesystem

## Objective

Learn how Linux block devices, filesystems and mount points work by creating and mounting a loopback filesystem.

---

## Environment

- Ubuntu Server
- ext4 filesystem
- loop device
- lsblk
- mount
- umount
- dd
- mkfs.ext4

---

## Tasks Performed

### 1. Display block devices

```bash
lsblk
```

Reviewed:

- disk
- partitions
- LVM
- mount points

---

### 2. Create a virtual disk image

```bash
dd if=/dev/zero of=disk.img bs=1M count=100
```

Created a 100 MB file to simulate a block device.

---

### 3. Create an ext4 filesystem

```bash
mkfs.ext4 disk.img
```

Formatted the image with an ext4 filesystem.

---

### 4. Create a mount point

```bash
mkdir mnt
```

---

### 5. Mount the filesystem

```bash
sudo mount -o loop disk.img mnt
```

Verified using:

```bash
df -h
mount | grep mnt
findmnt
```

---

### 6. Create files inside the mounted filesystem

```bash
touch test1.txt
touch test2.txt
mkdir data
echo "Hello Storage Lab" > data/info.txt
```

Adjusted ownership:

```bash
sudo chown -R $USER:$USER mnt
```

---

### 7. Unmount the filesystem

```bash
sudo umount mnt
```

Verified that the mount point was no longer active.

---

### 8. Cleanup

Created a cleanup script:

```bash
#!/bin/bash

set -e

cd "$(dirname "$0")/.."

if mount | grep -q "$(pwd)/mnt"; then
    sudo umount mnt
fi

rm -f disk.img

echo "Cleanup completed."
```

Made executable:

```bash
chmod +x scripts/cleanup.sh
```

---

## Files

```
13-storage/
├── README.md
├── mnt/
└── scripts/
    └── cleanup.sh
```

---

## What I Learned

- Difference between disks, partitions and filesystems.
- How Linux mounts filesystems.
- How loop devices allow a regular file to behave like a block device.
- How to create and format an ext4 filesystem.
- How to mount and unmount filesystems.
- How mount points expose a filesystem within the Linux directory tree.
- Basic cleanup automation with Bash.

---

## Key Commands

```bash
lsblk
dd
mkfs.ext4
mount
umount
findmnt
df -h
chmod +x
```
