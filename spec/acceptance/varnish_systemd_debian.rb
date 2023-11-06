require 'spec_helper_acceptance'

describe 'varnish_systemd_debian' do
  context 'set some varnishd param' do
    it 'should idempotently run' do
      pp = <<-EOS
      Service<| title == 'varnish' |> {
        provider => 'systemd',
      }
      class {'::varnish':
        listen_port     => '80',
        group           => 'varnish',
        multi_instances => false,
        secret_file     => '/etc/varnish/secret',
        user            => 'varnish',
      }

      varnish_param {'shm_reclen':
        value  => 4084,
        notify => [
          Exec['systemctl-daemon-reload'],
          Service['varnish'],
        ],
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)

    end
  end
end
