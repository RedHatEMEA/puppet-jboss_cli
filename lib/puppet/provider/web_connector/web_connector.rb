require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:web_connector).provide(:web_connector) do
  include PuppetX::Jboss
  @doc = "Manages HTTP connectors for an instance with the jboss-cli.sh"

  confine :osfamily => :redhat

  def self.instances
    return []
  end

  def init()
    $attrs_to_write = {}
    $current_attrs = {}
    $engine_path = @resource[:engine_path]
    $nic = @resource[:nic]
    $path = "/subsystem=web/connector=#{@resource[:connector_name]}"
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
    fail("Attribute 'socket_binding' is necessary for the 'create' operation to succeed.") if @resource[:socket_binding] == :nil
    fail("A 'socket-binding' called '#{@resource[:socket_binding]}' is necessary for the create operation to succeed.") if socket_binding_exists?(@resource[:socket_binding]) == false

    to_add = {}
    to_add["socket-binding"] = @resource[:socket_binding]
    to_add["secure"] = @resource[:secure]
    to_add["protocol"] = @resource[:protocol]
    to_add["scheme"] = @resource[:scheme]
    to_add["redirect-port"] = @resource[:redirect_port]
    to_add["proxy-name"] = @resource[:proxy_name] if @resource[:proxy_name] != :nil
    to_add["proxy-port"] = @resource[:proxy_port] if @resource[:proxy_port] != :nil

    return to_add
  end

  def socket_binding_exists?(socket_binding)
    path = "/socket-binding-group=standard-sockets/socket-binding=#{socket_binding}"
    operation = "read-resource"
    begin
      PuppetX::Jboss.exec_command($engine_path, $nic, path, operation)
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def socket_binding
    return $current_attrs["socket-binding"]
  end

  def socket_binding=(new_value)
    fail("A 'socket-binding' called '#{new_value}' is necessary for the create operation to succeed.") if socket_binding_exists?(new_value) == false
    $attrs_to_write["socket-binding"] = new_value
  end

  def secure
    return $current_attrs["secure"]
  end

  def secure=(new_value)
    $attrs_to_write["secure"] = new_value
  end

  def protocol
    return $current_attrs["protocol"]
  end

  def protocol=(new_value)
    $attrs_to_write["protocol"] = new_value
  end

  def scheme
    return $current_attrs["scheme"]
  end

  def scheme=(new_value)
    $attrs_to_write["scheme"] = new_value
  end

  def redirect_port
    return $current_attrs["redirect-port"]
  end

  def redirect_port=(new_value)
    $attrs_to_write["redirect-port"] = new_value
  end

  def proxy_name
    return $current_attrs["proxy-name"]
  end

  def proxy_name=(new_value)
    $attrs_to_write["proxy-name"] = new_value
  end

  def proxy_port
    return $current_attrs["proxy-port"]
  end

  def proxy_port=(new_value)
    $attrs_to_write["proxy-port"] = new_value
  end

end
