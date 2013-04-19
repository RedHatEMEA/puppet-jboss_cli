require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:server_identity) do
  @doc = "Manages server identity used by SSL for management consoles"

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the management realm"
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
  end

  newparam(:management_realm_name) do
    desc "The management realm: e.g: HttpManagementRealm"
  end

  newproperty(:keystore_path) do
    desc "The path where the keystore is stored"
    defaultto("keystore/management-ssl.keystore")
  end

  newproperty(:keystore_relative_to) do
    desc "The value on which the path is relative to where the keystore is stored"
    defaultto("jboss.server.config.dir")
  end

  newproperty(:keystore_password) do
    desc "The keystore password"
    defaultto("bdfbdf12")
  end

  newproperty(:ssl_alias) do
    desc "The alias name containing the the keys to use in the keystore"
    defaultto("management-ssl")
  end

  newproperty(:key_password) do
    desc "The key password"
    defaultto(:nil)
  end

  validate do
    errors = []
    errors.push( "Attribute 'engine_path' is mandatory !" ) if !@parameters.include?(:engine_path)
    errors.push( "Attribute 'nic' is mandatory !" ) if !@parameters.include?(:nic)
    errors.push( "Attribute 'management_realm_name' is mandatory !" ) if !@parameters.include?(:management_realm_name)
    raise Puppet::Error, errors.inspect if !errors.empty?
  end

end
