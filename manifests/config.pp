class varnish::config {
  case $::osfamily {
    'Debian': {
      if $::operatingsystemmajrelease =~ /sid/ or $::operatingsystemmajrelease >= 8 {
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
      } else {
        fail "${::operatingsystem}${::operatingsystemmajrelease} not yet supported"
      }
    }
    'RedHat': {
      $params_file = $::operatingsystemmajrelease ? {
        '6' => '/etc/sysconfig/varnish',
        '7' => '/etc/varnish/varnish.params',
      }
      Shellvar {
        target   => $params_file,
      }
      if $::varnish::admin_listen_address != undef {
        shellvar { 'VARNISH_ADMIN_LISTEN_ADDRESS':
          value => $::varnish::admin_listen_address,
        }
      }
      if $::varnish::admin_listen_port != undef {
        shellvar { 'VARNISH_ADMIN_LISTEN_PORT':
          value => $::varnish::admin_listen_port,
        }
      }
      if $::varnish::group != undef {
        shellvar { 'VARNISH_GROUP':
          value => $::varnish::group,
        }
      }
      if $::varnish::listen_address != undef {
        shellvar { 'VARNISH_LISTEN_ADDRESS':
          value => $::varnish::listen_address,
        }
      }
      if $::varnish::listen_port != undef {
        shellvar { 'VARNISH_LISTEN_PORT':
          value => $::varnish::listen_port,
        }
      }
      if $::varnish::secret_file != undef {
        shellvar { 'VARNISH_SECRET_FILE':
          value => $::varnish::secret_file,
        }
      }
      if $::varnish::storage != undef {
        shellvar { 'VARNISH_STORAGE':
          value => $::varnish::storage,
        }
      }
      if $::varnish::ttl != undef {
        shellvar { 'VARNISH_TTL':
          value => $::varnish::ttl,
        }
      }
      if $::varnish::user != undef {
        shellvar { 'VARNISH_USER':
          value => $::varnish::user,
        }
      }
      if $::varnish::vcl_conf != undef {
        shellvar { 'VARNISH_VCL_CONF':
          value => $::varnish::vcl_conf,
        }
      }
    }
    default: {
      fail "Unsupported Operating System family: ${::osfamily}"
    }
  }

  file { $::varnish::vcl_conf:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $::varnish::vcl_content,
  }
  ~>
  exec { 'varnish_reload_vcl':
    command     => 'service varnish reload',
    path        => $::path,
    refreshonly => true,
  }
}
