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

  if $operatingsystem =~ /RedHat|CentOS/ {

    # By default RPM package fail to send HUP to varnishlog process, and don't
    # bother compressing rotated files. This fixes these issues, waiting for
    # this bug to get corrected upstream:
    # https://bugzilla.redhat.com/show_bug.cgi?id=554745
    augeas { "logrotate config for varnishlog and varnishncsa":
      context => "/files/etc/logrotate.d/varnish/rule/",
      changes => [
        "set schedule daily",
        "set rotate 7",
        "set compress compress",
        "set delaycompress delaycompress",
        'set postrotate "for service in varnishlog varnishncsa; do if /usr/bin/pgrep -P 1 $service >/dev/null; then /usr/bin/pkill -HUP $service 2>/dev/null; fi; done"',
      ],
      require => Package["varnish"],
    }
  }

}
