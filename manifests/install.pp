class varnish::install(
  $install_varnish_modules = false,
) {
  package { 'varnish':
    ensure => present,
  }
  if $install_varnish_modules {
    package { 'varnish-modules':
      ensure => present,
    }
  }
}
