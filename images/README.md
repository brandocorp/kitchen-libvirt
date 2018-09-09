# Kitchen-Libvirt Packer Templates

The packer templates in this directory can be used to produce a set of images for use with this Test-Kitchen driver. Most of the work has been borrowed from the wonderful [chef/bento](https://github.com/chef/bento) project!

> Note: Copying the images into the default Libvirt storage pool requires sudo permission.

## Building

Execute a single build by running the following command:

```shell
make ubuntu pool-refresh

# or

packer build ubuntu.json
sudo install -g kvm -o libvirt-qemu myimage.qcow2 /var/lib/libvirt/images
virsh -c qemu:///system pool-refresh default
```

### Build All Images

To build all images run the following:

```
make all
```
