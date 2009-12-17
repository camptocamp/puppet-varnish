/*

== Class: varnish

Installs the varnish http accelerator and starts the varnishd and varnishlog
services.

*/
class varnish {

  package { "varnish": ensure => present }

  service { "varnish":
    enable  => false,
    ensure  => "stopped",
    pattern => "/var/run/varnishd.pid",
    require => Package["varnish"],
  }

  service { "varnishlog":
    enable  => true,
    ensure  => "running",
    pattern => "bin/varnishlog",
    require => Package["varnish"],
  }

  file { "/usr/local/sbin/vcl-reload.sh":
    ensure => present,
    owner  => "root",
    group  => "root",
    mode   => "0755",
    source => "puppet:///varnish/usr/local/sbin/vcl-reload.sh",
  }

}
