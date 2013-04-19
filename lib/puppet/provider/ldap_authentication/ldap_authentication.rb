require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'
require 'rexml/document'


Puppet::Type.type(:ldap_authentication).provide(:ldap_authentication) do
  include PuppetX::Jboss
  @doc = "Manages the LDAP's ManagementRealm(s) used to configure authentication agains consoles."

  confine :osfamily => :redhat

  def self.instances
    return []
  end

  def exists?
    $expected_attrs = {}
    $current_attrs = {}
    $engine_path = @resource[:engine_path]
    $nic = @resource[:nic]
    $path = "/core-service=management/security-realm=#{@resource[:management_realm_name]}/authentication=ldap"
    begin
      $current_attrs = PuppetX::Jboss.exec_command($engine_path, $nic, $path, 'read-resource', 'recursive=true')
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def create
    params = "connection=#{@resource[:ldap_connection_name]}, recursive=true, base-dn=\"#{@resource[:base_dn]}\", \
              advanced-filter=\"#{@resource[:advanced_filter]}\""
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, "add", params)
  end

  def destroy
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, "remove")
  end

  def flush
    PuppetX::Jboss.update_attributes($engine_path, $nic, $path, $current_attrs, $expected_attrs)
  end

  # ManagementRealm properties
  def base_dn
    return $current_attrs['base-dn']
  end
  def base_dn=(new_value)
    $expected_attrs['base-dn']=new_value
  end

  def advanced_filter
    return $current_attrs['advanced-filter']
  end
  def advanced_filter=(new_value)
    $expected_attrs['advanced-filter'] = new_value
  end
end

