require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/redhat/jboss'

Puppet::Type.type(:jdbc_driver).provide(:jdriver) do
  include PuppetX::Redhat
  @doc = "Manages JDBC Driver for an instance with the jboss-cli.sh"

  confine :osfamily => :redhat

  def create
    subsys = "/subsystem=datasources"
    jdbc_dri = "jdbc-driver=#{@resource[:driver_name]}"
    dri_name = "driver-name=#{@resource[:driver_name]}"
    dri_mod_name = "driver-module-name=#{@resource[:driver_module_name]}"
    dri_cls_name = "driver-class-name=#{@resource[:driver_class_name]}"
    dri_xa_ds_cls_name = "driver-xa-datasource-class-name=#{@resource[:driver_xa_datasource_class_name]}"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Redhat.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{jdbc_dri}:add\(#{dri_name},#{dri_mod_name},#{dri_cls_name},#{dri_xa_ds_cls_name}\)"
    ]
    PuppetX::Redhat.run_command(cmd)
  end

  def destroy
    debug "Test Destroy def"
    subsys = "/subsystem=datasources"
    jdbc_dri = "jdbc-driver=#{@resource[:driver_name]}"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Redhat.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{jdbc_dri}:remove"
    ]
    PuppetX::Redhat.run_command(cmd)
  end

  def exists?
    debug "Debug exists? def"
    subsys = "/subsystem=datasources"
    jdbc_dri = "jdbc-driver=#{@resource[:driver_name]}"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Redhat.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{jdbc_dri}:read-resource"
    ]
    begin
      PuppetX::Redhat.run_command(cmd)
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def driver_module_name
    output = ''
    val = ''
    subsys = "/subsystem=datasources"
    jdbc_dri = "/jdbc-driver=#{@resource[:driver_name]}"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Redhat.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{jdbc_dri}:read-attribute\(name=driver-module-name\)"
    ]
    output = PuppetX::Redhat.run_command(cmd)
    output.split("\n").collect do |line|
       if line.start_with?("    \"result\"")
         val = line.strip
         val = val.split(" => ")
         val = val[1].delete("\"")
       end
    end
    return val
  end

  def driver_module_name=(new_value)
    subsys = "/subsystem=datasources"
    jdbc_dri = "/jdbc-driver=#{@resource[:driver_name]}"

    cmd = [
    "#{@resource[:engine_path]}/bin/jboss-cli.sh",
    "-c", "--controller=#{PuppetX::Redhat.ip_instance("#{@resource[:nic]}")}",
    "--command=#{subsys}/#{jdbc_dri}:write-attribute\(name=value,value=#{new_value}\)"
    ]
    PuppetX::Redhat.run_command(cmd)
  end

end
