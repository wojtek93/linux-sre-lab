# KVM VM Troubleshooting Lab

## Goal

Practice troubleshooting a virtual machine that fails to start using libvirt and virsh.

The lab covers several common causes:

- missing storage
- incorrect file permissions
- VM resource configuration
- libvirt logs
- domain XML inspection

## Troubleshooting flow

The basic workflow used in this lab:

```text
virsh domstate <vm>
        |
        v
virsh start <vm>
        |
        v
read the error
        |
        v
journalctl -u libvirtd
        |
        v
virsh dumpxml <vm>
        |
        v
check:
- storage path
- permissions
- CPU/RAM
- domain configuration
        |
        v
fix the root cause
        |
        v
start the VM again
```

## 1. Create a VM with a missing disk

The VM was defined with a disk path that did not exist:

```xml
<disk type='file' device='disk'>
  <driver name='qemu' type='qcow2'/>
  <source file='/var/lib/libvirt/images/missing-disk.qcow2'/>
  <target dev='vda' bus='virtio'/>
</disk>
```

Define the VM:

```bash
virsh define broken-vm.xml
```

Try to start it:

```bash
virsh start broken-vm
```

The VM failed because the configured disk file did not exist.

## 2. Verify the storage path

Check the file:

```bash
ls -l /var/lib/libvirt/images/missing-disk.qcow2
```

Expected error:

```text
No such file or directory
```

Inspect the VM configuration:

```bash
virsh dumpxml broken-vm | grep -A3 source
```

This confirms which storage path libvirt is trying to use.

## 3. Create the missing qcow2 disk

Create a new virtual disk:

```bash
sudo qemu-img create -f qcow2 \
  /var/lib/libvirt/images/missing-disk.qcow2 1G
```

Verify:

```bash
ls -lh /var/lib/libvirt/images/missing-disk.qcow2
```

Start the VM again:

```bash
virsh start broken-vm
```

Check its state:

```bash
virsh domstate broken-vm
```

Expected:

```text
running
```

## 4. Check libvirt logs

Check recent libvirt logs:

```bash
journalctl -u libvirtd --since "15 minutes ago" | tail -n 30
```

The log showed the earlier storage error:

```text
Cannot access storage file
No such file or directory
```

This confirms the root cause from the host side.

## 5. Inspect storage permissions

Check owner, group and permissions:

```bash
ls -l /var/lib/libvirt/images/missing-disk.qcow2
```

More detailed information:

```bash
stat /var/lib/libvirt/images/missing-disk.qcow2
```

The disk had permissions similar to:

```text
-rw-r--r--
```

with owner/group used by libvirt/QEMU.

## 6. Reproduce a permission problem

Stop the VM:

```bash
virsh destroy broken-vm
```

Remove all permissions from the disk:

```bash
sudo chmod 000 /var/lib/libvirt/images/missing-disk.qcow2
```

Verify:

```bash
ls -l /var/lib/libvirt/images/missing-disk.qcow2
```

The file should show:

```text
----------
```

Try to start the VM:

```bash
virsh start broken-vm
```

The VM fails with a permission-related error.

This demonstrates that the file can exist but still be unusable by QEMU/libvirt.

## 7. Fix the permissions

Restore the permissions:

```bash
sudo chmod 644 /var/lib/libvirt/images/missing-disk.qcow2
```

Verify:

```bash
ls -l /var/lib/libvirt/images/missing-disk.qcow2
```

Start the VM again:

```bash
virsh start broken-vm
```

Check:

```bash
virsh domstate broken-vm
```

Expected:

```text
running
```

## 8. Check CPU and memory

Check host resources:

```bash
nproc
free -h
```

Inspect VM resources:

```bash
virsh dominfo broken-vm
```

Useful fields:

```text
CPU(s)
Max memory
Used memory
```

Inspect the XML:

```bash
virsh dumpxml broken-vm | grep -E 'memory|vcpu'
```

This shows the configured vCPU and RAM values.

## 9. Memory overcommit

The VM memory was temporarily changed to:

```xml
<memory unit='MiB'>16384</memory>
```

The host had much less physical RAM available, but the VM still started.

This demonstrates memory overcommit.

A VM can be configured with more memory than the host currently has physically available because QEMU/libvirt does not necessarily allocate all configured RAM immediately.

Important:

```text
configured VM memory != physical RAM consumed immediately
```

Problems appear if the guest actually tries to consume more memory than the host can provide.

The VM memory was later restored to:

```xml
<memory unit='MiB'>512</memory>
```

## 10. Useful troubleshooting commands

Check VM state:

```bash
virsh domstate broken-vm
```

Start VM:

```bash
virsh start broken-vm
```

Inspect libvirt logs:

```bash
journalctl -u libvirtd
```

Inspect full VM configuration:

```bash
virsh dumpxml broken-vm
```

Inspect VM resources:

```bash
virsh dominfo broken-vm
```

Check storage:

```bash
ls -l /var/lib/libvirt/images/
```

Check file metadata:

```bash
stat /var/lib/libvirt/images/missing-disk.qcow2
```

## 11. Important troubleshooting sequence

The key sequence to remember:

```text
domstate
   |
   v
start / read error
   |
   v
journalctl
   |
   v
dumpxml
```

Then verify:

```text
storage
permissions
CPU/RAM
domain configuration
```

## 12. PCI addresses in libvirt

`virsh dumpxml` may show additional devices and PCI addresses that were not manually written in the original XML.

Example:

```xml
<controller type='pci' index='0' model='pci-root'/>
```

Libvirt can automatically add virtual hardware and assign PCI addresses.

A PCI address can contain:

```text
domain
bus
slot
function
```

Example:

```text
0000:00:02.0
```

Meaning:

```text
domain   0000
bus      00
slot     02
function 0
```

In normal VM management, these values usually do not need to be configured manually.

## Key takeaway

When a VM does not start:

```text
1. Check its state.
2. Try to start it and read the error.
3. Check libvirt logs.
4. Inspect the domain XML.
5. Verify storage paths.
6. Verify file ownership and permissions.
7. Check CPU and memory configuration.
8. Fix the root cause.
9. Start the VM again and verify its state.
```

A concise interview answer:

```text
If a VM fails to start, I first check the virsh error and libvirt logs.
Then I inspect the domain XML and verify storage paths, permissions and
resource configuration. After fixing the root cause, I start the VM again
and verify its state.
```
