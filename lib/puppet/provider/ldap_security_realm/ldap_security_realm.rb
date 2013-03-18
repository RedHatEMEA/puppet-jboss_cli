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
      PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    end

    if !management_realm_exists?()
      path = "/core-service=management/security-realm=ManagementRealmHttp"
      operation ="add"
      params = ""
      PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    end

    if !security_realm_exists?()
      if properties_authentication_exists?()
        remove_properties_authentication()
      end
      path = "/core-service=management/security-realm=ManagementRealmHttp/authentication=ldap"
      operation ="add"
      params = "connection=ad-bdf, recursive=true, base-dn=\"#{@resource[:base_dn]}\", \
        advanced-filter=\"#{@resource[:advanced_filter]}\""
      PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    end
  end

  def destroy
    if security_realm_exists?()
      path = "/core-service=management/security-realm=ManagementRealmiHttp/authentication=ldap"
      operation ="remove"
      params = ""
      PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    end
    if ldap_connection_exists?()
      path = "/core-service=management/ldap-connection=ad-bdf"
      operation ="remove"
      params = ""
      PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
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
      PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end


  def management_realm_exists?
    debug  "Checking if the ManagementRealm exists"
    path = "/core-service=management/security-realm=ManagementRealmHttp"
    operation ="read-resource"
    params = ""
    begin
      PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def security_realm_exists?
    debug  "Checking if the ManagementRealm exists"
    path = "/core-service=management/security-realm=ManagementRealmHttp/authentication=ldap"
    operation ="read-resource"
    params = ""
    begin
      PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def  properties_authentication_exists?
    debug  "Checking if the properties authentication exists"
    path = "/core-service=management/security-realm=ManagementRealmHttp/authentication=properties"
    operation ="read-resource"
    params = ""
    begin
      PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end
  def remove_properties_authentication
    path = "/core-service=management/security-realm=ManagementRealmHttp/authentication=properties"
    operation ="remove"
    params = ""
    begin
      PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end
  def restore_properties_authentication
    path = "/core-service=management/security-realm=ManagementRealmHttp/authentication=properties"
    operation ="add"
    params = 'path="mgmt-users.properties", relative-to="jboss.server.config.dir"'
    begin
      PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
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
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end
  def url=(new_value)
    path = "/core-service=management/ldap-connection=ad-bdf"
    operation ="write-attribute"
    params = "name=url, value=#{new_value}"
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def search_dn
    path = "/core-service=management/ldap-connection=ad-bdf"
    operation ="read-attribute"
    params = "name=search-dn"
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end
  def search_dn=(new_value)
    path = "/core-service=management/ldap-connection=ad-bdf"
    operation ="write-attribute"
    params = "name=search-dn, value=\"#{new_value}\""
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def search_credential
    path = "/core-service=management/ldap-connection=ad-bdf"
    operation ="read-attribute"
    params = "name=search-credential"
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end
  def search_credential=(new_value)
    path = "/core-service=management/ldap-connection=ad-bdf"
    operation ="write-attribute"
    params = "name=search-credential, value=\"#{new_value}\""
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end


  # ManagementRealm properties
  def base_dn
    path = "/core-service=management/security-realm=ManagementRealmHttp/authentication=ldap"
    operation ="read-attribute"
    params = "name=base-dn"
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end
  def base_dn=(new_value)
    path = "/core-service=management/security-realm=ManagementRealmHttp/authentication=ldap"
    operation ="write-attribute"
    params = "name=base-dn, value=\"#{new_value}\""
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def advanced_filter
    path = "/core-service=management/security-realm=ManagementRealmHttp/authentication=ldap"
    operation ="read-attribute"
    params = "name=advanced-filter"
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    return PuppetX::Jboss.parse_single_cli_result(output)
  end
  def advanced_filter=(new_value)
    path = "/core-service=management/security-realm=ManagementRealmHttp/authentication=ldap"
    operation ="write-attribute"
    params = "name=advanced-filter, value=\"#{new_value}\""
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def http_enabled
    path = "/core-service=management"
    operation ="read-resource(recursive=true)"
    params = ""
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    result =  PuppetX::Jboss.parse_cli_result_as_map(output)
    socket_binding =  PuppetX::Jboss.hash_path(result, '/management-interface/http-interface/socket-binding')
    info( "operation: #{operation}, params:  #{params}, socket_binding:  #{socket_binding}, current_value:  #{socket_binding != 'undefined'}")
    return socket_binding
  end
  def http_enabled=(new_value)
    # ATTENTION: Uses ternary expression to build the operation name and the  params
    path = "/core-service=management/management-interface=http-interface"
    operation = (new_value == "management-http") ? "write-attribute" : "undefine-attribute"
    params = (new_value == "management-http") ? "name=\"socket-binding\", value=\"management-http\"" : "name=\"socket-binding\""
    info( "operation: #{operation}, params:  #{params}, new_value:  #{new_value}")
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
  end

  def https_enabled
    path = "/core-service=management"
    operation ="read-resource(recursive=true)"
    params = ""
    output = PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    result =  PuppetX::Jboss.parse_cli_result_as_map(output)
    secure_socket_binding  =  PuppetX::Jboss.hash_path(result, '/management-interface/http-interface/secure-socket-binding')
    return ( secure_socket_binding )
  end

  def https_enabled=(new_value)
    # ATTENTION: Uses ternary expression to build the operation name and the params
    path = "/core-service=management/security-realm=ManagementRealmHttp/server-identity=ssl"
    operation = (new_value == "management-https") ? "add" : "remove"
    params = (new_value == "management-https") ? "keystore-relative-to=\"jboss.server.config.dir\", \
                          alias=\"management-ssl\", \
                          keystore-password=\"#{@resource[:ssl_keystore_password]}\", \
                          keystore-path=\"keystore/management-ssl/management-ssl.keystore\"" : ""
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)

    path = "/core-service=management/management-interface=http-interface"
    operation = (new_value ==  "management-https" ) ? "write-attribute" : "undefine-attribute"
    params = (new_value ==  "management-https") ? "name=\"secure-socket-binding\", value=\"management-https\"" : "name=\"secure-socket-binding\""
    PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    begin
      path = "/core-service=management/management-interface=http-interface"
      operation = (new_value ==  "management-https") ? "write-attribute" : "undefine-attribute"
      params = (new_value ==  "management-https") ? "name=\"security-realm\", value=\"ManagementRealmHttp\"": "name=\"security-realm\""
      PuppetX::Jboss.run_cli_command(@resource[:engine_path], @resource[:nic], path, operation, params)
    rescue Puppet::ExecutionFailure => e
      error(e)
      fail("Disabling HTTPS failed: Check that you still have a Web management interface, by enabling HTTP for instance")
    end
  end
end



