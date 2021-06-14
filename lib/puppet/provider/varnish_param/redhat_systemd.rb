require File.dirname(__FILE__) + '/../../../augeasproviders/varnish_param/redhat'

Puppet::Type.type(:varnish_param).provide(:redhat_systemd, :parent => AugeasProviders::VarnishParam::RedHat) do
  desc "Manage varnish parameters on RedHat 7"

  confine :feature => :augeas
  confine :osfamily => :redhat
  defaultfor :osfamily => :redhat, :operatingsystemmajrelease => '7'
  defaultfor :osfamily => :redhat, :operatingsystemmajrelease => '8'

  lens { 'Shellvars.lns' }

  default_file { '/etc/varnish/varnish.params' }

  resource_path do |resource|
    "$target/#{var_name(resource)}"
  end
end
