require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:oracle_xa_datasource).provide(:ora_xa_ds) do
  include PuppetX::Jboss
  @doc = "Manages Oracle xa Datasources for an instance with the jboss-cli.sh"

  confine :osfamily => :redhat

  def self.instances
    return []
  end

  def init()
    $attrs_to_write = {}
    $attrs_to_add = {}
    $current_attrs = {}
    $engine_path = @resource[:engine_path]
    $nic = @resource[:nic]
    $path = "/subsystem=datasources/xa-data-source=#{@resource[:ds_name]}"
  end

  def exists?
    init()
    begin
      $current_attrs = PuppetX::Jboss.exec_command($engine_path, $nic, $path, "read-resource", "recursive=true")
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def create
    PuppetX::Jboss.add_attributes($engine_path, $nic, $path, $current_attrs, build_attrs_to_add())
  end

  def destroy
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, "remove")
  end

  def flush
    PuppetX::Jboss.write_attributes($engine_path, $nic, $path, $current_attrs, $attrs_to_write)
    PuppetX::Jboss.add_attributes($engine_path, $nic, $path, $current_attrs, $attrs_to_add)
  end

  def build_attrs_to_add()
    fail("Attribute 'dirver_name' is necessary for the 'create' operation to succeed.") if @resource[:driver_name] == :nil
    fail("A 'JDBC Driver' called '#{@resource[:driver_name]}' is necessary for the create operation to succeed.") if jdbc_driver_exists?(@resource[:driver_name]) == false
    fail("Attribute 'jndi_name' is necessary for the 'create' operation to succeed.") if @resource[:jndi_name] == :nil
    fail("Attribute 'connection_url' is necessary for the 'create' operation to succeed.") if @resource[:connection_url] == :nil
    fail("Attribute 'user_name' is necessary for the 'create' operation to succeed.") if @resource[:user_name] == :nil
    fail("Attribute 'password' is necessary for the 'create' operation to succeed.") if @resource[:password] == :nil

    to_add = {}
    to_add["jndi-name"] = @resource[:jndi_name]
    to_add["driver-name"] = @resource[:driver_name]
    to_add["min-pool-size"] = @resource[:min_pool_size] if @resource[:min_pool_size] != nil
    to_add["max-pool-size"] = @resource[:max_pool_size] if @resource[:max_pool_size] != nil
    to_add["idle-timeout-minutes"] = @resource[:idle_timeout_minutes] if @resource[:idle_timeout_minutes] != nil
    to_add["query-timeout"] = @resource[:query_timeout] if @resource[:query_timeout] != nil
    to_add["background-validation"] = @resource[:background_validation] if @resource[:background_validation] != nil
    to_add["valid-connection-checker-class-name"] = @resource[:valid_connection_checker_class_name] if @resource[:valid_connection_checker_class_name] != nil
    to_add["no-tx-separate-pool"] = @resource[:no_tx_separate_pool]
    to_add["pool-prefill"] = @resource[:pool_prefill] if @resource[:pool_prefill] != nil
    to_add["pool-use-strict-min"] = @resource[:pool_use_strict_min] if @resource[:pool_use_strict_min] != nil
    to_add["prepared-statements-cache-size"] = @resource[:prepared_statements_cache_size] if @resource[:prepared_statements_cache_size] != nil
    to_add["share-prepared-statements"] = @resource[:share_prepared_statements] if @resource[:share_prepared_statements] != nil
    to_add["use-java-context"] = @resource[:use_java_context] if @resource[:use_java_context] != nil
    to_add["xa-datasource-properties"] = {}
    to_add["xa-datasource-properties"]["URL"] = {}
    to_add["xa-datasource-properties"]["URL"]["value"] = @resource[:connection_url]
    to_add["xa-datasource-properties"]["User"] = {}
    to_add["xa-datasource-properties"]["User"]["value"] = @resource[:user_name]
    to_add["xa-datasource-properties"]["Password"] = {}
    to_add["xa-datasource-properties"]["Password"]["value"] = @resource[:password]

    return to_add
  end

  def jdbc_driver_exists?(driver)
    path = "/subsystem=datasources/jdbc-driver=#{driver}"
    operation = "read-resource"
    begin
      PuppetX::Jboss.exec_command($engine_path, $nic, path, operation)
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def jndi_name
    return $current_attrs["jndi-name"]
  end

  def jndi_name=(new_value)
    $attrs_to_write["jndi-name"] = new_value
  end

  def driver_name
    return $current_attrs["driver-name"]
  end

  def driver_name=(new_value)
    fail("A 'JDBC Driver' called '#{new_value}' is necessary for the create operation to succeed.") if jdbc_driver_exists?(new_value) == false
    $attrs_to_write["driver-name"] = new_value
  end

  def connection_url
    return :nil if $current_attrs["xa-datasource-properties"] == :nil
    return :nil if $current_attrs["xa-datasource-properties"]["URL"] == :nil
    return $current_attrs["xa-datasource-properties"]["URL"]["value"]
  end

  def connection_url=(new_value)
    $attrs_to_add["xa-datasource-properties"] = {} if $attrs_to_add["xa-datasource-properties"] == nil
    $attrs_to_add["xa-datasource-properties"]["URL"] = {} if $attrs_to_add["xa-datasource-properties"]["URL"] == nil
    $attrs_to_add["xa-datasource-properties"]["URL"]["value"] = new_value
  end

  def user_name
    return :nil if $current_attrs["xa-datasource-properties"] == :nil
    return :nil if $current_attrs["xa-datasource-properties"]["User"] == :nil
    return $current_attrs["xa-datasource-properties"]["User"]["value"]
  end

  def user_name=(new_value)
    $attrs_to_add["xa-datasource-properties"] = {} if $attrs_to_add["xa-datasource-properties"] == nil
    $attrs_to_add["xa-datasource-properties"]["User"] = {} if $attrs_to_add["xa-datasource-properties"]["User"] == nil
    $attrs_to_add["xa-datasource-properties"]["User"]["value"] = new_value
  end

  def min_pool_size
    return $current_attrs["min-pool-size"]
  end

  def min_pool_size=(new_value)
    $attrs_to_write["min-pool-size"] = new_value
  end

  def max_pool_size
    return $current_attrs["max-pool-size"]
  end

  def max_pool_size=(new_value)
    $attrs_to_write["max-pool-size"] = new_value
  end

  def pool_prefill
    return $current_attrs["pool-prefill"]
  end

  def pool_prefill=(new_value)
    $attrs_to_write["pool-prefill"] = new_value
  end

  def pool_use_strict_min
    return $current_attrs["pool-use-strict-min"]
  end

  def pool_use_strict_min=(new_value)
    $attrs_to_write["pool-use-strict-min"] = new_value
  end

  def idle_timeout_minutes
    return $current_attrs["idle-timeout-minutes"]
  end

  def idle_timeout_minutes=(new_value)
    $attrs_to_write["idle-timeout-minutes"] = new_value
  end

  def query_timeout
    return $current_attrs["query-timeout"]
  end

  def query_timeout=(new_value)
    $attrs_to_write["query-timeout"] = new_value
  end

  def prepared_statements_cache_size
    return $current_attrs["prepared-statements-cache-size"]
  end

  def prepared_statements_cache_size=(new_value)
    $attrs_to_write["prepared-statements-cache-size"] = new_value
  end

  def share_prepared_statements
    return $current_attrs["share-prepared-statements"]
  end

  def share_prepared_statements=(new_value)
    $attrs_to_write["share-prepared-statements"] = new_value
  end

  def background_validation
    return $current_attrs["background-validation"]
  end

  def background_validation=(new_value)
    $attrs_to_write["background-validation"] = new_value
  end

  def use_java_context
    return $current_attrs["use-java-context"]
  end

  def use_java_context=(new_value)
    $attrs_to_write["use-java-context"] = new_value
  end

  def valid_connection_checker_class_name
    return $current_attrs["valid-connection-checker-class-name"]
  end

  def valid_connection_checker_class_name=(new_value)
    $attrs_to_write["valid-connection-checker-class-name"] = new_value
  end

  def no_tx_separate_pool
    return $current_attrs["no-tx-separate-pool"]
  end

  def no_tx_separate_pool=(new_value)
    $attrs_to_write["no-tx-separate-pool"] = new_value
  end

end
