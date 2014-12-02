class varnish::service {
  service { 'varnish':
    ensure => running,
    enable => true,
  }
}
