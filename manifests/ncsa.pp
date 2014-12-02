class varnish::ncsa {
  Class['varnish'] -> Class['varnish::ncsa']

  service { 'varnishncsa':
    ensure => running,
    enable => true,
  }
}
