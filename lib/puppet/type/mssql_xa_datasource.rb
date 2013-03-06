require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:mssql_xa_datasource) do
  @doc = "Manages mssql xa datasources via JBoss-cli.sh"

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
    desc "The JBoss Engine path"
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."

    isrequired
  end

  newparam(:ds_name) do
    desc "The datasource name."
  end

  newparam(:no_tx_separate_pool) do
    desc "Oracle does not like XA connections getting used both inside and outside a JTA transaction. To workaround the problem you can create separate sub-pools for the different contexts."

    defaultto :true
    newvalues(:true, :false)

    munge do |value|
      @resource.munge_boolean(value)
    end
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

  newproperty(:min_pool_size) do
    desc "Minimum number of connections in a pool"

    validate do |value|
      unless value =~ /^[0-9]+$/
        raise ArgumentError , "#{value} is not a valid min-pool-size value."
      end
    end
  end

  newproperty(:max_pool_size) do
    desc "Maximum number of connections in a pool"

    validate do |value|
      unless value =~ /^[0-9]+$/
        raise ArgumentError , "#{value} is not a valid max-pool-size value."
      end
    end
  end

  newproperty(:idle_timeout_minutes) do
    desc "The idle-timeout-minutes elements indicates the maximum time in minutes a connection may be idle before being closed. Must be an Integer."

    validate do |value|
      unless value =~ /^[0-9]+$/
        raise ArgumentError , "#{value} is not a valid idle-timeout-minutes value."
      end
    end
  end

  newproperty(:query_timeout) do
    desc "Any configured query timeout in seconds. Must be in Integer."

    validate do |value|
      unless value =~ /^[0-9]+$/
        raise ArgumentError , "#{value} is not a valid query-timeout value."
      end
    end
  end

  newproperty(:driver_name) do
    desc "An unique name for the JDBC driver specified in the drivers section."

    isrequired
  end

  newproperty(:server_name) do
    desc "The database server name."
  end

  newproperty(:database_name) do
    desc "The database name."
  end

  newproperty(:driver_type) do
    desc "The Driver type."

    newvalues(1, 2, 3, 4)
  end

  newproperty(:user) do
    desc "The datasource username."
  end

  newparam(:password) do
    desc "The datasource password. The password is set a param and not a \
          property, because we only want to set it on creation. Then it \
          can be changed by other mechanism."

    isrequired
  end

  newproperty(:background_validation) do
    desc "Background Validation. The default is true."

    defaultto :true
    newvalues(:true, :false)

    munge do |value|
      @resource.munge_boolean(value)
    end
  end

  newparam(:valid_connection_checker_class_name) do
    desc "Valid Connection Checker Class Name"

    defaultto "org.jboss.jca.adapters.jdbc.extensions.mssql.MSSQLValidConnectionChecker"
    newvalues("org.jboss.jca.adapters.jdbc.extensions.mssql.MSSQLValidConnectionChecker")
  end

end
