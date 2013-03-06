require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:ldap_security_domain) do
  @doc = "Manages JaaS Security Domain via jboss-cli.sh"

  ensurable

  def munge_boolean(value)
    case value
      when true, "true", :true
        :true
      when false, "false", :false
        :false
    else
      fail("This parameter only takes booleans")
    end
  end

  newparam(:name, :namevar => true) do
    desc "Contains the name of a JAAS Security-manager which handles authentication."
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
    isrequired
  end

  newparam(:flag) do
    desc "Flags for security modules."

    defaultto("required")
    newvalues("required", "requisite", "sufficient", "optional")
  end

  newparam(:code) do
    desc "code."

    defaultto("LdapExtended")
    newvalues("LdapExtended")
  end

  newparam(:java_naming_factory_initial) do
    desc "java.naming.factory.initial."

    defaultto("com.sun.jndi.ldap.LdapCtxFactory")
    newvalues("com.sun.jndi.ldap.LdapCtxFactory")
  end

  newparam(:java_naming_provider_url) do
    desc ""

    validate do |value|
      unless value =~ /^ldap:\/\/[0-9a-zA-Z]+([\-.][0-9a-zA-Z]+)*:\d{1,}/
        raise ArgumentError , "#{value} is not a valid java-naming-provider-url."
      end
    end
  end

  newparam(:java_naming_security_authentication) do
    desc "java.naming.security.authentication."

    defaultto("simple")
    newvalues("simple")
  end

  newparam(:bind_dn) do
    desc "Bind DN"
  end

  newparam(:bind_credential) do
    desc "."
  end

  newparam(:allow_empty_passwords) do
    desc "."

    defaultto :false
    newvalues(:true, :false)

    munge do |value|
      @resource.munge_boolean(value)
    end
  end

  newparam(:base_ctx_dn) do
    desc ""

  end

  newparam(:base_filter) do
    desc ""

    defaultto("(sAMAccountName={0})")
  end

  newparam(:roles_ctx_dn) do
    desc ""

  end

  newparam(:role_filter) do
    desc ""

    defaultto("(member={1})")
  end

  newparam(:role_attribute_id) do
    desc ""

    defaultto("memberOf")
  end

  newparam(:role_name_attribute_id) do
    desc ""

    defaultto("cn")
  end

  newparam(:role_attribute_is_dn) do
    desc ""

    defaultto :true
    newvalues(:true, :false)

    munge do |value|
      @resource.munge_boolean(value)
    end
  end

  newparam(:search_scope) do
    desc ""

    defaultto("SUBTREE_SCOPE")
    newvalues("SUBTREE_SCOPE")
  end

  newparam(:throw_validate_error) do
    desc ""

    defaultto :true
    newvalues(:true, :false)

    munge do |value|
      @resource.munge_boolean(value)
    end
  end
end
