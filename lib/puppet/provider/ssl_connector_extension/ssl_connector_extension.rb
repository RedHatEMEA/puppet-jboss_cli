require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:ssl_connector_extension).provide(:ssl_connector_extension) do
  include PuppetX::Jboss
  @doc = "Manages web connectors for an instance with the jboss-cli.sh"

  confine :osfamily => :redhat

  def create
    debug "Trying to create a :ssl_connector_extension"
    password = "password=#{@resource[:password]}"
    certificate_key_file = "certificate-key-file=#{@resource[:certificate_key_file]}"
    protocol = "protocol=#{@resource[:protocol]}"

    params = "#{password},#{certificate_key_file},#{protocol}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
    operation ="add"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def destroy
    debug "Trying to destroy a :ssl_connector_extension"
    params = ""
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
    operation ="remove"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def exists?
    debug "Does this :ssl_connector_extension exist ?"
    params = ""
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
    operation ="read-resource"
    begin
      PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  # Manage the 'password' attribute
  def password
    params = "name=password"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
    operation ="read-attribute"
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end

  def password=(new_value)
    params = "name=password, value=#{new_value}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
    operation ="write-attribute"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  # The alias name to be used in that keystore
  def key_alias
    params = "name=key-alias"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
    operation ="read-attribute"
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end

  def key_alias=(new_value)
    params = "name=key-alias, value=#{new_value}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
    operation ="write-attribute"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end


  # Manage certificate-key-file attribute
  def certificate_key_file
    val = ''
    params = "name=certificate-key-file"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
    operation ="read-attribute"
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end

  def certificate_key_file=(new_value)
    params = "name=certificate-key-file, value=#{new_value}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
    operation ="write-attribute"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end


  # Manage 'protocol' attribute
  def protocol
    params = "name=protocol"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
    operation ="read-attribute"
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end

  def protocol=(new_value)
    params = "name=protocol, value=#{new_value}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
    operation ="write-attribute"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end
end
