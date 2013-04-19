require 'pathname'
require 'enumerator'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:single_mapping_module).provide(:single_mapping_module) do
  include PuppetX::Jboss
  @doc = "Manages JAAS Mapping Module in security Domain with the jboss-cli.sh"

  confine :osfamily => :redhat

  def module_options
    debug "Getting current value for module-options property"
    actual_attributes = {}
    path = "/subsystem=security/security-domain=#{@resource[:security_domain_name]}/mapping=classic"
    operation = "read-attribute"
    params = "name=mapping-modules"
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    # We need some replacements to make the ouput parseable by MultiJson 
    output = output.gsub('"module-options" => [', '"module-options" => {').gsub(']', '}').gsub('}}', '}]')
    output = output.gsub('(', '').gsub(')', '')

    # The returned result is interpreted as an array containing a map !!
    map = PuppetX::Jboss.parse_cli_result_as_map(output)

    Puppet.info( "Current value for module-options is #{map.inspect} ")
    return map['module-options']
  end

  def module_options=(new_value)
    Puppet.debug "Updating existing login-modules properties with #{new_value}"
    path = "/subsystem=security/security-domain=#{@resource[:security_domain_name]}/mapping=classic"
    operation = "write-attribute"
    params = "name=mapping-modules,value=[ {\
              \"type\"           =>\"#{@resource[:type]}\", \
              \"code\"           =>\"#{@resource[:code]}\", \
              \"module\"         =>\"#{@resource[:module]}\", \
              \"module-options\" =>  #{to_module_options(new_value)} \
             }]"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    notice "Updated JAAS Security Domain #{@resource[:name]} with #{new_value}"
  end

  def to_module_options(module_options)
    debug "Create Hash from parameters type"
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
                   \"module-options\" =>  #{to_module_options(@resource[:module_options])} \
                   }]"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    debug "Creation of mapping module completed"
  end

  def destroy
    Puppet.debug "Deleting mapping-modules"
    path = "/subsystem=security/security-domain=#{@resource[:security_domain_name]}/mapping=classic"
    operation = "remove"
    params = ""
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    debug "Deletion of mapping module completed"
  end

  def exists?
    path = "/subsystem=security/security-domain=#{@resource[:security_domain_name]}/mapping=classic"
    operation = "read-resource"
    params = ""
    begin
      PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end
end
