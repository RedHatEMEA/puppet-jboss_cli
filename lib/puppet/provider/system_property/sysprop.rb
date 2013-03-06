require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:system_property).provide(:sysprop) do
  include PuppetX::Jboss
  @doc = "Manages system-property for an instance with the jboss-cli.sh"

  confine :osfamily => :redhat

  def create
    debug "Creating resource"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=/system-property=#{@resource[:sp_name]}:add\(value=#{@resource[:value]}\)"
    ]
    PuppetX::Jboss.run_command(cmd)
  end

  def destroy
    debug "Test Destroy def"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=/system-property=#{@resource[:sp_name]}:remove"
    ]
    PuppetX::Jboss.run_command(cmd)
  end

  def exists?
    debug "Debug exists? def"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=/system-property=#{@resource[:sp_name]}:read-resource"
    ]
    begin
      PuppetX::Jboss.run_command(cmd)
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def value
    output = ''
    val = ''

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=/system-property=#{@resource[:sp_name]}:read-attribute\(name=value\)"
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

  def value=(new_value)
    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=/system-property=#{@resource[:sp_name]}:write-attribute\(name=value,value=#{new_value}\)"
    ]
    PuppetX::Jboss.run_command(cmd)
  end

end
