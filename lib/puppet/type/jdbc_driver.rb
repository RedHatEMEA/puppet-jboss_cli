require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:jdbc_driver) do
  @doc = "Manages jdbc driver via JBoss-cli.sh"

  ensurable

  newparam(:name, :namevar => true) do
    desc "The JDBC Driver Name."
  end

  newparam(:engine_path) do
    desc "The JBoss Engine Path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
  end

  newparam(:driver_name) do
    desc "The JDBC Driver name. Read-only."
  end

  newparam(:driver_module_name) do
    desc "The JDBC Driver Module name. Read-only."
  end

  newparam(:driver_module_slot) do
    desc "The JDBC Driver Module slot. Read-only."
    defaultto(:nil)
  end

  newparam(:driver_class_name) do
    desc "The JDBC Driver Class name. Read-only."
    defaultto(:nil)
  end

  newparam(:driver_xa_datasource_class_name) do
    desc "The JDBC Driver XA Datasource Class name. Read-only."
    defaultto(:nil)
  end

  validate do
    errors = []
    errors.push( "Attribute 'engine_path' is mandatory !" ) if !@parameters.include?(:engine_path)
    errors.push( "Attribute 'nic' is mandatory !" ) if !@parameters.include?(:nic)
    errors.push( "Attribute 'driver_name' is mandatory !" ) if !@parameters.include?(:driver_name)
    errors.push( "Attribute 'driver_module_name' is mandatory !" ) if !@parameters.include?(:driver_module_name)
    raise Puppet::Error, errors.inspect if !errors.empty?
  end

end
