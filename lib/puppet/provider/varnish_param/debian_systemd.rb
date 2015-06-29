require File.dirname(__FILE__) + '/../../../augeasproviders/varnish_param/debian'

Puppet::Type.type(:varnish_param).provide(:debian_systemd, :parent => AugeasProviders::VarnishParam::Debian) do
  desc "Manage varnish parameters on Debian 8"

  confine :feature => :augeas
  confine :osfamily => :debian
  defaultfor :operatingsystem => :debian, :operatingsystemmajrelease => '8'

  lens { 'Systemd.lns' }

  default_file { '/etc/systemd/system/varnish.service' }

  def self.base_path
    "$target/Service/ExecStart/arguments"
  end

  def self.set_base(aug, resource)
    aug.set('$target/Service/ExecStart/command', resource[:varnish_binary])
  end

  def self.next_arg(aug)
    num = next_seq(aug.match("#{base_path}/*"))
    "#{base_path}/#{num}"
  end

  def self.create_flag(aug, flag, resource)
    aug.set(next_arg(aug), flag)
  end

  def self.create_resource(aug, resource)
    aug.set(next_arg(aug), format_value(aug, resource, resource[:value]))
    aug.defvar('resource', resource_path(resource))
  end

  resource_path do |resource|
    flag = get_flag(resource)
    if flag == '-p'
      "#{base_path}/*[preceding-sibling::*[1]='#{flag}' and .=~regexp('#{resource[:name]}=.*')]"
    else
      "#{base_path}/*[preceding-sibling::*[1]='#{flag}']"
    end
  end
end
