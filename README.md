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

Notes
-----

* Version 1.x supported only multi-instances configuration. As we never use this use case, we decided to switch to a single instance configuration.
* Version 1.99.x adds support for single instance configuration but still defaults to multi-instances configuration.
* Version 2.x will default to single instance configuration and deprecate multi-instances configuration.
* Version 3.x will remove multi-instances configuration support.
