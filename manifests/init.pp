/*

== Class: varnish

Installs the varnish http accelerator and stops the varnishd and varnishlog
services, because they are handled separately by varnish::instance.

*/
class varnish {

  yumrepo { "varnish-cache"
    name     => 'Varnish 3.0 for Enterprise Linux 5 - $basearch',
    baseurl  => 'http://repo.varnish-cache.org/redhat/varnish-3.0/el5/$basearch',
    enabled  => "1",
    gpgcheck => "0"
  }

  package { "varnish":
    ensure => latest,
    require => Yumrepo["varnish-cache"]
  }

  service { "varnish":
    enable  => false,
    ensure  => "stopped",
    pattern => "/var/run/varnishd.pid",
    require => Package["varnish"],
  }

  service { "varnishlog":
    enable  => false,
    ensure  => "stopped",
    pattern => "/var/run/varnishlog.pid",
    require => Package["varnish"],
  }

  file { "/usr/local/sbin/vcl-reload.sh":
    ensure => present,
    owner  => "root",
    group  => "root",
    mode   => "0755",
    source => "puppet:///modules/varnish/usr/local/sbin/vcl-reload.sh",
  }

  case $operatingsystem { 
    RedHat,CentOS: {
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
}
