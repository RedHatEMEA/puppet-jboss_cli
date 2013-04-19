require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:log_handler) do
  @doc = "Manages JBoss log handlers"

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
    desc "The resource name"
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
  end

  newparam(:type) do
    desc "The logger's type."
    newvalues("async-handler", "console-handler", "custom-handler")
    newvalues("file-handler", "size-rotating-file-handler")
    newvalues("periodic-rotating-file-handler")
    # Convert Raw data to Typed data
    munge do |value|
      return String(value)
    end
  end

  newparam(:handler_name) do
    desc "The handler's name."
  end

  newproperty(:formatter) do
    desc "The format to use."
    defaultto("%d{dd/MM/yyy HH:mm:ss,SSS} %-5p [%c#] (%t) %s%E%n")
  end

  newproperty(:level) do
    desc "The level to use for logging"
    defaultto("INFO")
    newvalues("INFO","DEBUG","TRACE","ERROR")
    # Convert Raw data to Typed data
    munge do |value|
      return String(value)
    end
  end

  newproperty(:custom_options) do
    desc "A map of additional options specific to the handler"
    # Redefine this methods to refine comparison of current value and new value
    def should_to_s(newvalue)
      newvalue.inspect.gsub('\\', '')
    end

    def is_to_s(currentvalue)
      currentvalue.inspect.gsub('\\', '')
    end
  end

end
