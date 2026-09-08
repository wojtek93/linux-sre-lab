# virsh VM Lifecycle Lab

## Goal

Practice basic virtual machine lifecycle management using libvirt and virsh.

## Environment

The lab was performed inside a Linux virtual machine.

Hardware-assisted KVM virtualization was not available:

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```

Result:

```text
0
```

The `/dev/kvm` device was also unavailable.

This means nested hardware virtualization was not exposed to the Linux VM.

QEMU could still run virtual machines using software emulation.

## Install libvirt and virsh

```bash
sudo apt update
sudo apt install -y libvirt-clients libvirt-daemon-system
```

Verify:

```bash
virsh --version
systemctl status libvirtd
```

## User permissions

Add the current user to the `libvirt` group:

```bash
sudo usermod -aG libvirt $USER
newgrp libvirt
```

This allows `virsh` commands to be executed without `sudo`.

## Check virtual machines

```bash
virsh list --all
```

## Check libvirt networks

```bash
virsh net-list --all
```

The default libvirt network was active and configured for autostart.

## Create VM definition

File:

```text
vm.xml
```

Configuration:

```xml
<domain type='qemu'>
  <name>test-vm</name>

  <memory unit='MiB'>512</memory>
  <vcpu>1</vcpu>

  <os>
    <type arch='x86_64'>hvm</type>
  </os>

  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
  </devices>
</domain>
```

## Define VM

```bash
virsh define vm.xml
```

The VM became registered in libvirt.

Verify:

```bash
virsh list --all
```

Expected state:

```text
test-vm    shut off
```

## Start VM

```bash
virsh start test-vm
```

Verify:

```bash
virsh list --all
```

Expected state:

```text
test-vm    running
```

## Graceful shutdown

```bash
virsh shutdown test-vm
```

`shutdown` requests a graceful shutdown from the guest operating system.

In this lab the VM did not contain a real guest OS capable of processing the shutdown request, so the VM remained running.

## Force stop

```bash
virsh destroy test-vm
```

Verify:

```bash
virsh list --all
```

Expected:

```text
test-vm    shut off
```

Important:

`destroy` does not delete the VM.

It force-stops the running VM, similar to removing power from a physical machine.

## Remove VM definition

```bash
virsh undefine test-vm
```

Verify:

```bash
virsh list --all
```

The VM should no longer appear.

## Lifecycle commands

```text
virsh define vm.xml
        |
        v
VM registered
        |
        v
virsh start test-vm
        |
        v
VM running
        |
        +--------------------------+
        |                          |
        v                          v
virsh shutdown              virsh destroy
graceful stop               forced stop
        |                          |
        +------------+-------------+
                     |
                     v
                 VM shut off
                     |
                     v
           virsh undefine test-vm
                     |
                     v
             definition removed
```

## Important differences

### shutdown

```bash
virsh shutdown test-vm
```

Gracefully asks the guest operating system to shut down.

Preferred method for production systems.

### destroy

```bash
virsh destroy test-vm
```

Immediately force-stops the VM.

Use when the guest is unresponsive and graceful shutdown does not work.

### define

```bash
virsh define vm.xml
```

Registers a persistent VM definition in libvirt.

### undefine

```bash
virsh undefine test-vm
```

Removes the VM definition from libvirt.

It does not automatically mean that every associated disk image is deleted.

## KVM vs QEMU

With hardware virtualization available, a libvirt domain can typically use:

```xml
<domain type='kvm'>
```

KVM provides hardware-assisted virtualization through:

```text
/dev/kvm
```

Without `/dev/kvm`, QEMU can still run a VM using software emulation, but performance is significantly lower.

## Quick cheat sheet

```text
virsh list --all        = list VMs
virsh define            = register VM
virsh start             = start VM
virsh shutdown          = graceful shutdown
virsh destroy           = force stop
virsh undefine          = remove VM definition
virsh net-list --all    = list virtual networks
```

## Key takeaway

The normal lifecycle is:

```text
define -> start -> shutdown -> undefine
```

If the guest does not respond to a graceful shutdown:

```text
shutdown fails -> investigate -> destroy if force-stop is necessary
```
