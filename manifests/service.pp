class varnish::service {
  $ensure = $::varnish::start ? {
    true  => 'running',
    false => 'stopped',
  }
  service { 'varnish':
    ensure => $ensure,
    enable => $::varnish::enable,
  }
  ->
  service { 'varnishncsa':
    ensure => $ensure,
    enable => $::varnish::enable,
  }

  service { 'varnishlog':
    ensure => $ensure,
    enable => $::varnish::enable,
  }
}
