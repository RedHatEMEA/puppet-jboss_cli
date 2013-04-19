require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:datasource) do
  @doc = "Manages non xa datasources via JBoss-cli.sh."

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
    desc "The datasource name."
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
  end

  newparam(:ds_name) do
    desc "A String, which is the datasource name."
  end

  newproperty(:jndi_name) do
    desc "A String, which specifies the JNDI name of this datasource. \
      The given string must begin with 'java:/' or 'java:jboss/'."

    defaultto(:nil)

    validate do |value|
      unless value =~ /^java:jboss\/([\/\-_0-9a-zA-Z]+)$/ or
        value =~ /^java:\/([\/\-_0-9a-zA-Z]+)$/ or
        value == :nil
        raise ArgumentError , "#{value} is not a valid jndi name."
      end
    end
  end

  newproperty(:driver_name) do
    desc "A String, which specifies the name of the JDBC Driver this \
      datasource will use. \
      Note that a JDBC Driver with the given name must exists."

    defaultto(:nil)
  end

  newproperty(:connection_url) do
    desc "A String, which specifies the Connection URL of this datasource. \
      The given string must repect a specific format, regarding refered JDBC Driver. \
      Ex : \
        - for oracle : 'jdbc:oracle:*:@ip:*:*' ; \
        - for db2    : 'jdbc:db2:*:@ip:*:*' ; \
        - for mssql  : 'jdbc:sqlserver:*:@ip:*:*' ; \
        - for h2     : 'jdbc:h2:*:@ip:*:*' ;"

    defaultto(:nil)

    validate do |value|
      unless value =~ /^jdbc:oracle:\w*:@[0-9a-zA-Z]+([\-.][0-9a-zA-Z]+)*:\d{1,}:[0-9a-zA-Z]+$/ or
        value =~ /^jdbc:db2:\/\/[0-9a-zA-Z]+([\-.][0-9a-zA-Z]+)*:\d{1,}\/[0-9a-zA-Z]+$/ or
        value =~ /^jdbc:sqlserver:\/\/[0-9a-zA-Z]+([\-.][0-9a-zA-Z]+)*:\d{1,}\/[0-9a-zA-Z]+$/ or
        value =~ /^jdbc:h2:/ or
        value == :nil
        raise ArgumentError , "#{value} is not a valid connection url."
      end
    end
  end

  newproperty(:user_name) do
    desc "The datasource username."

    defaultto(:nil)
  end

  newparam(:password) do
    desc "The datasource password. The password is a Puppet Param (and not a \
      Puppet Property), because we only want to set it on creation. \
      After its creation, it will not be managed by Puppet."

    defaultto(:nil)
  end

  newproperty(:min_pool_size) do
    desc "An Integer, which defines the minimum number of connections in a pool."

    defaultto("0") # same as jboss default value

    validate do |value|
      unless value == :nil or value =~ /^[0-9]+$/
        raise ArgumentError , "#{value} is not a valid 'min-pool-size' value (not an integer)."
      end
    end
    # If not undefined, convert to Integer
    munge do |value|
      return value if value == :nil
      return Integer(value)
    end
  end

  newproperty(:max_pool_size) do
    desc "An Integer, which defines the maximum number of connections in a pool."

    defaultto("20") # same as jboss default value

    validate do |value|
      unless value == :nil or value =~ /^[1-9][0-9]*$/
        raise ArgumentError , "#{value} is not a valid 'max-pool-size' value (not a strictly positive integer)."
      end
      unless value == :nil or resource[:min_pool_size] == :nil or Integer(value) >= Integer(resource[:min_pool_size])
        raise ArgumentError , "#{value} is not a valid 'max-pool-size' value (can't be <'min-pool-size')."
      end
    end
    # If not undefined, convert to Integer
    munge do |value|
      return value if value == :nil
      return Integer(value)
    end
  end

  newproperty(:pool_prefill) do
    desc "A Boolean, which specifies if the connection pool is prefilled or not. \
      The default is true."

    newvalues(:true, :false)
    defaultto(:true)
    # Convert Raw data to Typed data
    munge do |value|
      return @resource.munge_boolean(value)
    end
  end

  newproperty(:pool_use_strict_min) do
    desc "A Boolean, which defines if the min-pool-size should be considered a \
      strictly way. \
      The default is true."

    newvalues(:true, :false)
    defaultto(:true)
    # Convert Raw data to Typed data
    munge do |value|
      return @resource.munge_boolean(value)
    end
  end

  newproperty(:idle_timeout_minutes) do
    desc "An Integer, which defines the maximum time in minutes a connection \
      may be idle before being closed. \
      /!\ \
      Due to a bug in the datasource subsystem, this attribute cannot be removed. \
      The only solution is to destroy the datasource's resource (e.g. 'absent') \
      with a first puppet run, and to create the datasource's resource (e.g. 'present') \
      without this attribute with a second puppet run."

    defaultto(:nil)

    validate do |value|
      unless value == :nil or value =~ /^[0-9]+$/
        raise ArgumentError , "#{value} is not a valid 'idle-timeout-minutes' value (not an integer)."
      end
    end
    # If not undefined, convert to Integer
    munge do |value|
      return value if value == :nil
      return Integer(value)
    end
  end

  newproperty(:query_timeout) do
    desc "Any configured query timeout in seconds. Must be in Integer."

    defaultto(:nil)

    validate do |value|
      unless value == :nil or String(value) =~ /^[0-9]+$/
        raise ArgumentError , "#{value} is not a valid 'query-timeout' value (not an integer)."
      end
    end
    # If not undefined, convert to Integer
    munge do |value|
      return value if value == :nil
      return Integer(value)
    end
  end

  newproperty(:prepared_statements_cache_size) do
    desc "The number of prepared statements per connection in an LRU cache. \
      Must be an Integer."

    defaultto("200")

    validate do |value|
      unless value == :nil or value =~ /^[0-9]+$/
        raise ArgumentError , "#{value} is not a valid 'prepared-statements-cache-size' value (not an integer)."
      end
    end
    # If not undefined, convert to Integer
    munge do |value|
      return value if value == :nil
      return Integer(value)
    end
  end

  newproperty(:share_prepared_statements) do
    desc "A Boolean. Whether to share prepare statements, i.e. whether asking \
      for same statement twice without closing uses the same underlying \
      prepared statement. The default is true."

    newvalues(:true, :false)
    defaultto(:true)
    # Convert Raw data to Typed data
    munge do |value|
      return @resource.munge_boolean(value)
    end
  end

  newproperty(:background_validation) do
    desc "A Boolean. Performs or not Background Validation. \
      The default is true."

    newvalues(:true, :false)
    defaultto(:true)
    # Convert Raw data to Typed data
    munge do |value|
      return @resource.munge_boolean(value)
    end
  end

  newproperty(:use_java_context) do
    desc "A boolean. If java context (java:jboss/ or java:) must be pre-pended \
      to datasource JNDI name. \
      The default is true."

    newvalues(:true, :false)
    defaultto(:true)
    # Convert Raw data to Typed data
    munge do |value|
      return @resource.munge_boolean(value)
    end
  end

  newproperty(:valid_connection_checker_class_name) do
    desc "Valid Connection Checker Class Name"
    newvalues("org.jboss.jca.adapters.jdbc.extensions.db2.DB2ValidConnectionChecker",
              "org.jboss.jca.adapters.jdbc.extensions.oracle.OracleValidConnectionChecker",
              "org.jboss.jca.adapters.jdbc.extensions.mssql.MSSQLValidConnectionChecker",
              :nil)
    defaultto {
      case @resource[:driver_name]
      when /^db2$/
        "org.jboss.jca.adapters.jdbc.extensions.db2.DB2ValidConnectionChecker"
      when /^oracle-ojdbc6$/
        "org.jboss.jca.adapters.jdbc.extensions.oracle.OracleValidConnectionChecker"
      when /^sqlserver$/
        "org.jboss.jca.adapters.jdbc.extensions.mssql.MSSQLValidConnectionChecker"
      else
        :nil
      end
    }
    # Convert Raw data to Typed data
    munge do |value|
      return value if value == :nil
      return String(value)
    end
  end

  validate do
    errors = []
    errors.push("Attribute 'engine_path' is mandatory !") if !@parameters.include?(:engine_path)
    errors.push("Attribute 'nic' is mandatory !") if !@parameters.include?(:nic)
    errors.push("Attribute 'ds_name' is mandatory !") if !@parameters.include?(:ds_name)
    raise Puppet::Error, errors.inspect if( !errors.empty? )
  end

end
