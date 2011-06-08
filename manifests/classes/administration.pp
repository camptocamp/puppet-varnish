class varnish::administration {

  group { "varnish-admin":
    ensure => present,
  }

  sudo::directive { "varnish-administration":
    ensure => present,
    content => template("varnish/sudoers.varnish.erb"),
    require => Group["varnish-admin"],
  }

}
