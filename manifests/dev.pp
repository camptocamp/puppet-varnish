class varnish::dev {

  package { "varnish-dev":
    ensure => present,
    name => $operatingsystem ? {
      Debian => "libvarnish-dev",
      RedHat => "varnish-libs-devel",
    },
  }

  # libvarnish-dev is broken on debian-squeeze. This is the workaround.
  # Details: http://mailman.verplant.org/pipermail/collectd/2010-June/003877.html
  if ($lsbdistcodename == "squeeze" and $varnish_version == "2.1.3") {

    File {
      ensure => link,
      notify => Exec["refresh ldconfig"],
      require => Package["varnish-dev"],
    }

    file {
      "/usr/lib/libvarnish.so":
        target => "/usr/lib/libvarnish.so.1.0.0";
      "/usr/lib/libvarnishapi.so":
        target => "/usr/lib/libvarnishapi.so.1.0.0";
      "/usr/lib/libvarnishcompat.so":
        target => "/usr/lib/libvarnishcompat.so.1.0.0";
    }

    file { "/usr/lib/pkgconfig/varnishapi.pc":
      ensure  => present,
      source  => "puppet:///modules/varnish/usr/lib/pkgconfig/varnishapi.pc",
    }

    exec { "refresh ldconfig":
      refreshonly => true,
      command     => "ldconfig",
    }

  }

}
