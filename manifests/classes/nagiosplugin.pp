/*

== Class: varnish::nagiosplugin

Downloads the sources of the official nagios plugin for varnish, builds it, and
installs it to $nagios_plugin_dir.

Attributes:
- *nagios_plugin_dir*: directory where you want the built plugin to be
  installed. Defaults to "/usr/lib/nagios/plugins/contrib".

Requires:
- Package["gcc"]
- Package["libtool"]
or
- Class["buildenv::c"]

*/
class varnish::nagiosplugin {

  if ( ! $nagios_plugin_dir ) {
    $nagios_plugin_dir = "/usr/lib/nagios/plugins/contrib"
  }

  $rev = "3305"
  $branch = "2.0"
  $baseurl = "http://varnish-cache.org/svn/branches/"

  package { "varnish-dev":
    ensure => present,
    name => $operatingsystem ? {
      Debian => "libvarnish-dev",
      RedHat => "varnish-libs-devel",
    },
  }

  exec { "checkout check_varnish from svn":
    command => "svn checkout -r${rev} ${baseurl}/${branch}/varnish-tools/nagios/ /usr/src/check_varnish-${rev}",
    creates => "/usr/src/check_varnish-${rev}",
  }

  exec { "build check_varnish":
    command => "./autogen.sh && ./configure && make",
    cwd     => "/usr/src/check_varnish-${rev}",
    creates => "/usr/src/check_varnish-${rev}/check_varnish",
    require => [
      Package["gcc"],
      Package["libtool"],
      Package["varnish-dev"],
      Exec["checkout check_varnish from svn"],
    ],
  }

  file { "${nagios_plugin_dir}/check_varnish":
    ensure  => present,
    mode    => 0755,
    owner   => "root",
    source  => "file:///usr/src/check_varnish-${rev}/check_varnish",
    require => Exec["build check_varnish"],
  }
}
