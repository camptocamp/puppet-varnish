Varnish
=======

[![Puppet Forge](http://img.shields.io/puppetforge/v/camptocamp/varnish.svg)](https://forge.puppetlabs.com/camptocamp/varnish)
[![Build Status](https://travis-ci.org/camptocamp/puppet-varnish.png?branch=master)](https://travis-ci.org/camptocamp/puppet-varnish)

Overview
--------

This puppet module installs and configures varnish.

Usage
-----

```puppet
class { 'varnish':
  multi_instances => false,
}
```

Configure environment params:

```puppet
varnish::config_entry { 'VARNISH_VCL_CONF':
  ensure => 'present',
  value  => '/foo/bar.vcl',
}
```

Reference
---------

Classes:

* [varnish](#class-varnish)

Resources:

* [varnish::config_entry](#resource-varnishconfig_entry)

###Class: varnish

####`enable`
Should the service be enabled during boot time?

####`config_entries`
A hash of config entries to set.

####`multi_instances`
Wether or not use the multi-instance configuration (see [notes](#notes)).

####`params_file`
Path of the params file.

####`start`
Should the service be started by Puppet?

###Resource: varnish::config_entry

####`ensure`
Should the config entry be `present` or `absent`?

####`key`
The key to change (defaults to `$name`).

####`value`
The value.

Notes
-----

* Version 1.x supported only multi-instances configuration. As we never use this use case, we decided to switch to a single instance configuration.
* Version 1.99.x adds support for single instance configuration but still defaults to multi-instances configuration.
* Version 2.x will default to single instance configuration and deprecate multi-instances configuration.
* Version 3.x will remove multi-instances configuration support.
