# Manage the JBoss Command Line Management tool with Puppet in Standalone Server mode

This module provides Customs Puppet Providers to handle the JBoss AS7.x/EAP6.x
CLI in standalone server mode only.

## Authors
* Gaël Chamoulaud (gael at redhat dot com)
* Akram Ben Aissi (akram at redhat dot com)

## Required Gems

 * `json`
 * `multi-json`
 * `Jboss EAP` >= 6.0.0 or `Jboss AS` >= 7.1.2

## Features

## Limitations

## Types and providers

The module adds the following new types:

* `jdbc_driver` for managing JDBC Driver
* `datasource` for managing non-xa Datasource
* `db2_xa_datasource` for managing DB2 XA Datasource
* `h2_xa_datasource` for managing H2 XA Datasource
* `oracle_xa_datasource` for managing Oracle XA Datasource
* `mssql_xa_datasource` for managing MSSQL XA Datasource
* `system_property` for managing the System Properties
* `ldap_security_domain` for managing LDAP Security Domain
* `ldap_security_realm` for managing LDAP Security Realm
* `ssl_connector_extension`
* `web_connector` for managing WEB Connector
* `vault` For managing VAULT

## Installing

In your puppet modules directory:

    git clone https://github.com/RedHatEMEA/puppet-jboss_cli.git

Ensure the module is present in your puppetmaster's own environment (it doesn't
have to use it) and that the master has pluginsync enabled.  Run the agent on
the puppetmaster to cause the custom types to be synced to its local libdir
(`puppet master --configprint libdir`) and then restart the puppetmaster so it
loads them.

## Managing your System Properties

### Parameters

- **engine_path**: The path of the JBoss Engine
- **ensure**: The basic property that the resource should be in. Valid values are `present`, `absent`.
- **nic**: The Network Interface attached to the instance.
- **sp_name**: The System Property name
- **value**: The system property value

### Examples

<pre>
system_property { 'environment':
  ensure       => present,
  engine_path  => '/opt/jboss-eap-6.0.0',
  nic          => 'eth0',
  sp_name      => 'environment',
  value        => 'DEV',
}
</pre>

## Managing your JDBC Driver

### Parameters

- **ensure**: Valid values are `present`, `absent`.
- **driver_name**: The JDBC Driver name.
- **engine_path**: The JBoss Engine Path.
- **nic**: The Network Interface attached to the instance.
- **driver_class_name**: The JDBC Driver Class name.
- **driver_module_name**: The JDBC Driver Module name.
- **driver_xa_datasource_class_name**: The JDBC Driver XA Datasource Class name.

### Examples

<pre>
jdbc_driver { 'db2_driver':
  ensure                          => present,
  driver_name                     => 'db2',
  engine_path                     => '/opt/jboss-6.0.0',
  nic                             => 'eth0',
  driver_module_name              => 'com.ibm.db2jcc',
  driver_class_name               => 'com.ibm.db2.jcc.DB2Driver',
  driver_xa_datasource_class_name => 'com.ibm.db2.jcc.DB2XADataSource',
}
</pre>

<pre>
jdbc_driver { 'h2_driver':
  ensure                          => present,
  driver_name                     => 'h2',
  engine_path                     => '/opt/jboss-6.0.0',
  nic                             => 'eth0',
  driver_module_name              => 'com.h2database.h2',
  driver_class_name               => 'org.h2.Driver',
  driver_xa_datasource_class_name => 'org.h2.jdbcx.JdbcDataSource',
}
</pre>

<pre>
jdbc_driver { 'oracle_driver':
  ensure                          => present,
  driver_name                     => 'oracle-ojdbc6',
  engine_path                     => '/opt/jboss-6.0.0',
  nic                             => 'eth0',
  driver_module_name              => 'com.oracle.ojdbc.ojdbc6',
  driver_class_name               => 'oracle.jdbc.OracleDriver',
  driver_xa_datasource_class_name => 'oracle.jdbc.xa.client.OracleXADataSource',
}
</pre>

<pre>
jdbc_driver { 'mssql_driver':
  ensure                          => present,
  driver_name                     => 'sqlserver',
  engine_path                     => '/opt/jboss-6.0.0',
  nic                             => 'eth0',
  driver_module_name              => 'com.microsoft.mssql',
  driver_class_name               => 'com.microsoft.sqlserver.jdbc.SQLServerDriver',
  driver_xa_datasource_class_name => 'com.microsoft.sqlserver.jdbc.SQLServerXADataSource',
}
</pre>

## Managing your Non-XA Datasources

### Parameters

- **ensure**: The basic property that the resource should be in.  Valid values are `present`, `absent`.
- **ds_name**: The datasource name.
- **engine_path**: The JBoss Engine path.
- **nic**: The Network Interface attached to the instance.
- **jndi_name**: Specifies the JNDI name for the datasource.
- **connection_url**: The JDBC driver connection URL.
- **driver_name**: An unique name for the JDBC driver specified in the drivers section.
- **idle_timeout_minutes**: The idle-timeout-minutes elements indicates the maximum time in minutes a connection may be idle before being closed. Must be an Integer.
- **min_pool_size**: Minimum number of connections in a pool
- **max_pool_size**: Maximum number of connections in a pool
- **user_name**: The datasource username.
- **password**: The datasource password. The password is set a param and not a property, because we only want to set it on creation. Then it can be changed by other mechanism.
- **pool_prefill**: Whether to attempt to prefill the connection pool. The default is true. Valid values are `true`, `false`.
- **pool_use_strict_min**: Define if the min-pool-size should be considered a strictly. The default is true. Valid values are `true`, `false`.
- **prepared_statements_cache_size**: The number of prepared statements per connection in an LRU cache. Must be an Integer.
- **query_timeout**: Any configured query timeout in seconds. Must be in Integer.
- **share_prepared_statements**: Whether to share prepare statements, i.e. whether asking for same statement twice without closing uses the same underlying prepared statement. The default is true.  Valid values are `true`, `false`.
- **use_java_context**: If java context (java:jboss/ our java:) must be appended to datasource JNDI name. The default is true.  Valid values are `true`, `false`.
- **valid_connection_checker_class_name**: Valid Connection Checker Class Name.
- **background_validation**: Background Validation. The default is true. Valid values are `true`, `false`.

