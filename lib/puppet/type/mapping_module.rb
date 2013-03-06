require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:mapping_module) do
  @doc = "Manages mapping modules via jboss-cli.sh"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Contains the name of a JAAS Security-manager which handles authentication."
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."

    isrequired
  end

  newparam(:security_domain) do
    desc "Security Domain Name."

    isrequired
  end

  newparam(:mapping_module) do
    desc "Module Options."

  end

end
