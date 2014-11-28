class varnish::config {
  case $::osfamily {
    'Debian': {
      include ::systemd

      file { '/etc/systemd/system/varnish.service':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => '/lib/systemd/system/varnish.service',
        replace => false,
      }

      Augeas {
        lens   => 'Systemd.lns',
        incl   => '/etc/systemd/system/varnish.service',
        notify  => Exec['systemctl-daemon-reload'],
        require => File['/etc/systemd/system/varnish.service'],
      }

      if $::varnish::varnish_listen_address != undef or $::varnish::varnish_listen_port != undef {
        augeas { 'address':
          changes => "set Service/ExecStart/arguments/*[preceding-sibling::*[1][self::*[. = '-a']]] '${::varnish::varnish_listen_address}:${::varnish::varnish_listen_port}'",
        }
      }
    }
    'RedHat': {
      Shellvar {
        target   => $::varnish::params_file,
      }
      if $::varnish::varnish_listen_address != undef {
        shellvar { 'VARNISH_LISTEN_ADDRESS':
          value => $::varnish::varnish_listen_address,
        }
      }
      if $::varnish::varnish_listen_port != undef {
        shellvar { 'VARNISH_LISTEN_PORT':
          value => $::varnish::varnish_listen_port,
        }
      }
    }
    default: {
      fail "Unsupported Operating System family: ${::osfamily}"
    }
  }
}
