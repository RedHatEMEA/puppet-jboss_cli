require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:mapping_module).provide(:mapping_module) do
  include PuppetX::Jboss
  @doc = "Manages Mapping Modules with the jboss-cli.sh"

  confine :osfamily => :redhat

  def ip_instance
    fact_nic_name = "ipaddress_#{@resource[:nic].gsub(':', '_')}"
    if fact_nic_name.empty? or Facter[fact_nic_name].nil?
      fail("Please verify if the network interface #{@resource[:nic]} exists !")
    end
    ip_instance = Facter.value(fact_nic_name) if !Facter[fact_nic_name].nil?
  end

  def mapping_module_options
    attributes = {}
    val = ""
    ip = ip_instance()
    subsys = "/subsystem=security"
    sd = "security-domain=#{@resource[:security_domain]}/mapping=classic"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{ip}",
      "--command=#{subsys}/#{sd}:read-attribute\(name=mapping-modules\)"
    ]

    # TODO: Puppet::Util.execute will be deprecated in 3.0
    output = Puppet::Util.execute(cmd)

    output.split("\n").collect do |line|
       val = line.delete(" ")
       if ! (val.start_with?("\"outcome\"") or
             val.start_with?("\"result\"")  or
             val.start_with?("\"module-options\"")  or
             val.start_with?("}]")          or
             val.start_with?("{")           or
             val.start_with?("}")           or
             val.start_with?("\"response-headers\""))
         val = val.split("=>")
         mykey = val[0].delete("\"")
         mykey = mykey.gsub(".", "-")
         myval = val[1].delete("\"")
         myval = myval.chomp(",")
         attributes.store(mykey, myval)
       end
    end
    hashparams = create_hash_from_param
    if hashparams != attributes
      update_login_modules
    end
  end

  def create_hash_from_param
    debug "Create Hash from parameters type"
    map_options = @resource.original_paramaters[:mapping_modules]
    if map_options.is_a?(Hash)
      params = map_options
      return params
    else
      fail("prout")
    end
  end

  def update_login_modules
    debug "Update existing login-modules properties"
    subsys = "/subsystem=security"
    sd = "security-domain=#{@resource[:security_domain]}/mapping=classic"
    map_mod = @resource.original_paramaters[:mapping_module]
    ip = ip_instance()

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{ip}",
      "--command=#{subsys}/#{sd}:write-attribute\(name=mapping-modules,value=[#{map_mod}]\)"
    ]
    # TODO: Puppet::Util.execute will be deprecated in 3.0
    debug "Updating JAAS security domain"
    Puppet::Util.execute(cmd)
    notice "Updating JAAS Security Domain #{@resource[:name]}"
  end

  def create
    subsys = "/subsystem=security"
    sd = "security-domain=#{@resource[:security_domain]}/mapping=classic"
    ip = ip_instance()

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{ip}",
      "--command=#{subsys}/#{sd}:add\(mapping-modules=[#{map_mod}]\)"
    ]

    # TODO: Puppet::Util.execute will be deprecated in 3.0
    debug "Creating JAAS security domain"
    Puppet::Util.execute(cmd)
  end

  def destroy
    debug "Test Destroy def"
    subsys = "/subsystem=security"
    sd = "security-domain=#{@resource[:security_domain]}/mapping=classic"
    ip = ip_instance()
    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{ip}",
      "--command=#{subsys}/#{sd}:remove"
    ]
    Puppet::Util.execute(cmd)
  end

  def exists?
    debug "Debug exists? def"
    subsys = "/subsystem=security"
    sd = "security-domain=#{@resource[:name]}/mapping=classic"
    ip = ip_instance()
    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{ip}",
      "--command=#{subsys}/#{sd}:read-resource"
    ]
    begin
      Puppet::Util.execute(cmd)
      mapping_module_options
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end
end
