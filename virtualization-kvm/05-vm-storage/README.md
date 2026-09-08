# KVM VM Storage Basics

## Goal

Understand how virtual machine disks are represented and managed with libvirt and QEMU.

Topics covered:

- virtual disks
- qcow2 vs raw
- disk mapping
- storage pools
- storage volumes

## Check disks attached to a VM

```bash
virsh domblklist broken-vm
```

Example result:

```text
Target   Source
vda      /var/lib/libvirt/images/missing-disk.qcow2
```

This means:

```text
vda
 |
 v
virtual disk visible to the VM

/var/lib/libvirt/images/missing-disk.qcow2
 |
 v
disk image file stored on the host
```

## Inspect a qcow2 image

```bash
qemu-img info /var/lib/libvirt/images/missing-disk.qcow2
```

Example:

```text
file format: qcow2
virtual size: 1 GiB
disk size: 200 KiB
```

Important distinction:

```text
virtual size = size visible to the VM
disk size    = space currently consumed on the host
```

A qcow2 image can therefore expose a large virtual disk while initially consuming much less physical storage.

## qcow2 vs raw

### qcow2

Features include:

- sparse allocation
- copy-on-write
- snapshots
- compression
- dynamic growth

Example:

```text
VM sees: 1 GiB
Host file currently uses: ~200 KiB
```

### raw

Raw is a simpler virtual disk format.

Characteristics:

- less metadata
- simpler layout
- lower format overhead
- fewer advanced features than qcow2

A concise comparison:

```text
qcow2 = flexible and feature-rich
raw   = simpler and lower overhead
```

## Disk image locking

Running:

```bash
qemu-img info /var/lib/libvirt/images/missing-disk.qcow2
```

while the VM was running produced a lock-related error.

The reason was that QEMU was already using the disk image.

After stopping the VM:

```bash
virsh destroy broken-vm
```

the image could be inspected normally.

## Storage pool

A storage pool is a location managed by libvirt for VM storage.

Conceptually:

```text
storage pool
    |
    +-- disk1.qcow2
    +-- disk2.qcow2
    +-- disk3.raw
```

In this lab the storage location was:

```text
/var/lib/libvirt/images
```

## Create a directory storage pool

```bash
virsh pool-define-as default dir --target /var/lib/libvirt/images
```

Start it:

```bash
virsh pool-start default
```

Enable automatic startup:

```bash
virsh pool-autostart default
```

Check:

```bash
virsh pool-list --all
```

Result:

```text
Name      State    Autostart
default   active   yes
```

## Storage volumes

A storage volume is a specific disk inside a storage pool.

List volumes:

```bash
virsh vol-list default
```

Example:

```text
Name                 Path
missing-disk.qcow2   /var/lib/libvirt/images/missing-disk.qcow2
```

Conceptually:

```text
storage pool: default
        |
        v
/var/lib/libvirt/images
        |
        v
volume: missing-disk.qcow2
        |
        v
attached to VM as vda
```

## Useful commands

List VM disks:

```bash
virsh domblklist <vm>
```

Inspect an image:

```bash
qemu-img info <image>
```

List storage pools:

```bash
virsh pool-list --all
```

List volumes in a pool:

```bash
virsh vol-list <pool>
```

## Key concepts

```text
storage pool = managed location for VM disks
volume       = individual VM disk
qcow2        = virtual disk format
vda          = disk name visible to the VM
```

## Interview answer

```text
A VM disk is typically represented by an image file on the host.
With libvirt, storage can be organized into storage pools and volumes.

qcow2 supports features such as sparse allocation and snapshots, while raw
is a simpler format with less overhead.

I can inspect attached disks with virsh domblklist and inspect image details
using qemu-img info.
```
