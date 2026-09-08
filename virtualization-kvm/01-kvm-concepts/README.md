# KVM Virtualization Concepts

## Goal

Understand the basic Linux virtualization stack:

- KVM
- QEMU
- libvirt
- virsh
- hypervisor types

## KVM

KVM stands for:

Kernel-based Virtual Machine

KVM is part of the Linux kernel.

It allows Linux to use hardware virtualization features provided by the CPU, such as:

- Intel VT-x
- AMD-V

KVM provides hardware acceleration for virtual machines.

Simple way to remember:

KVM = hardware acceleration / hypervisor

## QEMU

QEMU stands for:

Quick Emulator

QEMU is the program that creates and runs the virtual machine.

It can emulate components such as:

- CPU
- memory
- disks
- network interfaces
- other virtual hardware

When QEMU works together with KVM, it can use hardware virtualization instead of emulating everything in software.

Simple way to remember:

QEMU = runs the VM

KVM = makes it fast

## VM Disk Image

QEMU itself is not a VM image.

A virtual machine disk is stored in a separate file.

Common formats include:

- qcow2
- raw
- img

Example:

```text
server01.qcow2
```

Simple way to remember:

QEMU = program

qcow2 = virtual disk

## libvirt

libvirt is a virtualization management layer.

It provides a common interface for managing virtual machines.

It can manage things such as:

- VM configuration
- CPU
- RAM
- disks
- networks
- VM lifecycle

Simple way to remember:

libvirt = VM manager

## virsh

virsh is a command-line tool used to communicate with libvirt.

Example commands:

```bash
virsh list
virsh start test-vm
virsh shutdown test-vm
```

Simple way to remember:

virsh = CLI

libvirt = management layer

## Virtualization Stack

```text
User
  |
  v
virsh
  |
  v
libvirt
  |
  v
QEMU
  |
  v
KVM
  |
  v
CPU / Hardware Virtualization
```

## Hypervisor

A hypervisor is software or a system layer that allows multiple virtual machines to run on one physical computer.

It manages access to resources such as:

- CPU
- RAM
- storage
- networking

## Hypervisor Types

### Type 1

A Type 1 hypervisor works directly with the hardware or very close to it.

Examples:

- KVM
- VMware ESXi
- Hyper-V

KVM is generally considered a Type 1 hypervisor because it is integrated into the Linux kernel.

### Type 2

A Type 2 hypervisor runs as an application on top of an existing operating system.

Examples:

- VirtualBox
- VMware Workstation

## Quick Memory Cheat Sheet

```text
QEMU    = runs the virtual machine
KVM     = hardware acceleration
libvirt = manages virtual machines
virsh   = CLI for libvirt
qcow2   = virtual disk
```

## Interview Answers

### What is KVM?

KVM is a Linux kernel virtualization technology that allows Linux to work as a hypervisor and use CPU hardware virtualization features.

### What is QEMU?

QEMU is software used to create and run virtual machines. When used with KVM, it can use hardware acceleration.

### What is libvirt?

libvirt is a management layer used to manage virtual machines and virtualization resources.

### What is virsh?

virsh is a command-line tool used to manage virtual machines through libvirt.

## Key Takeaway

The easiest way to remember the stack is:

```text
virsh -> libvirt -> QEMU -> KVM -> hardware
```

QEMU runs the virtual machine.

KVM accelerates it using hardware virtualization.
