require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:single_mapping_module) do
  @doc = "Manages JaaS Security Domain single mapping module via jboss-cli.sh"

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
    desc "Contains the name of a JAAS Security-manager which handles authentication."
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
    isrequired
  end

  newparam(:security_domain_name) do
    desc "The security domain to attach this mapping module"
    isrequired
  end

  newparam(:type) do
    desc "The mapping module type: On which part of the principal the mapping module acts."
    defaultto("role")
    newvalues("role", "principal")
  end

  newparam(:module) do
    desc "The module name containing this mapping-module (optional)"
  end

  newparam(:code) do
    desc "code."
    isrequired
  end

  newproperty(:module_options) do
    desc "A map in the form comma separatated \
          {\"key1\" => \"value1\", \"key2\" => \"value2\"} \
          options to pass the module-options of mapping-module"
    validate do |value|
      unless value.kind_of? Hash
        raise ArgumentError, "module_options must be a map in the form \
              comma separatated {\"key1\" => \"value1\", \"key2\" => \"value2\"})\
              options to pass the module-options of mapping-module"
      end
    end

    # Redefine this methods to refine comparison of current value and new value
    def should_to_s(newvalue)
      newvalue.inspect
    end
    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end
end