### Examples

<pre>
datasource { 'Oracle-DS':
  ensure                         => present,
  ds_name                        => 'protoOracleDatasource',
  engine_path                    => '/opt/jboss-eap-6.0.0',
  nic                            => 'eth0',
  jndi_name                      => 'java:jboss/jdbc/protoOracleDatasource',
  connection_url                 => 'jdbc:oracle:thin:@db.example.com:1521:JBPAJ',
  driver_name                    => 'oracle-ojdbc6',
  min_pool_size                  => '15',
  max_pool_size                  => '350',
  user_name                      => 'jboss',
  password                       => 'jboss',
  idle_timeout_minutes           => '15',
  query_timeout                  => '350',
  prepared_statements_cache_size => '150',
  use_java_context               => true,
}
</pre>

## Managing your XA Oracle Datasource

### Parameters

- **background_validation**: Background Validation. The default is true.  Valid values are `true`, `false`.
- **driver_name**: An unique name for the JDBC driver specified in the drivers section.
- **ds_name**: The datasource name.
- **engine_path**: The JBoss Engine path.
- **ensure**: The basic property that the resource should be in.  Valid values are `present`, `absent`.
- **idle_timeout_minutes**: The idle-timeout-minutes elements indicates the maximum time in minutes a connection may be idle before being closed. Must be an Integer.
- **jndi_name**: Specifies the JNDI name for the datasource.
- **max_pool_size**: Maximum number of connections in a pool
- **min_pool_size**: Minimum number of connections in a pool
- **nic**: The Network Interface attached to the instance.
- **no_tx_separate_pool**: Oracle does not like XA connections getting used both inside and outside a JTA transaction. To workaround the problem you can create separate sub-pools for the different contexts.  Valid values are `true`, `false`.
- **password**: The datasource password. The password is set a param and not a property, because we only want to set it on creation. Then it can be changed by other mechanism.
- **query_timeout**: Any configured query timeout in seconds. Must be in Integer.
- **url**: The JDBC driver connection URL.
- **user**: The datasource username.
- **valid_connection_checker_class_name**: Valid Connection Checker Class Name  Valid values are `org.jboss.jca.adapters.jdbc.extensions.oracle.OracleValidConnectionChecker`.


### Examples

<pre>
oracle_xa_datasource { 'Oracle_XA_DS':
  ensure               => absent,
  ds_name              => 'myXADSOracle',
  engine_path          => '/opt/jboss-eap-6.0.0',
  nic                   => 'eth0',
  jndi_name            => 'java:/myXADSOracle',
  url                  => 'jdbc:oracle:thin:@db.example.com:1521:DSIBLE',
  driver_name          => 'oracle-ojdbc6',
  min_pool_size        => '5',
  max_pool_size        => '30',
  idle_timeout_minutes => '0',
  query_timeout        => '600',
  user                 => 'mydsuser',
  password             => 'mydspasswd',
}
</pre>

## Managing your XA DB2 Datasource

## Parameters

- **ensure**: The basic property that the resource should be in. Valid values are `present`, `absent`.
- **ds_name**: The datasource name.
- **engine_path**: The JBoss Engine path
- **nic**: The Network Interface attached to the instance.
- **driver_name**: An unique name for the JDBC driver specified in the drivers section.
- **jndi_name**: Specifies the JNDI name for the datasource.
- **server_name**: The database server name.
- **database_name**: The database name.
- **driver_type**: The Driver type.  Valid values are `1`, `2`, `3`, `4`.
- **idle_timeout_minutes**: The idle-timeout-minutes elements indicates the maximum time in minutes a connection may be idle before being closed. Must be an Integer.
- **max_pool_size**: Maximum number of connections in a pool
- **min_pool_size**: Minimum number of connections in a pool
- **no_tx_separate_pool**: Oracle does not like XA connections getting used both inside and outside a JTA transaction. To workaround the problem you can create separate sub-pools for the different contexts.  Valid values are `true`, `false`.
- **user**: The datasource username.
- **password**: The datasource password. The password is set a param and not a property, because we only want to set it on creation. Then it can be changed by other mechanism.
- **query_timeout**: Any configured query timeout in seconds. Must be in Integer.
- **background_validation**: Background Validation. The default is true.  Valid values are `true`, `false`.
- **valid_connection_checker_class_name**: Valid Connection Checker Class Name Valid values are `org.jboss.jca.adapters.jdbc.extensions.db2.DB2ValidConnectionChecker`.

## Examples

<pre>
db2_xa_datasource { 'DB2_XA_DS':
  ensure               => present,
  ds_name              => 'myDB2XADS',
  engine_path          => '/opt/jboss-eap-6.0.0',
  nic                  => 'eth0',
  jndi_name            => 'java:jboss/myDB2XADS',
  driver_name          => 'db2',
  server_name          => 'db.example.com',
  database_name        => 'MyDB',
  driver_type          => '4',
  user                 => 'user',
  password             => 'pwd',
  min_pool_size        => '2',
  max_pool_size        => '100',
  idle_timeout_minutes => '0',
  query_timeout        => '600',
}
</pre>

## Issues

Please file any issues or suggestions on [on GitHub](https://github.com/RedHatEMEA/puppet-jboss_cli/issues)
