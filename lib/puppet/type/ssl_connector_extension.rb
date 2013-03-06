require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.newtype(:ssl_connector_extension) do
  @doc = "Manages SSL extension for a JBoss Web connector"

  ensurable

  newparam(:name, :namevar => true) do
    desc "The extension's name."
  end

  newparam(:engine_path) do
    desc "The JBoss Engine path."
    isrequired
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
    isrequired
  end

  newparam(:connector_name) do
    desc "The connector's name."
    isrequired
  end

  newproperty(:protocol) do
    desc "The SSL protocol used on this connector and its version."
    defaultto("ALL")
    newvalues("ALL", "SSLv2","SSLv3","SSLv2+,SSLv3","TLSv1")
  end

  newproperty(:certificate_key_file) do
    desc "The keystore containing the server certificate to be loaded.
              The storepass and keypass for the keystore file must be identical."
    isrequired
  end

  newproperty(:password) do
    desc "The keystore password of the keystore refered by certificate_key_file. \
              The storepass and keypass for the keystore file must be identical."
    isrequired
  end
end
