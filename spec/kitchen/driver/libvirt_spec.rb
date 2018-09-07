# -*- encoding: utf-8 -*-
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

require "fog/libvirt"
require "kitchen/driver/libvirt"
require "kitchen/provisioner/dummy"
require "kitchen/transport/dummy"
require "kitchen/verifier/dummy"

describe Kitchen::Driver::Libvirt do

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:config) do
    {
      uri: 'qemu:///system',
      cpus: 2,
      memory: 2048,
    }
  end

  let(:image) do
    double("source_image",
      path: '/var/lib/images/image.img',
      pool_name: 'default', 
      format_type: 'raw'
    )
  end

  let(:volume) do 
    { 
      path: '/var/lib/images/volume.img',
      pool_name: 'default', 
      format_type: 'raw' 
    }
  end

  let(:nic) do
    { 
      type: 'network', 
      network: 'default' 
    }
  end
  
  let(:domain_options) do
    {
      name: "default-testos-99-0123456789", 
      persistent: true, 
      cpus: 1,
      memory_size: 512, 
      os_type: 'hvm', 
      arch: 'x86_64', 
      domain_type: 'kvm',
      nics: [nic],
      volumes: [volume] 
    }
  end

  let(:platform) { Kitchen::Platform.new(:name => "testos-99") }
  let(:transport) { Kitchen::Transport::Dummy.new }
  let(:provisioner) { Kitchen::Provisioner::Dummy.new }
  let(:state) { {} }
  let(:driver) { Kitchen::Driver::Libvirt.new(config) }
  let(:id) { "12345678-abcd-efgh-ijkl-mnopqrstuvwx" }
  let(:client) do
    double("Fog::Compute")
  end

  let(:domain) do 
    double(
      "libvirt domain", 
      id: id, 
      name: "default-testos-99-0123456789",
      public_ip_address: '1.2.3.4',
      start: true,
      volumes: [volume],
      nics: [nic],
    )
  end
  
  let(:instance) do
    instance_double(
      Kitchen::Instance,
      :name => "default-testos-99",
      :logger => logger,
      :transport => transport,
      :provisioner => provisioner,
      :platform => platform,
      :to_str => "str"
    )
  end

  before do
    allow(driver).to receive(:windows_os?).and_return(false)
    allow(driver).to receive(:instance).and_return(instance)
    allow(driver).to receive(:client).and_return(client)
    allow(client).to receive_message_chain("servers.create").and_return(domain)
    allow(driver).to receive(:create_volume).and_return(volume)
  end

  it "driver api_version is 2" do
    expect(driver.diagnose_plugin[:api_version]).to eq(2)
  end

  it "plugin_version is set to Kitchen::Vagrant::VERSION" do
    expect(driver.diagnose_plugin[:version]).to eq(Kitchen::Driver::LIBVIRT_VERSION)
  end

  describe "#create" do
    it "returns if an existing instance id is found" do
      state[:server_id] = id
      expect(driver.create(state)).to eq(nil)
    end

    it "sets the domain ip address as the hostname" do
      driver.create(state)
      expect(state[:server_id]).to eq("12345678-abcd-efgh-ijkl-mnopqrstuvwx")
      expect(state[:hostname]).to eq('1.2.3.4')
    end
  end

  describe "#destroy" do
    context "when no server id is found" do
      it "returns nil" do
        expect(driver.destroy(state)).to eq(nil)
      end
    end

    context "when an existing instance id is found" do
      let(:state) { { :server_id => "id", :hostname => "name" } }

      context "the server is already destroyed" do
        it "does nothing" do
          expect(driver).to receive(:load_domain).with("id").and_return nil
          driver.destroy(state)
          expect(state).to eq({})
        end
      end

      it "destroys the server" do
        expect(driver).to receive(:load_domain).with("id").and_return(domain)
        expect(instance).to receive_message_chain("transport.connection.close")
        expect(domain).to receive(:destroy)
        driver.destroy(state)
        expect(state).to eq({})
      end
    end
  end
end
