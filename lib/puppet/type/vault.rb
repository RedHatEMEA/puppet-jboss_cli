require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/redhat/jboss'

Puppet::Type.newtype(:vault) do
  @doc = "Manages vault via jboss-cli.sh"

  ensurable
  newparam(:name, :namevar => true) do
    desc "The vault name (only used to uniquely identify a vault in puppet).\
          There can only be one vault per instance"
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
    isrequired
  end

  newparam(:enc_file_dir) do
    desc "The directory containing the ENC files used by the vault."
    defaultto("\${jboss.server.config.dir}/evopajee-vault/")
  end

  newparam(:keystore_url) do
    desc "The URL for the keystore file. The file has to be created previously \
    with the keytool tool. The storepass and keypass for this keystore *must* \
    be identical."
    defaultto("\${jboss.server.config.dir}/evopajee-vault.keystore")
  end

  newparam(:keystore_password) do
    desc "The keystore password used to open the keystore"
  end

  newparam(:keystore_alias) do
    desc "One of the aliases present in the keystore."
    defaultto("vault")
  end

  newparam(:salt) do
    desc "An 8 chars word used to cipher the keystore password in order to \
          store it masked in JBoss configuration"
    validate do |value|
      unless value =~ /.{8}$/
        raise ArgumentError, "\"#{value}\" must be exactly 8 chars."
      end
    end
  end

  newparam(:iteration_count) do
    desc "The number of iteration used to cipher the masked password."
    defaultto("12")
    validate do |value|
      unless value =~ /^\d{1,2}$/
        raise ArgumentError, "\"#{value}\" is not a valid Iteration Count."
      end
    end
  end
end

