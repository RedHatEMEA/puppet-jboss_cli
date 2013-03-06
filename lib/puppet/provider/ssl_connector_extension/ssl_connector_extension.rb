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
    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    PuppetX::Jboss.run_command(cmd)
  end

  def destroy
    debug "Trying to destroy a :ssl_connector_extension"
    params = ""
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
    operation ="remove"
    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    PuppetX::Jboss.run_command(cmd)
  end

  def exists?
    debug "Does this :ssl_connector_extension exist ?"
    params = ""
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
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

  # Manage the 'password' attribute
  def password
    output = ''
    val = ''
    params = "name=password"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
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

  def password=(new_value)
    params = "name=password, value=#{new_value}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
    operation ="write-attribute"
    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    PuppetX::Jboss.run_command(cmd)
  end

  # Manage certificate-key-file attribute
  def certificate_key_file
    output = ''
    val = ''
    params = "name=certificate-key-file"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
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

  def certificate_key_file=(new_value)
    params = "name=certificate-key-file, value=#{new_value}"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
    operation ="write-attribute"
    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    PuppetX::Jboss.run_command(cmd)
  end


  # Manage 'protocol' attribute
  def protocol
    output = ''
    val = ''
    params = "name=protocol"
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
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
    path = "/subsystem=web/connector=#{@resource[:connector_name]}/ssl=configuration"
    operation ="write-attribute"
    cmd = [
        "#{@resource[:engine_path]}/bin/jboss-cli.sh",
        "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
        "--command=#{path}:#{operation}\(#{params}\)"
    ]
    PuppetX::Jboss.run_command(cmd)
  end
end
