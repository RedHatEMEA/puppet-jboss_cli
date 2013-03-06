require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:mssql_xa_datasource).provide(:mssql_xa_ds) do
  include PuppetX::Jboss
  @doc = "Manages SqlServer xa Datasources for an instance with the jboss-cli.sh"

  confine :osfamily => :redhat

  def create
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    no_tx_separate_pool = "no-tx-separate-pool=#{@resource[:no_tx_separate_pool]}"
    min_pool_size = "min-pool-size=#{@resource[:min_pool_size]}"
    max_pool_size = "max-pool-size=#{@resource[:max_pool_size]}"
    idle_timeout_minutes = "idle-timeout-minutes=#{@resource[:idle_timeout_minutes]}"
    query_timeout = "query-timeout=#{@resource[:query_timeout]}"
    jndi_name = "jndi-name=#{@resource[:jndi_name]}"
    dri_name = "driver-name=#{@resource[:driver_name]}"
    background_validation = "background-validation=#{@resource[:background_validation]}"
    val_con_checker_cls_name = "valid-connection-checker-class-name=#{@resource[:valid_connection_checker_class_name]}"
    server_name = "xa-datasource-properties=ServerName:add\(value=#{@resource[:server_name]}\)"
    db_name = "xa-datasource-properties=DatabaseName:add\(value=#{@resource[:database_name]}\)"
    dri_type = "xa-datasource-properties=DriverType:add\(value=#{@resource[:driver_type]}\)"
    user = "xa-datasource-properties=User:add\(value=#{@resource[:user]}\)"
    pwd = "xa-datasource-properties=Password:add\(value=#{@resource[:password]}\)"

    cmd1 = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:add\(#{no_tx_separate_pool},#{jndi_name},#{dri_name},#{background_validation},#{val_con_checker_cls_name},#{min_pool_size},#{max_pool_size},#{idle_timeout_minutes},#{query_timeout}\)"
    ]

    cmd2 = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--commands=#{subsys}/#{ds}/#{server_name},#{subsys}/#{ds}/#{db_name},#{subsys}/#{ds}/#{dri_type},#{subsys}/#{ds}/#{user},#{subsys}/#{ds}/#{pwd}"
    ]

    if jdbc_driver?("#{@resource[:driver_name]}")
      debug "Creating SqlServer XA Datasource"
      PuppetX::Jboss.run_command(cmd1)
      PuppetX::Jboss.run_command(cmd2)
    else
      fail "No #{@resource[:driver_name]} JDBC Driver found!"
    end
  end

  def destroy
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:remove"
    ]
    PuppetX::Jboss.run_command(cmd)
  end

  def exists?
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:read-resource"
    ]
    begin
      PuppetX::Jboss.run_command(cmd)
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def jdbc_driver?(driver)
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

  def server_name
    output = ''
    val = ''
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr = "xa-datasource-properties=ServerName:read-attribute\(name=value\)"
    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}/#{attr}"
    ]
    output = PuppetX::Jboss.run_command(cmd)
    output.split("\n").collect do |line|
       if line.start_with?("    \"result\"")
         val = line.strip
         val = val.split(" => ")
         val = val[1].delete("\",")
       end
    end
    return val
  end

  def server_name=(new_value)
    current_value = server_name()
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr_add = "xa-datasource-properties=ServerName:add\(value=#{new_value}\)"
    attr_del = "xa-datasource-properties=ServerName:remove"

    if current_value != new_value
      if current_value != "undefined"
        cmd = [
          "#{@resource[:engine_path]}/bin/jboss-cli.sh",
          "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
          "--command=#{subsys}/#{ds}/#{attr_del}"
        ]
        PuppetX::Jboss.run_command(cmd)
      end
      cmd2 = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{subsys}/#{ds}/#{attr_add}"
      ]
      PuppetX::Jboss.run_command(cmd2)
    end
  end

  def database_name
    debug "DATABASE NAME GETTER"
    output = ''
    val = ''
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr = "xa-datasource-properties=DatabaseName:read-attribute\(name=value\)"
    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}/#{attr}"
    ]
    output = PuppetX::Jboss.run_command(cmd)
    output.split("\n").collect do |line|
       if line.start_with?("    \"result\"")
         val = line.strip
         val = val.split(" => ")
         val = val[1].delete("\",")
       end
    end
    return val
  end

  def database_name=(new_value)
    current_value = server_name()
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr_add = "xa-datasource-properties=DatabaseName:add\(value=#{new_value}\)"
    attr_del = "xa-datasource-properties=DatabaseName:remove"

    if current_value != new_value
      if current_value != "undefined"
        cmd = [
          "#{@resource[:engine_path]}/bin/jboss-cli.sh",
          "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
          "--command=#{subsys}/#{ds}/#{attr_del}"
        ]
        PuppetX::Jboss.run_command(cmd)
      end
      cmd2 = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{subsys}/#{ds}/#{attr_add}"
      ]
      PuppetX::Jboss.run_command(cmd2)
    end
  end

  def driver_type
    output = ''
    val = ''
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr = "xa-datasource-properties=DriverType:read-attribute\(name=value\)"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}/#{attr}"
    ]
    output = PuppetX::Jboss.run_command(cmd)
    output.split("\n").collect do |line|
       if line.start_with?("    \"result\"")
         val = line.strip
         val = val.split(" => ")
         val = val[1].delete("\",")
       end
    end
    return val
  end

  def driver_type=(new_value)
    current_value = server_name()
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr_add = "xa-datasource-properties=DriverType:add\(value=\"#{new_value}\"\)"
    attr_del = "xa-datasource-properties=DriverType:remove"

    if current_value != new_value
      if current_value != "undefined"
        cmd = [
          "#{@resource[:engine_path]}/bin/jboss-cli.sh",
          "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
          "--command=#{subsys}/#{ds}/#{attr_del}"
        ]
        PuppetX::Jboss.run_command(cmd)
      end
      cmd2 = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{subsys}/#{ds}/#{attr_add}"
      ]
      PuppetX::Jboss.run_command(cmd2)
    end
  end

  def user
    output = ''
    val = ''
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    user = "xa-datasource-properties=User:read-attribute\(name=value\)"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}/#{user}"
    ]

    output = PuppetX::Jboss.run_command(cmd)
    output.split("\n").collect do |line|
       if line.start_with?("    \"result\"")
         val = line.strip
         val = val.split(" => ")
         val = val[1].delete("\",")
       end
    end
    return val
  end

  def user=(new_value)
    current_value = user()
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    user_add = "xa-datasource-properties=User:add\(value=#{new_value}\)"
    user_del = "xa-datasource-properties=User:remove"

    if current_value != new_value
      if current_value != "undefined"
        cmd = [
          "#{@resource[:engine_path]}/bin/jboss-cli.sh",
          "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
          "--command=#{subsys}/#{ds}/#{user_del}"
        ]
        PuppetX::Jboss.run_command(cmd)
      end
      cmd2 = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{subsys}/#{ds}/#{user_add}"
      ]
      PuppetX::Jboss.run_command(cmd2)
    end
  end

  def background_validation
    output = ''
    val = ''
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr = "background-validation"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:read-attribute\(name=#{attr}\)"
    ]

    output = PuppetX::Jboss.run_command(cmd)
    output.split("\n").collect do |line|
       if line.start_with?("    \"result\"")
         val = line.strip
         val = val.split(" => ")
         val = val[1].delete("\",")
       end
    end
    return val
  end

  def background_validation=(new_value)
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr = "background-validation"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:write-attribute\(name=#{attr},value=\"#{new_value}\"\)"
    ]
    PuppetX::Jboss.run_command(cmd)
  end

  def driver_name
    output = ''
    val = ''
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr = "driver-name"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:read-attribute\(name=#{attr}\)"
    ]

    output = PuppetX::Jboss.run_command(cmd)
    output.split("\n").collect do |line|
       if line.start_with?("    \"result\"")
         val = line.strip
         val = val.split(" => ")
         val = val[1].delete("\",")
       end
    end
    return val
  end

  def driver_name=(new_value)
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr = "driver-name"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:write-attribute\(name=#{attr},value=\"#{new_value}\"\)"
    ]
    PuppetX::Jboss.run_command(cmd)
  end

  def min_pool_size
    output = ''
    val = ''
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr = "min-pool-size"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:read-attribute\(name=#{attr}\)"
    ]

    output = PuppetX::Jboss.run_command(cmd)
    output.split("\n").collect do |line|
       if line.start_with?("    \"result\"")
         val = line.strip
         val = val.split(" => ")
         val = val[1].delete("\",")
       end
    end
    return val
  end

  def min_pool_size=(new_value)
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr = "min-pool-size"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:write-attribute\(name=#{attr},value=\"#{new_value}\"\)"
    ]

    PuppetX::Jboss.run_command(cmd)
  end

  def max_pool_size
    output = ''
    val = ''
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr = "max-pool-size"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:read-attribute\(name=#{attr}\)"
    ]

    output = PuppetX::Jboss.run_command(cmd)
    output.split("\n").collect do |line|
       if line.start_with?("    \"result\"")
         val = line.strip
         val = val.split(" => ")
         val = val[1].delete("\",")
       end
    end
    return val
  end

  def max_pool_size=(new_value)
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr = "max-pool-size"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:write-attribute\(name=#{attr},value=\"#{new_value}\"\)"
    ]

    PuppetX::Jboss.run_command(cmd)
  end

  def query_timeout
    output = ''
    val = ''
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr = "query-timeout"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:read-attribute\(name=#{attr}\)"
    ]

    output = PuppetX::Jboss.run_command(cmd)
    output.split("\n").collect do |line|
       if line.start_with?("    \"result\"")
         val = line.strip
         val = val.split(" => ")
         val = val[1].delete("\",")
       end
    end
    return val
  end

  def query_timeout=(new_value)
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr = "query-timeout"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:write-attribute\(name=#{attr},value=\"#{new_value}\"\)"
    ]

    PuppetX::Jboss.run_command(cmd)
  end

  def idle_timeout_minutes
    output = ''
    val = ''
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr = "idle-timeout-minutes"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:read-attribute\(name=#{attr}\)"
    ]

    output = PuppetX::Jboss.run_command(cmd)
    output.split("\n").collect do |line|
       if line.start_with?("    \"result\"")
         val = line.strip
         val = val.split(" => ")
         val = val[1].delete("\",")
       end
    end
    return val
  end

  def idle_timeout_minutes=(new_value)
    subsys = "/subsystem=datasources"
    ds = "xa-data-source=#{@resource[:ds_name]}"
    attr = "idle-timeout-minutes"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{ds}:write-attribute\(name=#{attr},value=\"#{new_value}\"\)"
    ]

    PuppetX::Jboss.run_command(cmd)
  end
end
