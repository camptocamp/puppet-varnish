module AugeasProviders
  module VarnishParam
    class Debian < Puppet::Type.type(:augeasprovider).provider(:default)
      def self.parse_value(resource, value)
        if ['listen_address', 'admin_listen_address'].include? resource[:name]
          value.split(':')[0]
        elsif ['listen_port', 'admin_listen_port'].include? resource[:name]
          value.split(':')[1]
        elsif FLAGS.has_key? resource[:name]
          value
        else
          # Parse for -p
          value.split('=')[1]
        end 
      end

      def self.format_value(aug, resource, value)
        if ['listen_address', 'admin_listen_address'].include? resource[:name]
          full_entry = aug.get('$resource')
          listen_port = full_entry.nil? ? '' : full_entry.split(':')[1]
          # Return nil if none of the values is set
          "#{value}:#{listen_port}" unless value.nil? && listen_port.empty?
        elsif ['listen_port', 'admin_listen_port'].include? resource[:name]
          full_entry = aug.get('$resource')
          listen_address = full_entry.nil? ? '' : full_entry.split(':')[0]
          # Return nil if none of the values is set
          "#{listen_address}:#{value}" unless listen_address.empty? && value.nil?
        elsif FLAGS.has_key? resource[:name]
          value
        else
          # Pass to -p
          "#{resource[:name]}=#{value}"
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
          # Default to -p
          '-p'
        end
      end

      def self.flag_path(resource)
        # Use * instead of value
        # so we can reuse it for the systemd provider
        flag = get_flag(resource)
        if flag == '-p'
          "#{base_path}/*[.='#{flag}' and following-sibling::*[1]=~regexp('#{resource[:name]}=.*')]"
        else
          "#{base_path}/*[.='#{flag}']"
        end
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
              elsif cur_arg == '-p'
                name, val = arg.split('=')
                resources << new(
                  :name   => name,
                  :ensure => :present,
                  :value  => val,
                  :target => target
                )
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
          klass.create_flag(aug, flag, resource) if aug.match(klass.flag_path(resource)).empty?
          klass.create_resource(aug, resource)
        end
      end

      def destroy
        augopen! do |aug|
          klass = self.class
          formatted = klass.format_value(aug, resource, nil)
          # Remove entry
          if resource[:name] =~ /listen_/ && formatted
            aug.set('$resource', formatted)
          else
            aug.defvar('flag', klass.flag_path(resource))
            aug.rm(klass.resource_path(resource))
            # Remove flag
            aug.rm('$flag')
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
  end
end
