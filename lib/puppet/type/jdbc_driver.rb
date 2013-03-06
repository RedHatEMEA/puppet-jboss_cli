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
    isrequired
  end

  newparam(:driver_name) do
    desc "The JDBC Driver name."

  end

  newparam(:driver_module_name) do
    desc "The JDBC Driver Module name."
  end

  newparam(:driver_class_name) do
    desc "The JDBC Driver Class name."
  end

  newparam(:driver_xa_datasource_class_name) do
    desc "The JDBC Driver XA Datasource Class name."
  end


end
