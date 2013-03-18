require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:web_connector).provide(:web_connector) do
  include PuppetX::Jboss
  @doc = "Manages SSL extenions for web connectors for an instance with the jboss-cli.sh"

  confine :osfamily => :redhat

  def create
    subsys = "/subsystem=web"
    connector_name = "connector=#{@resource[:connector_name]}"
    socket_binding = "socket-binding=#{@resource[:socket_binding]}"
    secure = "secure=#{@resource[:secure]}"
    protocol = "protocol=#{@resource[:protocol]}"
    scheme = "scheme=#{@resource[:scheme]}"

    params = "#{socket_binding},#{secure}, #{protocol}, #{scheme}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="add"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def destroy
    debug "Test Destroy def"
    params = ""
    operation ="remove"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def exists?
    debug "Debug exists? def"
    params = ""
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="read-resource"
    begin
      PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def socket_binding
    params = "name=socket-binding"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="read-attribute"
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end

  def socket_binding=(new_value)
    params = "name=socket-binding, value=#{new_value}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="write-attribute"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def secure
    params = "name=secure"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="read-attribute"
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end

  def secure=(new_value)
    params = "name=secure, value=#{new_value}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="write-attribute"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end


  def protocol
    params = "name=protocol"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="read-attribute"
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end

  def protocol=(new_value)
    params = "name=protocol, value=#{new_value}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="write-attribute"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def scheme
    params = "name=scheme"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="read-attribute"
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end

  def scheme=(new_value)
    params = "name=scheme, value=#{new_value}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="write-attribute"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def redirect_port 
    params = "name=redirect-port"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="read-attribute"
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def redirect_port=(new_value)
    params = "name=redirect-port, value=#{new_value}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="write-attribute"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

end
