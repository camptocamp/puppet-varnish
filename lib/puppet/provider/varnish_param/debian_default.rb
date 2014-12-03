Puppet::Type.type(:varnish_param).provide(:debian_default, :parent => Puppet::Type.type(:augeasprovider).provider(:default)) do
  desc "Manage varnish parameters on Debian 7"

  confine :feature => :augeas
  confine :osfamily => :debian
  defaultfor :operatingsystem => :debian, :operatingsystemmajrelease => '7'

  lens { 'Shellvars_list.lns' }

  default_file { '/etc/default/varnish' }

  def self.parse_value(resource, value)
    case resource[:name]
    when 'listen_address', 'admin_listen_address'
      value.split(':')[0]
    when 'listen_port', 'admin_listen_port'
      value.split(':')[1]
    else
      value
    end 
  end

  def self.format_value(aug, resource, value)
    case resource[:name]
    when 'listen_address', 'admin_listen_address'
      full_entry = aug.get('$resource')
      listen_port = full_entry.nil? ? '' : full_entry.split(':')[1]
      # Return nil if none of the values is set
      "#{value}:#{listen_port}" if value && listen_port
    when 'listen_port', 'admin_listen_port'
      full_entry = aug.get('$resource')
      listen_address = full_entry.nil? ? '' : full_entry.split(':')[0]
      # Return nil if none of the values is set
      "#{listen_address}:#{value}" if listen_address && value
    else
      value
    end 
  end

  FLAGS = {
    'listen_address'       => '-a',
    'listen_port'          => '-a',
    'admin_listen_address' => '-T',
    'admin_listen_port'    => '-T',
    'vcl_conf'             => '-f',
    'group'                => '-g',
    'ttl'                  => '-t',
    'user'                 => '-u',
    'secret_file'          => '-S',
    'storage'              => '-s',
  }

  def self.get_flag(resource)
    if FLAGS.has_key? resource[:name]
      FLAGS[resource[:name]]
    else
      fail "Unknown varnish parameter '#{resource[:name]}'"
    end
  end

  def self.flag_path(flag)
    # Use * instead of value
    # so we can reuse it for the systemd provider
    "#{base_path}/*[.='#{flag}']"
  end

  def self.create_flag(aug, flag)
    aug.set("#{base_path}/value[.='#{flag}']", flag)
  end

  def self.base_path
    '$target/DAEMON_OPTS'
  end

  def self.set_base(aug, resource)
    # Set quote first
    aug.set("#{base_path}/quote", '"') unless aug.match('$target/DAEMON_OPTS/quote').any?
  end

  def self.create_resource(aug, resource)
    aug.defnode('resource', resource_path(resource),
                format_value(aug, resource, resource[:value]))
  end

  resource_path do |resource|
    "#{base_path}/value[preceding-sibling::value[1]='#{get_flag(resource)}']"
  end

  def self.instances
    resources = []
    augopen do |aug, path|
      cur_arg = nil
      aug.match("#{base_path}/*[label()!='quote']").each do |spath|
        arg = aug.get(spath)
        if arg =~ /^-\w$/
          cur_arg = arg
          next
        else
          if cur_arg == '-a'
            address, port = arg.split(':')
            resources << new(
              :name   => 'listen_address',
              :ensure => :present,
              :value  => address,
              :target => target
            ) unless address.empty?
            resources << new(
              :name   => 'listen_port',
              :ensure => :present,
              :value  => port,
              :target => target
            ) unless port.empty?
          elsif cur_arg == '-T'
            address, port = arg.split(':')
            resources << new(
              :name   => 'admin_listen_address',
              :ensure => :present,
              :value  => address,
              :target => target
            ) unless address.empty?
            resources << new(
              :name   => 'admin_listen_port',
              :ensure => :present,
              :value  => port,
              :target => target
            ) unless port.empty?
          else
            variable = FLAGS.select { |f, v| v == cur_arg }.flatten[0]
            resources << new(
              :name   => variable,
              :ensure => :present,
              :value  => arg,
              :target => target
            ) if variable
          end
        end
      end
    end
    resources
  end

  def create
    augopen! do |aug|
      klass = self.class
      klass.set_base(aug, resource)
      # Keep flag creation generic
      # so we can reuse it for the systemd provider
      flag = klass.get_flag(resource)
      klass.create_flag(aug, flag) if aug.match(klass.flag_path(flag)).empty?
      klass.create_resource(aug, resource)
    end
  end

  def destroy
    augopen! do |aug|
      klass = self.class
      # Remove entry
      if klass.format_value(aug, resource, nil)
        aug.set(klass.resource_path(resource),
                klass.format_value(aug, resource, nil))
      else
        aug.rm(klass.resource_path(resource))
        # Remove flag
        aug.rm(klass.flag_path(klass.get_flag(resource)))
        # Remove entry if empty
        # keep generic so we can reuse it with systemd
        aug.rm("#{klass.base_path}[count(*[label()!='quote'])=0]")
      end
    end
  end

  define_aug_method(:value) do |aug, resource|
    parse_value(resource, aug.get('$resource'))
  end

  define_aug_method!(:value=) do |aug, resource, value|
    aug.set('$resource', format_value(aug, resource, value))
  end
end
