Puppet::Type.type(:varnish_param).provide(:redhat_sysconfig, :parent => Puppet::Type.type(:augeasprovider).provider(:default)) do
  desc "Manage varnish parameters on RedHat 6"

  confine :feature => :augeas
  defaultfor :osfamily => :redhat, :operatingsystemmajrelease => '6'

  lens { 'Shellvars.lns' }

  default_file { '/etc/sysconfig/varnish' }

  def self.var_name(resource)
    "varnish_#{resource[:name]}".upcase
  end

  resource_path do |resource|
    "$target/#{var_name(resource)}"
  end

  def create
    augopen! do |aug|
      klass = self.class
      variable = klass.var_name(resource)
      comment_path = "$target/#comment[.=~regexp('#{variable}')]"
      if aug.match(comment_path).empty?
        Puppet.debug("Inserting varnish_param #{variable} before DAEMON_OPTS")
        aug.insert('$target/DAEMON_OPTS', variable, true)
      else
        Puppet.debug("Inserting varnish_param #{variable} after existing comment")
        aug.insert(comment_path, variable, false)
      end
      aug.set(klass.resource_path(resource), resource[:value])
    end
  end

  attr_aug_accessor(:value, :label => :resource)
end
