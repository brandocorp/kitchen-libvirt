# Libvirt Installation

## CentOS

```bash
yum install qemu-kvm qemu-img virt-manager libvirt libvirt-client
systemctl start libvirtd
systemctl enable libvirtd
```

## Ubuntu

Install the required packages
```bash
apt-get install qemu-kvm libvirt-bin virt-manager
```

Start and enable the `libvirtd` service.

```bash
systemctl start libvirtd
systemctl enable libvirtd
```

Add yourself to the necessary groups.

> Note: Group changes to your user account will take effect on your next login.

```bash
usermod -aG kvm,libvirt $USER
```
