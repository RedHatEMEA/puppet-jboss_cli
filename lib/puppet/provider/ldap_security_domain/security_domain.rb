require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:ldap_security_domain).provide(:security_domain) do
  include PuppetX::Jboss
  @doc = "Manages JAAS Security Domain with the jboss-cli.sh"

  confine :osfamily => :redhat

  def login_modules_options
    attributes = {}
    val = ""
    subsys = "/subsystem=security"
    sd = "security-domain=#{@resource[:name]}"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{sd}/authentication=classic:read-attribute\(name=login-modules\)"
    ]

    output = PuppetX::Jboss.run_command(cmd)
    output.split("\n").collect do |line|
       val = line.delete(" ")
       if ! ((val.start_with?("\"outcome\"")or
             val.start_with?("\"result\"")  or
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
    params = {"flag"=>"#{@resource[:flag]}",
              "code"=>"LdapExtended",
              "java-naming-factory-initial"=>"#{@resource[:java_naming_factory_initial]}",
              "java-naming-provider-url"=>"#{@resource[:java_naming_provider_url]}",
              "java-naming-security-authentication"=>"#{@resource[:java_naming_security_authentication]}",
              "bindDN"=>"#{@resource[:bind_dn]}",
              "bindCredential"=>"#{@resource[:bind_credential]}",
              "allowEmptyPasswords"=>"#{@resource[:allow_empty_passwords]}",
              "baseCtxDN"=>"#{@resource[:base_ctx_dn]}",
              "baseFilter"=>"#{@resource[:base_filter]}",
              "rolesCtxDN"=>"#{@resource[:roles_ctx_dn]}",
              "roleFilter"=>"#{@resource[:role_filter]}",
              "roleAttributeID"=>"#{@resource[:role_attribute_id]}",
              "roleNameAttributeID"=>"#{@resource[:role_name_attribute_id]}",
              "roleAttributeIsDN"=>"#{@resource[:role_attribute_is_dn]}",
              "searchScope"=>"#{@resource[:search_scope]}",
              "throwValidateError"=>"#{@resource[:throw_validate_error]}"
             }
    return params
  end

  def update_login_modules
    debug "Update existing login-modules properties"
    subsys = "/subsystem=security"
    sd = "security-domain=#{@resource[:name]}"

  	cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{sd}/authentication=classic:write-attribute\(name=login-modules,value=[ \
             {\"flag\"                                   =>\"#{@resource[:flag]}\", \
              \"code\"                                   =>\"LdapExtended\", \
              \"module-options\"                         =>{ \
                 \"java.naming.factory.initial\"         => \"com.sun.jndi.ldap.LdapCtxFactory\", \
                 \"java.naming.provider.url\"            => \"#{@resource[:java_naming_provider_url]}\", \
                 \"java.naming.security.authentication\" => \"simple\", \
                 \"bindDN\"                              => \"#{@resource[:bind_dn]}\", \
                 \"bindCredential\"                      => \"#{@resource[:bind_credential]}\", \
                 \"allowEmptyPasswords\"                 => \"false\", \
                 \"baseCtxDN\"                           => \"#{@resource[:base_ctx_dn]}\", \
                 \"baseFilter\"                          => \"#{@resource[:base_filter]}\", \
                 \"rolesCtxDN\"                          => \"#{@resource[:roles_ctx_dn]}\", \
                 \"roleFilter\"                          => \"#{@resource[:role_filter]}\", \
                 \"roleAttributeID\"                     => \"#{@resource[:role_attribute_id]}\" , \
                 \"roleNameAttributeID\"                 => \"#{@resource[:role_name_attribute_id]}\", \
                 \"roleAttributeIsDN\"                   => \"#{@resource[:role_attribute_is_dn]}\", \
                 \"searchScope\"                         => \"#{@resource[:search_scope]}\", \
                 \"throwValidateError\"                  => \"#{@resource[:throw_validate_error]}\" \
             }}]\)"
    ]

    PuppetX::Jboss.run_command(cmd)
    notice "Updating JAAS Security Domain #{@resource[:name]}"
  end

  def create
    subsys = "/subsystem=security"
    sd = "security-domain=#{@resource[:name]}"

    cmd1 = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{sd}:add"
    ]

    cmd2 = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{sd}/authentication=classic:add\(login-modules=[ \
             {\"flag\"                                   =>\"#{@resource[:flag]}\", \
              \"code\"                                   =>\"LdapExtended\", \
              \"module-options\"                         =>{ \
                 \"java.naming.factory.initial\"         => \"com.sun.jndi.ldap.LdapCtxFactory\", \
                 \"java.naming.provider.url\"            => \"#{@resource[:java_naming_provider_url]}\", \
                 \"java.naming.security.authentication\" => \"simple\", \
                 \"bindDN\"                              => \"#{@resource[:bind_dn]}\", \
                 \"bindCredential\"                      => \"#{@resource[:bind_credential]}\", \
                 \"allowEmptyPasswords\"                 => \"false\", \
                 \"baseCtxDN\"                           => \"#{@resource[:base_ctx_dn]}\", \
                 \"baseFilter\"                          => \"#{@resource[:base_filter]}\", \
                 \"rolesCtxDN\"                          => \"#{@resource[:roles_ctx_dn]}\", \
                 \"roleFilter\"                          => \"#{@resource[:role_filter]}\", \
                 \"roleAttributeID\"                     => \"#{@resource[:role_attribute_id]}\" , \
                 \"roleNameAttributeID\"                 => \"#{@resource[:role_name_attribute_id]}\", \
                 \"roleAttributeIsDN\"                   => \"#{@resource[:role_attribute_is_dn]}\", \
                 \"searchScope\"                         => \"#{@resource[:search_scope]}\", \
                 \"throwValidateError\"                  => \"#{@resource[:throw_validate_error]}\" \
             }}]\)"
    ]

    debug "Creating JAAS security domain"
    PuppetX::Jboss.run_command(cmd1)
    PuppetX::Jboss.run_command(cmd2)
  end

  def destroy
    subsys = "/subsystem=security"
    sd = "security-domain=#{@resource[:name]}"
  	debug "Deletion of security-domain #{sd}"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{sd}:remove"
    ]
    PuppetX::Jboss.run_command(cmd)
  end

  def exists?
    subsys = "/subsystem=security"
    sd = "security-domain=#{@resource[:name]}"
    debug "Checking existence of security-domain #{sd}"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Jboss.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}/#{sd}:read-resource"
    ]
    begin
      PuppetX::Jboss.run_command(cmd)
      login_modules_options
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end
end
