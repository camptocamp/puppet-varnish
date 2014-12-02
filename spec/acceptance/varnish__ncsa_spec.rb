require 'spec_helper_acceptance'

describe 'varnish::ncsa' do

  context 'with distro package (EPEL for RedHat)' do

    before :all do
      pp = <<-EOS
        $source = $::osfamily ? {
          'Debian' => 'distro',
          'RedHat' => 'epel',
        }
        class { 'varnish::repo':
          source => $source,
        }
        package { 'varnish':
          ensure => 'absent',
        } ->
        package { 'varnish-libs':
          ensure => 'absent',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    context 'with defaults' do
      it 'should idempotently run' do
        pp = <<-EOS
        class { 'varnish':
          multi_instances => false,
        }
        class { 'varnish::ncsa': }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end
    end
  end

  context 'with upstream package' do

    before :all do
      pp = <<-EOS
        class { 'varnish::repo': }
        package { 'varnish':
          ensure => 'absent',
        } ->
        package { 'varnish-libs':
          ensure => 'absent',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    context 'with defaults' do
      it 'should idempotently run' do
        pp = <<-EOS
        class { 'varnish':
          multi_instances => false,
        }
        class { 'varnish::ncsa': }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end
    end
  end
end
