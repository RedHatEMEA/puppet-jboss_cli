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
  end

  newparam(:nic) do
    desc "The Network Interface attached to the instance."
  end

  newparam(:connector_name) do
    desc "The connector's name."
  end

  newproperty(:certificate_key_file) do
    desc "A String, which defines the path of the servers's keystore. \
      This keystore contains the server's private key."

    defaultto(:nil)
  end

  newproperty(:key_alias) do
    desc "A String, which points to an alias in the keystore refered by \
      the attribute 'certificate_key_file'. \
      This alias contains a private key entry. \
      This private key is the server's private key."

    defaultto("jboss")
  end

  newproperty(:password) do
    desc "A String, which is the password of the keystore refered by the 
      attribute 'certificate_key_file'. \
      /!\ The keystore's storepass must be equal to the alias's keypass."

    defaultto(:nil)
  end

  newproperty(:keystore_type) do
    desc "A String, which defines the keystore type. \
      Must be one of 'JKS', 'PKCS12'."

    defaultto(:nil)
    newvalues("JKS", "PKCS12", :nil)
    # Convert Raw data to Typed data
    munge do |value|
      return value if value == :nil
      return String(value)
    end
  end

  newproperty(:protocol) do
    desc "A String, which defines supported protocol. \
      Comma separeted values."

    defaultto("ALL")
    newvalues("ALL", "SSLv2", "SSLv3", "SSLv2+,SSLv3", "TLSv1")
    # Convert Raw data to Typed data
    munge do |value|
      return String(value)
    end
  end

  newproperty(:cipher_suite) do
    desc "A String, which defines supported ciphers. \
      Comma separeted values."

    defaultto(:nil)
  end

  newproperty(:verify_client) do
    desc "A String, which indicate if this ssl-connector will enable \
      client-certificate authentication. \
      Should contains one of 'true, 'false', or 'ask'."

    defaultto(:nil)
    newvalues("true", "false", "ask", :nil)
    # Convert Raw data to Typed data
    munge do |value|
      return value if value == :nil
      return String(value)
    end
  end

  newproperty(:ca_certificate_file) do
    desc "A String, which defines the path of the servers's truststore. \
      This truststore store contains the certificate of the Certificate \
      Authorities who signed the client certificates."

    defaultto(:nil)
  end

  newproperty(:truststore_type) do
    desc "A String, which defines the truststore type. \
      Must be one of 'JKS', 'PKCS12'."

    defaultto(:nil)
    newvalues("JKS", "PKCS12", :nil)
    # Convert Raw data to Typed data
    munge do |value|
      return value if value == :nil
      return String(value)
    end
  end

  validate do
    errors = []
    errors.push("Attribute 'engine_path' is mandatory !") if !@parameters.include?(:engine_path)
    errors.push("Attribute 'nic' is mandatory !") if !@parameters.include?(:nic)
    errors.push( "Attribute 'connector_name' is mandatory !") if !@parameters.include?(:connector_name)
    raise Puppet::Error, errors.inspect if !errors.empty?
  end

end
