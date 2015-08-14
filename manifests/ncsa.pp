class varnish::ncsa(
  $user     = undef,
  $filename = undef,
) {
  Class['varnish'] -> Class['varnish::ncsa']

  service { 'varnishncsa':
    ensure => running,
    enable => true,
  }

  file { '/etc/systemd/system/varnishncsa.service':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
  augeas_file { '/etc/systemd/system/varnishncsa.service':
    base => '/lib/systemd/system/varnishncsa.service',
  }
  if $user {
    augeas { 'varnishncsa user':
      incl    => '/etc/systemd/system/varnishncsa.service',
      lens    => 'Systemd.lns',
      changes => "Set Service/User ${user}",
    }
  }
  if $filename {
    augeas { 'varnishncsa filename':
      incl    => '/etc/systemd/system/varnishncsa.service',
      lens    => 'Systemd.lns',
      changes => "Set Service/ExecStart/arguments/*[preceding-sibling::*[1][.='-w']] ${filename}",
    }
  }
}
