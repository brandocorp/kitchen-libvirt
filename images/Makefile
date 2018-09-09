.PHONY: default
export LIBVIRT_SYSTEM_IMAGES = /var/lib/libvirt/images
export LIBVIRT_USER_IMAGES = /home/$(USER)/.local/libvirt/images
export PACKER_CACHE_DIR = /home/$(USER)/.packer.d/cache
export PACKER_BUILD_DIR = $(PACKER_CACHE_DIR)/builds

defalt: all

all: centos freebsd ubuntu pool-refresh
	mkdir -p $(PACKER_BUILD_DIR)

centos:
	packer build centos.json
	sudo install $(PACKER_BUILD_DIR)/centos-7/kitchen-centos-7 \
		-o libvirt-qemu -g kvm $(LIBVIRT_SYSTEM_IMAGES)
	rm -rf $(PACKER_BUILD_DIR)/centos-7

freebsd:
	packer build freebsd.json
	sudo install $(PACKER_BUILD_DIR)/freebsd-11.2/kitchen-freebsd-11.2 \
		-o libvirt-qemu -g kvm $(LIBVIRT_SYSTEM_IMAGES)
	rm -rf $(PACKER_BUILD_DIR)/freebsd-11.2

ubuntu:
	packer build ubuntu.json
	sudo install $(PACKER_BUILD_DIR)/ubuntu-18.04/kitchen-ubuntu-18.04 \
		-o libvirt-qemu -g kvm $(LIBVIRT_SYSTEM_IMAGES)
	rm -rf $(PACKER_BUILD_DIR)/ubuntu-18.04

pool-refresh:
	virsh -c qemu:///system pool-refresh default

clean:
	rm -rf $(PACKER_BUILD_DIR)/*
