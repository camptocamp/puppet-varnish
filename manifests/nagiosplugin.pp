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

  include varnish::dev

  if ( ! $nagios_plugin_dir ) {
    $nagios_plugin_dir = "/usr/lib/nagios/plugins/contrib"
  }

  $baseurl = "https://www.varnish-cache.org/svn/"

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
      $rev = "5773"
      $branch = "branches/2.0"
      $buildopt = ""
    }
    default: {
      $rev = "HEAD"
      $branch = "trunk"
      $buildopt = ""
    }
  }

  $workdir = "/usr/src/check_varnish-${varnish_version}-${rev}"

  vcsrepo { $workdir:
    provider => "svn",
    source   => "${baseurl}${branch}/varnish-tools/nagios/",
    revision => $rev,
  }

  file { "${workdir}/build-plugin.sh":
    mode    => 0755,
    content => "#!/bin/sh
cd \$(dirname \$0) && ./autogen.sh && ./configure && make ${buildopt}
",
    require => [
      Package["gcc"],
      Package["libtool"],
      Class["varnish::dev"],
      Vcsrepo[$workdir],
    ],
  }

  exec { "build check_varnish":
    command   => "${workdir}/build-plugin.sh",
    creates   => "${workdir}/check_varnish",
    require   => File["${workdir}/build-plugin.sh"],
    #logoutput => true,
  }

  file { "${nagios_plugin_dir}/check_varnish":
    ensure  => present,
    mode    => 0755,
    owner   => "root",
    source  => "file://${workdir}/check_varnish",
    require => Exec["build check_varnish"],
  }
}
