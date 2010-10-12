/*

== Class: varnish::nagiosplugin

Downloads the sources of the official nagios plugin for varnish, builds it, and
installs it to $nagios_plugin_dir.

Attributes:
- *nagios_plugin_dir*: directory where you want the built plugin to be
  installed. Defaults to "/usr/lib/nagios/plugins/contrib".

Requires:
- vcsrepo module from http://github.com/reductivelabs/puppet-vcsrepo

- Package["gcc"]
- Package["libtool"]
or
- Class["buildenv::c"]

*/
class varnish::nagiosplugin {

  if ( ! $nagios_plugin_dir ) {
    $nagios_plugin_dir = "/usr/lib/nagios/plugins/contrib"
  }

  $baseurl = "http://www.varnish-cache.org/svn/"

  case $varnish_version {
    "2.1.1", "2.1.2": {
      # http://www.varnish-cache.org/trac/ticket/710
      $rev = "4009"
      $branch = "tags/varnish-${varnish_version}"
      $buildopt = ""
    }
    "2.1.3": {
      $rev = "4009"
      $branch = "branches/2.1"
      $buildopt = "VARNISHAPI_LIBS='-lvarnishapi -lvarnish -lvarnishcompat'"
    }
    /^2\.0\./: {
      $rev = "3305"
      $branch = "tags/varnish-${varnish_version}"
      $buildopt = ""
    }
    default: {
      $rev = "HEAD"
      $branch = "trunk"
      $buildopt = ""
    }
  }

  package { "varnish-dev":
    ensure => present,
    name => $operatingsystem ? {
      Debian => "libvarnish-dev",
      RedHat => "varnish-libs-devel",
    },
  }

  vcsrepo { "/usr/src/check_varnish-${varnish_version}-${rev}":
    provider => "svn",
    source   => "${baseurl}/${branch}/varnish-tools/nagios/",
    revision => $rev,
  }

  exec { "build check_varnish":
    command => "./autogen.sh && ./configure && make ${buildopt}",
    cwd     => "/usr/src/check_varnish-${varnish_version}-${rev}",
    creates => "/usr/src/check_varnish-${varnish_version}-${rev}/check_varnish",
    require => [
      Package["gcc"],
      Package["libtool"],
      Package["varnish-dev"],
      Vcsrepo["/usr/src/check_varnish-${varnish_version}-${rev}"],
    ],
  }

  file { "${nagios_plugin_dir}/check_varnish":
    ensure  => present,
    mode    => 0755,
    owner   => "root",
    source  => "file:///usr/src/check_varnish-${varnish_version}-${rev}/check_varnish",
    require => Exec["build check_varnish"],
  }
}
