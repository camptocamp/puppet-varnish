class varnish::config {
  case $::osfamily {
    'Debian': {
      if versioncmp($::operatingsystemmajrelease, '8') >= 0 {
        include ::systemd

        file { '/etc/systemd/system/varnish.service':
          ensure  => 'file',
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          source  => '/lib/systemd/system/varnish.service',
          replace => false,
        }

        Varnish_param {
          ensure  => present,
          require => File['/etc/systemd/system/varnish.service'],
          notify  => Exec['systemctl-daemon-reload'],
        }

        varnish_param {
          'listen_address':       value => $::varnish::listen_address;
          'listen_port':          value => $::varnish::listen_port;
          'admin_listen_address': value => $::varnish::admin_listen_address;
          'admin_listen_port':    value => $::varnish::admin_listen_port;
          'group':                value => $::varnish::group;
          'user':                 value => $::varnish::user;
          'secret_file':          value => $::varnish::secret_file;
          'storage':              value => $::varnish::storage;
          'ttl':                  value => $::varnish::ttl;
          'vcl_conf':             value => $::varnish::vcl_conf;
        }
      } else {
        fail "${::operatingsystem}${::operatingsystemmajrelease} not yet supported"
      }
    }
    'RedHat': {
      if $::service_provider == 'systemd' {
        file { '/usr/lib/systemd/system/varnish.service':
          ensure  => present,
          content => file('varnish/usr/lib/systemd/system/varnish.service'),
        }
      }

      Varnish_param {
        ensure  => present,
      }

      varnish_param {
        'listen_address':       value => $::varnish::listen_address;
        'listen_port':          value => $::varnish::listen_port;
        'admin_listen_address': value => $::varnish::admin_listen_address;
        'admin_listen_port':    value => $::varnish::admin_listen_port;
        'group':                value => $::varnish::group;
        'user':                 value => $::varnish::user;
        'secret_file':          value => $::varnish::secret_file;
        'storage':              value => $::varnish::storage;
        'ttl':                  value => $::varnish::ttl;
        'vcl_conf':             value => $::varnish::vcl_conf;
      }
    }
    default: {
      fail "Unsupported Operating System family: ${::osfamily}"
    }
  }
}
