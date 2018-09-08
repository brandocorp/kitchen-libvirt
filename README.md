# Kitchen Libvirt 

A Test Kitchen Driver for Libvirt

## License

[Apache 2.0][license]

## Quick Start

1. Install [ChefDK](https://downloads.chef.io/chefdk).
2. Install libvirt.
3. Build images.
4. Add Libvirt configuration to the `driver` section of your `.kitchen.yml`

       driver:
         name: libvirt
         uri: qemu:///session

5. Run `kitchen test`.

## Requirements

* Libvirt (`4.0.0`)

## Configuration

### `uri` 

The Libvirt connection URI

    Default: qemu:///system

### `username`

The username to use when connecting to libvirt.

    Default: nil

### `password`

The password to use when connecting to libvirt.

    Default: nil

### `cpus`

The instance cpu count

    Default: 1

### `memory`

The instance memory in Megabytes

    Default: 1024

### `persistent`

Determines ephemerality of the instance

    Default: true

### `bridge_name` 

The bridge device to use for networking.

    Default: virbr0


### `network_name`

The network name to attach to the instance

    Default: default

### `domain_type`

The type of instance to crate

    Default: kvm

#### Platform Name

Specify the image by leaving `image_id` and `image_search`
blank, and specifying a standard platform name.

    platforms:
      - name: ubuntu-14.04

You may leave versions off, specify partial versions, and you may specify architecture to distinguish 32- and 64-bit. 

##### Examples

    platforms:
      - name: centos-7
      - name: ubuntu-16.04-i386

We always pick the highest released stable version that matches your regex, and
follow the other `image_search` rules for preference.

#### SSH

When using an existing key, or keys that exist on the instance through some other means, ensure that the private key is configured in your Test Kitchen `transport` section, either directly or made available via `ssh-agent`:

    transport:
      ssh_key: ~/.ssh/vagrant_insecure_private_key

For standard platforms we automatically provide the SSH username, but when specifying your own AMI you may need to configure that as well.

### Devices

#### Disk Configuration

A list of block device mappings for the machine.  An example of all available keys looks like:

    volumes:
    - format: raw
      pool: default
      size: 20G
      backing_volume: /var/lib/libvirt/golden.img

## Example

The following could be used in a `.kitchen.yml` or in a `.kitchen.local.yml`
to override default configuration.

    ---
    driver:
      name: libvirt
      uri: qemu:///session
    transport:
      username: vagrant
      ssh_key: ~/.vagrant.d/insecure_private_key

    platforms:
      - name: ubuntu-16.04
      - name: centos-7
        driver:
          cpus: 2
          memory: 2048
        transport:
          username: centos

    suites:
      - name: default
        driver:
          volumes:
            - format: qcow2
              pool: default
              size: 10G
            - format: qcow2
              pool: default
              size: 10G
        run_list:
        attributes:


## Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[author]:           https://github.com/brandocorp
[issues]:           https://github.com/brandocorp/kitchen-libvirt/issues
[license]:          https://github.com/brandocorp/kitchen-libvirt/blob/master/LICENSE
[repo]:             https://github.com/brandocorp/kitchen-libvirt
[driver_usage]:     https://github.com/brandocorp/kitchen-libvirt
[chef_omnibus_dl]:  https://downloads.chef.io/chef
[kitchenci]:        https://kitchen.ci/
