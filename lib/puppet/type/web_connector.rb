require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:web_connector) do
  @doc = "Manages JBoss Web connectors"

  ensurable
  def munge_boolean(value)
    case value
    when true, "true", :true
      :true
    when false, "false", :false
      :false
    else
      fail("This parameter only takes booleans")
    end
  end

  newparam(:name, :namevar => true) do
    desc "The connector's name."
  end
  newparam(:connector_name) do
    desc "The connector's name."
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
    isrequired
  end

  newproperty(:socket_binding) do
    desc "The socket-binding on which this connector will be attached."
    isrequired
  end

  newproperty(:secure) do
    desc "Wheter this connector is secured or not. on an SSL Connector or a \
        non SSL connector that is receiving data from a SSL accelerator, \
        like a crypto card, a SSL appliance or even a webserver. The default \
        value is false."
    defaultto :false
  end


  newproperty(:protocol) do
    desc "The protocol used on this connector and its version."
    defaultto :"HTTP/1.1"
  end

  newproperty(:scheme) do
    desc "The scheme used on this connector."
    isrequired
    newvalues("http", "https")
  end

  newproperty(:redirect_port) do
    desc "The redirection port to use when the connector is not secured"
  end

end
