/*
== Class varnish::dispatch-log

Installs dispatch-log script and set its service

Dispatch-log is a perl script which will take varnishncsa output as
input and dispatch log according to vhosts.
It requires a configuration file which will contain :
- $LOGDIR: base log dir. (optional, default: /mnt/varnish)
- $pid_file: pid file (optional, default /var/run/dispatch-log.pid)
- a perl hashmap named "%groups" like this:

$groups{'vhost'} = 'subdirectory';

Warning! you cannot change $LOGDIR nor $pid_file without restarting the service

Requires:
- Class["varnish"]

*/
class varnish::dispatch-log {

  file {"/usr/local/bin/dispatch-log":
    ensure => present,
    mode   => 0755,
    group  => root,
    owner  => root,
    source => "puppet:///varnish/usr/local/bin/dispatch-log",
  }

  file {"/etc/init.d/dispatch-log":
    ensure => present,
    mode   => 0755,
    group  => root,
    owner  => root,
    source => "puppet:///varnish/etc/init.d/dispatch-log",
  }

  service { "dispatch-log":
    enable  => true,
    ensure  => "running",
    pattern => "bin/dispatch-log",
    require => [ Class["varnish"], File["/etc/init.d/dispatch-log"], File["/usr/local/bin/dispatch-log"] ],
  }

}
