require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:ssl_connector_extension).provide(:ssl_connector_extension) do
  include PuppetX::Jboss
  @doc = "Manages SSL configuration of an HTTP connector for an instance with the jboss-cli.sh"

  confine :osfamily => :redhat

  def self.instances
    return []
  end

  def init()
    $attrs_to_write = {}
    $current_attrs = {}
    $engine_path = @resource[:engine_path]
    $nic = @resource[:nic]
    $path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
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
    PuppetX::Jboss.update_attributes($engine_path, $nic, $path, $current_attrs, $attrs_to_write)
  end

  def build_attrs_to_add()
    fail("A 'web-connector' called '#{@resource[:connector_name]}' is necessary for the create operation to succeed.") if !web_connector_exists?(@resource[:connector_name])
    fail("Attribute 'certificate_key_file' is necessary for the 'create' operation to succeed.") if @resource[:certificate_key_file] == :nil
    fail("Attribute 'password' is necessary for the 'create' operation to succeed.") if @resource[:password] == :nil

    to_add = {}
    to_add["certificate-key-file"] = @resource[:certificate_key_file]
    to_add["key-alias"] = @resource[:key_alias]
    to_add["password"] = @resource[:password]
    to_add["keystore-type"] = @resource[:keystore_type] if @resource[:keystore_type] != :nil
    to_add["protocol"] = @resource[:protocol]
    to_add["cipher_suite"] = @resource[:cipher_suite] if @resource[:cipher_suite] != :nil
    to_add["verify-client"] = @resource[:verify_client] if @resource[:verify_client] != :nil
    to_add["ca-certificate-file"] = @resource[:ca_certificate_file] if @resource[:ca_certificate_file] != :nil
    to_add["truststore-type"] = @resource[:truststore_type] if @resource[:truststore_type] != :nil

    return to_add
  end

  def web_connector_exists?(connector_name)
    path = "/subsystem=web/connector=#{connector_name}"
    operation = "read-resource"
    begin
      PuppetX::Jboss.exec_command($engine_path, $nic, path, operation)
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def certificate_key_file
    return $current_attrs["certificate-key-file"]
  end

  def certificate_key_file=(new_value)
    $attrs_to_write["certificate-key-file"] = new_value
  end

  def key_alias
    return $current_attrs["key-alias"]
  end

  def key_alias=(new_value)
    $attrs_to_write["key-alias"] = new_value
  end

  def password
    return $current_attrs["password"]
  end

  def password=(new_value)
    $attrs_to_write["password"] = new_value
  end

  def keystore_type
    return $current_attrs["keystore-type"]
  end

  def keystore_type=(new_value)
    $attrs_to_write["keystore-type"] = new_value
  end

  def protocol
    return $current_attrs["protocol"]
  end

  def protocol=(new_value)
    $attrs_to_write["protocol"] = new_value
  end

  def cipher_suite
    return $current_attrs["cipher-suite"]
  end

  def cipher_suite=(new_value)
    $attrs_to_write["cipher-suite"] = new_value
  end

  def verify_client
    return $current_attrs["verify-client"]
  end

  def verify_client=(new_value)
    $attrs_to_write["verify-client"] = new_value
  end

  def ca_certificate_file
    return $current_attrs["ca-certificate-file"]
  end

  def ca_certificate_file=(new_value)
    $attrs_to_write["ca-certificate-file"] = new_value
  end

  def truststore_type
    return $current_attrs["truststore-type"]
  end

  def truststore_type=(new_value)
    $attrs_to_write["truststore-type"] = new_value
  end

end
