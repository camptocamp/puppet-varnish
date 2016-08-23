require 'spec_helper_acceptance'

describe 'varnish' do

  context 'with distro package (EPEL for RedHat)' do

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
        it { is_expected.to be_listening.on('127.0.0.1').with('tcp') }
      end
    end

    context 'with varnishlog' do
      it 'should idempotently run' do
        pp = <<-EOS
        class { 'varnish':
          multi_instances => false,
        }
        class { 'varnish::log': }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end
    end

    context 'with varnishnsca' do
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

    context 'whith some params' do
      it 'should idempotently run' do
        pp = <<-EOS
        class { 'varnish':
          multi_instances      => false,
          admin_listen_address => '0.0.0.0',
          admin_listen_port    => 6083,
          listen_address       => 'localhost',
          listen_port          => 6080,
          storage              => 'file,/var/lib/varnish/varnish_storage.bin,100M',
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
        it { is_expected.to be_listening.on('0.0.0.0').with('tcp') }
      end

      describe process('varnishd') do
        describe '#args' do
          subject { super().args }
          it { is_expected.to match(/-s file,\/var\/lib\/varnish\/varnish_storage.bin,100M/) }
        end

        describe '#args' do
          subject { super().args }
          it { is_expected.to match(/-t 60/) }
        end
      end
    end

    context 'with broken vcl file' do
      it 'should idemptotently run' do
        pp = <<-EOS
        class { 'varnish':
          multi_instances      => false,
          admin_listen_address => '0.0.0.0',
          admin_listen_port    => 6082,
          listen_address       => 'localhost',
          listen_port          => 6081,
          storage              => 'file,/var/lib/varnish/varnish_storage.bin,100M',
          ttl                  => 60,
        }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end

      it 'should fail to reload but should not restart' do
        pp = <<-EOS
        class { 'varnish':
          multi_instances      => false,
          admin_listen_address => '0.0.0.0',
          admin_listen_port    => 6082,
          listen_address       => 'localhost',
          listen_port          => 6081,
          storage              => 'file,/var/lib/varnish/varnish_storage.bin,100M',
          ttl                  => 60,
          vcl_content          => 'Broken VCL file {',
        }
        EOS

        apply_manifest(pp, :expect_failures => true)
        # TODO: catch error message
      end

      describe port(6081) do
        it { is_expected.to be_listening }
      end

      describe port(6082) do
        it { is_expected.to be_listening }
        it { is_expected.to be_listening.on('0.0.0.0').with('tcp') }
      end
    end
  end
end
