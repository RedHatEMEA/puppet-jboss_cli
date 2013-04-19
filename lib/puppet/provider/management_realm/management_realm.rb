require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'
require 'rexml/document'


Puppet::Type.type(:management_realm).provide(:management_realm) do
  include PuppetX::Jboss
  @doc = "Manages the ManagementRealm(s) used to configure authentication agains consoles."

  confine :osfamily => :redhat

  def self.instances
    return []
  end

  def init()
    $engine_path = @resource[:engine_path]
    $nic = @resource[:nic]
    $path = "/core-service=management/security-realm=#{@resource[:management_realm_name]}"
  end

  def exists?
    init()
    begin
      PuppetX::Jboss.exec_command($engine_path, $nic, $path, 'read-resource')
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def create
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, "add")
  end

  def destroy
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, "remove")
  end

end
