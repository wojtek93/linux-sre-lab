# KVM Networking — NAT and Virtual Bridge

## Goal

Understand how libvirt connects virtual machines to virtual networks and how NAT networking differs from bridged networking.

## List libvirt networks

```bash
virsh net-list --all
```

The default network was active:

```text
Name      State    Autostart   Persistent
default   active   yes         yes
```

## Inspect the default network

```bash
virsh net-dumpxml default
```

Important parts:

```xml
<forward mode='nat'/>
<bridge name='virbr0'/>
<ip address='192.168.122.1' netmask='255.255.255.0'>
```

The DHCP range was:

```text
192.168.122.2 - 192.168.122.254
```

## NAT network

The default libvirt network uses NAT.

Simplified flow:

```text
VM
 |
 v
virbr0
 |
 v
host
 |
 v
external network / Internet
```

The VM receives a private IP address from the libvirt network.

Example:

```text
Host bridge: 192.168.122.1
VM:          192.168.122.x
```

The host translates traffic between the VM network and external networks.

## Bridge networking

With bridged networking, the VM can behave more like a separate physical computer on the LAN.

Example:

```text
Host: 192.168.1.20
VM:   192.168.1.21
```

Both can exist directly in the same LAN.

Simplified comparison:

```text
NAT:

VM -> host -> external network


Bridge:

VM -> LAN
Host -> LAN
```

## Check the virtual bridge

```bash
ip addr show virbr0
```

The bridge existed with:

```text
192.168.122.1/24
```

Check routing:

```bash
ip route | grep 192.168.122
```

The host had a route similar to:

```text
192.168.122.0/24 dev virbr0
```

This means traffic for the libvirt VM network is routed through `virbr0`.

## Check VM interfaces

```bash
virsh domiflist broken-vm
```

Initially the VM had no network interface.

A virtual NIC was then attached to the `default` network.

The final result was similar to:

```text
Interface   Type      Source    Model    MAC
vnet1       network   default   virtio   52:54:00:90:fa:a8
```

## Attach a network interface

A persistent interface can be added with:

```bash
virsh attach-interface \
  --domain broken-vm \
  --type network \
  --source default \
  --model virtio \
  --config
```

Important concepts:

```text
attach-interface = add virtual NIC
network          = connect to a libvirt network
default          = use the default libvirt network
virtio           = paravirtualized NIC model
```

The exact command syntax does not need to be memorized.

It can be checked using:

```bash
virsh help attach-interface
```

## Live vs persistent configuration

`--live` attempts to modify a running VM.

`--config` changes the persistent VM configuration.

Not every virtual hardware device supports hot-plugging.

In this lab, attempting to attach the NIC live produced a PCI hot-plug error.

The interface was therefore added to the persistent configuration and the VM was restarted.

## Inspect the interface in XML

```bash
virsh dumpxml broken-vm | grep -A6 interface
```

Example:

```xml
<interface type='network'>
  <mac address='52:54:00:90:fa:a8'/>
  <source network='default' bridge='virbr0'/>
  <target dev='vnet1'/>
  <model type='virtio'/>
</interface>
```

This means:

```text
VM NIC
 |
 v
libvirt network "default"
 |
 v
virbr0
 |
 v
NAT
```

## Important commands

```bash
virsh net-list --all
```

List libvirt networks.

```bash
virsh net-dumpxml default
```

Inspect network configuration.

```bash
virsh domiflist <vm>
```

Show the VM's network interfaces.

```bash
ip addr show virbr0
```

Inspect the Linux virtual bridge.

## Key takeaway

Remember:

```text
NAT:
VM -> virbr0 -> host -> external network

Bridge:
VM -> LAN as a separate host
```

And:

```text
net-list    = libvirt networks
net-dumpxml = network configuration
domiflist   = interfaces attached to a VM
```
