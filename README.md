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
* `ssl_connector_extension`
* `web_connector`
* `vault`

## Installing

In your puppet modules directory:

    git clone https://github.com/RedHatEMEA/puppet-jboss_cli.git

Ensure the module is present in your puppetmaster's own environment (it doesn't
have to use it) and that the master has pluginsync enabled.  Run the agent on
the puppetmaster to cause the custom types to be synced to its local libdir
(`puppet master --configprint libdir`) and then restart the puppetmaster so it
loads them.

## Issues

Please file any issues or suggestions on [on GitHub](https://github.com/RedHatEMEA/puppet-jboss_cli/issues)
