require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:web_connector) do
  @doc = "Manages JBoss Web connectors"

  ensurable

  def munge_boolean(value)
    case value
    when true, "true", :true, 'true'
      return :true
    when false, "false", :false, 'false'
      return :false
    else
      fail("This parameter only takes booleans")
    end
  end

  newparam(:name, :namevar => true) do
    desc "The connector's name."
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
  end

  newparam(:connector_name) do
    desc "The connector's name."
  end

  newproperty(:socket_binding) do
    desc "The socket-binding on which this connector will be attached."

    defaultto(:nil)
  end

  newproperty(:secure) do
    desc "Wheter this connector is secured or not. \
      The default value is false."

    newvalues(:true, :false)
    defaultto(:false)
    # Convert Raw data to Typed data
    munge do |value|
      return @resource.munge_boolean(value)
    end
  end

  newproperty(:protocol) do
    desc "The protocol used on this connector and its version."

    defaultto("HTTP/1.1")
  end

  newproperty(:scheme) do
    desc "The scheme used on this connector."

    defaultto("http")
    newvalues("http", "https")
    # Convert Raw data to Typed data
    munge do |value|
      return String(value)
    end
  end

  newproperty(:redirect_port) do
    desc "The redirection port to use when the connector is not secured."
    # BUG into JBoss EAP 6 : the redirect port default value is 8443.
    # So we must use the same incorrect default value.
    defaultto("8433")
    
    validate do |value|
      unless value == :nil or String(value) =~ /^[1-9][0-9]*$/
        raise ArgumentError , "#{value} is not a valid 'redirect_port' value (not an integer)."
      end
    end
    # If not undefined, convert to Integer
    munge do |value|
      return value if value == :nil
      return Integer(value)
    end
  end

  newproperty(:proxy_name) do
    desc "The fqdn of the proxy which is upstream to this jboss instance. \
      The given value is used by the jboss instance build absolute location \
      in 302 responses."

    defaultto(:nil)
  end

  newproperty(:proxy_port) do
    desc "The port on the proxy which is upstrean to this jboss instance.
      The given value is used by the jboss instance build absolute location \
      in 302 reisponses."

    defaultto(:nil)
    
    validate do |value|
      unless value == :nil or String(value) =~ /^[1-9][0-9]*$/
        raise ArgumentError , "#{value} is not a valid 'proxy_port' value (not an integer)."
      end
    end
    # If not undefined, convert to Integer
    munge do |value|
      return value if value == :nil
      return Integer(value)
    end
  end

  validate do
    errors = []
    errors.push( "Attribute 'engine_path' is mandatory !" ) if !@parameters.include?(:engine_path)
    errors.push( "Attribute 'nic' is mandatory !" ) if !@parameters.include?(:nic)
    errors.push( "Attribute 'connector_name' is mandatory !" ) if !@parameters.include?(:connector_name)
    raise Puppet::Error, errors.inspect if !errors.empty?
  end

end
