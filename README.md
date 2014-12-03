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

To manage varnishlog:
```puppet
class { 'varnish::log': }
```

To manage varnishncsa:
```puppet
class { 'varnish::ncsa': }
```

Reference
---------

Classes:

* [varnish](#class-varnish)
* [varnish::log](#class-varnishlog)
* [varnish::ncsa](#class-varnishncsa)

Resources:

* [varnish_param](#resource-varnish_param)

###Class: varnish

####`enable`
Should the service be enabled during boot time?

####`multi_instances`
Wether or not use the multi-instance configuration (see [notes](#notes)).

####`start`
Should the service be started by Puppet?

####`admin_listen_address`
Admin interface listen address.

####`admin_listen_port`
Admin interface listen port.

####`group`
Group for the varnishd worker processes

####`listen_address`
Default address to bind to.

####`listen_port`
Default port to bind to.

####`secret_file`
Shared secret file for admin interface.

####`storage`
Backend storage specification.

####`ttl`
Default TTL used when the backend does not specify one.

####`user`
User for the varnishd worker processes.

####`vcl_conf`
Main configuration file.

###Class: varnish::log

###Class: varnish::ncsa

###Resource: varnish_param

This resource is a native type and a series of Augeas-based providers.

It allows to modify varnish parameters where OSes put them by default:

* in /etc/default/varnish for Debian wheezy (as a list of parameters)
* in /etc/systemd/services/varnish.service for Debian jessie (as a list of parameters)
* in /etc/sysconfig/varnish for RedHat 6 (as standalone variables)
* in /etc/varnish/varnish.params for RedHat 7 (as standalone variables)

Example:

```puppet
varnish_param { 'listen_address':
  ensure => present,
  value   => 'localhost',
}
```


Notes
-----

* Version 1.x supported only multi-instances configuration. As we never use this use case, we decided to switch to a single instance configuration.
* Version 1.99.x adds support for single instance configuration but still defaults to multi-instances configuration.
* Version 2.x will default to single instance configuration and deprecate multi-instances configuration.
* Version 3.x will remove multi-instances configuration support.
