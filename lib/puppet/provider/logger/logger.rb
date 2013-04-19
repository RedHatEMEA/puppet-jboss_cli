require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'
require 'rexml/document'

Puppet::Type.type(:logger).provide(:logger) do
  include PuppetX::Jboss
  @doc = "Manages the logging subsystem."

  confine :osfamily => :redhat

  def init()
    $attrs_to_write = {}
    $current_attrs = {}
    $engine_path = @resource[:engine_path]
    $nic = @resource[:nic]
    $path = "/subsystem=logging/logger=#{@resource[:logger_name]}"
  end
  def exists?
    init()
    begin
      $current_attrs = PuppetX::Jboss.exec_command($engine_path, $nic, $path, "read-resource")
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def create
    PuppetX::Jboss.add_attributes($engine_path, $nic, $path, $current_attrs, build_attrs_to_add())
  end

  def destroy
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, "remove")
  end

  def flush
    PuppetX::Jboss.write_attributes($engine_path, $nic, $path, $current_attrs, $attrs_to_write)
  end

  def build_attrs_to_add()
    to_add = {}
    to_add["use-parent-handlers"] = @resource[:use_parent_handlers]
    to_add["level"] = @resource[:level]
    to_add["handlers"] = @resource[:handlers]

    return to_add
  end

  def level
    return $current_attrs["level"]
  end

  def level=(new_value)
    $attrs_to_write["level"] = new_value
  end

  def use_parent_handlers
    return $current_attrs["use-parent-handlers"]
  end

  def use_parent_handlers=(new_value)
    $attrs_to_write["use-parent-handlers"] = new_value
  end

  def handlers
    return $current_attrs["handlers"]
  end

  def handlers=(new_value)
    # In EAP 6.0.0 a bug makes handlers cannot be undefined. It is fixed in 6.1
    #if (PuppetX::Jboss.product_version(@resource[:engine_path], @resource[:nic]).start_with? "6.0.0.GA") and new_value.empty?
    #  notice("JBoss EAP 6.0.0 does not support undefining handlers on logger")
    #end
    $attrs_to_write["handlers"] = new_value
  end

end

