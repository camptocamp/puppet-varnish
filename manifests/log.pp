class varnish::log {
  Class['varnish'] -> Class['varnish::log']

  service { 'varnishlog':
    ensure => running,
    enable => true,
  }
}
