# MOT-13 — Mounts and /etc/fstab

## Goal

Understand Linux mounts, inspect mounted filesystems and troubleshoot persistent mounts configured in `/etc/fstab`.

## Check available disks and partitions

```bash
lsblk
```

`lsblk` shows block devices such as disks, partitions and LVM devices.

Think:

```text
lsblk → What disks and partitions do I have?
```

## Check currently mounted filesystems

```bash
findmnt
```

`findmnt` shows what is currently mounted and where.

Example from the lab:

```text
/           /dev/mapper/ubuntu--vg-ubuntu--lv   ext4
/boot       /dev/sda2                           ext4
/boot/efi   /dev/sda1                           vfat
```

Think:

```text
findmnt → What is mounted right now?
```

## Check persistent mount configuration

```bash
cat /etc/fstab
```

`/etc/fstab` defines filesystems that should be mounted automatically.

The basic structure is:

```text
<filesystem>  <mount point>  <type>  <options>  <dump>  <pass>
```

Example:

```text
UUID=xxxx    /boot    ext4    defaults    0    1
```

Meaning:

```text
UUID=xxxx → which filesystem/device
/boot     → where to mount it
ext4      → filesystem type
defaults  → standard mount options
0         → dump setting
1         → filesystem check order
```

The lab system also contains a swap entry:

```text
/swap.img    none    swap    sw    0    0
```

This tells Linux to use `/swap.img` as swap space.

## Test /etc/fstab safely

After changing `/etc/fstab`, test it before rebooting:

```bash
sudo mount -a
```

`mount -a` reads `/etc/fstab` and attempts to mount the configured filesystems.

In this lab:

```bash
sudo mount -a
```

returned no error, indicating that the current configuration could be processed successfully.

Verify mounts again:

```bash
findmnt
```

## Troubleshooting flow

```text
Mount missing
    ↓
lsblk
    ↓
Is the disk/partition visible?
    ↓
findmnt
    ↓
Is it currently mounted?
    ↓
cat /etc/fstab
    ↓
Check device/UUID, mount point,
filesystem type and options
    ↓
sudo mount -a
    ↓
Fix errors if present
    ↓
findmnt
    ↓
Verify
```

## Commands to remember

```text
lsblk       → what disks/partitions do I have?
findmnt     → what is mounted right now?
/etc/fstab  → what should be mounted automatically?
mount -a    → apply/test the fstab configuration
```

## Interview answer

If a filesystem was not mounted as expected, I would first use `lsblk` to verify that the disk or partition is visible. Then I would use `findmnt` to check the current mounts and inspect `/etc/fstab` for the persistent mount configuration. I would verify the device or UUID, mount point, filesystem type and options. After making any changes, I would run `mount -a` before rebooting to detect configuration errors and then verify the result with `findmnt`.
