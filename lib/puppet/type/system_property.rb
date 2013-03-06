require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/redhat/jboss'

Puppet::Type.newtype(:system_property) do
  @doc = "Manages System-property via JBoss-cli.sh"

  ensurable

  newparam(:name, :namevar => true) do
    desc "The datasource name."
  end

  newparam(:engine_path) do
    desc "The path of the JBoss Engine"
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
    isrequired
  end

  newparam(:sp_name) do
    desc "The System Property name"
  end

  newproperty(:value) do
    desc "The system property value"
  end
end
