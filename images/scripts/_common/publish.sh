#!/bin/sh -eux
build_image=$(jq ".builds[].files[].name" manifest.json)
install_command="install -g kvm -o libvirt-qemu $build_image /var/lib/libvirt/images"
sudo="sudo"

if [ -w /var/lib/libvirt/images ]; then
  sudo=""
fi

$sudo $install_command
