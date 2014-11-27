class varnish::config {
  create_resources(
    'varnish::config_entry',
    $::varnish::config_entries,
    {}
  )
}
