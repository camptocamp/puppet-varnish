require 'beaker-rspec'

hosts.each do |host|
  # Install puppet
  if ENV['PUPPET_AIO']
    install_puppet_agent_on host, {}
  else
    install_puppet_on host
    # Install ruby-augeas
    case fact('osfamily')
    when 'Debian'
      install_package host, 'libaugeas-ruby'
    when 'RedHat'
      install_package host, 'ruby-devel'
      install_package host, 'augeas-devel'
      on host, 'gem install ruby-augeas --no-ri --no-rdoc'
    else
      puts 'Sorry, this osfamily is not supported.'
      exit
    end
  end
end

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  module_name = module_root.split('-').last

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => module_root, :module_name => module_name)
    hosts.each do |host|
      on host, puppet('module','install','camptocamp-systemd'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','herculesteam-augeasproviders_core'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','herculesteam-augeasproviders_shellvar'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-apt'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
