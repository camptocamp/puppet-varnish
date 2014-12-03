#
# == Class: varnish
#
# Installs the varnish http accelerator and stops the varnishd and varnishlog
# services, because they are handled separately by varnish::instance.
#
class varnish(
  $multi_instances = true,

  $admin_listen_address = undef,
  $admin_listen_port    = undef,
  $group                = undef,
  $listen_address       = undef,
  $listen_port          = undef,
  $secret_file          = undef,
  $storage              = undef,
  $ttl                  = undef,
  $user                 = undef,
  $vcl_conf             = undef,
) {

  validate_bool($multi_instances)

  if ($multi_instances) {
    class { 'varnish::install': }

    service { 'varnish':
      ensure    => 'stopped',
      enable    => false,
      pattern   => '/var/run/varnishd.pid',
      hasstatus => false,
      require   => Package['varnish'],
    }

    service { 'varnishlog':
      ensure    => 'stopped',
      enable    => false,
      pattern   => '/var/run/varnishlog.pid',
      hasstatus => false,
      require   => Package['varnish'],
    }

    file { '/usr/local/sbin/vcl-reload.sh':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/varnish/usr/local/sbin/vcl-reload.sh',
    }

    case $::operatingsystem {
      RedHat,CentOS,Amazon: {
        # By default RPM package fail to send HUP to varnishlog process, and don't
        # bother compressing rotated files. This fixes these issues, waiting for
        # this bug to get corrected upstream:
        # https://bugzilla.redhat.com/show_bug.cgi?id=554745
        augeas { 'logrotate config for varnishlog and varnishncsa':
          incl    => '/etc/logrotate.d/varnish',
          lens    => 'Logrotate.lns',
          changes => [
            'set /rule/schedule daily',
            'set /rule/rotate 7',
            'set /rule/compress compress',
            'set /rule/delaycompress delaycompress',
            'set /rule/postrotate "for service in varnishlog varnishncsa; do if /usr/bin/pgrep -P 1 $service >/dev/null; then /usr/bin/pkill -HUP $service 2>/dev/null; fi; done"',
          ],
          require => Package['varnish'],
        }
      }

      default: {}
    }
  } else {
    # New clean implementation
    class { 'varnish::install': } ->
    class { 'varnish::config': } ~>
    class { 'varnish::service': } ->
    Class['varnish']
  }
}
