module AugeasProviders
  module VarnishParam
    class RedHat < Puppet::Type.type(:augeasprovider).provider(:default)
      def self.var_name(resource)
        "varnish_#{resource[:name]}".upcase
      end

      def self.instances
        resources = []
        augopen do |aug, path|
          aug.match('$target/*[label()=~glob("VARNISH_*")]').each do |spath|
            variable = path_label(aug, spath).sub('VARNISH_', '').downcase
            resources << new(
              :name   => variable,
              :ensure => :present,
              :value  => aug.get(spath),
              :target => target
            )
          end
        end
        resources
      end

      def create
        augopen! do |aug|
          klass = self.class
          variable = klass.var_name(resource)
          comment_path = "$target/#comment[.=~regexp('#{variable}=.*')]"
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
  end
end
