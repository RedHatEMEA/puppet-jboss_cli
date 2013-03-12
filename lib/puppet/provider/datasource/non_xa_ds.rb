require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:datasource).provide(:non_xa_ds) do
  include PuppetX::Jboss
  @doc = "Manages non-xa Datasources for an instance with the jboss-cli.sh"

  confine :osfamily => :redhat

  def get_current_attr_values
    debug "\n\nGet Current parameters\n\n"
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

  def attr_to_be_updated(h={})
    debug "\n\nis there some parameters to be updated\n\n"
    has_to_be_updated = {}
    hashparams = get_desired_attr_values_from_type
    hashparams.each do |key, value|
      if h.key?(key) and 
        h[key] != value
        has_to_be_updated.store(key, value)
      end
    end
    update_params(has_to_be_updated)
  end

  def update_params(h={})
    debug "\n\nUpdate parameters\n\n"
    cmds = []
    path = "/subsystem=datasources/data-source=#{@resource[:ds_name]}"
    operation = "write-attribute"
    h.each do |key, value|
      cmds << path + ":" + operation + "\\(name=#{key.gsub("_","-")},value=#{value}\\)"
    end
    PuppetX::Jboss.run_jboss_cli_commands(@resource[:engine_path],
                                          @resource[:nic],
                                          cmds)
  end

  def get_desired_attr_values_from_type
    debug "Create Hash from parameters type"
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
    subsys = "/subsystem=datasources"
    ds = "data-source=#{@resource[:ds_name]}"
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

    if "#{@resource[:valid_connection_checker_class_name]}".empty?
      cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{subsys}/#{ds}:add\(#{jndi_name},#{conn_url},#{dri_name},#{min_pool_size},#{max_pool_size},#{pool_prefill},#{pool_use_strict_min},#{user_name},#{password},#{idle_timeout_min},#{query_timeout},#{prepared_statements_cache_size},#{share_prepared_statements},#{background_validation},#{use_java_context}\)"
      ]
    else
      val_con_checker_cls_name = "valid-connection-checker-class-name=#{@resource[:valid_connection_checker_class_name]}"
      cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{subsys}/#{ds}:add\(#{jndi_name},#{conn_url},#{dri_name},#{min_pool_size},#{max_pool_size},#{pool_prefill},#{pool_use_strict_min},#{user_name},#{password},#{idle_timeout_min},#{query_timeout},#{prepared_statements_cache_size},#{share_prepared_statements},#{background_validation},#{use_java_context},#{val_con_checker_cls_name}\)"
      ]
    end

    if jdbc_driver?("#{@resource[:driver_name]}")
      debug "Creating Non-XA Datasource"
      PuppetX::Jboss.run_command(cmd)
    else
      fail "No #{@resource[:driver_name]} JDBC Driver found!"
    end
  end

  def destroy
    debug "Test Destroy def"
    subsys = "/subsystem=datasources"
    ds = "data-source=#{@resource[:ds_name]}"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:remove"
    ]
    PuppetX::Jboss.run_command(cmd)
  end

  def exists?
    debug "Debug exists? def"
    subsys = "/subsystem=datasources"
    ds = "data-source=#{@resource[:ds_name]}"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:read-resource"
    ]
    begin
      PuppetX::Jboss.run_command(cmd)
      get_current_attr_values
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def jdbc_driver?(driver)
    debug "Does JDBC driver exist ?"
    subsys = "/subsystem=datasources"
    jdbc_dri = "jdbc-driver=#{driver}"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{jdbc_dri}:read-resource"
    ]
    begin
      PuppetX::Jboss.run_command(cmd)
    rescue Puppet::ExecutionFailure => e
      false
    end
  end
end
