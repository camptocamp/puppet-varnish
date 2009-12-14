/*

== Definition: varnish::instance

Creates a running varnishd instance and configures it's different startup
parameters. Optionnally a VCL configuration file can be provided. Have a look
at http://varnish.projects.linpro.no/wiki/Introduction for more details.


Parameters:
- *listen_address*: address of varnish's http service, defaults to all interfaces.
- *listen_port*: port varnish's http service must listen to, defaults to 6081.
- *admin_address*: address of varnish's admin console, defaults to localhost.
- *admin_port*: port of varnish's admin console, defaults to 6082.
- *backend*: location of the backend, in the "address:port" format. This is
  passed to "varnishd -b". Defaults to none.
- *vcl_file*: location of the instance's VCL file, located on puppet's
  fileserver (puppet://host/module/path.vcl). This is passed to "varnishd -f".
  Defaults to none.
- *vcl_content*: content of the instance's VCL file. Defaults to none.
- *storage_size*: size of varnish's cache, either in bytes (with a K/M/G/T suffix)
  or in percentage of the space left on the device. Defaults to 50%.
- *storage*: complete storage string, usually something like
  "file,/var/lib/varnish/varnish_storage.bin,1G".
- *params*: array of "key=value" strings to be passed to "varnishd -p"
  (run-time parameters). Defaults to none.
- *nfiles*: max number of open files (ulimit -n) allocated to varnishd,
  defaults to 131072.
- *memlock*: max memory lock size (ulimit -l) allocated to varnishd, defaults
  to 82000.
- *corelimit*: size of coredumps (ulimit -c). Usually "unlimited" or 0,
  defaults to 0.

See varnishd(1) and /etc/{default,sysconfig}/varnish for more details.


Requires:
- Class["varnish"]
- gcc if a VCL configuration file is used.


Example usage:

  include varnish

  varnish::instance { "foo":
    backend        => "10.0.0.2:8080",
    listen_address => "192.168.1.10",
    listen_port    => "80",
    admin_port     => "6082",
    storage_size   => "5G",
    params         => ["thread_pool_min=1",
                       "thread_pool_max=1000",
                       "thread_pool_timeout=120"],
  }

  varnish::instance { "bar":
    listen_address => "192.168.1.11",
    listen_port    => "80",
    admin_port     => "6083",
    vcl_file       => "puppet:///barproject/varnish.vcl",
    corelimit      => "unlimited",
  }

*/
define varnish::instance($listen_address="",
                         $listen_port="6081",
                         $admin_address="localhost",
                         $admin_port="6082",
                         $backend=false,
                         $vcl_file=false,
                         $vcl_content=false,
                         $storage_size="50%",
                         $storage=false,
                         $params=[],
                         $nfiles="131072",
                         $memlock="82000",
                         $corelimit="0") {

  # All the startup options are defined in /etc/{default,sysconfig}/varnish-nnn
  file { "varnish-${name} startup config":
    ensure  => present,
    content => template("varnish/varnish.erb"),
    name    => $operatingsystem ? {
      Debian => "/etc/default/varnish-${name}",
      Ubuntu => "/etc/default/varnish-${name}",
      RedHat => "/etc/sysconfig/varnish-${name}",
      Fedora => "/etc/sysconfig/varnish-${name}",
    },
  }

  if ($vcl_file != false) {
    file { "/etc/varnish/${name}.vcl":
      ensure  => present,
      source  => $vcl_file,
      require => Package["varnish"],
      notify  => Service["varnish-${name}"],
    }
  }

  if ($vcl_content) {
    file { "/etc/varnish/${name}.vcl":
      ensure => present,
      content => $vcl_content,
      require => Package["varnish"],
      notify  => Service["varnish-${name}"],
    }
  }

  # generate instance initscript by filtering the original one through sed.
  case $operatingsystem {

    Debian,Ubuntu: {
      exec { "create varnish-${name} initscript":
        command => "sed -r -e 's|(NAME=varnishd)|\\1-${name}|' -e 's|(/etc/default/varnish)|\\1-${name}|' /etc/init.d/varnish > /etc/init.d/varnish-${name}",
        creates => "/etc/init.d/varnish-${name}",
        require => Package["varnish"],
      }
    }

    RedHat,Fedora,CentOS: {
      exec { "create varnish-${name} initscript":
        command => "sed -r -e 's|(/etc/sysconfig/varnish)|\\1-${name}|g' -e 's|(/var/lock/subsys/varnish)|\1-${name}|' -e 's|(/var/run/varnish.pid)|\\1-${name}|' /etc/init.d/varnish > /etc/init.d/varnish-${name}",
        creates => "/etc/init.d/varnish-${name}",
        require => Package["varnish"],
      }
    }
  }

  file { "/etc/init.d/varnish-${name}":
    ensure  => present,
    mode    => 0755,
    owner   => "root",
    group   => "root",
    require => Exec["create varnish-${name} initscript"],
  }

  service { "varnish-${name}":
    enable  => true,
    ensure  => running,
    pattern => $operatingsystem ? {
      Debian => "/var/run/varnishd-${name}.pid",
      Ubuntu => "/var/run/varnishd-${name}.pid",
      RedHat => "/var/run/varnish.pid-${name}",
      Fedora => "/var/run/varnish.pid-${name}",
      CentOS => "/var/run/varnish.pid-${name}",
    },
    require => [File["/etc/init.d/varnish-${name}"], Service["varnishlog"]],
  }


}
