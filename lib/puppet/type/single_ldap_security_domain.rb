require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:single_ldap_security_domain) do
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
    desc "The resource name"
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
    isrequired
  end


  newparam(:security_domain_name) do
    desc "The name of a JAAS Security-manager which handles authentication."
  end


  newproperty(:flag) do
    desc <<-EOF
        The flag controls how the module participants in the overall procedure.
        - Type: String
        - Nillable: False
        - Allowed: required, requisite, sufficient or optional
    EOF

    defaultto("required")
    newvalues("required", "requisite", "sufficient", "optional")
  end

  newproperty(:code) do
    desc <<-EOF
         Class name of the module to be instantiated.
         - Type: String
         - Nillable: false
    EOF

    defaultto("LdapExtended")
    newvalues("LdapExtended")
  end

  newproperty(:java_naming_factory_initial) do
    desc "Context.INITIAL_FACTORY_FACTORY"

    defaultto("com.sun.jndi.ldap.LdapCtxFactory")
    newvalues("com.sun.jndi.ldap.LdapCtxFactory")
  end

  newproperty(:java_naming_provider_url) do
    desc "Context.PROVIDER_URL"

    validate do |value|
      unless value =~ /^ldap:\/\/[0-9a-zA-Z]+([\-.][0-9a-zA-Z]+)*:\d{1,}/
        raise ArgumentError , "#{value} is not a valid java-naming-provider-url."
      end
    end
  end

  newproperty(:java_naming_security_authentication) do
    desc "Context.SECURITY_AUTHENTICATION"

    defaultto("simple")
    newvalues("simple")
  end

  newproperty(:bind_dn) do
    desc "The DN used to bind against the ldap server for the user and roles queries."
  end

  newproperty(:bind_credential) do
    desc "The password for the bindDN. This can be encrypted if the jaasSecurityDomain is specified."
  end

  newproperty(:allow_empty_passwords) do
    desc <<-EOF
        A flag indicating if empty(length == 0) passwords should be passed to the ldap server.
        An empty password is treated as an anonymous login by some ldap servers and this may
        not be a desirable feature. Set this to false to reject empty passwords, true to have
        the ldap server validate the empty password.
    EOF

    defaultto :false
    newvalues(:true, :false)

    munge do |value|
      @resource.munge_boolean(value)
    end
  end

  newproperty(:base_ctx_dn) do
    desc "The fixed DN of the context to start the user search from."

  end

  newproperty(:base_filter) do
    desc "A search filter used to locate the context of the user to authenticate."

    defaultto("(sAMAccountName={0})")
  end

  newproperty(:roles_ctx_dn) do
    desc "The fixed DN of the context to search for user roles"

  end

  newproperty(:role_filter) do
    desc "A search filter used to locate the roles associated with the authenticated user."

    defaultto("(member={1})")
  end

  newproperty(:role_attribute_id) do
    desc "The name of the role attribute of the context which corresponds to the name of the role."

    defaultto("memberOf")
  end

  newproperty(:role_name_attribute_id) do
    desc <<-EOF
        The name of the role attribute of the context which corresponds to the name of the role.
        If the role_attribute_is_dn property is set to true, this property is used to find the role
        object's name attribute. If the role_attribute_is_dn property is set to false, this property
        is ignored.
    EOF

    defaultto("cn")
  end

  newproperty(:role_attribute_is_dn) do
    desc <<-EOF
        A flag indicating whether the user's role attribute contains fully distinguished name of a role
        object, or the user's role attribute contains the role name.
    EOF

    defaultto :true
    newvalues(:true, :false)

    munge do |value|
      @resource.munge_boolean(value)
    end
  end

  newproperty(:search_scope) do
    desc <<-EOF
        Sets the search scope to one of the strings.
        - OBJECT_SCOPE  : only search the named roles context.
        - ONELEVEL_SCOPE: search directly under the named roles context.
        - SUBTREE_SCOPE : if the roles context is not a DirContext, search only the object.
                          if the roles context is a DirContext, search the subtree rooted at the named
                          object, including the named object itself.
    EOF

    defaultto("SUBTREE_SCOPE")
    newvalues("SUBTREE_SCOPE")
  end

  newproperty(:throw_validate_error) do
    desc ""

    defaultto :true
    newvalues(:true, :false)

    munge do |value|
      @resource.munge_boolean(value)
    end
  end
end
