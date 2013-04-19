require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:logger) do
  @doc = "Manages JBoss loggers"

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
    desc "The logger's name."
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
  end

  newparam(:logger_name) do
    desc "The logger's name."
  end

  newproperty(:level) do
    desc "The level to use for logging"
    newvalues("ALL","FINEST","FINER","TRACE","DEBUG","FINE","CONFIG","INFO","WARN","WARNING","ERROR","FATAL","OFF")
    defaultto("INFO")
    # Convert Raw data to Typed data
    munge do |value|
      return String(value)
    end
  end

  newproperty(:handlers, :array_matching => :all , :parent => Puppet::Property::UnorderedArray) do
    desc "An array containing the handlers handling this logger"
    # Redefine this methods to refine comparison of current value and new value
    def should_to_s(newvalue)
      newvalue.inspect
    end
    def is_to_s(currentvalue)
      currentvalue.inspect
    end
    defaultto :nil
  end

  newproperty(:use_parent_handlers) do
    desc "Does this logger also log in parent handlers ?"
    newvalues(:true, :false)
    defaultto(:false)
    munge do |value|
      @resource.munge_boolean(value)
    end
  end

  validate do
    errors = []
    errors.push( "Attribute 'engine_path' is mandatory !" ) if !@parameters.include?(:engine_path)
    errors.push( "Attribute 'nic' is mandatory !" ) if !@parameters.include?(:nic)
    errors.push( "Attribute 'logger_name' is mandatory !" ) if !@parameters.include?(:logger_name)
    raise Puppet::Error, errors.inspect if !errors.empty?
  end

end
