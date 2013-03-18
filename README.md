# Manage the JBoss Command Line Management tool with Puppet in Standalone Server mode

This module provides Customs Puppet Providers to handle the JBoss AS7.x/EAP6.x
CLI in standalone server mode only.

## Authors
* Gaël Chamoulaud <gael at redhat dot com>
* Akram Ben Aissi <akram at redhat dot com>

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

jdbc_driver { 'h2_driver':
  ensure                          => present,
  driver_name                     => 'h2',
  engine_path                     => '/opt/jboss-6.0.0',
  nic                             => 'eth0',
  driver_module_name              => 'com.h2database.h2',
  driver_class_name               => 'org.h2.Driver',
  driver_xa_datasource_class_name => 'org.h2.jdbcx.JdbcDataSource',
}

jdbc_driver { 'oracle_driver':
  ensure                          => present,
  driver_name                     => 'oracle-ojdbc6',
  engine_path                     => '/opt/jboss-6.0.0',
  nic                             => 'eth0',
  driver_module_name              => 'com.oracle.ojdbc.ojdbc6',
  driver_class_name               => 'oracle.jdbc.OracleDriver',
  driver_xa_datasource_class_name => 'oracle.jdbc.xa.client.OracleXADataSource',
}

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


## Issues

Please file any issues or suggestions on [on GitHub](https://github.com/RedHatEMEA/puppet-jboss_cli/issues)
