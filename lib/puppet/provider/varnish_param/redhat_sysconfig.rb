require File.dirname(__FILE__) + '/../../../augeasproviders/varnish_param/redhat'

Puppet::Type.type(:varnish_param).provide(:redhat_sysconfig, :parent => AugeasProviders::VarnishParam::RedHat) do
  desc "Manage varnish parameters on RedHat 6"

  confine :feature => :augeas
  confine :osfamily => :redhat
  defaultfor :osfamily => :redhat, :operatingsystemmajrelease => '6'

  lens { 'Shellvars.lns' }

  default_file { '/etc/sysconfig/varnish' }

  resource_path do |resource|
    "$target/#{var_name(resource)}"
  end
end
