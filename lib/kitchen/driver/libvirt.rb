# frozen_string_literal: true
#
# Author:: Brandon Raabe (<brandocorp@gmail.com>)
#
# Copyright:: 2018, Brandon Raabe
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'libvirt'
require 'fog/libvirt'
require 'kitchen'
require_relative 'libvirt_version'

module Kitchen
  module Driver
    # Libvirt driver for Test Kitchen
    #
    # @author Brandon Raabe (<brandocorp@gmail.com>)
    class Libvirt < Kitchen::Driver::Base
      kitchen_driver_api_version 2

      plugin_version Kitchen::Driver::LIBVIRT_VERSION

      # The Libvirt connection URI
      default_config :uri, 'qemu:///session'

      # The Libvirt connection username (optional)
      default_config :username, nil

      # The Libvirt connection password (optional)
      default_config :password, nil

      # The name to use when creating the domain
      default_config(:name, &:default_name)

      # The Libvirt domain's cpu count
      default_config :cpus, 1

      # The Libvirt domain's memory in MB
      default_config :memory, 1024

      # The Libvirt domain's persistence
      default_config :persistent, true

      # The base image to clone for the domain
      default_config(:image_name, &:default_image)

      # The base image format
      default_config :image_format, 'raw'

      # The bridge device to use for the domain's network connection
      default_config :bridge_name, 'virbr0'

      # The name of the network the domain will join
      default_config :network_name, 'default'

      # The type of domain to launch
      default_config :domain_type, 'kvm'

      # Additional volumes to create and attach
      default_config :extra_volumes, []

      # Create the target instance
      def create(state)
        info("Creating instance #{instance.name}")
        return if state[:server_id]

        domain = create_domain
        state[:server_id] = domain.id
        state[:hostname] = domain.public_ip_address

        instance.transport.connection(state).wait_until_ready

        info("Libvirt instance #{domain.name} created.")
      end

      # Destroy the target instance
      def destroy(state)
        info("Destroying instance #{instance.name}")
        return if state[:server_id].nil?
        instance.transport.connection(state).close
        domain = load_domain(state[:server_id])
        destroy_domain(domain) unless domain.nil?
        info("Libvirt instance #{state[:server_id]} destroyed.")
        state.delete(:server_id)
        state.delete(:hostname)
      end

      private

      # The libvirt client
      def client
        @client ||= Fog::Compute.new(
          provider: 'libvirt',
          libvirt_uri: config[:uri],
          libvirt_ip_command: default_ip_command
        )
      end

      # The command string to use for finding the domain IP address
      #
      # @return String The command string
      def default_ip_command
        %q( awk "/$mac/ {print \$1}" /proc/net/arp )
      end

      # Returns the default image name for the configured platform
      #
      # @return String The default image name
      def default_image
        "/var/lib/libvirt/images/kitchen-#{instance.platform.name}"
      end

      # The the default name for the domain
      #
      # @return String the domain name
      def default_name
        debug("Instance name: #{instance.name}")
        "#{instance.platform.name}-#{Time.now.to_i}"
      end

      # Create the domain, and all its dependencies
      #
      # @return Fog::Compute::Libvirt::Server The created domain
      def create_domain
        debug("Creating domain #{domain_name}")
        debug("Using options: #{domain_options}")
        domain = client.servers.create(domain_options)
        prepare_domain(domain)
        domain
      end

      # Prepares the domain for SSH connections
      def prepare_domain(domain)
        domain.start unless domain.active
        wait_for_ip_address(domain)
      end

      # Create the domain, and all its dependencies
      #
      # @return Fog::Compute::Libvirt::Server The created domain
      def destroy_domain(domain)
        debug("Destroying domain #{domain.id}")
        domain.halt if domain.active
        debug("Removing volumes for domain #{domain.id}")
        volume_cleanup(domain)
        domain.destroy
      end

      # Create a new volume from the source image
      #
      # @return Fog::Compute::Libvirt::Volume The created volume
      def clone_volume(source, target)
        debug("Creating Libvirt volume #{target}")
        debug("Cloning volume from #{source}")

        # Attempt to locate the target or source volume
        source_image = client.volumes.get(source)
        if source_image.name =~ /^fog-\d+/
          error("Could not find target image: #{source}.")
        end

        # Clone the source volume
        source_image.clone_volume(target)
        client.volumes.all.find { |vol| vol.name == target }
      end

      # Create the extra disks
      def create_volumes(volume_definitions)
        volume_definitions.each { |volume| client.volumes.create(volume) }
      end

      # Cleanup a domain's volumes
      def volume_cleanup(domain)
        domain.volumes.each do |volume|
          debug("Removing volumes #{volume.key}")
          volume.destroy if volume.key
        end
      end

      # Create an array of all virtual disks for the domain
      #
      # @return Array<Fog::Compute::Libvirt::Volume> the domain volumes
      def domain_volumes
        # Use the domain name as our volume base name.
        base_name = domain_name

        # Clone our root volume from our base image.
        root_volume = clone_volume(default_image, "#{base_name}-root")

        # Return the array of created volumes
        [root_volume].concat(
          create_volumes(
            extra_volumes(base_name)
          )
        )
      end

      # Create a config structure for each additional volume.
      #
      # @return Array<Hash> the volume configuration array
      def extra_volumes(base_name)
        configs = []

        config[:extra_volumes].each_with_index do |data, index|
          disk_id = (index + 1).to_s.rjust(2, '0')
          data[:name] = "#{base_name}-extra-#{disk_id}"
          configs << data
        end

        configs
      end

      # Prepare the options passed to create the domain
      #
      # @return Hash The domain configuration
      def domain_options
        @domain_options ||= {
          name: domain_name,
          persistent: config[:persistent],
          cpus: domain_cpus,
          memory_size: domain_memory,
          os_type: 'hvm',
          arch: config[:arch],
          domain_type: config[:domain_type],
          nics: [{
            type: 'network',
            network: config[:network_name],
            bridge: config[:network_bridge_name]
          }],
          volumes: domain_volumes
        }
      end

      # Returns the domain memory size in KBs
      #
      # @return Integer The memory size
      def domain_memory
        (config[:memory] || 512) * 1024
      end

      # Return domain cpu count
      #
      # @return Integer The cpu count
      def domain_cpus
        config[:cpus] || 1
      end

      # Return the domain type
      #
      # @return String The domain type (quem|kvm|xen)
      def domain_type
        config[:domain_type]
      end

      # Return the domain name
      #
      # @return String The domain's name
      def domain_name
        @domain_name ||= default_name
      end

      # Find and return a domain by it's id
      #
      # @return Fog::Compute::Libvirt::Domain The loaded domain
      def load_domain(domain_id)
        client.servers.get(domain_id)
      rescue ::Libvirt::RetrieveError
        debug("Domain with id #{domain_id} was not found.")
        nil
      end

      # Wait for the domain to receive its IP address
      def wait_for_ip_address(domain, timeout = 300)
        debug('Waiting for domain network to assign an IP address')
        loop do
          break if timeout <= 0

          if domain.public_ip_address
            debug("IP address: #{domain.public_ip_address}")
            break
          else
            debug('IP address not found...')
            timeout -= 5
            sleep 5
          end
        end
      end
    end
  end
end
