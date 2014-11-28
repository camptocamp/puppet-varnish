define varnish::config_entry(
  $value,
  $ensure = 'presen',
  $key    = $name,
) {
  shellvar { "varnish_${name}":
    ensure   => $ensure,
    target   => $::varnish::params_file,
    variable => $key,
    value    => $value,
  }
}
