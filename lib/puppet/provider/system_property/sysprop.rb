require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:system_property).provide(:sysprop) do
  include PuppetX::Jboss
  @doc = "Manages system-property for an instance with the jboss-cli.sh"

  confine :osfamily => :redhat

  def self.instances
    return []
  end

  def init()
    $attrs_to_write = {}
    $current_attrs = {}
    $engine_path = @resource[:engine_path]
    $nic = @resource[:nic]
    $path = "/system-property=#{@resource[:sp_name]}"
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

  def flush
    PuppetX::Jboss.write_attributes($engine_path, $nic, $path, $current_attrs, $attrs_to_write)
  end

  def build_attrs_to_add()
    fail("Attribute 'value' is necessary for the 'create' operation to succeed.") if @resource[:value] == :nil
    
    to_add = {}
    to_add["value"] = @resource[:value]

    return to_add
  end

  def value
    return $current_attrs["value"]
  end

  def value=(new_value)
    $attrs_to_write["value"] = new_value
  end

end
