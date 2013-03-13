require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:ldap_security_realm).provide(:ldap_security_realm) do
  include PuppetX::Jboss
  @doc = "Manages the LDAP Security Realm used to control access to the \
    JBoss Console using an LDAP directory."

  confine :osfamily => :redhat

  def create
    if !ldap_connection_exists?()
      path = "/core-service=management/ldap-connection=ad-bdf"
      operation = "add"
      params = "url=\"#{@resource[:url]}\", search-dn=\"#{@resource[:search_dn]}\", \
        search-credential=\"#{@resource[:search_credential]}\""
      PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    end
    if !security_realm_exists?()
      if properties_authentication_exists?()
        remove_properties_authentication()
      end
      path = "/core-service=management/security-realm=ManagementRealm/authentication=ldap"
      operation ="add"
      params = "connection=ad-bdf, recursive=true, base-dn=\"#{@resource[:base_dn]}\", \
        advanced-filter=\"#{@resource[:advanced_filter]}\""
      PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    end
  end

  def destroy
    if security_realm_exists?()
      path = "/core-service=management/security-realm=ManagementRealm/authentication=ldap"
      operation ="remove"
      params = ""
      PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    end
    if ldap_connection_exists?()
      path = "/core-service=management/ldap-connection=ad-bdf"
      operation ="remove"
      params = ""
      PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    end
    # Restoring properties authentication must be done even if ldap_connection
    # does not exist
    if !properties_authentication_exists?()
      restore_properties_authentication()
    end
  end

  def exists?
    #If the ldap connection exists or the security realm exist, configuration 
    # and in this case, we should check it (or check its removal)
    # If the properties authentication does not exist, the configuration may be
    # incomplete also.
    return ldap_connection_exists?() && security_realm_exists?()
  end

  def ldap_connection_exists?
    debug  "Checking if the LDAP connection exists ?"
    path = "/core-service=management/ldap-connection=ad-bdf"
    operation ="read-resource"
    params = ""
    begin
      PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def security_realm_exists?
    debug  "Checking if the ManagementRealm exists"
    path = "/core-service=management/security-realm=ManagementRealm/authentication=ldap"
    operation ="read-resource"
    params = ""
    begin
      PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def  properties_authentication_exists?
    debug  "Checking if the properties authentication exists"
    path = "/core-service=management/security-realm=ManagementRealm/authentication=properties"
    operation ="read-resource"
    params = ""
    begin
      PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end
  def remove_properties_authentication 
    path = "/core-service=management/security-realm=ManagementRealm/authentication=properties"
    operation ="remove"
    params = ""
    begin
      PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end
  def restore_properties_authentication
    path = "/core-service=management/security-realm=ManagementRealm/authentication=properties"
    operation ="add"
    params = 'path="mgmt-users.properties", relative-to="jboss.server.config.dir"'
    begin
      PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  # LDAP connection properties
  def url
    path = "/core-service=management/ldap-connection=ad-bdf"
    operation ="read-attribute"
    params = "name=url"
    output = PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end
  def url=(new_value)
    path = "/core-service=management/ldap-connection=ad-bdf"
    operation ="write-attribute"
    params = "name=url, value=#{new_value}"
    PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def search_dn
    path = "/core-service=management/ldap-connection=ad-bdf"
    operation ="read-attribute"
    params = "name=search-dn"
    output = PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end
  def search_dn=(new_value)
    path = "/core-service=management/ldap-connection=ad-bdf"
    operation ="write-attribute"
    params = "name=search-dn, value=\"#{new_value}\""
    PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def search_credential
    path = "/core-service=management/ldap-connection=ad-bdf"
    operation ="read-attribute"
    params = "name=search-credential"
    output = PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end
  def search_credential=(new_value)
    path = "/core-service=management/ldap-connection=ad-bdf"
    operation ="write-attribute"
    params = "name=search-credential, value=\"#{new_value}\""
    PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end


  # ManagementRealm properties
  def base_dn
    path = "/core-service=management/security-realm=ManagementRealm/authentication=ldap"
    operation ="read-attribute"
    params = "name=base-dn"
    output = PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end
  def base_dn=(new_value)
    path = "/core-service=management/security-realm=ManagementRealm/authentication=ldap"
    operation ="write-attribute"
    params = "name=base-dn, value=\"#{new_value}\""
    PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def advanced_filter
    path = "/core-service=management/security-realm=ManagementRealm/authentication=ldap"
    operation ="read-attribute"
    params = "name=advanced-filter"
    output = PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end
  def advanced_filter=(new_value)
    path = "/core-service=management/security-realm=ManagementRealm/authentication=ldap"
    operation ="write-attribute"
    params = "name=advanced-filter, value=\"#{new_value}\""
    PuppetX::Jboss.run_jboss_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

end
