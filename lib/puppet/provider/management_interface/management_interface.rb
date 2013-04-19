require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'
require 'rexml/document'


Puppet::Type.type(:management_interface).provide(:management_interface) do
  include PuppetX::Jboss
  @doc = "Manages the Management interface used to configure authentication agains consoles."

  confine :osfamily => :redhat

  def self.instances
    return []
  end

  def exists?
    $expected_attrs = {}
    $current_attrs = {}
    $engine_path = @resource[:engine_path]
    $nic = @resource[:nic]
    $path = "/core-service=management/management-interface=#{@resource[:management_interface_name]}"
    begin
      $current_attrs = PuppetX::Jboss.exec_command($engine_path, $nic, $path, 'read-resource', 'recursive=true')
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def create
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, "add")
  end

  def destroy
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, "remove")
  end

  def flush
    PuppetX::Jboss.update_attributes($engine_path, $nic, $path, $current_attrs, $expected_attrs)
  end

  def socket_binding
    return $current_attrs['socket-binding']
  end
  def socket_binding=(new_value)
    $expected_attrs['socket-binding'] = new_value
  end

  def security_realm
    return $current_attrs['security-realm']
  end
  def security_realm=(new_value)
    $expected_attrs['security-realm'] = new_value
  end

  def secure_socket_binding
    return $current_attrs['secure-socket-binding']
  end
  def secure_socket_binding=(new_value)
    $expected_attrs['secure-socket-binding'] = new_value
  end

end

