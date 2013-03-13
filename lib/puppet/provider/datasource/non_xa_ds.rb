require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:datasource).provide(:non_xa_ds) do
  include PuppetX::Jboss
  @doc = "Manages non-xa Datasources for an instance with the jboss-cli.sh"

  confine :osfamily => :redhat

  def get_current_attr_values
    current_attr = {}
    path = "/subsystem=datasources/data-source=#{@resource[:ds_name]}"
    operation = "read-resource"
    params = ""
    output = PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path],
                                                  @resource[:nic],
                                                  path,
                                                  operation,
                                                  params)
    output.split("\n").collect do |line|
      val = line.delete(" ")
      if ! ((val.start_with?("\"outcome\"")or
             val.start_with?("\"result\"")  or
             val.start_with?("{")           or
             val.start_with?("}")           or
             val.start_with?("\"response-headers\"")))

        val = val.split("=>")
        mykey = val[0].delete("\"")
        mykey = mykey.gsub("-", "_")
        myval = val[1].delete("\"")
        myval = myval.chomp(",")
        current_attr.store(mykey, myval)
      end
    end
    attr_to_be_updated(current_attr)
  end

  def attr_to_be_updated(current={})
    desired_values = {}
    hashparams = get_desired_attr_values_from_type
    hashparams.each do |key, value|
      if current.key?(key) and
         current[key] != value
        desired_values.store(key, value)
      end
    end
    update_params(desired_values, current)
  end

  def update_params(desire={}, current={})
    cmds = []
    path = "/subsystem=datasources/data-source=#{@resource[:ds_name]}"
    operation = "write-attribute"
    desire.each do |key, value|
      cmds << path + ":" + operation + "(name=#{key.gsub("_","-")},value=#{value})"
    end
    if cmds.length >= 1
      PuppetX::Jboss.run_jboss_cli_commands(@resource[:engine_path],
                                            @resource[:nic],
                                            cmds)
      desire.each do |key, value|
        Puppet.notice("/Datasource[#{@resource[:name]}/#{key.gsub("_","-")}] changed from #{current[key]} to #{value}")
      end
    end
  end

  def get_desired_attr_values_from_type
    params = {"driver_name"=>"#{@resource[:driver_name]}",
              "min_pool_size"=>"#{@resource[:min_pool_size]}",
              "max_pool_size"=>"#{@resource[:max_pool_size]}",
              "pool_prefill"=>"#{@resource[:pool_prefill]}",
              "pool_use_strict_min"=>"#{@resource[:pool_use_strict_min]}",
              "user_name"=>"#{@resource[:user_name]}",
              "idle_timeout_minutes"=>"#{@resource[:idle_timeout_minutes]}",
              "query_timeout"=>"#{@resource[:query_timeout]}",
              "prepared_statements_cache_size"=>"#{@resource[:prepared_statements_cache_size]}",
              "share_prepared_statements"=>"#{@resource[:share_prepared_statements]}",
              "background_validation"=>"#{@resource[:background_validation]}",
              "valid_connection_checker_class_name"=>"#{@resource[:valid_connection_checker_class_name]}",
              "use_java_context"=>"#{@resource[:use_java_context]}"
             }
    return params
  end

  def create
    jndi_name = "jndi-name=#{@resource[:jndi_name]}"
    conn_url = "connection-url=#{@resource[:connection_url]}"
    dri_name = "driver-name=#{@resource[:driver_name]}"
    min_pool_size = "min-pool-size=#{@resource[:min_pool_size]}"
    max_pool_size = "max-pool-size=#{@resource[:max_pool_size]}"
    pool_prefill = "pool-prefill=#{@resource[:pool_prefill]}"
    pool_use_strict_min = "pool-use-strict-min=#{@resource[:pool_use_strict_min]}"
    user_name = "user-name=#{@resource[:user_name]}"
    password = "password=#{@resource[:password]}"
    idle_timeout_min = "idle-timeout-minutes=#{@resource[:idle_timeout_minutes]}"
    query_timeout = "query-timeout=#{@resource[:query_timeout]}"
    prepared_statements_cache_size = "prepared-statements-cache-size=#{@resource[:prepared_statements_cache_size]}"
    share_prepared_statements = "share-prepared-statements=#{@resource[:share_prepared_statements]}"
    background_validation = "background-validation=#{@resource[:background_validation]}"
    use_java_context = "use-java-context=#{@resource[:use_java_context]}"
    val_con_checker_cls_name = ""

    if !"#{@resource[:valid_connection_checker_class_name]}".empty?
      val_con_checker_cls_name = "valid-connection-checker-class-name=#{@resource[:valid_connection_checker_class_name]}"
    end

    path = "/subsystem=datasources/data-source=#{@resource[:ds_name]}"
    operation = "add"
    params = "#{jndi_name},#{conn_url},#{dri_name},#{min_pool_size},\
      #{max_pool_size},#{pool_prefill},#{pool_use_strict_min},#{user_name},\
      #{password},#{idle_timeout_min},#{query_timeout},#{prepared_statements_cache_size},\
      #{share_prepared_statements},#{background_validation},#{use_java_context},\
      #{val_con_checker_cls_name}"

    if jdbc_driver_exists?("#{@resource[:driver_name]}")
      debug "Creating Non-XA Datasource"
      PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    else
      fail "No #{@resource[:driver_name]} JDBC Driver found!"
    end
  end

  def destroy
    debug "Test Destroy def"
    path = "/subsystem=datasources/data-source=#{@resource[:ds_name]}"
    operation = "remove"
    params = ""
    PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def exists?
    debug "Debug exists? def"
    path = "/subsystem=datasources/data-source=#{@resource[:ds_name]}"
    operation = "read-resource"
    params = ""
    begin
      PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
      get_current_attr_values
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def jdbc_driver_exists?(driver)
    debug "Does JDBC driver exist ?"
    path = "/subsystem=datasources/jdbc-driver=#{driver}"
    operation = "read-resource"
    params = ""
    begin
      PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    rescue Puppet::ExecutionFailure => e
      false
    end
  end
end
