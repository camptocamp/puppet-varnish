/*

== Class: varnish::nagiosplugin

Downloads the sources of the official nagios plugin for varnish, builds it, and
installs it to $plugin_dir.

Attributes:
- *nagios_plugin_dir*: directory where you want the built plugin to be
  installed. Defaults to '/usr/lib/nagios/plugins/contrib'.

Requires:
- vcsrepo module from http://github.com/reductivelabs/puppet-vcsrepo

- Package['gcc']
- Package['libtool']
or
- Class['buildenv::c']

*/
class varnish::nagiosplugin (
  $plugin_dir = '/usr/lib/nagios/plugins/contrib',
) {

  include ::varnish::dev

  $baseurl = 'https://github.com/varnish/varnish-nagios'

  case $::varnish_version {
    '2.1.1', '2.1.2': {
      # http://www.varnish-cache.org/trac/ticket/710
      $revision = '70e4ded1221846d4149dd743e2ac634946c313ad'
      $branch   = 'master'
      $buildopt = ''
    }
    '2.1.3': {
      $revision = '70e4ded1221846d4149dd743e2ac634946c313ad'
      $branch   = 'master'
      $buildopt = "VARNISHAPI_LIBS='-lvarnishapi -lvarnish -lvarnishcompat'"
    }
    /^2\.0\./: {
      $revision = 'a64abfb7e70fd1f6b53ff64f9ddeafb7209c0b23'
      $branch   = 'master'
      $buildopt = ''
    }
    default: {
      $revision = 'HEAD'
      $branch   = 'master'
      $buildopt = ''
    }
  }

  $workdir = "/usr/src/check_varnish-${::varnish_version}-${revision}"

  vcsrepo { $workdir:
    provider => 'git',
    source   => "${baseurl}/",
    revision => $revision,
  }

  file { "${workdir}/build-plugin.sh":
    mode    => '0755',
    content => "#!/bin/sh
cd \$(dirname \$0) && ./autogen.sh && ./configure && make ${buildopt}
",
    require => [
      Package['gcc'],
      Package['libtool'],
      Class['varnish::dev'],
      Vcsrepo[$workdir],
    ],
  }

  exec { 'build check_varnish':
    command   => "${workdir}/build-plugin.sh",
    creates   => "${workdir}/check_varnish",
    require   => File["${workdir}/build-plugin.sh"],
    #logoutput => true,
  }

  file { "${plugin_dir}/check_varnish":
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    source  => "file://${workdir}/check_varnish",
    require => Exec['build check_varnish'],
  }
}
