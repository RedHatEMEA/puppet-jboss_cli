require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'
require 'rexml/document'


Puppet::Type.type(:server_identity).provide(:server_identity) do
  include PuppetX::Jboss
  @doc = "Manages SSL used to configure authentication agains consoles."

  confine :osfamily => :redhat

  def self.instances
    return []
  end

  def init()
    $attrs_to_write = {}
    $current_attrs = {}
    $engine_path = @resource[:engine_path]
    $nic = @resource[:nic]
    $path = "/core-service=management/security-realm=#{@resource[:management_realm_name]}/server-identity=ssl"
  end

  def exists?
    init()
    begin
      $current_attrs = PuppetX::Jboss.exec_command($engine_path, $nic, $path, 'read-resource', 'recursive=true')
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
    PuppetX::Jboss.update_attributes($engine_path, $nic, $path, $current_attrs, $attrs_to_write)
  end

  def build_attrs_to_add()
    fail("A 'security-realm' called '#{@resource[:management_realm_name]}' is necessary for the create operation to succeed.") if security_realm_exists?(@resource[:management_realm_name]) == false

    to_add = {}
    to_add["keystore-relative-to"] = @resource[:keystore_relative_to]
    to_add["alias"] = @resource[:ssl_alias]
    to_add["keystore-password"] = @resource[:keystore_password]
    to_add["keystore-path"] = @resource[:keystore_path]

    return to_add
  end

  def security_realm_exists?(security_realm)
    path = "/core-service=management/security-realm=#{security_realm}"
    operation = "read-resource"
    begin
      PuppetX::Jboss.exec_command($engine_path, $nic, path, operation)
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def keystore_path
    return $current_attrs["keystore-path"]
  end

  def keystore_path=(new_value)
    $attrs_to_write["keystore-path"] = new_value
  end

  def keystore_relative_to
    return $current_attrs["keystore-relative-to"]
  end

  def keystore_relative_to=(new_value)
    $attrs_to_write["keystore-relative-to"] = new_value
  end

  def keystore_password
    return $current_attrs["keystore-password"]
  end

  def keystore_password=(new_value)
    $attrs_to_write["keystore-password"] = new_value
  end

  def ssl_alias
    return $current_attrs["alias"]
  end

  def ssl_alias=(new_value)
    $attrs_to_write["alias"] = new_value
  end

  def key_password
    return $current_attrs["key-password"]
  end

  def key_password=(new_value)
    $attrs_to_write["key-password"] = new_value
  end

end
