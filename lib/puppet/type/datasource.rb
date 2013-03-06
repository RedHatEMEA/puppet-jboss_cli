require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/redhat/jboss'

Puppet::Type.newtype(:datasource) do
  @doc = "Manages non xa datasources via JBoss-cli.sh"

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
    desc "The datasource name."
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
    isrequired
  end

  newparam(:ds_name) do
    desc "The datasource name."
  end

  newparam(:jndi_name) do
    desc "Specifies the JNDI name for the datasource."

    validate do |value|
      unless value =~ /^java:jboss\/([\/\-_0-9a-zA-Z]+)$/ or
        value =~ /^java:\/([\/\-_0-9a-zA-Z]+)$/
        raise ArgumentError , "#{value} is not a valid jndi name."
      end
    end
  end

  newparam(:connection_url) do
    desc "The JDBC driver connection URL."

    validate do |value|
      unless value =~ /^jdbc:oracle:\w*:@[0-9a-zA-Z]+([\-.][0-9a-zA-Z]+)*:\d{1,}:[0-9a-zA-Z]+$/ or
        value =~ /^jdbc:db2:\/\/[0-9a-zA-Z]+([\-.][0-9a-zA-Z]+)*:\d{1,}\/[0-9a-zA-Z]+$/ or
        value =~ /^jdbc:sqlserver:\/\/[0-9a-zA-Z]+([\-.][0-9a-zA-Z]+)*:\d{1,}\/[0-9a-zA-Z]+$/ or
        value =~ /^jdbc:h2:/
        raise ArgumentError , "#{value} is not a valid connection url."
      end
    end
  end

  newparam(:driver_name) do
    desc "An unique name for the JDBC driver specified in the drivers section."
    isrequired
  end

  newparam(:min_pool_size) do
    desc "Minimum number of connections in a pool"

    validate do |value|
      unless value =~ /^[0-9]+$/
        raise ArgumentError , "#{value} is not a valid min-pool-size value."
      end
    end
  end

  newparam(:max_pool_size) do
    desc "Maximum number of connections in a pool"

    validate do |value|
      unless value =~ /^[0-9]+$/
        raise ArgumentError , "#{value} is not a valid max-pool-size value."
      end
    end
  end

  newparam(:pool_prefill) do
    desc "Whether to attempt to prefill the connection pool. The default \
    is true."

    defaultto :true
    newvalues(:true, :false)

    munge do |value|
      @resource.munge_boolean(value)
    end
  end

  newparam(:pool_use_strict_min) do
    desc "Define if the min-pool-size should be considered a strictly. The \
    default is true."

    defaultto :true
    newvalues(:true, :false)

    munge do |value|
      @resource.munge_boolean(value)
    end
  end

  newparam(:user_name) do
    desc "The datasource username."

    isrequired
  end

  newparam(:password) do
    desc "The datasource password. The password is set a param and not a \
          property, because we only want to set it on creation. Then it \
          can be changed by other mechanism."

    isrequired
  end

  newparam(:idle_timeout_minutes) do
    desc "The idle-timeout-minutes elements indicates the maximum time in  \
          minutes a connection may be idle before being closed. Must be an Integer."

    validate do |value|
      unless value =~ /^[0-9]+$/
        raise ArgumentError , "#{value} is not a valid idle-timeout-minutes value."
      end
    end
  end

  newparam(:query_timeout) do
    desc "Any configured query timeout in seconds. Must be in Integer."

    validate do |value|
      unless value =~ /^[0-9]+$/
        raise ArgumentError , "#{value} is not a valid query-timeout value."
      end
    end
  end

  newparam(:prepared_statements_cache_size) do
    desc "The number of prepared statements per connection in an LRU cache. Must be an Integer."

    validate do |value|
      unless value =~ /^[0-9]+$/
        raise ArgumentError , "#{value} is not a valid prepared-statements-cache-size value."
      end
    end
  end

  newparam(:share_prepared_statements) do
    desc "Whether to share prepare statements, i.e. whether asking for same statement twice without closing uses the same underlying prepared statement. The default is true."

    defaultto :true
    newvalues(:true, :false)

    munge do |value|
      @resource.munge_boolean(value)
    end
  end

  newparam(:background_validation) do
    desc "Background Validation. The default is true."

    defaultto :true
    newvalues(:true, :false)

    munge do |value|
      @resource.munge_boolean(value)
    end
  end

  newparam(:valid_connection_checker_class_name) do
    desc "Valid Connection Checker Class Name"

    defaultto {
      case @resource[:driver_name]
      when /^db2$/
        "org.jboss.jca.adapters.jdbc.extensions.db2.DB2ValidConnectionChecker"
      when /^oracle-ojdbc6$/
        "org.jboss.jca.adapters.jdbc.extensions.oracle.OracleValidConnectionChecker"
      when /^sqlserver$/
        "org.jboss.jca.adapters.jdbc.extensions.oracle.OracleValidConnectionChecker"
      else
        nil
      end
    }
  end

  newparam(:use_java_context) do
    desc "If java context (java:jboss/ our java:) must be appended to datasource JNDI name. The default is true."
    defaultto :true
    newvalues(:true, :false)
    munge do |value|
      @resource.munge_boolean(value)
    end
  end

end
