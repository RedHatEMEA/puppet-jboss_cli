require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:management_interface) do
  @doc = "Manages management interfaces"
  ensurable


  newparam(:name, :namevar => true) do
    desc "The vault name (only used to uniquely identify a vault in puppet).\
          There can only be one vault per instance"
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
    isrequired
  end

  newparam(:management_interface_name) do
    desc "The management interface name."
    newvalues('native-interface')
    newvalues('http-interface')
  end

  newproperty(:socket_binding) do
    desc "The name of the socket binding configuration to use for the management interface's socket."
  end

  newproperty(:secure_socket_binding) do
    desc "The name of the socket binding configuration to use for the HTTPS management interface's socket."
  end

  newproperty(:security_realm) do
    desc "The security realm to use for the management interface."
  end

end

