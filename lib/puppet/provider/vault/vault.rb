require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:vault).provide(:vault) do
  include PuppetX::Jboss
  @doc = "Manages vault (to store sensitive data) with the jboss-cli.sh"
  confine :osfamily => :redhat
  def exists?
    vault_options = { 'ENC_FILE_DIR' => @resource[:enc_file_dir],
      'KEYSTORE_URL' => @resource[:keystore_url],
      'KEYSTORE_PASSWORD' => @resource[:keystore_password],
      'KEYSTORE_ALIAS' => @resource[:keystore_alias],
      'SALT' => @resource[:salt] ,
      'ITERATION_COUNT' => @resource[:iteration_count] }
    flat_vault_options = FlatHash.new(vault_options)
    $expected_attrs = {'vault-options' => flat_vault_options }
    $current_attrs = {}
    $engine_path = @resource[:engine_path]
    $nic = @resource[:nic]
    $path = "/core-service=vault"
    begin
      $current_attrs = PuppetX::Jboss.exec_command($engine_path, $nic, $path, "read-resource", "recursive=true")
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def create
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, "add", build_params_for_create())
  end

  def destroy
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, "remove")
  end

  def flush
    PuppetX::Jboss.update_attributes($engine_path, $nic, $path, $current_attrs, $expected_attrs)
  end

  def enc_file_dir
    return $current_attrs['vault-options']["ENC_FILE_DIR"]
  end

  def enc_file_dir=(new_value)
    $expected_attrs['vault-options']["ENC_FILE_DIR"] = new_value
  end

  def keystore_url
    return $current_attrs['vault-options']["KEYSTORE_URL"]
  end

  def keystore_url=(new_value)
    $expected_attrs['vault-options']["KEYSTORE_URL"] = new_value
  end

  def keystore_password
    return $current_attrs['vault-options']["KEYSTORE_PASSWORD"]
  end

  def keystore_password=(new_value)
    $expected_attrs['vault-options']["KEYSTORE_PASSWORD"] = new_value
  end

  def keystore_alias
    return $current_attrs['vault-options']["KEYSTORE_ALIAS"]
  end

  def keystore_alias=(new_value)
    $expected_attrs['vault-options']["KEYSTORE_ALIAS"] = new_value
  end

  def salt
    return $current_attrs['vault-options']["SALT"]
  end

  def salt=(new_value)
    $expected_attrs['vault-options']["SALT"] = new_value
  end

  def iteration_count
    return $current_attrs['vault-options']["ITERATION_COUNT"]
  end

  def iteration_count=(new_value)
    $expected_attrs['vault-options']["ITERATION_COUNT"] = "#{new_value}"
  end

  def build_params_for_create
    debug "Create Hash from parameters type"
    params = "vault-options={\"ENC_FILE_DIR\"=>\"#{@resource[:enc_file_dir]}\", \
      \"KEYSTORE_URL\"=>\"#{@resource[:keystore_url]}\",\
      \"KEYSTORE_PASSWORD\"=>\"#{@resource[:keystore_password]}\",\
      \"KEYSTORE_ALIAS\"=>\"#{@resource[:keystore_alias]}\",\
      \"SALT\"=>\"#{@resource[:salt]}\",\
      \"ITERATION_COUNT\"=>\"#{@resource[:iteration_count]}\"\
    }"
    return params
  end

end
