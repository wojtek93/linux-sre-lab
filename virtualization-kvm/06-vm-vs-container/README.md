# VM vs Container

## Goal

Understand the fundamental difference between virtual machines and containers.

## Virtual Machine

A virtual machine contains:

```text
Application
Guest OS
Guest Kernel
Virtual Hardware
Hypervisor
Host
```

A VM has its own operating system and kernel.

Because of this, a Linux host can run a VM with another operating system, for example Windows.

Characteristics:

- own guest kernel
- stronger isolation
- higher resource overhead
- slower startup
- can run a different operating system than the host

## Container

A container uses:

```text
Application
Container runtime
Host Kernel
Host
```

Containers share the kernel of the host operating system.

Characteristics:

- shares host kernel
- lightweight
- fast startup
- lower resource overhead
- less isolation than a full VM

## Key difference

```text
VM        -> own kernel
Container -> shares host kernel
```

This is the main reason containers are lighter and faster to start.

## Isolation

A VM provides stronger isolation because it runs with its own guest operating system and kernel.

Containers isolate applications and processes, but they still depend on the host kernel.

## Typical use cases

VM:

```text
- different operating systems
- stronger isolation
- full server environments
- workloads requiring their own kernel
```

Container:

```text
- application deployment
- microservices
- fast scaling
- lightweight isolated environments
```

## Interview answer

```text
A virtual machine includes its own guest operating system and kernel,
while containers share the host kernel.

VMs provide stronger isolation but have more overhead.
Containers are lighter and start faster because they do not need to boot
a separate operating system.

A Linux host can run a Windows VM, while a normal Linux container cannot
use a completely different kernel because it shares the host kernel.
```

## Key takeaway

```text
VM:
own kernel -> stronger isolation -> heavier

Container:
shared host kernel -> lighter -> faster
```
