require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:jdbc_driver).provide(:jdriver) do
  include PuppetX::Jboss

  confine :osfamily => :redhat

  def self.instances
    return []
  end

  def init()
    $attrs_to_write = {}
    $current_attrs = {}
    $engine_path = @resource[:engine_path]
    $nic = @resource[:nic]
    $path = "/subsystem=datasources/jdbc-driver=#{@resource[:driver_name]}"
  end

  def exists?
    init()
    begin
      $current_attrs = PuppetX::Jboss.exec_command($engine_path, $nic, $path, "read-resource")
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def create
    PuppetX::Jboss.add_attributes($engine_path, $nic, $path, $current_attrs, build_attrs_to_add())
  end

  def destroy
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, "remove")
  end

  def build_attrs_to_add()
    to_add = {}
    to_add["driver-name"] = @resource[:driver_name]
    to_add["driver-module-name"] = @resource[:driver_module_name]
    to_add["driver-module-slot"] = @resource[:driver_module_slot] if @resource[:driver_module_slot] != :nil
    to_add["driver-class-name"] = @resource[:driver_class_name] if @resource[:driver_class_name] != :nil
    to_add["driver-xa-datasource-class-name"] = @resource[:driver_xa_datasource_class_name] if @resource[:driver_xa_datasource_class_name] != :nil

    return to_add
  end

end
