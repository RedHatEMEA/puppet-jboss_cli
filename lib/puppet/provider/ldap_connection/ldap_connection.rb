require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'
require 'rexml/document'

Puppet::Type.type(:ldap_connection).provide(:ldap_connection) do
  include PuppetX::Jboss
  @doc = "Manages the LDAP Connection to be used by Security Realm used to control access to the \
    JBoss Console using an LDAP directory."

  confine :osfamily => :redhat
  def self.instances
    return []
  end

  def exists?
    $expected_attrs = {}
    $current_attrs = {}
    $engine_path = @resource[:engine_path]
    $nic = @resource[:nic]
    $path = "/core-service=management/ldap-connection=#{@resource[:connection_name]}"
    operation ="read-resource"
    params = "recursive=true"
    begin
      $current_attrs = PuppetX::Jboss.exec_command($engine_path, $nic, $path, operation, params)
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def create
    params = "url=\"#{@resource[:url]}\", search-dn=\"#{@resource[:search_dn]}\", \
        search-credential=\"#{@resource[:search_credential]}\""
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, "add", params)
  end

  def destroy
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, "remove")
  end

  def flush
    PuppetX::Jboss.update_attributes($engine_path, $nic, $path, $current_attrs, $expected_attrs)
  end

  # LDAP connection properties
  def url
    return $current_attrs["url"]
  end

  def url=(new_value)
    $expected_attrs["url"] = new_value
  end

  def search_dn
    return $current_attrs["search-dn"]
  end

  def search_dn=(new_value)
    $expected_attrs["search-dn"] = new_value
  end

  def search_credential
    return $current_attrs["search-credential"]
  end

  def search_credential=(new_value)
    $expected_attrs["search-credential"] = new_value
  end

end

