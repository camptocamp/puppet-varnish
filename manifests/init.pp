/*

== Class: varnish

Installs the varnish http accelerator and starts the varnishd and varnishlog
services.

*/
class varnish {

  package { "varnish": ensure => present }

  service { "varnish":
    enable  => true,
    ensure  => "running",
    pattern => "sbin/varnishd",
    require => Package["varnish"],
  }

  service { "varnishlog":
    enable  => true,
    ensure  => "running",
    pattern => "bin/varnishlog",
    require => Package["varnish"],
  }

}
