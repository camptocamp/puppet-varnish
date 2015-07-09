require File.dirname(__FILE__) + '/../../../augeasproviders/varnish_param/debian'

Puppet::Type.type(:varnish_param).provide(:debian_default, :parent => AugeasProviders::VarnishParam::Debian) do
  desc "Manage varnish parameters on Debian 7"

  confine :feature => :augeas
  confine :osfamily => :debian
  defaultfor :operatingsystem => :debian, :operatingsystemmajrelease => '7'

  lens { 'Shellvars_list.lns' }

  default_file { '/etc/default/varnish' }

  def self.base_path
    '$target/DAEMON_OPTS'
  end

  def self.set_base(aug, resource)
    # Set quote first
    aug.set("#{base_path}/quote", '"') unless aug.match('$target/DAEMON_OPTS/quote').any?
  end

  def self.create_flag(aug, flag, resource)
    aug.set("#{base_path}/value[last()+1]", flag)
  end

  def self.create_resource(aug, resource)
    # Don't use defnode because of composite values where node value might be there already
    aug.set(resource_path(resource), format_value(aug, resource, resource[:value]))
    aug.defvar('resource', resource_path(resource))
  end

  resource_path do |resource|
    flag = get_flag(resource)
    if flag == '-p'
      "#{base_path}/value[preceding-sibling::value[1]='#{flag}' and .=~regexp('#{resource[:name]}=.*')]"
    else
      "#{base_path}/value[preceding-sibling::value[1]='#{flag}']"
    end
  end
end
