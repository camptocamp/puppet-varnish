define varnish::config_entry(
  $value,
  $ensure = 'present',
  $key    = $name,
) {
  Varnish::Config_entry[$title] ~> Service['varnish']
  shellvar { "varnish_${name}":
    ensure   => $ensure,
    target   => $::varnish::params_file,
    variable => $key,
    value    => $value,
  }
}
