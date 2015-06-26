require 'spec_helper'

describe 'varnish' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context "with multi_instances" do
        let(:params) do
          {
            :multi_instances => true,
          }
        end

        it { is_expected.to compile.with_all_deps }
      end

      context "with mono instance" do
        let(:params) do
          {
            :multi_instances => false,
          }
        end

        if facts[:osfamily] == 'RedHat' or facts[:operatingsystemmajrelease,].to_i >= 8
          it { is_expected.to compile.with_all_deps }
        end
      end
    end
  end
end
