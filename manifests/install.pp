class varnish::install {
  package { 'varnish':
    ensure => present,
  }
}
