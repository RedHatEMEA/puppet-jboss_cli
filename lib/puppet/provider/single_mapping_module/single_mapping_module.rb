require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:single_mapping_module).provide(:single_mapping_module) do
  include PuppetX::Jboss
  @doc = "Manages JAAS Mapping Module in security Domain with the jboss-cli.sh"

  confine :osfamily => :redhat

  def module_options
    actual_attributes = {}
    path = "/subsystem=security/security-domain=#{@resource[:security_domain_name]}/mapping=classic"
    operation = "read-attribute"
    params = "name=mapping-modules"
    output = PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)

    output.split("\n").collect do |line|
      val = line.delete(" ")
      if ! ((val.start_with?("\"outcome\"")or
             val.start_with?("\"result\"")  or
             val.start_with?("\"type\"")  or
             val.start_with?("\"code\"")  or
             val.start_with?("\"module\"")  or
             val.start_with?("\"module-options\"")  or
             val.start_with?("[{")          or
             val.start_with?("}]")          or
             val.start_with?("[")           or
             val.start_with?("]")           or
             val.start_with?("{")           or
             val.start_with?("}")           or
             val.start_with?("\"response-headers\"")))
        val = val.split("=>")
        mykey = val[0].delete("\"")
        mykey = mykey.gsub(".", "-")
        myval = val[1].delete("\"")
        myval = myval.chomp(",")
        actual_attributes.store(mykey, myval)
      end
    end
    return actual_attributes
  end

  def module_options=(new_value)
    Puppet.debug "Update existing login-modules properties"
    path = "/subsystem=security/security-domain=#{@resource[:security_domain_name]}/mapping=classic"
    operation = "write-attribute"
    params = "name=mapping-modules,value=[ {\
              \"type\"           =>\"#{@resource[:type]}\", \
              \"code\"           =>\"#{@resource[:code]}\", \
              \"module\"         =>\"#{@resource[:module]}\", \
              \"module-options\" =>  #{to_module_options()} \
             }]"
    PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    notice "Updating JAAS Security Domain #{@resource[:name]}"
  end

  def to_module_options
    debug "Create Hash from parameters type"
    module_options = @resource[:module_options]
    params = "{ "
    module_options.keys.sort.each do |key|
      params = "#{params} \"#{key}\" => \"#{module_options[key]}\", "
      Puppet.debug "key=#{key} value=#{module_options[key]}"
    end
    params = "#{params.chomp(", ")} }"
    Puppet.debug "Received module-options converted to Hash: #{params}"
    return params
  end

  def create
    Puppet.debug "Creating mapping-modules"
    path = "/subsystem=security/security-domain=#{@resource[:security_domain_name]}/mapping=classic"
    operation = "add"
    params = "mapping-modules=[ {\
                   \"type\"           =>\"#{@resource[:type]}\", \
                   \"code\"           =>\"#{@resource[:code]}\", \
                   \"module\"         =>\"#{@resource[:module]}\", \
                   \"module-options\" =>  #{to_module_options()} \
                   }]"
    PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    debug "Creation of mapping module completed"
  end

  def destroy
    Puppet.debug "Deleting mapping-modules"
    path = "/subsystem=security/security-domain=#{@resource[:security_domain_name]}/mapping=classic"
    operation = "remove"
    params = ""
    PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    debug "Deletion of mapping module completed"
  end

  def exists?
    path = "/subsystem=security/security-domain=#{@resource[:security_domain_name]}/mapping=classic"
    operation = "read-resource"
    params = ""
    begin
      PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end
end
