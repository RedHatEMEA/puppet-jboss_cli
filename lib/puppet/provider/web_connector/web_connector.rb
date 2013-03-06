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
    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    PuppetX::Jboss.run_command(cmd)
  end

  def destroy
    debug "Test Destroy def"
    params = ""
    operation ="remove"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"

    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    PuppetX::Jboss.run_command(cmd)
  end

  def exists?
    debug "Debug exists? def"
    params = ""
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="read-resource"
    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    begin
      PuppetX::Jboss.run_command(cmd)
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def socket_binding
    output = ''
    val = ''
    params = "name=socket-binding"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="read-attribute"
    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    output = PuppetX::Jboss.run_command(cmd)
    output.split("\n").collect do |line|
      if line.start_with?("    \"result\"")
        val = line.strip
        val = val.split(" => ")
        val = val[1].delete("\",")
      end
    end
    return val
  end

  def socket_binding=(new_value)
    params = "name=socket-binding, value=#{new_value}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="write-attribute"
    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    PuppetX::Jboss.run_command(cmd)
  end

  def secure
    output = ''
    val = ''
    params = "name=secure"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="read-attribute"
    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    output = PuppetX::Jboss.run_command(cmd)
    output.split("\n").collect do |line|
      if line.start_with?("    \"result\"")
        val = line.strip
        val = val.split(" => ")
        val = val[1].delete("\",")
      end
    end
    return val
  end

  def secure=(new_value)
    params = "name=secure, value=#{new_value}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="write-attribute"
    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    PuppetX::Jboss.run_command(cmd)
  end


  def protocol
    output = ''
    val = ''
    params = "name=protocol"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="read-attribute"
    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    output = PuppetX::Jboss.run_command(cmd)
    output.split("\n").collect do |line|
      if line.start_with?("    \"result\"")
        val = line.strip
        val = val.split(" => ")
        val = val[1].delete("\",")
      end
    end
    return val
  end

  def protocol=(new_value)
    params = "name=protocol, value=#{new_value}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="write-attribute"
    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    PuppetX::Jboss.run_command(cmd)
  end

  def scheme
    output = ''
    val = ''
    params = "name=scheme"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="read-attribute"
    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    output = PuppetX::Jboss.run_command(cmd)
    output.split("\n").collect do |line|
      if line.start_with?("    \"result\"")
        val = line.strip
        val = val.split(" => ")
        val = val[1].delete("\",")
      end
    end
    return val
  end

  def scheme=(new_value)
    params = "name=scheme, value=#{new_value}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}"
    operation ="write-attribute"
    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    PuppetX::Jboss.run_command(cmd)
  end
end
