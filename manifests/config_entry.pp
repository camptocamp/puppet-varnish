define varnish::config_entry(
  $value,
  $key = $name,
) {
  shellvar { "varnish_${name}":
    ensure   => 'present',
    target   => $::varnish::params_file,
    variable => $key,
    value    => $value,
  }
}
