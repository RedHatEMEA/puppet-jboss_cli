require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:ldap_security_realm) do
  @doc = "Manages LDAP Security Realm used to configuration JBoss Console \
    authentication against LDAP"

  ensurable
  
  newparam(:name, :namevar => true) do
    desc "The extension's name."
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
    isrequired
  end

  newproperty(:url) do
    desc "The LDAP server URL"
    isrequired
  end

  newproperty(:search_dn) do
    desc "The dn (username) used to connect to the LDAP and perform the search."
    isrequired
  end

  newproperty(:search_credential) do
    desc "The password or credentials associated with the dn used to connect \
    and search the LDAP. VAULT expressions are supported."
    isrequired
  end

  newproperty(:base_dn) do
    desc "Starts the search within this base."
    isrequired
  end

  newproperty(:advanced_filter) do
    desc "The LDAP filter used to refine users "
    defaultto("(&amp; (sAMAccountName={0})(memberOf=AU_EVOPAJEE_RSP))")
  end

end

