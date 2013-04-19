require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:authentication_realm) do
  @doc = "Manages authentication realms for management consoles"
  ensurable


  newparam(:name, :namevar => true) do
    desc "The name of the management realm"
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
    isrequired
  end

  newparam(:management_realm_name) do
    desc "The management realm: e.g: HttpManagementRealm"
  end

end

