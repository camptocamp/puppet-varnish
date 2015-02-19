class varnish::config {
  case $::osfamily {
    'Debian': {
      if $::operatingsystemmajrelease =~ /sid/ or versioncmp($::operatingsystemmajrelease, '8') >= 0 {
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
          notify  => Exec['systemctl-daemon-reload'],
        }

        varnish_param {
          'listen_address': value => $::varnish::varnish_listen_address;
          'listen_port':    value => $::varnish::varnish_listen_port;
        }
      } else {
        fail "${::operatingsystem}${::operatingsystemmajrelease} not yet supported"
      }
    }
    'RedHat': {
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
