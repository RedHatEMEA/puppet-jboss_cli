require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:management_realm) do
  @doc = "Manages Management Realms for management consoles"

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
    desc "The management realm: e.g: HttpManagementRealm. \
      /!\ After a it has been destroyed (e.g. ensure => absent), the server \
      must be (manually) reloaded."
  end

  validate do
    errors = []
    errors.push( "Attribute 'engine_path' is mandatory !" ) if !@parameters.include?(:engine_path)
    errors.push( "Attribute 'nic' is mandatory !" ) if !@parameters.include?(:nic)
    errors.push( "Attribute 'management_realm_name' is mandatory !" ) if !@parameters.include?(:management_realm_name)
    raise Puppet::Error, errors.inspect if !errors.empty?
  end
end

