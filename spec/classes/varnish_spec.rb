require 'spec_helper'
describe 'varnish' do
  context 'when on RedHat' do
    let (:facts) { {
      :operatingsystem => 'RedHat',
      :osfamily        => 'Redhat',
    } }

    it { is_expected.to compile.with_all_deps }
  end
end
