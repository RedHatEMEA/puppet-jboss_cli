require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:single_ldap_security_domain).provide(:single_ldap_security_domain) do
  include PuppetX::Jboss
  @doc = "Manages JAAS Security Domain with the jboss-cli.sh"

  confine :osfamily => :redhat
  def self.instances
    return []
  end

  def exists?
    current_login_module  = FlatHash.new({ 'module-options' => FlatHash.new({}) })
    expected_login_module = FlatHash.new({ 'module-options' => FlatHash.new({}) })
    $expected_attrs =  FlatHash.new({'login-modules' => [ current_login_module ]})
    $current_attrs   =  FlatHash.new({'login-modules' => [ expected_login_module ]})
    $engine_path = @resource[:engine_path]
    $nic = @resource[:nic]
    $path = "/subsystem=security/security-domain=#{@resource[:security_domain_name]}/authentication=classic"
    operation ="read-resource"
    params = "recursive=true"
    begin
      $current_attrs = PuppetX::Jboss.exec_command($engine_path, $nic, $path, operation, params)
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def build_params_for_create
    debug "Create Hash from parameters type"
    module_options = FlatHash.new({
      "java-naming-factory-initial" => "#{@resource[:java_naming_factory_initial]}",
      "java-naming-provider-url" => "#{@resource[:java_naming_provider_url]}",
      "java-naming-security-authentication" => "#{@resource[:java_naming_security_authentication]}",
      "bindDN" => "#{@resource[:bind_dn]}",
      "bindCredential" => "#{@resource[:bind_credential]}",
      "allowEmptyPasswords" => "#{@resource[:allow_empty_passwords]}",
      "baseCtxDN" => "#{@resource[:base_ctx_dn]}",
      "baseFilter" => "#{@resource[:base_filter]}",
      "rolesCtxDN" => "#{@resource[:roles_ctx_dn]}",
      "roleFilter" => "#{@resource[:role_filter]}",
      "roleAttributeID" => "#{@resource[:role_attribute_id]}",
      "roleNameAttributeID" => "#{@resource[:role_name_attribute_id]}",
      "roleAttributeIsDN" => "#{@resource[:role_attribute_is_dn]}",
      "searchScope" => "#{@resource[:search_scope]}",
      "throwValidateError" => "#{@resource[:throw_validate_error]}"
    })
    params = "login-modules=[ {\"flag\" =>\"#{@resource[:flag]}\", \
                               \"code\" =>\"LdapExtended\", \
                               \"module-options\" => #{module_options.to_s}}]"
    Puppet.debug(params)
    return params
  end

  def create
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, 'add', build_params_for_create())
  end

  def destroy
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, 'remove')
  end

  def flush
    PuppetX::Jboss.update_attributes($engine_path, $nic, $path, $current_attrs, $expected_attrs)
  end

  def flag
    return $current_attrs['login-modules'][0]['module-options']['flag']
  end

  def flag=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['flag'] = new_value
  end

  def code
    return $current_attrs['login-modules'][0]['module-options']['code']
  end

  def code=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['code'] = new_value
  end

  def java_naming_factory_initial
    return $current_attrs['login-modules'][0]['module-options']['code']
  end

  def java_naming_factory_initial=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['code'] = new_value
  end

  def java_naming_provider_url
    return $current_attrs['login-modules'][0]['module-options']['java_naming_provider_url']
  end

  def java_naming_provider_url=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['java_naming_provider_url'] = new_value
  end

  def java_naming_security_authentication
    return $current_attrs['login-modules'][0]['module-options']['java_naming_security_authentication']
  end

  def java_naming_security_authentication=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['java_naming_security_authentication'] = new_value
  end

  def bind_dn
    return $current_attrs['login-modules'][0]['module-options']['bindDn']
  end

  def bind_dn=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['bindDn'] = new_value
  end

  def bind_credential
    return $current_attrs['login-modules'][0]['module-options']['bindCredential']
  end

  def bind_credential=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['bindCredential'] = new_value
  end

  def allow_empty_passwords
    return $current_attrs['login-modules'][0]['module-options']['allowEmptyPasswords']
  end

  def allow_empty_passwords=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['allowEmptyPasswords'] = new_value
  end

  def base_ctx_dn
    return $current_attrs['login-modules'][0]['module-options']['baseCtxDN']
  end

  def base_ctx_dn=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['baseCtxDN'] = new_value
  end

  def base_filter
    return $current_attrs['login-modules'][0]['module-options']['baseFilter']
  end

  def base_filter=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['baseFilter'] = new_value
  end

  def roles_ctx_dn
    return $current_attrs['login-modules'][0]['module-options']['rolesCtxDN']
  end

  def roles_ctx_dn=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['rolesCtxDN'] = new_value
  end

  def role_filter
    return $current_attrs['login-modules'][0]['module-options']['roleFilter']
  end

  def role_filter=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['roleFilter'] = new_value
  end

  def role_attribute_id
    return $current_attrs['login-modules'][0]['module-options']['roleAttributeID']
  end

  def role_attribute_id=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['roleAttributeID'] = new_value
  end

  def role_name_attribute_id
    return $current_attrs['login-modules'][0]['module-options']['roleNameAttributeID']
  end

  def role_name_attribute_id=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['roleNameAttributeID'] = new_value
  end

  def role_attribute_is_dn
    return $current_attrs['login-modules'][0]['module-options']['roleAttributeIsDN']
  end

  def role_attribute_is_dn=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['roleAttributeIsDN'] = new_value
  end

  def search_scope
    return $current_attrs['login-modules'][0]['module-options']['searchScope']
  end

  def search_scope=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['searchScope'] = new_value
  end

  def throw_validate_error
    return $current_attrs['login-modules'][0]['module-options']['throwValidateError']
  end

  def throw_validate_error=(new_value)
    $expected_attrs['login-modules'][0]['module-options']['throwValidateError'] = new_value
  end

end

