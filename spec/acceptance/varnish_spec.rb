require 'spec_helper_acceptance'

describe 'varnish' do

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
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end

      describe port(6081) do
        it { is_expected.to be_listening }
      end

      describe port(6082) do
        it { is_expected.to be_listening }
        it do
          skip 'requires serverspec >= 2.0.0'
          is_expected.to be_listening.on('127.0.0.1').with('tcp')
        end
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
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end

      describe port(6081) do
        it { is_expected.to be_listening }
      end

      describe port(6082) do
        it { is_expected.to be_listening }
        it do
          skip 'requires serverspec >= 2.0.0'
          is_expected.to be_listening.on('127.0.0.1').with('tcp')
        end
      end
    end

    context 'whith some params' do
      it 'should idempotently run' do
        pp = <<-EOS
        class { 'varnish':
          multi_instances      => false,
          admin_listen_address => '0.0.0.0',
          admin_listen_port    => 6083,
          listen_address       => 'localhost',
          listen_port          => 6080,
          storage              => 'file,/var/lib/varnish/varnish_storage.bin,95%',
          ttl                  => 60,
        }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end

      describe port(6080) do
        it { is_expected.to be_listening }
      end

      describe port(6083) do
        it { is_expected.to be_listening }
        it do
          skip 'requires serverspec >= 2.0.0'
          is_expected.to be_listening.on('127.0.0.1').with('tcp')
        end
      end

      describe process('varnishd') do
        describe '#args' do
          subject { super().args }
          it { is_expected.to match /-s file,\/var\/lib\/varnish\/varnish_storage.bin,95%/ }
        end

        describe '#args' do
          subject { super().args }
          it { is_expected.to match /-t 60/ }
        end
      end
    end
  end

end
