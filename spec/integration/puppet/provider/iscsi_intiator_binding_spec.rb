#! /usr/bin/env ruby

require 'spec_helper'
require 'yaml'
require 'puppet/provider/vcenter'
require 'rbvmomi'

describe Puppet::Type.type(:iscsi_intiator_binding).provider(:iscsi_intiator_binding) do

  iscsi_intiator_binding_yml =  YAML.load_file(my_fixture('iscsi_intiator_binding.yml'))
   initiator_binding = iscsi_intiator_binding_yml['initiator_binding']

  transport_yml =  YAML.load_file(my_fixture('transport.yml'))
  transport_node = transport_yml['transport']
    
    

  let(:bind_iscsi_initiator) do
    puts "calling"
    puts transport_node.inspect
    @catalog = Puppet::Resource::Catalog.new
    transport = Puppet::Type.type(:transport).new({
      :name => transport_node['name'],
      :username => transport_node['username'],
      :password => transport_node['password'],
      :server   => transport_node['server'],
      :options  => transport_node['options'],
    })
    @catalog.add_resource(transport)

    Puppet::Type.type(:iscsi_intiator_binding).new(
    :name                   => initiator_binding['name'],
    :ensure                 => initiator_binding['ensure'],
    :transport              => transport,
    :catalog                => @catalog,
    :vmknics                => initiator_binding['vmknics'],
    :script_executable_path => initiator_binding['script_executable_path'],
    :host_username          => initiator_binding['host_username'],
    :host_password          => initiator_binding['host_password']
    )
  end


  let(:provider) do
    described_class.new( )
  end

  describe "when binding a iscsi initiator" do
    it "should be able bind iscsi initiator" do
      bind_iscsi_initiator.provider.create
      response = bind_iscsi_initiator.provider.is_binded
      response.should be_true
      end
  end

  describe "when undinding a iscsi initiator - which already bind" do
    it "should be able to unbind iscsi initiator " do
      puts "inside destroy"
      bind_iscsi_initiator.provider.destroy
      response = bind_iscsi_initiator.provider.is_binded
      response.should be_false
    end
  end

end
